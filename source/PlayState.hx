package;

import PlayStateUtils.*;
import Song.SwagSong;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.FlxSubState;
import flixel.addons.display.FlxPieDial;
import flixel.addons.effects.FlxTrail;
import flixel.addons.transition.FlxTransitionableState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.ui.FlxBar;
import flixel.util.FlxColor;
import flixel.util.FlxSort;
import flixel.util.FlxTimer;
import shaderslmfao.BuildingShaders;

using StringTools;

#if (windows && cpp)
import Discord.DiscordClient;
#end

class PlayState extends MusicBeatState
{
	// -------------------------
	// ---- CUR STATE THINGS----
	// -------------------------
	public static var instance:PlayState;
	public static var SONG:SwagSong;
	public static var curDifficulty:Int = 1;
	public static var curWeek:Int = 0;
	public static var isStoryMode:Bool = false;
	public static var weekColor:FlxColor;
	public static var curStage:String = '';
	public static var stateToBack:Class<FlxState> = MainMenuState;
	public static var seenCutscene:Bool = false;
	public static var storyPlaylist:Array<String> = [];

	var goForP:FlxSprite;
	var inCutscene:Bool = false;
	private var generatedMusic:Bool = false;
	private var startingSong:Bool = false;
	private var paused:Bool = false;
	var startedCountdown:Bool = false;
	var canPause:Bool = true;
	var startedSong:Bool = false;

	// -------------------
	// ---- NOTE SHIT ----
	// -------------------
	public static var notesColor = ['purple', 'blue', 'green', 'red'];
	public static var notesDir = ['LEFT', 'DOWN', 'UP', 'RIGHT'];

	// ---------------
	// ---- STATS ----
	// ---------------
	public static var deathCounter:Int;
	public static var campaignScore:Int = 0;
	public static var campaignMisses:Int = 0;
	public static var practiceMode:Bool = false;
	public static var accuracy:Float;
	public static var misses = 0;
	public static var sicks = 0;
	public static var goods = 0;
	public static var bads = 0;
	public static var shits = 0;

	private var health:Float = 1;
	private var combo:Int = 0;
	private var songScore:Int = 0;

	public static function resetPlayState(fromDead:Bool):Void
	{
		if (!fromDead)
		{
			campaignScore = 0;
			campaignMisses = 0;
			deathCounter = 0;
			practiceMode = false;
			seenCutscene = false;
		}
		accuracy = 0 / 0;
		misses = 0;
		sicks = 0;
		goods = 0;
		bads = 0;
		shits = 0;
	}

	// -----------------------
	// ---- ACCURACY VARS ----
	// -----------------------
	var notesThanShouldBeHitted:Int;
	var totalNotesHitted:Float;

	// --------------------
	// ---- CHARACTERS ----
	// --------------------
	public static var opponentMode:Bool = false;
	public static var dad:Character;
	public static var gf:Character;
	public static var boyfriend:Character;
	public static var opponentChar(get, never):Character;
	public static var playableChar(get, never):Character;

	public static inline function get_opponentChar():Character
		return !opponentMode ? dad : boyfriend;

	public static inline function get_playableChar():Character
		return !opponentMode ? boyfriend : dad;

	// -----------------
	// ---- CAMERAS ----
	// -----------------
	var cameraRightSide = false;
	private var camZooming:Bool = true;
	private var camGame:FlxCamera;
	private var camBACKGROUND_OPACITY:FlxCamera;
	private var camHUD:FlxCamera;
	private var camNOTES:FlxCamera;
	private var camOTHER:FlxCamera;
	#if mobileC
	private var camCONTROLS:FlxCamera;
	#end
	private var camPAUSE:FlxCamera;
	private var camFollow:FlxObject;

	private static var prevCamFollow:FlxObject;

	// ---------------
	// ---- NOTES ----
	// ---------------
	private var notes:FlxTypedGroup<Note>;
	private var unspawnNotes:Array<Note> = [];

	public var strumLine:FlxSprite;
	public var strumLineNotes:FlxTypedGroup<BabyArrow>;
	public var playerStrums:FlxTypedGroup<BabyArrow>;
	public var opponentStrums:FlxTypedGroup<BabyArrow>;
	public var grpNoteSplashes:FlxTypedGroup<NoteSplash>;
	public var defaultCamZoom:Float = 1.05;

	// --------------
	// ---- SKIP ----
	// --------------
	var skippedIntro:Bool = false;
	var skipSpr:FlxSprite;
	var firstNoteTime:Float = 0.0;
	var vocals:FlxSound;

	// ------------
	// ---- UI ----
	// ------------
	var scoreTxt:FlxText;
	var songNameTxt:FlxText;
	var debugTxt:FlxText;
	private var iconP1:HealthIcon;
	private var iconP2:HealthIcon;
	var songTimer:FlxPieDial; // ? unused
	private var healthBarBG:FlxSprite;
	private var healthBar:FlxBar;
	var startTimer:FlxTimer;

	// --------------
	// ---- MISC ----
	// --------------
	public static inline final daPixelZoom:Float = 6; // how big to stretch the pixel art assets

	var dialogue:Array<String> = ['blah blah blah', 'coolswag'];
	private var gfSpeed:Int = 1;
	var previousFrameTime:Int = 0;
	var songTime:Float = 0;

	// ! --------------------
	// ! ---- STAGE VARS ----
	// ! --------------------
	// ? WEEK 2
	var lightningStrikeBeat:Int = 0;
	var lightningOffset:Int = 8;

	// ? WEEK 3
	var startedMoving:Bool = false;
	var trainCars:Int = 8;
	var trainMoving:Bool = false;
	var trainFinishing:Bool = false;
	var trainCooldown:Int = 0;
	var trainFrameTiming:Float = 0;
	var trainSound:FlxSound;

	// ? WEEK 4
	var fastCarCanDrive:Bool = true;

	#if (windows && cpp)
	// Discord RPC variables
	var curDifficultyText:String = "";
	var iconRPC:String = "";
	var songLength:Float = 0;
	var detailsText:String = "";
	var detailsPausedText:String = "";
	#end

	#if mobileC
	var mcontrols:MobileControls;
	var pauseButton:FlxVirtualPad;
	#end

	override public function create()
	{
		resetPlayState(true);
		instance = this;
		curStage = '';
		if (FlxG.sound.music != null)
			FlxG.sound.music.stop();

		// var gameCam:FlxCamera = FlxG.camera;
		camGame = new FlxCamera();
		camBACKGROUND_OPACITY = new FlxCamera();
		camBACKGROUND_OPACITY.bgColor.alpha = 0;
		camHUD = new FlxCamera();
		camHUD.bgColor.alpha = 0;
		camNOTES = new FlxCamera();
		camNOTES.bgColor.alpha = 0;
		camOTHER = new FlxCamera();
		camOTHER.bgColor.alpha = 0;
		#if mobileC
		camCONTROLS = new FlxCamera();
		camCONTROLS.bgColor.alpha = 0;
		#end
		camPAUSE = new FlxCamera();
		camPAUSE.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camBACKGROUND_OPACITY);
		FlxG.cameras.add(camHUD);
		FlxG.cameras.add(camNOTES);
		FlxG.cameras.add(camOTHER);
		#if mobileC
		FlxG.cameras.add(camCONTROLS);
		#end
		FlxG.cameras.add(camPAUSE);
		FlxCamera.defaultCameras = [camGame];

		if (opponentMode)
			camGame.flashSprite.scaleX = -1;
		blackscreenMidScroll = new FlxSprite(500, 0).makeGraphic(500, 1000, FlxColor.BLACK);

		blackscreenMidScroll.cameras = [camBACKGROUND_OPACITY];
		blackscreenMidScroll.alpha = getPref("background-opacity");
		blackscreenMidScroll.scrollFactor.set();
		blackscreenMidScroll.screenCenter();
		add(blackscreenMidScroll);
		blackscreen1 = new FlxSprite(25, 0).makeGraphic(500, 1000, FlxColor.BLACK);
		blackscreen1.cameras = [camBACKGROUND_OPACITY];
		blackscreen1.alpha = getPref("background-opacity");
		blackscreen1.scrollFactor.set();
		blackscreen1.screenCenter(Y);
		add(blackscreen1);
		blackscreen2 = new FlxSprite(660, 0).makeGraphic(500, 1000, FlxColor.BLACK);
		blackscreen2.cameras = [camBACKGROUND_OPACITY];
		blackscreen2.alpha = getPref("background-opacity");
		blackscreen2.scrollFactor.set();
		blackscreen2.screenCenter(Y);
		add(blackscreen2);

		blackscreenMidScroll.visible = getPref('midscroll');
		blackscreenMidScroll.alpha = getPref("background-opacity");
		blackscreen1.alpha = getPref("background-opacity");
		blackscreen1.visible = !getPref('midscroll');
		blackscreen2.alpha = getPref("background-opacity");
		blackscreen2.visible = !getPref('midscroll');

		persistentUpdate = true;
		persistentDraw = true;

		if (SONG == null)
			SONG = Song.loadFromJson('tutorial');

		grpNoteSplashes = new FlxTypedGroup<NoteSplash>();
		var noteSplash = new NoteSplash(100, 100, 0);
		noteSplash.alpha = 0;
		grpNoteSplashes.add(noteSplash);
		new FlxTimer().start(1.5, function(tmr:FlxTimer)
		{
			noteSplash.alpha = .6;
		});

		goForP = new FlxSprite(-415, -50).loadGraphic(Paths.image('goForP', 'shared'));
		goForP.visible = false;
		goForP.antialiasing = true;
		goForP.setGraphicSize(Std.int(goForP.width * 0.4));
		goForP.cameras = [camOTHER];
		add(goForP);

		// before this code exists, a random splash spawned in the air
		Conductor.mapBPMChanges(SONG);
		Conductor.changeBPM(SONG.bpm);

		switch (SONG.song.toLowerCase())
		{
			case 'tutorial':
				dialogue = ["Hey you're pretty cute.", 'Use the arrow keys to keep up \nwith me singing.'];
			case 'bopeebo':
				dialogue = [
					'HEY!',
					"You think you can just sing\nwith my daughter like that?",
					"If you want to date her...",
					"You're going to have to go \nthrough ME first!"
				];
			case 'fresh':
				dialogue = ["Not too shabby boy.", ""];
			case 'dad-battle':
				dialogue = [
					"gah you think you're hot stuff?",
					"If you can beat me here...",
					"Only then I will even CONSIDER letting you\ndate my daughter!"
				];
			case 'senpai':
				dialogue = CoolUtil.coolTextFile(Paths.txt('senpai/senpaiDialogue'));
			case 'roses':
				dialogue = CoolUtil.coolTextFile(Paths.txt('roses/rosesDialogue'));
			case 'thorns':
				dialogue = CoolUtil.coolTextFile(Paths.txt('thorns/thornsDialogue'));
		}

		#if (windows && cpp)
		// Making difficulty text for Discord Rich Presence.
		switch (curDifficulty)
		{
			case 0:
				curDifficultyText = "Easy";
			case 1:
				curDifficultyText = "Normal";
			case 2:
				curDifficultyText = "Hard";
		}

		iconRPC = SONG.player2;

		// To avoid having duplicate images in Discord assets
		switch (iconRPC)
		{
			case 'senpai-angry':
				iconRPC = 'senpai';
			case 'monster-christmas':
				iconRPC = 'monster';
			case 'mom-car':
				iconRPC = 'mom';
		}

		// String that contains the mode defined here so it isn't necessary to call changePresence for each mode
		if (isStoryMode)
			detailsText = "Story Mode: Week " + curWeek;
		else
			detailsText = "Freeplay";

		// String for when the game is paused
		detailsPausedText = "Paused - " + detailsText;

		// Updating Discord Rich Presence.
		DiscordClient.changePresence(detailsText, SONG.song + " (" + curDifficultyText + ")", iconRPC);
		#end

		if (!getPref('ultra-optimize'))
			loadStage();

		if (isAloneFunkin)
		{
			gfVersion = 'speaker';
			dadVersion = 'none';
			bfVersion = 'bf';
		}

