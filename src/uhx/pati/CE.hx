package uhx.pati;

#if (eval || macro)
import haxe.macro.Expr;
#else
import js.Browser.*;
import js.html.HtmlElement;
import js.html.MutationObserverInit;
import js.html.CustomElementRegistry;
#end

using tink.CoreApi;

class CE {

    #if !(eval || macro)
    public static final registry:CustomElementRegistry = js.Syntax.field(window, "customElements");
    #end

    public static function main() {
        #if !(eval||macro) 
        window.document.addEventListener('DOMContentLoaded', _ -> Empty.main());
        #end
        setup().handle( o -> switch o {
            case Success(_): trace('done');
            case Failure(e): trace(e);
        });
    }

    public static macro function setup():ExprOf<Promise<Noise>> {
        var map = uhx.pati.macro.CustomElement.knownComponents;
        var array = [for (k in map.keys()) map.get(k)];
        return macro @:mergeBlock {
            trace('booting custom elements');
            CE.register([$a{array}]);
        }
    }

    public static macro function register(customElements:ExprOf<Array<Class<{htmlName:String}>>>):ExprOf<Promise<Noise>> {
        return macro @:pos(customElements.pos) @:mergeBlock {
            @:privateAccess tink.core.Promise.ofOutcome(Error.catchExceptions( () -> {
                for (ce in $customElements) {
                    if (CE.registry.get(ce.htmlName) == js.Lib.undefined) CE.registry.define(ce.htmlName, uhx.pati.ES5.ctor(ce));
                }
                tink.core.Promise.NOISE;
            } ) );
        };
    }

}

@:tag('foo-bar')
class Thing extends uhx.pati.CE1 {

    @:attr public var foo:String;
    @:attribute public var bar:Int;
    @:attr('fooy') public var thing:Float;

    /**
    @:attr is short for @:attribute.
    @:attr(value) is an alternative name to match against.
    Attribute names automatically get put into `observedAttributes`.
    **/

    public static var observedAttributes = ['foo'];

    public function new() {

    }

}


enum abstract MutationType(String) to String {
    var ChildList = 'childList';
    var Attributes = 'attributes';
    var CharacterData = 'characterData';
}

#if !(eval || macro)
@:build(uhx.pati.macro.PhantomElement.build())
/**
Automatically uses lowercase type name if the meta is missing.
`data-controller="empty"` is optional. Let the macro autogenerate for you.
---
The macro will generate a unique id for each controller and generate faster
access. As attributes selectors are one of the slower ways to search for elements.
**/

@:data.controller('empty')
/*@:html(
<div data-controller="empty">
    <span data-target="empty.bar" data-empty-bar="1"></span>
    <input data-target="empty.foo" type="text" value="bob">
    <button data-action="click->empty#sayHello">Say Hi!</button>
</div>
)*/
/*@:html(
<div data-controller='${this}'>
    <span data-target='${this.bar}' data-attr-bar="1"></span>
    <input data-target='${this.foo}' type="text" value="bob">
    <button data-action='${this.sayHello}'>Say Hi!</button>
</div>
)*/
@:html(
<div :controller='${this}'>
    <span :target='${this.bar}' :attr-bar="1"></span>
    <input :target='${this.foo}' type="text" value="bob">
    <button :action='${this.sayHello}'>Say Hi!</button>
</div>
)
class Empty {

    public static function main() {
        var observer = new js.html.MutationObserver((records, observer) -> {
            for (record in records) {
                switch record.type {
                    case Attributes:

                    case ChildList:
                        //if (record.target == window.document.body) {
                            //console.log( 'document level change', record.addedNodes, record.removedNodes );
                            var empties = [];
                            for (n in record.addedNodes) if (n.nodeType == 1) {
                                var n:HtmlElement = cast n;
                                var c:js.html.NodeList = null;
                                if (n.hasAttribute('data-controller') && n.getAttribute('data-controller') == 'empty') {
                                    empties.push(n);

                                }
                                
                                if ((c = n.querySelectorAll('[data-controller="empty"]')).length > 0) {
                                    for (_c in c) empties.push(cast _c);
                                }
                            }
                            console.log(empties);
                            var actives = [for (empty in empties) new Empty(cast empty)];
                            for (active in actives) {
                                observer.observe(active.root, Empty.watchWhat);

                            }

                        //}

                    case CharacterData:

                }

            }
            console.log(records, observer);
        });
        observer.observe(window.document.body, {childList: true, subtree: true});
        var empties = window.document.querySelectorAll('[data-controller="empty"]');
        console.log(empties);

        var actives = [for (empty in empties) new Empty(cast empty)];

        for (active in actives) {
            observer.observe(active.root, Empty.watchWhat);

        }
    }

    public static var observedAttributes = ['data-controller', 'data-target', 'data-action'];
    public static var knownActions = ['click->empty#sayHello'];
    public static var knownTargets = ['bar', 'foo', 'fooy'];
    public static var watchWhat:MutationObserverInit = {attributes:true, attributeFilter: observedAttributes, childList:true, subtree:false};

    /**
    Target names automatically get put into `observedAttributes`.
    Target names automatically are `data-target-${fieldname}`.
    @:target(value) is an alternative value to match against. They become `data-target-${value}`.
    All these names will be stored.
    ---
    Each @:target also generates a `this.${fieldname}Target` which points to the matched dom element.
    ---
    @:data.target is long form for @:target.
    ---
    Each variable gets transformed to into a (g/s)etter, accessing and setting
    the generated `this.${fieldname}Target` dom element for you.
    ---
    Depending on the type parameter:
        - :Stream - changes will happen as soon as they arrive.
        - :(other types) - everything else might be queued, event based etc.
    **/

    @:data.attribute public var int:Int = 10;
    @:attr @:target public var bar:Int;
    @:data.target @:attr('value') public var foo:String;
    public var fooTarget:js.html.InputElement;

    @:target('fooy') public var thing:Float;

    /**
    @:data.attribute
    @:data.attr
    @:attribute
    @:attr
    ---
    Variables marked with @:attr will store/retrieve their values in `data-attr-${fieldname}`.
    Allowing state to be preserved in html. By default, it will be stored on the root element.
    Even thought its using the data- attributes, (g/s)etAttribute is still faster than the dataset api.
    ---
    @:attr("value")
    ---
    Can be paired with `@:target`. This changes the element to store/retreive from.
    This prevents the macro code from settings the value into innerText or whatever is selected.
    **/

    // Run only once.
    public function initilize() {}

    // Will be run at least once.
    public function connect() {}

    // Can be run more than once.
    public function disconnect() {}

    // Run whenever a matching attribute value is changed/added.
    public function attributeChange(attribute:String, oldValue:String, newValue:String):Void {}

    /**
    @:data.action(event)
    @:action(event) matches `data-action="$event->empty#sayHello"`.
    **/

    @:action('click') public function sayHello(event:js.html.MouseEvent):Void {
        console.log( 'Hello, ' + foo );
        foo = foo;
        console.log( bar, int );
        int += bar;
        bar = bar * 2;
    }

}
#end