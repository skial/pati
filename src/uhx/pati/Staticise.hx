package uhx.pati;

import js.html.*;
import js.Browser.*;
import uhx.pati.Consts;
import uhx.pati.EventPhase;

using StringTools;
using uhx.pati.Utilities;

class Staticise extends Component {
	
	public function new() {
		super();
	}
	
	//
	
	// overrides
	
	public override function attachedCallback():Void {
		var contents = querySelectorAll('content');
		var differences = contents.length > 0 ? this.diff( template ) : [];
		
		// Move unknown elements based on the original template into any `<content>`
		// if they exist. Then remove any existing `<content>` tags.
		// TODO support `select` attribute.
		for (node in contents) {
			var content:ContentElement = cast node;
			for (difference in differences) content.parentElement.insertBefore(difference, content);
			content.remove();
			
		}
		
		super.attachedCallback();
	}
	
	public override function attached():Void {
		super.attached();
		
		if (phase == Bubbling && isCustomChild) {
			parentElement.dispatchEvent( new CustomEvent(Completed, {detail:uid, bubbles:!phase}) );
			
		} else {
			remove();
			
		}
		
	}
	
}