		gf = new Character(400, 130, gfVersion, gfArgs, false, false);
		if (curStage != 'gamer-go')
			gf.scrollFactor.set(0.95, 0.95);

		dad = new Character(100, 100, dadVersion, dadArgs, false, opponentMode);
		boyfriend = new Character(770, 450, bfVersion, bfArgs, true, !opponentMode);

		var camPos = new FlxPoint(dad.getGraphicMidpoint().x, dad.getGraphicMidpoint().y);

		if (!getPref('ultra-optimize'))
		{
			switch (SONG.player2)
			{
				case 'gf':
					dad.setPosition(gf.x, gf.y);
					gf.visible = false;
					if (isStoryMode)
					{
						camPos.x += 600;
						tweenCamIn();
					}

				case "spooky":
					dad.y += 200;
				case "monster":
					dad.y += 100;
				case 'monster-christmas':
					dad.y += 130;
				case 'dad':
					camPos.x += 400;
				case 'pico':
					camPos.x += 600;
					dad.y += 300;
				case 'parents-christmas':
					dad.x -= 500;
				case 'senpai':
					dad.x += 150;
					dad.y += 360;
					camPos.set(dad.getGraphicMidpoint().x + 300, dad.getGraphicMidpoint().y);
				case 'senpai-angry':
					dad.x += 150;
					dad.y += 360;
					camPos.set(dad.getGraphicMidpoint().x + 300, dad.getGraphicMidpoint().y);
				case 'spirit':
					dad.x -= 150;
					dad.y += 100;
					camPos.set(dad.getGraphicMidpoint().x + 300, dad.getGraphicMidpoint().y);
			}

			// REPOSITIONING PER STAGE
			switch (curStage)
			{
				case 'limo':
					boyfriend.y -= 220;
					boyfriend.x += 260;

				case 'mall':
					boyfriend.x += 200;

				case 'mallEvil':
					boyfriend.x += 320;
					dad.y -= 80;
				case 'school':
					boyfriend.x += 200;
					boyfriend.y += 220;
					gf.x += 180;
					gf.y += 300;
				case 'schoolEvil':
					var evilTrail = new FlxTrail(dad, null, 4, 24, 0.3, 0.069);
					add(evilTrail);

					boyfriend.x += 200;
					boyfriend.y += 220;
					gf.x += 180;
					gf.y += 300;
			}

			add(gf);
			afterAddGF();
			add(dad);
			afterAddDAD();
			add(boyfriend);
			afterAddALL();
		}

		var doof:DialogueBox = new DialogueBox(false, dialogue);
		// doof.x += 70;
		// doof.y = FlxG.height * 0.5;
		doof.scrollFactor.set();
		doof.finishThing = startCountdown;

		Conductor.songPosition = -5000;

		strumLine = new FlxSprite(0, 50).makeGraphic(FlxG.width, 10);
		strumLine.scrollFactor.set();

		strumLineNotes = new FlxTypedGroup<BabyArrow>();
		playerStrums = new FlxTypedGroup<BabyArrow>();
		opponentStrums = new FlxTypedGroup<BabyArrow>();
		add(strumLineNotes);
		add(grpNoteSplashes);

		generateSong();

		camFollow = new FlxObject(0, 0, 1, 1);

		cameraMovement();
		// camFollow.setPosition(camPos.x, camPos.y);

		if (prevCamFollow != null)
		{
			camFollow = prevCamFollow;
			prevCamFollow = null;
		}

		add(camFollow);

		FlxG.camera.follow(camFollow, LOCKON, 0.04);
		// FlxG.camera.setScrollBounds(0, FlxG.width, 0, FlxG.height);
		FlxG.camera.zoom = defaultCamZoom;
		FlxG.camera.focusOn(camFollow.getPosition());

		FlxG.worldBounds.set(0, 0, FlxG.width, FlxG.height);

		FlxG.fixedTimestep = false;

		#if mobileC
		pauseButton = new FlxVirtualPad(NONE, C);
		pauseButton.cameras = [camCONTROLS];
		pauseButton.alpha = 0.75;
		mcontrols = new MobileControls();
		mcontrols.cameras = [camCONTROLS];

		mcontrols.active = false;
		pauseButton.active = false;

		mcontrols.visible = false;
		pauseButton.visible = false;

		add(mcontrols);
		add(pauseButton);
		#end

		healthBarBG = new FlxSprite(0, FlxG.height * 0.9, Paths.image('healthBar'));
		healthBarBG.screenCenter(X);
		healthBarBG.scrollFactor.set();
		add(healthBarBG);

		healthBar = new FlxBar(healthBarBG.x + 4, healthBarBG.y + 4, RIGHT_TO_LEFT, Std.int(healthBarBG.width - 8), Std.int(healthBarBG.height - 8), this,
			'health', 0, 2);
		healthBar.scrollFactor.set();
		add(healthBar);

