package;

#if (windows && cpp)
import Discord.DiscordClient;
import sys.thread.Thread;
#end
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.transition.FlxTransitionSprite.GraphicTransTileDiamond;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.transition.TransitionData;
import flixel.graphics.FlxGraphic;
import flixel.group.FlxGroup;
import flixel.input.gamepad.FlxGamepad;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import openfl.Assets;

using StringTools;

class TitleState extends MusicBeatState
{
	static var firstTime = true;
	static var initialized:Bool = false;

	var daGuys:FlxSprite;
	var blackScreen:FlxSprite;
	var credGroup:FlxGroup;
	var credTextShit:Alphabet;
	var textGroup:FlxGroup;
	var ngSpr:FlxSprite;

	var curWacky:Array<String> = [];
	var swagShader = new shaderslmfao.ColorSwap();
	var wackyImage:FlxSprite;

	static var canLoad:Bool = true;

	override public function create():Void
	{
		if (canLoad)
			LoadingState.loadAndSwitchState(TitleState, false, true);
		canLoad = false;
		{
			FlxG.save.bind('config', 'saves');
			FlxG.game.focusLostFramerate = 30;
			#if android
			FlxG.android.preventDefaultKeys = [BACK];
			#end
			PreferencesMenu.initPrefs();
			KeyBinds.initBinds(true);
			PlayerSettings.init();
			Highscore.load();
			AllData.init();
			FlxG.sound.muteKeys = [48];
			loadTransition(transIn, transOut);
			PreferencesMenu.checkPrefValue('fpsCap');
			#if debug
			FlxG.console.registerClass(PreferencesMenu);
			FlxG.console.registerClass(PlayState);
			FlxG.console.registerClass(ChartingState);
			#end
		}
		curWacky = FlxG.random.getObject(getIntroTextShit());

		super.create();

		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		add(bg);

		logoBl = new FlxSprite(0);
		logoBl.frames = Paths.getSparrowAtlas('logoBumpin');
		logoBl.antialiasing = getPref('antialiasing');
		logoBl.animation.addByPrefix('bump', 'logo bumpin', 24, false);
		logoBl.animation.play('bump');
		logoBl.updateHitbox();
		// logoBl.screenCenter();
		// logoBl.color = FlxColor.BLACK;

		gfDance = new FlxSprite(FlxG.width * 0.4, FlxG.height * 0.07);
		gfDance.frames = Paths.getSparrowAtlas('gfDanceTitle');
		gfDance.animation.addByIndices('danceLeft', 'gfDanceTitle instance 1', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
		gfDance.animation.addByIndices('danceRight', 'gfDanceTitle instance 1', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);
		gfDance.antialiasing = getPref('antialiasing');
		add(gfDance);
		add(logoBl);

		var gradient = new FlxSprite(0, 0, Paths.image('gradientTitle'));
		gradient.alpha = gradient.alpha / 2;
		add(gradient);

		titleText = new FlxSprite(100, FlxG.height * 0.8);
		titleText.frames = Paths.getSparrowAtlas('titleEnter');
		titleText.animation.addByPrefix('idle', "Press Enter to Begin", 24);
		if (getPref('flashing-menu'))
			titleText.animation.addByPrefix('press', "ENTER PRESSED", 24);
		else
			titleText.animation.addByIndices('press', "ENTER PRESSED", [1], '', 24);

		titleText.antialiasing = getPref('antialiasing');
		titleText.animation.play('idle');
		titleText.updateHitbox();
		// titleText.screenCenter(X);
		add(titleText);

		credGroup = new FlxGroup();
		add(credGroup);
		daGuys = new FlxSprite(-235, 0).loadGraphic(Paths.image('daGuys', 'preload'));
		daGuys.visible = false;

		daGuys.y = -290;
		daGuys.setGraphicSize(Std.int(daGuys.width * 0.55));
		daGuys.antialiasing = getPref('antialiasing');
		add(daGuys);
		textGroup = new FlxGroup();

		blackScreen = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		credGroup.add(blackScreen);

		#if FREEPLAY
		switchState(FreeplayState);
		#elseif OPTIONS
		switchState(OptionsMenu);
		#elseif PLAYSTATE
		PlayState.loadSong('ringside-hard', 7, 0xFF, false);
		#elseif STORYMODE
		switchState(StoryMenuState, [false]);
		#else
		new FlxTimer().start(1, function(tmr:FlxTimer)
		{
			startIntro();
		});
		#end
	}

	var logoBl:FlxSprite;

	var gfDance:FlxSprite;
	var danceLeft:Bool = false;
	var titleText:FlxSprite;

	function startIntro()
	{
		if (!initialized)
		{
			MusicManager.playMainMusic(0);
			FlxG.sound.music.fadeIn(4, 0, 0.7);
		}

		Conductor.changeBPM(BPMList.mainMenuStateBPM);
		persistentUpdate = true;

		var logo:FlxSprite = new FlxSprite().loadGraphic(Paths.image('logo'));
		logo.screenCenter();
		logo.antialiasing = getPref('antialiasing');
		// add(logo);

		// FlxTween.tween(logoBl, {y: logoBl.y + 50}, 0.6, {ease: FlxEase.quadInOut, type: PINGPONG});
		// FlxTween.tween(logo, {y: logoBl.y + 50}, 0.6, {ease: FlxEase.quadInOut, type: PINGPONG, startDelay: 0.1});

		credTextShit = new Alphabet(0, 0, "ninjamuffin99\nPhantomArcade\nkawaisprite\nevilsk8er", false, true);
		credTextShit.type = [IGNORE_X, IGNORE_Y];

		credTextShit.screenCenter(Y);

		// credTextShit.alignment = CENTER;

		credTextShit.visible = false;

		ngSpr = new FlxSprite(0, FlxG.height * 0.52).loadGraphic(Paths.image('Nintendo'));
		ngSpr.visible = false;
		ngSpr.setGraphicSize(Std.int(ngSpr.width * 0.8));
		ngSpr.updateHitbox();
		ngSpr.screenCenter(X);
		ngSpr.antialiasing = getPref('antialiasing');
		add(ngSpr);

		FlxTween.tween(credTextShit, {y: credTextShit.y + 20}, 2.9, {ease: FlxEase.quadInOut, type: PINGPONG});

		#if FLX_MOUSE
		FlxG.mouse.useSystemCursor = true;
		#end
		if (initialized)
			skipIntro();
		else
			initialized = true;

		// credGroup.add(credTextShit);
	}

	function getIntroTextShit():Array<Array<String>>
	{
		var fullText:String = Assets.getText(Paths.txt('introText'));

		var firstArray:Array<String> = fullText.split('\n');
		var swagGoodArray:Array<Array<String>> = [];

		for (i in firstArray)
			swagGoodArray.push(i.split('--'));

		return swagGoodArray;
	}

	var transitioning:Bool = false;

	override function update(elapsed:Float)
	{
		if (checkKey('M'))
			logoBl.setPosition(FlxG.mouse.x, FlxG.mouse.y);
		if (checkKey('M'))
			trace('\nlogoBl: ${logoBl.x}, ${logoBl.y}');
		if (FlxG.sound.music != null)
			Conductor.songPosition = FlxG.sound.music.time;
		// FlxG.watch.addQuick('amp', FlxG.sound.music.amplitude);

		FlxG.camera.zoom = (1 + 0.95 * (FlxG.camera.zoom - 1));

		var pressedEnter:Bool = FlxG.keys.justPressed.ENTER;

		#if mobile
		for (touch in FlxG.touches.list)
		{
			if (touch.justPressed)
			{
				pressedEnter = true;
			}
		}
		#end

		var gamepad:FlxGamepad = FlxG.gamepads.lastActive;

		if (gamepad != null)
		{
			if (gamepad.justPressed.START)
				pressedEnter = true;

			#if switch
			if (gamepad.justPressed.B)
				pressedEnter = true;
			#end
		}

		if (pressedEnter && !transitioning && skippedIntro)
		{
			titleText.animation.play('press');

			FlxG.camera.flash(FlxColor.WHITE, 1);
			FlxG.sound.play(Paths.sound('confirmMenu'), 0.7);

			transitioning = true;
			// FlxG.sound.music.stop();

			new FlxTimer().start(2, function(tmr:FlxTimer)
			{
				if (!firstTime)
					switchState(MainMenuState);
				else
					switchState(MainMenuState);
				firstTime = false;
			});
			// FlxG.sound.play(Paths.music('titleShoot'), 0.7);
		}

		if (pressedEnter && !skippedIntro)
		{
			skipIntro();
		}

		super.update(elapsed);
	}

	function createCoolText(textArray:Array<String>)
	{
		for (i in 0...textArray.length)
		{
			var money = new Alphabet(0, 0, textArray[i], false, true);
			money.type = [IGNORE_X, IGNORE_Y];
			money.y += (i * 60) + 200;
			credGroup.add(money);
			textGroup.add(money);
		}
	}

	function addMoreText(text:String)
	{
		var coolText = new Alphabet(0, 0, text, false, true);
		coolText.type = [IGNORE_X, IGNORE_Y];
		coolText.y += (textGroup.length * 60) + 200;
		credGroup.add(coolText);
		textGroup.add(coolText);
	}

	function deleteCoolText()
	{
		while (textGroup.members.length > 0)
		{
			credGroup.remove(textGroup.members[0], true);
			textGroup.remove(textGroup.members[0], true);
		}
	}

	override function beatHit()
	{
		super.beatHit();
		logoBl.animation.play('bump', true);
		danceLeft = !danceLeft;

		if (getPref('camera-zoom'))
			FlxG.camera.zoom += 0.03;

		if (danceLeft)
			gfDance.animation.play('danceRight');
		else
			gfDance.animation.play('danceLeft');

		if (firstTime)
			switch (curBeat)
			{
				case 1:
					createCoolText(['Dizzle', 'Matriculaso', 'Gamerbross', 'Chango', 'Blaize.Mayes', 'Shustrik']);

				// credTextShit.visible = true;
				case 3:
					addMoreText('present');
					daGuys.visible = true;
				case 4:
					daGuys.visible = false;
					deleteCoolText();
				case 5:
					createCoolText(['In association', 'with']);
				case 7:
					addMoreText('Nintendo');
					ngSpr.visible = true;
				// credTextShit.text += '\nNewgrounds';
				case 8:
					deleteCoolText();
					ngSpr.visible = false;
				case 9:
					createCoolText([curWacky[0]]);
				// credTextShit.visible = true;
				case 11:
					addMoreText(curWacky[1]);
				// credTextShit.text += '\nlmao';
				case 12:
					deleteCoolText();
				// credTextShit.visible = false;
				// credTextShit.text = "Friday";
				// credTextShit.screenCenter();
				case 13:
					addMoreText('Friday');
				// credTextShit.visible = true;
				case 14:
					addMoreText('Night');
				// credTextShit.text += '\nNight';
				case 15:
					addMoreText('Rhythm'); // credTextShit.text += '\nFunkin';

				case 16:
					skipIntro();
			}
	}

	var skippedIntro:Bool = false;

	function skipIntro():Void
	{
		if (!skippedIntro)
		{
			remove(ngSpr);
			remove(daGuys);

			FlxG.camera.flash(FlxColor.WHITE, 4);
			remove(credGroup);
			skippedIntro = true;
		}
	}

	public static function loadTransition(?transIn:TransitionData, ?transOut:TransitionData):Void
	{
		var diamond:FlxGraphic = FlxGraphic.fromClass(GraphicTransTileDiamond);
		diamond.persist = true;
		diamond.destroyOnNoUse = false;
		FlxTransitionableState.defaultTransIn = new TransitionData(TILES, FlxColor.BLACK, 1, new FlxPoint(-1, 0), {asset: diamond, width: 32, height: 32},
			new FlxRect(-200, -200, FlxG.width * 1.4, FlxG.height * 1.4));
		FlxTransitionableState.defaultTransOut = new TransitionData(TILES, FlxColor.BLACK, 0.7, new FlxPoint(1, 0), {asset: diamond, width: 32, height: 32},
			new FlxRect(-200, -200, FlxG.width * 1.4, FlxG.height * 1.4));

		if (transIn != null)
		{
			transIn = FlxTransitionableState.defaultTransIn;
			transOut = FlxTransitionableState.defaultTransOut;
		}
	}
}
