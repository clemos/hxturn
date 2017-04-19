## Basic STUN/TURN Server implementation in Haxe

This library implements a very minimal STUN/TURN server that is able to : 

* Require authentication, and read credentials, and thus receive data from web clients without web traffic :) (TURN only)

* Respond to STUN binding requests

These two features make it possible to establish WebRTC PeerConnection connections 
between a client and a "static" server, without signaling.


```
npm i // to install dependencies (haxe, etc.)
```

Then:
```
npm run test // builds test scripts and runs UTs
npm run start:auth-server // starts the TURN "auth server"
npm run serve // starts a local http server
```

Check "auth server demo" at : 
http://localhost:8080/test-auth-client.html

