package uhx.pati;

import js.html.*;
import js.Browser.*;
import tink.core.Pair;
import uhx.pati.Consts;
import uhx.pati.IProcessor;

using uhx.pati.Utilities;

@:forward abstract Phantom(Element) from Element to Element {
	
	public var to(get, never):Null<String>;
	
	public function new(v:Element) {
		this = v;
	}
	
	//
	
	// getters/setters
	
	private function get_to():Null<String> {
		var result = null;
		
		for (attribute in this.attributes) if (attribute.name == PhantomAttr.To) {
			result = attribute.value;
			break;
		}
		
		return result;
	}
	
	// casts
	
	@:to private function toNode() return (this:Node);
	@:from private static function fromNode(v:Node):Phantom return cast v;
	@:from private static function fromString(v:String):Phantom return window.document.createTextNode(v);
	
	// operator overloads
	
	@:op(A>>B) @:commutative
	public static function mapGenericData<D, S>(node:Phantom, pair:Pair<D, IProcessor<D, S>>):Phantom {
		var result = node;
		var find = pair.b.find.bind( pair.a, _ );
		var to = node.to;
		
		console.log( to );
		
		if (to != null) {
			var start = to.indexOf('{');
			var end = to.indexOf('}');
			
			console.log( start, end, start > -1 && end > -1 && end > start );
			// Value needs to be interpreted.
			if (start > -1 && end > -1 && end > start) {
				var interpreted = to.trackAndInterpolate('}'.code, ['{'.code => '}'.code], finder.bind( pair, _ ) );
				console.log( interpreted );
				result = (interpreted.value:Phantom);
				
			} else {
				// Attempt to match values with the entire attribute value.
				var matches = find( to );
				
				if (matches.length > 0) {
					result = (matches.map( cast pair.b.stringify ).join(' '):Phantom);
					
				}
				
			}
			
		}
		
		console.log( result );
		
		return result;
	}
	
	/*@:op(A>>B) @:commutative
	public static function mapArrayValues<D, S>(node:Phantom, pair:Pair<Array<Any>, IProcessor<D, S>>):Phantom {
		var result = node;
		var to = node.to;
		
		if (pair.a.length > 0) {
			var matches = [];
			
			for (value in pair.a) {
				console.log( value );
				
				if (to != null) {
					var start = to.indexOf('{');
					var end = to.indexOf('}');
					
					//console.log( start, end, start > -1 && end > -1 && end > start );
					// Value needs to be interpreted.
					if (start > -1 && end > -1 && end > start) {
						var interpreted = to.trackAndInterpolate('}'.code, ['{'.code => '}'.code], function(str) {
							var m = pair.b.find( cast value, str );
							console.log( m, str, str.length );
							return m.length > 0 ? m.map( cast pair.b.stringify ).join(' ') : str;
						} );
						
						matches.push( interpreted.value );
						
					} else {
						// Attempt to match values with the entire attribute value.
						var m = pair.b.find( cast value, to );
						
						if (m.length > 0) {
							matches.push( m.map( cast pair.b.stringify ).join(' ') );
							
						}
						
					}
					
				}
				
			}
			
			console.log( matches );
			
		}
		
		return result;
	}*/
	
	private static function finder<D, S>(pair:Pair<D, IProcessor<D, S>>, str:String):String {
		console.log( pair.a, str );
		var matches = pair.b.find( pair.a, str );
		console.log( matches );
		return matches.length > 0 ? matches.map( cast pair.b.stringify ).join(' ') : str;
		
	}
	
}
