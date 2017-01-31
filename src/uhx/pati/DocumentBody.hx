package uhx.pati;

class DocumentBody extends MoveTags {
	
	public static function main() {
		var _ = new DocumentBody();
	}
	
	//
	
	public function new() {
		super();
	}
	
	// override
	
	public override function get_to():Null<String> {
		return 'body';
	}
	
}
