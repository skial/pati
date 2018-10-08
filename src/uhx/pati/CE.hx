package uhx.pati;

#if (eval || macro)
import haxe.macro.Expr;
#else
import js.Browser.*;
import js.html.CustomElementRegistry;
#end

using tink.CoreApi;

class CE {

    #if !(eval || macro)
    public static final registry:CustomElementRegistry = js.Syntax.field(window, "customElements");
    #end

    public static function main() {
        //if (CE.registry.get('foo-bar') == js.Lib.undefined) CE.registry.define('foo-bar', uhx.pati.ES5.ctor(CE.Thing));
        register([CE.Thing]).handle( o -> switch o {
            case Success(_): trace('done');
            case Failure(e): trace(e);
        });
		//var _ = new CE.Thing();
    }

    public static macro function register(customElements:ExprOf<Array<Class<Any>>>):ExprOf<Promise<Noise>> {
        return macro @:pos(customElements.pos) @:mergeBlock {
            @:privateAccess tink.core.Promise.ofOutcome(Error.catchExceptions( () -> {
                for (ce in $customElements) {
                    if (CE.registry.get(ce.htmlname) == js.Lib.undefined) CE.registry.define(ce.htmlname, uhx.pati.ES5.ctor(ce));
                }
                tink.core.Promise.NOISE;
            } ) );
        };
    }

}

#if !(eval || macro)
class Thing extends uhx.pati.Pati {

    public static var htmlname:String = 'foo-bar';

    public function new() {
        console.log('thing ctor', foo());
        
    }

    public function foo() return 'hello world';

    // Invoked each time the element is appended into the DOM.
    

    public static final observedAttributes:Array<String> = ['foo'];


}
#end