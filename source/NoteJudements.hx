package;

class NoteJudements
{
	static final judementsArray = [
		'shit', // - SHIT
		'bad', // - BAD
		'good', // - GOOD
		'sick' // - SICK
	];

	static final judementTimeArray = [
		166, // - SHIT
		135, // - BAD
		90, // - GOOD
		45 // - SICK
	];

	static final judementHitAccuracy = [
		// + USED TO CALCULATE ACCURACY
		0, // - SHIT
		0.25, // - BAD
		0.50, // - GOOD
		1, // - SICK
	];

	static final judementRatings:Array<String> = [
		'FC', // - 100%
		'S', // - > 95%
		'A', // - > 90%
		'B', // - > 80%
		'C', // - > 75%
		'D' // - < 75%
	];

	public static function getJudement(daNote:Note):String
	{
		var noteDiff:Float = Math.abs(daNote.strumTime - Conductor.songPosition);

		for (i in 0...judementTimeArray.length)
		{
			var daTime = judementTimeArray[i];
			var nextTime = i + 1 > judementTimeArray.length - 1 ? 0 : judementTimeArray[i + 1];
			if (noteDiff < daTime && noteDiff >= nextTime)
			{
				switch (i)
				{
					case 0:
						return "shit";
					case 1:
						return "bad";
					case 2:
						return "good";
					case 3:
						return "sick";
				}
			}
		}
		return "shit";
	}

	public static inline function getJudementAccuracy(daJudement:String):Float
		return judementHitAccuracy[judementsArray.indexOf(daJudement)];

	public static function calculateRating(accuracy:Float):String
	{
		if (Math.isFinite(accuracy))
		{
			if (accuracy == 100)
				return judementRatings[0];
			else
			{
				if (accuracy >= 95)
					return judementRatings[1];
				else if (accuracy >= 90)
					return judementRatings[2];
				else if (accuracy >= 80)
					return judementRatings[3];
				else if (accuracy >= 75)
					return judementRatings[4];
				else
					return judementRatings[5];
			}
		}

		return '?';
	}
}
