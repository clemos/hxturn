package turn.message;

using StringTools;
import haxe.io.Input;

@:enum
abstract MessageType(Int) to Int {

    var AllocateRequest:MessageType = 0x0003;
    var AllocateResponse:MessageType = 0x0103;
    var AllocateErrorResponse:MessageType = 0x0113;
    var SendRequest:MessageType = 0x0004;
    var DataIndication:MessageType = 0x0115;
    var SetActiveDestinationRequest:MessageType = 0x0006;
    var SetActiveDestinationResponse:MessageType = 0x0106;
    var SetActiveDestinationErrorResponse:MessageType = 0x0116;
    // The following TURN message types are not supported
    // by this extension and the server MUST NOT send them: 
    var SendRequestResponse:MessageType = 0x0104;
    var SendRequestErrorResponse:MessageType = 0x0114;

    // In addition, this extension does not support the
    // shared secret authentication mechanism. 
    // The following shared secret messages MUST NOT be used
    // by either the client or server: 
    var SharedSecretRequest:MessageType = 0x0002;
    var SharedSecretResponse:MessageType = 0x0102;
    var SharedSecretErrorResponse:MessageType = 0x0112;

    // STUN message types
    var BindingRequest:MessageType = 0x0001;
    var BindingResponse:MessageType = 0x0101;
    var BindingErrorResponse:MessageType = 0x0111;

    static var LABELS:Map<Int,String> = [
        AllocateRequest=>'AllocateRequest', 
        AllocateResponse=>'AllocateResponse', 
        AllocateErrorResponse=>'AllocateErrorResponse',
        SendRequest=>'SendRequest',
        DataIndication=>'DataIndication',
        SetActiveDestinationRequest=>'SetActiveDestinationRequest',
        SetActiveDestinationResponse=>'SetActiveDestinationResponse',
        SetActiveDestinationErrorResponse=>'SetActiveDestinationErrorResponse',
        SendRequestResponse=>'SendRequestResponse',
        SendRequestErrorResponse=>'SendRequestErrorResponse',
        SharedSecretRequest=>'SharedSecretRequest',
        SharedSecretResponse=>'SharedSecretResponse',
        SharedSecretErrorResponse=>'SharedSecretErrorResponse',
        BindingRequest=>'BindingRequest',
        BindingResponse=>'BindingResponse',
        BindingErrorResponse=>'BindingErrorResponse'
    ];

    function new(type:Int){
        this = type;
    }

    public inline function label(){
        return LABELS[this];
    }

    @:from public static inline function fromInt(code:Int):MessageType {
        if( !LABELS.exists(code) ) {
            throw 'Unknown message type: 0x${code.hex(4)}';
        }
        return new MessageType(code);
    }

    public static inline function read( i:Input ):MessageType {
        i.bigEndian = true;
        return fromInt(i.readUInt16());
    }

}