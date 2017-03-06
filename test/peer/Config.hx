package peer;

typedef ConfigAddress = {
     address: String,
    port: Int
}

typedef ConfigData = {
    stunGun : ConfigAddress,
    stun : ConfigAddress,
    turn : ConfigAddress
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
            }
        };
    }
}