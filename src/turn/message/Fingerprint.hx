package turn.message;

import haxe.io.Bytes;

class Fingerprint {

    static inline var XOR = 0x5354554e;
    
    public static inline var FINGERPRINT_LENGTH = 8;
    
    public static function check( message:Bytes, fingerprint:Int ) {  
        // remove fingerprint from message
        var bytes = message.sub(0, message.length - FINGERPRINT_LENGTH);
        var messageFingerprint = make( bytes );

        return messageFingerprint == fingerprint;
    
    }

    public static function make( message:Bytes ):Int {
        return (haxe.crypto.Crc32.make( message ) ^ XOR) >>> 0;
    }

}