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

    public function connectPort(port:cpp.UInt32, data:cpp.RawPointer<cpp.Void>):Void
    {
        trace('connectPort');
    }

    public function activate()
    {

    }

    public function deactivate()
    {
        trace('deactivated');
    }

    public function cleanup()
    {

    }

    public function run(numSamples:cpp.UInt32)
    {
        trace(numSamples);
    }

}
