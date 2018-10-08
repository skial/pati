package uhx.pati;

import js.html.*;
import js.Browser.*;
import uhx.pati.Consts;
import uhx.pati.Phantom;

using uhx.pati.Utilities;

class MoveTags extends Staticise implements IProcessor<Array<Phantom>, Phantom> {
	
	public static function main() {
		var _ = new MoveTags();
	}
	
	//
	
	public var affix(get, null):Bool;
	public var to(get, null):Null<String>;
	
	public function new(?prefix:String, ?name:String) {
		super(prefix, name);
	}
	
	public override function attached():Void {
		if (!isCustomChild && to != null) {
			onDataAvailable( find( [document], to ) );
			
		}
		
	}
	
	// IProcessor
	
	public function find(data:Array<Phantom>, selector:String):Array<Phantom> {
		var results:Array<Phantom> = [];
		
		for (d in data) {
			for (n in d.querySelectorAll(selector)) {
				var node:Phantom = n;
				var exists = false;
				for (r in results) if (exists = node.isEqualNode(r)) break;
				if (!exists) results.push( node );
				
			}
			
		}
		
		return results;
	}
	
	public function stringify(data:Array<Phantom>):String {
		return '';
	}
	
	public function onDataAvailable(data:Array<Phantom>):Void {
		for (d in data) {
			// Possible bug with `bind` on extern javascript methods?
			var attach = affix ? function(n) d.insertBefore(n, d.firstElementChild) : function(n) d.appendChild(n);
			
			for (node in [for (c in childNodes) c]) {
				var cloned = node;
				attach( cloned );
				
			}
			
		}
		
		super.attached();
	}
	
	public function handleNode(node:Phantom, data:Array<Phantom>, forEach:Bool = false):Void {
		
	}
	
	// override
	
	private override function get_wait():EWait {
		if (wait == null) if (!hasAttribute(Wait)) {
			wait = Until(0);
			
		} else {
			var str = getAttribute(Wait);
			if (str != '') {
				wait = str.parseWaitAttribute();
				
			} else {
				wait = For(to);
				
			}
			
		}
		
		return wait;
	}
	
	public override function get_phase():EventPhase {
		return Capturing;
	}
	
	// (g/s)etters
	
	public function get_to():Null<String> {
		var result = null;
		
		if (hasAttribute(ShortTo)) {
			result = getAttribute(ShortTo);
			
		} else if (hasAttribute(LongTo)) {
			result = getAttribute(LongTo);
			
		}
		
		return result;
	}
	
	private #if !debug inline #end function get_affix():Bool {
		return hasAttribute(Prepend) && !hasAttribute(Append);
	}
	
}
