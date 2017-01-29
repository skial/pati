package uhx.pati;

@:enum @:forward abstract EventPhase(Bool) from Bool to Bool {
	public var Capturing = true;
	public var Bubbling = false;
	
	@:to public inline function asString():String {
		return switch this {
			case true: 'capture';
			case false: 'bubble';
		}
	}
	
}
