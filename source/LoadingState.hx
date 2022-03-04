package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.math.FlxMath;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import haxe.io.Path;
import lime.app.Future;
import lime.app.Promise;
import lime.utils.AssetLibrary;
import lime.utils.AssetManifest;
import lime.utils.Assets as LimeAssets;
import openfl.utils.Assets;

class LoadingState extends MusicBeatState
{
	inline static var MIN_TIME = 1.0;

	var target:Class<FlxState>;
	var stopMusic = false;
	var callbacks:MultiCallback;
	var loadBar:FlxSprite;
	var funkay:FlxSprite;
	var targetShit = 0.0;
	var fakeRemaining = 4;
	var isFake:Bool;

	static var loadedSongs:Array<String> = [];

	function new(target:Class<FlxState>, stopMusic:Bool, fake:Bool = #if NO_PRELOAD_ALL false #else true #end)
	{
		super();
		this.target = target;
		isFake = fake;
		this.stopMusic = stopMusic;
		if (PlayState.SONG != null)
		{
			ignoreThis = loadedSongs.contains(PlayState.SONG.song.toLowerCase());
			if (curSong == 'ratio' && !ignoreThis)
			{
				Paths.getSparrowAtlas('squizzle/bfPixelSquizzle', 'rhythm');
				Paths.image('icons/bf-dizzle-pixel');
				Paths.image('icons/dizzle-spirit');
			}
		}
	}

	override function create()
	{
		#if PRELOAD_ALL
		Assets.cache.clear("songs");

		FlxG.bitmap.clearCache();
		FlxG.bitmap.clearUnused();
		FlxG.bitmap.dumpCache();
		// FlxG.bitmap.reset();
		Assets.cache.clear();
		LimeAssets.cache.clear();
		#end
		trace(loadedSongs);
		if (ignoreThis)
		{
			onLoad();
			return;
		}
		var funkayBG = new FlxSprite(-900, -900).makeGraphic(10000, 10000, 0xFFcaff4d);
		funkayBG.antialiasing = getPref('antialiasing');
		add(funkayBG);
		funkay = new FlxSprite(0, 0, Paths.image('Rloading', 'rhythm'));
		funkay.setGraphicSize(0, FlxG.height);
		funkay.updateHitbox();
		funkay.antialiasing = getPref('antialiasing');
		add(funkay);
		funkay.scrollFactor.set();
		funkay.screenCenter();
		loadBar = new FlxSprite(0, FlxG.height - 20).makeGraphic(FlxG.width, 10, -59694);
		loadBar.screenCenter(X);
		add(loadBar);

		if (!isFake)
			initSongsManifest().onComplete(function(lib)
			{
				callbacks = new MultiCallback(onLoad);
				var introComplete = callbacks.add("introComplete");
				checkLoadSong(getSongPath());
				if (PlayState.SONG.needsVoices)
					checkLoadSong(getVocalPath());
				checkLibrary("shared");
				if (PlayState.curWeek > 0)
					checkLibrary("week" + PlayState.curWeek);
				else
					checkLibrary("tutorial");

				var fadeTime = 0.5;
				FlxG.camera.fade(FlxG.camera.bgColor, fadeTime, true);
				new FlxTimer().start(fadeTime + MIN_TIME, function(_) introComplete());
			});
		else
		{
			new FlxTimer().start(FlxG.random.float(minFakeTime, maxFakeTime), function(tmr:FlxTimer)
			{
				fakeRemaining--;
			}, 4);
			new FlxTimer().start(maxFakeTime * 4, function(tmr:FlxTimer)
			{
				fakeRemaining = 0;
			});
		}
	}

	static inline final maxFakeTime = #if mobileC .5 #else .25 #end;
	static inline final minFakeTime = #if mobileC .1 #else .05 #end;

	function checkLoadSong(path:String)
	{
		if (!Assets.cache.hasSound(path))
		{
			var library = Assets.getLibrary("songs");
			final symbolPath = path.split(":").pop();
			// @:privateAccess
			// library.types.set(symbolPath, SOUND);
			// @:privateAccess
			// library.pathGroups.set(symbolPath, [library.__cacheBreak(symbolPath)]);
			var callback = callbacks.add("song:" + path);
			Assets.loadSound(path).onComplete(function(_)
			{
				callback();
			});
		}
	}

	function checkLibrary(library:String)
	{
		trace(Assets.hasLibrary(library));
		if (Assets.getLibrary(library) == null)
		{
			@:privateAccess
			if (!LimeAssets.libraryPaths.exists(library))
				throw "Missing library: " + library;

			var callback = callbacks.add("library:" + library);
			Assets.loadLibrary(library).onComplete(function(_)
			{
				callback();
			});
		}
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
		if (ignoreThis)
			return;
		funkay.setGraphicSize(Std.int(.88 * FlxG.width + .9 * (funkay.width - .88 * FlxG.width)));
		funkay.updateHitbox();
		#if FLX_TOUCH
		var touchJustPressed = false;
		for (touch in FlxG.touches.list)
			if (touch.justPressed)
				touchJustPressed = true;
		#end
		if (controls.ACCEPT #if FLX_TOUCH || touchJustPressed #end)
		{
			funkay.setGraphicSize(Std.int(funkay.width + 60));
			funkay.updateHitbox();
		}
		if (!isFake)
		{
			if (callbacks != null)
				targetShit = FlxMath.remapToRange(callbacks.numRemaining / callbacks.length, 1, 0, 0, 1);
		}
		else
		{
			targetShit = FlxMath.remapToRange(fakeRemaining / 4, 1, 0, 0, 1);
			if (fakeRemaining == 0)
				onLoad();
		}

		loadBar.scale.x += .5 * (targetShit - loadBar.scale.x);
	}

	inline function onLoad()
	{
		if (stopMusic && FlxG.sound.music != null)
			FlxG.sound.music.stop();
		if (PlayState.SONG != null)
			loadedSongs.push(PlayState.SONG.song.toLowerCase());
		switchState(target);
	}

	var ignoreThis = false;

	inline static function getSongPath()
		return Paths.inst(PlayState.SONG.song);

	inline static function getVocalPath()
		return Paths.voices(PlayState.SONG.song);

	inline static public function loadAndSwitchState(target:Class<FlxState>, stopMusic = false, fake:Bool = #if NO_PRELOAD_ALL false #else true #end)
		CoolUtil.switchState(getNextState(target, stopMusic, fake), [target, stopMusic, fake]);

	static function getNextState(target:Class<FlxState>, stopMusic = false, fake:Bool):Class<FlxState>
	{
		Paths.setCurrentLevel("week" + PlayState.curWeek);
		#if NO_PRELOAD_ALL
		var loaded:Bool = false;
		if (!fake)
			loaded = isSoundLoaded(getSongPath())
				&& (!PlayState.SONG.needsVoices || isSoundLoaded(getVocalPath()))
				&& isLibraryLoaded("shared");

		if (!loaded)
		#end
		return LoadingState;

		if (stopMusic && FlxG.sound.music != null)
			FlxG.sound.music.stop();

		return target;
	}

	#if NO_PRELOAD_ALL
	static function isSoundLoaded(path:String):Bool
	{
		return Assets.cache.hasSound(path);
	}

	static function isLibraryLoaded(library:String):Bool
	{
		return Assets.getLibrary(library) != null;
	}
	#end

	override function destroy()
	{
		super.destroy();

		callbacks = null;
	}

	static function initSongsManifest()
	{
		var id = "songs";
		var promise = new Promise<AssetLibrary>();

		var library = LimeAssets.getLibrary(id);

		if (library != null)
		{
			return Future.withValue(library);
		}

		var path = id;
		var rootPath = null;

		@:privateAccess
		var libraryPaths = LimeAssets.libraryPaths;
		if (libraryPaths.exists(id))
		{
			path = libraryPaths[id];
			rootPath = Path.directory(path);
		}
		else
		{
			if (StringTools.endsWith(path, ".bundle"))
			{
				rootPath = path;
				path += "/library.json";
			}
			else
			{
				rootPath = Path.directory(path);
			}
			@:privateAccess
			path = LimeAssets.__cacheBreak(path);
		}

		AssetManifest.loadFromFile(path, rootPath).onComplete(function(manifest)
		{
			if (manifest == null)
			{
				promise.error("Cannot parse asset manifest for library \"" + id + "\"");
				return;
			}

			var library = AssetLibrary.fromManifest(manifest);

			if (library == null)
			{
				promise.error("Cannot open library \"" + id + "\"");
			}
			else
			{
				@:privateAccess
				LimeAssets.libraries.set(id, library);
				library.onChange.add(LimeAssets.onChange.dispatch);
				promise.completeWith(Future.withValue(library));
			}
		}).onError(function(_)
		{
				promise.error("There is no asset library with an ID of \"" + id + "\"");
		});

		return promise.future;
	}
}

class MultiCallback
{
	public var callback:Void->Void;
	public var logId:String = null;
	public var length(default, null) = 0;
	public var numRemaining(default, null) = 0;

	var unfired = new Map<String, Void->Void>();
	var fired = new Array<String>();

	public function new(callback:Void->Void, logId:String = null)
	{
		this.callback = callback;
		this.logId = logId;
	}

	public function add(id = "untitled")
	{
		id = '$length:$id';
		length++;
		numRemaining++;
		var func:Void->Void = null;
		func = function()
		{
			if (unfired.exists(id))
			{
				unfired.remove(id);
				fired.push(id);
				numRemaining--;

				if (logId != null)
					log('fired $id, $numRemaining remaining');

				if (numRemaining == 0)
				{
					if (logId != null)
						log('all callbacks fired');
					callback();
				}
			}
			else
				log('already fired $id');
		}
		unfired[id] = func;
		return func;
	}

	inline function log(msg):Void
	{
		if (logId != null)
			trace('$logId: $msg');
	}

	public function getFired()
		return fired.copy();

	public function getUnfired()
		return [for (id in unfired.keys()) id];
}
