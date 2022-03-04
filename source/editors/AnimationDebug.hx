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
class AnimationDebug extends FlxState
{
	var char:Character;
	var ghostChar:Character;
	var animList:Array<String> = [];
	var curAnim:String;
	var isPlayer:Bool = true;
	var UI_box:FlxUITabMenu;
	var daAnim:String = 'spooky';
	var camFollow:FlxObject;

	var camHUD:FlxCamera;
	var camGame:FlxCamera;

	var leHealthIcon:HealthIcon;

	public function new(daAnim:String = 'dad', _isDad:Bool)
	{
		super();
		this.daAnim = daAnim;
		isPlayer = !_isDad;
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
		charAnims = new FlxUIDropDownMenu(10, 60, FlxUIDropDownMenu.makeStrIdLabelArray(animList, false), function(animAtion:String)
		{
			ghostChar.playAnim(animAtion, true);
		});
		charAnims.selectedLabel = char.animation.curAnim.name;
		charAnims.cameras = [camHUD];
		add(charAnims);
		leHealthIcon = new HealthIcon(char.curCharacter, false);
		leHealthIcon.setGraphicSize(Std.int(leHealthIcon.width * 1.5));
		add(leHealthIcon);
		leHealthIcon.y = FlxG.height - 150;
		leHealthIcon.cameras = [camHUD];
		reloadChar();
		super.create();
	}

	var charAnims:FlxUIDropDownMenu;

	override function update(elapsed:Float)
	{
		#if FLX_MOUSE
		if (FlxG.mouse.overlaps(leHealthIcon) && FlxG.mouse.justPressed)
		{
			switch (leHealthIcon.animation.curAnim.curFrame)
			{
				case 0:
					leHealthIcon.animation.curAnim.curFrame = 1;
				case 1:
					leHealthIcon.animation.curAnim.curFrame = 0;
			}
		}

		if (FlxG.mouse.wheel != 0)
			FlxG.camera.zoom += (FlxG.mouse.wheel / 10);
		#end

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

		var controlArray = [
			FlxG.keys.justPressed.SPACE,
			FlxG.keys.justPressed.A,
			FlxG.keys.justPressed.S,
			FlxG.keys.justPressed.W,
			FlxG.keys.justPressed.D
		];

		if (controlArray.contains(true))
		{
			var singList = ['idle', 'singLEFT', 'singDOWN', 'singUP', 'singRIGHT'];
			var singNormalList = ['idle', 'singLEFT', 'singDOWN', 'singUP', 'singRIGHT'];
			var singAltList = ['idle', 'singLEFT', 'singDOWN', 'singUP', 'singRIGHT'];
			var singShiftList = ['idle', 'singLEFT', 'singDOWN', 'singUP', 'singRIGHT'];
			switch (char.curCharacter)
			{
				case 'parents-christmas':
					singAltList = ['idle', 'singLEFT-alt', 'singDOWN-alt', 'singUP-alt', 'singRIGHT-alt'];
				case 'bf':
					singShiftList = ['hey', 'singLEFTmiss', 'singDOWNmiss', 'singUPmiss', 'singRIGHTmiss'];
					singAltList = ['scared', 'singHIT', 'singDODGE', 'singUP', 'singRIGHT'];
					if (char.isDead)
						singNormalList = ['firstDeath', 'deathLoop', 'deathLoop', 'deathConfirm', 'deathLoop'];
				case 'gf':
					singNormalList = ['sad', 'danceLeft', 'sad', 'sad', 'danceRight'];
					singShiftList = ['sad', 'singLEFT', 'singDOWN', 'singUP', 'singRIGHT'];
					singAltList = ['scared', 'cheer', 'duck', 'hairBlow', 'hairFall'];
				case 'speaker':
					singNormalList = ['danceLeft', 'danceLeft', 'danceLeft', 'danceLeft', 'danceRight'];
				case 'spooky':
					singShiftList = ['danceLeft', 'danceLeft', 'danceLeft', 'danceLeft', 'danceRight'];
				case 'dizzle':
					singAltList = [
						'idle-pixel',
						'singLEFT-pixel',
						'singDOWN-pixel',
						'singUP-pixel',
						'singRIGHT-pixel'
					];
					singShiftList = ['sing321', 'singBRUH', 'singOHNONO', 'singPENIS', 'singSCREAM'];
				case 'chango':
					singNormalList = ['disgust', 'danceLeft', 'danceRight', 'danceLeft', 'danceRight'];
					singAltList = ['danceLeft', 'danceLeft', 'danceRight', 'danceLeft', 'danceRight'];
					singShiftList = ['danceLeft', 'danceLeft', 'danceRight', 'danceLeft', 'danceRight'];
			}
			switch (char.curCharacter)
			{
				default:
					if (checkKey('ALT', PRESSED))
						singList = singAltList;
					else if (checkKey('SHIFT', PRESSED))
						singList = singShiftList;
					else
						singList = singNormalList;

					char.playAnim(singList[controlArray.indexOf(true)], true);
			}
		}

		var checkArray = [checkKey('UP'), checkKey('DOWN'), checkKey('LEFT'), checkKey('RIGHT')];
		if (checkArray.contains(true))
		{
			var holdShift = FlxG.keys.pressed.SHIFT;
			var multiplier = 1;
			if (holdShift)
				multiplier = 10;

			if (checkArray[0])
				char.animOffsets.get(char.animation.curAnim.name)[1] += 1 * multiplier;
			if (checkArray[1])
				char.animOffsets.get(char.animation.curAnim.name)[1] -= 1 * multiplier;
			if (checkArray[2])
				char.animOffsets.get(char.animation.curAnim.name)[0] += 1 * multiplier;
			if (checkArray[3])
				char.animOffsets.get(char.animation.curAnim.name)[0] -= 1 * multiplier;

			char.playAnim(char.animation.curAnim.name, true);
		}

		if (checkKey('U'))
			trace(generateOffsetCode(char.animation.curAnim.name));

		if (FlxG.keys.justPressed.ENTER)
			LoadingState.loadAndSwitchState(PlayState);

		if (FlxG.keys.justPressed.ESCAPE)
			saveOffsetsInCode();
		super.update(elapsed);
	}

