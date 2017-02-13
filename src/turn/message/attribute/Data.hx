package turn.message.attribute;

import haxe.io.Bytes;

@:enum abstract Protocol(Int) to Int {
    var UDP = 7;
    var TCP = 6;
}

@:enum abstract Family(Int) to Int {
    var IPV4 = 0x01;
    var IPV6 = 0x02;
}

abstract Address(Int) to Int {

    function new( ip:Int ){
        this = ip;
    }

    @:from public static function fromString( ip:String ) {
        var val = 0;
        var parts = ip.split('.').map(Std.parseInt);
        
        val += parts[0] << 24;
        val += parts[1] << 16;
        val += parts[2] << 8;
        val += parts[3];

        return new Address(val);
    }

}

enum Data {
    RequestedTransport( protocol:Int, rffu:Bytes );
    ErrorCode( code:Int, reason:String );
    Realm( realm:String );
    Nonce( nonce:String );
    Username( username:String );
    Software( username:String );
    Fingerprint( fingerprint:Int );

    MappedAddress( address:Address, port:Int );

    Unknown( type:AttributeType, data:Bytes );
}