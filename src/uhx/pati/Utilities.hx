package uhx.pati;

import js.html.*;
import js.Browser.*;
import haxe.ds.IntMap;
import tink.core.Pair;
import uhx.pati.Consts;
import uhx.pati.CustomElement;

using StringTools;
using uhx.pati.Utilities;

class Utilities {
	
	/*
	 *	`node.cloneNode` and `window.document.importNode`, where the node to be cloned
	 *	is a custom element, the newly cloned node doesnt appear to be initialized
	 *	fully.
	*/
	public static function clone(node:Phantom, deep:Bool = true):Phantom {
		var tagName = '';
		
		if (node.nodeType == Node.ELEMENT_NODE && CustomElement.knownComponents.indexOf( tagName = node.tagName.toLowerCase() ) > -1) {
			/*var template:TemplateElement = cast window.document.createElement('template');
			var owner:Document = template.content.ownerDocument;*/
			var clone:Phantom = window.document.createElement( tagName );
			//console.log( 'cloning', node.outerHTML, node );
			//clone.setAttribute(Pause, 'true');
			for (a in node.attributes) if (a.name != UID) clone.setAttribute( a.name, a.value );
			for (c in node.childNodes) clone.appendChild( c.clone( deep ) );
			//clone.removeAttribute(Pause);
			//console.log( 'cloned', clone.outerHTML, clone );
			node = clone;
			
		} else {
			node = node.cloneNode( deep );
			
		}
		
		return node;
	}
	
	public static inline function replaceAttributes(node:Phantom, resolve:String->String):Phantom {
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
			console.log( value, matches );
			result = (matches.length > 0 ? matches.map( cast pair.b.stringify ).join(' ') : value);
			
		}
		
		return result;
	}
	
	public static #if !debug inline #end function bracketInterpolate<A, B>(value:String, pair:Pair<A, IProcessor<A, B>>) {
		return trackAndInterpolate(value, -1, [Left => Right], function(str) {
			var matches = pair.b.find( pair.a, str );
			console.log( str, pair.a, matches,matches.length > 0 ? matches.map( cast pair.b.stringify ).join(' ') : str );
			return matches.length > 0 ? matches.map( cast pair.b.stringify ).join(' ') : str;
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
