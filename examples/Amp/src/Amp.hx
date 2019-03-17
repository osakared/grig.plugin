package;

@:build(grig.plugin.lv2.Plugin.export())
class Amp
{
    public var sampleRate(default, null):Float;

    public static function getURI():String
    {
        return "https://grig.io/eg-amp";
    } 

    public function new(_sampleRate:Float)
    {
        sampleRate = _sampleRate;
        trace('boink');
    }

}
