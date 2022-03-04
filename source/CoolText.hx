import flixel.text.FlxText;
import flixel.util.FlxColor;

class CoolText extends FlxText
{
	public static function coolTextFormat(daText:FlxText, ?align:FlxTextAlign = CENTER):FlxText
	{
		daText.setFormat(getFont(false), daText._defaultFormat.size, FlxColor.WHITE, align, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		daText.borderSize = 1.25;
		return daText;
	}

	public static function changeToPixel(daText:FlxText, pixel:Bool):FlxText
	{
		daText.font = getFont(pixel);
		return daText;
	}

	inline static function getFont(pixel:Bool):String
		return pixel ? "Pixel Arial 11 Bold" : Paths.font("vcr.ttf");
}
