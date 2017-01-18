package uhx.pati;

import js.html.*;
import js.Browser.*;
import uhx.pati.Consts;

class Capturing extends Component {
	
	public static var values:Array<Int> = untyped (window.specValues:Array<Int>).copy();
	
	public static function main() {
		var _ = new Capturing();
	}
	
	public function new() {
		super();
	}
	
	// v0 lifecycle callbacks
	
	public override function created():Void {
		super.created();
	}
	
	public override function attached():Void {
		super.attached();
		
		if (values.length > 0) this.parentElement.insertBefore(window.document.createTextNode('' + values.shift()), this);
		for (node in this.childNodes) this.parentElement.insertBefore(window.document.importNode(node, true), this);
		
		this.remove();
	}
	
	public override function detached():Void {
		super.detached();
	}
	
	public override function get_phase():EventPhase {
		return Capturing;
	}
	
}
