package peer;

import js.node.webrtc.*;
import peer.Config;

class ServerWorker {

    public var pc (default,null) : js.html.rtc.PeerConnection;
    var channel : js.html.rtc.DataChannel;
    var description : js.html.rtc.SessionDescription; 
    var candidates : Array<js.html.rtc.IceCandidate>;

    public var ip (default,null): String;
    public var port (default,null): Int;
    public var hasRemoteDescription = false;

    public function new( iceServers, certs:Array<Certificate> ){
        candidates = [];
        pc = new PeerConnection(untyped {
            iceServers: iceServers,
            certificates: certs
        });
        pc.addEventListener('iceconnectionstatechange', function(){
            trace('ICE CONNECTION STATE', pc.iceConnectionState);
        });
        pc.addEventListener('datachannel', function(c){
            trace('got datachannel',c);
            c.channel.send('HELLO');
        });
        channel = pc.createDataChannel('test');
        channel.onopen = function(){
            trace('CHANNEL IS OPEN');
        };
    }

    public function start( offer:js.html.rtc.SessionDescriptionInit, cb ){
        pc.addEventListener('icecandidate', function(c){
            trace('got ice candidate',c.candidate);
            if( c.candidate != null ) {
                candidates.push(c.candidate);
                var r = ~/candidate:[0-9]* [0-9] udp [0-9]* ([0-9.]*) ([0-9]*) typ host generation 0/i;
                if( r.match(c.candidate.candidate) ) {
                    ip = r.matched(1);
                    port = Std.parseInt(r.matched(2));
                }
            }else{
                description = pc.localDescription;
                cb(description);
            }
        });

        pc.setLocalDescription(new SessionDescription(offer),function(){
            trace(pc.peerIdentity);
            trace('local description set');
        }, function(err){
            trace(pc);
            trace('got error setting local descrition',err);
        } );
        
    }

    public function getAddress(){
        var r = ~/a=candidate:[0-9]* 1 udp [0-9]* ([0-9.]*) ([0-9]*) typ host generation 0/gi;

        for( l in description.sdp.split("\n") ){
            if( r.match(l) ) {
                trace('got address', r.matched(1), r.matched(2));
            }
        }

    }
}