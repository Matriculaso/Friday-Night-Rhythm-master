package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.effects.FlxFlicker;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;

class StoryMenuState extends MusicBeatState
{
	var save = 'bf';
	var weeks:Array<WeekData.WeekClass> = [];
	var isGF = false;

	public function new(_isGF:Bool = true)
	{
		isGF = _isGF;
		if (isGF)
			save = 'gf';
		super();
	}

	var weekItems:FlxTypedGroup<FlxSprite>;
	var diffItems:FlxTypedGroup<FlxSprite>;

	var selectorSpriteWeeks:FlxSprite;
	var selectorSpriteDiffs:FlxSprite;

	override function create()
	{
		for (weekNum in 0...WeekData.Weeks.weeksSongs.length)
		{
			var length = WeekData.Weeks.weeksSongs.length;
			while (length > WeekData.Weeks.weeksNames.length)
				WeekData.Weeks.weeksNames.push('Unknowned Week Name');

			while (length > WeekData.Weeks.librariesNames.length)
				WeekData.Weeks.librariesNames.push('tutorial');

			while (length > WeekData.Weeks.weeksFiles.length)
				WeekData.Weeks.weeksFiles.push('tutorial');

			while (length > WeekData.Weeks.weeksCharacters.length)
				WeekData.Weeks.weeksCharacters.push('dad');

			while (length > WeekData.Weeks.weeksColors.length)
				WeekData.Weeks.weeksColors.push(-7179779);

			weeks.push({
				weekFile: WeekData.Weeks.weeksFiles[weekNum],
				weekName: WeekData.Weeks.weeksNames[weekNum],
				weekCharacter: WeekData.Weeks.weeksCharacters[weekNum],
				library: WeekData.Weeks.librariesNames[weekNum],
				weekSongs: WeekData.Weeks.weeksSongs[weekNum],
				weekColor: WeekData.Weeks.weeksColors[weekNum]
			});
		}
		MusicManager.checkPlaying();
		var bg = new FlxSprite();
		bg.frames = Paths.getSparrowAtlas('main-menu/desat-animated-background');
		bg.animation.addByPrefix('idle', 'animated background', 24, true);
		bg.animation.play('idle', true);
		bg.antialiasing = getPref('antialiasing');
		bg.color = HealthIconsData.getIconColor(isGF ? 'gf' : 'bf'); // 0xFF73ff8a
		add(bg);

		weekItems = new FlxTypedGroup<FlxSprite>();
		add(weekItems);
		diffItems = new FlxTypedGroup<FlxSprite>();
		add(diffItems);
		for (i in 0...200)
		{
			var weekItem = new FlxSprite(0, 0);
			weekItem.x += 50 * (i / 5).int();
			weekItem.y += 50 * (i % 5);
			weekItem.frames = Paths.getSparrowAtlas('main-menu/story-$save-weeks');
			weekItem.animation.addByPrefix('week0', 'week0', 0, false);
			weekItem.ID = i;
			if (isGF)
			{
				for (i in 1...7)
					weekItem.animation.addByPrefix('week$i', 'week$i', 0, false);
			}
			else
			{
				weekItem.animation.addByPrefix('week1', 'week1', 0, false);
			}
			weekItem.animation.addByPrefix('weekLock', 'weekLock', 0, false);
			weekItem.animation.addByPrefix('week?', 'week?', 0, false);
			if (weekItem.animation.getByName('week$i') != null)
			{
				weekItem.animation.play('week$i');
				weekItem.animation.play('weekLock');
			}
			else
				weekItem.animation.play('week?');
			weekItem.antialiasing = getPref('antialiasing');
			weekItems.add(weekItem);
			var goForAPerfect = new FlxSprite(weekItem.x - 21.8, weekItem.y - 21.55, Paths.image('main-menu/goForAPerfectStoryMode'));
			add(goForAPerfect);
		}
		for (i in 0...3)
		{
			var diffItem = new FlxSprite(25, 70);
			diffItem.y += i * 20;
			var animName = ['easy', 'normal', 'hard'][i];
			diffItem.frames = Paths.getSparrowAtlas('main-menu/story-diffies');
			diffItem.animation.addByPrefix('idle', animName, 0, false);
			diffItem.animation.play('idle');
			diffItem.antialiasing = getPref('antialiasing');
			diffItem.ID = i;
			var goForAPerfect = new FlxSprite(diffItem.x - 21.8, diffItem.y - 21.55, Paths.image('main-menu/goForAPerfectStoryMode'));
			add(goForAPerfect);
			diffItems.add(diffItem);
		}

		selectorSpriteWeeks = new FlxSprite();
		selectorSpriteWeeks.frames = Paths.getSparrowAtlas('main-menu/storySelector');
		selectorSpriteWeeks.animation.addByPrefix('idle', 'storySelector', 0, false);
		selectorSpriteWeeks.animation.addByPrefix('desat', 'storySelectorDesat', 0, false);
		selectorSpriteWeeks.antialiasing = getPref('antialiasing');
		add(selectorSpriteWeeks);

		selectorSpriteDiffs = new FlxSprite();
		selectorSpriteDiffs.frames = Paths.getSparrowAtlas('main-menu/storySelector');
		selectorSpriteDiffs.animation.addByPrefix('idle', 'storySelector', 0, false);
		selectorSpriteDiffs.animation.addByPrefix('desat', 'storySelectorDesat', 0, false);
		selectorSpriteDiffs.antialiasing = getPref('antialiasing');
		add(selectorSpriteDiffs);

		var bottomBar = new FlxSprite(-0.1, 602.5);
		bottomBar.frames = Paths.getSparrowAtlas('main-menu/story-bars');
		bottomBar.animation.addByPrefix('idle', '$save bar', 0, false);
		bottomBar.animation.play('idle');
		bottomBar.active = false;
		bottomBar.antialiasing = getPref('antialiasing');
		add(bottomBar);

		var scoreTxt = new FlxText(590, 635, 0, '', 40);
		scoreTxt.antialiasing = getPref('antialiasing');
		scoreTxt.color = -16777216;
		scoreTxt.font = Paths.font('AntipastoPro.ttf');
		scoreTxt.text = MainMenuState.getScoreOrMisses(isGF, false);
		add(scoreTxt);

		var missesTxt = new FlxText(790, scoreTxt.y, 0, '', 40);
		missesTxt.antialiasing = getPref('antialiasing');
		missesTxt.color = -16777216;
		missesTxt.font = Paths.font('AntipastoPro.ttf');
		missesTxt.text = MainMenuState.getScoreOrMisses(isGF, true);
		add(missesTxt);

		selectorSpriteWeeks.animation.play('idle');
		selectorSpriteDiffs.animation.play('desat');

		changeSelection();
		changeDiff();
		super.create();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (curRow != 4)
			if (controls.UI_DOWN_P)
				changeSelection(-5);

		if (curRow != 0)
			if (controls.UI_UP_P)
				changeSelection(5);

		if (curColumn != 5)
			if (controls.UI_RIGHT_P)
				changeSelection(-1);

		if (curColumn != 0)
		{
			if (controls.UI_LEFT_P)
				changeSelection(1);
		}
		else
		{
			if (!selectingDiff)
			{
				if (controls.UI_LEFT_P)
				{
					selectingDiff = true;
					selectorSpriteWeeks.animation.play('desat');
					selectorSpriteDiffs.animation.play('idle');
				}
			}
			else
			{
				if (controls.UI_UP_P)
					changeDiff(-1);
				if (controls.UI_DOWN_P)
					changeDiff(1);
				if (controls.UI_RIGHT_P)
				{
					selectingDiff = false;
					selectorSpriteWeeks.animation.play('idle');
					selectorSpriteDiffs.animation.play('desat');
				}
			}
		}
		if (controls.ACCEPT)
			selectWeek();

		if (controls.BACK)
			switchState(MainMenuState);

		#if debug
		FlxG.watch.addQuick('curSelected', curSelected);
		FlxG.watch.addQuick('curColumn', curColumn);
		FlxG.watch.addQuick('curRow', curRow);
		FlxG.watch.addQuick('curDifficulty', curDifficulty);
		FlxG.watch.addQuick('selectingDiff', selectingDiff);
		if (FlxG.keys.justPressed.SEVEN)
		{
			setPref('ratio-unlocked', true);
			FlxG.resetState();
		}
		#end
	}

