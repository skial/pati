package uhx.pati;

import haxe.Constraints;

@:callable abstract FunctionPointer<T>(T->Void) from T->Void from Null<T>->Void to T->Void to Null<T>->Void to Function {}

typedef EventObject<T> = {method:FunctionPointer<T>, options:{capture:Bool, once:Bool, passive:Bool, composed:Bool}};

@:forward abstract EventListener(EventObject<Any>) from EventObject<Any> {
	
	public var capture(get, set):Bool;
	public var once(get, set):Bool;
	public var passive(get, set):Bool;
	public var composed(get, set):Bool;
	
	public inline function new(method:FunctionPointer<Any>, capture:Bool = false, once:Bool = false, passive:Bool = false, composed:Bool = false) {
		this = { method:method, options:{ capture:capture, once:once, passive:passive, composed:composed } };
	}
	
	private inline function get_capture():Bool {
		return this.options.capture;
	}
	
	private inline function set_capture(v:Bool):Bool {
		return this.options.capture = v;
	}
	
	private inline function get_once():Bool {
		return this.options.once;
	}
	
	private inline function set_once(v:Bool):Bool {
		return this.options.once = v;
	}
	
	private inline function get_passive():Bool {
		return this.options.passive;
	}
	
	private inline function set_passive(v:Bool):Bool {
		return this.options.passive = v;
	}
	
	private inline function get_composed():Bool {
		return this.options.composed;
	}
	
	private inline function set_composed(v:Bool):Bool {
		return this.options.composed = v;
	}
	
	@:to private inline function toFunction() {
		return this.method;
	}
	
	@:from private static inline function fromFunction<T:Function>(v:T):EventListener {
		return new EventListener( cast v );
	}
	
	@:from private static inline function fromObjectCapture<T:Function>(v:{method:T,capture:Bool}):EventListener {
		var el = new EventListener(cast v.method, v.capture);
		return el;
	}
	
	@:from private static inline function fromObjectOnce<T:Function>(v:{method:T,once:Bool}):EventListener {
		var el = new EventListener(cast v.method, false, v.once);
		return el;
	}
	
	@:from private static inline function fromObjectPassive<T:Function>(v:{method:T,passive:Bool}):EventListener {
		var el = new EventListener(cast v.method, false, false, v.passive);
		return el;
	}
	
	@:from private static inline function fromObjectComposed<T:Function>(v:{method:T,composed:Bool}):EventListener {
		var el = new EventListener(cast v.method, false, false, false, v.composed);
		return el;
	}
	
	@:from private static inline function fromObjectAll<T:Function>(v:{method:T, ?capture:Bool, ?once:Bool, ?passive:Bool, ?composed:Bool}):EventListener {
		var el = new EventListener(cast v.method, v.capture == null?false:v.capture, v.once == null?false:v.once, v.passive == null?false:v.passive, v.composed == null?false:v.composed);
		return el;
	}
	
}
