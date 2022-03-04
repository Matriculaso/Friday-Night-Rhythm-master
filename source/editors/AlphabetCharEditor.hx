import KeyBinds.checkKey;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxState;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.ui.FlxUIDropDownMenu;
import flixel.addons.ui.FlxUIInputText;
import flixel.addons.ui.FlxUITabMenu;
import flixel.input.keyboard.FlxKey;

using StringTools;

/*
 * This is useless
 */
class AlphabetCharEditor extends MusicBeatState
{
	public function new()
		super();

	static inline final ghostChar = 'A';

	var alphabet:Alphabet;
	var ghostAlphabet:Alphabet;
	var curCharacter:String = 'Ñ';
	var camFollow:FlxObject;
	var camHUD:FlxCamera;
	var camGame:FlxCamera;
	var choosingChar:Bool = false;

	override function create()
	{
		camGame = new FlxCamera();
		camHUD = new FlxCamera();

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camHUD);
		camHUD.bgColor.alpha = 0;

		FlxCamera.defaultCameras = [camGame];

		if (FlxG.sound.music != null)
			FlxG.sound.music.stop();

		var gridBG = FlxGridOverlay.create(50, 50, 6000, 6000);
		gridBG.y -= 500;
		gridBG.x -= 500;
		gridBG.scrollFactor.set(.5, .5);
		gridBG.cameras = [camGame];
		gridBG.screenCenter();
		add(gridBG);

		camFollow = new FlxObject(0, 0, 2, 2);
		camFollow.screenCenter();
		add(camFollow);
		FlxG.camera.follow(camFollow);

		reloadAlphabet(true);

		inputChar = new Console();
		inputChar.maxLength = 2;
		add(inputChar);
		inputChar.hasFocus = false;
		inputChar.active = false;
		inputChar.visible = false;
		super.create();
	}

	var inputChar:FlxUIInputText;

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (checkKey('ENTER'))
		{
			if (choosingChar)
			{
				curCharacter = inputChar.text;
				reloadAlphabet(false);
			}
			choosingChar = !choosingChar;
			inputChar.hasFocus = choosingChar;
			inputChar.active = choosingChar;
			inputChar.visible = choosingChar;
		}

		if (!choosingChar)
		{
			if (FlxG.mouse.wheel != 0)
				FlxG.camera.zoom += (FlxG.mouse.wheel / 10);

			if (FlxG.keys.pressed.I)
				camFollow.velocity.y = -180;
			else if (FlxG.keys.pressed.K)
				camFollow.velocity.y = 180;
			else
				camFollow.velocity.y = 0;

			if (FlxG.keys.pressed.J)
				camFollow.velocity.x = -180;
			else if (FlxG.keys.pressed.L)
				camFollow.velocity.x = 180;
			else
				camFollow.velocity.x = 0;

			var multiplier = 1;
			if (FlxG.keys.pressed.SHIFT)
				multiplier = 10;
			var checkArray = [checkKey('UP'), checkKey('DOWN'), checkKey('LEFT'), checkKey('RIGHT')];
			alphabet.forEach(function(_char:Dynamic)
			{
				if (Std.isOfType(_char, Alphabet.AlphaCharacter))
				{
					var curChar:Alphabet.AlphaCharacter = _char;
					if (checkArray[0])
						curChar.daOffset.y += 1 * multiplier;
					if (checkArray[1])
						curChar.daOffset.y -= 1 * multiplier;
					if (checkArray[2])
						curChar.daOffset.x += 1 * multiplier;
					if (checkArray[3])
						curChar.daOffset.x -= 1 * multiplier;

					if (checkKey('Y'))
						trace('\ncase "${curChar.getAnimPrefix(curChar.letter)}": daOffset.set(${curChar.daOffset.x}, ${curChar.daOffset.y});');

					if (checkKey('R'))
						curChar.daOffset.set(0, 0);
				}
			});
		}

		if (checkKey('ESCAPE'))
			CoolUtil.switchState(MainMenuState);
	}

	function reloadAlphabet(firstTime:Bool):Void
	{
		if (firstTime)
		{
			ghostAlphabet = new Alphabet(0, 0, ghostChar, false, true);
			ghostAlphabet.type = [IGNORE_X, IGNORE_Y];
			ghostAlphabet.screenCenter();
			ghostAlphabet.alpha = 0.6;
			ghostAlphabet.color = 0xFF666688;
			add(ghostAlphabet);
		}
		if (alphabet != null)
			remove(alphabet);
		alphabet = new Alphabet(ghostAlphabet.x, ghostAlphabet.y, curCharacter, false, true);
		alphabet.type = [IGNORE_X, IGNORE_Y];
		alphabet.alpha = .85;
		add(alphabet);
	}
}