	function changeAnim(daAnim:String)
	{
		char.playAnim(daAnim, true);
		charAnims.selectedLabel = char.animation.curAnim.name;
	}

	private function saveOffsetsInCode():Void
	{
		var clipboardString = '';

		for (swagAnim in animList)
			clipboardString += generateOffsetCode(swagAnim);

		openfl.system.System.setClipboard(clipboardString);

		trace('offsets in code here:\n$clipboardString');
	}

	private function generateOffsetCode(swagAnim:String)
		return 'addOffset(\'$swagAnim\', ${char.animOffsets.get(swagAnim)[0]}, ${char.animOffsets.get(swagAnim)[1]});\n';

	var charDropText:FlxInputText;
	var check_player:FlxUICheckBox;
	var check_dead:FlxUICheckBox;
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

		check_player = new FlxUICheckBox(10, 60, null, null, "Playable Character", 100);
		check_player.checked = isPlayer;
		check_player.callback = function():Void
		{
			reloadChar();
		};

		ghostChar_check = new FlxUICheckBox(10, 90, null, null, "Ghost Character", 100);
		ghostChar_check.checked = true;
		ghostChar_check.callback = function():Void
		{
			ghostChar.visible = !ghostChar.visible;
			char.alpha = ghostChar.visible ? .85 : 1;
		};

		check_dead = new FlxUICheckBox(10, 120, null, null, "Simulate Dead", 100);
		check_dead.checked = false;
		check_dead.callback = function():Void
		{
			reloadChar();
		};

		charDropText = new FlxInputText(10, 30, 70, daAnim, 8, FlxColor.BLACK, FlxColor.TRANSPARENT);
		charDropText.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		charDropText.focusGained = focusGained;
		charDropText.focusLost = focusLost;
		// charDropText.textField.font = Paths.font("vcr.ttf");
		// charDropText.setFormat(, 20, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);

		var reloadCharacter = new FlxButton(140, 30, "Reload Char", function()
		{
			reloadChar();
		});

		tab_group.add(new FlxText(charDropText.x, charDropText.y - 18, 0, 'Character:'));
		tab_group.add(check_player);
		tab_group.add(ghostChar_check);
		tab_group.add(check_dead);
		tab_group.add(reloadCharacter);
		tab_group.add(charDropText);
		UI_box.addGroup(tab_group);
	}

	function reloadChar(firstTime:Bool = false):Void
	{
		if (char != null)
		{
			remove(char);
			remove(ghostChar);
		}

		var charArgs:Array<String> = [];

		switch (daAnim)
		{
			case 'bf':
				charArgs = ['DODGE', 'SHAKE'];
			case 'gf':
				charArgs = ['BLOWING', 'CHEER', 'DUCK', 'FEAR', 'SING'];
		}

		if (check_dead != null)
			if (check_dead.checked)
				charArgs = ['DEAD'];

		char = new Character(0, 0, daAnim, charArgs, firstTime ? isPlayer : check_player.checked, false);
		char.debugMode = true;
		char.antialiasing = false;
		add(char);

		ghostChar = new Character(0, 0, char.curCharacter, charArgs, firstTime ? isPlayer : check_player.checked, false);
		ghostChar.debugMode = true;
		ghostChar.antialiasing = false;
		ghostChar.alpha = 0.6;
		ghostChar.color = 0xFF666688;
		add(ghostChar);

		char.cameras = [camGame];
		ghostChar.cameras = [camGame];
		animList = [];
		for (anim => offsets in char.animOffsets)
			animList.push(anim);

		if (!firstTime)
		{
			charDropText.text = char.curCharacter;
			leHealthIcon.changeIcon(char.curCharacter);
		}
	}
}
