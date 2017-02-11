package turn.message;

import haxe.io.Bytes;
import haxe.io.BytesInput;
import haxe.io.Eof;
import haxe.io.Input;

import turn.message.MessageType;
import turn.message.AttributeType;

class Reader {

    static inline var HEADER_LENGTH = 20;

    var bytes:Bytes;
    var input:Input;

    public function new(bytes:Bytes){
        this.bytes = bytes;
        this.input = new BytesInput(bytes);
    }

    function readHeader(){
        trace('HEADER');
        if( bytes.length < HEADER_LENGTH ) {
            throw 'Message too short, less than $HEADER_LENGTH bytes';
        }

        var type = MessageType.read(input);
        trace('==>',type.label());
        var length : Int = input.readUInt16();

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
       trace('ATTRIBUTES');
       while(true) {
        var attributeType:AttributeType = try{ 
            AttributeType.read(input); 
        } catch(e:Eof) {
            break;
        } catch(e:Dynamic) {
            throw 'Error reading input, $e';
        }

        switch(attributeType){
            case AttributeType.RequestedTransport:
                var transport = turn.message.attribute.RequestedTransport.read(input);
                trace('got request transport', transport);
            default:
                trace('got attribute', attributeType.label());        
        }
        
        // throw attributeType.label();
        // if( attributeType == AttributeType.Fingerprint ) {
        //     throw 'Not implemented';
        // } else {
        //     // switch(attributeType){

        //     // }
        // }
       }
       return [];
    }

    public function read(){
        trace('reading ${bytes.length} bytes');
        trace(bytes);
        return {
            header: readHeader(),
            attributes: readAttributes()
        };
    }
}