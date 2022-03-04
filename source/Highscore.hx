package;

import flixel.util.FlxSave;

class Highscore
{
	public static var daSave:FlxSave;
	public static var songScores:Map<String, Int> = new Map();

	public static function saveScore(song:String, score:Int = 0, ?diff:Int = 0):Void
	{
		var daSong:String = CoolUtil.formatSong(song, diff);

		if (songScores.exists(daSong))
		{
			if (songScores.get(daSong) < score)
				setScore(daSong, score);
		}
		else
			setScore(daSong, score);
	}

	public static function saveWeekScore(week:Int = 1, score:Int = 0, ?diff:Int = 0):Void
	{
		var daWeek:String = CoolUtil.formatSong('week' + week, diff);

		if (songScores.exists(daWeek))
		{
			if (songScores.get(daWeek) < score)
				setScore(daWeek, score);
		}
		else
			setScore(daWeek, score);
		daSave.flush();
	}

	/**
	 * YOU SHOULD FORMAT SONG WITH formatSong() BEFORE TOSSING IN SONG VARIABLE
	 */
	static function setScore(song:String, score:Int):Void
	{
		// Reminder that I don't need to format this song, it should come formatted!
		songScores.set(song, score);
		daSave.data.songScores = songScores;
		daSave.flush();
	}

	public static function getScore(song:String, diff:Int):Int
	{
		if (!songScores.exists(CoolUtil.formatSong(song, diff)))
			setScore(CoolUtil.formatSong(song, diff), 0);

		return songScores.get(CoolUtil.formatSong(song, diff));
	}

	public static function getWeekScore(week:Int, diff:Int):Int
	{
		if (!songScores.exists(CoolUtil.formatSong('week' + week, diff)))
			setScore(CoolUtil.formatSong('week' + week, diff), 0);

		return songScores.get(CoolUtil.formatSong('week' + week, diff));
	}

	public static function load():Void
	{
		daSave = new FlxSave();
		daSave.bind('scores', 'saves');
		if (daSave.data.songScores != null)
		{
			songScores = daSave.data.songScores;
		}
	}
}
