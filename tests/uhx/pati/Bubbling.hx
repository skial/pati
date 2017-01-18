package uhx.pati;

import js.html.*;
import js.Browser.*;
import uhx.pati.Consts;

class Bubbling extends Component {
	
	public static var values:Array<Int> = untyped (window.specValues:Array<Int>).copy();
	
	public static function main() {
		var _ = new Bubbling();
	}
	
	public function new():Void {
		super();
	}
	
	// v0 lifecycle callbacks
	
	public override function created():Void {
		super.created();
	}
	
	public override function attached():Void {
		super.attached();
		
		this.parentElement.insertBefore(window.document.createTextNode('' + values.shift()), this);
		for (n in this.childNodes) this.parentElement.insertBefore(window.document.importNode(n, true), this);
		
		if (isCustomChild) {
			this.parentElement.dispatchEvent( new CustomEvent(Completed, {detail:uid, bubbles:!phase}) );
			
		} else {
			this.remove();
			
		}
		
	}
	
	public override function detached():Void {
		super.detached();
	}
	
}
