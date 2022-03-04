package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.addons.transition.FlxTransitionableState;
import flixel.effects.FlxFlicker;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.keyboard.FlxKey;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import lime.app.Application;

using StringTools;

#if (windows && cpp)
import Discord.DiscordClient;
#end

class MainMenuState extends MusicBeatState
{
	var curSelected:Int = 0;

	var menuItems:FlxTypedGroup<FlxSprite>;
	var saveItems:FlxTypedGroup<MenuSave>;
	var select_one:FlxSprite;
	var daPanel:FlxSprite;
	var optionShit:Array<String> = ['story mode', 'freeplay', 'options', 'donate'];

	override function create()
	{
		#if debug
		MenuSaveEditor;
		#end
		#if (windows && cpp)
		DiscordClient.changePresence("In the Menus", null);
		#end

		MusicManager.checkPlaying();

		persistentUpdate = persistentDraw = true;

		var bg = new FlxSprite(-117.75, -75.75);
		bg.frames = Paths.getSparrowAtlas('main-menu/animated-background');
		bg.animation.addByPrefix('idle', 'animated background', 24, true);
		bg.animation.play('idle', true);
		bg.antialiasing = getPref('antialiasing');
		add(bg);

		var menuItemTex = Paths.getSparrowAtlas('main-menu/menu-items');

		saveItems = new FlxTypedGroup<MenuSave>();
		add(saveItems);

		daPanel = new FlxSprite(223.5, 258.5 + 484, Paths.image('main-menu/daPanel'));
		daPanel.antialiasing = getPref('antialiasing');
		add(daPanel);

		menuItems = new FlxTypedGroup<FlxSprite>();
		add(menuItems);

		for (i in 0...optionShit.length)
		{
			final iOption = optionShit[i];
			var menuItem = new FlxSprite();

			menuItem.frames = menuItemTex;
			menuItem.ID = i;
			menuItem.animation.addByIndices('idle', iOption, [0], '', 24, false);
			menuItem.animation.addByIndices('selected', iOption, [0, 1, 2, 3, 4, 5, 6, 7, 8, 9], '', 24, false);
			menuItem.animation.addByIndices('unselected', iOption, [9, 8, 7, 6, 5, 4, 3, 2, 1, 0], '', 24, false);
			menuItem.animation.addByPrefix('enter', iOption, 24, false);
			menuItem.animation.play('idle');
			menuItem.antialiasing = getPref('antialiasing');

			if (iOption != 'story mode')
				menuItem.y = 548.75 + 484;
			switch (iOption)
			{
				case 'story mode':
					menuItem.x = 282.3;
					menuItem.y = 801.7;
				case 'freeplay':
					menuItem.x = 282.3;
				case 'options':
					menuItem.x = 522.35;
				case 'donate':
					menuItem.x = 769.95;
			}

			menuItems.add(menuItem);
		}
		for (i in MenuSave.saves)
		{
			var index = MenuSave.saves.indexOf(i);
			var saveItem = new MenuSave(419.9, index == 0 ? 201.6 : 434.1, index);
			saveItem.scrollFactor.set();
			saveItems.add(saveItem);
		}

		var versionShit = new FlxText(5, FlxG.height - 50, 0, 'Rhythm Engine v${GameVars.engineVer}', 12);
		versionShit.scrollFactor.set();
		versionShit.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		versionShit.borderSize = 1.25;
		versionShit.screenCenter(X);
		versionShit.scrollFactor.set();

		select_one = new FlxSprite(-31.2, -177.6);
		select_one.frames = Paths.getSparrowAtlas('main-menu/select-one');
		select_one.animation.addByPrefix('select one', 'select one', 24, true);
		select_one.animation.play('select one');
		add(select_one);

		if (getPref("first-time"))
			null; // anashei;

		scoreTxtBF = new FlxText(600, 200, 0, '', 40);
		scoreTxtBF.antialiasing = getPref('antialiasing');
		scoreTxtBF.font = Paths.font('AntipastoPro.ttf');
		scoreTxtBF.text = getScoreOrMisses(false, false);
		add(scoreTxtBF);

		missesTxtBF = new FlxText(734, 332, 0, '', 40);
		missesTxtBF.antialiasing = getPref('antialiasing');
		missesTxtBF.font = Paths.font('AntipastoPro.ttf');
		missesTxtBF.text = getScoreOrMisses(false, true);
		add(missesTxtBF);

		scoreTxtGF = new FlxText(600, 200 + 290, 0, '', 40);
		scoreTxtGF.antialiasing = getPref('antialiasing');
		scoreTxtGF.font = Paths.font('AntipastoPro.ttf');
		scoreTxtGF.text = getScoreOrMisses(true, false);
		add(scoreTxtGF);

		missesTxtGF = new FlxText(734, 332 + 290, 0, '', 40);
		missesTxtGF.antialiasing = getPref('antialiasing');
		missesTxtGF.font = Paths.font('AntipastoPro.ttf');
		missesTxtGF.text = getScoreOrMisses(true, true);
		add(missesTxtGF);

		changeItem();

		#if debug
		checkKeysToTrace = function()
		{
			if (FlxG.keys.justPressed.U)
			{
				// trace(scoreTxtBF.getPosition());
				trace(missesTxtBF.getPosition());
			}
			var keysArray = [FlxKey.LEFT, DOWN, UP, FlxKey.RIGHT];
			if (FlxG.keys.anyJustPressed(keysArray))
			{
				for (i in keysArray)
					if (FlxG.keys.anyJustPressed([i]))
						switch (keysArray.indexOf(i))
						{
							case 0:
								missesTxtBF.x -= 1;
							case 1:
								missesTxtBF.y += 1;
							case 2:
								missesTxtBF.y -= 1;
							case 3:
								missesTxtBF.x += 1;
						}
			}
		}
		#end
		super.create();
	}

