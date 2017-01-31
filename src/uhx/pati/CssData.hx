package uhx.pati;

import js.html.*;
import js.Browser.*;
import uhx.pati.Consts;
import uhx.pati.Phantom;

class CssData extends ConvertTag<Array<Phantom>, Phantom> implements IProcessor<Array<Phantom>, Phantom> {
	
	public static function main() {
		var _ = new CssData();
	}
	
	//
	
	public var each(get, null):Bool;
	public var asText(get, null):Bool;
	public var prepend(get, null):Bool;
	public var select(get, null):Null<String>;
	
	public function new() {
		super();
	}
	
	// overloads
	
	public override function attached():Void {
		if (!isCustomChild && select != null) {
			onDataAvailable( find([document], select) );
			
		}
		
	}
	
	// IProcessor fields
	
	public function onDataAvailable(data:Array<Phantom>):Void {
		console.log( data, prepend, firstChild );
		var attach = childNodes.length > 0 && prepend ? insertBefore.bind(_, firstChild) : appendChild;
		var newNodes = asText ? [(stringify(data):Phantom)] : data.map( Utilities.clone.bind(_, true) );
		
		newNodes.map( attach );
		
		super.attached();
	}
	
	public function find(data:Array<Phantom>, selector:String):Array<Phantom> {
		var results = [];
		for (d in data) for (n in d.querySelectorAll( selector )) results.push( (n:Phantom) );
		return results;
	}
	
	public function stringify(data:Array<Phantom>):String {
		return data.map( function(n) return n.textContent ).join(' ');
	}
	
	public function handleMatch(child:Node, match:Null<Phantom>):Array<Node> {
		return [];
	}
	
	// (g/s)etters
	
	private function get_each():Bool {
		return hasAttribute(Each);
	}
	
	private function get_asText():Bool {
		return hasAttribute(UseText);
	}
	
	private function get_prepend():Bool {
		return hasAttribute(Prepend) && !hasAttribute(Append);
	}
	
	private function get_select():Null<String> {
		for (attribute in attributes) if (attribute.name == Select) {
				select = attribute.value;
				break;
		}
		
		return select;
	}
	
	private override function get_ignoredAttributes():Array<String> {
		return super.get_ignoredAttributes().concat( [Select, Each, UseText, Prepend, Append] );
	}
	
}
