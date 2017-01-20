package uhx.pati;

import js.html.*;
import js.Browser.*;
import uhx.pati.Consts;

class Bubbling extends Staticise {
	
	public static var values:Array<Int> = untyped (window.specValues:Array<Int>).copy();
	
	public static function main() {
		var _ = new Bubbling();
	}
	
	public function new():Void {
		super();
	}
	
	//
	
	public override function attached():Void {
		if (values.length > 0) this.parentElement.insertBefore(window.document.createTextNode('' + values.shift()), this);
		for (node in this.childNodes) this.parentElement.insertBefore(window.document.importNode(node, true), this);
		
		super.attached();
	}
	
}
