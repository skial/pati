package uhx.pati.macro;

import haxe.macro.Type;
import haxe.macro.Expr;
import uhx.mo.html.Lexer;
import uhx.mo.html.Parser;
import haxe.macro.Printer;
import haxe.macro.Context;
import uhx.pati.macro.PhantomElement.Exceptions.*;

using StringTools;
using haxe.macro.Context;
using tink.CoreApi;
using tink.MacroApi;
using uhx.pati.macro.HtmlDetails;
using uhx.pati.macro.PhantomElement.MapHelper;

@:forward enum abstract Metadata(String) from String to String {
    var Target = ':target';
    var DataTarget = ':data.target';
    var Action = ':action';
    var DataAction = ':data.action';
    var DataController = ':data.controller';
    var Attr = ':attr';
    var DataAttr = ':data.attr';
    var Attribute = ':attribute';
    var DataAttribute = ':data.attribute';
}

abstract Exceptions(String->String) {
    public static var ClassNotFound = _ -> 'Unable to resolve class.';
    public static var MetaMissingParam = m -> '@$m can not be an empty string.';
    public static var MissingEvent = m -> '@$m requires an event name. Eg `@$m("click")`.';
    public static var UserDefinedAccess = m -> 'User defined (g/s)etters will have to get/set @$m manually.';
    public static var NotSupported = m -> '@$m on methods are not supported.';
}

typedef Controller = {
    var name:String;
    var knownTargets:Map<String, {c:ComplexType, n:String, f:Field}>;
    var knownActions:Map<String, Field>;
    var knownAttributes:Map<String, {a:String, f:Field}>;
    var actionExprs:Array<Expr>;
    var targetElements:Array<Field>;
    var removables:Array<String>;
    var updatables:Map<String, Array<{?get:Expr, ?set:Expr, t:ComplexType, ?e:Expr, ?meta:haxe.macro.Expr.Metadata}>>;
}

class PhantomElement {

    #if (eval || macro)
    private static var printer:Printer = new Printer();
    private static var stringType = (macro:String).toType().sure();
    private static var controller:Controller = {
        name: '',
        knownTargets: new Map<String, {c:ComplexType, n:String, f:Field}>(),
        knownActions: new Map<String, Field>(),
        knownAttributes: new Map<String, {a:String, f:Field}>(),
        actionExprs: [],
        targetElements: [],
        removables: [],
        updatables: new Map<String, Array<{?get:Expr, ?set:Expr, t:ComplexType, ?e:Expr, ?meta:haxe.macro.Expr.Metadata}>>(),
    };
    
