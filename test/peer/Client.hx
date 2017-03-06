package peer;

import js.html.rtc.*;
import peer.Config;

class Client {

    var config : ConfigData;

    var stunGun : StunGunClient;

    var pc : PeerConnection;

    var JSON_OFFER : SessionDescriptionInit = {"type":SdpType.OFFER,"sdp":"v=0\r\no=- 105748813897781274 2 IN IP4 127.0.0.1\r\ns=-\r\nt=0 0\r\na=msid-semantic: WMS\r\nm=application 9 DTLS/SCTP 5000\r\nc=IN IP4 0.0.0.0\r\na=ice-ufrag:vP22M9MvRR7lhnxQ\r\na=ice-pwd:x3vuFY8eskba51ub5vbNFOO0\r\na=fingerprint:sha-256 1B:62:63:49:73:49:29:CB:E8:78:EA:35:1A:D2:A4:6F:A4:D4:79:0C:20:21:A5:CA:0A:A1:C8:2F:2F:10:4D:F4\r\na=setup:actpass\r\na=mid:data\r\na=sctpmap:5000 webrtc-datachannel 1024\r\n"};

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

        pc.onicecandidate = function(c){
            if( c.candidate == null ){
                //trace('DONE');
                
            } else {
                trace('LOCAL CANDIDATE',c.candidate.candidate);
            }

        }

        //respondToOffer(JSON_OFFER);
    }

    public function respondToOffer(offer) {
        var d = new SessionDescription(offer);
        pc.setRemoteDescription( d , function(){
            trace('successfully added remote desc');
            pc.createAnswer(function(a){
                trace('got answer',a);
                pc.setLocalDescription(new SessionDescription(a), function(){
                    trace('set local description');
                    var turnClient = new TurnClient(config.turn);
                    turnClient.sendAnswer(haxe.Json.stringify(pc.localDescription));
                }, function(err){
                    trace('error setting local description',err);
                });
            }, function(err){
                trace('failed creating anwser',err);
            });
        }, function(err){
            trace('error setting remote desc',err);
        } );

        stunGun = new StunGunClient(config.stunGun);
        stunGun.getServerAddress(function(address,port){
            trace('got address $address $port');

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

    public function sendAnswer(data:String) {
        trace('sending answer $data');
        var pc = new PeerConnection({
            iceServers: [{
                urls:['turn:${config.address}:${config.port}'],
                username: data,
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