package uhx.pati;

#if (eval || macro)
import haxe.macro.Expr;

using tink.MacroApi;
#end

class ES5 {

    public static macro function ctor<T>(cls:ExprOf<Class<T>>):ExprOf<Class<T>> {
        return macro @:mergeBlock {
            var cls = js.Syntax.code("class extends HTMLElement {static get observedAttributes() { return {1}; } constructor() { super(); {0}.call(this); } }", $cls, $cls.observedAttributes);
            js.Syntax.code("Object.setPrototypeOf( {0}.prototype, {1}.prototype )", cls, $cls);
            cls;
        }
    }

}