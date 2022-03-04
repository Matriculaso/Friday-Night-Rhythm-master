package;

typedef WeekClass =
{
	var library:String;
	var weekName:String;
	var weekSongs:Array<String>;
	var weekFile:String;
	var weekCharacter:String;
	var weekColor:flixel.util.FlxColor;
}

class Weeks
{
	public static var librariesNames = [
		'tutorial',
		'week1',
		'week2',
		'week3',
		'week4',
		'week5',
		'week6',
		'rhythm',
		'rhythm'
	];
	public static var weeksNames = [
		'How To Funk',
		'Daddy Dearest',
		'Spooky Month!',
		'Go Pico!, yeah! yeah!',
		'Mommy Must Murder',
		'Red Snow',
		'dating simulator ft. moawling',
		'Rhythm Heaven',
		'Squizzle Dizzle'
	];
	public static var weeksSongs = [
		['Tutorial'],
		['Bopeebo', 'Fresh', 'Dad-Battle'],
		['Spookeez', 'South', "Monster"],
		['Pico', 'Philly-Nice', "Blammed"],
		['Satin-Panties', "High", "M.I.L.F"],
		['Cocoa', 'Eggnog', 'Winter-Horrorland'],
		['Senpai', 'Roses', 'Thorns'],
		['Rhythm-Report', 'Questionnaire', 'Ringside'],
		['Ratio']
	];
	public static var weeksFiles = [
		'tutorial',
		'week1',
		'week2',
		'week3',
		'week4',
		'week5',
		'week6',
		'tutorial',
		'tutorial'
	];
	public static var weeksCharacters = [
		'dad',
		'dad',
		'spooky',
		'pico',
		'mom',
		'parents-christmas',
		'senpai',
		'dad',
		'dad'
	];
	public static var weeksColors = [
		-7179779,
		-7179779,
		-14535868,
		-7072173,
		-223529,
		-6237697,
		-34625,
		0xFFed698a,
		0xFFfed189
	];
	public static var lockedWeeks = [-1];
}
