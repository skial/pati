package uhx.pati;

import haxe.ds.IntMap;

using StringTools;
using uhx.pati.Utilities;

class Utilities {
	
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
				var _info = value.substr( index + 1 ).trackAndInterpolate( until, track, resolve );
				var _value = _info.value;
				match = true;
				pos = index += _info.length + 2;
				result += _value;

			} else {
				result += String.fromCharCode( character );
				pos = index++;
				
			}

		}
		
		return {matched:match, length:pos, value:resolve(result)};
	}
	
}
