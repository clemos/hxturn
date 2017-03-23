package peer;

import haxe.io.Bytes;
import peer.Config;
import js.node.webrtc.*;

using Lambda;

class WorkerPool {

    static inline var POOL_SIZE = 5;
    
    var workers : Array<{
        worker: ServerWorker,
        ?stunGunTransactionId: Null<Bytes>
    }>;

    var config:ConfigData;

    var certificates:Array<Certificate>;
    var iceServers:Dynamic; // FIXME

    public function new(config:ConfigData){
        this.config = config;
        iceServers = [{
            urls: ['stun:${config.stun.address}:${config.stun.port}']
        }];
        certificates = [Certificate.fromPEM( config.cert )];

        workers = [];
        pool();
    }

    public function getNext(cb){
        var worker = workers.find(function(w){
            return w.stunGunTransactionId == null;
        });
        cb(worker);
    }

    public function getByAddress(address:{address:String,port:Int}, cb ){
        var worker = workers.find(function(w){
            return w.worker.ip == address.address && w.worker.port == address.port;
        });
        cb(worker);
    }

    public function getByStunGunTransactionId( id:Bytes, cb ):Void {
        var worker = workers.find(function(w){
            return (w.stunGunTransactionId != null) 
                && (id.compare(w.stunGunTransactionId) == 0);
        });

        if( worker != null ) {
            return cb( worker );
        }

        return getNext(function(w){
            w.stunGunTransactionId = id;
            cb(w);
        });
    }

    function pool(){
        trace('creating ${POOL_SIZE-workers.length}');
        if( workers.length < POOL_SIZE ) {
            createWorker(pool);
        }
    }

    function createWorker( cb ){

        var worker = new ServerWorker(iceServers, certificates);

        worker.start(config.offer,function(desc){
            trace('server address', worker.ip, worker.port);   
            workers.push({worker:worker});
            cb();
        });
    }

}