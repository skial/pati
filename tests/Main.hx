package ;

import js.html.*;
import js.Browser.*;
import utest.Assert;
import utest.Runner;
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

private class SectionRunner {
	
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
		var pairs = [];
		
		for (i in 0...expected.children.length) {
			pairs.push( [expected.children[i], outcome.children[i]] );
			
		}
		
		for (pair in pairs) {
			var a = pair[0];
			var b = pair[1];
			
			Assert.equals( a.nodeType, b.nodeType );
			Assert.equals( a.nodeName, b.nodeName );
			
			for (attribute in a.attributes) {
				Assert.isTrue( b.hasAttribute(attribute.name) );
				
			}
			
		}
		
	}
	
}
