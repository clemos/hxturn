package turn.message.attribute;

import haxe.io.Bytes;
import haxe.io.Input;

typedef RequestedTransportData = {
    protocol: Int,
    rffu: Bytes
}

class RequestedTransport {

    static inline var LENGTH = 4;

    public static inline var UDP = 7;
    public static inline var TCP = 6;

    public static function read(input:Input):RequestedTransportData {
        var length = input.readUInt16();

        if( length != LENGTH ){ 
            throw 'Invalid Requested Transport length: $length should be $LENGTH';
        }

        var protocol = input.readByte();
        
        var rffu = Bytes.alloc(3);
        input.readBytes(rffu, 0, 3);

        return {
            protocol: protocol,
            rffu: rffu
        };
    }
    
}