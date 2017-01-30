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
	var Template = 'template';
}

@:enum @:forward abstract AttributeConsts(String) from String to String {
	var UID = 'uid';
	var Name = 'data-name';
	var Prefix = 'data-prefix';
	var To = 'to:';
	var Select = 'select';
	var PendingRemoval = 'pending-remove';
	var ScopedData = 'scoped-data';
	var Phase = 'phase';
	var Each = 'each';
	var Append = ':+';
	var Prepend = '+:';
	var UseText = 'use:text';
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
