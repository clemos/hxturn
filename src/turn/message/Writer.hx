package turn.message;

import haxe.io.BytesOutput;
import haxe.io.Bytes;
import haxe.io.Output;
import turn.message.Data;

typedef AttributeWriter = turn.message.attribute.Writer;

class Writer {

    var output:BytesOutput;

    var addFingerprint=false;

    static inline var FINGERPRINT_LENGTH = 8;

    public function new(){
        output = new BytesOutput();
        output.bigEndian = true;
    }

    public function getBytes(){
        var bytes = output.getBytes();
        if( addFingerprint ) {
            var crc32 = haxe.crypto.Crc32.make( bytes );
            var aWriter = new AttributeWriter();
            aWriter.writeAttribute(Fingerprint(crc32));
            var fingerprint = aWriter.getBytes();

            var o = new BytesOutput();
            o.bigEndian = true;
            o.writeBytes(bytes, 0, bytes.length);
            o.writeBytes(fingerprint, 0, fingerprint.length);

            return o.getBytes();
        }

        return bytes;
    }

    public function write(data:Data):Void {
        var aWriter = new AttributeWriter();
        aWriter.write(data.attributes);
        var attributes = aWriter.getBytes();

        writeHeader(data.type, data.transactionId, attributes.length);
        output.writeBytes(attributes, 0, attributes.length);

    }

    function writeHeader(type:MessageType, transactionId:TransactionId, length:Int){
        output.writeUInt16(type);
        output.writeUInt16(length + (addFingerprint ? FINGERPRINT_LENGTH : 0) );
        output.writeBytes(transactionId, 0, transactionId.length);
    }

}