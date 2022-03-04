package;

class SongsData
{
	public static final pixelSongs = ['senpai', 'roses', 'thorns'];
	public static var songWithLessOrMoreDiffies:Map<String, Array<Int>>;

	public static function init():Void
	{
		songWithLessOrMoreDiffies = new Map<String, Array<Int>>();
		songWithLessOrMoreDiffies['test'] = [1];
	}

	public static function getSongDiffies(song:String):Array<Int>
	{
		if (songWithLessOrMoreDiffies.exists(song))
			return songWithLessOrMoreDiffies[song];
		else
		{
			var num = 0;
			var numArray:Array<Int> = [];

			@:privateAccess
			for (i in 0...CoolUtil.difficultyArray.length)
			{
				numArray.push(num);
				num++;
			}
			return numArray;
		}
	}
}
