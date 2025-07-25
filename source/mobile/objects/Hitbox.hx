package mobile.objects;

import openfl.display.BitmapData;
import openfl.display.Shape;
import flixel.graphics.FlxGraphic;
import openfl.geom.Matrix;
import flixel.util.FlxSignal;

/**
 * A zone with 4 hint's (A hitbox).
 * It's really easy to customize the layout.
 *
 * @author: Karim Akra and Homura Akemi (HomuHomu833)
 */
class Hitbox extends MobileInputManager {
	final offsetFir:Int = (ClientPrefs.data.hitboxPos ? Std.int(FlxG.height / 4) * 3 : 0);
	final offsetSec:Int = (ClientPrefs.data.hitboxPos ? 0 : Std.int(FlxG.height / 4));

	public var buttonLeft:TouchButton = new TouchButton(0, 0, [MobileInputID.NOTE_LEFT, MobileInputID.HITBOX_LEFT]);
	public var buttonDown:TouchButton = new TouchButton(0, 0, [MobileInputID.NOTE_DOWN, MobileInputID.HITBOX_DOWN]);
	public var buttonUp:TouchButton = new TouchButton(0, 0, [MobileInputID.NOTE_UP, MobileInputID.HITBOX_UP]);
	public var buttonRight:TouchButton = new TouchButton(0, 0, [MobileInputID.NOTE_RIGHT, MobileInputID.HITBOX_RIGHT]);
	public var buttonExtra:TouchButton = new TouchButton(0, 0, [MobileInputID.EXTRA_1]);
	public var buttonExtra2:TouchButton = new TouchButton(0, 0, [MobileInputID.EXTRA_2]);

	public var onButtonUp:FlxTypedSignal<(TouchButton, Array<MobileInputID>) -> Void> = new FlxTypedSignal<(TouchButton, Array<MobileInputID>) -> Void>();
	public var onButtonDown:FlxTypedSignal<(TouchButton, Array<MobileInputID>) -> Void> = new FlxTypedSignal<(TouchButton, Array<MobileInputID>) -> Void>();

	public var instance:MobileInputManager;

	var storedButtonsIDs:Map<String, Array<MobileInputID>> = new Map<String, Array<MobileInputID>>();

	/**
	 * Create the zone.
	 */
	public function new(?extraMode:ExtraActions = NONE) {
		super();

		for (button in Reflect.fields(this)) {
			var field = Reflect.field(this, button);
			if (Std.isOfType(field, TouchButton))
				storedButtonsIDs.set(button, Reflect.getProperty(field, 'IDs'));
		}

		switch (extraMode) {
			case NONE:
				add(buttonLeft = createHint(0, 0, Std.int(FlxG.width / 4), FlxG.height, 0xFFC24B99, "buttonLeft"));
				add(buttonDown = createHint(FlxG.width / 4, 0, Std.int(FlxG.width / 4), FlxG.height, 0xFF00FFFF, "buttonDown"));
				add(buttonUp = createHint(FlxG.width / 2, 0, Std.int(FlxG.width / 4), FlxG.height, 0xFF12FA05, "buttonUp"));
				add(buttonRight = createHint((FlxG.width / 2) + (FlxG.width / 4), 0, Std.int(FlxG.width / 4), FlxG.height, 0xFFF9393F, "buttonRight"));
			case SINGLE:
				add(buttonLeft = createHint(0, offsetSec, Std.int(FlxG.width / 4), Std.int(FlxG.height / 4) * 3, 0xFFC24B99, "buttonLeft"));
				add(buttonDown = createHint(FlxG.width / 4, offsetSec, Std.int(FlxG.width / 4), Std.int(FlxG.height / 4) * 3, 0xFF00FFFF, "buttonDown"));
				add(buttonUp = createHint(FlxG.width / 2, offsetSec, Std.int(FlxG.width / 4), Std.int(FlxG.height / 4) * 3, 0xFF12FA05, "buttonUp"));
				add(buttonRight = createHint((FlxG.width / 2) + (FlxG.width / 4), offsetSec, Std.int(FlxG.width / 4), Std.int(FlxG.height / 4) * 3,
					0xFFF9393F, "buttonRight"));
				add(buttonExtra = createHint(0, offsetFir, FlxG.width, Std.int(FlxG.height / 4), 0xFF0066FF, "buttonExtra"));
			case DOUBLE:
				add(buttonLeft = createHint(0, offsetSec, Std.int(FlxG.width / 4), Std.int(FlxG.height / 4) * 3, 0xFFC24B99, "buttonLeft"));
				add(buttonDown = createHint(FlxG.width / 4, offsetSec, Std.int(FlxG.width / 4), Std.int(FlxG.height / 4) * 3, 0xFF00FFFF, "buttonDown"));
				add(buttonUp = createHint(FlxG.width / 2, offsetSec, Std.int(FlxG.width / 4), Std.int(FlxG.height / 4) * 3, 0xFF12FA05, "buttonUp"));
				add(buttonRight = createHint((FlxG.width / 2) + (FlxG.width / 4), offsetSec, Std.int(FlxG.width / 4), Std.int(FlxG.height / 4) * 3,
					0xFFF9393F, "buttonRight"));
				add(buttonExtra2 = createHint(Std.int(FlxG.width / 2), offsetFir, Std.int(FlxG.width / 2), Std.int(FlxG.height / 4), 0xA6FF00, "buttonExtra2"));
				add(buttonExtra = createHint(0, offsetFir, Std.int(FlxG.width / 2), Std.int(FlxG.height / 4), 0xFF0066FF, "buttonExtra"));
		}

		for (button in Reflect.fields(this)) {
			if (Std.isOfType(Reflect.field(this, button), TouchButton))
				Reflect.setProperty(Reflect.getProperty(this, button), 'IDs', storedButtonsIDs.get(button));
		}

		scrollFactor.set();
		updateTrackedButtons();

		instance = this;
	}

