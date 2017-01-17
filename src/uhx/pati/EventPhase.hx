package uhx.pati;

@:enum @:forward abstract EventPhase(Bool) from Bool to Bool {
	public var Capturing = true;
	public var Bubbling = false;
}
