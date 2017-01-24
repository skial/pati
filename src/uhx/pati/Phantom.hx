package uhx.pati;

import js.html.*;
import js.Browser.*;
import tink.core.Pair;
import uhx.pati.Consts;
import uhx.pati.IProcessor;

using StringTools;
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
	
	//
	
	private static #if !debug inline #end function processAttribute<D, S>(value:String, pair:Pair<D, IProcessor<D, S>>):String {
		var result = value;
		var start = value.indexOf('{');
		var end = value.indexOf('}');
		
		if (start > -1 && end > -1 && end > start) {
			// Value needs to be interpreted.
			var interpreted = value.bracketInterpolate( pair );
			result = interpreted.value;
			
		} else {
			// Attempt to match values with the entire attribute value.
			var matches = pair.b.find( pair.a, value );
			result = (matches.length > 0 ? matches.map( cast pair.b.stringify ).join(' ') : value);
			
		}
		
		return result;
	}
	
	// operator overloads
	
	@:op(A|B) @:commutative
	public static #if !debug inline #end function convertNode<D, S>(node:Phantom, pair:Pair<D, IProcessor<D, S>>):Phantom {
		var to = node.to;
		var result = node;
		
		if (to != null) {
			result = (processAttribute(to, pair):Phantom);
			
		} else if (result.nodeType == Node.ELEMENT_NODE) {
			if (Std.is(pair.a, Array)) {
				var a:Array<Any> = cast pair.a;
				var remove = false;
				
				for (value in a) {
					var p:Pair<D, IProcessor<D, S>> = cast new Pair(value, pair.b);
					var clone = node.cloneNode(true);
					var modified = convertNode( clone, p );
					
					console.log(node, modified, node != modified);
					if (node != modified) {
						for (child in [for (c in modified.children) c]) {
							replaceNode( convertNode( child, p ), child );
							
						}
						
						modified.replaceAttributes( processAttribute.bind(_, p) );
						node.parentElement.insertBefore(modified, node);
						
						remove = true;
						
					}
					
				}
				
				if (remove) node.remove();
				
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
	
}
