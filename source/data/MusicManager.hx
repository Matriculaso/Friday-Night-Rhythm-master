package;

import flixel.FlxG;

class MusicManager
{
	public static inline function playMainMusic(?volume:Float = 1):Void
	{
		FlxG.sound.playMusic(Paths.music('freakyMenu'), volume);
		Conductor.changeBPM(BPMList.mainMenuStateBPM);
	}

	public static inline function checkPlaying():Void
	{
		if (FlxG.sound.music != null)
		{
			if (!FlxG.sound.music.playing)
				MusicManager.playMainMusic();
		}
	}
}
