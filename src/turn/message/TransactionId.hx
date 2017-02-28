package turn.message;

import haxe.io.Bytes;
import haxe.io.Input;

@:forward(length)
abstract TransactionId(Bytes) to Bytes {

    public static inline var LENGTH = 16;

    function new(id:Bytes){
        this=id;
    }

    @:to public function toString():String{
        return this.toHex();
    }

    public static inline function read( i:Input ):TransactionId {
        var b = Bytes.alloc(LENGTH);
        i.readBytes( b, 0, LENGTH );
        return new TransactionId(b);
    }

    public static inline function random():TransactionId {
        var b = Bytes.alloc(LENGTH);
        for( i in 0...LENGTH ) {
            b.set(i, Std.random(256));
        }
        return new TransactionId(b);
    }
    
}