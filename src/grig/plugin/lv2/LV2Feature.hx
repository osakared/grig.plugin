package grig.plugin.lv2; #if cpp

import cpp.ConstCharStar;
import cpp.RawPointer;
import cpp.Void;

@:native('LV2_Feature*')
extern class LV2Feature
{
    var URI:ConstCharStar;
    var data:RawPointer<Void>;
}

#end