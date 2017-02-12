package turn.message.attribute;

import haxe.io.Bytes;

@:enum abstract Protocol(Int) to Int {
    var UDP = 7;
    var TCP = 6;
}

enum Data {
    RequestedTransport( protocol:Int, rffu:Bytes );
    ErrorCode( code:Int, reason:String );
    Realm( realm:String );
    Nonce( nonce:String );
    Username( username:String );

    Unknown( type:AttributeType, data:Bytes );
}