	var checkKeysToTrace:Void->Void;

	public static function getScoreOrMisses(gf:Bool, misses:Bool):String
	{
		var scoreInt = 0;
		var tempWeeksScore:Array<Int> = getPref(!misses ? 'weeksScore' : 'weeksMisses');
		for (i in 0...tempWeeksScore.length - 1)
		{
			var scoreBF = tempWeeksScore[i];
			if ((!gf ? (i > 6) : (i < 7)))
				scoreInt += scoreBF;
		}
		var scoreString = '';
		scoreString = Std.string(scoreInt);
		if (!(scoreInt < 1000))
		{
			var tempArray = scoreString.split('');
			tempArray.pop();
			tempArray.pop();
			tempArray.pop();
			scoreString = tempArray.join('') + 'K';
		}

		return scoreString;
	}

	var scoreTxtBF:FlxText;
	var missesTxtBF:FlxText;

	var scoreTxtGF:FlxText;
	var missesTxtGF:FlxText;

	var selectedSomethin:Bool = false;

	override function update(elapsed:Float)
	{
		#if debug
		FlxG.watch.addQuick('curSelected', curSelected);
		FlxG.watch.addQuick('selectedSave', selectedSave);
		FlxG.watch.addQuick('selectedSomethin', selectedSomethin);
		if (FlxG.keys.justPressed.F7)
			Console.open();
		if (FlxG.keys.justPressed.F8)
			switchState(AlphabetCharEditor);
		if (checkKey('Q', PRESSED))
			FlxG.camera.zoom += .025;
		if (checkKey('E', PRESSED))
			FlxG.camera.zoom -= .025;

		if (FlxG.keys.justPressed.SEVEN)
			switchState(BopperOffsetMaker, [0]);
		if (FlxG.keys.justPressed.EIGHT)
			switchState(BopperOffsetMaker, [1]);
		if (FlxG.keys.justPressed.NINE)
			switchState(BopperOffsetMaker, [2]);
		#end
		if (!selectedSomethin)
		{
			var up = false,
				down = false,
				left = false,
				right = false,
				accept = false,
				back = false,
				space = false;
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
			#else
			up = controls.UI_UP_P;
			down = controls.UI_DOWN_P;
			left = controls.UI_LEFT_P;
			right = controls.UI_RIGHT_P;
			back = controls.BACK;
			accept = controls.ACCEPT;
			#end

			if (selectedSave != -1)
			{
			}
			else
			{
				#if FLX_MOUSE
				if (FlxG.mouse.wheel != 0)
					changeItem(FlxG.mouse.wheel == 1 ? -1 : 1);
				#end

				if (up)
					changeItem(-1);

				if (down)
					changeItem(1);
			}

			if (back)
				switchState(TitleState);

			if (accept)
				selectItem();
		}
		super.update(elapsed);
	}

