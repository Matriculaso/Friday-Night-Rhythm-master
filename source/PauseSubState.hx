package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;

class PauseSubState extends MusicBeatSubstate
{
	var grpMenuShit:FlxTypedGroup<Alphabet>;

	var animationDebugMenu = false;
	var menuItems:Array<String> = [''];
	var pauseOG = [
		langString('pauseOG')[0],
		langString('pauseOG')[1],
		langString('pauseOG')[2],
		langString('pauseOG')[3],
		langString('pauseOG')[4],
		#if debug 'Animation Debug', 'Chart Editor',
		#end
		langString('pauseOG')[5],
		langString('pauseOG')[6]
	];
	#if debug
	var characterList = [
		PlayState.dad.curCharacter,
		PlayState.gf.curCharacter,
		PlayState.boyfriend.curCharacter,
		'BACK'
	];
	var grpIconShit:FlxTypedGroup<HealthIcon>;
	#end
	var practiceText:FlxText;
	var difficultyChoices = [];
	var curSelected:Int = 0;

	var pauseMusic:FlxSound;

	var fromOptions:Bool = false;

	public function new(x:Float, y:Float, ?_fromOptions:Bool = false)
	{
		super();
		fromOptions = _fromOptions;
		for (i in SongsData.getSongDiffies(curSong))
			difficultyChoices.push(CoolUtil.getDiffPause(i));

		difficultyChoices.push(langString('back'));
		pauseOG.remove(langString('pauseOG')[2]);
		if (SongsData.getSongDiffies(curSong).length == 1)
			pauseOG.remove(langString('pauseOG')[3]);
		menuItems = pauseOG;

		pauseMusic = new FlxSound().loadEmbedded(Paths.music('breakfast'), true, true);
		pauseMusic.volume = 0;
		pauseMusic.play(false, FlxG.random.float(0, pauseMusic.length / 2));

		FlxG.sound.list.add(pauseMusic);

		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		bg.alpha = 0;
		bg.scrollFactor.set();
		add(bg);

		var levelInfo = new FlxText(20, 15, 0, "", 32);
		levelInfo.text += prettySong;
		levelInfo.scrollFactor.set();
		levelInfo.setFormat(Paths.font("vcr.ttf"), 32);
		levelInfo.updateHitbox();
		add(levelInfo);

		var levelDifficulty = new FlxText(20, 47, 0, "", 32);
		levelDifficulty.text += CoolUtil.getDiffName(PlayState.curDifficulty, PlayState.isAloneFunkin);
		levelDifficulty.scrollFactor.set();
		levelDifficulty.setFormat(Paths.font('vcr.ttf'), 32);
		levelDifficulty.updateHitbox();
		add(levelDifficulty);

		var levelDeaths = new FlxText(20, 79, 0, "", 32);
		levelDeaths.text += "Blue balled: " + PlayState.deathCounter;
		levelDeaths.scrollFactor.set();
		levelDeaths.setFormat(Paths.font('vcr.ttf'), 32);
		levelDeaths.updateHitbox();
		add(levelDeaths);

		var levelAvanced = new FlxText(20, 30 + 96, 0, "", 32);
		levelAvanced.text += 'Playing VS ${CharactersData.characterNames[PlayState.dad.curCharacter]} ${StagesData.stageNames[PlayState.curStage]}';
		levelAvanced.scrollFactor.set();
		levelAvanced.setFormat(Paths.font('vcr.ttf'), 32);
		levelAvanced.updateHitbox();
		// add(levelAvanced);

		practiceText = new FlxText(20, 111, 0, langString('practiceMode'), 32);
		practiceText.scrollFactor.set();
		practiceText.setFormat(Paths.font('vcr.ttf'), 32);
		practiceText.updateHitbox();
		practiceText.x = (FlxG.width - (practiceText.width + 20));
		practiceText.set_visible(PlayState.practiceMode);
		add(practiceText);

		levelDifficulty.alpha = 0;
		levelInfo.alpha = 0;
		levelDeaths.alpha = 0;
		levelAvanced.alpha = 0;

		levelInfo.x = FlxG.width - (levelInfo.width + 20);
		levelDifficulty.x = FlxG.width - (levelDifficulty.width + 20);
		levelDeaths.x = FlxG.width - (levelDeaths.width + 20);
		levelAvanced.x = FlxG.width - (levelAvanced.width + 20);

		FlxTween.tween(bg, {alpha: 0.6}, 0.4, {ease: FlxEase.quartInOut});
		FlxTween.tween(levelInfo, {alpha: 1, y: 20}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.3});
		FlxTween.tween(levelDifficulty, {alpha: 1, y: levelDifficulty.y + 5}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.5});
		FlxTween.tween(levelDeaths, {alpha: 1, y: levelDeaths.y + 5}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.7});

		grpMenuShit = new FlxTypedGroup<Alphabet>();
		add(grpMenuShit);
		#if debug
		grpIconShit = new FlxTypedGroup<HealthIcon>();
		add(grpIconShit);
		#end
		regenMenu();

		if (fromOptions)
		{
			curSelected = menuItems.indexOf(langString('pauseOG')[5]);
			changeSelection();
		}

		cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];
	}

	var lastSelected:Int;

	override function update(elapsed:Float)
	{
		if (pauseMusic.volume < 0.5)
			pauseMusic.volume += 0.01 * elapsed;

		super.update(elapsed);

		var up = false, down = false, accept = false, back = false;
		#if mobileC
		for (swipe in FlxG.swipes)
		{
			var f = swipe.startPosition.x - swipe.endPosition.x;
			var g = swipe.startPosition.y - swipe.endPosition.y;
			if (25 <= Math.sqrt(f * f + g * g))
			{
				if ((-45 <= swipe.startPosition.angleBetween(swipe.endPosition)
					&& 45 >= swipe.startPosition.angleBetween(swipe.endPosition)))
					down = true;
				if (-180 <= swipe.startPosition.angleBetween(swipe.endPosition)
					&& -135 >= swipe.startPosition.angleBetween(swipe.endPosition)
					|| (135 <= swipe.startPosition.angleBetween(swipe.endPosition)
						&& 180 >= swipe.startPosition.angleBetween(swipe.endPosition)))
					up = true;
			}
			else
				accept = true;
		}
		if (MobileControls.androidBack)
			back = true;
		#else
		up = controls.UI_UP_P #if FLX_MOUSE || FlxG.mouse.wheel == -1 #end;
		down = controls.UI_DOWN_P #if FLX_MOUSE || FlxG.mouse.wheel == 1 #end;
		back = controls.BACK;
		accept = controls.ACCEPT;
		#end
		if (up)
			changeSelection(-1);
		if (down)
			changeSelection(1);

		#if FLX_MOUSE
		for (item in grpMenuShit)
		{
			if (FlxG.mouse.overlaps(item) && item.ID == curSelected && FlxG.mouse.justPressed)
				accept = true;
		}
		#end

		if (accept)
			this.accept();
		if (back)
			resumeSelected();
	}

	function accept():Void
	{
		var daSelected:String = menuItems[curSelected];
		switch (daSelected)
		{
			case "Resume", 'Continuar':
				resumeSelected();
			case "Restart Song", 'Reiniciar Cancion':
				FlxG.resetState();
			case 'Skip Song', "Saltar Cancion":
				close();
				PlayState.instance.endSong();
			case 'Change Difficulty', "Cambiar Dificultad":
				lastSelected = curSelected;
				menuItems = difficultyChoices;
				regenMenu();
			case 'EASY', 'FACIL':
				PlayState.loadSong('${PlayState.SONG.song.toLowerCase()}-easy', PlayState.curWeek, PlayState.weekColor, PlayState.isStoryMode, true);
			case 'NORMAL':
				PlayState.loadSong('${PlayState.SONG.song.toLowerCase()}-normal', PlayState.curWeek, PlayState.weekColor, PlayState.isStoryMode, true);
			case 'HARD':
				PlayState.loadSong('${PlayState.SONG.song.toLowerCase()}-hard', PlayState.curWeek, PlayState.weekColor, PlayState.isStoryMode, true);
			case 'Toggle Practice Mode', "Alternar modo practica":
				PlayState.practiceMode = !PlayState.practiceMode;
				practiceText.set_visible(PlayState.practiceMode);
			#if debug
			case 'Animation Debug':
				lastSelected = curSelected;
				menuItems = characterList;
				regenMenu(true);
			case 'Chart Editor':
				switchState(ChartingState);
			#end
			case 'Options', "Opciones":
				FlxG.state.openSubState(new PreferencesMenu(true));
			case "Exit to menu", "Salir al menu":
				PlayState.exit();
			case 'BACK', 'ATRAS':
				menuItems = pauseOG;
				regenMenu();
				curSelected = lastSelected;
				changeSelection();
			default:
				if (animationDebugMenu)
				{
					switch (curSelected)
					{
						case 0:
							switchState(AnimationDebug, [PlayState.dad.curCharacter, true]);
						case 1:
							switchState(AnimationDebug, [PlayState.gf.curCharacter, true]);
						case 2:
							switchState(AnimationDebug, [PlayState.boyfriend.curCharacter, false]);
					}
				}
		}
	}

	override function destroy()
	{
		pauseMusic.destroy();

		super.destroy();
	}

	function changeSelection(change:Int = 0):Void
	{
		curSelected += change;
		if (change != 0)
			FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

		if (curSelected < 0)
			curSelected = menuItems.length - 1;
		if (curSelected >= menuItems.length)
			curSelected = 0;

		var bullShit:Int = 0;

		for (item in grpMenuShit.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;

			item.alpha = 0.6;
			// item.setGraphicSize(Std.int(item.width * 0.8));

			if (item.targetY == 0)
			{
				item.alpha = 1;
			}
		}

		#if debug
		for (item in grpIconShit.members)
		{
			item.alpha = 0.6;
			if (item.ID == curSelected)
				item.alpha = 1;
		}
		#end
	}

	function regenMenu(animDebug = false):Void
	{
		animationDebugMenu = animDebug;
		for (i in 0...grpMenuShit.members.length)
			grpMenuShit.remove(grpMenuShit.members[0], true);

		#if debug
		for (i in 0...grpIconShit.members.length)
			grpIconShit.remove(grpIconShit.members[0], true);
		#end

		for (i in 0...menuItems.length)
		{
			var songText = new Alphabet(0, (70 * i) + 30, menuItems[i], false, true);
			songText.targetY = i;
			songText.ID = i;
			songText.type = [IGNORE_X];
			grpMenuShit.add(songText);

			#if debug
			if (animDebug && songText.text != 'BACK')
			{
				var icon = new HealthIcon(characterList[i]);
				icon.ID = i;
				icon.sprTracker = songText;
				grpIconShit.add(icon);
			}
			#end
		}
		curSelected = 0;
		changeSelection();
	}

	function resumeSelected():Void
	{
		close();
		if (fromOptions)
			PlayState.instance.checkSettingsInGame(false, false);
	}
}
