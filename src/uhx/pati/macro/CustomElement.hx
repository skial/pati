package uhx.pati.macro;

import haxe.macro.Type;
import haxe.macro.Expr;
import haxe.macro.Context;

using tink.MacroApi;

@:forward @:forwardStatics private enum abstract Meta(String) from String to String {
    var Tag = ':tag';
}

@:forward @:forwardStatics private enum abstract Errors(String) from String to String {
    var UnavailableClass = 'Unable to access the current class.';
    var TagName = 'Custom element names require a dash to be used in them, they can not be single words.';
}

class CustomElement {

    public static var knownComponents:Map<String, ExprOf<Class<{htmlName:String}>>> = [];

    public static macro function build():Array<Field> {
        var fields = Context.getBuildFields();
        var ref = Context.getLocalClass();
        
        if (ref == null) {
            Context.error(UnavailableClass, Context.currentPos());
        }

        var cls = ref.get();
        var meta = cls.meta;
        var tag:String = 'x-${cls.name.toLowerCase()}';
        
        if (meta.has(Tag)) {
            var entry = meta.extract(Tag)[0];
            var value = entry.params[0].toString();
            if (value.indexOf('-') == -1) Context.error(TagName, entry.pos);
            tag = value;
            
        }

        trace( tag );

        var ceMap = [for (field in (macro class Tmp {
            @:keep public static final htmlName = $v{tag.substring(1, tag.length-1)};
            public static final observedAttributes:Array<String> = [];

            @:keep public function connectedCallback():Void {
                trace('connected');
            }

            @:keep public function disconnectedCallback():Void {
                trace('disconnected');
            }

            @:keep public function adoptedCallback():Void {
                trace('adopted');
            }

            @:keep public function attributeChangedCallback(name:String, oldValue:String = 'unknown', newValue:String = 'unknown'):Void {
                trace('attribute', name, oldValue, newValue);
            }
        }).fields) field.name => field ];

        for (field in fields) {
            if (ceMap.exists(field.name)) ceMap.remove(field.name);
            
        }

        var ceFields = [for (key in ceMap.keys()) ceMap.get(key)];
        knownComponents.set(tag.substring(1, tag.length-1), (TInst(ref, [])).getID().resolve() );

        return fields.concat(ceFields);
    }

}