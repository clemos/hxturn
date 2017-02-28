class Run {
    static function main(){
        var r = new haxe.unit.TestRunner();
        r.add(new FingerprintTest());
        r.run();
    }
}