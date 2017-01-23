package uhx.pati;

import js.html.*;
import js.Browser.*;
import tink.core.Pair;
import uhx.pati.Consts;
import uhx.pati.Phantom;
import tink.core.Future;
import tink.core.Callback;
import haxe.DynamicAccess;
import uhx.select.JsonQuery;

using uhx.pati.Utilities;

class JsonData extends ConvertTag<Any, Any> implements IProcessor<Any, Any> {
	
	public static var globalData:FutureTrigger<Any> = new FutureTrigger();
	
	public static function onGlobalJsonDataAvailable(e:CustomEvent):Void {
		console.log( 'triggered global json data callback', e );
		globalData.trigger( e.detail );
	}
	
	public static function main() {
		if (untyped window.json_data != null) {
			globalData.trigger( untyped window.json_data );
			
		} else {
			window.document.addEventListener(JsonDataRecieved, onGlobalJsonDataAvailable, untyped {once:true, capture:false});
			
		}
		
		var _ = new JsonData();
	}
	
	//
	
	public var select(get, null):Null<String>;
	
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
			console.log( globalData );
			console.log( 'adding JsonDataRecieved event listener' );
			var link = globalData.asFuture().handle( onJsonDataAvailable );
			
		}
		
		super.created();
	}
	
	//
	
	public function onJsonDataAvailable(data:Any):Void {
		console.log( 'triggered local json data callback', data );
		var matches = find(data, select);
		
		// Only interested if it has elements are children.
		if (this.children.length > 0) {
			var self:IProcessor<Any, Any> = this;
			var pair:Pair<Any, IProcessor<Any, Any>> = new Pair(cast matches, self);
			
			for (child in children) {
				(child:Phantom) | pair | child;
				
			}
			
		} else {
			appendChild( (matches.map( stringify ).join(' '):Phantom) );
			
		}
		
		super.attachedCallback();
	}
	
	// IProcessor fields
	
	public function stringify(data:Any):String {
		return '$data';
	}
	
	public function find(data:Any, selector:String):Array<Any> {
		console.log( data, selector );
		return cast uhx.select.JsonQuery.find( data, selector );
	}
	
	public function handleMatch(child:Node, match:Null<Any>):Array<Node> {
		return [];
	}
	
	//
	
	private function get_select():Null<String> {
		for (attribute in attributes) if (attribute.name == Select) {
				select = attribute.value;
				break;
		}
		
		return select;
	}
	
	private override function get_ignoredAttributes():Array<String> {
		return super.get_ignoredAttributes().concat( [Select] );
	}
	
}
