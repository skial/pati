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

using tink.CoreApi;
using uhx.pati.Utilities;

@:access(uhx.select.JsonQuery)
class JsonData extends ConvertTag<Any, Any> implements IProcessor<Any, Any> {
	
	public static var globalData:FutureTrigger<Any> = new FutureTrigger();
	
	@:keep public static function onGlobalJsonDataAvailable(e:CustomEvent):Void {
		globalData.trigger( e.detail );
	}
	
	@:keep public static #if !debug inline #end function init():Void {
		window.document.addEventListener(JsonDataRecieved, onGlobalJsonDataAvailable, untyped {once:true, capture:false});
	}
	
	public static function main() {
		init();
		
		var _ = new JsonData();
	}
	
	//
	
	public var each(get, null):Bool;
	public var isScoped(get, null):Bool;
	@:isVar public var src(get, null):Null<String>;
	@:isVar public var select(get, null):Null<String>;
	@:isVar public var retarget(get, null):Null<String>;
	
	public function new(?prefix:String, ?name:String) {
		super(prefix, name);
	}
	
	// overloads
	
	public override function attached():Void {
		//console.log( isCustomChild, isScoped, select, retarget, src );
		if (!isCustomChild) {
			if (!isScoped && !hasAttribute(Src)) {
				var link = globalData.asFuture().handle( onDataAvailable );
				
			} else if (src == null && select != null && retarget == null) {
				onDataAvailable( haxe.Json.parse( getAttribute(ScopedData) ) );
				
			} else if (retarget != null) {
				globalData.asFuture().handle( function (d) {
					var selector = retarget.bracketInterpolate( new Pair(d, (this:IProcessor<Any, Any>)) );
					var data = find(d, selector.value);
					
					if (data.length > 0 && retarget == select) {
						select = null;
						setAttribute(Select, '*');
					};
					
					onDataAvailable( data );
					
				} );
				
			} else if (src != null) {
				//console.log( src );
				#if hxnodejs

				#else
					var f:Surprise<Response, Error> = window.fetch( src );
					f.handle( function(o) switch o {
						case Success(r):
							Future.ofJsPromise( r.json() ).handle( function(o) switch o {
								case Success(json):
									onDataAvailable( json );

								case Failure(e):
									//console.log( e );

							} );

						case Failure(e):
							//console.log( e );

					} );
				#end

			}
			
		}
		
	}
	
	//
	
	@:keep public function onDataAvailable(data:Any):Void {
		var matches = find(data, select);
		var self:IProcessor<Any, Any> = this;
		var pair:Pair<Any, IProcessor<Any, Any>> = new Pair(cast matches, self);
		
		this.replaceAttributes( Utilities.processAttribute.bind(_, new Pair(cast matches, self) ) );
		
		var action:Array<Phantom>->Void = each ? function(children) {
			for (match in matches) for (child in children) handleNode(child, match, true);
			
		} : function(children) {
			for (child in children) handleNode(child, matches);
			
		}
		
		// Only interested if it has elements as children.
		if (children.length > 0) {
			// Don't iterate over a live list.
			action( [for (c in children) c] );
			
		} else {
			appendChild( (matches.map( stringify ).join(' '):Phantom) );
			
		}
		
		super.attached();
	}
	
	// IProcessor fields
	
	public function stringify(data:Any):String {
		var result = if (Std.is(data, Array)) {
			if ((data:Array<Any>).length > 1) {
				(data:Array<Any>).map( haxe.Json.stringify.bind(_) ).map( StringTools.replace.bind(_, '"', '') ).join(' ');
				
			} else {
				stringify( (data:Array<Any>)[0] );
				
			}
			
		} else if (Type.typeof(data).match(TObject)) {
			haxe.Json.stringify( data );
			
		} else {
			'$data';
			
		}
		
		return result;
	}
	
	public function find(data:Any, selector:String):Array<Any> {
		var results = [];
		if (selector == null || selector.length == 0) return results;
		// Bypass `JsonQuery` which only works on objects and arrays.
		if (selector == '*') {
			if (Std.is(data, Array)) {
				results = cast data;
				
			} else {
				results = [data];
				
			}
			
		} else {
			results = cast JsonQuery.find( data, selector );
			
		}
		
		return cast results;
	}
	
	public function handleNode(node:Phantom, data:Any, forEach:Bool = false):Void {
		var pair:Pair<Any, IProcessor<Any, Any>> = new Pair(data, (this:IProcessor<Any, Any>));
		var modified = node.clone() | pair;
		
		if (CustomElement.knownComponents.indexOf(node.tagName.toLowerCase()) == -1) {
			
			if (forEach) {
				appendChild(modified);
				
			} else {
				modified | node;
				
			}
			
			if (modified.nodeType == Node.ELEMENT_NODE) {
				modified.replaceAttributes( Utilities.processAttribute.bind(_, pair) );
				
			}
			
			node.setAttribute(PendingRemoval, True);
			
		} else {
			if (node.tagName.toLowerCase() == htmlFullname) {
				
				for (attribute in [for (a in node.attributes) a]) if (['$Process$Select', '$Process$Retarget'].indexOf(attribute.name) > -1) {
					node.setAttribute(attribute.name.substring(1), Utilities.processAttribute( attribute.value, pair ) );
					node.removeAttribute(attribute.name);
					
				}
				
				node.setAttribute(ScopedData, haxe.Json.stringify(data));
				
			}
			
		}
		
	}
	
	//
	
	private override function get_wait():EWait {
		if (wait == null) if (!hasAttribute(Wait)) {
			wait = Until(0);
			
		} else {
			var str = getAttribute(Wait);
			if (str != '') {
				wait = str.parseWaitAttribute();
				
			} else {
				wait = For(select);
				
			}
			
		}
		
		return wait;
	}
	
	private #if !debug inline #end function get_each():Bool {
		return hasAttribute(Each);
	}
	
	private #if !debug inline #end function get_isScoped():Bool {
		return hasAttribute(ScopedData);
	}
	
	private #if !debug inline #end function get_select():Null<String> {
		if (hasAttribute(Select)) {
			select = getAttribute(Select);
			
		}
		
		return select;
	}

	private #if !debug inline #end function get_src():Null<String> {
		if (hasAttribute(Src)) {
			src = getAttribute(Src);

		}

		return src;
	}
	
	private #if !debug inline #end function get_retarget():Null<String> {
		if (hasAttribute(Retarget)) {
			retarget = getAttribute(Retarget);
			if (retarget == null || retarget == '') if (select != null) {
				retarget = select;
				
			} else {
				retarget = Root;
				
			}
			
		}
		
		return retarget;
	}
	
	private override function get_ignoredAttributes():Array<String> {
		return super.get_ignoredAttributes().concat( [Select, ScopedData, Each, Retarget] );
	}
	
}
