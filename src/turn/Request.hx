package turn;

import js.node.net.Socket;
import turn.message.Data;

class Request {

    public var from (default,null) : SocketAdress;
    public var message (default,null) : Data;

    public function new( from:SocketAdress, message:Data ) {
        this.from = from;
        this.message = message;
    }
}