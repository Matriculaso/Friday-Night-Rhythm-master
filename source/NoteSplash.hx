package;

import flixel.FlxG;

class NoteSplash extends flixel.FlxSprite
{
	public function new(x:Float, y:Float, noteData:Int)
	{
		super(x, y);
		frames = Character.joinFrames(['noteSplashes', 'noteSplashesBar'], 'shared');
		var downscroll = getPref('downscroll');
		animation.addByPrefix("note0-0", "note impact 1 purple", 24, false, false, downscroll);
		animation.addByPrefix("note0-1", "note impact 2 purple", 24, false, false, downscroll);
		animation.addByPrefix("note1-0", "note impact 1 blue", 24, false, false, downscroll);
		animation.addByPrefix("note1-1", "note impact 2 blue", 24, false, false, downscroll);
		animation.addByPrefix("note2-0", "note impact 1 green", 24, false, false, downscroll);
		animation.addByPrefix("note2-1", "note impact 2 green", 24, false, false, downscroll);
		animation.addByPrefix("note3-0", "note impact 1 red", 24, false, false, downscroll);
		animation.addByPrefix("note3-1", "note impact 2 red", 24, false, false, downscroll);
		animation.addByPrefix("note4-0", "note impact 1 orange", 24, false, false, downscroll);
		animation.addByPrefix("note4-1", "note impact 2 orange", 24, false, false, downscroll);

		antialiasing = getPref('antialiasing');

		setupNoteSplash(x, y, noteData);
	}

	public function setupNoteSplash(x:Float, y:Float, noteData:Int):Void
	{
		setPosition(x, y);
		alpha = .6;
		animation.play('note${noteData}-${FlxG.random.int(0, 1)}', true);
		animation.curAnim.frameRate = 24 + FlxG.random.int(-2, 2);
		updateHitbox();
		offset.set(.3 * width, .3 * height);
	}

	override function update(elapsed:Float)
	{
		if (animation.curAnim.finished)
			kill();

		super.update(elapsed);
	}

	public static function spawnSplash(playState:PlayState, daNote:Note, player:Int, barrrrr = false, iii = 0):Void
	{
		if (!getPref('note-splashes') || daNote.isSustainNote)
			return;
		if (player == 2 && getPref('midscroll'))
			return;

		var splash = playState.grpNoteSplashes.recycle(NoteSplash);
		splash.setupNoteSplash(daNote.x + (barrrrr ? (Note.swagWidth * iii) : 0), daNote.y, !barrrrr ? daNote.noteData : 4);
		playState.grpNoteSplashes.add(splash);
	}
}
