package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import openfl.display.Shader;

using StringTools;

#if (windows && cpp)
import Discord.DiscordClient;
#end

class FreeplayState extends MusicBeatState
{
	var songs:Array<SongMetadata> = [];
	var vocals:FlxSound;
	var songPlaying:Int = -1;

	static var curSelected:Int = 0;
	static var curDifficulty:Int = 1;

	var scoreText:FlxText;
	var scoreBG:FlxSprite;
	var diffText:FlxText;
	var lerpScore:Int = 0;
	var intendedScore:Int = 0;
	var coolColors = [
		-7179779,
		-7179779,
		-14535868,
		-7072173,
		-223529,
		-6237697,
		-34625,
		0xFFed698a,
		0xFFfed189
	];
	var bg = new FlxSprite(-117.75, -75.75);
	var fromPlayState:Bool = false;
	var isGF:Bool = false;

	private var grpSongs:FlxTypedGroup<Alphabet>;
	private var curPlaying:Bool = false;

	private var iconArray:Array<HealthIcon> = [];

	public function new(?fromPlayState:Bool = false, ?isGF:Bool = false)
	{
		this.fromPlayState = fromPlayState;
		this.isGF = isGF;
		super();
	}

	override function create()
	{
		#if (windows && cpp)
		DiscordClient.changePresence("In the Menus", null);
		#end

		if (isGF)
		{
			bg = new MenuBG(DESAT);
			addWeek(['Tutorial'], 0, ['gf']);
			addWeek(['Bopeebo', 'Fresh', 'Dad-Battle'], 1, ['dad']);
			addWeek(['Spookeez', 'South', 'Monster'], 2, ['spooky', 'spooky', 'monster']);
			addWeek(['Pico', 'Philly-Nice', 'Blammed'], 3, ['pico']);
			addWeek(['Satin-Panties', 'High', 'M.I.L.F'], 4, ['mom']);
			addWeek(['Cocoa', 'Eggnog', 'Winter-Horrorland'], 5, ['parents-christmas', 'parents-christmas', 'monster-christmas']);
			addWeek(['Senpai', 'Roses', 'Thorns'], 6, ['senpai', 'senpai', 'spirit']);
			#if ALLOW_ALONE_FUNKIN
			addWeek(["Alone-Funkin'"], 7, ['']);
			#end
		}
		else
		{
			bg.frames = Paths.getSparrowAtlas('main-menu/desat-animated-background');
			bg.animation.addByPrefix('idle', 'animated background', 24, true);
			bg.animation.play('idle', true);
			addWeek(['Rhythm-Report', 'Questionnaire', 'Ringside'], 7, ['reporter']);
			// TODO: if unlocked
			if (getPref('ratio-unlocked'))
				addWeek(['Ratio'], 8, ['dizzle']);
		}
		bg.antialiasing = getPref('antialiasing');
		bg.color = coolColors[0];
		add(bg);

		grpSongs = new FlxTypedGroup<Alphabet>();
		add(grpSongs);

		for (i in 0...songs.length)
		{
			var songText = new Alphabet(0, (70 * i) + 30, songs[i].songName, true, true);
			songText.targetY = i;
			songText.ID = i;
			grpSongs.add(songText);

			var icon:HealthIcon = new HealthIcon(songs[i].songCharacter);
			icon.sprTracker = songText;

			iconArray.push(icon);
			if (songs[i].songCharacter != '')
				add(icon);
		}

		scoreText = new FlxText(0.7 * FlxG.width, 5, 0, "", 32);
		scoreText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		scoreText.borderSize = 1.5;

		scoreBG = new FlxSprite(scoreText.x - 6, 0).makeGraphic(1, 66, FlxColor.BLACK);
		scoreBG.antialiasing = (false);
		scoreBG.alpha = (0.6);
		add(scoreBG);

		diffText = new FlxText(scoreText.x, scoreText.y + 36, 0, "", 24);
		diffText.setFormat(Paths.font("vcr.ttf"), 24, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		diffText.borderSize = 1.5;
		add(diffText);

		add(scoreText);

		playBG = new FlxSprite(0, FlxG.height - 35).makeGraphic(FlxG.width, 35, FlxColor.BLACK);
		playBG.active = false;
		playBG.alpha = 0.6;
		add(playBG);

		playTxt = new FlxText(0, playBG.y, 0, langString('freeplayPlay'));
		playTxt.active = false;
		playTxt.setFormat(Paths.font("vcr.ttf"), 28, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		playTxt.screenCenter(X);
		add(playTxt);

		changeSelection();
		changeDiff();

		MusicManager.checkPlaying();
		if (fromPlayState)
			MusicManager.playMainMusic();

		#if mobileC
		playButton = new FlxVirtualPad(NONE, X);
		playButton.alpha = .65;
		playButton.y -= 50;
		add(playButton);
		#end

		super.create();
	}

	#if mobileC
	var playButton:FlxVirtualPad;
	#end

	var playBG:FlxSprite;
	var playTxt:FlxText;

	public function addSong(songName:String, weekNum:Int, songCharacter:String)
		songs.push(new SongMetadata(songName, weekNum, songCharacter));

	public function addWeek(songs:Array<String>, weekNum:Int, ?songCharacters:Array<String>)
	{
		if (songCharacters == null)
			songCharacters = ['bf'];

		var num:Int = 0;
		for (song in songs)
		{
			addSong(song, weekNum, songCharacters[num]);

			if (songCharacters.length != 1)
				num++;
		}
	}

	inline function positionHighscore():Void
	{
		scoreText.x = (FlxG.width - scoreText.width - 6);
		scoreBG.scale.x = (FlxG.width - scoreText.x + 6);
		scoreBG.x = (FlxG.width - scoreBG.scale.x / 2);
		diffText.x = (Std.int(scoreBG.x + scoreBG.width / 2));
		diffText.x = (diffText.x - diffText.width / 2);
	}

	function resyncVocals():Void
	{
		vocals.pause();
		FlxG.sound.music.play();
		vocals.time = FlxG.sound.music.time;
		vocals.play();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (FlxG.sound.music != null)
			if (FlxG.sound.music.volume < 0.7)
				FlxG.sound.music.volume += 0.5 * FlxG.elapsed;

		if (vocals != null)
			vocals.volume = FlxG.sound.music.volume;

		lerpScore = CoolUtil.coolLerp(lerpScore, intendedScore, 0.4);

		if (Math.abs(lerpScore - intendedScore) <= 10)
			lerpScore = intendedScore;

		// ninjamuffin color change sucks in windows lol
		// var color2 = coolColors[songs[curSelected].week % coolColors.length];
		// if (bg.color != color2)
		// 	bg.color = FlxColor.interpolate(bg.color, color2, CoolUtil.camLerpShit(.045));

		scoreText.text = '${langString('personalBest')}:' + lerpScore;
		positionHighscore();

		if (!exiting)
		{
			var up = false,
				down = false,
				left = false,
				right = false,
				accept = false,
				back = false,
				space = false;
			#if mobileC
			var touchOverlaps:Bool = false;

			#if FLX_TOUCH
			for (touch in FlxG.touches.list)
				if (touch.overlaps(playButton))
					touchOverlaps = true;
			#else
			#if FLX_MOUSE
			if (FlxG.mouse.overlaps(playButton))
				touchOverlaps = true;
			#end
			#end

			if (!touchOverlaps)
				for (swipe in FlxG.swipes)
				{
					var f = swipe.startPosition.x - swipe.endPosition.x;
					var g = swipe.startPosition.y - swipe.endPosition.y;
					if (25 <= Math.sqrt(f * f + g * g))
					{
						if ((-45 <= swipe.startPosition.angleBetween(swipe.endPosition)
							&& 45 >= swipe.startPosition.angleBetween(swipe.endPosition)))
							down = true;
						if (-135 < swipe.startPosition.angleBetween(swipe.endPosition)
							&& -45 > swipe.startPosition.angleBetween(swipe.endPosition))
							left = true;
						if (45 < swipe.startPosition.angleBetween(swipe.endPosition)
							&& 135 > swipe.startPosition.angleBetween(swipe.endPosition))
							right = true;
						if (-180 <= swipe.startPosition.angleBetween(swipe.endPosition)
							&& -135 >= swipe.startPosition.angleBetween(swipe.endPosition)
							|| 135 <= swipe.startPosition.angleBetween(swipe.endPosition)
							&& 180 >= swipe.startPosition.angleBetween(swipe.endPosition))
							up = true;
					}
					else
						accept = true;
				}
			if (MobileControls.androidBack)
				back = true;
			space = playButton.buttonX.justPressed;
			#else
			#if FLX_MOUSE
			for (item in grpSongs)
			{
				if ((FlxG.mouse.overlaps(item) || FlxG.mouse.overlaps(iconArray[grpSongs.members.indexOf(item)]))
					&& item.ID == curSelected
					&& FlxG.mouse.justPressed)
					accept = true;
			}
			#end
			up = controls.UI_UP_P #if FLX_MOUSE || FlxG.mouse.wheel == -1 #end;
			down = controls.UI_DOWN_P #if FLX_MOUSE || FlxG.mouse.wheel == 1 #end;
			left = controls.UI_LEFT_P;
			right = controls.UI_RIGHT_P;
			back = controls.BACK;
			accept = controls.ACCEPT;
			space = checkKey('SPACE');
			#end

			if (up)
				changeSelection(-1);
			if (down)
				changeSelection(1);

			if (left)
				changeDiff(-1);
			if (right)
				changeDiff(1);

			if (back)
				this.back();

			if (accept)
				enterSong();

			if (space && songPlaying != curSelected && songs[curSelected].songName != "Alone-Funkin'")
			{
				for (i in [playBG, playTxt])
					FlxTween.tween(i, {y: FlxG.height}, 0.25, {ease: FlxEase.bounceOut});
				#if mobileC
				if (playButton != null)
					FlxTween.tween(playButton, {y: FlxG.height}, 0.25, {ease: FlxEase.bounceOut});
				#end
				previewSong(curSelected, false);
			}
		}
	}

	function back():Void
	{
		exiting = true;
		if (songPlaying != -1)
		{
			vocals.fadeOut(.25, 0);
			FlxG.sound.music.fadeOut(.25, 0, function(twn:FlxTween)
			{
				MusicManager.playMainMusic(0);
				FlxG.sound.music.fadeIn(.25, 0, 1);
				FlxTween.cancelTweensOf(bg);
				switchState(MainMenuState);
			});
		}
		else
		{
			FlxTween.cancelTweensOf(bg);
			switchState(MainMenuState);
		}
	}

	var exiting:Bool = false;

	function previewSong(songINT:Int, fromFinish:Bool):Void
	{
		if (vocals != null)
		{
			vocals.stop();
			vocals.volume = 0;
			vocals.destroy();
		}
		songPlaying = songINT;

		FlxG.sound.music.loadEmbedded(Paths.inst(songs[songINT].songName), false, false, function()
		{
			previewSong(songPlaying, true);
		});
		FlxG.sound.music.volume = 0;
		FlxG.sound.music.play(false, !fromFinish ? FlxG.sound.music.length / 2 : 0);

		vocals = new FlxSound().loadEmbedded(Paths.voices(songs[songINT].songName));
		vocals.volume = 0;
		vocals.play(false, FlxG.sound.music.time);
		FlxG.sound.list.add(vocals);
		new FlxTimer().start(0.1, function(tmr:FlxTimer)
		{
			resyncVocals();
		});
	}

	function enterSong():Void
	{
		if (vocals != null)
			vocals.fadeOut(.25, 0);
		FlxG.sound.music.fadeOut(.25, 0, function(twn:FlxTween)
		{
			FlxTween.cancelTweensOf(bg);
			switch (songs[curSelected].songName.toLowerCase())
			{
				#if ALLOW_ALONE_FUNKIN
				case 'alone-funkin\'':
					switchState(AloneFunkinState);
				#end
				default:
					PlayState.loadSong(CoolUtil.formatSong(songs[curSelected].songName.toLowerCase(), curDifficulty), songs[curSelected].week,
						coolColors[songs[curSelected].week], false);
			}
		});
	}

	function changeDiff(change:Int = 0)
	{
		curDifficulty += change;

		if (curDifficulty < 0)
			curDifficulty = 2;
		if (curDifficulty > 2)
			curDifficulty = 0;

		#if !switch
		intendedScore = Highscore.getScore(songs[curSelected].songName, curDifficulty);
		#end

		diffText.text = '< ${CoolUtil.getDiffName(curDifficulty, false)} >';
		FlxTween.color(diffText, CoolUtil.camLerpShit(.45), diffText.color, CoolUtil.difficultyColorArray[curDifficulty]);
		positionHighscore();
	}

	function changeSelection(change:Int = 0, force:Bool = false)
	{
		if (change != 0)
			FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
		curSelected += change;

		if (curSelected < 0)
			curSelected = songs.length - 1;
		if (curSelected >= songs.length)
			curSelected = 0;

		if (force)
			change = curSelected;

		FlxTween.color(bg, CoolUtil.camLerpShit(.25), bg.color, coolColors[songs[curSelected].week]);
		if (songPlaying == curSelected || songs[curSelected].songName == "Alone-Funkin'")
			for (i in [playBG, playTxt])
				FlxTween.tween(i, {y: FlxG.height}, 0.25, {ease: FlxEase.bounceOut});
		else
			for (i in [playBG, playTxt])
				FlxTween.tween(i, {y: FlxG.height - 35}, 0.25, {ease: FlxEase.bounceOut});

		// selector.y = (70 * curSelected) + 30;

		#if !switch
		intendedScore = Highscore.getScore(songs[curSelected].songName, curDifficulty);
		// lerpScore = 0;
		#end

		var bullShit:Int = 0;

		for (i in 0...iconArray.length)
			iconArray[i].alpha = 0.6;

		iconArray[curSelected].alpha = 1;

		for (item in grpSongs.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;

			item.alpha = 0.6;

			if (item.targetY == 0)
				item.alpha = 1;
		}
	}
}

class SongMetadata
{
	public var songName:String = "";
	public var week:Int = 0;
	public var songCharacter:String = "";

	public function new(song:String, week:Int, songCharacter:String)
	{
		this.songName = song;
		this.week = week;
		this.songCharacter = songCharacter;
	}
}
