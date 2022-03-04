#if ALLOW_ALONE_FUNKIN
package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.util.FlxColor;

using StringTools;

class AloneFunkinState extends MusicBeatState
{
	override function create()
	{
		add(new MenuBG(DESAT_BORDER));

		final fullScreen = FlxG.fullscreen;
		FlxG.fullscreen = false;
		var textUI = new FlxText(125, 153, 'Drag and drop the chart of you want to play. The folder where the chart is located has to be like this:', 20);
		textUI.fieldWidth = 700;
		textUI.setFormat(Paths.font("vcr.ttf"), 52, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		textUI.scrollFactor.set();
		textUI.borderSize = 1.25;
		add(textUI);

		var screenshot = new FlxSprite(textUI.x, textUI.y + 250, Paths.image('chartExample'));
		screenshot.setGraphicSize(Std.int(screenshot.width * 1.6));
		screenshot.updateHitbox();
		add(screenshot);

		lime.app.Application.current.window.onDropFile.add(function(path:String)
		{
			if (path.endsWith('.json'))
			{
				PlayState.loadSong(path, 0, flixel.util.FlxColor.WHITE, false, false, true);
				FlxG.fullscreen = fullScreen;
				lime.app.Application.current.window.onDropFile.removeAll();
			}
		});

		super.create();
	}

	override function update(elapsed:Float)
	{
		if (controls.BACK)
			switchState(FreeplayState);
		super.update(elapsed);
	}
}
#end
