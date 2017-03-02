package auth;

typedef AttributeData = turn.message.attribute.Data;

class Server extends turn.Server {

    static var nonce = "91217987db7f0936";
    static var realm = "test";
    static var software = "None";

    public function new(){
        super({
            onAllocateRequest: function(request, cb){
                var hasUsername = false;
                for( a in request.message.attributes ) switch(a){
                    case AttributeData.Username(u):
                        hasUsername = true;
                        trace('got username', u);
                    default:
                        //trace('other attribute', Std.string(a));
                }

                var response : turn.message.Data = if( !hasUsername ) {
                    trace('no username, responding 401');
                    {
                        type : turn.message.MessageType.AllocateErrorResponse,
                        transactionId: request.message.transactionId,
                        attributes : [
                            AttributeData.ErrorCode(401, "Unauthorized"),
                            AttributeData.Nonce(nonce),
                            AttributeData.Realm(realm),
                            AttributeData.Software(software)
                        ]
                    };
                } else {
                    {
                        type : turn.message.MessageType.AllocateResponse,
                        transactionId: request.message.transactionId,
                        attributes : [
                            AttributeData.XorRelayedAddress(ADDRESS,1234),
                            AttributeData.Nonce(nonce),
                            AttributeData.Realm(realm),
                            AttributeData.Software(software)
                        ]
                    };
                }
                cb(null, response);
            },
            onBindingRequest: function(request, cb){
                //trace('binding request');
                var response : turn.message.Data = {
                    type: turn.message.MessageType.BindingResponse,
                    transactionId: request.message.transactionId,
                    attributes: [
                        AttributeData.MappedAddress( request.from.address, request.from.port ),
                        AttributeData.XorMappedAddress( request.from.address, request.from.port ),
                        AttributeData.Software(software)
                    ]
                }

                cb(null, response);
            }
        });
    }

    static inline var PORT = 3480;
    static inline var ADDRESS = '127.0.0.1';

    static function main(){
        var s = new Server();
        s.bind(PORT, ADDRESS);
    }
    
}