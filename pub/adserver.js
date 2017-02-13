var RTCPeerConnection     = wrtc.RTCPeerConnection;
var RTCSessionDescription = wrtc.RTCSessionDescription;
var RTCIceCandidate       = wrtc.RTCIceCandidate;

var username = '';
for(var i=0; i<100; i++) {
  username += 'a';
}

var iceCandidates = [];
var googleIce = {url:'stun:stun.l.google.com:19302'};
var localIce = {
    urls: ['turn:127.0.0.1:3480'],
    //urls: ['turn:127.0.0.1:3478'],
    username: 'clemos',//username,
    credential: 'test'
};

function trace(){
    console.log.apply(arguments);
}

var pc = new RTCPeerConnection(
  {
    iceServers: [localIce],
    //peerIdentity: 'test'
  },
  {
    'optional': []
  }
);

pc.onpeeridentity = function(event){
    console.log('got peer identity',event);
}
pc.onsignalingstatechange = function(event)
{
  console.info("signaling state change: ", event.target.signalingState);
};
pc.oniceconnectionstatechange = function(event)
{
  console.info("ice connection state change: ", event.target.iceConnectionState);
};
pc.onicegatheringstatechange = function(event)
{
  console.info("ice gathering state change: ", event.target.iceGatheringState);
};
pc.onicecandidate = function(event)
{
  var candidate = event.candidate;
  if( candidate ) {
    console.log('got candidate');
    iceCandidates.push(candidate);
    console.log(JSON.stringify(iceCandidates));
  } else {
    doSendOffer();
  }
  
};

function doSetLocalDesc(desc){
    //console.log('set local description',desc);
    //console.log('set local description',desc.sdp);
    pc.setLocalDescription(
        new RTCSessionDescription(desc),
        function(){
            console.log('local description set',desc);
        },
        //doSendOffer.bind(undefined, desc),
        trace
      );
}

function doSendOffer(){
    console.info("HERE IS THE OFFER");
    console.log('start('+JSON.stringify(pc.localDescription)+')');
}

function reply(answer){
    console.log('replying to', answer);
    var s = new RTCSessionDescription(answer);
    pc.setRemoteDescription(s, 
        function(){
            console.log('DONE!!!');
        },
        trace
    );
}

pc.ondatachannel=function(){
  console.log('got datachannel');
}


var channel = pc.createDataChannel('TEST', {
    ordered: false,
    maxRetransmits: 10
});
channel.binaryType = 'arraybuffer';

channel.onopen = function(){
    console.log('channel open');
}

channel.onmessage = function(){
    console.log('channel message');
}

pc.createOffer(doSetLocalDesc, trace);
