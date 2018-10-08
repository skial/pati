package uhx.pati;

import js.html.*;
import js.Browser.*;
import uhx.pati.Consts;
import uhx.pati.EventPhase;

using StringTools;
using uhx.pati.Utilities;

class Staticise extends Component {
	
	public function new(?prefix:String, ?name:String, ?template:js.html.TemplateElement) {
		super(prefix, name, template);
	}
	
	//
	
	// overrides
	
	public override function attachedCallback():Void {
		var contents = querySelectorAll('$Content:not([$PendingRemoval="$True"])');
		
		if (contents.length > 0) {
			var differences = this.diff( template );
			
			for (difference in differences) for (node in contents) if (!difference.contains(node)) {
				var content:Element = cast node;
				content.parentElement.insertBefore(difference, content);
				content.setAttribute(PendingRemoval, True);
				break;
				
			}
			
		}
		
		for (n in contents) (n:Phantom).remove();
					
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
