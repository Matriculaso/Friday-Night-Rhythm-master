package;

import flixel.util.FlxColor;

class HealthIconsData
{
	public static var healthIconsForCharacter:Map<String, String>;
	public static var healthIconsColors:Map<String, Int>;
	public static final charsWithWinningIcons = []; // example: ['agoti']

	public static function init():Void
	{
		healthIconsForCharacter = new Map<String, String>();
		healthIconsForCharacter['bf-car'] = 'bf';
		healthIconsForCharacter['gf-car'] = 'gf';
		healthIconsForCharacter['mom-car'] = 'mom';

		healthIconsForCharacter['bf-christmas'] = 'bf';
		healthIconsForCharacter['gf-christmas'] = 'gf';
		healthIconsForCharacter['parents-christmas'] = 'parents';
		healthIconsForCharacter['monster-christmas'] = 'monster';

		healthIconsForCharacter['gf-pixel'] = 'gf';
		healthIconsForCharacter['senpai-angry'] = 'senpai';

		healthIconsColors = new Map<String, Int>();
		healthIconsColors['bf'] = 0xFF31b0d1;
		healthIconsColors['bf-old'] = 0xFFe9ff48;
		healthIconsColors['gf'] = 0xFFa5004d;
		healthIconsColors['dad'] = 0xFFaf66ce;
		healthIconsColors['spooky'] = 0xFFb4b4b4;
		healthIconsColors['monster'] = 0xFFf3ff6e;
		healthIconsColors['pico'] = 0xFFb7d855;
		healthIconsColors['mom'] = 0xFFd8558e;
		healthIconsColors['parents'] = 0xFFaf66ce;
		healthIconsColors['bf-pixel'] = 0xFF7bd6f6;
		healthIconsColors['senpai'] = 0xFFffaa6f;
		healthIconsColors['spirit'] = 0xFFff3c6e;
		healthIconsColors['face'] = 0xFFa1a1a1;
		healthIconsColors['none'] = FlxColor.GRAY;

		healthIconsColors['reporter'] = 0xFFed698a;
		healthIconsColors['dizzle'] = 0xFFfed189;

		healthIconsColors['bf-dizzle-pixel'] = 0xFF30adce;
		healthIconsColors['dizzle-spirit'] = 0xFFadf45d;
	}

	public static function getCharIcon(char:String):String
	{
		if (healthIconsForCharacter.exists(char))
			return healthIconsForCharacter[char];
		else
			return char;
	}

	public static function getIconColor(char:String):Int
	{
		if (healthIconsColors.exists(char))
			return healthIconsColors[char];
		else
		{
			trace('$char DOESN\'T HAVE A ICON COLOR!!!');
			return 0xffffff;
		}
	}
}
