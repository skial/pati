package uhx.pati;

@:enum @:forward abstract SelectorConsts(String) from String to String {
	var All = '*';
	var Template = 'template';
}

@:enum @:forward abstract AttributeConsts(String) from String to String {
	var UID = 'uid';
	var Name = 'data-name';
	var Prefix = 'data-prefix';
}

@:enum @:forward abstract StorageConsts(String) from String to String {
	var Storage = 'uhx_pati_component_storage';
}

@:enum @:forward abstract EventConsts(String) from String to String {
	var DOMContentLoaded = 'DOMContentLoaded';
	var ChildAdded = 'Pati_ChildAdded';
	var Completed = 'Pati_ElementCompleted';
}
