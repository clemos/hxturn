
class Main {

    static inline var PORT = 3478;

    static function main(){
        var server = new turn.Server();
        server.listen(PORT);
    }
}