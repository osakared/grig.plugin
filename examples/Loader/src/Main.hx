package;

using grig.plugin.lv2.Instance;

class Main
{

    static function main()
    {
        var instance = Instance.load('amp.so');
        trace(instance.uri);
    }

}
