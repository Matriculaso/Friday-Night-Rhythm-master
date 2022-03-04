package;

import flixel.FlxG;
import flixel.input.keyboard.FlxKey;

class KeyBinds
{
	public static function setBind(dir:Int, key:String, isUI:Bool):Void
	{
		trace('binds lol >>aasda>');
		if (isUI)
			FlxG.save.data.uiBinds[dir] = key;
		else
			FlxG.save.data.noteBinds[dir] = key;
		FlxG.save.flush();
		PlayerSettings.player1.controls.refreshBinds();
	}

	static var defaultKeys = [FlxKey.A, FlxKey.S, FlxKey.W, FlxKey.D, FlxKey.SPACE];

	public static function initBinds(firstTime:Bool = false):Void
	{
		if (FlxG.save.data.noteBinds == null)
			FlxG.save.data.noteBinds = defaultKeys;
		if (FlxG.save.data.uiBinds == null)
			FlxG.save.data.uiBinds = defaultKeys;

		for (i in 0...defaultKeys.length)
		{
			if (FlxG.save.data.noteBinds[i] == null)
				FlxG.save.data.noteBinds[i] = defaultKeys[i];

			if (FlxG.save.data.uiBinds[i] == null)
				FlxG.save.data.uiBinds[i] = defaultKeys[i];
		}

		FlxG.save.flush();
		if (!firstTime)
			PlayerSettings.player1.controls.setKeyboardScheme();

		trace('noteBinds: ${FlxG.save.data.noteBinds}');
		trace('uiBinds: ${FlxG.save.data.uiBinds}');
	}

	public static function checkKey(key:String, ?inputType:flixel.input.FlxInput.FlxInputState = JUST_PRESSED):Bool
		return FlxG.keys.checkStatus(FlxKey.fromString(key.toUpperCase()), inputType);

	public static function keyCodeToString(keyCode:Int):String
	{
		return switch (keyCode)
		{
			default: String.fromCharCode(keyCode);
			case 37: 'LEFT';
			case 40: 'DOWN';
			case 39: 'RIGHT';
			case 38: 'UP';
			case 190: '.';
			case 222: "'";
			case 112: 'F1';
			case 113: 'F2';
			case 114: 'F3';
			case 115: 'F4';
			case 116: 'F5';
			case 117: 'F6';
			case 118: 'F7';
			case 119: 'F8';
			case 120: 'F9';
			case 121: 'F10';
			case 122: 'F11';
			case 123: 'F12';
			case 188: ',';
			case 189: '-';
			case 18: 'ALT GR';
			case 17: 'CTRL';
			case 187: '+';
			case 192: '`';
			case 186: ';';
			case 219: '[';
			case 221: ']';
			case 220: '\\';
			case 45: 'INS';
			case 46: 'DEL';
			case 36: 'HOME';
			case 35: 'END';
			case 33: 'PG UP';
			case 34: 'PG DOWN';
			case 191: '/';
			case 32: 'SPACE';
		}
	}
}
