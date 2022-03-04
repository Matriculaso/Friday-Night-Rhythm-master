package;

import flixel.FlxSprite;
import openfl.utils.Assets as OpenFlAssets;

class HealthIcon extends FlxSprite
{
	/**
	 * Used for FreeplayState! If you use it elsewhere, prob gonna annoying
	 */
	public var sprTracker:FlxSprite;

	public var isOldIcon = false;
	public var isPlayer:Bool;
	public var char:String;

	var oldChar:String = '';

	public function new(_char:String = 'bf', _isPlayer:Bool = false)
	{
		super();
		isPlayer = _isPlayer;
		changeIcon(_char);
	}

	public function changeIcon(_newChar:String)
	{
		char = HealthIconsData.getCharIcon(_newChar);

		if (!OpenFlAssets.exists(Paths.image('icons/$char', 'preload')))
			char = 'face';

		loadGraphic(Paths.image('icons/$char', 'preload'), true, 150, 150);
		animation.add(char, HealthIconsData.charsWithWinningIcons.contains(char) ? [0, 1, 2] : [0, 1], 0, false, isPlayer);
		animation.play(char, true);
		antialiasing = getPref('antialiasing') && !CharactersData.characterWithoutAntialiasing.contains(char);
		scrollFactor.set();
	}

	public function swapOldIcon():Void
	{
		isOldIcon = !isOldIcon;

		if (isOldIcon)
		{
			oldChar = char;
			changeIcon("bf-old");
		}
		else
			changeIcon(oldChar);
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (sprTracker != null)
			setPosition(sprTracker.x + sprTracker.width + 10, sprTracker.y - 30);
	}
}
