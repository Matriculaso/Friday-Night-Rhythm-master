package;

import flixel.FlxSprite;

class MainMenuItem extends FlxSprite
{
	var fireInstantly = false;
	var name:String;

	public function new(x:Float = 0, y:Float = 0, _name:String, ?_callback:Void->Void)
	{
		super(x, y);
		antialiasing = PreferencesMenu.getPref('antialiasing');
		setData(_name, _callback);
	}

	public function setData(_name:String, b)
	{
		name = _name;
	}
}