    public static function build():Array<Field> {
        var type = Context.getLocalClass();
        var fields = Context.getBuildFields();

        if (type == null) {
            Context.fatalError(ClassNotFound(''), Context.currentPos());
            return fields;
        }

        var html = '<html><head></head><body></body></html>';
        var p = new Parser();
        trace( p.toTokens(byte.ByteData.ofString(html), 'phantom') );

        var cls = type.get();
        controller.name = cls.name.toLowerCase();

        for (field in fields) {
            switch [field.name, field.kind] {
                case [_.endsWith('Target') => true, FVar(ctype, _)]:
                    var key = field.name.replace('Target', '');
                    var info = controller.knownTargets.exists(key) 
                        ? controller.knownTargets.get(key)
                        : { c: null, n: null, f: null };

                    info.c = ctype;
                    #if debug
                    /*var pm = (m:MetadataEntry) -> '@' + m.name + ' (' + m.params.map(p->p.toString()).join(', ') + ')';
                    trace( ctype.toType().sure().getMeta()[0].get().map( pm ) );
                    trace( ctype.toType().sure().getFields().sure().map( f -> f.name + ' ' + f.meta.get().map( pm )) );*/
                    #end
                    controller.knownTargets.set(key, info);
                    controller.removables.push( field.name );

                case _:

            }

            for (meta in field.meta) switch meta.name {
                case Attr, DataAttr, Attribute, DataAttribute if (!field.kind.match(FFun(_))):
                    var attr = field.name;
                    if (meta.params.length > 0) {
                        attr = meta.params[0].toString();
                        attr = attr.trim().substr(1, attr.length-2);
                    }

                    controller.knownAttributes.set(field.name, {a:attr, f:field});

                case t = Target, t = DataTarget if (!field.kind.match(FFun(_))):
                    var key = field.name;
                    if (meta.params.length > 0) {
                        key = meta.params[0].toString();
                        key = key.trim().substr(1, key.length-2);
                    }

                    var info = controller.knownTargets.exists(key)
                        ? controller.knownTargets.get(key)
                        : {f:null, c:macro:js.html.Element, n:null};

                    info.n = key;
                    info.f = field;
                    controller.knownTargets.set(field.name, info);

                case m = Action, m = DataAction if (field.kind.match(FFun(_))):
                    var key = field.name;

                    if (meta.params.length > 0) {
                        key = meta.params[0].toString();
                        key = key.substr(1, key.length-2);
                        if (key.length == 0) Context.fatalError(MetaMissingParam(m), meta.pos);

                    } else {
                        // TODO try to determine event name from the type parameter. IE MouseEvent could be `click` etc. Offer suggestions based on info.
                        Context.fatalError(MissingEvent(m), meta.pos);

                    }

                    controller.knownActions.set(key, field);
                    break;

                case x:
                    //trace(meta.name, meta.params.map(p->p.toString()));

            }

        }

        // @:data.action
        for (key in controller.knownActions.keys()) {
            var event = key;
            var field = controller.knownActions.get(key);
            var selector = '[data-action="${event}->${controller.name}#${field.name}"]';

            controller.actionExprs.push( macro @:mergeBlock {
                var element = this.root.querySelector($v{selector});
                if (element != null && element.nodeType == 1) element.addEventListener($v{key}, $i{field.name});
            } );
        }

        // @:data.target
        for (key in controller.knownTargets.keys()) {
            var info = controller.knownTargets.get(key);
            var name = info.n + 'Target';
            var getter = 'get_$name';
            var selector = '[data-target="${controller.name}.${key}"]';
            var ctype = info.c;

            var newFields = (macro class {
                @:isVar private var $name(get, null):$ctype;
                private function $getter():$ctype {
                    if ($i{name} == null) {
                        var result = this.root.querySelector($v{selector});
                        if (result != null && result.nodeType == 1) $i{name} = cast result;
                    }
                    return $i{name};
                }
            }).fields;
            
            if (!controller.knownAttributes.exists(key)) switch ctype.toType() {
                case Success(data):
                    switch info.f.kind {
                        case FVar(c, _) | FProp(_, _, c, _): 
                            var t = c.toType().sure();
                            var defaults = data.defaultValues(true);
                            var typeMatches = defaults.filter( f -> f.type.unify(t) );
                            var stringMatches = defaults.filter( f -> f.type.unify(stringType) );
                            #if debug
                            /*trace( defaults.map( f -> f.name ) );
                            trace( c.toString(), typeMatches.map( f -> f.name ) );
                            trace( stringMatches.map( f -> f.name ) );*/
                            #end

                            var wrap = false;
                            var matchedField = typeMatches[0];
                            if (wrap = matchedField == null) matchedField = stringMatches[0];

                            var getterExpr = '${name}.${matchedField.name}'.resolve();
                            if (wrap) getterExpr = macro (be.co.Coerce.value($getterExpr):$c);

                            var setterExpr = '${name}.${matchedField.name}'.resolve();

                            controller.updatables.add( info.f.name, {
                                t: c,
                                get: getterExpr,
                                set: macro $setterExpr = $e{wrap ? macro Std.string(v) : macro v},
                                meta: [{ name:':isVar', params:[], pos:info.f.pos }]
                            } );

                        case _:

                    }

                case _:
            }

            #if debug
            for (f in newFields) trace(printer.printField(f));
            #end
            for (f in newFields) controller.targetElements.push( f );
        }

        // @:data.attribute
        for (key in controller.knownAttributes.keys()) {
            var info = controller.knownAttributes.get(key);
            var name = key;
            var getter = 'get_$key';
            var setter = 'set_$key';
            var attr = info.a;
            var ctype:ComplexType = null;
            var expr:Expr = null;
            var alsoTarget = controller.knownTargets.exists(key);

            switch info.f.kind {
                case FVar(t, e):
                    ctype = t;
                    expr = e;

                case FProp(get, set, t, e):
                    ctype = t;
                    expr = e;

                    // TODO setters can be modified. Getters can not, as far as I can see.
                    if (get == 'get' || set == 'set') {
                        Context.fatalError(UserDefinedAccess(':attr'), info.f.pos);
                    }
                    
                case _:
                    Context.fatalError(NotSupported(':attr'), info.f.pos);
            }

            var root = alsoTarget ?
                'this.${name}Target'.resolve()
                : macro this.root;
            var coerce = if (ctype.toType().sure().unify(stringType)) {
                macro $root.getAttribute($v{attr});
            } else {
                macro be.co.Coerce.value($root.getAttribute($v{'data-${controller.name}-${attr}'}));
            }
            
            var extra = if (expr != null) {
                macro if (r == null) {
                    r = $expr;
                }
            } else {
                macro @:mergeBlock {};
            }
            
            controller.updatables.add( info.f.name, {
                t: ctype,
                get: macro {
                    var r:$ctype = $coerce;
                    $extra;
                    r;
                },
                set: macro $root.setAttribute($v{'data-${controller.name}-${attr}'}, '' + v),
                meta: [{ name:':isVar', params:[], pos:info.f.pos }]
            } );

        }

        var map = [for (field in (macro class {

            public static var knownActions = [/*'click->empty#sayHello'*/];
            public static var knownTargets = [/*'bar', 'foo', 'fooy'*/];
            public static var observedAttributes = ['data-controller', 'data-target', 'data-action'];
            public static var watchWhat:js.html.MutationObserverInit = {attributes:true, attributeFilter: observedAttributes, childList:true, subtree:false};

            //

            public var root:js.html.Element;

            public function new(root:js.html.Element) {
                this.root = root;
                setup();
            }

            public function setup() {
                $a{controller.actionExprs};
            }

        }).fields) field.name => field];

        processUpdatables(controller, fields);

        for (field in controller.targetElements) map.set( field.name, field );

        fields = [for (field in fields) if (controller.removables.indexOf(field.name) == -1) field];
        for (field in fields) if (map.exists(field.name)) map.remove(field.name);
        for (key in map.keys()) {
            //trace(key);
            fields.push( map.get(key) );
        }

        return fields;
    }

