package grig.plugin.lv2; #if cpp

import cpp.RawConstPointer;
import cpp.Float64;
import cpp.ConstCharStar;

@:native('const LV2_Descriptor*')
extern class LV2Descriptor
{
    var URI:ConstCharStar;
    var instantiate:cpp.Callable<(descriptor:LV2Descriptor, sampleRate:Float64, bundlePath:ConstCharStar,
                                  features:cpp.RawConstPointer<LV2Feature>)->LV2Handle>;
    var connect_port:cpp.Callable<(handle:LV2Handle, port:cpp.UInt32, data:cpp.RawPointer<cpp.Void>)->Void>;
    var activate:cpp.Callable<(handle:LV2Handle)->Void>;
    var run:cpp.Callable<(handle:LV2Handle, sampleCount:cpp.UInt32)->Void>;
    var deactivate:cpp.Callable<(handle:LV2Handle)->Void>;
    var cleanup:cpp.Callable<(handle:LV2Handle)->Void>;
    var extension_data:cpp.Callable<(uri:ConstCharStar)->RawConstPointer<cpp.Void>>;
}

#end