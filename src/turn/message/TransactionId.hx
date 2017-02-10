package turn.message;

import haxe.io.Bytes;
import haxe.io.Input;

abstract TransactionId(Bytes) {

    static inline var LENGTH = 16;

    function new(id:Bytes){
        this=id;
    }

    public static inline function read( i:Input ):TransactionId {
        var b = Bytes.alloc(LENGTH);
        i.readBytes( b, 0, LENGTH );
        return new TransactionId(b);
    }
    
}