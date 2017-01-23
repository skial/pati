package ;

import js.html.*;
import js.Browser.*;
import uhx.pati.Consts;
import uhx.pati.Component;
import uhx.pati.CustomElement;
import uhx.pati.TemplateElement;

class Main {
	
	public static function main() {
		window.document.addEventListener('DOMContentLoaded', function(e){
			console.log(e);
			var event = new CustomEvent(JsonDataRecieved, {detail:untyped window.json_data, bubbles:true});
			console.log( event );
			window.document.dispatchEvent( event );
		}, untyped {once:true});
	}
	
}
