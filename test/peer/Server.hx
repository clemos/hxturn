package peer;

import haxe.Json;
import js.node.wrtc.*;
import peer.Config;

class Server {

    var offers : Array<ServerOffer>;

    var POOL_SIZE = 1;

    var stunGun : turn.Server;
    var turnServer : turn.Server;

    var config: ConfigData;

    function new(config:ConfigData){
        this.config = config;
        offers = [];
        trace('starting peer server');
        pool();

        stunGun = new turn.Server({
            onAllocateRequest:function(_,_){
                throw "not allowed";
            },
            onBindingRequest: function(request, cb){
                
                var currentOffer = offers[0];

                if( currentOffer != null ) {
                    trace('got binding request, sending offer',currentOffer.ip, currentOffer.port);

                    var response : turn.message.Data = {
                        type: turn.message.MessageType.BindingResponse,
                        transactionId: request.message.transactionId,
                        attributes: [
                            turn.message.attribute.Data.MappedAddress( currentOffer.ip, currentOffer.port ),
                            turn.message.attribute.Data.XorMappedAddress( currentOffer.ip, currentOffer.port ),
                            turn.message.attribute.Data.Software('stungun')
                        ]
                    }
                    cb(null, response);
                }
            }
        });

        stunGun.bind(config.stunGun.port,config.stunGun.address);

        var nonce = '1234';
        var realm = 'toto.com';

        turnServer = new turn.Server({
            onAllocateRequest: function(request, cb){
                var hasUsername = false;
                for( a in request.message.attributes ) switch(a){
                    case turn.message.attribute.Data.Username(u):
                        hasUsername = true;
                        var currentOffer = offers[0];
                        var session = new SessionDescription(haxe.Json.parse(u));
                        currentOffer.pc.setRemoteDescription(session,function(){
                            trace('REMOTE DESCRIPTION SET', u);
                        }, function(err){
                            //trace('got error setting remote description',err);
                        });
                        
                    default:
                        //trace('other attribute', Std.string(a));
                }

                var response : turn.message.Data = if( !hasUsername ) {
                    trace('no username, responding 401');
                    {
                        type : turn.message.MessageType.AllocateErrorResponse,
                        transactionId: request.message.transactionId,
                        attributes : [
                            turn.message.attribute.Data.ErrorCode(401, "Unauthorized"),
                            turn.message.attribute.Data.Nonce(nonce),
                            turn.message.attribute.Data.Realm(realm),
                            turn.message.attribute.Data.Software('turngun')
                        ]
                    };
                } else {
                    {
                        type : turn.message.MessageType.AllocateResponse,
                        transactionId: request.message.transactionId,
                        attributes : [
                            //turn.message.attribute.Data.XorRelayedAddress(ADDRESS,1234),
                            turn.message.attribute.Data.Nonce(nonce),
                            turn.message.attribute.Data.Realm(realm),
                            turn.message.attribute.Data.Software('turngun')
                        ]
                    };
                }
                cb(null, response);
            },
            onBindingRequest: function(request, cb){
                //trace('binding request');
                var response : turn.message.Data = {
                    type: turn.message.MessageType.BindingResponse,
                    transactionId: request.message.transactionId,
                    attributes: [
                        turn.message.attribute.Data.MappedAddress( request.from.address, request.from.port ),
                        turn.message.attribute.Data.XorMappedAddress( request.from.address, request.from.port ),
                        turn.message.attribute.Data.Software('turngun')
                    ]
                }

                cb(null, response);
            }
        });

        turnServer.bind(config.turn.port,config.turn.address);
    }

    function pool(){
        trace('creating ${POOL_SIZE-offers.length}');
        if( offers.length < POOL_SIZE ) {
            createOffer(pool);
        }
    }

    function createOffer( cb ){
        
        var iceServers = [{
            urls: ['stun:${config.stun.address}:${config.stun.port}']
        }];

        var offer = new ServerOffer(iceServers);

        offer.start(function(desc){
            trace('server address', offer.ip, offer.port);   
            offers.push(offer);
            cb();
        });
    }

    static function main(){
        new Server(Config.get());
    }
}

class ServerOffer {

    public var pc (default,null) : js.html.rtc.PeerConnection;
    var channel : js.html.rtc.DataChannel;
    var description : js.html.rtc.SessionDescription; 
    var candidates : Array<js.html.rtc.IceCandidate>;

    public var ip (default,null): String;
    public var port (default,null): Int;

    public function new( iceServers ){
        candidates = [];
        pc = new PeerConnection({
            iceServers: iceServers,
        });
        pc.oniceconnectionstatechange = function(){
            trace('ICE CONNECTION STATE', pc.iceConnectionState);
        };
        channel = pc.createDataChannel('test');
        channel.onopen = function(){
            trace('CHANNEL IS OPEN');
        };
    }

    public function start( cb ){
        pc.onicecandidate = function(c){
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
        }

        pc.createOffer(function(offer){
            trace('HERE IS THE OFFER');
            trace(offer);
            trace(Json.stringify(offer));
            
            pc.setLocalDescription(new SessionDescription(offer),function(){
                trace('local description set');
            }, function(err){
                trace('got error setting local descrition',err);
            } );
        }, function(err){
            trace('error creating offer',err);
        });
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