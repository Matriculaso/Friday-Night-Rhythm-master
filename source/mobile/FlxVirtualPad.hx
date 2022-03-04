package;

import PreferencesMenu.getPref;
import flash.display.BitmapData;
import flixel.FlxG;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.graphics.frames.FlxTileFrames;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxPoint;
import flixel.system.FlxAssets;
import flixel.ui.FlxButton;
import flixel.util.FlxDestroyUtil;
import openfl.utils.ByteArray;

/**
 * A gamepad which contains 4 directional buttons and 4 action buttons.
 * It's easy to set the callbacks and to customize the layout.
 *
 * @author Ka Wing Chin
 */
@:keep @:bitmap("assets/shared/images/mobileControls/virtual-input.png")
class GraphicVirtualInput extends BitmapData
{
}

@:file("assets/shared/images/mobileControls/virtual-input.txt")
class VirtualInputData extends #if (lime_legacy || nme) ByteArray #else ByteArrayData #end
{
}

class FlxVirtualPad extends FlxSpriteGroup
{
	public var buttonA:FlxButton;
	public var buttonB:FlxButton;
	public var buttonC:FlxButton;
	public var buttonY:FlxButton;
	public var buttonX:FlxButton;
	public var buttonLeft:FlxButton;
	public var buttonUp:FlxButton;
	public var buttonRight:FlxButton;
	public var buttonDown:FlxButton;

	public var buttonLeft2:FlxButton;
	public var buttonUp2:FlxButton;
	public var buttonRight2:FlxButton;
	public var buttonDown2:FlxButton;

	/**
	 * Group of directions buttons.
	 */
	public var dPad:FlxSpriteGroup;

	/**
	 * Group of action buttons.
	 */
	public var actions:FlxSpriteGroup;

