package turn.message;

import haxe.io.Bytes;
import haxe.io.BytesBuffer;
import haxe.io.BytesInput;
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

    public static function appendTo(message:Bytes):Bytes {

        var input = new BytesInput(message);
        input.bigEndian = true;
        var output = new BytesOutput();
        output.bigEndian = true;

        output.writeUInt16(input.readUInt16()); // copy type

        var length = input.readUInt16();
        output.writeUInt16(length+FINGERPRINT_LENGTH); // increase length by fingerprint length

        var rest = input.readAll();
        output.writeBytes(rest, 0, rest.length);

        var bytes = output.getBytes();
        var fp = AttributeWriter.encode( [AttributeData.Fingerprint(make(bytes))] );

        var result = new BytesBuffer();
        result.add(bytes);
        result.add(fp);

        return result.getBytes();

    }

}