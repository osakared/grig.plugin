package;

using grig.plugin.lv2.Instance;
import tink.unit.Assert.*;

@:asserts
class LV2Test
{
    public function new()
    {

    }
    
    public function testWriteAndRead()
    {
        var instance = Instance.load('examples/Amp/bin/Amp/output');
        trace(instance.uri);
        return assert(true);
    }

}
