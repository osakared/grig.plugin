package grig.plugin.lv2; #if cpp

using StringTools;

@:build(grig.plugin.lv2.Build.xml())
@:cppInclude('core/lv2.h')
class Instance
{
    public var uri(default, null):String;

    private function new()
    {
    }

    static public function getLibExtension():String
    {
        #if windows
        return '.dll';
        #elseif macos || ios
        return '.dylib';
        #else
        return '.so';
        #end
    }

    public static function load(libName:String):Instance
    {
        var instance = new Instance();
        
        // if (!libName.endsWith(getLibExtension())) {
        //     libName += getLibExtension();
        // }

        var lv2Descriptor:LV2DescriptorFunction = cpp.Function.getProcAddress(libName, 'lv2_descriptor');
        var descriptor = lv2Descriptor(0);
        instance.uri = descriptor.URI;

        return instance;
    }
}

#end