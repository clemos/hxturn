package auth;

import js.html.rtc.*;

class Client {

    static function main(){

        var message = {
            data: "COUCOU"
        };

        var localIce = {
            urls: ['stun:127.0.0.1:3480'],
            username: haxe.Json.stringify(message),
            credential: 'test'
        };

        var pc = new PeerConnection({
            iceServers: [localIce],
        });

        var channel = pc.createDataChannel('FOO');
        
        pc.onicecandidate = function(c){
            trace('got ice candidate');
            untyped console.log(c.candidate);
        }

        pc.createOffer(function(desc){
            trace('got offer');
            pc.setLocalDescription(new SessionDescription(desc), function(){
                trace('local description set');
            }, function(err){
                trace('got error setting local descrition',err);
            } );
        }, function(err){
            trace('got error');
        });
    }
}