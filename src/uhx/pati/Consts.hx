package uhx.pati;

@:enum @:forward abstract IntConsts(Int) from Int to Int {
	var Left = '{'.code;
	var Right = '}'.code;
	var Process = ':'.code;
	
	@:to private inline function asString():String {
		return switch this {
			case Left: '{';
			case Right: '}';
			case Process: ':';
			case _: String.fromCharCode(this);
		}
		
	}
	
}

@:enum @:forward abstract SelectorConsts(String) from String to String {
	var All = '*';
	var Root = ':root';
	var Scope= ':scope';
	var Content = 'content';
	var Template = 'template';
}

@:enum @:forward abstract AttributeConsts(String) from String to String {
	var ShortTo = To;
	var LongTo = 'to';
	var Append = ':+';
	var Prepend = '+:';
	var Select = 'select';
	var PendingRemoval = 'pending-remove';
}

@:enum @:forward abstract AttributeValues(String) from String to String {
	var True = 'true';
	var False = 'false';
}

@:enum @:foward abstract CustomElementAttributes(String) from String to String {
	var Name = 'data-name';
	var Prefix = 'data-prefix';
}

@:enum @:forward abstract ComponentAttributes(String) from String to String {
	var UID = 'uid';
	var Wait = 'wait';
	var Phase = 'phase';
}

@:enum @:forward abstract ConvertTagAttributes(String) from String to String {
	var To = 'to:';
}

@:enum @:forward abstract DomDataAttributes(String) from String to String {
	var UseText = 'use:text';
	var TargetCopy = 'target:copy'; // Default action.
	var TargetMove = 'target:move';
	var TargetRemove = 'target:remove';
}

@:enum @:forward abstract JsonDataAttributes(String) from String to String {
	var Each = 'each';
	var Retarget = "retarget";
	var ScopedData = 'scoped-data';
}

@:enum @:forward abstract StorageConsts(String) from String to String {
	var Storage = 'uhx_pati_component_storage';
}

@:enum @:forward abstract EventConsts(String) from String to String {
	var ChildAdded = 'Pati_ChildAdded';
	var Completed = 'Pati_ElementCompleted';
	var JsonDataRecieved = 'Pati_JsonDataRecieved';
}

typedef PhantomAttr = PhantomAttributes;

@:enum @:forward abstract PhantomAttributes(String) from String to String {
	var To = ':to';
}
