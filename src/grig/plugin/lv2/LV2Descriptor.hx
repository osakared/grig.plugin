package grig.plugin.lv2; #if cpp

import cpp.Float64;
import cpp.ConstCharStar;

@:native('const LV2_Descriptor*')
extern class LV2Descriptor
{
    var URI:ConstCharStar;
    var instantiate:cpp.Callable<(descriptor:LV2Descriptor, sampleRate:Float64, bundlePath:ConstCharStar,
                                  features:cpp.RawConstPointer<LV2Feature>)->LV2Handle>;
}

#end