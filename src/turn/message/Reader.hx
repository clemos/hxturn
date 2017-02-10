package turn.message;

import haxe.io.Bytes;
import haxe.io.BytesInput;
import haxe.io.Input;

import turn.message.MessageType;

class Reader {

    static inline var HEADER_LENGTH = 20;

    var bytes:Bytes;
    var input:Input;

    public function new(bytes:Bytes){
        this.bytes = bytes;
        this.input = new BytesInput(bytes);
    }

    function readHeader(){
        if( bytes.length < HEADER_LENGTH ) {
            throw 'Message too short, less than $HEADER_LENGTH bytes';
        }

        var type = MessageType.read(input);
        var length : Int = input.readInt16();

        var actualLength = bytes.length - HEADER_LENGTH;
        if( actualLength != length ) {
            throw 'Invalid message length, expecting $length, actual is $actualLength';
        }

        var transactionId = TransactionId.read(input);
        
        return { 
            type : type,
            length: length,
            transactionId: transactionId
        };
    }

    function readAttributes(){
       
    }

    public function read(){
        return {
            header: readHeader()
        };
    }
}