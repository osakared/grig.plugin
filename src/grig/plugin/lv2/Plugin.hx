package grig.plugin.lv2;

import haxe.io.Path;
import haxe.macro.Expr;
import haxe.macro.Context;

using  StringTools;

class Plugin
{

    private static function getBuildXml():String
    {
        var sourcePath = "${haxelib:grig.plugin}/src/grig/plugin/lv2";
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
        var className = Context.getLocalModule().toLowerCase();
        var haxeClassName = localClass.toString();
        var cppClassName = haxeClassName + '_obj';

        var fields = Context.getBuildFields();

        // For now, only supporting one plugin
        var exportCode = '
            #include "core/lv2.h"
            extern "C" {
                bool initialized = false;
                void initialize()
                {
                    if (!initialized) {
                        HX_TOP_OF_STACK
                        hx::Boot();
                        __boot_all();
                        initialized = true;
                    }
                }

                static LV2_Handle
                CLASSNAME_instantiate(const LV2_Descriptor*   descriptor,
                            double                            rate,
                            const char*                       bundle_path,
                            const LV2_Feature* const*         features)
                {
                    initialize();
                    auto id = CLASSOBJ::lv2_create_instance(rate);
                    return (LV2_Handle)id;
                }

                static void
                CLASSNAME_connect_port(LV2_Handle instance,
                                       uint32_t   port,
                                       void*      data)
                {
                    CLASSOBJ::lv2_connect_port((size_t)instance, port, data);
                }

                static void
                CLASSNAME_activate(LV2_Handle instance)
                {
                    CLASSOBJ::lv2_activate((size_t)instance);
                }

                static void
                CLASSNAME_run(LV2_Handle instance, uint32_t n_samples)
                {
                    CLASSOBJ::lv2_run((size_t)instance, n_samples);
                }

                static void
                CLASSNAME_deactivate(LV2_Handle instance)
                {
                    CLASSOBJ::lv2_deactivate((size_t)instance);
                }

                static void
                CLASSNAME_cleanup(LV2_Handle instance)
                {
                    CLASSOBJ::lv2_cleanup((size_t)instance);
                }

                static const void*
                CLASSNAME_extension_data(const char* uri)
                {
                    return NULL; // not supported yet
                }

                LV2_Descriptor CLASSNAME_descriptor = {
                    CLASSOBJ::getURI(),
                    CLASSNAME_instantiate,
                    CLASSNAME_connect_port,
                    CLASSNAME_activate,
                    CLASSNAME_run,
                    CLASSNAME_deactivate,
                    CLASSNAME_cleanup,
                    CLASSNAME_extension_data
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

        // Add static methods for managing instances
        // Keep track to make ints unique.. uuid would be better
        fields.push({
            name: "lv2_instance_count",
            access: [Access.APrivate, Access.AStatic],
            kind: FieldType.FVar(macro:cpp.SizeT, macro $v{0}),
            pos: pos,
        });

        // Map of instances of this plugin so that id can be passed around instead of pointers to cast
        fields.push({
            name:  "lv2_instances",
            access:  [Access.APrivate, Access.AStatic],
            kind: FieldType.FVar(null, Context.parse('new Map<cpp.SizeT, $haxeClassName>()', pos)), 
            pos: pos,
        });

        fields.push({
            name: "lv2_create_instance",
            access: [Access.APublic, Access.AStatic],
            kind: FieldType.FFun({
                args: [{
                    name: 'sampleRate',
                    type: macro:Float
                }],
                ret: macro:cpp.SizeT,
                expr: Context.parse('{
                    var instance = new ${haxeClassName}(sampleRate);
                    var instanceID = lv2_instance_count++;
                    lv2_instances.set(instanceID, instance);
                    return instanceID;
                }', pos),
            }),
            pos: pos,
        });

        fields.push({
            name: "lv2_connect_port",
            access: [Access.APublic, Access.AStatic],
            kind: FieldType.FFun({
                args: [{
                    name: 'instanceID',
                    type: macro:cpp.SizeT,
                }, {
                    name: 'port',
                    type: macro:cpp.UInt32,
                }, {
                    name: 'data',
                    type: macro:cpp.RawPointer<cpp.Void>,
                }],
                ret: macro:Void,
                expr: Context.parse('{
                    var instance = lv2_instances.get(instanceID);
                    instance.connectPort(port, data);
                }', pos),
            }),
            pos: pos
        });

        for (functionName in ['activate', 'deactivate', 'cleanup']) {
            fields.push({
                name: 'lv2_' + functionName,
                access: [Access.APublic, Access.AStatic],
                kind: FieldType.FFun({
                    args: [{
                        name: 'instanceID',
                        type: macro:cpp.SizeT,
                    }],
                    ret: macro:Void,
                    expr: Context.parse('{
                        var instance = lv2_instances.get(instanceID);
                        instance.$functionName();
                    }', pos),
                }),
                pos: pos
            });
        }

        fields.push({
            name: "lv2_run",
            access: [Access.APublic, Access.AStatic],
            kind: FieldType.FFun({
                args: [{
                    name: 'instanceID',
                    type: macro:cpp.SizeT,
                }, {
                    name: 'numSamples',
                    type: macro:cpp.UInt32,
                }],
                ret: macro:Void,
                expr: Context.parse('{
                    var instance = lv2_instances.get(instanceID);
                    instance.run(numSamples);
                }', pos),
            }),
            pos: pos
        });

        localClass.get().meta.add(":cppFileCode", [{ expr:EConst( CString( exportCode ) ), pos: pos }], pos );
        localClass.get().meta.add(":keep", [], pos);
        localClass.get().meta.add(":buildXml", [{ expr:EConst( CString( getBuildXml() ) ), pos: pos }], pos );

        return fields;
    }

}