package turn;
import haxe.io.BytesInput;
import haxe.io.BytesOutput;
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
    var adapter : Adapter;

    public function new(adapter:Adapter){
        this.adapter = adapter;

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
        //FIXME: probably needs try/catch in case the request parsing throws errors
        var bytes = new haxe.io.BytesInput(buffer.hxToBytes());
        var data = new Reader(bytes);
        var request = new Request( address, data.read() );
        
        function processResponse( err:Null<js.Error>, response:Data ) {
            if( err == null && response != null ) {
                respond(address, response);
            }
        }

        //trace('got message',request.message.type.label(),request.message.attributes);

        switch( request.message.type ) {
            case MessageType.AllocateRequest: 
                adapter.onAllocateRequest( request, processResponse );                

            case MessageType.BindingRequest:
                adapter.onBindingRequest( request, processResponse );

            default:
                // FIXME: implement others.
                trace('nothing to do');
        }
    }

    function respond( address:SocketAdress, response:Data ) {
        var data = new BytesOutput();
        var writer = new turn.message.Writer(data);
        writer.write(response);
        var message = data.getBytes();
        
        message = turn.message.Fingerprint.appendTo(message);
        
        var buf = js.node.Buffer.hxFromBytes(message);

        udp.send( buf,0, buf.length, address.port, address.address, function(err,int){
            //trace('done responding',err,int);
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