	/**
	 * Create a gamepad which contains 4 directional buttons and 4 action buttons.
	 *
	 * @param   DPadMode     The D-Pad mode. `FULL` for example.
	 * @param   ActionMode   The action buttons mode. `A_B_C` for example.
	 */
	public function new(?DPad:FlxDPadMode, ?Action:FlxActionMode)
	{
		super();
		scrollFactor.set();

		if (DPad == null)
			DPad = FULL;
		if (Action == null)
			Action = A_B_C;

		dPad = new FlxSpriteGroup();
		dPad.scrollFactor.set();

		actions = new FlxSpriteGroup();
		actions.scrollFactor.set();

		switch (DPad)
		{
			case UP_DOWN:
				dPad.add(add(buttonUp = createButton(0, FlxG.height - 85 * 3, 44 * 3, 45 * 3, "up")));
				dPad.add(add(buttonDown = createButton(0, FlxG.height - 45 * 3, 44 * 3, 45 * 3, "down")));
			case LEFT_RIGHT:
				dPad.add(add(buttonLeft = createButton(0, FlxG.height - 45 * 3, 44 * 3, 45 * 3, "left")));
				dPad.add(add(buttonRight = createButton(42 * 3, FlxG.height - 45 * 3, 44 * 3, 45 * 3, "right")));
			case UP_LEFT_RIGHT:
				dPad.add(add(buttonUp = createButton(35 * 3, FlxG.height - 81 * 3, 44 * 3, 45 * 3, "up")));
				dPad.add(add(buttonLeft = createButton(0, FlxG.height - 45 * 3, 44 * 3, 45 * 3, "left")));
				dPad.add(add(buttonRight = createButton(69 * 3, FlxG.height - 45 * 3, 44 * 3, 45 * 3, "right")));
			case FULL:
				dPad.add(add(buttonUp = createButton(35 * 3, FlxG.height - 116 * 3, 44 * 3, 45 * 3, "up")));
				dPad.add(add(buttonLeft = createButton(0, FlxG.height - 81 * 3, 44 * 3, 45 * 3, "left")));
				dPad.add(add(buttonRight = createButton(69 * 3, FlxG.height - 81 * 3, 44 * 3, 45 * 3, "right")));
				dPad.add(add(buttonDown = createButton(35 * 3, FlxG.height - 45 * 3, 44 * 3, 45 * 3, "down")));
			case RIGHT_FULL:
				dPad.add(add(buttonUp = createButton(FlxG.width - 86 * 3, FlxG.height - 66 - 116 * 3, 44 * 3, 45 * 3, "up")));
				dPad.add(add(buttonLeft = createButton(FlxG.width - 130 * 3, FlxG.height - 66 - 81 * 3, 44 * 3, 45 * 3, "left")));
				dPad.add(add(buttonRight = createButton(FlxG.width - 44 * 3, FlxG.height - 66 - 81 * 3, 44 * 3, 45 * 3, "right")));
				dPad.add(add(buttonDown = createButton(FlxG.width - 86 * 3, FlxG.height - 66 - 45 * 3, 44 * 3, 45 * 3, "down")));
			case DOUBLE_FULL:
				dPad.add(add(buttonUp = createButton(35 * 3, FlxG.height - 116 * 3, 44 * 3, 45 * 3, "up")));
				dPad.add(add(buttonLeft = createButton(0, FlxG.height - 81 * 3, 44 * 3, 45 * 3, "left")));
				dPad.add(add(buttonRight = createButton(69 * 3, FlxG.height - 81 * 3, 44 * 3, 45 * 3, "right")));
				dPad.add(add(buttonDown = createButton(35 * 3, FlxG.height - 45 * 3, 44 * 3, 45 * 3, "down")));
				dPad.add(add(buttonUp2 = createButton(FlxG.width - 86 * 3, FlxG.height - 66 - 116 * 3, 44 * 3, 45 * 3, "up")));
				dPad.add(add(buttonLeft2 = createButton(FlxG.width - 130 * 3, FlxG.height - 66 - 81 * 3, 44 * 3, 45 * 3, "left")));
				dPad.add(add(buttonRight2 = createButton(FlxG.width - 44 * 3, FlxG.height - 66 - 81 * 3, 44 * 3, 45 * 3, "right")));
				dPad.add(add(buttonDown2 = createButton(FlxG.width - 86 * 3, FlxG.height - 66 - 45 * 3, 44 * 3, 45 * 3, "down")));
			case CUSTOM:
				var nashing:Array<FlxPoint> = getPref('mobileCustomPositions');
				dPad.add(add(buttonUp = createButton(FlxG.width - 86 * 3, FlxG.height - 66 - 116 * 3, 44 * 3, 45 * 3, "up")));
				dPad.add(add(buttonLeft = createButton(FlxG.width - 130 * 3, FlxG.height - 66 - 81 * 3, 44 * 3, 45 * 3, "left")));
				dPad.add(add(buttonRight = createButton(FlxG.width - 44 * 3, FlxG.height - 66 - 81 * 3, 44 * 3, 45 * 3, "right")));
				dPad.add(add(buttonDown = createButton(FlxG.width - 86 * 3, FlxG.height - 66 - 45 * 3, 44 * 3, 45 * 3, "down")));
				buttonUp.setPosition(nashing[0].x, nashing[0].y);
				buttonLeft.setPosition(nashing[1].x, nashing[1].y);
				buttonRight.setPosition(nashing[2].x, nashing[2].y);
				buttonDown.setPosition(nashing[3].x, nashing[3].y);
			case NONE: // do nothing
		}

		switch (Action)
		{
			case A:
				actions.add(add(buttonA = createButton(FlxG.width - 44 * 3, FlxG.height - 45 * 3, 44 * 3, 45 * 3, "a")));
			case B:
				actions.add(add(buttonB = createButton(FlxG.width - 44 * 3, FlxG.height - 45 * 3, 44 * 3, 45 * 3, "b")));
			case C:
				actions.add(add(buttonC = createButton(FlxG.width - 44 * 3, 0, 44 * 3, 45 * 3, "c")));
			case X:
				actions.add(add(buttonX = createButton(FlxG.width - 44 * 3, FlxG.height - 45 * 3, 44 * 3, 45 * 3, "x")));
			case A_B:
				actions.add(add(buttonA = createButton(FlxG.width - 44 * 3, FlxG.height - 45 * 3, 44 * 3, 45 * 3, "a")));
				actions.add(add(buttonB = createButton(FlxG.width - 86 * 3, FlxG.height - 45 * 3, 44 * 3, 45 * 3, "b")));
			case A_B_C:
				actions.add(add(buttonA = createButton(FlxG.width - 44 * 3, FlxG.height - 45 * 3, 44 * 3, 45 * 3, "a")));
				actions.add(add(buttonB = createButton(FlxG.width - 86 * 3, FlxG.height - 45 * 3, 44 * 3, 45 * 3, "b")));
				actions.add(add(buttonC = createButton(FlxG.width - 128 * 3, FlxG.height - 45 * 3, 44 * 3, 45 * 3, "c")));
			case A_B_C_X_Y:
				actions.add(add(buttonY = createButton(FlxG.width - 86 * 3, FlxG.height - 90 * 3, 44 * 3, 45 * 3, "y")));
				actions.add(add(buttonX = createButton(FlxG.width - 44 * 3, FlxG.height - 90 * 3, 44 * 3, 45 * 3, "x")));
				actions.add(add(buttonA = createButton(FlxG.width - 44 * 3, FlxG.height - 45 * 3, 44 * 3, 45 * 3, "a")));
				actions.add(add(buttonB = createButton(FlxG.width - 86 * 3, FlxG.height - 45 * 3, 44 * 3, 45 * 3, "b")));
				actions.add(add(buttonC = createButton(FlxG.width - 128 * 3, FlxG.height - 45 * 3, 44 * 3, 45 * 3, "c")));
			case A_B_X_Y:
				actions.add(add(buttonY = createButton(FlxG.width - 86 * 3, FlxG.height - 90 * 3, 44 * 3, 45 * 3, "y")));
				actions.add(add(buttonX = createButton(FlxG.width - 44 * 3, FlxG.height - 90 * 3, 44 * 3, 45 * 3, "x")));
				actions.add(add(buttonB = createButton(FlxG.width - 86 * 3, FlxG.height - 45 * 3, 44 * 3, 45 * 3, "b")));
				actions.add(add(buttonA = createButton(FlxG.width - 44 * 3, FlxG.height - 45 * 3, 44 * 3, 45 * 3, "a")));
			case NONE: // do nothing
		}
	}