		scoreTxt = new FlxText(0, healthBarBG.y + 36, FlxG.width, "", 20);
		scoreTxt.setFormat(curStage.startsWith('school') ? "Pixel Arial 11 Bold" : Paths.font("vcr.ttf"), 20, FlxColor.WHITE, CENTER,
			FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		scoreTxt.scrollFactor.set();
		scoreTxt.borderSize = 3;
		scoreTxt.borderQuality = 3;

		songNameTxt = new FlxText(4, FlxG.width, '${prettySong} - ${CoolUtil.getDiffName(curDifficulty, isAloneFunkin)}', 20);
		songNameTxt.setFormat(curStage.startsWith('school') ? "Pixel Arial 11 Bold" : Paths.font("vcr.ttf"), 20, FlxColor.WHITE, CENTER,
			FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		songNameTxt.scrollFactor.set();
		songNameTxt.borderSize = 1.25;
		songNameTxt.y = FlxG.height * 0.9 + 45;

		var iconP1_Char = !getPref('ultra-optimize') ? playableChar.curCharacter : (!opponentMode ? SONG.player1 : SONG.player1);
		var iconP2_Char = !getPref('ultra-optimize') ? opponentChar.curCharacter : (!opponentMode ? SONG.player2 : SONG.player1);
		iconP1 = new HealthIcon(iconP1_Char, true);
		iconP1.y = healthBar.y - (iconP1.height / 2);
		add(iconP1);

		iconP2 = new HealthIcon(iconP2_Char, false);
		iconP2.y = healthBar.y - (iconP2.height / 2);
		add(iconP2);

		add(scoreTxt);
		add(songNameTxt);

		healthBar.createFilledBar(HealthIconsData.getIconColor(iconP2.char), HealthIconsData.getIconColor(iconP1.char));

		grpNoteSplashes.cameras = [camNOTES];
		strumLineNotes.cameras = [camNOTES];
		notes.cameras = [camNOTES];
		healthBar.cameras = [camHUD];
		healthBarBG.cameras = [camHUD];
		iconP1.cameras = [camHUD];
		iconP2.cameras = [camHUD];
		scoreTxt.cameras = [camHUD];
		songNameTxt.cameras = [camHUD];
		doof.cameras = [camHUD];

		checkSettingsInGame(true, false);
		#if debug
		debugTxt = new FlxText(0, 100, FlxG.width, "DEBUG TOOLS:
		Q/E: ZOOM IN/OUT
		U/I: ADD/REMOVE HEALTH
		B: TRACE curBeat
		N: TRACE curStep
		MOUSE WHEEL CLICK: HIDE/SHOW HUD AND NOTES
		H: HIDE/SHOW THIS MESSAGE
		", 20);
		debugTxt.setFormat(Paths.font("vcr.ttf"), 20, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		debugTxt.scrollFactor.set();
		debugTxt.borderSize = 1.25;
		debugTxt.cameras = [camHUD];
		add(debugTxt);
		#end
		startingSong = true;

		if (isStoryMode && !seenCutscene)
		{
			switch (curSong)
			{
				case "winter-horrorland":
					var blackScreen:FlxSprite = new FlxSprite(0, 0).makeGraphic(Std.int(FlxG.width * 2), Std.int(FlxG.height * 2), FlxColor.BLACK);
					add(blackScreen);
					blackScreen.scrollFactor.set();
					camHUD.visible = false;

					new FlxTimer().start(0.1, function(tmr:FlxTimer)
					{
						remove(blackScreen);
						FlxG.sound.play(Paths.sound('Lights_Turn_On'));
						camFollow.y = -2050;
						camFollow.x += 200;
						FlxG.camera.focusOn(camFollow.getPosition());
						FlxG.camera.zoom = 1.5;

						new FlxTimer().start(0.8, function(tmr:FlxTimer)
						{
							camHUD.visible = true;
							remove(blackScreen);
							FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom}, 2.5, {
								ease: FlxEase.quadInOut,
								onComplete: function(twn:FlxTween)
								{
									startCountdown();
								}
							});
						});
					});
				case 'senpai':
					schoolIntro(doof);
				case 'roses':
					FlxG.sound.play(Paths.sound('ANGRY'));
					schoolIntro(doof);
				case 'thorns':
					schoolIntro(doof);
				case 'rhythm-report':
					inCutscene = true;
					var video = new MP4Sprite();
					video.antialiasing = true;

					video.finishCallback = function()
					{
						camOTHER.fade(FlxColor.BLACK, 1, true);
						startCountdown();
					};
					video.playVideo(Paths.video('FNRCutscene'), false, false);
					video.cameras = [camOTHER];
					add(video);
				case 'questionnaire':
					inCutscene = true;
					var video = new MP4Sprite();
					video.antialiasing = true;

					video.finishCallback = function()
					{
						camOTHER.fade(FlxColor.BLACK, 1, true);
						startCountdown();
					};
					video.playVideo(Paths.video('FNRCutscene2'), false, false);
					video.cameras = [camOTHER];
					add(video);
				case 'ringside':
					inCutscene = true;
					var video = new MP4Sprite();
					video.antialiasing = true;

					video.finishCallback = function()
					{
						camOTHER.fade(FlxColor.BLACK, 1, true);
						startCountdown();
					};
					video.playVideo(Paths.video('FNRCutscene3'), false, false);
					video.cameras = [camOTHER];
					add(video);
				default:
					startCountdown();
			}
		}
		else
		{
			switch (curSong)
			{
				default:
					startCountdown();
			}
		}

		songTimer = new FlxPieDial(100, 100, 50, weekColor, 1024, FlxPieDialShape.CIRCLE, false, 50);
		songTimer.cameras = [camHUD];
		songTimer.antialiasing = getPref('antialiasing');
		// add(songTimer); FlxPieDial sucks

		super.create();
	}

	function schoolIntro(?dialogueBox:DialogueBox):Void
	{
		var black = new FlxSprite(-100, -100).makeGraphic(FlxG.width * 2, FlxG.height * 2, FlxColor.BLACK);
		black.scrollFactor.set();
		add(black);

		var red = new FlxSprite(-100, -100).makeGraphic(FlxG.width * 2, FlxG.height * 2, 0xFFff1b31);
		red.scrollFactor.set();

		var senpaiEvil:FlxSprite = new FlxSprite();
		senpaiEvil.frames = Paths.getSparrowAtlas('weeb/senpaiCrazy');
		senpaiEvil.animation.addByPrefix('idle', 'Senpai Pre Explosion', 24, false);
		senpaiEvil.setGraphicSize(Std.int(senpaiEvil.width * 6));
		senpaiEvil.scrollFactor.set();
		senpaiEvil.updateHitbox();
		senpaiEvil.screenCenter();

		if (SONG.song.toLowerCase() == 'roses' || SONG.song.toLowerCase() == 'thorns')
		{
			remove(black);

			if (SONG.song.toLowerCase() == 'thorns')
			{
				add(red);
				camHUD.alpha = 0;
				camBACKGROUND_OPACITY.alpha = 0;
			}
		}

		new FlxTimer().start(0.3, function(tmr:FlxTimer)
		{
			black.alpha -= 0.15;

			if (black.alpha > 0)
			{
				tmr.reset(0.3);
			}
			else
			{
				if (dialogueBox != null)
				{
					inCutscene = true;

					if (SONG.song.toLowerCase() == 'thorns')
					{
						add(senpaiEvil);
						senpaiEvil.alpha = 0;
						new FlxTimer().start(0.3, function(swagTimer:FlxTimer)
						{
							senpaiEvil.alpha += 0.15;
							if (senpaiEvil.alpha < 1)
							{
								swagTimer.reset();
							}
							else
							{
								senpaiEvil.animation.play('idle');
								FlxG.sound.play(Paths.sound('Senpai_Dies'), 1, false, null, true, function()
								{
									remove(senpaiEvil);
									remove(red);
									FlxTween.tween(camHUD, {alpha: 1}, 0.01);
									FlxTween.tween(camBACKGROUND_OPACITY, {alpha: 1}, 0.01);
									FlxG.camera.fade(FlxColor.WHITE, 0.01, true, function()
									{
										add(dialogueBox);
									}, true);
								});
								new FlxTimer().start(3.2, function(deadTime:FlxTimer)
								{
									FlxG.camera.fade(FlxColor.WHITE, 1.6, false);
								});
							}
						});
					}
					else
						add(dialogueBox);
				}
				else
					startCountdown();

				remove(black);
			}
		});
	}

	var barraGrisMidscroll:Void->Void;
	var wasMidscroll = false;

	function startCountdown():Void
	{
		if (curSong == 'ringside')
		{
			var laputabarragris = new FlxSprite(0, 160);
			laputabarragris.x += 50;
			laputabarragris.x += ((flixel.FlxG.width / 2) * 1);
			laputabarragris.frames = Paths.getSparrowAtlas('NOTE_assets');
			laputabarragris.animation.addByPrefix('staticfalse', 'arrowSPACE', 0, false, false, false);
			laputabarragris.animation.addByPrefix('statictrue', 'arrowSPACE', 0, false, false, true);
			laputabarragris.setGraphicSize(Std.int(laputabarragris.width * 0.7));
			laputabarragris.antialiasing = getPref('antialiasing');
			laputabarragris.updateHitbox();
			laputabarragris.animation.play('static');
			laputabarragris.cameras = [camNOTES];
			add(laputabarragris);

			var elNinioDelOxxito = new FlxText(laputabarragris.x + 125, laputabarragris.y + 75, 0, KeyBinds.keyCodeToString(FlxG.save.data.noteBinds[4]),
				30); // ! https://cdn.discordapp.com/avatars/472104176051027981/a0b44d89ebe800749ba6b49e538b3b44.png?size=4096
			elNinioDelOxxito.flipY = getPref('downscroll');
			elNinioDelOxxito.setFormat(Paths.font("vcr.ttf"), 45, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			elNinioDelOxxito.setBorderStyle(FlxTextBorderStyle.OUTLINE);
			elNinioDelOxxito.borderSize = 4;
			elNinioDelOxxito.borderSize = 4;
			elNinioDelOxxito.borderQuality = 4;
			elNinioDelOxxito.borderColor = FlxColor.BLACK;
			elNinioDelOxxito.cameras = [camNOTES];
			elNinioDelOxxito.x = laputabarragris.width / 2;
			elNinioDelOxxito.autoSize = false;
			elNinioDelOxxito.fieldWidth = 250;
			elNinioDelOxxito.alignment = FlxTextAlign.CENTER;
			add(elNinioDelOxxito);

			barraGrisMidscroll = function()
			{
				if (getPref('midscroll'))
				{
					wasMidscroll = true;
					laputabarragris.x -= 275;
				}
				else if (wasMidscroll)
				{
					wasMidscroll = false;
					laputabarragris.x += 275;
				}
				elNinioDelOxxito.x = laputabarragris.x + laputabarragris.width / 2 + 50;
				elNinioDelOxxito.flipY = getPref('downscroll');
				laputabarragris.animation.play('static${getPref('downscroll')}');
			}

			if (!isStoryMode)
			{
				for (object in [elNinioDelOxxito, laputabarragris])
				{
					object.y -= 10;
					object.alpha = 0;
					FlxTween.tween(object, {y: object.y + 10, alpha: 1}, 1, {ease: FlxEase.circOut, startDelay: 1 + (0.2 * 4)});
				}
			}
			new FlxTimer().start(TimeTools.toSeconds(firstNoteTime - 1500, MS), function(_)
			{
				for (object in [elNinioDelOxxito, laputabarragris])
				{
					FlxTween.tween(object, {alpha: 0}, 1, {
						ease: FlxEase.circOut
					});
				}
			});
		}

		goForP.visible = true;
		new FlxTimer().start(2, function(tmr:FlxTimer)
		{
			FlxTween.tween(goForP, {alpha: 0, x: goForP.x + 200}, 0.6, {
				ease: FlxEase.quartInOut,
				onComplete: function(twn:FlxTween)
				{
					remove(goForP);
				}
			});
		});
		inCutscene = false;
		seenCutscene = true;

		checkSettingsInGame(false, true);

		startedCountdown = true;
		Conductor.songPosition = 0;
		Conductor.songPosition -= Conductor.crochet * 7;

		var swagCounter:Int = 0;

		skipSpr = new FlxSprite().loadGraphic(Paths.image('skip'));
		skipSpr.antialiasing = getPref('antialiasing');
		skipSpr.setGraphicSize(Std.int(skipSpr.width * 0.4));
		skipSpr.updateHitbox();
		skipSpr.screenCenter();
		skipSpr.y = FlxG.height - 100;
		skipSpr.x = FlxG.width - 350;
		skipSpr.alpha = 0;
		skipSpr.cameras = [camHUD];
		add(skipSpr);

		startTimer = new FlxTimer().start(Conductor.crochet / 1000, function(tmr:FlxTimer)
		{
			if (swagCounter != 4)
			{
				dad.dance();
				gf.dance();
				boyfriend.dance();
			}

			var introAssets:Map<String, Array<String>> = new Map<String, Array<String>>();
			introAssets.set('default', ['ready', "set", "go"]);
			introAssets.set('school', ['weeb/pixelUI/ready-pixel', 'weeb/pixelUI/set-pixel', 'weeb/pixelUI/date-pixel']);
			introAssets.set('schoolEvil', ['weeb/pixelUI/ready-pixel', 'weeb/pixelUI/set-pixel', 'weeb/pixelUI/date-pixel']);

			var introAlts:Array<String> = introAssets.get('default');
			var altSuffix:String = "";

			for (value in introAssets.keys())
			{
				if (value == curStage)
				{
					introAlts = introAssets.get(value);
					altSuffix = '-pixel';
				}
			}

			switch (swagCounter)
			{
				case 0:
					FlxG.sound.play(Paths.sound('intro3'), 0.6);
				case 1:
					var ready:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[0]));
					ready.scrollFactor.set();
					ready.updateHitbox();

					if (curStage.startsWith('school'))
						ready.setGraphicSize(Std.int(ready.width * daPixelZoom));

					ready.screenCenter();
					ready.cameras = [camHUD];
					add(ready);
					FlxTween.tween(ready, {y: ready.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							ready.destroy();
						}
					});
					FlxG.sound.play(Paths.sound('intro2'), 0.6);
				case 2:
					var set:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[1]));
					set.scrollFactor.set();

					if (curStage.startsWith('school'))
						set.setGraphicSize(Std.int(set.width * daPixelZoom));

					set.screenCenter();
					set.cameras = [camHUD];
					add(set);
					FlxTween.tween(set, {y: set.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							set.destroy();
						}
					});
					FlxG.sound.play(Paths.sound('intro1'), 0.6);
				case 3:
					// var go = new FlxSprite().loadGraphic(Paths.image(introAlts[2]));
					// go.scrollFactor.set();

					// if (curStage.startsWith('school'))
					// 	go.setGraphicSize(Std.int(go.width * daPixelZoom));

					// go.updateHitbox();

					// go.screenCenter();
					// add(go);

