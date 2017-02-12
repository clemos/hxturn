package turn.message.attribute;

import haxe.io.Bytes;
import haxe.io.Eof;
import haxe.io.Input;

import turn.message.attribute.Data;

class Reader {

    var input:Input;

    public function new(i:Input){
        input = i;
    }

    public function read():Array<Data> {
        var attributes = [];
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
                    attributes.push(readRequestedTransport());
                case AttributeType.Username:
                    attributes.push(Username(readAttribute().toString()));
                case AttributeType.Realm:
                    attributes.push(Realm(readAttribute().toString()));
                case AttributeType.Nonce:
                    attributes.push(Nonce(readAttribute().toString()));
                case AttributeType.Software:
                    attributes.push(Software(readAttribute().toString()));
                case AttributeType.Fingerprint:
                    attributes.push(Fingerprint(readAttribute().getInt32(0)));
                default:
                    attributes.push(Unknown(attributeType,readAttribute()));
            }
        }
        return attributes;
    }

    function readAttribute():Bytes {
        var length = input.readUInt16();
        var b = Bytes.alloc(length);
        input.readBytes(b,0,length);

        // drop until multiple of 4
        if( length%4 != 0 ) {
            for( i in 0...4-(length%4) ) {
                input.readByte();
            }
        }
        
        return b;
    }

    function readRequestedTransport():Data{
        var data = readAttribute();

        if( data.length != 4 ){ 
            throw 'Invalid Requested Transport length: ${data.length} should be 4';
        }

        return RequestedTransport( data.get(0), data.sub(1,3) );
    }
    
}