	override public function destroy():Void
	{
		super.destroy();

		dPad = FlxDestroyUtil.destroy(dPad);
		actions = FlxDestroyUtil.destroy(actions);

		dPad = null;
		actions = null;
		buttonA = null;
		buttonB = null;
		buttonC = null;
		buttonY = null;
		buttonX = null;
		buttonLeft = null;
		buttonUp = null;
		buttonDown = null;
		buttonRight = null;
	}

	/**
	 * @param   X          The x-position of the button.
	 * @param   Y          The y-position of the button.
	 * @param   Width      The width of the button.
	 * @param   Height     The height of the button.
	 * @param   Graphic    The image of the button. It must contains 3 frames (`NORMAL`, `HIGHLIGHT`, `PRESSED`).
	 * @param   Callback   The callback for the button.
	 * @return  The button
	 */
	public function createButton(X:Float, Y:Float, Width:Int, Height:Int, Graphic:String, ?OnClick:Void->Void):FlxButton
	{
		var button = new FlxButton(X, Y);
		var frame = getVirtualInputFrames().getByName(Graphic);
		button.frames = FlxTileFrames.fromFrame(frame, FlxPoint.get(Width, Height));
		button.resetSizeFromFrame();
		button.solid = false;
		button.immovable = true;
		button.scrollFactor.set();

		#if FLX_DEBUG
		button.ignoreDrawDebug = true;
		#end

		if (OnClick != null)
			button.onDown.callback = OnClick;

		return button;
	}

	public static function getVirtualInputFrames():FlxAtlasFrames
	{
		#if !web
		var bitmapData = new GraphicVirtualInput(0, 0);
		#end

		/*
			#if html5 // dirty hack for openfl/openfl#682
			Reflect.setProperty(bitmapData, "width", 399);
			Reflect.setProperty(bitmapData, "height", 183);
			#end
		 */

		#if !web
		var graphic:FlxGraphic = FlxGraphic.fromBitmapData(bitmapData);
		return FlxAtlasFrames.fromSpriteSheetPacker(graphic, Std.string(new VirtualInputData()));
		#else
		var graphic:FlxGraphic = FlxGraphic.fromAssetKey(Paths.image('virtual-input'));
		return FlxAtlasFrames.fromSpriteSheetPacker(graphic, Std.string(new VirtualInputData()));
		#end
	}
}

enum FlxDPadMode
{
	NONE;
	UP_DOWN;
	DOUBLE_FULL;
	LEFT_RIGHT;
	UP_LEFT_RIGHT;
	RIGHT_FULL;
	FULL;
	CUSTOM;
}

enum FlxActionMode
{
	NONE;
	A;
	B;
	C;
	X;
	A_B;
	A_B_C;
	A_B_C_X_Y;
	A_B_X_Y;
}
