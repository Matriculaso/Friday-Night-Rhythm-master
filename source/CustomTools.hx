package;

class CustomTools
{
	public static function capitalize(s:String, spliter:String = ' '):String
	{
		if (!['M.I.L.F'].contains(s.toUpperCase()))
		{
			var splited = s.split(spliter);
			var shitOutput:Array<String> = [];
			for (i in splited)
			{
				var tempI = i.toLowerCase();
				tempI = tempI.charAt(0).toUpperCase() + tempI.substring(1);
				shitOutput.push(tempI);
			}
			// join the words
			return shitOutput.join(spliter);
		}
		else
			return s.toUpperCase();
	}

	/**
	 * IT **ROUNDS** THE FLOAT
	 */
	public static inline function int(f:Float):Int
		return Std.int(f);

	public static function truncate(f:Float):Int
		return Std.parseInt(Std.string(f).split('.')[0]); // ! 3.68 => '3.68' => ['3', '68'] => '3' => 3
}
