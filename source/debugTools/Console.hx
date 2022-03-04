package;

import KeyBinds.checkKey;
import flixel.FlxG;
import flixel.text.FlxText.FlxTextBorderStyle;
import flixel.util.FlxColor;

class Console extends flixel.addons.ui.FlxUIInputText
{
	public function new()
	{
		super(10, 10, FlxG.width, '', 32, FlxColor.BLACK, 0x64FFFFFF);
		setFormat(Paths.font("CascadiaCode.ttf"), 42, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		borderSize = 1.25;
		scrollFactor.set();
		screenCenter();
		y = FlxG.height - 60;
		antialiasing = PreferencesMenu.getPref('antialiasing');
		hasFocus = true;
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
		if (checkKey('CONTROL', PRESSED) && checkKey('V'))
		{
			text = lime.system.Clipboard.text;
			caretIndex = text.length;
		}
	}

	public static function open(?callback:Bool->Bool->Void)
	{
		var state = FlxG.state;
		state.persistentUpdate = false;
		state.persistentDraw = true;
		state.openSubState(new ConsoleSubstate(callback));
	}
}
