package turn.message;

using StringTools;
import haxe.io.Input;

@:enum abstract AttributeType(Int) to Int {
    var MappedAddress = 0x0001;
    var Username = 0x0006;
    var MessageIntegrity = 0x0008;
    var ErrorCode = 0x0009;
    var UnknownAttributes = 0x000A;
    var Lifetime = 0x000D;
    var AlternateServer = 0x000E;
    var MagicCookie = 0x000F;
    var Bandwidth = 0x0010;
    var DestinationAddress = 0x0011;
    var RemoteAddress = 0x0012;
    var Data = 0x0013;
    var Nonce = 0x0014;
    var Realm = 0x0015;
    var XorMappedAddress = 0x8020;

    var XorMappedAddressStun = 0x0020;
    var RealmStun = 0x0014; 
    var NonceStun = 0x0015;

    // The following optional attributes are also supported in
    // this extension. Any other attributes from the optional
    // attribute space SHOULD be ignored. 
    var MsVersion = 0x8008;
    var MsSequenceNumber = 0x8050;
    var MsServiceQuality = 0x8055;

    // rfc 5389
    var Software = 0x8022;
    var Fingerprint = 0x8028;

    // ietf-mmusic-ice
    var Priority = 0x0024;          // 32 bit unsigned integer
    var UseCandidate = 0x0025;      // has no content
    var IceControlled = 0x8029;     // 64 bit unsigned integer
    var IceControlling = 0x802a;    // 64 bit unsigned integer

    // rfc3489 - obsolete
    var ResponseAddress = 0x0002;
    var ChangeRequest = 0x0003;
    var SourceAddress = 0x0004;
    var ChangedAddress = 0x0005;
    var Password = 0x0007;
    var ReflectedFrom = 0x000B;

    // rfc5766 https://tools.ietf.org/html/rfc5766
    var ChannelNumber = 0x000C;
    var XorRelayedAddress = 0x0016;
    var EvenPort = 0x0018;
    var RequestedTransport = 0x0019;
    var DontFragment = 0x001A;
    var ReservationToken = 0x0022;



    static var LABELS:Map<Int,String> = [
        MappedAddress => 'MappedAddress',
        Username => 'Username',
        MessageIntegrity => 'MessageIntegrity',
        ErrorCode => 'ErrorCode',
        UnknownAttributes => 'UnknownAttributes',
        Lifetime => 'Lifetime',
        AlternateServer => 'AlternateServer',
        MagicCookie => 'MagicCookie',
        Bandwidth => 'Bandwidth',
        DestinationAddress => 'DestinationAddress',
        RemoteAddress => 'RemoteAddress',
        Data => 'Data',
        Nonce => 'Nonce',
        Realm => 'Realm',
        XorMappedAddress => 'XorMappedAddress',

        XorMappedAddressStun => 'XorMappedAddressStun',
        RealmStun => 'RealmStun',
        NonceStun => 'NonceStun',

        // The following optional attributes are also supported in
        // this extension. Any other attributes from the optional
        // attribute space SHOULD be ignored. 
        MsVersion => 'MsVersion',
        MsSequenceNumber => 'MsSequenceNumber',
        MsServiceQuality => 'MsServiceQuality',

        // rfc 5389
        Software => 'Software',
        Fingerprint => 'Fingerprint',

        // ietf-mmusic-ice
        Priority => 'Priority',         // 32 bit unsigned integer
        UseCandidate => 'UseCandidate',  // has no content
        IceControlled => 'IceControlled',    // 64 bit unsigned integer
        IceControlling => 'IceControlling',    // 64 bit unsigned integer

        // rfc3489 - obsolete
        ResponseAddress => 'ResponseAddress',
        ChangeRequest => 'ChangeRequest',
        SourceAddress => 'SourceAddress',
        ChangedAddress => 'ChangedAddress',
        Password => 'Password',
        ReflectedFrom => 'ReflectedFrom',

        // rfc5766 https://tools.ietf.org/html/rfc5766
    
        ChannelNumber => 'ChannelNumber',
        XorRelayedAddress => 'XorRelayedAddress',
        EvenPort => 'EvenPort',
        RequestedTransport => 'RequestedTransport',
        DontFragment => 'DontFragment',
        ReservationToken => 'ReservationToken',

    ];

    function new(type:Int){
        this = type;
    }

    public inline function label(){
        return LABELS[this];
    }

    @:from public static function fromInt(code:Int):AttributeType {
        if( !LABELS.exists(code) ) {
            throw 'Unknown attribute type: 0x${code.hex(4)}';
        }
        return new AttributeType(code);
    }

    public static inline function read( i:Input ):AttributeType {
        i.bigEndian = true;
        return fromInt(i.readUInt16());
    }
}