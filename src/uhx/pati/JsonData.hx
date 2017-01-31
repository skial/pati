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

@:access(uhx.select.JsonQuery)
class JsonData extends ConvertTag<Any, Any> implements IProcessor<Any, Any> {
	
	public static var globalData:FutureTrigger<Any> = new FutureTrigger();
	
	public static function onGlobalJsonDataAvailable(e:CustomEvent):Void {
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
	
	public var each(get, null):Bool;
	public var isScoped(get, null):Bool;
	public var select(get, null):Null<String>;
	
	public function new() {
		super();
	}
	
	// overloads
	
	public override function attached():Void {
		if (!isCustomChild) {
			if (!isScoped) {
				var link = globalData.asFuture().handle( onDataAvailable );
				
			} else {
				onDataAvailable( haxe.Json.parse( getAttribute(ScopedData) ) );
				
			}
			
		}
		
	}
	
	//
	
	public function onDataAvailable(data:Any):Void {
		var matches = find(data, select);
		var self:IProcessor<Any, Any> = this;
		var pair:Pair<Any, IProcessor<Any, Any>> = new Pair(cast matches, self);
		
		this.replaceAttributes( Utilities.processAttribute.bind(_, new Pair(cast matches, self) ) );
		
		var action:Phantom->Void = each ? function(child) {
			if (CustomElement.knownComponents.indexOf(child.tagName.toLowerCase()) == -1) {
				var remove = false;
				
				for (match in matches) {
					var pair:Pair<Any, IProcessor<Any, Any>> = new Pair(cast match, self);
					var modified = child.clone() | pair;
					
					if (child != modified) {
						child.parentElement.insertBefore(modified,child);
						remove = true;
						
					}
					
				}
				
				if (remove) child.setAttribute(PendingRemoval, True);
				
			} else {
				if (child.tagName.toLowerCase() == htmlFullname) {
					child.setAttribute(ScopedData, haxe.Json.stringify(matches));
					
				}
				
			}
			
		} : function(child) {
			if (CustomElement.knownComponents.indexOf(child.tagName.toLowerCase()) == -1) {
				(child:Phantom) | pair | child;
				
			} else {
				if (child.tagName.toLowerCase() == htmlFullname) {
					child.setAttribute(ScopedData, haxe.Json.stringify(matches));
					
				}
				
			}
			
		}
		
		// Only interested if it has elements as children.
		if (children.length > 0) {
			// Don't iterate over a live list.
			for (child in [for (c in children) c]) action( child );
			
			for (node in querySelectorAll('$Scope [$PendingRemoval="$True"]')) {
				(node:Phantom).remove();
				
			}
			
		} else {
			appendChild( (matches.map( stringify ).join(' '):Phantom) );
			
		}
		
		super.attached();
	}
	
	// IProcessor fields
	
	public function stringify(data:Any):String {
		var result = if (Std.is(data, Array)) {
			if ((data:Array<Any>).length > 1) {
				(data:Array<Any>).map( haxe.Json.stringify.bind(_) ).join(' ');
				
			} else {
				haxe.Json.stringify( (data:Array<Any>)[0] );
				
			}
			
		} else if (Type.typeof(data).match(TObject)) {
			haxe.Json.stringify( data );
			
		} else {
			'$data';
			
		}
		
		return result;
	}
	
	public function find(data:Any, selector:String):Array<Any> {
		if (selector == null || selector.length == 0) return [];
		var results = JsonQuery.find( data, selector );
		return cast results;
	}
	
	public function handleMatch(child:Node, match:Null<Any>):Array<Node> {
		return [];
	}
	
	//
	
	private function get_each():Bool {
		return hasAttribute(Each);
	}
	
	private function get_isScoped():Bool {
		return hasAttribute(ScopedData);
	}
	
	private function get_select():Null<String> {
		for (attribute in attributes) if (attribute.name == Select) {
				select = attribute.value;
				break;
		}
		
		return select;
	}
	
	private override function get_ignoredAttributes():Array<String> {
		return super.get_ignoredAttributes().concat( [Select, ScopedData, Each] );
	}
	
}
