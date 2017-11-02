package uhx.pati;

import js.html.*;
import js.Browser.*;
import tink.core.Pair;
import uhx.pati.Consts;
import uhx.pati.IProcessor;

using Type;
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
	
	// operator overloads
	
	@:op(A|B) @:commutative
	public static #if !debug inline #end function convertNode<D, S>(node:Phantom, pair:Pair<D, IProcessor<D, S>>):Phantom {
		console.log('convertNode');
		var to = node.to;
		var result = node;
		
		if (to != null) {
			result = Utilities.processAttribute(to, pair);
			node.setAttribute(PendingRemoval, True);
			
		} else {
			for (child in [for (c in node.children) c]) pair.b.handleNode(child, pair.a);
			
		}
		
		return result;
	}
	
	@:op(A|B) @:commutative
	public static #if !debug inline #end function insertBeforeElement(newNode:Phantom, oldNode:Element):Phantom {
		console.log('insertBeforeElement');
		var result = oldNode;
		
		if (oldNode != newNode) {
			result = newNode;
			oldNode.parentElement.insertBefore(newNode, oldNode);
			
		}
		
		return result;
	}
	
	@:op(A|B) @:commutative
	public static #if !debug inline #end function insertBeforeNode(newNode:Phantom, oldNode:Node):Phantom {
		console.log('insertBeforeNode');
		return switch oldNode.nodeType {
			case Node.ELEMENT_NODE, Node.DOCUMENT_NODE, Node.DOCUMENT_FRAGMENT_NODE:
				insertBeforeElement(newNode, cast oldNode);
				
			case _:
				oldNode;
				
		}
	}
	
}
