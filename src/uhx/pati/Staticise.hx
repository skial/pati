package uhx.pati;

import js.html.*;
import js.Browser.*;
import uhx.pati.Consts;
import uhx.pati.EventPhase;

class Staticise extends Component {
	
	public function new() {
		super();
	}
	
	//
	
	public override function attached():Void {
		super.attached();
		
		if (phase == Bubbling && isCustomChild) {
			this.parentElement.dispatchEvent( new CustomEvent(Completed, {detail:uid, bubbles:!phase}) );
			
		} else {
			this.remove();
			
		}
		
	}
	
}
