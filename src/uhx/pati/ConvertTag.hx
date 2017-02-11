package uhx.pati;

import js.html.*;
import js.Browser.*;
import uhx.pati.Consts;

using uhx.pati.Utilities;

using StringTools;

/**
D == Data object to search, an array, object or map etc.
S == Single data type contained in the D object.
*/
class ConvertTag<D, S> extends Staticise {
	
	@:isVar public var to(get, null):Null<String> = null;
	public var ignoredAttributes(get, null):Array<String>;
	
	public static function main() {
		var _ = new ConvertTag();
	}
	
	public function new() {
		super();
	}
	
	//
	
	public override function attached():Void {
		for (node in querySelectorAll('$Scope [$PendingRemoval="$True"]')) {
			(node:Phantom).remove();
			
		}
		
		if (to != null) {
			var replacement = window.document.createElement(to);
			
			for (attribute in attributes) switch attribute.name {
				case _.startsWith(To) || ignoredAttributes.indexOf(_) > -1 => false:
					replacement.setAttribute( attribute.name, attribute.value );
					
				case _:
						
			}
				
			for (node in [for (n in childNodes) (n:Phantom)]) replacement.appendChild( node );
			parentElement.insertBefore(replacement, this);
				
		} else {
			for (node in [for (n in childNodes) (n:Phantom)]) parentElement.insertBefore( node, this );
			
		}
			
		super.attached();
	}
	
	//
	
	private #if !debug inline #end function get_to():Null<String> {
		for (attribute in attributes) if (attribute.name.startsWith(To)) {
				to = attribute.name.substring(To.length);
				break;
		}
		
		return to;
	}
	
	private function get_ignoredAttributes():Array<String> {
		return [To, UID, PendingRemoval, Phase];
	}
	
	private override function get_phase():EventPhase {
		return Capturing;
	}
	
}
