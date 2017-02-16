package uhx.pati;

import js.html.*;
import thx.Decimal;
import js.Browser.*;
import uhx.pati.EWait;
import thx.unit.time.*;
import tink.core.Pair;
import uhx.uid.Hashids;
import uhx.pati.Consts;
import tink.core.Signal;
import tink.core.Callback;
import uhx.pati.EventPhase;
import uhx.pati.EventListener;

using StringTools;
using uhx.pati.Utilities;

class Component extends uhx.pati.TemplateElement {
	
	public static var hash:Hashids = new Hashids();
	
	@:isVar public static var observer(get, null):MutationObserver;
	@:isVar public static var mutated(get, null):Signal<Array<MutationRecord>>;
	@:isVar public static var mutatedTrigger(get, null):SignalTrigger<Array<MutationRecord>>;
	
	//
	
	private static function get_observer():MutationObserver {
		if (observer == null) observer = new MutationObserver( onMutation );
		return observer;
	}
	
	private static function get_mutated():Signal<Array<MutationRecord>> {
		if (mutated == null) {
			observer.observe( window.document, {childList:true, subtree:true} );
			mutated = mutatedTrigger;
			
		}
		
		return mutated;
	}
	
	private static function get_mutatedTrigger():SignalTrigger<Array<MutationRecord>> {
		if (mutatedTrigger == null) mutatedTrigger = Signal.trigger();
		return mutatedTrigger;
	}
	
	//
	
	private static function onMutation(records:Array<MutationRecord>, observer:MutationObserver):Void {
		mutatedTrigger.trigger( records );
		
	}
	
	//
	
	@:isVar public var uid(get, set):String;
	@:isVar public var wait(get, null):EWait;
	@:isVar public var isCustomChild(get, null):Bool;
	@:isVar public var hasCustomChildren(get, null):Bool;
	
	public var phase(get, null):EventPhase;
	public var events(get, null):Map<String, EventListener>;
	
	public function new(?prefix:String, ?name:String) {
		super(prefix, name);
	}
	
	// v0 lifecycle callbacks
	
	public override function createdCallback():Void {
		super.createdCallback();
		
		for (key in events.keys()) {
			var event = events.get(key);
			addEventListener(key, event.method, untyped event.options);
			
		}
		
		created();
	}
	
	public override function attachedCallback():Void {
		super.attachedCallback();
		
		uid = stampUid( this );
		setAttribute(Phase, phase);
		
		if (isCustomChild) parentElement.dispatchEvent( new CustomEvent(ChildAdded, { detail:uid, bubbles:true } ) );
		if (phase == Bubbling && !hasCustomChildren) {
			intercept();
			
		} else if (phase == Capturing && !isCustomChild) {
			intercept();
			
		}
		
	}
	
	public override function detachedCallback():Void {
		super.detachedCallback();
		
		detached();
	}
	
	public function intercept():Void {
		switch wait {
			case Until(0):
				attached();
				
			case Until(x) if (x > 0):
				window.setTimeout( attached, x );
				
			case For(s):
				var link:CallbackLink = null;
				var callback:Callback<Array<MutationRecord>> = null;
				
				callback = function(_) {
					if (document.querySelectorAll(s).length > 0) {
						link.dissolve();
						attached();
						
					}
					
				};
				
				link = mutated.handle( callback );
				
		}
		
	}
	
	//
	
	public function created():Void {
		
	}
	
	public function attached():Void {
		
	}
	
	public function detached():Void {
		for (key in events.keys()) {
			var event = events.get(key);
			removeEventListener(key, event.method);
		}
		
	}
	
	// private methods
	
	private function stampUid(node:Node):String {
		var result = '';
		
		if (node.nodeType == Node.TEXT_NODE) {
			result = node.textContent;
			
		} else if (node.nodeType != Node.COMMENT_NODE) {
			var ele:Element = cast node;
			var stamp = ele.nodeName + [for (a in ele.attributes) if (a.name != UID) a.name + a.value].join('') + ele.querySelectorAll(All).length;
			
			result = hash.encode( [for (i in 0...stamp.length) stamp.charCodeAt(i)] );
			
		}
		//console.log( this, uid );
		return result;
	}
	
	// Custom event handlers
	
	public function onCustomChildAdded(?e:CustomEvent):Void {
		//console.log( htmlFullname, e );
		e.stopPropagation();
	}
	
	public function onCustomChildFinished(?e:CustomEvent):Void {
		//console.log( htmlFullname, e );
		e.stopPropagation();
		var children:Array<Element> = [for (node in querySelectorAll('[UID="${e.detail}"]')) cast node];
		
		for (child in children) child.remove();
		
		if (!hasCustomChildren) attached();
	}
	
	public function onCustomParentFinished(?e:CustomEvent):Void {
		//console.log( htmlFullname, e );
		e.stopPropagation();
		
		created();
	}
	
	//
	
	private function get_wait():EWait {
		if (wait == null) if (!hasAttribute(Wait)) {
			wait = Until(0);
			
		} else {
			wait = getAttribute(Wait).parseWaitAttribute();
			
		}
		
		return wait;
	}
		
	private #if !debug inline #end function get_uid():String {
		if (!hasAttribute(UID) && uid == null) {
			uid = '';
			
		} else if (hasAttribute(UID)) {
			uid = getAttribute(UID);
			
		}
		
		return uid;
	}
	
	private #if !debug inline #end function set_uid(v:String):String {
		setAttribute(UID, v);
		return uid = v;
	}
	
	private #if !debug inline #end function get_isCustomChild():Bool {
		return window.document.querySelectorAll('[$UID] $htmlFullname[$UID="$uid"]').length > 0;
	}
	
	private #if !debug inline #end function get_hasCustomChildren():Bool {
		return querySelectorAll( CustomElement.knownComponents.map(function(v) return '$Scope $v').join(', ') ).length > 0;
	}
	
	private function get_phase():EventPhase {
		return Bubbling;
	}
	
	private function get_events():Map<String, EventListener> {
		return [ChildAdded => onCustomChildAdded, Completed => { method:phase == Bubbling? onCustomChildFinished : onCustomParentFinished, capture:phase }];
	}
	
}
