package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxSpriteGroup;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.ui.FlxButton;

using StringTools;

// copyed from flxvirtualpad
class Hitbox extends FlxSpriteGroup
{
	public var hitbox:FlxSpriteGroup;

	var sizex:Int = 320;

	var screensizey:Int = 720;

	public var left:FlxButton;
	public var down:FlxButton;
	public var up:FlxButton;
	public var right:FlxButton;

	public static var sufixFile:String = "";

	public function new(?widghtScreen:Int, ?heightScreen:Int)
	{
		sufixFile = '-${Note.getNoteStyle().toLowerCase()}';
		super(widghtScreen, heightScreen);

		sizex = widghtScreen != null ? Std.int(widghtScreen / 4) : 320;
		hitbox = new FlxSpriteGroup();
		hitbox.scrollFactor.set();

		var hitbox_hint:FlxSprite = new FlxSprite(0, 0).loadGraphic(Paths.image('mobileControls/hitbox_hint$sufixFile', 'shared'));
		hitbox_hint.alpha = 0.2;

		add(hitbox_hint);

		hitbox.add(add(left = createhitbox(sizex * 0, "left")));

		hitbox.add(add(down = createhitbox(sizex * 1, "down")));

		hitbox.add(add(up = createhitbox(sizex * 2, "up")));

		hitbox.add(add(right = createhitbox(sizex * 3, "right")));
	}

	public function createhitbox(X:Float, framestring:String)
	{
		var button = new FlxButton(X, 0);
		var frames = Paths.getSparrowAtlas('mobileControls/hitbox$sufixFile', 'shared', 'mobileControls/hitbox');
		button.loadGraphic(FlxGraphic.fromFrame(frames.getByName(framestring)));

		button.alpha = 0;

		button.onDown.callback = function()
		{
			FlxTween.num(0, 0.75, .075, {ease: FlxEase.circInOut}, function(a:Float)
			{
				button.alpha = a;
			});
		};

		button.onUp.callback = function()
		{
			FlxTween.num(0.75, 0, .1, {ease: FlxEase.circInOut}, function(a:Float)
			{
				button.alpha = a;
			});
		}

		button.onOut.callback = function()
		{
			FlxTween.num(button.alpha, 0, .2, {ease: FlxEase.circInOut}, function(a:Float)
			{
				button.alpha = a;
			});
		}

		return button;
	}

	override public function destroy():Void
	{
		super.destroy();

		left = null;
		down = null;
		up = null;
		right = null;
	}
}