	function changeDiff(change = 0)
	{
		if (lockedSelection)
			return;

		if (change != 0)
			FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

		curDifficulty += change;
		if (curDifficulty > 2)
			curDifficulty = 2;
		if (curDifficulty < 0)
			curDifficulty = 0;

		for (diffItem in diffItems)
			if (diffItem.ID == curDifficulty)
			{
				FlxTween.cancelTweensOf(selectorSpriteDiffs);
				FlxTween.tween(selectorSpriteDiffs, {
					x: diffItem.x - 10.9,
					y: diffItem.y - 8.65
				}, 0.1, {ease: FlxEase.quadOut});
			}
	}

	var selectingDiff = false;
	var curSelected = 0;
	var curColumn = 0;
	var curRow = 0;
	var lockedSelection = false;
	var curDifficulty = 1;

	function changeSelection(change:Int = 0, force = false)
	{
		if (lockedSelection || selectingDiff)
			return;
		if (change != 0)
			FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

		curSelected += change;

		curColumn = (curSelected / 5).int();
		curRow = curSelected % 5;

		for (weekItem in weekItems)
		{
			if (weekItem.ID == curSelected)
			{
				FlxTween.cancelTweensOf(selectorSpriteWeeks);
				FlxTween.tween(selectorSpriteWeeks, {
					x: weekItem.x - 10.9,
					y: weekItem.y - 8.65
				}, 0.1, {ease: FlxEase.quadOut});
			}
		}
	}

	function selectWeek()
	{
		if (lockedSelection)
			return;

		for (weekItem in weekItems)
			if (weekItem.ID == curSelected)
				if (weekItem.animation.curAnim.name == 'week?' || weekItem.animation.curAnim.name == 'weekLock')
					return;

		lockedSelection = true;

		FlxG.sound.play(Paths.sound('confirmMenu'));
		for (weekItem in weekItems)
		{
			if (weekItem.ID == curSelected)
				FlxFlicker.flicker(weekItem, 1, 0.075, true, true, function(_)
				{
					var elpepe:Array<String> = [];
					for (song in weeks[curSelected + (!isGF ? 7 : 0)].weekSongs)
						elpepe.push(song);
					PlayState.storyPlaylist = cast(elpepe);

					PlayState.curDifficulty = curDifficulty;
					PlayState.loadSong(CoolUtil.formatSong(PlayState.storyPlaylist[0].toLowerCase(), curDifficulty), curSelected + (!isGF ? 7 : 0),
						flixel.util.FlxColor.WHITE, true, true);
				});
		}
	}
}
