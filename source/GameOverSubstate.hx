package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;

class GameOverSubstate extends MusicBeatSubstate
{
	var bf:Character;
	var camFollow:FlxObject;

	var stageSuffix:String = "";

	public function new(x:Float, y:Float)
	{
		var daStage = PlayState.curStage;
		switch (daStage)
		{
			case 'school', 'schoolEvil':
				stageSuffix = '-pixel';
		}

		super();

		Conductor.songPosition = 0;

		bf = new Character(x, y, CharactersData.getCharDead(PlayState.boyfriend.curCharacter), ['DEAD'], true, true);
		bf.setNewSize(PlayState.boyfriend.newSize);
		add(bf);

		camFollow = new FlxObject(bf.getGraphicMidpoint().x, bf.getGraphicMidpoint().y, 1, 1);
		add(camFollow);

		FlxG.sound.play(Paths.sound('fnf_loss_sfx' + stageSuffix));
		Conductor.changeBPM(100);

		FlxG.camera.scroll.set();
		FlxG.camera.target = null;

		bf.playAnim('firstDeath');

		_pad = new FlxVirtualPad(NONE, B);
		_pad.cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];
		#if mobileC
		add(_pad);
		#end
	}

	var _pad:FlxVirtualPad;

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		var accept = false;
		var back = false;
		#if mobileC
		for (touch in FlxG.touches.list)
			if (touch.overlaps(bf))
				accept = true;
		back = _pad.buttonB.justPressed;
		#else
		accept = controls.ACCEPT;
		back = controls.BACK;
		#end

		if (!isEnding)
		{
			if (accept)
				endBullshit();

			if (back && !isEnding)
			{
				FlxG.sound.music.stop();
				PlayState.exit();
			}
		}
		#if !mobileC
		else if (accept)
			LoadingState.loadAndSwitchState(PlayState);
		#end

		if (bf.animation.curAnim.name == 'firstDeath' && bf.animation.curAnim.curFrame == 12)
			FlxG.camera.follow(camFollow, LOCKON, 0.01);

		if (bf.animation.curAnim.name == 'firstDeath' && bf.animation.curAnim.finished)
			FlxG.sound.playMusic(Paths.music('gameOver' + stageSuffix));

		if (FlxG.sound.music.playing)
			Conductor.songPosition = FlxG.sound.music.time;
	}

	var isEnding:Bool = false;

	function endBullshit():Void
	{
		if (!isEnding)
		{
			isEnding = true;
			bf.playAnim('deathConfirm', true);
			FlxG.sound.music.stop();
			FlxG.sound.play(Paths.music('gameOverEnd' + stageSuffix));
			new FlxTimer().start(0.7, function(tmr:FlxTimer)
			{
				FlxG.camera.fade(FlxColor.BLACK, 2, false, function()
				{
					LoadingState.loadAndSwitchState(PlayState);
				});
			});
		}
	}
}
