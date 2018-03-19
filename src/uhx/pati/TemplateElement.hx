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
	
	public function new(?prefix:String, ?name:String, ?template:js.html.TemplateElement) {
		super(prefix, name);
		
		if (template == null) {
			if (prefix == null) prefix = htmlPrefix;
			if (name == null) name = htmlName;
			
			var node = owner.querySelector('$Template[$Prefix="$prefix"][$Name="$name"]');
			if (node != null) {
				this.template = cast node;

			} else {
				this.template = cast window.document.createElement(Template);

			}
			
		} else {
			this.template = template;

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
