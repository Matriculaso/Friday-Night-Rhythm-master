package;

import flixel.FlxG;
import haxe.Json;
import lime.utils.Assets;

using StringTools;

class Language
{
	public static var curLang:Dynamic;

	public static function loadFromJSON():Void
	{
		var langPath = Paths.lang(getPref('language'));
		trace(langPath);
		var value = parseJSONshit(Assets.getText(langPath).trim());
		curLang = value;
	}

	public static function parseJSONshit(rawJson:String):Dynamic
	{
		var swagShit = cast Json.parse(rawJson);
		return swagShit;
	}

	public static function langString(key:String):Dynamic
	{
		if (Reflect.getProperty(curLang, key) != null)
			return Reflect.getProperty(curLang, key);
		else
			return 'LANG ERROR!';
	}
}
