package;

import Alphabet.AlphaCharacter.alphabet;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.text.FlxTypeText;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;

using StringTools;

class PreferencesMenu extends MusicBeatSubstate
{
	public static var preferences:Map<String, Dynamic> = [];

	var descriptionBG:FlxSprite;
	var prefBG:FlxSprite;
	var descriptionTxt:FlxTypeText;
	var prefTxt:FlxText;
	var checkboxes:Array<FlxSprite>;
	var menuCamera:FlxCamera;
	var sprOpt:AlphabetList;

	static final options:Array<Array<Dynamic>> = [
		['Controls', 'controls'], //
		['Downscroll', 'downscroll', Bool], //
		['Midscroll', 'midscroll', Bool], //
		['Ghost Tapping', 'ghostTapping', Bool],
		['FPS Cap', 'fpsCap', Int], //
		['HitSound', 'hitsound', Bool], //
		['Ultra Optimize', 'ultra-optimize', Bool], //
		['Note Splashes', 'note-splashes', Bool],
		['Background Opacity', 'background-opacity', Float], //
		['Language', 'language', String], //
		['Flashing Lights', 'flashing-menu', Bool], //
		['Antialiasing', 'antialiasing', Bool],
		['Camera Beats', 'camera-zoom', Bool], //
		['FPS Counter', 'fps-counter', Bool], //
		['Auto Pause', 'auto-pause', Bool], //
		['Allow Reset', 'allowReset', Bool] //
	];

	static final descriptions = [
		'Change your controls.', // controls
		'Places gray notes at bottom of the screen.', // downscroll
		'Centers gray notes.', // midscroll
		"If you press a key and there aren't notes to press, you miss.", // ghost tapping
		'Change the game framerate limit.', // fps cap
		'When you press a note, a satisfying sound plays.', // hitsound
		'Deletes the characters and the background for better performance.', // ultra optimize
		"Spawns a a fancy splash when you hit a 'Sick'.", // note splahes
		'Adds a black screen behind your notes to hide the background to see them better.', // background opacity
		'Changes your game language.', // background opacity
		'Toggle the flashing lights for photosensitive people.', // flashing lights
		'Toggle the antialiasing for better performance.', // antialiasing
		'Toggle the camera zooms on a song beat.', // camera beats
		'Toggle the visiblity of the FPS counter.', // fps counter
		"Auto pauses the game when it doesn't have focus.", // auto pause
		'Allow die on game with the R key.' // allow reset
	];

	var isPause:Bool;

