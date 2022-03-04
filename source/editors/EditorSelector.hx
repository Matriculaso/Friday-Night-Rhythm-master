import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;

class EditorSelector extends MusicBeatSubstate
{
	var editorsName:Array<String> = ['Alphabet Character Editor'];
	var editors:Array<Class<FlxState>> = [AlphabetCharEditor];
	var list:AlphabetList;

	public function new():Void
	{
		var bg = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		bg.alpha = 0;
		bg.scrollFactor.set();
		add(bg);
		FlxTween.tween(bg, {alpha: 0.6}, 0.4, {ease: FlxEase.quartInOut});
		list = new AlphabetList(editorsName);
		add(list);

		super();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
		if (controls.ACCEPT)
		{
			close();
			CoolUtil.switchState(editors[list.selectedIndex]);
		}
		if (controls.BACK)
			close();
	}

	public static function open():Void
	{
		var state = FlxG.state;
		state.persistentUpdate = false;
		state.persistentDraw = true;
		state.openSubState(new EditorSelector());
	}
}
