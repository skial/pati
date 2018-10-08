package js.html;

import haxe.Constraints.Function;

private typedef Options = {
    @:native("extends") @:optional var _extends:String;
}

extern class CustomElementRegistry {

    public function define(name:String, constructor:Function, ?options:Options):Void;
    public function get<T>(name:String):Null<Class<T>>;
    public function whenDefined(name:String):js.Promise<Void>;

}