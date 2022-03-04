#if mobileC
package;

import FlxVirtualPad;
import Hitbox;
import PreferencesMenu.getPref;
import flixel.FlxG;
import flixel.group.FlxSpriteGroup;

class MobileControls extends FlxSpriteGroup
{
	public var _pad:FlxVirtualPad;
	public var _hitbox:Hitbox;

	public var controlMode:Int = 0;

	private var controls(get, never):Controls;

	inline function get_controls():Controls
		return PlayerSettings.player1.controls;

	// keys
	public var NOTE_UP:Bool;
	public var NOTE_RIGHT:Bool;
	public var NOTE_DOWN:Bool;
	public var NOTE_LEFT:Bool;

	public var NOTE_UP_P:Bool;
	public var NOTE_RIGHT_P:Bool;
	public var NOTE_DOWN_P:Bool;
	public var NOTE_LEFT_P:Bool;

	public var NOTE_UP_R:Bool;
	public var NOTE_RIGHT_R:Bool;
	public var NOTE_DOWN_R:Bool;
	public var NOTE_LEFT_R:Bool;

	public function new()
	{
		super();

		controlMode = cast(getPref('mobileControlsType'), Int);

		switch (controlMode)
		{
			case 0: // right default
				_pad = new FlxVirtualPad(RIGHT_FULL, NONE);
				_pad.alpha = 0.75;
				this.add(_pad);
			case 1: // left default
				_pad = new FlxVirtualPad(FULL, NONE);
				_pad.alpha = 0.75;
				this.add(_pad);
			case 2: // left default
				_pad = new FlxVirtualPad(DOUBLE_FULL, NONE);
				_pad.alpha = 0.75;
				this.add(_pad);
			case 3:
			case 4: // custom
				_pad = new FlxVirtualPad(CUSTOM, NONE);
				_pad.alpha = 0.75;
				this.add(_pad);
			case 5:
				_hitbox = new Hitbox();
				add(_hitbox);
			default: // default (0)
				_pad = new FlxVirtualPad(RIGHT_FULL, NONE);
				_pad.alpha = 0.75;
				this.add(_pad);
		}
	}

	override public function update(elapsed:Float)
	{
		group.update(elapsed);

		if (moves)
			updateMotion(elapsed);

		switch (controlMode)
		{
			default:
				NOTE_UP = _pad.buttonUp.pressed;
				NOTE_RIGHT = _pad.buttonRight.pressed;
				NOTE_DOWN = _pad.buttonDown.pressed;
				NOTE_LEFT = _pad.buttonLeft.pressed;

				NOTE_UP_P = _pad.buttonUp.justPressed;
				NOTE_RIGHT_P = _pad.buttonRight.justPressed;
				NOTE_DOWN_P = _pad.buttonDown.justPressed;
				NOTE_LEFT_P = _pad.buttonLeft.justPressed;

				NOTE_UP_R = _pad.buttonUp.justReleased;
				NOTE_RIGHT_R = _pad.buttonRight.justReleased;
				NOTE_DOWN_R = _pad.buttonDown.justReleased;
				NOTE_LEFT_R = _pad.buttonLeft.justReleased;

			case 2:
				NOTE_UP = _pad.buttonUp.pressed || _pad.buttonUp2.pressed;
				NOTE_RIGHT = _pad.buttonRight.pressed || _pad.buttonRight2.pressed;
				NOTE_DOWN = _pad.buttonDown.pressed || _pad.buttonDown2.pressed;
				NOTE_LEFT = _pad.buttonLeft.pressed || _pad.buttonLeft2.pressed;

				NOTE_UP_P = _pad.buttonUp.justPressed || _pad.buttonUp2.justPressed;
				NOTE_RIGHT_P = _pad.buttonRight.justPressed || _pad.buttonRight2.justPressed;
				NOTE_DOWN_P = _pad.buttonDown.justPressed || _pad.buttonDown2.justPressed;
				NOTE_LEFT_P = _pad.buttonLeft.justPressed || _pad.buttonLeft2.justPressed;

				NOTE_UP_R = _pad.buttonUp.justReleased || _pad.buttonUp2.justReleased;
				NOTE_RIGHT_R = _pad.buttonRight.justReleased || _pad.buttonRight2.justReleased;
				NOTE_DOWN_R = _pad.buttonDown.justReleased || _pad.buttonDown2.justReleased;
				NOTE_LEFT_R = _pad.buttonLeft.justReleased || _pad.buttonLeft2.justReleased;

			case 3:
				NOTE_UP = controls.NOTE_UP;
				NOTE_RIGHT = controls.NOTE_RIGHT;
				NOTE_DOWN = controls.NOTE_DOWN;
				NOTE_LEFT = controls.NOTE_LEFT;

				NOTE_UP_P = controls.NOTE_UP_P;
				NOTE_RIGHT_P = controls.NOTE_RIGHT_P;
				NOTE_DOWN_P = controls.NOTE_DOWN_P;
				NOTE_LEFT_P = controls.NOTE_LEFT_P;

				NOTE_UP_R = controls.NOTE_UP_R;
				NOTE_RIGHT_R = controls.NOTE_RIGHT_R;
				NOTE_DOWN_R = controls.NOTE_DOWN_R;
				NOTE_LEFT_R = controls.NOTE_LEFT_R;

			case 5:
				NOTE_UP = _hitbox.up.pressed;
				NOTE_RIGHT = _hitbox.right.pressed;
				NOTE_DOWN = _hitbox.down.pressed;
				NOTE_LEFT = _hitbox.left.pressed;

				NOTE_UP_P = _hitbox.up.justPressed;
				NOTE_RIGHT_P = _hitbox.right.justPressed;
				NOTE_DOWN_P = _hitbox.down.justPressed;
				NOTE_LEFT_P = _hitbox.left.justPressed;

				NOTE_UP_R = _hitbox.up.justReleased;
				NOTE_RIGHT_R = _hitbox.right.justReleased;
				NOTE_DOWN_R = _hitbox.down.justReleased;
				NOTE_LEFT_R = _hitbox.left.justReleased;
		}
	}

	public static var androidBack(get, never):Bool;

	private static inline function get_androidBack():Bool
		return #if android FlxG.android.justReleased.BACK #else false #end;
}
#end
