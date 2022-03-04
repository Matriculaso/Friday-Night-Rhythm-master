package;

import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.addons.display.FlxGridOverlay;

class BopperOffsetMaker extends MusicBeatState
{
	var bopperType = 0;

	public function new(_bopperType:Int = 0)
	{
		bopperType = _bopperType;
		super();
	}

	var bopper:FlxSprite;
	var ghostBopper:FlxSprite;
	var camFollow:FlxObject;
	var camHUD:FlxCamera;
	var camGame:FlxCamera;

	override function create()
	{
		camGame = new FlxCamera();
		camHUD = new FlxCamera();

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camHUD);
		camHUD.bgColor.alpha = 0;

		FlxCamera.defaultCameras = [camGame];

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

		switch (bopperType)
		{
			case 0:
				ghostBopper = new FlxSprite();
				ghostBopper.frames = Paths.getSparrowAtlas('squizzle/ShusDJSpungMatriBop', 'rhythm');
				ghostBopper.animation.addByPrefix('bop', 'ShusDJSpungMatriBop0', 24, false);
				ghostBopper.animation.addByPrefix('bop disgusted', 'ShusDJSpungMatriBop disgusted', 24, false);
				ghostBopper.animation.play('bop');

				bopper = new FlxSprite();
				bopper.frames = Paths.getSparrowAtlas('squizzle/ShusDJSpungMatriBop', 'rhythm');
				bopper.animation.addByPrefix('bop', 'ShusDJSpungMatriBop0', 24, false);
				bopper.animation.addByPrefix('bop disgusted', 'ShusDJSpungMatriBop disgusted', 24, false);
				bopper.animation.play('bop');
			case 1:
				ghostBopper = new FlxSprite(); // its meeeeeeeeee :D
				ghostBopper.frames = Paths.getSparrowAtlas('squizzle/BrossBop', 'rhythm');
				ghostBopper.animation.addByPrefix('bop', 'BrossBop0', 24, false);
				ghostBopper.animation.addByPrefix('bop disgusted', 'BrossBop disgusted', 24, false);
				ghostBopper.animation.play('bop');

				bopper = new FlxSprite(); // its meeeeeeeeee :D
				bopper.frames = Paths.getSparrowAtlas('squizzle/BrossBop', 'rhythm');
				bopper.animation.addByPrefix('bop', 'BrossBop0', 24, false);
				bopper.animation.addByPrefix('bop disgusted', 'BrossBop disgusted', 24, false);
				bopper.animation.play('bop');
			case 2:
				ghostBopper = new FlxSprite();
				ghostBopper.frames = Paths.getSparrowAtlas('BGCharDance', 'rhythm');
				ghostBopper.animation.addByPrefix('bop', 'BGCharDance', 24, false);
				ghostBopper.animation.addByPrefix('bop disgusted', 'BGCharCamera', 24, false);
				ghostBopper.animation.play('bop');

				bopper = new FlxSprite();
				bopper.frames = Paths.getSparrowAtlas('BGCharDance', 'rhythm');
				bopper.animation.addByPrefix('bop', 'BGCharDance', 24, false);
				bopper.animation.addByIndices('bop disgusted', 'BGCharCamera', [0], '', 24, false);
				bopper.animation.play('bop');
		}

		bopper.animation.play('bop disgusted');

		bopper.alpha = .85;
		ghostBopper.alpha = 0.6;
		ghostBopper.color = 0xFF666688;

		add(ghostBopper);
		add(bopper);

		super.create();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (FlxG.mouse.wheel != 0)
			FlxG.camera.zoom += (FlxG.mouse.wheel / 10);

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

		var multiplier = 1;
		if (FlxG.keys.pressed.SHIFT)
			multiplier = 10;
		var checkArray = [checkKey('UP'), checkKey('DOWN'), checkKey('LEFT'), checkKey('RIGHT')];
		if (checkArray[0])
			bopper.offset.y += 1 * multiplier;
		if (checkArray[1])
			bopper.offset.y -= 1 * multiplier;
		if (checkArray[2])
			bopper.offset.x += 1 * multiplier;
		if (checkArray[3])
			bopper.offset.x -= 1 * multiplier;

		if (checkKey('Y'))
			trace('offset.set(${bopper.offset.x}, ${bopper.offset.y});');

		if (checkKey('R'))
			bopper.offset.set(0, 0);

		if (checkKey('SPACE'))
			bopper.animation.play('bop disgusted');

		if (checkKey('ESCAPE'))
			CoolUtil.switchState(MainMenuState);
	}
}