	static var lastSaveSelected = -1;
	static var lastSelected = -1;

	function selectItem():Void
	{
		if (selectedSave == -1)
		{
			final tweenTime = 0.583333333333333;
			saveItems.forEach(function(spr:MenuSave)
			{
				if (spr.daSave == curSelected)
				{
					curSelected = 0;
					selectedSave = spr.daSave;
					selectedSomethin = true;
					changeItem();
					new FlxTimer().start(tweenTime, function(tmr:FlxTimer)
					{
						spr.playAnim('alpha remove');
						var scoreTxt = spr.daSave == 0 ? scoreTxtBF : scoreTxtGF;
						var missesTxt = spr.daSave == 0 ? missesTxtBF : missesTxtGF;
					});
				}
				else
				{
				};

				{
					if (optionShit[curSelected] == 'donate')
					{
						#if linux
						Sys.command('/usr/bin/xdg-open', ["https://ninja-muffin24.itch.io/funkin", "&"]);
						#else
						FlxG.openURL('https://ninja-muffin24.itch.io/funkin');
						#end
					}
					else
					{
						selectedSomethin = true;
						FlxG.sound.play(Paths.sound('confirmMenu'));

						menuItems.forEach(function(spr:FlxSprite)
						{
							if (curSelected != spr.ID)
							{
							}
							else
							{
								var finishFunc = function(flick:Dynamic)
								{
									var daChoice:String = optionShit[curSelected];

									switch (daChoice)
									{
										case 'story mode':
											switchState(StoryMenuState, [selectedSave != 0]);
										case 'freeplay':
											switchState(FreeplayState, [false, selectedSave != 0]);
										case 'options':
											switchState(OptionsMenu);
									}
								};
								if (getPref('flashing-menu'))
									FlxFlicker.flicker(spr, 1, 0.06, false, false, finishFunc);
								else
									new FlxTimer().start(1, finishFunc);
							}
						});
					}
				}
			});
		}
	}

	var selectedSave = -1;

	function changeItem(huh:Int = 0, force:Bool = false)
	{
		if (huh != 0)
			FlxG.sound.play(Paths.sound('scrollMenu'));
		curSelected += huh;

		if (force)
			curSelected = huh;

		var daGroup:FlxTypedGroup<Dynamic> = selectedSave == -1 ? saveItems : menuItems;

		if (curSelected >= daGroup.length)
			curSelected = 0;
		if (curSelected < 0)
			curSelected = daGroup.length - 1;

		if (selectedSave == -1)
		{
			saveItems.forEach(function(spr:MenuSave)
			{
				@:privateAccess
				var wasSelected = spr.animation.curAnim.name == 'selected';
				spr.playAnim('idle');
				if (spr.ID == curSelected)
					spr.playAnim('selected');
				if (wasSelected)
					spr.playAnim('unselected');
				if (spr.ID == 0)
				{
				}
				var scoreTxt = spr.ID == 0 ? scoreTxtBF : scoreTxtGF;
				var missesTxt = spr.ID == 0 ? missesTxtBF : missesTxtGF;
				var yyy = spr.ID == 0 ? 0 : 290;
			});
		}
		else
			menuItems.forEach(function(spr:FlxSprite)
			{
				var wasSelected = spr.animation.curAnim.name == 'selected';
				spr.animation.play('idle', true);

				if (spr.ID == curSelected)
					spr.animation.play('selected');
				if (wasSelected)
					spr.animation.play('unselected');
			});
	}
} // class MainMenuList extends MenuTypedList
// {
// 	public function createItem(a = 0, b = 0, c, d, e = false)
// 	{
// 		var item = new MainMenuItem(a, b, c, atlas, d);
// 		item.fireInstantly = e;
// 		a.ID = length;
// 		return addItem(c, a);
// 	}
// }
// class MainMenuItem
// {
// }
