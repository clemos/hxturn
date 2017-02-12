package turn.message;

import haxe.io.BytesOutput;
import haxe.io.Bytes;
import haxe.io.Output;
import turn.message.Data;

typedef AttributeWriter = turn.message.attribute.Writer;

class Writer {
    public static function write(data:Data):Bytes {
        var b = new BytesOutput();
        b.bigEndian = true;
        var aWriter = new AttributeWriter();
        aWriter.write(data.attributes);
        var attributes = aWriter.getBytes();

        writeHeader(b, data.type, data.transactionId, attributes.length);
        b.writeBytes(attributes, 0, attributes.length);

        return b.getBytes();

    }

    public static function writeHeader(b:Output, type:MessageType, transactionId:TransactionId, length:Int){
        b.writeUInt16(type);
        b.writeUInt16(length);
        b.writeBytes(transactionId, 0, transactionId.length);
    }
}