package uhx.pati;

import js.html.*;
import js.Browser.*;
import uhx.pati.Consts;
import uhx.pati.Phantom;

using StringTools;
using uhx.pati.Utilities;

@:enum abstract TargetAction(Int) from Int to Int {
	public var Copy = 0;
	public var Move = 1;
	public var Remove = 2;
}

class DomData extends ConvertTag<Array<Phantom>, Phantom> implements IProcessor<Array<Phantom>, Phantom> {
	
	public static function main() {
		var _ = new DomData();
	}
	
	//
	
	public var each(get, null):Bool;
	public var asText(get, null):Bool;
	public var prepend(get, null):Bool;
	public var select(get, null):Null<String>;
	public var targetAction(get, null):TargetAction;
	
	public function new(?prefix:String, ?name:String) {
		super(prefix, name);
	}
	
	// overloads
	
	public override function attached():Void {
		if (!isCustomChild && select != null) {
			var results = [for (n in document.querySelectorAll( select )) (n:Phantom)];
			onDataAvailable( results );
			
		}
		
	}
	
	// IProcessor fields
	
	public function onDataAvailable(data:Array<Phantom>):Void {
		this.replaceAttributes( Utilities.processAttribute.bind(_, new tink.core.Pair(cast data, cast this) ) );
		var attach = childNodes.length > 0 && prepend ? insertBefore.bind(_, firstChild) : appendChild;
		var newNodes = switch targetAction {
			case Copy:
				data.map( Utilities.clone.bind(_, true) );
				
			case Move:
				data;
				
			case Remove:
				var r = data.map( Utilities.clone.bind(_, true) );
				data.map( function(n) n.remove() );
				r;
				
		}
		
		if (asText) newNodes = [(stringify(newNodes):Phantom)];
		
		newNodes.map( attach );
		
		super.attached();
	}
	
	public function find(data:Array<Phantom>, selector:String):Array<Phantom> {
		var results = [];
		var fragment = document.createDocumentFragment();
		
		for (d in data) {
			fragment.appendChild((d:Phantom).clone());
			
		}
		
		for (n in fragment.querySelectorAll( selector )) results.push( (n:Phantom) );
		
		return results;
	}
	
	public function stringify(data:Array<Phantom>):String {
		return data.map( function(n) return n.textContent ).join(' ').trim();
	}
	
	public function handleNode(node:Phantom, data:Array<Phantom>, forEach:Bool = false):Void {
		
	}
	
	// (g/s)etters
	
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
	
	private #if !debug inline #end function get_targetAction():TargetAction {
		var result = Copy;
		
		if (!hasAttribute(TargetCopy)) if (hasAttribute(TargetMove)) {
			result = asText ? Remove : Move;
			
		} else if (hasAttribute(TargetRemove)) {
			result = Remove;
			
		}
		
		return result;
	}
	
	private #if !debug inline #end function get_each():Bool {
		return hasAttribute(Each);
	}
	
	private #if !debug inline #end function get_asText():Bool {
		return hasAttribute(UseText);
	}
	
	private #if !debug inline #end function get_prepend():Bool {
		return hasAttribute(Prepend) && !hasAttribute(Append);
	}
	
	private #if !debug inline #end function get_select():Null<String> {
		if (hasAttribute(Select)) {
			select = getAttribute(Select);
			
		}
		
		return select;
	}
	
	private override function get_ignoredAttributes():Array<String> {
		return super.get_ignoredAttributes().concat( [Select, Each, UseText, Prepend, Append, TargetMove, TargetRemove] );
	}
	
}
