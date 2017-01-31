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
	
	public var prepend(get, null):Bool;
	public var to(get, null):Null<String>;
	
	public function new() {
		super();
	}
	
	public override function attached():Void {
		if (!isCustomChild && to != null) {
			onDataAvailable( find( [document], to ) );
			
		}
		
	}
	
	// IProcessor
	
	public function find(data:Array<Phantom>, selector:String):Array<Phantom> {
		var results = [];
		
		for (d in data) for (n in d.querySelectorAll(selector)) results.push( (n:Phantom) );
		
		return results;
	}
	
	public function stringify(data:Array<Phantom>):String {
		return '';
	}
	
	public function onDataAvailable(data:Array<Phantom>):Void {
		for (d in data) {
			var attach = prepend ? d.insertBefore.bind(_, d.firstChild) : d.appendChild;
			
			for (node in childNodes) {
				var cloned = node.clone();
				attach( cloned );
				
			}
			
		}
		
		super.attached();
	}
	
	// override
	
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
	
	private #if !debug inline #end function get_prepend():Bool {
		return hasAttribute(Prepend) && !hasAttribute(Append);
	}
	
}
