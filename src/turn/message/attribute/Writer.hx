package turn.message.attribute;

import haxe.io.BytesOutput;
import haxe.io.Bytes;

class Writer {
    var output : BytesOutput;
    
    public function new() {
        output = new BytesOutput();
        output.bigEndian = true;
    }

    function writeAttribute(type:Int,bytes:Bytes) {
        output.writeUInt16(type);
        output.writeUInt16(bytes.length);
        output.writeBytes(bytes, 0, bytes.length);
        if( bytes.length % 4 != 0 ){
            for( i in 0...4-(bytes.length % 4) ) {
                output.writeByte(0);
            }    
        }
        
    }

    public function getBytes():Bytes {
        return output.getBytes();
    }

    public function write(attributes:Array<Data>) {
        for(a in attributes) {
            var o = new BytesOutput();
            o.bigEndian = true;
            switch(a){
                case RequestedTransport(protocol, rffu):
                    o.writeByte(protocol);
                    o.writeBytes(rffu,0,rffu.length);
                    writeAttribute(AttributeType.RequestedTransport, o.getBytes());
                case ErrorCode(code,reason):
                    o.writeByte(0);
                    o.writeByte(0);
                    // Class
                    o.writeByte( Math.floor(code / 100) );
                    // Number
                    o.writeByte( code % 100 );
                    o.writeString(reason);

                    writeAttribute(AttributeType.ErrorCode, o.getBytes());
                case Realm(realm):
                    o.writeString(realm);
                    
                    writeAttribute(AttributeType.Realm, o.getBytes());

                case Nonce(nonce):
                    o.writeString(nonce);
                    
                    writeAttribute(AttributeType.Nonce, o.getBytes());

                case Username(username):
                    o.writeString(username);
                    
                    writeAttribute(AttributeType.Username, o.getBytes());

                case Unknown(type,data):
                    writeAttribute(type, data);

            }
        }
    }
}