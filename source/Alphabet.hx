package;

import flixel.FlxG;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;

using StringTools;

/**
 * Loosley based on FlxTypeText lolol
 */
class Alphabet extends flixel.group.FlxSpriteGroup
{
	public var delay:Float = 0.05;
	public var paused:Bool = false;

	// for menu shit
	public var targetY:Float = 0;
	public var type:Array<AlphabetType> = [];

	public var text:String = "";

	// custom shit
	// amp, backslash, question mark, apostrophy, comma, angry faic, period
	var lastSprite:AlphaCharacter;
	var xPosResetted:Bool = false;
	var lastWasSpace:Bool = false;

	var splitWords:Array<String> = [];

	var isBold:Bool = false;
	var isFreeplay:Bool = false;

	public function new(x:Float, y:Float, _text:String, freeplay:Bool, bold:Bool)
	{
		super(x, y);

		isFreeplay = freeplay;

		text = _text;
		if (isFreeplay)
		{
			text.replace('-', ' ');
			text = text.replace('-', ' ');
		}
		isBold = bold;

		addText();
	}

	public function addText()
	{
		doSplitWords();

		var xPos:Float = 0;
		for (character in splitWords)
		{
			if (character == " ")
				lastWasSpace = true;

			if (!character.contains('\n') && !character.contains(' ') && !AlphaCharacter.numbers.contains(character))
			{
				if (lastSprite != null)
					xPos = lastSprite.x + lastSprite.width;
				if (lastWasSpace)
				{
					xPos += 40;
					lastWasSpace = false;
				}
				var letter = new AlphaCharacter(xPos, 0, isBold);
				letter.create(character);
				add(letter);

				lastSprite = letter;
			}
		}
	}

	public function rewrite(newText:String):Void
	{
	}

	function doSplitWords():Void
	{
		splitWords = text.split("");
	}

	override function update(elapsed:Float)
	{
		var scaledY = FlxMath.remapToRange(targetY, 0, 1, 0, 1.3);

		if (!type.contains(IGNORE_Y))
			y = CoolUtil.coolLerp(y, (scaledY * 120) + (FlxG.height * 0.48), 0.16);
		if (!type.contains(IGNORE_X))
			x = CoolUtil.coolLerp(x, (targetY * 20) + 90, 0.16);
		else
			screenCenter(X);

		super.update(elapsed);
	}
}

enum AlphabetType
{
	IGNORE_Y;
	IGNORE_X;
}

class AlphaCharacter extends flixel.FlxSprite
{
	public static inline var alphabet:String = "abcdefghijklmnopqrstuvwxyz";

	public static inline var numbers:String = "1234567890";

	public static inline var symbols:String = "-:;<=>@[]^_.,'!?";

	public var daOffset:FlxPoint;
	public var row:Int = 0;
	public var letter:String = '';

	public var isBold:Bool = false;

	public function new(x:Float, y:Float, _isBold:Bool)
	{
		super(x, y);
		isBold = _isBold;
		frames = Paths.getSparrowAtlas('fonts/${isBold ? 'bold' : 'default'}');
		antialiasing = getPref('antialiasing');
		daOffset = new FlxPoint(0, 0);
	}

	public function create(_letter:String)
	{
		letter = _letter;
		animation.addByPrefix(letter, getAnimPrefix(letter), 24);
		animation.play(letter);
		updateHitbox();

		if (!isBold)
		{
			y = (110 - height);
			y += row * 60;
		}

		if (isBold)
			switch (getAnimPrefix(letter))
			{
				case "A":
					daOffset.set(0, 0);
				case "B":
					daOffset.set(-4, 1);
				case "C":
					daOffset.set(0, -2);
				case "D":
					daOffset.set(0, 0);
				case "E":
					daOffset.set(-3, -1);
				case "F":
					daOffset.set(-5, 0);
				case "G":
					daOffset.set(0, 0);
				case "H":
					daOffset.set(-2, -1);
				case "I":
					daOffset.set(-2, -2);
				case "J":
					daOffset.set(0, 0);
				case "K":
					daOffset.set(-3, 1);
				case "L":
					daOffset.set(-2, 0);
				case "M":
					daOffset.set(-1, -5);
				case "N":
					daOffset.set(0, -1);
				case "O":
					daOffset.set(-2, 0);
				case "P":
					daOffset.set(-2, 1);
				case "Q":
					daOffset.set(-1, -1);
				case "R":
					daOffset.set(-3, -1);
				case "S":
					daOffset.set(-2, -1);
				case "T":
					daOffset.set(-1, -2);
				case "U":
					daOffset.set(-2, -6);
				case "V":
					daOffset.set(-1, -1);
				case "W":
					daOffset.set(-2, -4);
				case "X":
					daOffset.set(0, 0);
				case "Y":
					daOffset.set(-2, 1);
				case "Z":
					daOffset.set(-1, -2);
				//
				//
				//
				//
				//
				case "-dash-":
					daOffset.set(-2, -24);
				case '_':
					daOffset.set(0, -43);
				case "&":
					daOffset.set(-4, -5);
				case "%":
					daOffset.set(0, -3);
				case "(":
					daOffset.set(-10, 0);
				case ")":
					daOffset.set(10, 0);
				case "+":
					daOffset.set(-1, -15);
				case "-period-":
					daOffset.set(0, -41);
				case "-question mark-":
					daOffset.set(-3, 8);
				case "-down arrow-":
					daOffset.set(-3, -13);
				case "-left arrow-":
					daOffset.set(-2, -16);
			}
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
		offset.set(daOffset.x, daOffset.y);
	}

	public function getAnimPrefix(letter:String):String
		switch (letter)
		{
			case "'":
				return "-apostraphie-";
			case "\\":
				return "-back slash-";
			case ",":
				return "-comma-";
			case "-":
				return "-dash-";
			case '↓':
				return '-down arrow-';
			case "“", '"':
				return "-start quote-";
			case '”':
				return "-end quote-";
			case "!":
				return "-exclamation point-";
			case "/":
				return "-forward slash-";
			case '←':
				return '-left arrow-';
			case "*":
				return "-multiply x-";
			case ".":
				return "-period-";
			case "?":
				return "-question mark-";
			case '→':
				return '-right arrow-';
			case '↑':
				return '-up arrow-';
			case 'ñ', 'Ñ':
				return '-spanish n-';
			default:
				return isBold ? letter.toUpperCase() : letter;
		}
}
