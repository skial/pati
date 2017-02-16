package uhx.pati;

import js.html.*;
import js.Browser.*;
import uhx.pati.Consts;

class TemplateElement extends CustomElement {
	
	public static function main() {
		var _ = new TemplateElement();
	}
	
	//
	
	@:isVar public var owner(get, null):HTMLDocument;
	@:isVar public var template(get, null):js.html.TemplateElement;
	
	public function new(?prefix:String, ?name:String, ?template:String) {
		super(prefix, name);
		
		if (prefix != null && name != null) {
			this.template = cast window.document.createElement(Template);
			
			if (template != null) {
				var tmp = window.document.createElement('div');
				tmp.innerHTML = template;
				for (node in tmp.childNodes) this.template.content.appendChild(node);
				
			}
			
		}
		
	}
	
	// v0 lifecycle callbacks
	
	public override function createdCallback():Void {
		var content = template.content;
		var active = window.document.importNode( content, true );
		
		this.appendChild( active );
		
		super.createdCallback();
	}
	
	//
	
	private function get_owner():HTMLDocument {
		if (owner == null) owner = window.document.currentScript != null ? window.document.currentScript.ownerDocument : window.document;
		return owner;
	}
	
	private function get_template():js.html.TemplateElement {
		if (template == null) template = cast owner.querySelector(Template);
		return template;
	}
	
	private override function get_htmlPrefix():String {
		if (htmlPrefix == null && template.hasAttribute(Prefix)) {
			htmlPrefix = template.getAttribute(Prefix);
			
		} else {
			super.get_htmlPrefix();
			
		}
		
		return htmlPrefix;
	}
	
	private override function get_htmlName():String {
		if (htmlName == null && template.hasAttribute(Name)) {
			htmlName = template.getAttribute(Name);
			
		} else {
			super.get_htmlName();
			
		}
		
		return htmlName;
	}
	
}
