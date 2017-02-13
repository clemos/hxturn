package turn;
import haxe.io.BytesInput;
import js.Error;
import js.node.Buffer;
import js.node.dgram.Socket;
import js.node.Dgram;
import js.node.net.Socket.SocketAdress;
import turn.message.Data;
import turn.message.MessageType;
import turn.message.Reader;
import turn.message.attribute.AttributeType;

typedef AttributeData = turn.message.attribute.Data;

class Server {
    var udp : Socket;

    var nonce = "91217987db7f0936";
    var realm = "test";
    var software = "None";

    public function new(){
        udp = Dgram.createSocket("udp4");
        udp.on(SocketEvent.Error,onError);
        udp.on(SocketEvent.Message,onMessage);
        udp.on(SocketEvent.Listening,onListening);
        udp.on(SocketEvent.Close,onClose);
    }

    public function bind(port:Int, address:String){
        udp.bind(port,address);
    }

    function onError(e:Error){
        trace('got error',e);
    }

    function onMessage(buffer:Buffer, address:SocketAdress){
        //trace('got message', buffer,address);
        var bytes = buffer.hxToBytes();
        //var input = new BytesInput(bytes);
        var data = new Reader(bytes);
        var request = data.read();
        trace('got message',request.type.label(),request.attributes);
        trace('transaction = ', request.transactionId);

        switch( request.type ) {
            case MessageType.AllocateRequest: 

                for( a in request.attributes ) {
                    switch(a){
                        case Fingerprint(fingerprint) :
                            trace('CHECKING FINGERPRINT');
                            trace(turn.message.Fingerprint.check(bytes,fingerprint) ? 'OK': 'KO');
                        default:
                    }
                }
                // for( a in request.attributes ) {
                //     switch(a){
                //         case Unknown( AttributeType.RequestedAddressFamily, _ ):
                //             var response : turn.message.Data = {
                //                 header : {
                //                     type : MessageType.AllocateErrorResponse,
                //                     transactionId: request.header.transactionId
                //                 },
                //                 attributes : [AttributeData.ErrorCode(440, "Address Family not Supported")]
                //             };

                //             respond(address, response);
                //             return;
                //         default:
                //     }
                // }

                var response : turn.message.Data = {
                    type : MessageType.AllocateErrorResponse,
                    transactionId: request.transactionId,
                    attributes : [
                        AttributeData.ErrorCode(401, "Unauthorized"),
                        AttributeData.Nonce(nonce),
                        AttributeData.Realm(realm),
                        AttributeData.Software(software)
                    ]
                };

                respond(address, response);
            default:
                trace('nothing to do');
        }
    }

    function respond( address:SocketAdress, response:Data ) {
        var client = udp;//Dgram.createSocket('udp4');
        var writer = new turn.message.Writer();
        writer.write(response);
        var message = writer.getBytes();
        trace('responding...',response);
        trace('to', address);
        var buf = js.node.Buffer.hxFromBytes(message);

        client.send( buf,0, buf.length, address.port, address.address, function(err,int){
            trace('done responding',err,int);
            //client.close();
        });
    }

    function onListening(){
        trace('listening');
        trace(udp.address());
    }

    function onClose(){
        trace('closing');
    }

}