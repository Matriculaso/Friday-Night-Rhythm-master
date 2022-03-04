#if mobileC
package;

import PreferencesMenu.getPref;
import PreferencesMenu.setPref;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.ui.FlxUIButton;
import flixel.math.FlxPoint;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;
import flixel.util.FlxSave;
import haxe.Json;

using StringTools;

#if lime
import lime.system.Clipboard;
#end

class MobileControlsSubState extends MusicBeatSubstate
{
	var _pad:FlxVirtualPad;
	var _hb:Hitbox;

	var _saveconrtol:FlxSave;
	var exitbutton:FlxUIButton;
	var exportbutton:FlxUIButton;
	var importbutton:FlxUIButton;

	var inputvari:FlxText;

	var leftArrow:FlxSprite;
	var rightArrow:FlxSprite;
	var controlitems:Array<String> = ['Right', 'Left', 'Double', 'Keyboard', 'Custom', 'Hitbox'];

	var curSelected:Int = 0;

	var buttonistouched:Bool = false;

	var bindbutton:flixel.ui.FlxButton;

	public function new()
	{
		super();

		curSelected = getPref('mobileControlsType');

		_pad = new FlxVirtualPad(RIGHT_FULL, NONE);
		_pad.alpha = 0;

		inputvari = new FlxText(125, 50, 0, controlitems[0].toLowerCase(), 48);
		inputvari.setFormat(Paths.font("vcr.ttf"), 48, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		inputvari.borderSize = 1.25;

		var ui_tex = Paths.getSparrowAtlas('campaign_menu_UI_assets');

		leftArrow = new FlxSprite(inputvari.x - 60, inputvari.y - 10);
		leftArrow.frames = ui_tex;
		leftArrow.animation.addByPrefix('idle', "arrow left");
		leftArrow.animation.addByPrefix('press', "arrow push left");
		leftArrow.animation.play('idle');

		rightArrow = new FlxSprite(inputvari.x + inputvari.width + 10, leftArrow.y);
		rightArrow.frames = ui_tex;
		rightArrow.animation.addByPrefix('idle', 'arrow right');
		rightArrow.animation.addByPrefix('press', "arrow push right", 24, false);
		rightArrow.animation.play('idle');

		_hb = new Hitbox();
		_hb.visible = false;

		exitbutton = new FlxUIButton(FlxG.width - 650, 25, "Exit without Save");
		exitbutton.resize(125, 50);
		exitbutton.setLabelFormat("VCR OSD Mono", 24, FlxColor.BLACK, "center", OUTLINE, FlxColor.BLACK);
		exitbutton.label.borderSize = 1.25;

		var savebutton = new FlxUIButton((exitbutton.x + exitbutton.width + 25), 25, "Exit and Save", () ->
		{
			save();
			FlxG.switchState(new OptionsMenu());
		});
		savebutton.resize(250, 50);
		savebutton.setLabelFormat("VCR OSD Mono", 24, FlxColor.BLACK, "center", OUTLINE, FlxColor.BLACK);
		savebutton.label.borderSize = 1.25;

		exportbutton = new FlxUIButton(FlxG.width - 150, 25, "Copy in Clipboard", () ->
		{
			saveToClipboard(_pad);
		});
		exportbutton.resize(125, 50);
		exportbutton.setLabelFormat("VCR OSD Mono", 24, FlxColor.BLACK, "center", OUTLINE, FlxColor.BLACK);
		exportbutton.label.borderSize = 1.25;

		importbutton = new FlxUIButton(exportbutton.x, exportbutton.y + 75, "Load from Clipboard", () ->
		{
			loadFromClipboard(_pad);
		});
		importbutton.resize(125, 50);
		importbutton.setLabelFormat("VCR OSD Mono", 24, FlxColor.BLACK, "center", OUTLINE, FlxColor.BLACK);
		importbutton.label.borderSize = 1.25;

		add(exitbutton);
		add(savebutton);
		add(exportbutton);
		add(importbutton);

		add(_pad);

		add(_hb);

		add(inputvari);
		add(leftArrow);
		add(rightArrow);

		changeSelection();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
		rightArrow.x = inputvari.x + inputvari.width + 10;
		leftArrow.x = inputvari.x - 60;

		if (exitbutton.justReleased || MobileControls.androidBack)
			FlxG.switchState(new OptionsMenu());

		#if windows
		if (FlxG.keys.justPressed.RIGHT)
			changeSelection(1);
		else if (FlxG.keys.justPressed.LEFT)
			changeSelection(-1);
		#end

		#if FLX_TOUCH
		for (touch in FlxG.touches.list)
		{
			arrowanimate(touch);

			if ((touch.overlaps(leftArrow) && touch.justPressed))
				changeSelection(-1);
			else if ((touch.overlaps(rightArrow) && touch.justPressed))
				changeSelection(1);

			if (curSelected != 5)
				trackbutton(touch);
		}
		#end
	}

	function changeSelection(change:Int = 0, ?forceChange:Int)
	{
		curSelected += change;

		if (curSelected < 0)
			curSelected = controlitems.length - 1;
		if (curSelected >= controlitems.length)
			curSelected = 0;

		if (forceChange != null)
			curSelected = forceChange;

		inputvari.text = controlitems[curSelected].toLowerCase();

		if (forceChange != null)
		{
			if (curSelected == 3)
				_pad.visible = true;

			return;
		}

		_hb.visible = false;

		switch (curSelected)
		{
			case 0:
				remove(_pad);
				_pad = null;
				_pad = new FlxVirtualPad(RIGHT_FULL, NONE);
				_pad.alpha = 0.75;
				add(_pad);
			case 1:
				remove(_pad);
				_pad = null;
				_pad = new FlxVirtualPad(FULL, NONE);
				_pad.alpha = 0.75;
				add(_pad);
			case 2:
				remove(_pad);
				_pad = null;
				_pad = new FlxVirtualPad(DOUBLE_FULL, NONE);
				_pad.alpha = 0.75;
				add(_pad);
			case 3:
				_pad.alpha = 0;
			case 4:
				remove(_pad);
				_pad = null;
				_pad = new FlxVirtualPad(RIGHT_FULL, NONE);
				add(_pad);
				_pad.alpha = 0.75;
				loadcustom();
			case 5:
				_pad.alpha = 0;
				_hb.visible = true;
		}
	}

	#if FLX_TOUCH
	function arrowanimate(touch:flixel.input.touch.FlxTouch)
	{
		for (arrow in [leftArrow, rightArrow])
		{
			if (touch.overlaps(arrow) && touch.pressed)
				arrow.animation.play('press');

			if (touch.released)
				arrow.animation.play('idle');
		}
	}

	function trackbutton(touch:flixel.input.touch.FlxTouch)
	{
		if (buttonistouched)
		{
			if (bindbutton.justReleased && touch.justReleased)
			{
				bindbutton = null;
				buttonistouched = false;
			}
			else
				movebutton(touch, bindbutton);
		}
		else
			for (button in [_pad.buttonUp, _pad.buttonDown, _pad.buttonRight, _pad.buttonLeft])
				if (button.justPressed)
				{
					if (curSelected != 4 && curSelected != 5)
						changeSelection(0, 4);

					movebutton(touch, button);
				}
	}

	function movebutton(touch:flixel.input.touch.FlxTouch, button:flixel.ui.FlxButton)
	{
		button.x = touch.x - _pad.buttonUp.width / 2;
		button.y = touch.y - _pad.buttonUp.height / 2;
		bindbutton = button;
		buttonistouched = true;
	}
	#end

	function save()
	{
		setPref('mobileControlsType', curSelected);

		savecustom();
	}

	function savecustom()
	{
		var tempSaveData = new Array();

		var customPos:Array<FlxPoint> = cast(getPref('mobileCustomPositions'));
		tempSaveData = customPos;

		if (tempSaveData == null)
			for (buttons in _pad)
				tempSaveData.push(FlxPoint.get(buttons.x, buttons.y));
		else
		{
			var tempCount:Int = 0;
			for (buttons in _pad)
			{
				tempSaveData[tempCount] = FlxPoint.get(buttons.x, buttons.y);
				tempCount++;
			}
		}

		setPref('mobileCustomPositions', tempSaveData);
	}

	function loadcustom():Void
	{
		var customPos:Array<FlxPoint> = cast(getPref('mobileCustomPositions'));
		if (customPos != null)
		{
			var tempCount:Int = 0;

			for (buttons in _pad)
			{
				buttons.x = customPos[tempCount % 4].x;
				buttons.y = customPos[tempCount % 4].y;
				tempCount++;
			}
		}
	}

	function resizebuttons(vpad:FlxVirtualPad, ?int:Int = 200)
	{
		for (button in vpad)
		{
			button.setGraphicSize(260);
			button.updateHitbox();
		}
	}

	function saveToClipboard(pad:FlxVirtualPad)
	{
		var json = {
			buttonsarray: []
		};

		var tempCount:Int = 0;
		var buttonsarray = new Array<FlxPoint>();

		for (buttons in pad)
		{
			buttonsarray[tempCount] = FlxPoint.get(buttons.x, buttons.y);
			tempCount++;
		}

		json.buttonsarray = buttonsarray;

		var data:String = Json.stringify(json);

		openfl.system.System.setClipboard(data.trim());
	}

	function loadFromClipboard(pad:FlxVirtualPad):Void
	{
		if (curSelected != 4)
			changeSelection(0, 4);

		var cbtext:String = Clipboard.text; // this not working on android 10 or higher

		if (!cbtext.endsWith("}"))
			return;

		var json = Json.parse(cbtext);

		var tempCount:Int = 0;

		for (buttons in pad)
		{
			buttons.x = json.buttonsarray[tempCount].x;
			buttons.y = json.buttonsarray[tempCount].y;
			tempCount++;
		}
	}

	override function destroy()
		super.destroy();
}
#end
