package uhx.pati.macro;

import haxe.macro.Expr;
import haxe.macro.Context;

using tink.MacroApi;

class CustomElement {

    public static macro function build():Array<Field> {
        var fields = Context.getBuildFields();

        return fields;
    }

}