package;

import Alphabet.AlphabetType;
import flixel.FlxG;
import flixel.group.FlxGroup.FlxTypedGroup;

class AlphabetList extends FlxTypedGroup<Alphabet>
{
	public var selectedIndex:Int;
	public var textList:Array<String> = [];

	var alphabetsType:Array<AlphabetType> = [];
	var alphabetsArgs:Array<AlphabetListArgs> = [];

	public var _changeSelection:Bool->Void; // function(change:Int,curSelected:Int):Void
	public var canChangeSel:Bool = true;

	public function new(_textList:Array<String>, ?_alphabetsType:Array<AlphabetType>, ?_alphabetsArgs:Array<AlphabetListArgs>)
	{
		super();
		if (_alphabetsType != null)
			alphabetsType = _alphabetsType;
		if (_alphabetsArgs != null)
			alphabetsArgs = _alphabetsArgs;
		textList = _textList;
		restartList();
	}

	override function update(elapsed:Float)
	{
		if (canChangeSel)
		{
			if (FlxG.mouse.wheel != 0)
				changeSelection(FlxG.mouse.wheel == 1 ? -1 : 1);

			if (controls.UI_UP_P)
				changeSelection(-1);
			if (controls.UI_DOWN_P)
				changeSelection(1);
		}
		super.update(elapsed);
	}

	public function restartList():Void
	{
		forEach(function(spr:Alphabet) remove(spr));

		for (i in 0...textList.length)
		{
			var text = new Alphabet(0, (70 * i) + 30, textList[i], true, false);
			text.targetY = i;
			text.type = alphabetsType;
			add(text);
		}
		changeSelection(0, true, true);
	}

	public function changeSelection(change:Int = 0, force:Bool = false, firstTime:Bool = false)
	{
		selectedIndex = !force ? (selectedIndex + change) : change;
		if (!firstTime && !alphabetsArgs.contains(NO_CHANGE_SOUND))
			FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

		if (selectedIndex < 0)
			selectedIndex = textList.length - 1;
		if (selectedIndex >= textList.length)
			selectedIndex = 0;

		if (_changeSelection != null)
			_changeSelection(true);

		var bullShit:Int = 0;

		for (item in members)
		{
			item.targetY = bullShit - selectedIndex;
			bullShit++;

			item.alpha = 0.6;

			if (item.targetY == 0)
				item.alpha = 1;
		}
	}

	private var controls(get, never):Controls;

	inline function get_controls():Controls
		return PlayerSettings.player1.controls;
}

enum AlphabetListArgs
{
	NO_CHANGE_SOUND;
}
