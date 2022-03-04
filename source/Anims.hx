typedef Anim =
{
	var name:String; // Anim Name
	@:optional var frameRate:Int; // Anim Frame Rate
	@:optional var loop:Bool; // Anim Looped
	@:optional var offsets:Array<Int>; // Anim Offsets
	@:optional var playerOffsets:Array<Int>; // Anim Player Offsets (only for a Character)
	@:optional var indices:Array<Int>; // Anim Indices
}

class Anims
{
	public static function animFilter(anim:Anim):Anim
	{
		if (anim.frameRate == null)
			anim.frameRate = 24;

		if (anim.loop == null)
			anim.loop = false;

		if (anim.offsets == null)
			anim.offsets = [0, 0];

		if (anim.playerOffsets == null)
			anim.playerOffsets = [0, 0];

		return anim;
	}
}
