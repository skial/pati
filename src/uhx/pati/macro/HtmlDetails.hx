package uhx.pati.macro;

import haxe.macro.Type;
import haxe.macro.Expr;

using tink.MacroApi;

enum abstract HtmlFieldMetadata(String) to String from String {
    var _Default = ':default';
}

class HtmlDetails {

    public static function defaultValues(t:Type, ?follow:Bool = false):Null<Array<ClassField>> {
        var result = null;

        switch t {
            case TInst(_.get() => cls, _) if (cls.isExtern):
                var emptyDefaults = [];
                var defaults = [];

                for (field in cls.fields.get()) {
                    if (field.meta.has(_Default)) {
                        var meta = field.meta.extract(_Default)[0];

                        (meta.params.length == 0 ? emptyDefaults : defaults)
                        .push( field );

                    }
                }

                result = emptyDefaults.concat( defaults );

                if (follow && cls.superClass != null) {
                    result = result.concat( defaultValues( TInst(cls.superClass.t, cls.superClass.params), follow ) );
                }

            case x:
                trace( x );
        }

        return result;
    }

}