	/**
	 * Clean up memory.
	 */
	override function destroy() {
		super.destroy();
		onButtonUp.destroy();
		onButtonDown.destroy();

		for (fieldName in Reflect.fields(this)) {
			var field = Reflect.field(this, fieldName);
			if (Std.isOfType(field, TouchButton))
				Reflect.setField(this, fieldName, FlxDestroyUtil.destroy(field));
		}
	}

	private function createHint(X:Float, Y:Float, Width:Int, Height:Int, Color:Int = 0xFFFFFF, ?mapKey:String):TouchButton {
		var hint = new TouchButton(X, Y);
		hint.statusAlphas = [];
		hint.statusIndicatorType = NONE;
		hint.loadGraphic(createHintGraphic(Width, Height));

		if (ClientPrefs.data.hitboxType != "Hidden") {
			hint.onDown.callback = function() {
				onButtonDown.dispatch(hint, storedButtonsIDs.get(mapKey));
				hint.alpha = ClientPrefs.data.controlsAlpha;
			}

			hint.onOut.callback = hint.onUp.callback = function() {
				onButtonUp.dispatch(hint, storedButtonsIDs.get(mapKey));
				hint.alpha = 0.00001;
			}
		}
		else {
			hint.onUp.callback = hint.onOut.callback = () -> onButtonUp.dispatch(hint, storedButtonsIDs.get(mapKey));
			hint.onDown.callback = () -> onButtonDown.dispatch(hint, storedButtonsIDs.get(mapKey));
		}

		hint.immovable = hint.multiTouch = true;
		hint.solid = hint.moves = false;
		hint.alpha = 0.00001;
		hint.antialiasing = ClientPrefs.data.antialiasing;
		hint.color = Color;
		#if FLX_DEBUG
		hint.ignoreDrawDebug = true;
		#end
		return hint;
	}

	function createHintGraphic(Width:Int, Height:Int):FlxGraphic {
		var shape:Shape = new Shape();
		shape.graphics.beginFill(0xFFFFFF);

		if (ClientPrefs.data.hitboxType == "No Gradient") {
			var matrix:Matrix = new Matrix();
			matrix.createGradientBox(Width, Height, 0, 0, 0);

			shape.graphics.beginGradientFill(RADIAL, [0xFFFFFF, 0xFFFFFF], [0, 1], [60, 255], matrix, PAD, RGB, 0);
			shape.graphics.drawRect(0, 0, Width, Height);
			shape.graphics.endFill();
		}
		else if (ClientPrefs.data.hitboxType == "No Gradient (Old)") {
			shape.graphics.lineStyle(10, 0xFFFFFF, 1);
			shape.graphics.drawRect(0, 0, Width, Height);
			shape.graphics.endFill();
		}
		else // if (ClientPrefs.data.hitboxType == 'Gradient')
		{
			shape.graphics.lineStyle(3, 0xFFFFFF, 1);
			shape.graphics.drawRect(0, 0, Width, Height);
			shape.graphics.lineStyle(0, 0, 0);
			shape.graphics.drawRect(3, 3, Width - 6, Height - 6);
			shape.graphics.endFill();
			shape.graphics.beginGradientFill(RADIAL, [0xFFFFFF, FlxColor.TRANSPARENT], [1, 0], [0, 255], null, null, null, 0.5);
			shape.graphics.drawRect(3, 3, Width - 6, Height - 6);
			shape.graphics.endFill();
		}

		var bitmap:BitmapData = new BitmapData(Width, Height, true, 0);
		bitmap.draw(shape);

		return FlxG.bitmap.add(bitmap);
	}
}
