import haxe.io.BytesOutput;
import haxe.io.BytesInput;
import turn.message.Data;

import turn.message.MessageType;
import turn.message.TransactionId;

private typedef AttributeData = turn.message.attribute.Data;

class FingerprintTest extends haxe.unit.TestCase {
  public function testSymetry() {
    var message = {
        type: MessageType.AllocateRequest,
        transactionId: TransactionId.random(),
        attributes: [
            AttributeData.Realm( "test.com" ),
            AttributeData.Nonce( "abcdefg" ),
            AttributeData.Username( "toto" ),
            AttributeData.Software( "hxturn" )
        ]
    };

    var o = new BytesOutput();
    var writer = new turn.message.Writer(o);
    writer.write(message);

    var wrote = o.getBytes();

    var fingerprinted = turn.message.Fingerprint.appendTo(wrote);

    var input = new BytesInput(fingerprinted);
    var reader = new turn.message.Reader(input);
    var read = reader.read();

    assertEquals(message.type,read.type);
    assertEquals(message.transactionId.toString(),read.transactionId.toString());

    var hasFingerprint = false;
    for(i in 0...read.attributes.length){
        var a = read.attributes[i];
        switch(a){
            case AttributeData.Fingerprint(fp): 
                assertTrue(turn.message.Fingerprint.check(fingerprinted,fp));
                hasFingerprint = true;
            case other:
                assertEquals(Std.string(a), Std.string(message.attributes[i])); 
        }
    }

    assertTrue(hasFingerprint);

  }
}