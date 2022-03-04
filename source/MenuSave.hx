import flixel.FlxSprite;

class MenuSave extends FlxSprite
{
	public static final saves = ['bf', 'gf'];

	public var animOffsets:Map<String, Array<Dynamic>>;

	public var daSave:Int;

	public function new(x:Float, y:Float, _daSave:Int)
	{
		super(x, y);
		animOffsets = new Map<String, Array<Dynamic>>();
		daSave = _daSave;
		ID = daSave;
		frames = Paths.getSparrowAtlas('main-menu/$saveName-save');
		animation.addByPrefix('idle', 'idle', 24, false);
		animation.addByPrefix('selected', 'selected', 24, false);
		animation.addByIndices('unselected', 'selected', [4, 3, 2, 1, 0], '', 24, false);
		animation.addByPrefix('enter', 'enter', 24, false);
		animation.addByPrefix('alpha remove', 'alpha remove', 24, false);
		// animation.finishCallback = function(name:String)
		// {
		// 	if (name == 'unselected')
		// 		playAnim('idle');
		// }
		playAnim('idle');
		antialiasing = getPref('antialiasing');
		animOffsets["idle"] = [0, 0];
		animOffsets["unselected"] = [21, 10];
		animOffsets["enter"] = [21, 8];
		animOffsets["alpha remove"] = [10, 10];
		animOffsets["selected"] = [21, 8];
	}

	public function playAnim(AnimName:String)
	{
		animation.play(AnimName, true);
		var daOffset = animOffsets.get(AnimName);
		if (animOffsets.exists(AnimName))
			offset.set(daOffset[0], daOffset[1]);
		else
			offset.set(0, 0);
	}

	public var saveName(get, never):String;

	function get_saveName():String
		return saves[daSave];
}
