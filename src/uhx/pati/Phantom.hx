package uhx.pati;

import js.html.*;
import js.Browser.*;
import tink.core.Pair;
import uhx.pati.Consts;
import uhx.pati.IProcessor;

using uhx.pati.Utilities;

@:forward abstract Phantom(Element) from Element to Element {
	
	public var to(get, never):Null<String>;
	
	public #if !debug inline #end function new(v:Element) {
		this = v;
	}
	
	// getters/setters
	
	private #if !debug inline #end function get_to():Null<String> {
		var result = null;
		
		for (attribute in this.attributes) if (attribute.name == PhantomAttr.To) {
			result = attribute.value;
			break;
		}
		
		return result;
	}
	
	// casts
	
	@:to private #if !debug inline #end function toNode() return (this:Node);
	@:from private static #if !debug inline #end function fromNode(v:Node):Phantom return cast v;
	@:from private static #if !debug inline #end function fromString(v:String):Phantom return window.document.createTextNode(v);
	
	// operator overloads
	
	@:op(A|B) @:commutative
	public static #if !debug inline #end function convertNode<D, S>(node:Phantom, pair:Pair<D, IProcessor<D, S>>):Phantom {
		var to = node.to;
		var result = node;
		var finder = finder.bind( pair, _ );
		
		if (to != null) {
			var start = to.indexOf('{');
			var end = to.indexOf('}');
			
			if (start > -1 && end > -1 && end > start) {
				// Value needs to be interpreted.
				var interpreted = to.trackAndInterpolate('}'.code, ['{'.code => '}'.code], finder );
				result = (interpreted.value:Phantom);
				
			} else {
				// Attempt to match values with the entire attribute value.
				result = (finder( to ):Phantom);
				
			}
			
		}
		
		return result;
	}
	
	@:op(A|B) @:commutative
	public static #if !debug inline #end function replaceElement(newNode:Phantom, oldNode:Element):Phantom {
		var result = oldNode;
		
		if (oldNode != newNode) {
			result = newNode;
			oldNode.parentElement.insertBefore(newNode, oldNode);
			oldNode.remove();
			
		}
		
		return result;
	}
	
	@:op(A|B) @:commutative
	public static #if !debug inline #end function replaceNode(newNode:Phantom, oldNode:Node):Phantom {
		return switch oldNode.nodeType {
			case Node.ELEMENT_NODE, Node.DOCUMENT_NODE, Node.DOCUMENT_FRAGMENT_NODE:
				replaceElement(newNode, cast oldNode);
				
			case _:
				oldNode;
				
		}
	}
	
	//
	
	private static #if !debug inline #end function finder<D, S>(pair:Pair<D, IProcessor<D, S>>, str:String):String {
		var matches = pair.b.find( pair.a, str );
		return matches.length > 0 ? matches.map( cast pair.b.stringify ).join(' ') : str;
	}
	
}
