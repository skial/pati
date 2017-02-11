package ;

import js.html.*;
import js.Browser.*;
import utest.Assert;
import utest.Runner;
import tink.core.Pair;
import utest.ui.Report;
import uhx.pati.Phantom;
import utest.TestFixture;
import haxe.DynamicAccess;

using StringTools;

@:enum @:forward private abstract LocalConsts(String) from String to String {
	public var DOMContentLoaded = 'DOMContentLoaded';
	public var Scope = ':scope';
	public var Expected = '.expected';
	public var Outcome = '.outcome';
	public var Section = 'section';
}

@:forward @:forwardStatics private abstract TestError(Pair<Phantom, Phantom>) from Pair<Phantom, Phantom> to Pair<Phantom, Phantom> {
	
	public inline function new(a, b) {
		this = new Pair(a, b);
	}
	
	@:to public function toString():String {
		return 'Expected `${this.a.outerHTML}` but got `${this.b.outerHTML}`.';
	}
	
}

class Main {
	
	public static function main() {
		window.document.addEventListener(DOMContentLoaded, function(e) {
			window.setTimeout( function() {
				var runner = new Runner();
				
				var sections = [for (c in window.document.querySelectorAll(Section)) (c:Phantom)];
				
				for (section in sections) {
					var expected = section.querySelectorAll('$Scope > $Expected');
					var outcome = section.querySelectorAll('$Scope > $Outcome' );
					var tests = new SectionRunner(expected[0], outcome[0], section.getAttribute('class').replace(' ', '_'));
					runner.addCase( tests.makeUnique(), 'setup', 'teardown', tests.name );
					
				}
				
				Report.create(runner);
				runner.run();
			}, 1000 );
			
		});
		
	}
	
}

@:keep private class SectionRunner {
	
	public var name:String;
	public var outcome:Phantom;
	public var expected:Phantom;
	
	public function new(expected:Phantom, outcome:Phantom, name:String) {
		this.name = name;
		this.outcome = outcome;
		this.expected = expected;
	}
	
	public function makeUnique():SectionRunner {
		var newFields:DynamicAccess<Void->Void> = {};
		
		for (field in Type.getInstanceFields(SectionRunner)) {
			if (field.startsWith('test')) {
				newFields['${name}_${field}'] = Reflect.field(this, field);
				
			}
			
		}
		var copy:Class<SectionRunner> = SectionRunner;
		untyped copy.prototype = __js__("$extend")(SectionRunner.prototype, newFields);
		
		return Type.createInstance(untyped copy, [expected, outcome, name]);
	}
	
	public function testChildLength() {
		Assert.equals( expected.children.length, outcome.children.length );
	}
	
	public function testChildren() {
		var check:Phantom->Phantom->Void = null;
		var loop:Phantom->Phantom->Void = null;
		
		check = function(e, o) {
			if (o == null) throw '`o` can not be null.';
			Assert.equals( e.nodeType, o.nodeType, o.outerHTML );
			Assert.equals( e.nodeName, o.nodeName, o.outerHTML );
			
			for (attribute in e.attributes) {
				Assert.isTrue( o.hasAttribute(attribute.name) );
				Assert.equals( attribute.value, o.getAttribute(attribute.name) );
				
			}
			
			Assert.equals( e.children.length, o.children.length, new TestError(e, o) );
			
			for (i in 0...e.children.length) {
				loop( e.children[i], o.children[i] );
				
			}
			
		}
		
		loop = function loop(e, o) {
			Assert.notNull( o );
			Assert.equals( e.children.length, o.children.length, new TestError(e, o) );
			
			for (i in 0...e.children.length) {
				try {
					check( e.children[i], o.children[i] );
					
				} catch (error:Any) {
					console.log( new TestError(e, o).toString(), error );
					
				}
				
			}
			
		}
		
		loop(expected, outcome);
		
	}
	
}
