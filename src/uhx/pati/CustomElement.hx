package uhx.pati;

import js.html.*;
import js.Browser.*;

class CustomElement extends Element {
	
	public static var knownComponents:KnownComponents = new KnownComponents();
	
	@:isVar public var htmlName(get, null):String;
	@:isVar public var htmlPrefix(get, null):String;
	@:isVar public var htmlFullname(get, set):String;
	
	public function new() {
		if (knownComponents.indexOf( htmlFullname ) == -1) {
			knownComponents.push( htmlFullname );
			
		}
		
		console.log( htmlName, htmlPrefix, htmlFullname, knownComponents );
		window.document.registerElement(htmlFullname, { prototype: this });
		
	}
	
	// Lifecycle callbacks for v0 of the Custom Elements spec.
	
	// 	An instance of the element is created
	@:keep public function createdCallback():Void {
		
	}
	
	// An instance was inserted into the document
	@:keep public function attachedCallback():Void {
		
	}
	
	// An instance was removed from the document
	@:keep public function detachedCallback():Void {
		
	}
	
	// An attribute was added, removed, or updated
	@:keep public function attributeChangedCallback(name:String, oldValue:Any, newValue:Any):Void {
		
	}
	
	//
	
	private function get_htmlPrefix():String {
		return 'hx';
	}
	
	private function get_htmlName():String {
		return 'customelement';
	}
	
	private function get_htmlFullname():String {
		if (htmlFullname == null) htmlFullname = '$htmlPrefix-$htmlName';
		return htmlFullname;
	}
	
	private function set_htmlFullname(v:String):String {
		return htmlFullname = v;
	}
	
}
