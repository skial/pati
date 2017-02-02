package uhx.pati;

import js.html.*;
import uhx.pati.Phantom;

/**
D == Data object to search, an array, object or map etc.
S == Single data type contained in the D object.
*/
interface IProcessor<D, S> {
	
	public function stringify(data:D):String;
	public function onDataAvailable(data:D):Void;
	public function find(data:D, selector:String):Array<S>;
	public function handleNode(node:Phantom, data:D, forEach:Bool = false):Void;
	
}