	public function new(_isPause:Bool)
	{
		super();
		isPause = _isPause;

		if (isPause)
		{
			var bg = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
			bg.alpha = .6;
			bg.scrollFactor.set();
			add(bg);
		}

		sprOpt = new AlphabetList(optionsNameList);
		add(sprOpt);

		descriptionBG = new FlxSprite(0.7 * FlxG.width - 6, 0).makeGraphic(1, Std.int(FlxG.height / 2), FlxColor.BLACK);
		descriptionBG.alpha = 0.6;
		descriptionBG.y = FlxG.height - descriptionBG.height;
		add(descriptionBG);

		descriptionTxt = new FlxTypeText(0.7 * FlxG.width, descriptionBG.y + 10, Std.int(FlxG.width / 2) - 300, "", 32);
		descriptionTxt.setFormat(Paths.font("vcr.ttf"), 38, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		descriptionTxt.borderSize = 1.25;
		descriptionTxt.sounds = [FlxG.sound.load(Paths.sound('generic2'), 0.6)];
		add(descriptionTxt);

		prefBG = new FlxSprite(0.7 * FlxG.width - 6, 0).makeGraphic(1, 66, FlxColor.WHITE);
		add(prefBG);

		prefTxt = new FlxText(0.7 * FlxG.width, prefBG.y + 10, Std.int(FlxG.width / 2) - 300, "", 32);
		prefTxt.setFormat(Paths.font("vcr.ttf"), 38, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		prefTxt.borderSize = 1.25;
		add(prefTxt);

		sprOpt._changeSelection = function(lol:Bool):Void
		{
			if (lol)
			{
				descriptionTxt.resetText(Language.langString(curPref)[1]);
				descriptionTxt.start(.04, true);
			}
			if (curPref != 'controls')
				prefTxt.text = prefValueToText(getPref(curPref), curPref);
			var daColor = new FlxColor(switch (prefTxt.text)
			{
				case 'OFF':
					FlxColor.RED;
				case 'ON':
					FlxColor.LIME;
				case 'UNKNOWN':
					FlxColor.GRAY;
				default:
					FlxColor.ORANGE;
			});
			daColor.alphaFloat = .6;
			var daColor2 = FlxColor.WHITE;
			switch (curPref)
			{
				case 'controls', 'reset options':
					daColor.alphaFloat = 0;
					daColor2.alphaFloat = 0;
			}
			FlxTween.color(prefBG, CoolUtil.camLerpShit(.45), prefBG.color, daColor);
			FlxTween.color(prefTxt, CoolUtil.camLerpShit(.45), prefTxt.color, daColor2);
		}

		sprOpt.changeSelection(0, false, true);

		if (isPause)
			cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];
	}

	var optionsNameList(get, never):Array<String>;

	inline function get_optionsNameList():Array<String>
	{
		var optionsList:Array<String> = [];
		for (i in options)
			optionsList.push(Language.langString(i[1])[0]);

		return optionsList;
	}

	var curPref(get, never):String;

	inline function get_curPref():String
		return options[curSelected][1];

	var curPrefType(get, never):Dynamic;

	inline function get_curPrefType():Dynamic
		return options[curSelected][2];

	var curSelected(get, never):Int;

	inline function get_curSelected():Int
		return sprOpt.selectedIndex;

	function prefValueToText(value:Dynamic, daPref:String):String
	{
		switch (daPref)
		{
			case 'background-opacity':
				return '${Std.string(value * 100)}%';
			case 'language':
				return value.toUpperCase();
			default:
				if (Std.isOfType(value, Bool))
					return switch (value)
					{
						case true:
							'ON';
						case false:
							'OFF';
					}
				else if (Std.isOfType(value, Int) || Std.isOfType(value, Float))
					return Std.string(value);
				else
					return 'UNKNOWN';
		}
	}

	function accept():Void
	{
		switch (curPrefType)
		{
			case Bool:
				toggleOption(curPref);
			default:
				switch (curPref)
				{
					case 'language':
						if (!isPause)
						{
							if (getPref(curPref) == 'english') //
								setPref(curPref, 'spanish'); //
							else if (getPref(curPref) == 'spanish') //
								setPref(curPref, 'english'); //
							else //
								setPref(curPref, 'english'); //

							LoadingState.loadAndSwitchState(OptionsMenu);
						}
						else makeAnError();
					case 'controls':
						// FlxG.state.openSubState(new ControlsSubMenu());
				}
		}
		if (curPref != 'language')
			sprOpt._changeSelection(false);
	}

	override function update(elapsed:Float)
	{
		for (item in sprOpt)
		{
			if (FlxG.mouse.overlaps(item) && item.ID == curSelected && FlxG.mouse.justPressed)
				accept();
		}
		if (controls.ACCEPT)
			accept();

		if (controls.UI_LEFT_P || controls.UI_RIGHT_P)
		{
			var change = controls.UI_LEFT_P ? -1 : 1;
			var floatChange = controls.UI_LEFT_P ? -.01 : .01;
			if (KeyBinds.checkKey('SHIFT', PRESSED))
			{
				change = controls.UI_LEFT_P ? -10 : 10;
				floatChange = controls.UI_LEFT_P ? -.1 : .1;
			}
			switch (curPrefType)
			{
				case Int:
					setPref(curPref, getPref(curPref) + change);
				case Float:
					setPref(curPref, getPref(curPref) + floatChange);
				case Bool:
					toggleOption(curPref);
			}
			sprOpt._changeSelection(false);
		}
		if (controls.BACK)
		{
			close();
			if (!isPause)
				CoolUtil.switchState(MainMenuState);
			else
				FlxG.state.openSubState(new PauseSubState(PlayState.boyfriend.getScreenPosition().x, PlayState.boyfriend.getScreenPosition().y, true));
		}

		descriptionTxt.x = (FlxG.width - descriptionTxt.width - 6);
		prefTxt.x = (FlxG.width - descriptionTxt.width - 6);
		descriptionBG.scale.x = (FlxG.width - descriptionTxt.x + 6);
		descriptionBG.x = (FlxG.width - descriptionBG.scale.x / 2);
		prefBG.scale.x = (FlxG.width - descriptionTxt.x + 6);
		prefBG.x = (FlxG.width - descriptionBG.scale.x / 2);
		super.update(elapsed);
	}

	function toggleOption(daPref:String)
	{
		if (isPause)
		{
			switch (daPref)
			{
				case 'ultra-optimize', 'antialiasing', 'language':
					makeAnError();
				default:
					setPref(daPref, !getPref(daPref));
			}
		}
		else
			setPref(daPref, !getPref(daPref));
	}

	function makeAnError():Void
	{
		for (item in sprOpt.members)
			if (item.targetY == 0)
			{
				FlxG.sound.play(Paths.sound('errorMenu'));
				sprOpt.canChangeSel = false;
				FlxTween.color(item, .5, FlxColor.WHITE, FlxColor.RED, {
					onComplete: function(twn:FlxTween)
					{
						FlxTween.color(item, .1, FlxColor.RED, FlxColor.WHITE, {
							onComplete: function(twn:FlxTween)
							{
								sprOpt.canChangeSel = true;
							}
						});
					}
				});
			}
	}

	public static function getPref(preference:String):Dynamic
		return preferences[preference];

	public static function setPref(preference:String, value:Dynamic, ?isPrefCheck:Bool = false):Void
	{
		if (!isPrefCheck && Std.isOfType(value, String))
			switch (value.toLowerCase())
			{
				case 'false':
					value = null;
					value = false;
				case 'true':
					value = null;
					value = true;

				default:
					var boolArray:Array<Bool> = [];
					var a:String = value;
					for (i in 0...a.length)
						boolArray.push(alphabet.contains(a.charAt(i)));

					trace(boolArray);
					if (!boolArray.contains(true))
					{
						var tempValue:String = value;
						value = null;
						if (!a.contains(','))
							value = Std.parseInt(tempValue);
						else
						{
							var elpepe = tempValue.split(',').join('.');
							value = Std.parseFloat(elpepe);
						}
					}
			}

		switch (preference)
		{
			case 'background-opacity':
				value = FlxMath.roundDecimal(value, 2);
				if (value >= 1)
					value = 1;
				if (value <= 0)
					value = 0;

			case 'fpsCap':
				if (value > 270)
					value = 270;
				if (value < 60)
					value = 60;
		}
		trace('\u001b[96m' + 'setPref (${preference}) to: ${value}\u001b[0m');
		preferences[preference] = value;
		FlxG.save.data.prefs = preferences;
		FlxG.save.flush();
		checkPrefValue(preference);
	}

	public static function resetPrefs():Void
	{
		FlxG.save.data.prefs = null;
		FlxG.save.flush();
		initPrefs();
	}

	public static function preferenceCheck(preference:String, defValue:Dynamic):Void
	{
		if (preferences[preference] == null)
			setPref(preference, defValue, true);
		else
			checkPrefValue(preference);
	}

	public static function initPrefs():Void
	{
		if (FlxG.save.data.prefs == null)
			FlxG.save.data.prefs = new Map<String, Dynamic>();
		preferences = FlxG.save.data.prefs;

		{
			// gameplay
			preferenceCheck("downscroll", false);
			preferenceCheck("midscroll", false);
			preferenceCheck("ghostTapping", true);
			preferenceCheck("fpsCap", Main.getHZ());
			preferenceCheck("hitsound", false);
			preferenceCheck("ultra-optimize", false);
			// apparence
			preferenceCheck("note-splashes", true);
			preferenceCheck("background-opacity", 0.0);
			// etc
			preferenceCheck("language", 'english');
			preferenceCheck("flashing-menu", true);
			preferenceCheck("censor-naughty", true);
			preferenceCheck("antialiasing", true);
			preferenceCheck("camera-zoom", true);
			preferenceCheck("fps-counter", true);
			preferenceCheck("auto-pause", false);
			preferenceCheck("first-time", true);
			preferenceCheck("allowReset", true);
		}
	}

	public static function checkPrefValue(preference:String):Void
	{
		switch (preference)
		{
			case 'fps-counter':
				Main.fpsCounterVisible(getPref('fps-counter'));
			case 'fpsCap':
				cast(openfl.Lib.current.getChildAt(0), Main).setFPSCap(getPref('fpsCap'));
			case 'auto-pause':
				FlxG.autoPause = getPref("auto-pause");
			case 'language':
				Language.loadFromJSON();
		}
	}
}
