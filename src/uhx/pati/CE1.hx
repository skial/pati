package uhx.pati;

#if !(eval || macro)
@:autoBuild(uhx.pati.macro.CustomElement.build())
#end
/**
Implements v1 of Web Components, replacing v0, obviously.
@see https://developer.mozilla.org/en-US/docs/Web/Web_Components
**/
class CE1 #if !(eval || macro) extends js.html.Element #end {}