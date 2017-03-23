package peer;

import haxe.Json;
import js.node.webrtc.*;
import peer.Config;

class Server {

    var stunGun : turn.Server;
    var turnServer : turn.Server;
    var workerPool : WorkerPool;
    var config: ConfigData;

    function new(config:ConfigData){
        this.config = config;
        trace('starting peer server');
        

        stunGun = new turn.Server({
            onAllocateRequest:function(_,_){
                throw "not allowed";
            },
            onBindingRequest: function(request, cb){
                workerPool.getByStunGunTransactionId(request.message.transactionId, function(w){
                    trace('got binding request, sending offer',w.worker.ip, w.worker.port);
                    var response : turn.message.Data = {
                        type: turn.message.MessageType.BindingResponse,
                        transactionId: request.message.transactionId,
                        attributes: [
                            turn.message.attribute.Data.MappedAddress( w.worker.ip, w.worker.port ),
                            turn.message.attribute.Data.XorMappedAddress( w.worker.ip, w.worker.port ),
                            turn.message.attribute.Data.Software('stungun')
                        ]
                    }
                    cb(null, response);
                });
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
                        var data : AnswerData = haxe.Json.parse(u);

                        workerPool.getByAddress({address:data.address, port:data.port}, function(w){
                            var worker = w.worker;
                            var session = new SessionDescription(data.session);
                            trace('SETTING REMOTE DESCRIPTION', data.session);
                            if( !worker.hasRemoteDescription ){
                                worker.hasRemoteDescription = true;
                                worker.pc.setRemoteDescription(session,function(){
                                    trace('REMOTE DESCRIPTION SET', u);
                                }, function(err){
                                    trace('got error setting remote description',err);
                                });
                            } else {
                                trace('connecting...');
                            }
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

        workerPool = new WorkerPool(config);

    }

    static function main(){
        new Server(Config.get());
    }
}