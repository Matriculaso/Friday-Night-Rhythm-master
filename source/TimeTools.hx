package;

class TimeTools
{
	public static function convertTime(time:Float, oldTimeType:TimeType, toTimeType:TimeType):Float
	{
		var timeToSeconds = toSeconds(time, oldTimeType);
		return switch (toTimeType)
		{
			case MS:
				timeToSeconds * 1000;
			case SEC:
				timeToSeconds;
			case MIN:
				timeToSeconds / 60;
			case HOUR:
				timeToSeconds / 3600;
		};
	}

	public static function toSeconds(time:Float, timeType:TimeType):Float
	{
		return switch (timeType)
		{
			case MS:
				time / 1000;
			case SEC:
				time;
			case MIN:
				time * 60;
			case HOUR:
				time * 3600;
		};
	}
}

enum TimeType
{
	MS;
	SEC;
	MIN;
	HOUR;
}
