import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.keyboard.FlxKey;
import flixel.text.FlxText;
import flixel.util.FlxColor;

class KeyBindsMenu extends MusicBeatSubstate
{
	var isPause:Bool;
	var playerStrums:FlxTypedGroup<BabyArrow>;
	var arrowGrp:ArrowGrp;
	var textStrums:FlxTypedGroup<FlxText>;
	var textArrows:FlxTypedGroup<FlxText>;
	var sprOpt:AlphabetList;
	var keysBlackList:Array<FlxKey> = [
		FlxKey.ALT,
		FlxKey.BACKSPACE,
		FlxKey.CAPSLOCK,
		FlxKey.CONTROL,
		FlxKey.ENTER,
		FlxKey.SHIFT,
		FlxKey.ESCAPE,
		FlxKey.TAB
	];

	public function new(_isPause:Bool)
	{
		isPause = _isPause;
		super();

		if (isPause)
		{
			var bg = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
			bg.alpha = .6;
			bg.scrollFactor.set();
			add(bg);
		}

		sprOpt = new AlphabetList([
			'NOTE LEFT',
			'NOTE DOWN',
			'NOTE UP',
			'NOTE RIGHT',
			'NOTE SPACE',
			'UI LEFT',
			'UI DOWN',
			'UI UP',
			'UI RIGHT'
		]);
		add(sprOpt);
		playerStrums = new FlxTypedGroup<BabyArrow>();
		add(playerStrums);
		textStrums = new FlxTypedGroup<FlxText>();
		add(textStrums);
		textArrows = new FlxTypedGroup<FlxText>();
		add(textArrows);

		babyArrowSpace = new FlxSprite(0, 100);
		babyArrowSpace.x += 50;
		babyArrowSpace.x += ((flixel.FlxG.width / 2) * 1);
		babyArrowSpace.frames = Paths.getSparrowAtlas('NOTE_assets');
		babyArrowSpace.animation.addByPrefix('static', 'arrowSPACE', 24, false, false, false);
		babyArrowSpace.animation.addByPrefix('confirm', 'space confirm', 24, false, false, false);
		babyArrowSpace.animation.addByPrefix('pressed', 'space press', 24, false, false, false);
		babyArrowSpace.setGraphicSize(Std.int(babyArrowSpace.width * 0.7));
		babyArrowSpace.antialiasing = getPref('antialiasing');
		babyArrowSpace.updateHitbox();
		babyArrowSpace.animation.play('static');
		babyArrowSpace.offset.set(0, 0);
		// add(babyArrowSpace);

		for (i in 0...5)
		{
			var babyArrow = new BabyArrow(50, i, 'normal', 1, false, true);
			var noteKeyText = new FlxText(babyArrow.getMidpoint().x - 22.5, babyArrow.getMidpoint().y + 20, 0, '');
			if (i == 4)
				noteKeyText.setPosition(babyArrowSpace.getMidpoint().x - 22.5, babyArrowSpace.getMidpoint().y + 20);
			noteKeyText.setFormat(Paths.font("vcr.ttf"), 52, switch (i)
			{
				default:
					0xFFc24b99;
				case 1:
					0xFF00ffff;
				case 2:
					0xFF12fa05;
				case 3:
					0xFFf9393f;
				case 4:
					0xFFFF7C40;
			}, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			noteKeyText.borderSize = 1.25;
			noteKeyText.ID = i;
			if (i == 4)
				noteKeyText.alignment = CENTER;
			textStrums.add(noteKeyText);

			var uiKeyText = new FlxText(965, 520, 0, '');
			uiKeyText.setFormat(Paths.font("vcr.ttf"), 52, 0xFF00ffff, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			uiKeyText.borderSize = 1.25;
			uiKeyText.ID = i;
			if (i != 4)
				textArrows.add(uiKeyText);
			switch (i)
			{
				case 0:
				case 2:
					uiKeyText.x += 90;
					uiKeyText.y -= 100;
				case 3:
					uiKeyText.x += 85 + 100;
				case 1:
					uiKeyText.x += 95;
					uiKeyText.y += 95;
			}
			if (i != 4)
				playerStrums.add(babyArrow);
		}

		arrowGrp = new ArrowGrp();
		add(arrowGrp);

		daBG = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		daBG.alpha = .6;
		daBG.scrollFactor.set();
		add(daBG);
		daBG.visible = false;
		if (isPause)
			cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];
	}

	var babyArrowSpace:FlxSprite;

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (back)
		{
			close();
			openSubState(new PreferencesMenu(isPause));
		}

		sprOpt.canChangeSel = !choosingKey;

		var noteArray:Array<Bool> = [
			controls.NOTE_LEFT_P,
			controls.NOTE_DOWN_P,
			controls.NOTE_UP_P,
			controls.NOTE_RIGHT_P,
			controls.NOTE_SPACE_P
		];
		var noteHoldArray:Array<Bool> = [
			controls.NOTE_LEFT, //
			controls.NOTE_DOWN, //
			controls.NOTE_UP, //
			controls.NOTE_RIGHT,
			controls.NOTE_SPACE //
		];

		var uiHoldArray:Array<Bool> = [
			controls.UI_LEFT, //
			controls.UI_DOWN, //
			controls.UI_UP, //
			controls.UI_RIGHT //
		];

		if (!choosingKey)
		{
			playerStrums.forEach(function(spr:BabyArrow)
			{
				if (noteArray[spr.ID] && spr.animation.curAnim.name != 'confirm')
				{
					if (checkKey('SHIFT', PRESSED))
						spr.playAnim('confirm');
					else
						spr.playAnim('pressed');
				}

				if (!noteHoldArray[spr.ID])
					spr.playAnim('static');
			});
			if (noteArray[4] && babyArrowSpace.animation.curAnim.name != 'confirm')
			{
				if (checkKey('SHIFT', PRESSED))
				{
					babyArrowSpace.animation.play('confirm');
					babyArrowSpace.offset.set(0, 0);
					babyArrowSpace.offset.set(0, 0);
					babyArrowSpace.offset.x -= 13;
					babyArrowSpace.offset.y -= 13;
				}
				else
				{
					babyArrowSpace.offset.set(0, 0);
					babyArrowSpace.animation.play('pressed');
				}
			}
			if (!noteHoldArray[4])
			{
				babyArrowSpace.animation.play('static', true);
				babyArrowSpace.offset.set(0, 0);
			}
			arrowGrp.forEach(function(spr:FlxSprite)
			{
				if (uiHoldArray[spr.ID])
				{
					textArrows.forEach(function(text:FlxText)
					{
						if (text.ID == spr.ID)
							text.color = 0xFFffffff;
					});
					spr.animation.play('press');
				}
				else
				{
					textArrows.forEach(function(text:FlxText)
					{
						if (text.ID == spr.ID)
							text.color = 0xFF00ffff;
					});
					spr.animation.play('idle');
				}
			});

			textStrums.forEach(function(spr:FlxText) spr.text = KeyBinds.keyCodeToString(FlxG.save.data.noteBinds[spr.ID]));
			textArrows.forEach(function(spr:FlxText) spr.text = KeyBinds.keyCodeToString(FlxG.save.data.uiBinds[spr.ID]));

			if (controls.ACCEPT)
			{
				choosingKey = true;
				if (isNote)
					FlxG.save.data.noteBinds[curSelected] = -1;
				else
					FlxG.save.data.uiBinds[curSelected % 4] = -1;

				daBG.visible = true;
			}
			if (controls.BACK)
			{
				back = true;
			}
		}
		else
		{
			if (FlxG.keys.firstJustPressed() != -1)
			{
				if (isNote)
					FlxG.save.data.noteBinds[curSelected] = keysBlackList.contains(FlxG.keys.firstJustPressed()) ? null : FlxG.keys.firstJustPressed();
				else
					FlxG.save.data.uiBinds[curSelected % 4] = keysBlackList.contains(FlxG.keys.firstJustPressed()) ? null : FlxG.keys.firstJustPressed();
				choosingKey = false;
				daBG.visible = false;
				KeyBinds.initBinds();
			}
		}
	}

	var back = false;

	var daBG:FlxSprite;

	var choosingKey:Bool = false;

	var curSelected(get, never):Int;

	inline function get_curSelected():Int
		return sprOpt.selectedIndex;

	var isNote(get, never):Bool;

	inline function get_isNote():Bool
		return sprOpt.textList[curSelected].contains('NOTE');
}
