package;

/**
 * `this` is a simplified version of `FlxSprite` especially designed to be a Background Sprite.
 * @param spriteName [0] = SpriteName, [1] = Library
 * @param spriteArgs like pixel or something like that
 * @param x posX
 * @param y posY
 * @param scrollFactorX
 * @param scrollFactorY 
 * @param anims is the array than contains all anims from the .XML file
 * @param loop if the anims are looped
 */
class BGSprite extends flixel.FlxSprite
{
	var anims:Map<String, Anims.Anim> = [];
	var firstAnim:Anims.Anim;
	var spriteArgs:Array<SpriteArgs>;
	var haveAnims:Bool = true;

	public function new(spriteName:Array<String>, _spriteArgs:Array<SpriteArgs>, x:Float = 0, y:Float = 0, scrollFactorX:Float = 1, scrollFactorY:Float = 1,
			?_anims:Array<Anims.Anim>):Void
	{
		super(x, y);
		if (_anims == null)
		{
			haveAnims = false;
			_anims = [];
		}

		spriteArgs = _spriteArgs;
		for (anim in _anims)
			_anims[_anims.indexOf(anim)] = Anims.animFilter(anim);

		for (anim in _anims)
			anims[anim.name] = anim;

		firstAnim = _anims[0];

		if (haveAnims)
		{
			if (spriteArgs.contains(PACKER_ATLAS))
				frames = Paths.getPackerAtlas(spriteName[0], spriteName[1]);
			else
				frames = Paths.getSparrowAtlas(spriteName[0], spriteName[1]);
			for (anim in anims)
			{
				if (!spriteArgs.contains(PACKER_ATLAS))
				{
					if (anim.indices == null)
						animation.addByPrefix(anim.name, anim.name, anim.frameRate, anim.loop);
					else
						animation.addByIndices(anim.name, anim.name, anim.indices, '', anim.frameRate, anim.loop);
				}
				else
					animation.add(anim.name, anim.indices, anim.frameRate, anim.loop);
			}

			playAnim(firstAnim.name);
		}
		else
		{
			loadGraphic(Paths.image(spriteName[0], spriteName[1]));
			active = false;
		}

		scrollFactor.set(scrollFactorX, scrollFactorY);
		antialiasing = getPref('antialiasing') && !spriteArgs.contains(PIXEL);
	}

	public inline function playAnim(AnimName:String, Force:Bool = false, Reversed:Bool = false, Frame:Int = 0):Void
		animation.play(AnimName, Force, Reversed, Frame);

	public inline function dance(force:Bool = false):Void
		playAnim(firstAnim.name, force);

	override public function setGraphicSize(Width:Float = 0, Height:Float = 0)
	{
		super.setGraphicSize(Std.int(Width), Std.int(Height));
		if (!spriteArgs.contains(NO_UPDATEHITBOX))
			updateHitbox();
	}
}

enum SpriteArgs
{
	PIXEL;
	NO_UPDATEHITBOX;
	PACKER_ATLAS;
}
