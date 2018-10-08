package uhx.pati;

import js.Browser.console;

#if !(eval || macro)
@:autoBuild(uhx.pati.macro.CustomElement.build())
#end
/**
Implements v1 of Web Components, replacing v0, obviously.
@see https://developer.mozilla.org/en-US/docs/Web/Web_Components
**/
class Pati extends js.html.HtmlElement {

    @:keep public function connectedCallback():Void {
        console.log('new foo-bar constructed');
        setAttribute('foo', 'bar');
    }

    @:keep public function disconnectedCallback():Void {
        console.log('foo-bar disconnected');
    }

    @:keep public function adoptedCallback():Void {
        console.log('foo-bar adopted');
    }

    @:keep public function attributeChangedCallback(name:String, oldValue:String = 'unknown', newValue:String = 'unknown'):Void {
        console.log('$name attribute changed from $oldValue to $newValue');
    }

}