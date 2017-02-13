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
    var listener : ServerListener;

    public function new(listener:ServerListener){
        this.listener = listener;

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

        function processResponse( err:Null<js.Error>, response:Data ) {
            if( err != null && response != null ) {
                respond(address, response);
            }
        }

        switch( request.type ) {
            case MessageType.AllocateRequest: 
                listener.onAllocateRequest( request, processResponse );                

            case MessageType.BindingRequest:
                listener.onBindingRequest( request, processResponse );

            default:
                trace('nothing to do');
        }
    }

    function respond( address:SocketAdress, response:Data ) {
        var writer = new turn.message.Writer();
        writer.write(response);
        var message = writer.getBytes();
        trace('responding...',response);
        trace('to', address);
        var buf = js.node.Buffer.hxFromBytes(message);

        udp.send( buf,0, buf.length, address.port, address.address, function(err,int){
            trace('done responding',err,int);
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