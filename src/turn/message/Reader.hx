package turn.message;

import haxe.io.Bytes;
import haxe.io.BytesInput;
import haxe.io.Eof;
import haxe.io.Input;

import turn.message.MessageType;

private typedef AttributeReader = turn.message.attribute.Reader;

class Reader {

    static inline var HEADER_LENGTH = 20;

    var bytes:Bytes;
    var input:Input;

    public function new(input:Input) {
        this.input = input;
    }

    function readHeader(){
        // if( bytes.length < HEADER_LENGTH ) {
        //     throw 'Message too short, less than $HEADER_LENGTH bytes';
        // }

        var type = MessageType.read(input);
        var length : Int = input.readUInt16();

        // var actualLength = bytes.length - HEADER_LENGTH;
        // if( actualLength != length ) {
        //     throw 'Invalid message length, expecting $length, actual is $actualLength';
        // }

        var transactionId = TransactionId.read(input);

        return { 
            type : type,
            transactionId: transactionId
        };
    }

    function readAttributes(){
        // fixme: check length
        var reader = new AttributeReader(input);
        return reader.read();
    }

    public function read(){
        var header = readHeader();
        return {
            type: header.type,
            transactionId: header.transactionId,
            attributes: readAttributes()
        };
    }
}