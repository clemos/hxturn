package peer;

import js.html.rtc.*;
import peer.Config;
import haxe.Json;

class Client {

    var config : ConfigData;

    var stunGun : StunGunClient;

    var pc : PeerConnection;

    function new(config:ConfigData){
        this.config = config;

        pc = new PeerConnection({
            iceServers: [{urls:['stun:${config.stun.address}:${config.stun.port}']}],
        }); 

        pc.oniceconnectionstatechange = function(){
            trace('CONNECTION STATE CHANGED', pc.iceConnectionState);
        }

        pc.ondatachannel = function(e){
            trace('GOT DATACHANNEL', e);
        }
        var channel = pc.createDataChannel("test");

        channel.onopen = function(){
            trace("CHANNEL IS OPEN");
        };

        channel.onmessage = function(m){
            trace("GOT MESSAGE",m.data);
        }

        pc.onicecandidate = function(c){
            if( c.candidate == null ){
                //trace('DONE');
                
            } else {
                trace('LOCAL CANDIDATE',c.candidate.candidate);
            }

        }

        respondToOffer(config.offer);
    }

    public function respondToOffer(offer) {
        stunGun = new StunGunClient(config.stunGun);
        stunGun.getServerAddress(function(address,port){
            trace('got address $address $port');

            var d = new SessionDescription(offer);
        
            pc.onicecandidate = function(c){
                trace('got local ice candidate');
                if( c.candidate == null ) {
                    trace('gathering finished, sending answer to server', pc.localDescription.sdp);
                    var turnClient = new TurnClient(config.turn);
                    turnClient.sendAnswer({
                        session:pc.localDescription,
                        address: address,
                        port: port
                    });
                }
            };

            pc.setRemoteDescription( d , function(){
                trace('successfully added remote desc');
                pc.createAnswer(function(a){
                    trace('got answer',a);
                    pc.setLocalDescription(new SessionDescription(a), function(){
                        trace('local description set');
                    }, function(err){
                        trace('error setting local description',err);
                    });
                }, function(err){
                    trace('failed creating anwser',err);
                });
            }, function(err){
                trace('error setting remote desc',err);
            } );


            var serverCandidate = {
                candidate:'candidate:1195654268 1 udp 2122260223 $address $port typ host generation 0',
                sdpMid : 'data', 
                sdpMLineIndex : 0
            };
            trace('adding ice candidate',serverCandidate);
            var c = new IceCandidate(serverCandidate);
            pc.addIceCandidate(c, function(){
                trace('success adding ice candidate');
            }, function(err){
                trace('error adding ice candidate');
                untyped console.log(err);
            } );
        });
    }

    function onServerAddress( address, port ) {
        trace('got server address', address, port);
    }

    static function main(){
       untyped window.rtcclient = new Client(Config.get());
    }
}

class StunGunClient {

    var pc : PeerConnection;

    public function new(config:ConfigAddress) {
        pc = new PeerConnection({
            iceServers: [{urls:['stun:${config.address}:${config.port}']}],
        });
    }

    public function getServerAddress( cb ) {
        pc.onicecandidate = function(c){
            if( c.candidate != null ) {
                trace('got stungun candidate ', c.candidate.candidate);
                var r = ~/candidate:[0-9]* 1 udp [0-9]* ([0-9.]*) ([0-9]*) typ srflx/gi;
                if( r.match(c.candidate.candidate) ) {
                    cb(r.matched(1),Std.parseInt(r.matched(2)));
                }
            }
        }
        var channel = pc.createDataChannel('test');

        pc.createOffer(function(offer){
            //trace('got offer',offer);
            pc.setLocalDescription(new SessionDescription(offer),function(){
                trace('local description set');
            }, function(err){
                trace('got error setting local descrition',err);
            } );
        }, function(err){
            trace('error creating offer',err);
        });
    }

}

class TurnClient {
    var config : ConfigAddress;

    public function new(config:ConfigAddress) {
        this.config = config;
    }

    public function sendAnswer(data:{session:SessionDescription,address:String,port:Int}) {
        trace('sending answer $data');
        var pc = new PeerConnection({
            iceServers: [{
                urls:['turn:${config.address}:${config.port}'],
                username: Json.stringify(data), // FIXME: data is too long in FF (513 ch)
                credential: "toto"
            }]
        });
        var channel = pc.createDataChannel('FOO');
        pc.onicecandidate = function(c){
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