typedef AttributeData = turn.message.attribute.Data;

class Main {

    static inline var PORT = 3480;
    static inline var ADDRESS = '127.0.0.1';

    static var nonce = "91217987db7f0936";
    static var realm = "test";
    static var software = "None";
    

    static function main(){
        var server = new turn.Server({
            onAllocateRequest: function(request, cb){
                trace('allocate request');
                var response : turn.message.Data = {
                    type : turn.message.MessageType.AllocateErrorResponse,
                    transactionId: request.message.transactionId,
                    attributes : [
                        AttributeData.ErrorCode(401, "Unauthorized"),
                        AttributeData.Nonce(nonce),
                        AttributeData.Realm(realm),
                        AttributeData.Software(software)
                    ]
                };

                cb(null, response);
            },
            onBindingRequest: function(request, cb){
                trace('binding request');
                var response : turn.message.Data = {
                    type: turn.message.MessageType.BindingResponse,
                    transactionId: request.message.transactionId,
                    attributes: [
                        AttributeData.MappedAddress( request.from.address, request.from.port ),
                        AttributeData.Software(software)
                    ]
                }

                cb(null, response);
            }
        });
        server.bind(PORT, ADDRESS);
    }
}