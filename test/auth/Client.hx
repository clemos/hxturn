package auth;

import js.html.rtc.*;

class Client {

    static function main(){

        // this is the arbitrary message we want to communicate to the server
        var message = {
            data: "COUCOU"
        };

        // this is our server coordinate, with our message as "username"
        var localIce = {
            urls: ['turn:127.0.0.1:3480'],
            username: haxe.Json.stringify(message),
            credential: 'test'
        };

        // create the PeerConnection
        var pc = new PeerConnection({
            iceServers: [localIce],
        });

        // create a channel (otherwise the ICE request is not done)
        var channel = pc.createDataChannel('FOO');
        
        // debug
        pc.onicecandidate = function(c){
            trace('got ice candidate');
            untyped console.log(c.candidate);
        }

        // create the offer + set LocalDescription to trigger ICE gathering
        pc.createOffer(function(desc){
            trace('got offer');
            pc.setLocalDescription(new SessionDescription(desc), function(){
                trace('local description set');
                pc.close();
            }, function(err){
                trace('got error setting local descrition',err);
                pc.close();
            } );
        }, function(err){
            trace('got error');
            pc.close();
        });
    }
}