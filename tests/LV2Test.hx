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
        var instance = Instance.load('/home/pinkboi/src/lv2/build/plugins/eg-amp.lv2/eg-amp.lv2/amp');
        trace(instance.uri);
        return assert(true);
    }

}
