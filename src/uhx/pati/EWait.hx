package uhx.pati;

enum EWait {
	For(selector:String);
	Until(milliseconds:Int);
}
