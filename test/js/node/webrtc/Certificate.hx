package js.node.webrtc;

typedef CertificatePEM = Dynamic;

@:jsRequire('webrtc','RTCCertificate')
extern class Certificate extends js.html.rtc.Certificate {
    public static function fromPEM(pem:CertificatePEM):Certificate;
    public function toPEM():CertificatePEM;
}