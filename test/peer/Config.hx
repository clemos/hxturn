package peer;

typedef ConfigAddress = {
     address: String,
    port: Int
}

typedef CertificatePEM = Dynamic;

typedef ConfigData = {
    stunGun : ConfigAddress,
    stun : ConfigAddress,
    turn : ConfigAddress,
    offer : js.html.rtc.SessionDescriptionInit,
    cert: CertificatePEM
}

class Config {
    public static function get():ConfigData{
        return {
            stunGun : {
                address: '127.0.0.1',
                port: 4000
            },
            stun : {
                address: '127.0.0.1',
                port: 3478
            },
            turn : {
                address: '127.0.0.1',
                port: 3480
            },
            offer : { sdp: 'v=0\r\no=- 1972409902958240199 2 IN IP4 127.0.0.1\r\ns=-\r\nt=0 0\r\na=msid-semantic: WMS\r\nm=application 9 DTLS/SCTP 5000\r\nc=IN IP4 0.0.0.0\r\na=ice-ufrag:qDQm\r\na=ice-pwd:kYU72dpUXDmo56hFzn306HWl\r\na=fingerprint:sha-256 88:95:83:10:0B:4D:E4:C0:35:CC:23:50:A1:7C:E0:24:85:E1:85:BC:24:91:37:D9:3B:40:44:15:17:A7:40:CC\r\na=setup:actpass\r\na=mid:data\r\na=sctpmap:5000 webrtc-datachannel 1024\r\n',type: js.html.rtc.SdpType.OFFER },
            cert: {"privateKey":"-----BEGIN PRIVATE KEY-----\nMIICdQIBADANBgkqhkiG9w0BAQEFAASCAl8wggJbAgEAAoGBAMv7AYvU4L9SadHm\nzH3lU7UCnQPixTN2FH/ur2/RirEm+SnE05LTMaP8pDIB/+Z6eIz0G5heARnfGI+C\nbGt4ZKfh48G6Om5GtI7V+GP6g/vYHqNux0TdXyIL+Sa8NgvjQNhV0PPLHXzZLp8C\n1lEp8V9BnVMA9XDEWkDrLaGeRVn5AgMBAAECgYAQq5bYwrELccTMLryPnWpV5LzI\nUIQlTIUoX21fChT3nWPHkhpoaXIpIMCahadQQroPavPGZAhbAOyU7efGcLRpDqcE\ndTzJeC6I/JVrYoCRN//8t3NlHtbSYJKBT8CS+ziwC+KgMstK2ZHwLGYR5sQB2rdI\n4AFPsIgBZOM76geYMQJBAOU4aXrWxDt1JSBr4v65DmKI2wbPVTc1sy5wopikRJP7\nwrxeScMQpn8ZH9kWCJeWUbEYezpFu5gEnuIpXKBI/esCQQDjz7Z9qCvQXJvXqAlN\n0Hw/zcQ6FANs/+Mi5GMllRbaeFuL7+NR33KCxOxpHjzejFmG57TSoG1jyx8HdQgi\nVbqrAkBP62VLgQoWOPfi3/rbGSac0F6ddzic8UoyDO+EDPIkLoltJ+rL6khC1D24\ncOg6Ah0lhAWjAaEwlZvX+tfiwtBVAkAR00bsPiRvgU+QaE2SESYnt+oKwVYjSUJ0\nkHpRjoDjR1eic3rOBTXolZAKCZuprkGzFJ5JfNQSYupiov2n8h1RAkBbZSScuoRK\nBtVvyUqw1jwwsLmU8bbNGtRvp1z2IqCy3cehftqXm74bfRTeKHbI5rwvMvrkoM+K\nyG5uN9N5eydF\n-----END PRIVATE KEY-----\n","certificate":"-----BEGIN CERTIFICATE-----\nMIIBnjCCAQegAwIBAgIJAJJR1XwFPRNBMA0GCSqGSIb3DQEBCwUAMBExDzANBgNV\nBAMMBldlYlJUQzAeFw0xNzAzMTQxMDMyNDdaFw0xNzA0MTQxMDMyNDdaMBExDzAN\nBgNVBAMMBldlYlJUQzCBnzANBgkqhkiG9w0BAQEFAAOBjQAwgYkCgYEAy/sBi9Tg\nv1Jp0ebMfeVTtQKdA+LFM3YUf+6vb9GKsSb5KcTTktMxo/ykMgH/5np4jPQbmF4B\nGd8Yj4Jsa3hkp+Hjwbo6bka0jtX4Y/qD+9geo27HRN1fIgv5Jrw2C+NA2FXQ88sd\nfNkunwLWUSnxX0GdUwD1cMRaQOstoZ5FWfkCAwEAATANBgkqhkiG9w0BAQsFAAOB\ngQB0cWxoHqeFrF+C7ZACYuRBZcTEPaJ78CQLBiPwIR4FEpTRIYjLT1rBMdku9903\ne7XNJ716AbZGCFntP3Dovqy/AKEUpCJaVe9p+NfInoK/tEB2zTtlSByv3qJSm5yT\nyAQIae1nDz0+3aN/NFKIdrmQ7/0AKaK4r80P6cMK4cMuPQ==\n-----END CERTIFICATE-----\n"}
            // offer : {
            //     "type": js.html.rtc.SdpType.OFFER,
            //     "sdp": "v=0\r\no=- 105748813897781274 2 IN IP4 127.0.0.1\r\ns=-\r\nt=0 0\r\na=msid-semantic: WMS\r\nm=application 9 DTLS/SCTP 5000\r\nc=IN IP4 0.0.0.0\r\na=ice-ufrag:vP22M9MvRR7lhnxQ\r\na=ice-pwd:x3vuFY8eskba51ub5vbNFOO0\r\na=fingerprint:sha-256 1B:62:63:49:73:49:29:CB:E8:78:EA:35:1A:D2:A4:6F:A4:D4:79:0C:20:21:A5:CA:0A:A1:C8:2F:2F:10:4D:F4\r\na=setup:actpass\r\na=mid:data\r\na=sctpmap:5000 webrtc-datachannel 1024\r\n"
            // }
        };
    }
}