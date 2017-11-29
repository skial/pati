package uhx.pati;

import uhx.pati.*;

// All Custom Elements
class ACE {
	
	public static function main() {
		JsonData.init();
		
		// 
		
		var d = new DomData('dom', 'data');
		var m = new MoveTags('move', 'tags');
		var j = new JsonData('json', 'data');
		var c = new ConvertTag('convert', 'tag');
		var h = new DocumentHead('document', 'head');
		var b = new DocumentBody('document', 'body');
		var i = new SvgObject('svg', 'obj');
	}
	
}
