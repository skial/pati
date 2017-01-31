package uhx.pati;

class DocumentHead extends MoveTags {
	
	public static function main() {
		var _ = new DocumentHead();
	}
	
	//
	
	public function new() {
		super();
	}
	
	// override
	
	public override function get_to():Null<String> {
		return 'head';
	}
	
}
