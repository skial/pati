package uhx.pati;

import js.html.*;
import js.Browser.*;
import uhx.pati.Consts;

class JsonData extends ConvertTag<Any, Any> {
	
	public static function main() {
		var _ = new JsonData();
	}
	
	public function new() {
		super();
	}
	
	//
	
	public override function attachedCallback():Void {
		console.log( htmlFullname, 'added' );
	}
	
	public override function created():Void {
		console.log( isCustomChild, hasCustomChildren );
		if (!isCustomChild) {
			console.log( 'adding JsonDataRecieved event listener' );
			window.document.addEventListener(JsonDataRecieved, onJsonDataAvailable, untyped {once:true});
			
		}
		
		super.created();
	}
	
	//
	
	public function onJsonDataAvailable(?e:CustomEvent):Void {
		console.log( e );
		super.attachedCallback();
	}
	
}
