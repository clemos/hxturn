var RTCPeerConnection     = wrtc.RTCPeerConnection;
var RTCSessionDescription = wrtc.RTCSessionDescription;
var RTCIceCandidate       = wrtc.RTCIceCandidate;

var iceCandidates = [];
var googleIce = {url:'turn:stun.l.google.com:19302'};
var localIce = {
    url:'turn:127.0.0.1:3478',
    //username: 'test',
    //credential: 'toto'

};

//[{"candidate":"candidate:1195654268 1 udp 2113937151 10.111.0.119 38482 typ host generation 0 ufrag 4mp0 network-cost 50","sdpMid":"data","sdpMLineIndex":0},{"candidate":"candidate:842163049 1 udp 1677729535 62.23.184.220 38482 typ srflx raddr 10.111.0.119 rport 38482 generation 0 ufrag 4mp0 network-cost 50","sdpMid":"data","sdpMLineIndex":0}]

// [
// "v=0",
// "o=- 8121340498987220967 2 IN IP4 127.0.0.1",
// "s=-",
// "t=0 0",
// "a=msid-semantic: WMS",
// "m=application 9 DTLS/SCTP 5000",
// "c=IN IP4 0.0.0.0",
// "a=ice-ufrag:qP0Z",
// "a=ice-pwd:K8juiKC9sYaIV/prlkCpRPpo",
// "a=fingerprint:sha-256 58:5F:E7:D3:8F:8A:E0:0A:8F:E0:6C:37:9B:35:9C:AE:0F:86:FF:ED:75:8E:61:E4:FE:8F:0C:24:A7:C0:D0:72",
// "a=setup:active",
// "a=mid:data",
// "a=sctpmap:5000 webrtc-datachannel 1024",
// ""
// // ]
// {
//   type : 'offer',
//   sdp : [
//   "v=0", 
//   "o=- 2692847208124867750 2 IN IP4 127.0.0.1", 
//   "s=-", 
//   "t=0 0", 
//   "a=msid-semantic: WMS", 
//   "m=application 9 DTLS/SCTP 5000", 
//   "c=IN IP4 0.0.0.0", 
//   "a=ice-ufrag:Rm7S", 
//   "a=ice-pwd:93dI5NjyW80VFMCbMQtfn5sY", 
//   "a=fingerprint:sha-256 8E:03:6D:71:42:F6:5C:DD:69:53:87:FF:36:30:0D:B7:0C:81:26:0B:5B:09:42:D7:FF:BD:60:A1:92:E1:7B:AE", 
//   "a=setup:actpass", 
//   "a=mid:data", 
//   "a=sctpmap:5000 webrtc-datachannel 1024", 
//   ""
//   ]
//   .join("\r\n")
// };

function trace(){
    console.log.apply(arguments);
}

var pc = new RTCPeerConnection(
  {
    iceServers: [localIce]
  },
  {
    'optional': []
  }
);

pc.onnegotiationneeded = function(event){
  console.info('negociation needed', event);

  // pc.createOffer().then(function (answer) {
  //     return pc.setLocalDescription(offer);
  // }).then(function(){
  //   trace('done creating answer');


  // });
  


}

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
  console.log('got candidate', candidate);
  if( candidate == null ) {
    console.log('HERE IS THE ANSWER');
    console.log('reply('+JSON.stringify(pc.localDescription)+')');
  }
  
};




pc.ondatachannel=function(e){
  console.log('got datachannel',e);
}

var channel = pc.createDataChannel('TEST', {});
channel.binaryType = 'arraybuffer';
channel.onopen = function(){
  console.log('channel is open !!');
}

channel.onclose = function(event) {
  console.info('onclose');
};

channel.onmessage = function(event) {
  console.info('message from channel',event);
};

channel.onerror = function(e){
  console.warn('error connecting channel', e);
}

function addIceCandidates(){
  iceCandidates.map(function(sdp){
  var candidate = new RTCIceCandidate(sdp);
  pc.addIceCandidate(candidate, function(){
    console.log('success adding ice candidate', candidate);
  }, function(e){
    console.warn('problem adding ice candidate', candidate, e);
  });
});
}

function start( offerSdp ){
  var offer = new RTCSessionDescription(offerSdp);
  pc.setRemoteDescription(
      offer,
      function(){
        console.log('creating anwser...');
        pc.createAnswer(
          function(answer){
            pc.setLocalDescription(
              answer,
              function(){
                console.log('answer done');
                addIceCandidates();
              },
              trace
            );
            
          },
          trace
        );
      },
      trace
    );
}




// function doSetLocalDesc(desc){
//     //console.log('set local description',desc);
//     //console.log('set local description',desc.sdp);
//     pc.setLocalDescription(
//         new RTCSessionDescription(desc),
//         doSendOffer.bind(undefined, desc),
//         trace
//       );
// }

// function doSendOffer(offer){
//     console.log('SENDING OFFER',offer.sdp);
// }

// var channel = pc.createDataChannel('TEST', {});
// channel.binaryType = 'arraybuffer';

// pc.createOffer(doSetLocalDesc, trace);
