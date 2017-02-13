
class Main {

    static inline var PORT = 3480;
    static inline var ADDRESS = '127.0.0.1';

    static function main(){
        var server = new turn.Server();
        server.bind(PORT, ADDRESS);
    }
}