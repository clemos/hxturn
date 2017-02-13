package turn.message;

import haxe.io.BytesOutput;
import haxe.io.Bytes;
import haxe.io.Output;
import turn.message.Data;

typedef AttributeWriter = turn.message.attribute.Writer;

class Writer {

    var output:BytesOutput;

    var addFingerprint=true;

    public function new(){
        output = new BytesOutput();
        output.bigEndian = true;
    }

    public function getBytes(){
        var bytes = output.getBytes();
        if( addFingerprint ) {
            var fp = turn.message.Fingerprint.make( bytes );
            var aWriter = new AttributeWriter();
            aWriter.writeAttribute(Fingerprint(fp));
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
        output.writeUInt16(length + (addFingerprint ? turn.message.Fingerprint.FINGERPRINT_LENGTH : 0) );
        output.writeBytes(transactionId, 0, transactionId.length);
    }

}