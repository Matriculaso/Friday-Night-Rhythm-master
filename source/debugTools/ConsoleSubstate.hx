package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;

class ConsoleSubstate extends MusicBeatSubstate
{
	static var commandsEntered:Array<String> = [];

	var curSelected = 0;
	var consoleInput:Console;
	var __closeCallback:Bool->Bool->Void;

	public function new(?_closeCallback:Bool->Bool->Void)
	{
		super();
		if (_closeCallback != null)
			__closeCallback = _closeCallback;
		var bg = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		bg.alpha = 0;
		bg.scrollFactor.set();
		add(bg);
		FlxTween.tween(bg, {alpha: 0.6}, 0.4, {ease: FlxEase.quartInOut});

		consoleInput = new Console();
		add(consoleInput);

		cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (commandsEntered.length >= 1)
		{
			if (KeyBinds.checkKey('UP'))
			{
				consoleInput.text = commandsEntered[curSelected];
				consoleInput.caretIndex = consoleInput.text.length;
				curSelected++;
			}
			if (KeyBinds.checkKey('UP'))
			{
				consoleInput.text = commandsEntered[curSelected];
				consoleInput.caretIndex = consoleInput.text.length;
				curSelected--;
			}
		}
		if (KeyBinds.checkKey('ENTER'))
		{
			commandsEntered.unshift(consoleInput.text);
			var argsArray:Array<Dynamic> = consoleInput.text.split('.');
			trace(argsArray);

			switch (argsArray[0])
			{
				case 'options': // ! options.setPref.downscroll.true
					switch (argsArray[1])
					{
						case 'setPref':
							PreferencesMenu.setPref(argsArray[2], argsArray[3]);
						case 'getPref':
							trace('\u001b[96mpref ${argsArray[2]} = ${PreferencesMenu.getPref(argsArray[2])}\u001b[0m');
						case 'reset':
							PreferencesMenu.resetPrefs();
					}
				case 'PlayState': // ! PlayState.loadSong.blammed-hard
					switch (argsArray[1])
					{
						case 'loadSong':
							PlayState.loadSong(argsArray[2], 0, flixel.util.FlxColor.WHITE, false);
					}
				case 'binds': // ! binds.note.setBind.up.K
					var dir:Int = switch (argsArray[3])
					{
						default:
							0;
						case 'down':
							1;
						case 'up':
							2;
						case 'right':
							3;
					}
					switch (argsArray[1])
					{
						case 'note':
							switch (argsArray[2])
							{
								case 'setBind':
									KeyBinds.setBind(dir, argsArray[4].toUpperCase(), false);
								case 'getBind':
									trace('\u001b[96m'
										+ 'bind ${argsArray[1].toUpperCase()}_${argsArray[3].toUpperCase()} = ${FlxG.save.data.noteBinds[dir]}\u001b[0m');
							}
						case 'ui':
							switch (argsArray[2])
							{
								case 'setBind':
									KeyBinds.setBind(dir, argsArray[4].toUpperCase(), true);
								case 'getBind':
									trace('\u001b[96m' + 'bind ${argsArray[1]}_${argsArray[2]} = ${FlxG.save.data.uiBinds[dir]}\u001b[0m');
							}
					}
				default: // ! hi
					trace('unknown command! ${argsArray[0]}');
			}
			close();
		}
	}

	override public function close():Void
	{
		super.close();
		if (__closeCallback != null)
			__closeCallback(false, false);
	}
}
