package uhx.pati;

import js.html.*;
import haxe.Int64;
import tink.core.*;
import js.Browser.*;
import haxe.ds.IntMap;
import uhx.pati.EWait;
import uhx.pati.Consts;
import uhx.pati.CustomElement;

using StringTools;
using uhx.pati.Utilities;

class Utilities {
	
	private static var isTimeUnit:EReg = ~/^ *([0-9]+(ms|s))? *$/im;
	private static var getTimeUnit:EReg = ~/(ms|s)?/i;

	// All results should be in milliseconds.
	private static var symbols:Array<Pair<String, Int->Int64>> = [
		new Pair('ms', Int64.ofInt),
		new Pair('s', function(v) return Int64.fromFloat((v * 1) / 0.001)),
	];
	
	public static function parseWaitAttribute(value:String):EWait {
		var result = Until(0);
		
		if (isTimeUnit.match( value )) {
			var unit = 'ms';
			var action = symbols[0].b;
			
			if (getTimeUnit.match( isTimeUnit.matched(1) )) for (symbol in symbols) {
				if (symbol.a == getTimeUnit.matched(1)) {
					unit = symbol.a;
					action = symbol.b;
					break;
					
				}
				
			}
			
			result = Until( Int64.toInt( action(Std.parseInt( value.substring( 0, value.length - unit.length ) )) ) );
			
		} else if (value != '') {
			// Assume its a css selector
			result = For(value);
			
		}
		
		return result;
	}
	
	public static function diff(dom:Phantom, template:TemplateElement):Array<Phantom> {
		var results = [];
		template = cast template.cloneNode(true);
		var contents = template.content.querySelectorAll(Content);
		
		if (contents.length > 0) {
			for (n in contents) (n:Phantom).remove();
			
			results = diffChildren( [for (n in dom.children) n], [for (n in template.content.children) n] );
			
		} 
		
		return results;
	}
	
	// Checks for differences between the custom element and the original template.
	public static function diffChildren(dom:Array<Phantom>, template:Array<Phantom>):Array<Phantom> {
		var results = [];
		var domIndex = 0;
		var customElements = CustomElement.knownComponents;
		
		while (domIndex < dom.length) {
			var match = false;
			var templateIndex = 0;
			var original = dom[domIndex];
			var child = original;
			
			if (child.nodeName.toLowerCase() == Content) {
				domIndex++;
				continue;
			}
			
			if (child.querySelectorAll(Content).length > 0) {
				var clone = clone( child );
				for (n in clone.querySelectorAll(Content)) (n:Phantom).remove();
				child = clone;
				
			}
			
			while (templateIndex < template.length) {
				var node = template[templateIndex];
				
				if (customElements.indexOf( node.nodeName.toLowerCase() ) == -1) {
					// Normal node, hopefully.
					if (match = node.isEqualNode(child)) {
						templateIndex = template.length;
						break;
					}
					
				} else {
					// Known custom element.
					var custom:TemplateElement = untyped document.createElement( node.nodeName ).template;
					custom = cast custom.cloneNode(true);
					// Remove `<content>` tags from template.
					for (n in custom.content.querySelectorAll(Content)) (n:Phantom).remove();
					var sub = diffChildren( [child], [for (n in custom.content.children) n] );
					
					if (match = sub.length == 0) {
						templateIndex = template.length;
						break;
					}
					
				}
				
				templateIndex++;
				
			}
			
			if (!match) results.push( child );
			
			domIndex++;
			
		}
		
		return results;
	}
	
	/*
	 *	`node.cloneNode` and `window.document.importNode`, where the node to be cloned
	 *	is a custom element, the newly cloned node doesnt appear to be initialized
	 *	fully.
	*/
	public static function clone(node:Phantom, deep:Bool = true):Phantom {
		var tagName = node.nodeType == Node.ELEMENT_NODE ? node.tagName.toLowerCase() : '';
		
		if (node.nodeType == Node.ELEMENT_NODE /*&& CustomElement.knownComponents.indexOf( tagName = node.tagName.toLowerCase() ) > -1*/) {
			var clone:Phantom = window.document.createElement( tagName );
			// Use `(g/s)etAttributeNode` instead of `(g/s)etAttribute` to avoid invalid value errors.
			for (a in node.attributes) if (a.name != UID && a.name != PendingRemoval) clone.setAttributeNode(untyped node.getAttributeNode(a.name).cloneNode(true));
			for (c in node.childNodes) clone.appendChild( c.clone( deep ) );
			node = clone;
			
		} else {
			node = node.cloneNode( deep );
			if (node.nodeType == Node.ELEMENT_NODE && node.hasAttribute(PendingRemoval)) node.removeAttribute(PendingRemoval);
			
		}
		
		return node;
	}
	
