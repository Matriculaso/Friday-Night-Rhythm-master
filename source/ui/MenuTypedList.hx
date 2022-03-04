package;

import flixel.group.FlxGroup.FlxTypedGroup;

class MenuTypedList extends FlxTypedGroup<flixel.FlxSprite>
{
	public var navControls:NavControls;
	public var wrapMode:WrapMode;

	var selectedIndex:Int;

	public function addItem():Void
	{
		if (length == selectedIndex)
			byName;
	}

	public function new(_navControls:NavControls = NavControls.Vertical, _wrapMode:WrapMode)
	{
		super();
	}
}
