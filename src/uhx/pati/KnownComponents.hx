package uhx.pati;

import js.html.*;
import js.Browser.*;
import uhx.pati.Consts;
import haxe.Serializer;
import haxe.Unserializer;

@:forward abstract KnownComponents(Array<String>) to Array<String> {
	
	private static var storage(get, never):Storage;
	private static var values(get, set):Array<String>;
	
	public inline function new() this = values;
	
	@:arrayWrite public function push(v:String):Int {
		var tmp = get_values();
		var index = tmp.push(v);
		set_values(tmp);
		return index;
	}
	
	@:arrayRead private function read(index:Int):Null<String> {
		return KnownComponents.values[index];
	}
	
	//
	
	private static inline function get_storage():Storage {
		return window.sessionStorage;
	}
	
	private static inline function get_values():Array<String> {
		return storage.getItem( Storage ) == null ? [] : (Unserializer.run( storage.getItem( Storage ) ):Array<String>);
	}
	
	private static inline function set_values(v:Array<String>):Array<String> {
		storage.setItem( Storage , Serializer.run(v));
		return v;
	}
	
}