	public static #if !debug inline #end function replaceAttributes(node:Phantom, resolve:String->String):Phantom {
		// Don't iterate over a live list.
		for (attribute in [for (a in node.attributes) a]) {
			switch attribute.name {
				case _.startsWith(Process) => true:
					node.setAttribute( attribute.name.substring(1), resolve(attribute.value) );
					node.removeAttribute( attribute.name );
					
				case _:
					
					
			}
			
		}
		
		return node;
	}
	
	public static function processAttribute<D, S>(value:String, pair:Pair<D, IProcessor<D, S>>):String {
		var result = value;
		var start = value.indexOf(Left);
		var end = value.indexOf(Right);
		
		if (start > -1 && end > -1 && end > start) {
			// Value needs to be interpreted.
			var interpreted = value.bracketInterpolate( pair );
			result = interpreted.value;
			
		} else {
			// Attempt to match values with the entire attribute value.
			var matches = pair.b.find( pair.a, value );
			result = pair.b.stringify( cast matches );
			
		}
		
		return result;
	}
	
	public static #if !debug inline #end function bracketInterpolate<A, B>(value:String, pair:Pair<A, IProcessor<A, B>>) {
		return trackAndInterpolate(value, -1, [Left => Right], function(str) {
			var matches = pair.b.find( pair.a, str );
			return pair.b.stringify( cast matches );
		});
	}
	
	/** All these are from an internal project likely never to see the light of day */
	public static function trackAndConsume(value:String, until:Int, track:IntMap<Int>):String {
		var result = '';
		var length = value.length;
		var index = 0;
		var character = -1;

		while (index < length) {
			character = value.fastCodeAt( index );
			
			if (character == until) {
				break;

			}
			
			if (track.exists( character )) {
				var _char = track.get( character );
				var _value = value.substr( index + 1 ).trackAndConsume( _char, track );
				result += String.fromCharCode( character ) + _value + String.fromCharCode( _char );
				index += _value.length + 1;

			} else {
				result += String.fromCharCode( character );
				index++;

			}

		}

		return result;
	}

	public static function trackAndSplit(value:String, split:Int, track:IntMap<Int>):Array<String> {
		var pos = 0;
		var results = [];
		var length = value.length;
		var index = 0;
		var character = -1;
		var current = '';

		while (index < length) {
			character = value.fastCodeAt( index );
			
			if (character == split) {

				if (results.length == 0) {
					results.push( value.substr(0, index) );

				} else if (current != '') {
					results.push( current );

				}
				
				pos = index;
				index++;
				current = '';
				continue;

			}
			
			if (track.exists( character )) {
				var _char = track.get( character );
				var _value = value.substr( index + 1 ).trackAndConsume( _char, track );
				current += String.fromCharCode( character ) + _value + String.fromCharCode( _char );
				index += _value.length + 2;

			} else {
				current += String.fromCharCode( character );
				index++;

			}

		}

		if (current != '') results.push( current );

		return results;
	}
	
	public static function trackAndInterpolate(value:String, until:Int, track:IntMap<Int>, resolve:String->String):{matched:Bool, length:Int, value:String} {
		var result = '';
		var length = value.length;
		var index = 0;
		var character = -1;
		var pos = 0;
		var match = false;

		while (index < length) {
			character = value.fastCodeAt( index );
			
			if (character == until) {
				pos = index++;
				break;

			}
			
			if (track.exists( character )) {
				var _char = track.get( character );
				var _info = value.substr( index + 1 ).trackAndInterpolate( _char, track, resolve );
				var _value = resolve(_info.value);
				match = true;
				pos = index += _info.length + 2;
				result += _value;

			} else {
				result += String.fromCharCode( character );
				pos = index++;
				
			}

		}
		
		return {matched:match, length:pos, value:result};
	}
	
}
