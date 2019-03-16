package grig.plugin.lv2;

import haxe.io.Path;
import haxe.macro.Expr;
import haxe.macro.Context;

using  StringTools;

class Plugin
{

    private static function getBuildXml():String
    {
        var sourcePath = "${haxelib:grig.plugin}/src/grig/plugin/lv2";// Path.directory(posInfo.file);
        sourcePath = Path.normalize(sourcePath);

        var libPath = Path.normalize(Path.join([sourcePath, 'lv2/lv2']));

        var xml = Xml.createDocument();

        var files = Xml.createElement('files');
        xml.addChild(files);
        files.set('id', 'haxe');
        files.set('append', 'true');
        
        var _includePath = Xml.createElement('compilerflag');
        _includePath.set('value', '-I$libPath');
        files.addChild(_includePath);

        return files.toString();
    }

    macro public static function export():Array<Field>
    {
        var pos =  Context.currentPos();
        var localClass = Context.getLocalClass();
        var className = Context.getLocalModule().toLowerCase(); // It would be better if I could easily snake_case it
        var cppClassName = Context.getLocalClass().toString() + '_obj';

        // var fields = Context.getBuildFields();// localClass.get().fields.get();
        // trace(fields);
        // var uri:String = null;
        // for (field in fields) {
        //     if (field.name == 'uri') {
        //         uri = field
        //     }
        //     trace(field);
        // }

        // For now, only supporting one plugin
        var exportCode = '
            #include "core/lv2.h"
            extern "C" {
                LV2_Descriptor CLASSNAME_descriptor = {
                    CLASSOBJ::getURI(),
                    NULL,//instantiate,
                    NULL,//connect_port,
                    NULL,//activate,
                    NULL,//run,
                    NULL,//deactivate,
                    NULL,//cleanup,
                    NULL,//extension_data
                };

                LV2_SYMBOL_EXPORT
                const LV2_Descriptor*
                lv2_descriptor(uint32_t index)
                {
                    switch (index) {
                        case 0:  return &CLASSNAME_descriptor;
                        default: return NULL;
                    }
                }
            }
        ';
        exportCode = exportCode.replace('CLASSNAME', className).replace('CLASSOBJ', cppClassName);

        localClass.get().meta.add(":cppFileCode", [{ expr:EConst( CString( exportCode ) ), pos: pos }], pos );
        localClass.get().meta.add(":keep", [], pos);
        localClass.get().meta.add(":buildXml", [{ expr:EConst( CString( getBuildXml() ) ), pos: pos }], pos );

        return Context.getBuildFields();
    }

}