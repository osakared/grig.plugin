package;

using grig.plugin.lv2.Instance;

class Main
{

    static function main()
    {
        var instance = Instance.load('../Amp/bin/Amp/output');
        trace(instance.uri);
    }

}
