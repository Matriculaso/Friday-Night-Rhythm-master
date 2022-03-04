package;

import Section.SwagSection;
import haxe.Json;
import lime.utils.Assets;

using StringTools;

typedef SwagSong =
{
	var song:String;
	var notes:Array<SwagSection>;
	var bpm:Float;
	var needsVoices:Bool;
	var speed:Float;

	var player1:String;
	var player2:String;
}

class Song
{
	public static var curSong(get, never):String;

	public static inline function get_curSong():String
		return PlayState.SONG.song.toLowerCase() != null ? PlayState.SONG.song.toLowerCase() : '';

	public static var prettySong(get, never):String;

	public static function get_prettySong():String
		return curSong.capitalize('-').replace('-', ' ');

	public static function loadFromJson(jsonInput:String, ?folder:String):SwagSong
	{
		var rawJson = Assets.getText(Paths.json(folder.toLowerCase() + '/' + jsonInput.toLowerCase())).trim();

		while (!rawJson.endsWith("}"))
			rawJson = rawJson.substr(0, rawJson.length - 1);

		return parseJSONshit(rawJson);
	}

	#if windows
	public static function loadFromJsonFILE(jsonPath:String):SwagSong
	{
		var rawJson = sys.io.File.getContent(jsonPath).trim();

		while (!rawJson.endsWith("}"))
			rawJson = rawJson.substr(0, rawJson.length - 1);

		return parseJSONshit(rawJson);
	}
	#end

	public static function parseJSONshit(rawJson:String):SwagSong
	{
		var swagShit:SwagSong = cast Json.parse(rawJson).song;
		return swagShit;
	}
}
