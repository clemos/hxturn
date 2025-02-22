package turn.message.attribute;

import haxe.io.BytesOutput;
import haxe.io.Bytes;
import haxe.io.Output;
import turn.message.attribute.Data;
import turn.message.MagicCookie;

class Writer {
    var output:Output;
    
    public function new(output:Output) {
        this.output = output;
        output.bigEndian = true;
    }

    function writeData(type:Int,bytes:Bytes) {
        output.writeUInt16(type);
        output.writeUInt16(bytes.length);
        output.writeBytes(bytes, 0, bytes.length);
        if( bytes.length % 4 != 0 ){
            for( i in 0...4-(bytes.length % 4) ) {
                output.writeByte(0);
            }    
        }
        
    }

    // public function getBytes():Bytes {
    //     return output.getBytes();
    // }

    public function writeAttribute(a:Data):Void {
        var o = new BytesOutput();
        o.bigEndian = true;
        switch(a){
            case RequestedTransport(protocol, rffu):
                o.writeByte(protocol);
                o.writeBytes(rffu,0,rffu.length);
                writeData(AttributeType.RequestedTransport, o.getBytes());
            
            case ErrorCode(code,reason):
                o.writeByte(0);
                o.writeByte(0);
                // Class
                o.writeByte( Math.floor(code / 100) );
                // Number
                o.writeByte( code % 100 );
                o.writeString(reason);

                writeData(AttributeType.ErrorCode, o.getBytes());
            case Realm(realm):
                o.writeString(realm);
                
                writeData(AttributeType.Realm, o.getBytes());

            case Nonce(nonce):
                o.writeString(nonce);
                
                writeData(AttributeType.Nonce, o.getBytes());

            case Software(software):
                o.writeString(software);
                
                writeData(AttributeType.Software, o.getBytes());

            case Username(username):
                o.writeString(username);
                
                writeData(AttributeType.Username, o.getBytes());

            case Fingerprint(fingerprint):
                o.writeInt32(fingerprint);
                
                writeData(AttributeType.Fingerprint, o.getBytes());

            case MappedAddress(ip, port):
                writeAddress(o, ip, port);
                writeData(AttributeType.MappedAddress, o.getBytes());

            case XorMappedAddress(ip, port):
                writeAddress(o, ip, port,true);
                writeData(AttributeType.XorMappedAddress, o.getBytes());

            case XorRelayedAddress(ip, port):
                writeAddress(o, ip, port, true);
                writeData(AttributeType.XorRelayedAddress, o.getBytes());


            case Unknown(type,data):
                writeData(type, data);

        }
    }

    inline function writeAddress(o:Output, ip:Address, port:Int, xor=false):Void{
        o.writeByte(0); // reserved

        // FIXME: ipv6
        o.writeByte(Family.IPV4);
        if( xor ){
            o.writeUInt16((port ^ ( MagicCookie.VALUE >> 16 ) ) & 0xffff);
            o.writeInt32(ip ^ MagicCookie.VALUE);
        } else {
            o.writeUInt16(port);
            o.writeInt32(ip);
        }
    }

    public function write(attributes:Array<Data>) {
        for(a in attributes) {
            writeAttribute(a);
        }
    }

    public static inline function encode(attributes:Array<Data>):Bytes{
        var o = new BytesOutput();
        var w = new Writer(o);
        w.write(attributes);
        return o.getBytes();
        
    }
}