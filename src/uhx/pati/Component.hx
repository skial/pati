package uhx.pati;

import js.html.*;
import js.Browser.*;
import uhx.pati.Consts;
import uhx.pati.EventPhase;
import uhx.pati.EventListener;

class Component extends uhx.pati.TemplateElement {
	
	@:isVar public var isCustomChild(get, null):Bool;
	@:isVar public var hasCustomChildren(get, null):Bool;
	
	public var phase(get, null):EventPhase;
	public var events(get, null):Map<String, EventListener>;
	
	public function new() {
		super();
	}
	
	// v0 lifecycle callbacks
	
	// Custom event handlers
	
	public function onCustomChildAdded(?e:CustomEvent):Void {
		
	}
	
	public function onCustomChildFinished(?e:CustomEvent):Void {
		
	}
	
	public function onCustomParentFinished(?e:CustomEvent):Void {
		
	}
	
	//
	
	private function get_isCustomChild():Bool {
		return window.document.querySelectorAll('[$UID] $htmlFullname[$UID="$uid"]').length > 0;
	}
	
	private function get_hasCustomChildren():Bool {
		return querySelectorAll( CustomElement.knownComponents.join(', ') ).length > 0;
	}
	
	private function get_phase():EventPhase {
		return Bubbling;
	}
	
	private function get_events():Map<String, EventListener> {
		return [ChildAdded => onCustomChildAdded, Completed => { method:phase == Bubbling? onCustomChildFinished : onCustomParentFinished, capture:phase }];
	}
	
}
