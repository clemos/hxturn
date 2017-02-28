package turn.message;

import haxe.io.Bytes;
import haxe.io.BytesOutput;

typedef AttributeWriter = turn.message.attribute.Writer;
typedef AttributeData = turn.message.attribute.Data;

class Fingerprint {

    static inline var XOR = 0x5354554e;
    
    public static inline var FINGERPRINT_LENGTH = 8;
    public static inline var LENGTH_POS = 2;
    
    public static function check( message:Bytes, fingerprint:Int ) {  
        // remove fingerprint from message
        var bytes = message.sub(0, message.length - FINGERPRINT_LENGTH);
        var messageFingerprint = make( bytes );

        return messageFingerprint == fingerprint;
    
    }

    public static function make( message:Bytes ):Int {
        return (haxe.crypto.Crc32.make( message ) ^ XOR) >>> 0;
    }

    // FIXME: doesn't work
    public static function appendTo(message:Bytes):Bytes {
        var length = message.getUInt16( LENGTH_POS );
        message.setUInt16( 2, length + FINGERPRINT_LENGTH );

        var fp = make(message);
        var aOutput = new BytesOutput();
        var aWriter = new AttributeWriter(aOutput);
        aWriter.writeAttribute(AttributeData.Fingerprint(fp));
        var fingerprint = aOutput.getBytes();

        var output = new BytesOutput();
        output.bigEndian = true;
        output.writeBytes(message,0,message.length);
        output.writeBytes(fingerprint,0, fingerprint.length);

        return output.getBytes();
    }

}