					var go = new FlxSprite();
					go.frames = Paths.getSparrowAtlas('go_anim');
					go.animation.addByPrefix('go', 'GO!!', 24, false);
					go.animation.play('go');
					go.cameras = [camHUD];
					go.animation.finishCallback = function(name:String)
					{
						go.destroy();
					};
					FlxTween.tween(go, {y: go.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							go.destroy();
						}
					});
					go.scrollFactor.set();
					go.updateHitbox();
					go.screenCenter();
					add(go);
					FlxG.sound.play(Paths.sound('introGo'), 0.6);
				case 4:
					#if mobileC
					mcontrols.active = true;
					pauseButton.active = true;

					mcontrols.visible = true;
					pauseButton.visible = true;
					#end
			}

			swagCounter += 1;
		}, 5);

		if (!skippedIntro)
			FlxTween.tween(skipSpr, {alpha: 1}, 0.5);
	}

	function startSong():Void
	{
		startingSong = false;
		previousFrameTime = FlxG.game.ticks;
		if (!paused)
		{
			FlxG.sound.playMusic(getInst(), 1, false);
			FlxG.sound.music.looped = false;
		}
		startedSong = true;
		FlxG.sound.music.onComplete = function()
		{
			if (isStoryMode && curSong == 'ringside')
			{
			}
			else
				endSong();
			vocals.volume = 0;
			vocals.stop();
		};
		vocals.play();
		#if (windows && cpp)
		// Song duration in a float, useful for the time left feature
		songLength = FlxG.sound.music.length;
		// Updating Discord Rich Presence (with Time Left)
		DiscordClient.changePresence(detailsText, SONG.song + " (" + curDifficultyText + ")", iconRPC, true, songLength);
		#end
	}

	private function generateSong():Void
	{
		Conductor.changeBPM(SONG.bpm);

		vocals = getVocals();
		FlxG.sound.list.add(vocals);
		vocals.looped = false;

		notes = new FlxTypedGroup<Note>();
		add(notes);

		var daBeats:Int = 0; // Not exactly representative of 'daBeats' lol, just how much it has looped
		var i = 0;
		for (section in SONG.notes)
		{
			for (songNotes in section.sectionNotes)
			{
				var daStrumTime:Float = songNotes[0];
				if (i == 0)
				{
					firstNoteTime = songNotes[0];
					if (firstNoteTime - 1500 < 0 || curSong == 'ringside')
						skippedIntro = true;
					i++;
				}
				var daNoteData:Int = Std.int(songNotes[1]);

				var gottaHitNote:Bool = section.mustHitSection;

				if (songNotes[1] % 8 >= 4)
					gottaHitNote = !section.mustHitSection;

				gottaHitNote = !opponentMode ? gottaHitNote : !gottaHitNote;
				var oldNote:Note;
				if (unspawnNotes.length > 0)
					oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];
				else
					oldNote = null;

				var swagNote = new Note(daStrumTime, daNoteData, oldNote, false, false, songNotes[4] == true ? true : false);
				if ((section.altAnim && (!opponentMode ? !gottaHitNote : gottaHitNote)))
					swagNote.singSuffix = '-alt';
				swagNote.sustainLength = songNotes[2];
				swagNote.scrollFactor.set(0, 0);

				var susLength:Float = swagNote.sustainLength;

				susLength = susLength / Conductor.stepCrochet;
				unspawnNotes.push(swagNote);

				for (susNote in 0...Math.floor(susLength))
				{
					oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];

					var sustainNote = new Note(daStrumTime + (Conductor.stepCrochet * susNote) + Conductor.stepCrochet, daNoteData, oldNote, true, true,
						songNotes[4] == true ? true : false);
					if ((section.altAnim && (!opponentMode ? !gottaHitNote : gottaHitNote))
						|| (Std.isOfType(songNotes[3], Bool) && songNotes[3] == true))
						sustainNote.singSuffix = '-alt';
					sustainNote.scrollFactor.set();
					unspawnNotes.push(sustainNote);

					sustainNote.mustPress = gottaHitNote;

					if (sustainNote.mustPress)
						sustainNote.x += FlxG.width / 2; // general offset
				}

				swagNote.mustPress = gottaHitNote;

				if (swagNote.mustPress)
					swagNote.x += FlxG.width / 2; // general offset
			}
			daBeats += 1;
		}

		// trace(unspawnNotes.length);
		// playerCounter += 1;

		unspawnNotes.sort(sortByShit);

		generatedMusic = true;
	}

	function sortByShit(Obj1:Note, Obj2:Note):Int
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1.strumTime, Obj2.strumTime);

	private function generateStaticArrows(player:Int, ?style:String, ?fadeInAnim:Dynamic):Void
	{
		if (style == null)
			style = Note.getNoteStyle();
		if (fadeInAnim == null)
			fadeInAnim = true;
		for (i in 0...4)
		{
			var babyArrow = new BabyArrow(strumLine.y, i, style, player, fadeInAnim && !isStoryMode);

			if (getPref('midscroll'))
				babyArrow.x -= 275;
			if (player == 1)
				playerStrums.add(babyArrow);
			else
				opponentStrums.add(babyArrow);

			if (getPref('midscroll') && player == 0)
				return;

			strumLineNotes.add(babyArrow);
		}
	}

	function tweenCamIn():Void
		FlxTween.tween(FlxG.camera, {zoom: 1.3}, (Conductor.stepCrochet * 4 / 1000), {ease: FlxEase.elasticInOut});

	override function openSubState(SubState:FlxSubState)
	{
		paused = true;

		if (paused)
		{
			if (FlxG.sound.music != null)
			{
				FlxG.sound.music.pause();
				vocals.pause();
			}

			if (startTimer != null)
				if (!startTimer.finished)
					startTimer.active = false;
		}

		super.openSubState(SubState);
	}

	override function closeSubState()
	{
		if (paused)
		{
			if (FlxG.sound.music != null && !startingSong)
				resyncVocals();

			if (startTimer != null)
				if (!startTimer.finished)
					startTimer.active = true;
			paused = false;

			#if (windows && cpp)
			if (startTimer != null)
				if (startTimer.finished)
				{
					DiscordClient.changePresence(detailsText, SONG.song + " (" + curDifficultyText + ")", iconRPC, true, songLength - Conductor.songPosition);
				}
				else
				{
					DiscordClient.changePresence(detailsText, SONG.song + " (" + curDifficultyText + ")", iconRPC);
				}
			#end
		}

		super.closeSubState();
	}

	override public function onFocus():Void
	{
		#if (windows && cpp)
		if (health > 0 && !paused)
		{
			if (Conductor.songPosition > 0.0)
			{
				DiscordClient.changePresence(detailsText, SONG.song + " (" + curDifficultyText + ")", iconRPC, true, songLength - Conductor.songPosition);
			}
			else
			{
				DiscordClient.changePresence(detailsText, SONG.song + " (" + curDifficultyText + ")", iconRPC);
			}
		}
		#end

		super.onFocus();
	}

	override public function onFocusLost():Void
	{
		#if (windows && cpp)
		if (health > 0 && !paused)
		{
			DiscordClient.changePresence(detailsPausedText, SONG.song + " (" + curDifficultyText + ")", iconRPC);
		}
		#end

		super.onFocusLost();
	}

	function resyncVocals():Void
	{
		vocals.pause();

		FlxG.sound.music.play();
		Conductor.songPosition = FlxG.sound.music.time;
		vocals.time = Conductor.songPosition;
		vocals.play();
	}

	override public function update(elapsed:Float)
	{
		if (stageUpdate != null)
			stageUpdate(elapsed);

		if (checkKey('NINE'))
		{
			if (!opponentMode)
				iconP1.swapOldIcon();
			else
				iconP2.swapOldIcon();
			healthBar.createFilledBar(HealthIconsData.getIconColor(iconP2.char), HealthIconsData.getIconColor(iconP1.char));
			healthBar.updateFilledBar();
		}

		if (!skippedIntro && startedSong)
		{
			if (checkKey('SPACE'))
			{
				FlxG.sound.music.time = firstNoteTime - 1500;
				resyncVocals();
			}
			if (FlxG.sound.music.time >= firstNoteTime - 1500)
			{
				FlxTween.tween(skipSpr, {alpha: 0}, 0.5);
				skippedIntro = true;
			}
		}

		if (startedSong)
			songTimer.amount = 1 - ((FlxG.sound.music.length - FlxG.sound.music.time) / FlxG.sound.music.length);
		else
			songTimer.amount = 0;

		super.update(elapsed);

		scoreTxt.text = '${langString('score')}: $songScore | ${langString('misses')}: $misses | ${langString('accuracy')}: ${Math.isFinite(accuracy) ? accuracy.truncate() : 0}% [${NoteJudements.calculateRating(accuracy)}]';
		scoreTxt.screenCenter(X);

		if ((controls.PAUSE #if mobileC || pauseButton.buttonC.justPressed || MobileControls.androidBack #end)
			&& startedCountdown
			&& canPause)
		{
			persistentUpdate = false;
			persistentDraw = true;
			paused = true;

			// 1 / 1000 chance for Gitaroo Man easter egg
			if (FlxG.random.bool(0.1))
				switchState(GitarooPause);
			else
				openSubState(new PauseSubState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));

			#if (windows && cpp)
			DiscordClient.changePresence(detailsPausedText, SONG.song + " (" + curDifficultyText + ")", iconRPC);
			#end
		}

		iconP1.setGraphicSize(Std.int(150 + 0.85 * (iconP1.width - 150)));
		iconP2.setGraphicSize(Std.int(150 + 0.85 * (iconP2.width - 150)));
		iconP1.updateHitbox();
		iconP2.updateHitbox();

		iconP1.x = (healthBar.x + (0.01 * healthBar.width * FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) - 26));
		iconP2.x = (healthBar.x + 0.01 * healthBar.width * FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) - (iconP2.width - 26));

		if (health > 2)
			health = 2;

		if (healthBar.percent < 20)
			iconP1.animation.curAnim.curFrame = 1;
		else
			iconP1.animation.curAnim.curFrame = 0;

		if (healthBar.percent > 80)
			iconP2.animation.curAnim.curFrame = 1;
		else
			iconP2.animation.curAnim.curFrame = 0;

		if (startingSong)
		{
			if (startedCountdown)
			{
				Conductor.songPosition += FlxG.elapsed * 1000;
				if (Conductor.songPosition >= 0)
					startSong();
			}
		}
		else
		{
			Conductor.songPosition += FlxG.elapsed * 1000;

			if (!paused)
			{
				songTime += FlxG.game.ticks - previousFrameTime;
				previousFrameTime = FlxG.game.ticks;

				// Interpolation type beat
				if (Conductor.lastSongPos != Conductor.songPosition)
				{
					songTime = (songTime + Conductor.songPosition) / 2;
					Conductor.lastSongPos = Conductor.songPosition;
					// trace('MISSED FRAME');
				}
			}

			// Conductor.lastSongPos = FlxG.sound.music.time;
		}

		var curSection = PlayState.SONG.notes[Std.int(curStep / 16)];
		if (generatedMusic && curSection != null)
		{
			cameraRightSide = !isAloneFunkin ? curSection.mustHitSection : true;
			cameraMovement();
		}

		if (camZooming)
		{
			FlxG.camera.zoom = defaultCamZoom + 0.95 * (FlxG.camera.zoom - defaultCamZoom);
			camHUD.zoom = 1 + 0.95 * (camHUD.zoom - 1);
		}

		FlxG.watch.addQuick("beatShit", curBeat);
		FlxG.watch.addQuick("stepShit", curStep);
		FlxG.watch.addQuick('sicks', sicks);
		FlxG.watch.addQuick('goods', goods);
		FlxG.watch.addQuick('bads', bads);
		FlxG.watch.addQuick('shits', shits);

		if (curSong == 'fresh')
		{
			switch (curBeat)
			{
				case 16:
					gfSpeed = 2;
				case 48:
					gfSpeed = 1;
				case 80:
					gfSpeed = 2;
				case 112:
					gfSpeed = 1;
			}
		}

		if (curSong == 'bopeebo')
		{
			switch (curBeat)
			{
				case 128, 129, 130:
					vocals.volume = 0;
			}
		}
		// better streaming of shit

		// CHEAT = brandon's a pussy
		if (controls.CHEAT)
		{
			health += 1;
			trace("User is cheating!");
		}

		if (health <= 0 && !practiceMode)
			deathAnim(false);
		if (controls.RESET && getPref('allowReset'))
			deathAnim(true);

		if (unspawnNotes[0] != null)
		{
			if (unspawnNotes[0].strumTime - Conductor.songPosition < 1500)
			{
				var dunceNote:Note = unspawnNotes[0];
				notes.add(dunceNote);

				var index:Int = unspawnNotes.indexOf(dunceNote);
				unspawnNotes.splice(index, 1);
			}
		}

		if (generatedMusic)
		{
			notes.forEachAlive(function(daNote:Note)
			{
				if (daNote.y > FlxG.height)
				{
					daNote.active = false;
					daNote.visible = false;
				}
				else
				{
					daNote.visible = true;
					daNote.active = true;
				}

				if (!daNote.mustPress && getPref('midscroll'))
					daNote.alpha = 0;

				var posPoint = new FlxPoint(0, 0);

				if (daNote.mustPress)
				{
					if (playerStrums.members[daNote.noteData] != null)
						posPoint = playerStrums.members[daNote.noteData].getPosition();
				}
				else
				{
					if (opponentStrums.members[daNote.noteData] != null)
						posPoint = opponentStrums.members[daNote.noteData].getPosition();
				}

				daNote.y = (posPoint.y - (Conductor.songPosition - daNote.strumTime) * (.45 * FlxMath.roundDecimal(SONG.speed, 2)));
				daNote.x = posPoint.x;

				if (daNote.isSustainNote)
				{
					daNote.x += daNote.width / 2 + 20;
					if (daNote.isSpaceBarNote)
						daNote.x += 150;
				}

				// i am so fucking sorry for this if condition
				if (daNote.isSustainNote
					&& daNote.y + daNote.offset.y <= strumLine.y + Note.swagWidth / 2
					&& (!daNote.mustPress || (daNote.wasGoodHit || (daNote.prevNote.wasGoodHit && !daNote.canBeHit))))
				{
					var swagRect = new FlxRect(0, strumLine.y + Note.swagWidth / 2 - daNote.y, daNote.width * 2, daNote.height * 2);
					swagRect.y /= daNote.scale.y;
					swagRect.height -= swagRect.y;

					daNote.clipRect = swagRect;
				}

				if (!daNote.mustPress && daNote.wasGoodHit)
				{
					opponentChar.sing(daNote);
					opponentChar.holdTimer = 0;

					if (SONG.needsVoices)
						vocals.volume = 1;

					NoteSplash.spawnSplash(this, daNote, 2);
					opponentStrums.forEach(function(spr:BabyArrow)
					{
						if (spr.noteData == daNote.noteData)
							spr.playConfirm(daNote);
					});

					daNote.kill();
					notes.remove(daNote, true);
					daNote.destroy();
				}

				// WIP interpolation shit? Need to fix the pause issue
				// daNote.y = (strumLine.y - (songTime - daNote.strumTime) * (0.45 * PlayState.SONG.speed));

				if (daNote.y < -daNote.height)
				{
					if (daNote.tooLate || !daNote.wasGoodHit)
						noteMiss(daNote, false);

					daNote.active = false;
					daNote.visible = false;

					daNote.kill();
					notes.remove(daNote, true);
					daNote.destroy();
				}
			});

			for (squizzleFunc in squizzleFuncsArray)
			{
				if (squizzleFunc.time <= Conductor.songPosition && !squizzleFuncsCompleted.contains(squizzleFunc.time))
					squizzleFunc.func();
			}
		}

		if (!inCutscene)
			keyShit();

		#if debug
		debugToolsCheck();
		#end
	}

	public function endSong():Void
	{
		#if mobileC
		mcontrols.active = false;
		pauseButton.active = false;

		mcontrols.visible = false;
		pauseButton.visible = false;
		#end

		canPause = false;
		FlxG.sound.music.stop();
		FlxG.sound.music.volume = 0;
		vocals.volume = 0;
		Highscore.saveScore(SONG.song, songScore, curDifficulty);

		if (isStoryMode)
		{
			campaignScore += songScore;
			campaignMisses += misses;
			trace(campaignScore);
			trace(songScore);
			trace(campaignMisses);
			trace(misses);

			storyPlaylist.remove(storyPlaylist[0]);

			if (storyPlaylist.length <= 0)
			{
				MusicManager.playMainMusic();

				PlayState.exit();
				// pls ignore this fucking hardcoding
				var tempWeeksScore:Array<Int> = [];
				var weeksScore:Array<Int> = getPref('weeksScore');
				var tempWeeksMisses:Array<Int> = [];
				var weeksMisses:Array<Int> = getPref('weeksMisses');
				var tempWeeksCompleted:Array<Bool> = [];
				var weeksCompleted:Array<Bool> = getPref('weeksCompleted');

				for (i in weeksScore)
					tempWeeksScore.push(i);
				for (i in weeksMisses)
					tempWeeksMisses.push(i);
				for (i in weeksCompleted)
					tempWeeksCompleted.push(i);

				if (campaignScore > weeksScore[curWeek])
					tempWeeksScore[curWeek] = campaignScore;
				if (campaignMisses < weeksMisses[curWeek] || weeksCompleted[curWeek] == false)
					tempWeeksMisses[curWeek] = campaignMisses;
				tempWeeksCompleted[curWeek] = true;

				setPref('weeksScore', tempWeeksScore);
				setPref('weeksMisses', tempWeeksMisses);
				setPref('weeksCompleted', tempWeeksCompleted);
				Highscore.saveWeekScore(curWeek, campaignScore, curDifficulty);
			}
			else
			{
				if (SONG.song.toLowerCase() == 'eggnog')
				{
					var blackShit:FlxSprite = new FlxSprite(-FlxG.width * FlxG.camera.zoom,
						-FlxG.height * FlxG.camera.zoom).makeGraphic(FlxG.width * 3, FlxG.height * 3, FlxColor.BLACK);
					blackShit.scrollFactor.set();
					add(blackShit);
					camHUD.visible = false;

					FlxG.sound.play(Paths.sound('Lights_Shut_off'));
				}

				prevCamFollow = camFollow;

				loadSong(CoolUtil.formatSong(PlayState.storyPlaylist[0].toLowerCase(), curDifficulty), curWeek, weekColor, isStoryMode, true, false, true);
			}
		}
		else
			PlayState.exit();
	}

	var endingSong:Bool = false;

	private function popUpScore(daNote:Note):Void
	{
		vocals.volume = 1;

		var rating:FlxSprite = new FlxSprite();
		var score:Int = 350;

		var daRating = NoteJudements.getJudement(daNote);

		switch (daRating)
		{
			case 'shit':
				shits++;
				score = 50;
			case 'bad':
				bads++;
				score = 100;
			case 'good':
				goods++;
				score = 200;
			case 'sick':
				sicks++;
				if (!daNote.isSpaceBarNote)
					NoteSplash.spawnSplash(this, daNote, 1);
				else
				{
					for (i in 0...3)
						NoteSplash.spawnSplash(this, daNote, 1, true, i);
				}
		}
		totalNotesHitted += NoteJudements.getJudementAccuracy(daRating);
		recalculateRating();
		if (!practiceMode)
			songScore += score;

		var pixelShitPart1:String = "";
		var pixelShitPart2:String = '';

		if (isPixel)
		{
			pixelShitPart1 = 'weeb/pixelUI/';
			pixelShitPart2 = '-pixel';
		}

		var libraryyyy = isPixel ? 'week6' : null;
		rating.loadGraphic(Paths.image(pixelShitPart1 + daRating + pixelShitPart2, libraryyyy));
		rating.screenCenter();
		rating.x = (FlxG.width * 0.55) - 40;
		rating.screenCenter();
		if (getPref('midscroll'))
			rating.x += 250;
		rating.y -= 60;
		rating.acceleration.y = 550;
		rating.velocity.y -= FlxG.random.int(140, 175);
		rating.velocity.x -= FlxG.random.int(0, 10);
		rating.cameras = [camHUD];

		add(rating);

		if (!isPixel)
		{
			rating.setGraphicSize(Std.int(rating.width * 0.7));
			rating.antialiasing = getPref('antialiasing');
		}
		else
		{
			rating.setGraphicSize(Std.int(rating.width * daPixelZoom * 0.7));
		}

		rating.updateHitbox();

		var seperatedScore:Array<Int> = [];

		var comboSplit:Array<String> = (combo + "").split('');

		// make sure we have 3 digits to display (looks weird otherwise lol)
		if (comboSplit.length == 1)
		{
			seperatedScore.push(0);
			seperatedScore.push(0);
		}
		else if (comboSplit.length == 2)
			seperatedScore.push(0);

		for (i in 0...comboSplit.length)
		{
			var str:String = comboSplit[i];
			seperatedScore.push(Std.parseInt(str));
		}

		var daLoop:Int = 0;
		for (i in seperatedScore)
		{
			var numScore = new FlxSprite().loadGraphic(Paths.image(pixelShitPart1 + 'num' + Std.int(i) + pixelShitPart2, libraryyyy));
			numScore.screenCenter();
			numScore.x = rating.x + (43 * daLoop) - 50;
			numScore.y = rating.y + 100;
			numScore.cameras = [camHUD];

			if (!isPixel)
			{
				numScore.antialiasing = getPref('antialiasing');
				numScore.setGraphicSize(Std.int(numScore.width * 0.5));
			}
			else
			{
				numScore.setGraphicSize(Std.int(numScore.width * daPixelZoom));
			}
			numScore.updateHitbox();

			numScore.acceleration.y = FlxG.random.int(200, 300);
			numScore.velocity.y -= FlxG.random.int(140, 160);
			numScore.velocity.x = FlxG.random.float(-5, 5);
			add(numScore);

			FlxTween.tween(numScore, {alpha: 0}, 0.2, {
				onComplete: function(tween:FlxTween)
				{
					numScore.destroy();
				},
				startDelay: Conductor.crochet * 0.002
			});

			daLoop++;
		}

		FlxTween.tween(rating, {alpha: 0}, 0.2, {
			startDelay: Conductor.crochet * 0.001
		});
	}

	private function keyShit():Void
	{
		var spaceP = #if mobileC mcontrols.NOTE_SPACE_P #else controls.NOTE_SPACE_P #end;
		var spaceR = #if mobileC mcontrols.NOTE_SPACE_R #else controls.NOTE_SPACE_R #end;
		var space = #if mobileC mcontrols.NOTE_SPACE #else controls.NOTE_SPACE #end;
		if (curSong != 'ringside')
		{
			spaceP = false;
			spaceR = false;
			space = false;
		}
		var controlArray:Array<Bool> = [
			#if mobileC //
			mcontrols.NOTE_LEFT_P, mcontrols.NOTE_DOWN_P, mcontrols.NOTE_UP_P, mcontrols.NOTE_RIGHT_P //
			#else //
			controls.NOTE_LEFT_P, controls.NOTE_DOWN_P, controls.NOTE_UP_P, controls.NOTE_RIGHT_P //
			#end //
		];
		var controlHoldArray:Array<Bool> = [
			#if mobileC //
			mcontrols.NOTE_LEFT, mcontrols.NOTE_DOWN, mcontrols.NOTE_UP, mcontrols.NOTE_RIGHT //
			#else //
			controls.NOTE_LEFT, controls.NOTE_DOWN, controls.NOTE_UP, controls.NOTE_RIGHT //
			#end //
		];

		if ((controlArray.contains(true) || spaceP) && getPref('hitsound'))
			FlxG.sound.play(Paths.sound('hitsound'), .65);
		playerStrums.forEach(function(spr:BabyArrow)
		{
			if (spaceP)
				spr.playAnim('pressed');
			if (spaceR)
				spr.playAnim('static');
			if (controlArray[spr.ID] && spr.animation.curAnim.name != 'confirm')
				spr.playAnim('pressed');

			if (!space)
				if (!controlHoldArray[spr.ID])
					spr.playAnim('static');
		});
		if (generatedMusic)
		{
			notes.forEachAlive(function(daNote:Note)
			{
				if (daNote.isSpaceBarNote)
					controlHoldArray[0] = space;
				if (daNote.isSustainNote && controlHoldArray[daNote.noteData] && daNote.canBeHit && daNote.mustPress && !daNote.tooLate && !daNote.wasGoodHit)
					goodNoteHit(daNote);
			});

			if (((controlHoldArray.contains(true) || space) || (controlArray.contains(true) || spaceP)) && !endingSong)
			{
				if (controlArray.contains(true) || spaceP)
				{
					for (i in 0...controlArray.length)
					{
						var pressNotes:Array<Note> = [];
						var notesDatas:Array<Int> = [];
						var notesStopped:Bool = false;

						var sortNotes:Array<Note> = [];
						notes.forEachAlive(function(daNote:Note)
						{
							if (daNote.canBeHit && daNote.mustPress && !daNote.tooLate && !daNote.wasGoodHit && daNote.noteData == i)
							{
								sortNotes.push(daNote);
								notesDatas.push(daNote.noteData);
							}
						});
						sortNotes.sort((a, b) -> Std.int(a.strumTime - b.strumTime));

						if (sortNotes.length > 0)
						{
							for (sortedNote in sortNotes)
							{
								for (doubleNote in pressNotes)
								{
									if (Math.abs(doubleNote.strumTime - sortedNote.strumTime) < 10)
									{
										doubleNote.kill();
										notes.remove(doubleNote, true);
										doubleNote.destroy();
									}
									else
										notesStopped = true;
								}

								if (sortedNote.isSpaceBarNote)
									controlArray[0] = spaceP;
								if (controlArray[sortedNote.noteData] && !notesStopped)
								{
									goodNoteHit(sortedNote);
									pressNotes.push(sortedNote);
								}
							}
						}
						else if (!getPref('ghostTapping') && (controlArray[i]))
							noteMiss(new Note(0, i), true);
					}
				}
			}

			if (playableChar.holdTimer > Conductor.stepCrochet * 4 * 0.001 && !controlHoldArray.contains(true))
				if (playableChar.animation.curAnim.name.startsWith('sing') && !playableChar.animation.curAnim.name.endsWith('miss'))
					playableChar.dance();
		}
	}

	function noteMiss(daNote:Note, isGhost:Bool):Void
	{
		if (!isGhost)
		{
			notes.forEachAlive(function(note:Note)
			{
				if (daNote != note
					&& daNote.mustPress
					&& daNote.noteData == note.noteData
					&& daNote.isSustainNote == note.isSustainNote
					&& Math.abs(daNote.strumTime - note.strumTime) < 10)
				{
					note.kill();
					notes.remove(note, true);
					note.destroy();
				}
			});
			vocals.volume = 0;
		}
		recalculateRating();
		misses++;
		combo = 0;
		health -= 0.0475;
		if (combo > 5 && gf.animOffsets.exists('sad'))
			gf.playAnim('sad');

		if (!practiceMode)
			songScore -= 10;

		FlxG.sound.play(Paths.soundRandom('missnote', 1, 3), FlxG.random.float(0.1, 0.2));

		playableChar.playAnim('sing${!daNote.isSpaceBarNote ? notesDir[daNote.noteData] : 'RIGHT'}miss', true);
	}

	function goodNoteHit(note:Note):Void
	{
		if (note.wasGoodHit)
			return;

		if (!note.isSustainNote)
		{
			combo += 1;
			popUpScore(note);
		}

		if (note.noteData >= 0)
			health += 0.023;
		else
			health += 0.004;

		playableChar.sing(note);

		playerStrums.forEach(function(spr:BabyArrow)
		{
			if (!note.isSpaceBarNote)
			{
				if (spr.noteData == note.noteData)
					spr.playAnim('confirm', true);
			}
			else
				spr.playAnim('confirm', true);
		});

		note.wasGoodHit = true;
		vocals.volume = 1;

		if (!note.isSustainNote)
		{
			note.kill();
			notes.remove(note, true);
			note.destroy();
		}
	}

	inline function recalculateRating():Void
	{
		notesThanShouldBeHitted++;
		accuracy = Math.min(100, Math.max(0, (totalNotesHitted / notesThanShouldBeHitted) * 100));
	}

	override function stepHit()
	{
		super.stepHit();
		if (stageStep != null)
			stageStep();
		if (FlxG.sound.music.time > Conductor.songPosition + 20 || FlxG.sound.music.time < Conductor.songPosition - 20)
			resyncVocals();
	}

	override function beatHit()
	{
		super.beatHit();

		if (stageBeat != null)
			stageBeat();

		if (generatedMusic)
			notes.sort(FlxSort.byY, FlxSort.DESCENDING);

		if (SONG.notes[Math.floor(curStep / 16)] != null)
		{
			if (SONG.notes[Math.floor(curStep / 16)].changeBPM)
			{
				Conductor.changeBPM(SONG.notes[Math.floor(curStep / 16)].bpm);
				FlxG.log.add('CHANGED BPM!');
			}
		}

		if (opponentChar.animation.curAnim.name.startsWith('sing'))
		{
			if (opponentChar.animation.curAnim.finished)
				opponentChar.dance();
		}
		else
			opponentChar.dance();

		// HARDCODING FOR MILF ZOOMS!
		if (getPref('camera-zoom'))
		{
			if (curSong == 'm.i.l.f' && curBeat >= 168 && curBeat < 200 && camZooming && FlxG.camera.zoom < 1.35)
			{
				FlxG.camera.zoom += 0.015;
				camHUD.zoom += 0.03;
			}

			if (camZooming && FlxG.camera.zoom < 1.35 && curBeat % 4 == 0)
			{
				FlxG.camera.zoom += 0.015;
				camHUD.zoom += 0.03;
			}
		}

		iconP1.setGraphicSize(Std.int(iconP1.width + 30));
		iconP2.setGraphicSize(Std.int(iconP2.width + 30));

		iconP1.updateHitbox();
		iconP2.updateHitbox();

		if (curBeat % gfSpeed == 0)
			gf.dance();

		if (!playableChar.animation.curAnim.name.startsWith("sing"))
			playableChar.dance();

		if (curBeat % 8 == 7 && curSong == 'bopeebo')
			boyfriend.playAnim('hey', true);

		if (curBeat % 16 == 15 && curSong == 'tutorial' && dad.curCharacter == 'gf' && curBeat > 16 && curBeat < 48)
		{
			boyfriend.playAnim('hey', true);
			dad.playAnim('cheer', true);
		}
	}

	function cameraMovement():Void
	{
		if (camFollow.getPosition() != getCamDadPos() && !cameraRightSide)
		{
			camFollow.setPosition(getCamDadPos().x, (curStage != 'gamer-go') ? getCamDadPos().y : getCamBFPos().y);
			if (curSong == 'tutorial')
				tweenCamIn();
		}
		if (camFollow.getPosition() != getCamBFPos() && cameraRightSide)
		{
			camFollow.setPosition(getCamBFPos().x, getCamBFPos().y);

			if (curSong == 'tutorial')
				FlxTween.tween(FlxG.camera, {zoom: 1}, (Conductor.stepCrochet * 4 / 1000), {ease: FlxEase.elasticInOut});
		}
	}

	inline function getCamDadPos():FlxPoint
	{
		var camDadPos = new FlxPoint(dad.getMidpoint().x + 150, dad.getMidpoint().y - 100);
		switch (dad.curCharacter)
		{
			case 'mom':
				camDadPos.y = dad.getMidpoint().y;
				vocals.volume = 1;
			case 'senpai', 'senpai-angry':
				camDadPos.y = dad.getMidpoint().y - 430;
				camDadPos.x = dad.getMidpoint().x - 100;
		}
		switch (curStage)
		{
			case 'ringside':
				camDadPos.y -= 75;
				camDadPos.x += 430;
			case 'gamer-go':
				camDadPos.x += 150;
				if (isPixel)
					camDadPos.y -= 180;
		}

		return camDadPos;
	}

	inline function getCamBFPos():FlxPoint
	{
		var camBFPos = new FlxPoint(boyfriend.getMidpoint().x - 100, boyfriend.getMidpoint().y - 100);

		switch (curStage)
		{
			case 'limo':
				camBFPos.x = boyfriend.getMidpoint().x - 300;
			case 'mall':
				camBFPos.y = boyfriend.getMidpoint().y - 200;
			case 'school':
				camBFPos.x = boyfriend.getMidpoint().x - 200;
				camBFPos.y = boyfriend.getMidpoint().y - 200;
			case 'schoolEvil':
				camBFPos.x = boyfriend.getMidpoint().x - 200;
				camBFPos.y = boyfriend.getMidpoint().y - 200;
			case 'gamer-go':
				camBFPos.x -= (-115 * -2) + 50;
				camBFPos.y -= 192;
				if (isPixel)
					camBFPos.y -= 180;
			case 'ringside':
				camBFPos.x -= 400;
		}

		return camBFPos;
	}

	var stageSing:String->Void;
	var stageBeat:Void->Void;
	var stageStep:Void->Void;
	var stageUpdate:Float->Void;
	var gfVersion = 'gf';
	var gfArgs = [];
	var bfVersion = SONG.player1;
	var bfArgs = [];
	var dadVersion = SONG.player2;
	var dadArgs = [];

	var afterAddGF = function():Void
	{
	};

	var afterAddALL = function():Void
	{
	};

	var afterAddDAD = function():Void
	{
	};

	var afterAddStage = function():Void
	{
	};

	inline function loadStage():Void
	{
		switch (SONG.song.toLowerCase())
		{
			default:
				{
					defaultCamZoom = 0.9;
					curStage = 'stage';
					var bg = new BGSprite(['stageback', 'shared'], [], -600, -200, .9, .9);
					add(bg);

					var stageFront = new BGSprite(['stagefront', 'shared'], [], -650, 600, .9, .9);
					stageFront.setGraphicSize(Std.int(stageFront.width * 1.1));
					add(stageFront);

					var stageCurtains = new BGSprite(['stagecurtains', 'shared'], [], -500, -300, 1.3, 1.3);
					stageCurtains.setGraphicSize(Std.int(stageCurtains.width * 0.9));
					add(stageCurtains);
					if (curSong == 'tutorial')
						dadArgs = ['CHEER', 'SING'];
				}
			case 'spookeez', 'south', 'monster':
				{
					curStage = 'spooky';
					var halloweenBG = new BGSprite(['halloween_bg', 'week2'], [], -200, -90, 1, 1,
						[{name: 'halloweem bg0'}, {name: 'halloweem bg lightning strike'}]);
					halloweenBG.animation.finishCallback = function(anim:String)
					{
						if (anim == 'halloweem bg lightning strike')
							halloweenBG.playAnim('halloweem bg0');
					};
					add(halloweenBG);
					stageBeat = function():Void
					{
						if (FlxG.random.bool(10) && curBeat > lightningStrikeBeat + lightningOffset)
						{
							FlxG.sound.play(Paths.soundRandom('thunder_', 1, 2));
							halloweenBG.playAnim('halloweem bg lightning strike');

							lightningStrikeBeat = curBeat;
							lightningOffset = FlxG.random.int(8, 24);

							boyfriend.playAnim('scared', true);
							gf.playAnim('scared', true);
						}
					};
					bfArgs.push('SHAKE');
					gfArgs.push('FEAR');
				}
			case 'pico', 'philly-nice', 'blammed':
				{
					curStage = 'philly';

					var bg = new BGSprite(['philly/sky', 'week3'], [], -100, 0, 0.1, 0.1);
					add(bg);

					var city = new BGSprite(['philly/city', 'week3'], [], -10, 0, 0.3, 0.3);
					city.setGraphicSize(city.width * 0.85);
					city.updateHitbox();
					add(city);

					var phillyCityLights = new FlxTypedGroup<BGSprite>();
					add(phillyCityLights);

					var lightFadeShader = new BuildingShaders();
					for (i in 0...5)
					{
						var light = new BGSprite(['philly/win' + i, 'week3'], [], city.x, 0, 0.3, 0.3);
						light.visible = false;
						light.setGraphicSize(light.width * 0.85);
						light.updateHitbox();
						light.shader = lightFadeShader.shader;
						phillyCityLights.add(light);
					}

					var streetBehind = new BGSprite(['philly/behindTrain', 'week3'], [], -40, 50);
					add(streetBehind);

					var phillyTrain = new BGSprite(['philly/train', 'week3'], [], 2000, 360);
					add(phillyTrain);

					trainSound = new FlxSound().loadEmbedded(Paths.sound('train_passes'));
					FlxG.sound.list.add(trainSound);

					var street = new BGSprite(['philly/street', 'week3'], [], -40, streetBehind.y);
					add(street);

					stageUpdate = function(elapsed):Void
					{
						lightFadeShader.update((Conductor.crochet / 1e3) * FlxG.elapsed * 1.5);
						if (trainMoving)
						{
							trainFrameTiming += elapsed;

							if (trainFrameTiming >= 1 / 24)
							{
								{
									if (trainSound.time >= 4700)
									{
										startedMoving = true;
										gf.playAnim('hairBlow');
									}

									if (startedMoving)
									{
										phillyTrain.x -= 400;

										if (phillyTrain.x < -2000 && !trainFinishing)
										{
											phillyTrain.x = -1150;
											trainCars -= 1;

											if (trainCars <= 0)
												trainFinishing = true;
										}

										if (phillyTrain.x < -4000 && trainFinishing)
										{
											gf.playAnim('hairFall');
											phillyTrain.x = FlxG.width + 200;
											trainMoving = false;
											// trainSound.stop();
											// trainSound.time = 0;
											trainCars = 8;
											trainFinishing = false;
											startedMoving = false;
										};
									}
								}
								trainFrameTiming = 0;
							}
						}
					};

					stageBeat = function():Void
					{
						if (!trainMoving)
							trainCooldown += 1;

						if (curBeat % 4 == 0)
						{
							lightFadeShader.reset();
							phillyCityLights.forEach(function(light:FlxSprite)
							{
								light.visible = false;
							});

							phillyCityLights.members[FlxG.random.int(0, phillyCityLights.length - 1)].visible = true;
						}

						if (curBeat % 8 == 4 && FlxG.random.bool(30) && !trainMoving && trainCooldown > 8)
						{
							trainCooldown = FlxG.random.int(-4, 0);
							{
								trainMoving = true;
								if (!trainSound.playing)
									trainSound.play(true);
							}
						}
					};

					gfArgs.push('BLOWING');
				}
			case 'm.i.l.f' | 'satin-panties' | 'high':
				{
					curStage = 'limo';
					defaultCamZoom = 0.90;

					var skyBG = new BGSprite(['limo/limoSunset', 'week4'], [], -120, -50, .1, .1);
					add(skyBG);

					var bgLimo = new BGSprite(['limo/bgLimo', 'week4'], [], -200, 480, .4, .4, [{name: 'background limo pink', loop: true}]);
					add(bgLimo);

					var grpLimoDancers = new FlxTypedGroup<BackgroundDancer>();
					add(grpLimoDancers);

					for (i in 0...5)
					{
						var dancer:BackgroundDancer = new BackgroundDancer((370 * i) + 130, bgLimo.y - 400);
						dancer.scrollFactor.set(0.4, 0.4);
						grpLimoDancers.add(dancer);
					}

					var overlayShit = new BGSprite(['limo/limoOverlay', 'week4'], [], -500, -600);
					overlayShit.alpha = 0.5;

					var limo = new BGSprite(['limo/limoDrive', 'week4'], [], -120, 550, 1, 1, [{name: 'Limo stage', loop: true}]);

					var fastCar = new BGSprite(['limo/fastCarLol', 'week4'], [], -300, 160);
					fastCar.x = (-12600);
					fastCar.y = (FlxG.random.int(140, 250));
					fastCar.velocity.x = (0);
					fastCarCanDrive = true;

					gfVersion = 'gf-car';
					afterAddGF = function():Void add(limo);
					afterAddALL = function():Void add(fastCar);

					stageBeat = function():Void
					{
						grpLimoDancers.forEach(function(dancer:BackgroundDancer)
						{
							dancer.dance();
						});

						if (FlxG.random.bool(10) && fastCarCanDrive)
						{
							FlxG.sound.play(Paths.soundRandom('carPass', 0, 1), 0.7);

							fastCar.velocity.x = (FlxG.random.int(170, 220) / FlxG.elapsed) * 3;
							fastCarCanDrive = false;
							new FlxTimer().start(2, function(tmr:FlxTimer)
							{
								fastCar.x = -12600;
								fastCar.y = FlxG.random.int(140, 250);
								fastCar.velocity.x = 0;
								fastCarCanDrive = true;
							});
						}
					};
				}
			case 'cocoa' | 'eggnog':
				{
					curStage = 'mall';

					defaultCamZoom = 0.80;

					var bg = new BGSprite(['christmas/bgWalls', 'week5'], [], -1000, -500, .2, .2);
					bg.setGraphicSize(Std.int(bg.width * 0.8));
					add(bg);

					var upperBoppers = new BGSprite(['christmas/upperBop', 'week5'], [], -240, -90, .33, .33, [{name: 'Upper Crowd Bob'}]);
					upperBoppers.setGraphicSize(Std.int(upperBoppers.width * 0.85));
					add(upperBoppers);

					var bgEscalator = new BGSprite(['christmas/bgEscalator', 'week5'], [], -1100, -600, 0.3, 0.3);
					bgEscalator.setGraphicSize(Std.int(bgEscalator.width * 0.9));
					add(bgEscalator);

					var tree = new BGSprite(['christmas/christmasTree', 'week5'], [], 370, -250, .4, .4);
					add(tree);

					var bottomBoppers = new BGSprite(['christmas/bottomBop', 'week5'], [], -300, 140, .9, .9, [{name: 'Bottom Level Boppers'}]);
					bottomBoppers.setGraphicSize(Std.int(bottomBoppers.width * 1));
					add(bottomBoppers);

					var fgSnow = new BGSprite(['christmas/fgSnow', 'week5'], [], -600, 700);
					add(fgSnow);

					var santa = new BGSprite(['christmas/santa', 'week5'], [], -840, 150, 1, 1, [{name: 'santa idle in fear'}]);
					add(santa);

					stageBeat = function():Void
					{
						upperBoppers.dance(true);
						bottomBoppers.dance(true);
						santa.dance(true);
					}
					gfVersion = 'gf-christmas';
				}
			case 'winter-horrorland':
				{
					curStage = 'mallEvil';
					var bg = new BGSprite(['christmas/evilBG', 'week5'], [], -400, -500, .2, .2);
					bg.setGraphicSize(Std.int(bg.width * 0.8));
					add(bg);

					var evilTree = new BGSprite(['christmas/evilTree', 'week5'], [], 300, -300, .2, .2);
					add(evilTree);

					var evilSnow = new BGSprite(["christmas/evilSnow", 'week5'], [], -200, 700);
					add(evilSnow);
					gfVersion = 'gf-christmas';
				}
			case 'senpai' | 'roses':
				{
					curStage = 'school';

					var bgSky = new BGSprite(['weeb/weebSky', 'week6'], [PIXEL], 0, 0, 0.1, 0.1);
					add(bgSky);

					var bgSchool = new BGSprite(['weeb/weebSchool', 'week6'], [PIXEL], -200, 0, 0.6, 0.90);
					add(bgSchool);

					var bgStreet = new BGSprite(['weeb/weebStreet', 'week6'], [PIXEL], -200, 5, 0.95, 0.95);
					add(bgStreet);

					var fgTrees = new BGSprite(['weeb/weebTreesBack', 'week6'], [PIXEL], -200 + 170, 130, 0.9, 0.9);
					add(fgTrees);

					var bgTrees = new BGSprite(['weeb/weebTrees', 'week6'], [PACKER_ATLAS, PIXEL], -200 - 390, -800, 0.85, 0.85, [
						{
							name: 'treeLoop',
							loop: true,
							frameRate: 12,
							indices: [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18]
						}
					]);
					add(bgTrees);

					var treeLeaves = new BGSprite(['weeb/petals', 'week6'], [PIXEL], -200, -40, 0.85, 0.85, [{name: 'PETALS ALL', loop: true}]);
					add(treeLeaves);

					var widShit = Std.int(bgSky.width * 6);
					bgSky.setGraphicSize(widShit);
					bgSchool.setGraphicSize(widShit);
					bgStreet.setGraphicSize(widShit);
					bgTrees.setGraphicSize(widShit * 1.4);
					fgTrees.setGraphicSize(widShit * 0.8);
					treeLeaves.setGraphicSize(widShit);

					var bgGirls = new BackgroundGirls(-100, 190);
					bgGirls.scrollFactor.set(0.9, 0.9);

					if (SONG.song.toLowerCase() == 'roses')
						bgGirls.getScared();

					bgGirls.setGraphicSize(Std.int(bgGirls.width * daPixelZoom));
					bgGirls.updateHitbox();
					add(bgGirls);

					stageBeat = function():Void bgGirls.dance();
					gfVersion = 'gf-pixel';
				}
			case 'thorns':
				{
					curStage = 'schoolEvil';

					var bg = new BGSprite(['weeb/animatedEvilSchool', 'week6'], [PIXEL], 400, 200, 0.8, 0.9, [{name: 'background 2', loop: true}]);
					bg.scale.set(6, 6);
					add(bg);
					gfVersion = 'gf-pixel';
				}
			case 'rhythm-report', 'questionnaire', 'ringside':
				{
					curStage = 'ringsidee';
					defaultCamZoom = 0.2;

					var reporterBG = new FlxSprite(-6003.5, -276.5);
					reporterBG.frames = Paths.getSparrowAtlas('reporterBG', 'rhythm');
					reporterBG.animation.addByPrefix('bg', 'BGReporter', 0, false);
					reporterBG.animation.play('bg');
					reporterBG.active = false;
					reporterBG.antialiasing = getPref('antialiasing');
					reporterBG.setGraphicSize(Std.int(reporterBG.width * 1.35));
					add(reporterBG);

					var flashit = new FlxSprite(2435, 7721);
					flashit.frames = Paths.getSparrowAtlas('CameraFlashes', 'rhythm');
					flashit.animation.addByPrefix('flash', 'CameraFlashes', 24, false);
					flashit.antialiasing = getPref('antialiasing');
					flashit.scrollFactor.set();
					flashit.visible = false;
					flashit.animation.finishCallback = function(name:String)
					{
						flashit.visible = false;
					}
					flashit.cameras = [camHUD];
					flashit.screenCenter();

					var bgCharDance = new FlxSprite(-73, 643);
					bgCharDance.frames = Paths.getSparrowAtlas('BGCharDance', 'rhythm');
					bgCharDance.animation.addByPrefix('bop', 'BGCharDance', 24, false);
					bgCharDance.animation.addByPrefix('pftf', 'BGCharCamera', 24, false);
					bgCharDance.animation.play('bop');
					bgCharDance.antialiasing = getPref('antialiasing');
					bgCharDance.animation.finishCallback = function(name:String)
					{
						if (name == 'pftf')
						{
							new FlxTimer().start(0.5, function(tmr:FlxTimer)
							{
								new FlxTimer().start(1.5, function(_)
								{
									bgCharDance.animation.play('bop', true);
									bgCharDance.offset.set(0, 0);
									defaultCamZoom = 0.55;
								});
								camGame.flash(FlxColor.WHITE, 2, null, true);
								new FlxTimer().start(0.35, function(tmr:FlxTimer)
								{
									flashit.visible = true;
									flashit.animation.play('flash');
								});
							});
						}
					}
					stageBeat = function():Void
					{
						if (bgCharDance.animation.curAnim.name != 'pftf')
						{
							bgCharDance.animation.play('bop', true);
							bgCharDance.offset.set(0, 0);
						}
					}

					stageUpdate = function(elapsed:Float):Void
					{
						if (dad.curCharacter == 'reporter' && startedSong)
						{
							if (dad.animSuffix == '')
							{
								if (healthBar.percent < 20)
									dad.animSuffix = '-disgust';
							}
							else if (dad.animSuffix == '-disgust')
							{
								if (!(healthBar.percent < 20))
									dad.animSuffix = '';
							}
						}
						if (bgCharDance.animation.curAnim.name == 'pftf')
							vocals.volume = 1;
					}

					afterAddALL = function()
					{
						dad.setNewSize(0.589844);
						boyfriend.setNewSize(2.589844);
						dad.setPosition(-284.5, -260);
						boyfriend.setPosition(1040.5, 224);
						add(bgCharDance);
						if (getPref('flashing-menu'))
							add(flashit);
					}

					stageStep = function()
					{
						switch (SONG.song.toLowerCase())
						{
							case 'ringside':
								switch (curStep)
								{
									case 1:
										dad.playAnim('singTRUE');
								}
						}
					}
					switch (SONG.song.toLowerCase())
					{
						case 'ringside':
							for (i in [677, 3333])
							{
								if (vocals != null)
									vocals.volume = 1;
								if (vocals != null)
									vocals.volume = 1;
								addSquizzleFunc(i - 12312, function() // pose for the fans shit
								{
									bgCharDance.animation.play('pftf');
									defaultCamZoom = 0.5;
									bgCharDance.offset.set(-9, 330);
								});
							}
					}
					if (curSong == 'ringside' && isStoryMode)
						addSquizzleFunc(20293, function()
						{
							camNOTES.fade(FlxColor.WHITE, 1, false, function()
							{
								FlxG.sound.music.pause();
								FlxG.sound.music.stop();
								FlxG.sound.music.volume = 0;
								vocals.pause();
								vocals.stop();
								vocals.volume = 0;

								inCutscene = true;
								var video = new MP4Sprite();

								video.finishCallback = function()
								{
									camOTHER.fade(FlxColor.BLACK, 1, false, function()
									{
										endSong();
									});
									setPref('ratio-unlocked', true);
								};
								video.playVideo(Paths.video('FNRCutscene4'), false, false);
								video.cameras = [camOTHER];
								add(video);
							});
						});
				}
			case 'ratio':
				{
					curStage = 'gay-go';
					defaultCamZoom = 0.1;
					var stageFill:FlxSprite = new FlxSprite().makeGraphic(Std.int(FlxG.width * 2), Std.int(FlxG.height * 1), 0xFFf5ece7); // dont ask
					stageFill.screenCenter(X);
					stageFill.y = -500;
					var stageFillWeird:FlxSprite = new FlxSprite().makeGraphic(Std.int(FlxG.width * 7), Std.int(FlxG.height * 4), 0xFF050021); // dont ask
					stageFillWeird.screenCenter(X);
					stageFillWeird.y = -500;
					stageFillWeird.visible = false;
					add(stageFillWeird);
					var gamerGoBG = new FlxSprite(-2000, -200);
					gamerGoBG.frames = Paths.getSparrowAtlas('squizzle/GamerGoBG', 'rhythm');
					gamerGoBG.animation.addByPrefix('idle', 'GamerGoBG', 0, false);
					gamerGoBG.animation.play('idle');
					gamerGoBG.antialiasing = getPref('antialiasing');
					gamerGoBG.active = false;
					add(gamerGoBG);
					add(stageFill);

					var gamerGhoul = new FlxSprite(500, 100, Paths.image('squizzle/gamerGhoul', 'rhythm'));
					gamerGhoul.active = false;
					gamerGhoul.setPosition(40, 700); // mas y es mas abajo
					add(gamerGhoul);

					var brossBop = new FlxSprite(1000, 165); // its meeeeeeeeee :D
					brossBop.frames = Paths.getSparrowAtlas('squizzle/BrossBop', 'rhythm');
					brossBop.animation.addByPrefix('bop', 'BrossBop0', 24, false);
					brossBop.animation.addByPrefix('bop disgusted', 'BrossBop disgusted', 24, false);
					brossBop.animation.play('bop');
					brossBop.antialiasing = getPref('antialiasing');

					afterAddGF = function()
					{
						add(brossBop);
					}
					afterAddALL = function()
					{
						dad.setNewSize(1.908907);
						boyfriend.setNewSize(0.349027);
						gf.setNewSize(2.356018);
						dad.setPosition(-299, 166);
						boyfriend.setPosition(644, 532);
						gf.setPosition(-366, 216);

						dad.animation.finishCallback = function(name:String)
						{
							switch (name)
							{
								case 'sing321':
									dad.playAnim('singSCREAM');
								case 'singPENIS':
									stageBeat(); // reset boppers anim
							}
						}
					}

					stageBeat = function()
					{
						{
							new FlxTimer().start(1.2, function(tmr:FlxTimer)
							{
								brossBop.animation.play('bop', true);
								brossBop.offset.set(0, 0);
							});
						}
					}

					gfVersion = 'chango';

					addSquizzleFunc(23 /*17794*/, function() // 1 2 3 AAAAA
					{
						dad.playAnim('sing321');
					});

					addSquizzleFunc(535, function() // penis haha funny
					{
						dad.playAnim('singPENIS');
					});

					addSquizzleFunc(12, function() // penis haha funny
					{
						gf.playAnim('disgust');
						brossBop.animation.play('bop disgusted');
						brossBop.offset.set(6, 0);
					});

					addSquizzleFunc(79771, function() // BRUH
					{
						dad.playAnim('singBRUH');
					});

					addSquizzleFunc(89981 + 25900, function() // OH NONONO
					{
						dad.playAnim('singOHNONO');
					});

					addSquizzleFunc(99888, function() // AAAAAAAA
					{
						dad.playAnim('singSCREAM');
					});

					addSquizzleFunc(100305, function() // Pixel guy home cumming
					{
						defaultCamZoom = 0.6;
						stageFillWeird.visible = true;
						stageFill.visible = false;
						camNOTES.flash(FlxColor.WHITE, 1);
						camGame.flash(FlxColor.WHITE, 1.5);
						dad.animSuffix = '-pixel';
						remove(boyfriend);

						boyfriend = new Character(770, 450, 'bf-dizzle-pixel', bfArgs, true, !opponentMode);
						boyfriend.setGraphicSize(Std.int(boyfriend.width * (1.349243 * 7.5)));
						boyfriend.antialiasing = false;
						boyfriend.updateHitbox();
						boyfriend.width -= 100;
						boyfriend.height -= 100;
						dad.antialiasing = false;
						dad.y += 200;
						boyfriend.setPosition(750, 810);
						dad.setPosition(dad.x -= 40, dad.y);
						add(boyfriend);

						iconP1.changeIcon('bf-dizzle-pixel');
						iconP2.changeIcon('dizzle-spirit');
						healthBar.createFilledBar(HealthIconsData.getIconColor(iconP2.char), HealthIconsData.getIconColor(iconP1.char));
						healthBar.updateFilledBar();

						isPixel = true;
						playerStrums.forEach(function(spr:BabyArrow) playerStrums.remove(spr));
						opponentStrums.forEach(function(spr:BabyArrow) opponentStrums.remove(spr));
						strumLineNotes.forEach(function(spr:BabyArrow) strumLineNotes.remove(spr));
						generateStaticArrows(0, 'pixel-dizzle', false);
						generateStaticArrows(1, 'pixel-dizzle', false);
						gf.visible = false;
						gf.active = gf.visible;
						brossBop.visible = false;
						brossBop.active = brossBop.visible;
						gamerGhoul.visible = true;
						gamerGoBG.visible = false;
					});
					addSquizzleFunc(140541, function() // Pixel guy no way home uncumming
					{
						camNOTES.flash(FlxColor.WHITE, 3);
						camGame.flash(FlxColor.WHITE, 3.5);
					});

					addSquizzleFunc(140741, function() // Pixel guy no way home uncumming
					{
						defaultCamZoom = 0.65;
						stageFillWeird.visible = false;
						stageFill.visible = true;

						dad.animSuffix = '';
						remove(boyfriend);

						boyfriend = new Character(770, 450, 'bf', bfArgs, true, !opponentMode);
						boyfriend.setNewSize(1.349243);
						boyfriend.antialiasing = getPref('antialiasing');
						boyfriend.setPosition(644, 532);
						dad.antialiasing = getPref('antialiasing');
						dad.y -= 200;
						add(boyfriend);

						iconP1.changeIcon('bf');
						iconP2.changeIcon('dizzle');
						healthBar.createFilledBar(HealthIconsData.getIconColor(iconP2.char), HealthIconsData.getIconColor(iconP1.char));
						healthBar.updateFilledBar();

						isPixel = false;
						playerStrums.forEach(function(spr:BabyArrow) playerStrums.remove(spr));
						opponentStrums.forEach(function(spr:BabyArrow) opponentStrums.remove(spr));
						strumLineNotes.forEach(function(spr:BabyArrow) strumLineNotes.remove(spr));
						generateStaticArrows(0, null, false);
						generateStaticArrows(1, null, false);
						gf.visible = true;
						gf.active = gf.visible;
						brossBop.visible = true;
						brossBop.active = brossBop.visible;
						gamerGhoul.visible = false;
						gamerGoBG.visible = true;
					});
				}
		}
	}

	var oldHealthBarPercent = 0;
	var maxBF_X:Int = 0;
	var maxBF_Y:Int = 0;
	var isPixel:Bool = false;
	var squizzleFuncsArray = new Array<SongEvent>();
	var squizzleFuncsCompleted = new Array<Float>();

	function addSquizzleFunc(time:Float, func:Void->Void)
		squizzleFuncsArray.push({
			time: time,
			func: function()
			{
				func();
				trace(time);
				squizzleFuncsCompleted.push(time);
			}
		});

	public static var isAloneFunkin:Bool = false;
	public static var songPath:String = '';

	public static function loadSong(song:String, week:Int, wColor:FlxColor, isStory:Bool, ?stopMusic:Bool = false, ?usePATH:Bool = false,
			?wasStorySong:Bool = false):Void
	{
		if (!usePATH)
		{
			var splited:Array<String> = song.split('-');
			var diff = splited[splited.length - 1];
			splited.remove(diff);
			var songFOLDER = splited.join('-');
			var songJSON:String = song;
			if (!songJSON.contains('-normal'))
				SONG = Song.loadFromJson(songJSON, songFOLDER);
			else
				SONG = Song.loadFromJson(songJSON.replace('-normal', ''), songFOLDER);

			@:privateAccess
			for (i in CoolUtil.difficultyArray)
			{
				if (i[0] == diff.toUpperCase())
					curDifficulty = CoolUtil.difficultyArray.indexOf(i);
			}
			songPath = '';

			if (isStory)
				PlayState.stateToBack = StoryMenuState;
			else
				PlayState.stateToBack = FreeplayState;
		}
		else
		{
			#if ALLOW_ALONE_FUNKIN
			songPath = song;
			SONG = Song.loadFromJsonFILE(song);
			curDifficulty = 1;
			PlayState.stateToBack = AloneFunkinState;
			#end
		}

		weekColor = wColor;

		isAloneFunkin = usePATH;
		isStoryMode = isStory;
		curWeek = week;
		seenCutscene = false;

		if (!wasStorySong)
			resetPlayState(false);
		LoadingState.loadAndSwitchState(PlayState, stopMusic);
	}

	var charTarget:Int = 0;

	#if debug
	inline function debugToolsCheck():Void
	{
		/**
		 * Q/E: ZOOM IN/OUT
		 * U/I: ADD/REMOVE HEALTH
		 * B: TRACE curBeat
		 * N: TRACE curStep
		 * MOUSE WHEEL CLICK: HIDE/SHOW HUD AND NOTES
		 * H: HIDE/SHOW THIS MESSAGE
		 */

		if (checkKey('ONE'))
			endSong();

		if (checkKey('Q', PRESSED))
			defaultCamZoom += .025;
		if (checkKey('E', PRESSED))
			defaultCamZoom -= .025;

		if (checkKey('U'))
			health += .25;
		if (checkKey('I'))
			health -= .25;

		if (checkKey('B'))
			trace('curBeat: $curBeat');
		if (checkKey('N'))
			trace('curStep: $curStep');

		// 		if (checkKey('M'))
		// 		{
		// 			switch (charTarget)
		// 			{
		// 				case 0:
		// 					dad.setPosition(FlxG.mouse.x, FlxG.mouse.y);
		// 				case 1:
		// 					boyfriend.setPosition(FlxG.mouse.x, FlxG.mouse.y);
		// 				case 2:
		// 					gf.setPosition(FlxG.mouse.x, FlxG.mouse.y);
		// 			}
		// 		}

		// 		if (checkKey('K'))
		// 		{
		// 			charTarget++;
		// 			if (charTarget > 2)
		// 				charTarget = 0;
		// 			if (charTarget < 0)
		// 				charTarget = 2;
		// 		}

		// 		if (checkKey('J'))
		// 			trace('
		// dad: ${dad.x}, ${dad.y}
		// boyfriend: ${boyfriend.x}, ${boyfriend.y}
		// gf: ${gf.x}, ${gf.y}
		// 		');

		if (checkKey('H'))
			debugTxt.visible = !debugTxt.visible;

		if (checkKey('F7'))
			Console.open(checkSettingsInGame);

		#if FLX_MOUSE
		if (FlxG.mouse.justPressedMiddle)
		{
			camHUD.visible = !camHUD.visible;
			camNOTES.visible = camHUD.visible;
			camBACKGROUND_OPACITY.visible = camHUD.visible;
		}
		#end
	}
	#end

	function deathAnim(wasRestart:Bool):Void
	{
		persistentUpdate = false;
		persistentDraw = false;
		paused = true;
		vocals.stop();
		if (FlxG.sound.music != null)
			FlxG.sound.music.stop();

		if (!wasRestart)
			deathCounter++;

		openSubState(new GameOverSubstate(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));

		#if (windows && cpp)
		DiscordClient.changePresence("Game Over - " + detailsText, SONG.song + " (" + curDifficultyText + ")", iconRPC);
		#end
	}

	public function checkSettingsInGame(firstTime:Bool, fadeInStrums:Bool):Void
	{
		camZooming = curSong != 'tutorial' && getPref('camera-zoom');
		camNOTES.flashSprite.scaleY = getPref('downscroll') ? -1 : 1;

		if (getPref('downscroll'))
			healthBarBG.y = 0.1 * FlxG.height;
		else
			healthBarBG.y = FlxG.height * 0.9;

		healthBar.y = healthBarBG.y + 4;
		scoreTxt.y = healthBarBG.y + 36;

		iconP1.y = healthBar.y - (iconP1.height / 2);
		iconP2.y = healthBar.y - (iconP2.height / 2);

		blackscreenMidScroll.visible = getPref('midscroll');
		blackscreenMidScroll.alpha = getPref("background-opacity");
		blackscreen1.alpha = getPref("background-opacity");
		blackscreen1.visible = !getPref('midscroll');
		blackscreen2.alpha = getPref("background-opacity");
		blackscreen2.visible = !getPref('midscroll');

		playerStrums.forEach(function(spr:BabyArrow) playerStrums.remove(spr));
		opponentStrums.forEach(function(spr:BabyArrow) opponentStrums.remove(spr));
		strumLineNotes.forEach(function(spr:BabyArrow) strumLineNotes.remove(spr));
		// notes.forEach(function(daNote:Note) daNote.loadNote());

		if (!firstTime)
		{
			generateStaticArrows(0, null, fadeInStrums);
			generateStaticArrows(1, null, fadeInStrums);
		}

		if (barraGrisMidscroll != null)
			barraGrisMidscroll();

		// notes.forEachAlive(function(note:Note) note.loadFrames());
	}

	public static function exit():Void
	{
		var args = [];
		if (stateToBack == FreeplayState)
			args.push(true);

		if (stateToBack == FreeplayState || stateToBack == StoryMenuState)
			args.push(curWeek <= 6);
		switchState(stateToBack, args);
	}

	var blackscreenMidScroll:FlxSprite;
	var blackscreen1:FlxSprite;
	var blackscreen2:FlxSprite;
} // ! matriculaso es el pepe

// ! peppy es un pro
// ! COMO DIJO UN NEGRO: FlxSprite.toLowerCase() == 'MILF'
typedef SongEvent =
{
	var time:Float;
	var func:Void->Void;
}
