import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;

class ArrowGrp extends FlxTypedGroup<FlxSprite>
{
	public function new()
	{
		super();
		for (i in 0...4)
		{
			var arrow = new FlxSprite(1000, 500);
			arrow.frames = Paths.getSparrowAtlas('arrow');
			arrow.animation.addByPrefix('idle', "arrow0");
			arrow.animation.addByPrefix('press', "arrow push");
			arrow.animation.play('idle');
			arrow.angle = 90 * i;
			switch (i)
			{
				case 0:
					arrow.ID = 0;
				case 1:
					arrow.ID = 2;
					arrow.x += 50;
					arrow.y -= 50;
				case 2:
					arrow.ID = 3;
					arrow.x += 100;
				case 3:
					arrow.ID = 1;
					arrow.x += 50;
					arrow.y += 50;
			}
			add(arrow);
		}
	}
}
