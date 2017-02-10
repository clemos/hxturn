package turn;
import haxe.io.BytesInput;
import js.Error;
import js.node.Buffer;
import js.node.dgram.Socket;
import js.node.Dgram;
import js.node.net.Socket.SocketAdress;
import turn.message.Reader;

class Server {
    var udp : Socket;
    public function new(){
        udp = Dgram.createSocket("udp4");
        udp.on(SocketEvent.Error,onError);
        udp.on(SocketEvent.Message,onMessage);
        udp.on(SocketEvent.Listening,onListening);
        udp.on(SocketEvent.Close,onClose);
    }

    public function listen(port:Int){
        udp.bind(port);
    }

    function onError(e:Error){
        trace('got error',e);
    }

    function onMessage(buffer:Buffer, address:SocketAdress){
        //trace('got message', buffer,address);
        var bytes = buffer.hxToBytes();
        //var input = new BytesInput(bytes);
        var data = new Reader(bytes);
        var message = data.read();
        trace('got message',message);
    }

    function onListening(){
        trace('listening');
    }

    function onClose(){
        trace('closing');
    }

}