package;

import KeyBinds.checkKey;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.ui.FlxInputText;
import flixel.addons.ui.FlxUI;
import flixel.addons.ui.FlxUICheckBox;
import flixel.addons.ui.FlxUIDropDownMenu;
import flixel.addons.ui.FlxUIInputText;
import flixel.addons.ui.FlxUITabMenu;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;

using StringTools;

#if lime
import lime.system.Clipboard;
#end

/**
	*DEBUG MODE
 */
class MenuSaveEditor extends FlxState
{
	var char:MenuSave;
	var ghostChar:MenuSave;
	var animList:Array<String> = [];
	var curAnim:String;
	var UI_box:FlxUITabMenu;
	var daAnim = 0;
	var camFollow:FlxObject;

	var camHUD:FlxCamera;
	var camGame:FlxCamera;

	public function new(daAnim = 0)
	{
		super();
		this.daAnim = daAnim;
	}

	override function create()
	{
		camGame = new FlxCamera();
		camHUD = new FlxCamera();

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camHUD);
		camHUD.bgColor.alpha = 0;

		FlxCamera.defaultCameras = [camGame];

		trace('Change Offsets at Character: $daAnim');
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

		reloadChar(true);
		var tabs = [{name: 'Settings', label: 'Settings'}];

		UI_box = new FlxUITabMenu(null, tabs, true);
		UI_box.cameras = [camHUD];
		UI_box.resize(250, 220);
		UI_box.x = FlxG.width - 275;
		UI_box.y = 25;
		UI_box.scrollFactor.set();
		add(UI_box);
		addSettingsUI();
		charAnims = new FlxUIDropDownMenu(10, 60, FlxUIDropDownMenu.makeStrIdLabelArray(['idle', 'selected', 'enter', 'alpha remove'], false),
			function(animAtion:String)
			{
				ghostChar.playAnim(animAtion);
			});
		charAnims.selectedLabel = char.animation.curAnim.name;
		charAnims.cameras = [camHUD];
		add(charAnims);
		reloadChar();
		super.create();
	}

	var charAnims:FlxUIDropDownMenu;

	override function update(elapsed:Float)
	{
		if (FlxG.mouse.wheel != 0)
			FlxG.camera.zoom += (FlxG.mouse.wheel / 10);

		if (!textingAnim)
		{
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
		}

		var controlArray = [
			FlxG.keys.justPressed.SPACE,
			FlxG.keys.justPressed.A,
			FlxG.keys.justPressed.S,
			FlxG.keys.justPressed.W,
			FlxG.keys.justPressed.D
		];

		if (controlArray.contains(true) && !textingAnim)
		{
			var singList = ['idle', 'selected', 'enter', 'alpha remove', 'unselected'];
			char.playAnim(singList[controlArray.indexOf(true)]);
			charAnims.selectedLabel = char.animation.curAnim.name;
		}

		var holdShift = FlxG.keys.pressed.SHIFT;
		var multiplier = 1;
		if (holdShift)
			multiplier = 10;

		animDropText = new FlxInputText(60, 50, 1000, '', 100, FlxColor.BLACK, FlxColor.TRANSPARENT);
		animDropText.setFormat(Paths.font("vcr.ttf"), 72, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		animDropText.screenCenter();
		animDropText.focusGained = focusGained;
		animDropText.focusLost = focusLost;
		animDropText.cameras = [camHUD];

		if (FlxG.keys.justPressed.Z)
		{
			if (!textingAnim)
			{
				textingAnim = true;
				add(animDropText);
				animDropText.hasFocus = true;
				animDropText.focusGained();
			}
		}

		var checkArray = [checkKey('UP'), checkKey('DOWN'), checkKey('LEFT'), checkKey('RIGHT')];
		if (checkArray.contains(true))
		{
			if (checkArray[0])
				char.animOffsets.get(char.animation.curAnim.name)[1] += 1 * multiplier;
			if (checkArray[1])
				char.animOffsets.get(char.animation.curAnim.name)[1] -= 1 * multiplier;
			if (checkArray[2])
				char.animOffsets.get(char.animation.curAnim.name)[0] += 1 * multiplier;
			if (checkArray[3])
				char.animOffsets.get(char.animation.curAnim.name)[0] -= 1 * multiplier;

			char.playAnim(char.animation.curAnim.name);
		}

		if (checkKey('U'))
			trace(generateOffsetCode(char.animation.curAnim.name));
		// if (FlxG.keys.justPressed.Z)

		// {
		// 	var daTextInput = new FlxInputText(0, 0,)
		// }

		// if (FlxG.mouse.pressed)
		// {
		// 	updateTexts();
		// 	char.animOffsets.get(char.animation.curAnim.name)[0] = FlxG.mouse.x - char.x - char.offset.x;
		// 	char.animOffsets.get(char.animation.curAnim.name)[1] = FlxG.mouse.y - char.y - char.offset.y;
		// 	updateTexts();
		// 	genBoyOffsets(false);
		// 	char.playAnim(char.animation.curAnim.name);
		// }

		if (FlxG.keys.justPressed.ENTER)
		{
			if (!textingAnim)
				LoadingState.loadAndSwitchState(MainMenuState);
			else
			{
				textingAnim = false;
				changeAnim(animDropText.text);
				remove(animDropText);
				animDropText.text = '';
				animDropText.hasFocus = false;
				animDropText.focusLost();
			}
		}

		if (FlxG.keys.justPressed.ESCAPE)
		{
			saveOffsetsInCode();
		}
		super.update(elapsed);
	}

	function changeAnim(daAnim:String)
	{
		char.playAnim(daAnim);
		charAnims.selectedLabel = char.animation.curAnim.name;
	}

	var textingAnim = false;
	var animDropText:FlxInputText;

	private function saveOffsetsInCode():Void
	{
		var clipboardString = '';

		for (swagAnim in animList)
			clipboardString += generateOffsetCode(swagAnim);

		openfl.system.System.setClipboard(clipboardString);

		trace('offsets in code here:\n$clipboardString');
	}

	private function generateOffsetCode(swagAnim:String)
		return 'animOffsets["$swagAnim"] = [${char.animOffsets.get(swagAnim)[0]}, ${char.animOffsets.get(swagAnim)[1]}];\n';

	var ghostChar_check:FlxUICheckBox;

	var focusGained = function():Void
	{
		FlxG.sound.volumeDownKeys = [MINUS, NUMPADMINUS];
		FlxG.sound.volumeUpKeys = [PLUS, NUMPADPLUS];
		FlxG.sound.muteKeys = [ZERO, NUMPADZERO];
	}

	var focusLost = function():Void
	{
		FlxG.sound.volumeDownKeys = [MINUS, NUMPADMINUS];
		FlxG.sound.volumeUpKeys = [PLUS, NUMPADPLUS];
		FlxG.sound.muteKeys = [ZERO, NUMPADZERO];
	}

	function addSettingsUI()
	{
		var tab_group = new FlxUI(null, UI_box);
		tab_group.name = "Settings";

		ghostChar_check = new FlxUICheckBox(10, 90, null, null, "Ghost Character", 100);
		ghostChar_check.checked = true;
		ghostChar_check.callback = function():Void
		{
			ghostChar.visible = !ghostChar.visible;
			char.alpha = ghostChar.visible ? .85 : 1;
		};

		var reloadCharacter = new FlxButton(140, 30, "Reload Char", function()
		{
			reloadChar();
		});

		tab_group.add(ghostChar_check);
		tab_group.add(reloadCharacter);
		UI_box.addGroup(tab_group);
	}

	function reloadChar(firstTime:Bool = false):Void
	{
		if (char != null)
		{
			remove(char);
			remove(ghostChar);
		}

		char = new MenuSave(0, 0, 0);
		char.antialiasing = false;
		add(char);

		ghostChar = new MenuSave(0, 0, 0);
		ghostChar.antialiasing = false;
		ghostChar.alpha = 0.6;
		ghostChar.color = 0xFF666688;
		add(ghostChar);

		char.cameras = [camGame];
		ghostChar.cameras = [camGame];
		animList = [];
		for (anim => offsets in char.animOffsets)
			animList.push(anim);
	}
}
