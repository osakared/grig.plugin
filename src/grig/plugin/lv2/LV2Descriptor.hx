package grig.plugin.lv2; #if cpp

import cpp.ConstCharStar;

@:native('const LV2_Descriptor*')
extern class LV2Descriptor
{
    var URI:ConstCharStar;
}

#end