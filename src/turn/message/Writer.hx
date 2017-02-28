package turn.message;

import haxe.io.BytesOutput;
import haxe.io.Bytes;
import haxe.io.Output;
import turn.message.Data;

private typedef AttributeWriter = turn.message.attribute.Writer;

class Writer {

    var output:Output;

    public function new(output:Output){
        output.bigEndian = true;
        this.output = output;
    }

    public function write(data:Data):Void {
        var aOutput = new BytesOutput();
        var aWriter = new AttributeWriter(aOutput);
        aWriter.write(data.attributes);
        var attributes = aOutput.getBytes();

        writeHeader(data.type, data.transactionId, attributes.length);
        output.writeBytes(attributes, 0, attributes.length);

    }

    function writeHeader(type:MessageType, transactionId:TransactionId, length:Int){
        output.writeUInt16(type);
        output.writeUInt16(length);
        output.writeBytes(transactionId, 0, transactionId.length);
    }

}