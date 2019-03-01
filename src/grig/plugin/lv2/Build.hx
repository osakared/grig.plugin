package grig.plugin.lv2;

import haxe.io.Path;
import haxe.macro.Expr;
import haxe.macro.Context;

using haxe.macro.PositionTools;

@:dox(hide)
class Build
{

    macro public static function xml():Array<Field>
    {
        var _pos =  Context.currentPos();
        var _pos_info = _pos.getInfos();
        var _class = Context.getLocalClass();

        var _source_path = Path.directory(_pos_info.file);
        if( !Path.isAbsolute(_source_path) ) {
            _source_path = Path.join([Sys.getCwd(), _source_path]);
        }

        _source_path = Path.normalize(_source_path);

        var _lib_path = Path.normalize(Path.join([_source_path, 'lv2/lv2']));

        var _xml = Xml.createDocument();

        var _files = Xml.createElement('files');
        _xml.addChild(_files);
        _files.set('id', 'haxe');
        _files.set('append', 'true');
        
        var _includePath = Xml.createElement('compilerflag');
        _includePath.set('value', '-I$_lib_path');
        _files.addChild(_includePath);

        var filesString = _files.toString();

        _class.get().meta.add(":buildXml", [{ expr:EConst( CString( filesString ) ), pos:_pos }], _pos );

        return Context.getBuildFields();
    }

}