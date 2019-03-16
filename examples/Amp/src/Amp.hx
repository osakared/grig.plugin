package;

@:build(grig.plugin.lv2.Plugin.export())
class Amp
{
    public static function getURI():String
    {
        return "https://grig.io/eg-amp";
    } 

    public static function nada()
    {
        trace('boink');
    }

}
