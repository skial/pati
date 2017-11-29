package uhx.pati;

import js.html.*;
import js.Browser.*;
import uhx.pati.Consts;

using StringTools;
using tink.CoreApi;
using haxe.io.Path;

@:forward @:enum abstract SvgConsts(String) from String to String {
    var Svg = 'svg';
    var SvgNamespace = "http://www.w3.org/2000/svg";
}

class SvgObject extends ConvertTag<Array<Phantom>, Phantom> implements IProcessor<Array<Phantom>, Phantom> { 

    public static function main() {
        var _ = new SvgObject();
    }

    //

    @:isVar public var data(get, null):Null<String>;

    public function new(?prefix:String, ?name:String) {
        super(prefix, name);
    }

    private function callSuperAttached() {
        super.attached();
    }

    public override function attached():Void {
        if (data != null) {
            console.log( data );
            var content:Surprise<Response, Error> = window.fetch( data );
            content.handle( function(o) switch o {
                case Success(r):
                    Future.ofJsPromise( r.text() ).handle( function(o) switch o {
                        case Success(s):
                            var svg = document.createElementNS(SvgNamespace, Svg);
                            svg.innerHTML = s;
                            svg = svg.firstElementChild;
                            console.log( svg );
                            onDataAvailable( [svg] );

                        case Failure(e):
                            console.log( e );
                            callSuperAttached();

                    } );

                case Failure(e):
                    console.log( e );
                    callSuperAttached();

            } );

        } else {
            callSuperAttached();

        }

    }

    // IProcessor fields

    public function stringify(data:Array<Phantom>):String {
        return data.map( p -> p.outerHTML ).join('\n');
    }

    public function onDataAvailable(data:Array<Phantom>):Void {
        var svg = data.shift();

        for (attribute in attributes) switch attribute.name {
            case _.startsWith(To) || ignoredAttributes.indexOf(_) > -1 => false if (!svg.hasAttribute(attribute.name)):
                svg.setAttribute( attribute.name, attribute.value );
                
            case _:

        }

        parentElement.appendChild( svg );
        
        super.attached();
    }

    public function find(data:Array<Phantom>, selector:String):Array<Phantom> {
        return [];
    }

    public function handleNode(node:Phantom, data:Array<Phantom>, forEach:Bool = false):Void {
        
    }

    //

    private function get_data():Null<String> {
        if (data == null && hasAttribute(Data)) {
            data = getAttribute(Data);

        }

        return data;
    }

    private override function get_ignoredAttributes():Array<String> {
        return super.get_ignoredAttributes().concat( [Data] );
    }

}