    private static function processUpdatables(controller:Controller, fields:Array<Field>):Void {
        // Merge changes into (g/s)etters.
        for (key in controller.updatables.keys()) {
            var changes = controller.updatables.get( key );
            var matches = fields.filter( f -> f.name == key );

            if (matches.length > 0) {
                var field = matches[0];
                var ctype = changes[0].t;   // Even though each entry stores the type, each entry is assumed to be the same type.
                var getterName = 'get_${field.name}';
                var getterExprs = changes.map( c -> c.get ).filter( c -> c != null );
                var setterName = 'set_${field.name}';
                var setterExprs = changes.map( c -> c.set ).filter( c -> c != null );

                var getter = getterExprs.length > 0 ? (macro class {
                    public function $getterName():$ctype {
                        return @:mergeBlock $b{getterExprs};
                    }
                }).fields[0] : null;

                var setter = setterExprs.length > 0 ? (macro class {
                    public function $setterName(v:$ctype):$ctype {
                        @:mergeBlock $b{setterExprs};
                        return v;
                    }
                }).fields[0] : null;

                switch field.kind {
                    case FVar(t, e):
                        field.kind = FProp(getter == null ? 'default' : 'get', setter == null ? 'default' : 'set', ctype, null);

                    case FProp(get, set, t, e):
                        // TODO check existing get/set
                        field.kind = FProp(getter == null ? 'default' : 'get', setter == null ? 'default' : 'set', ctype, null);

                    case _:
                        Context.fatalError('This shouldnt have been reached, please report.', field.pos);

                }

                var stringifyMeta = (m:MetadataEntry) -> '${m.name}:${m.params.map(e->e.toString())}';
                var stringMeta = field.meta.map(stringifyMeta);
                for (change in changes) {
                    if (change.meta != null) for (meta in change.meta) {
                        var _sm = stringifyMeta(meta);
                        if (stringMeta.indexOf( _sm ) == -1) {
                            field.meta.push( meta );
                            stringMeta.push( _sm );

                        }

                    }
                }

                if (getter != null) controller.targetElements.push( getter );
                if (setter != null) controller.targetElements.push( setter );

                #if debug
                trace( printer.printField( field ) );
                if (getter != null) trace( printer.printField( getter ) );
                if (setter != null) trace( printer.printField( setter ) );
                #end


            }
        }
    }

    #end
    
}

class MapHelper {

    public static function add<T>(map:Map<String, Array<T>>, key:String, value:T):Void {
        var entry = (map.exists(key)) ? map.get(key) : [];
        entry.push(value);
        map.set(key, entry);
    }

}