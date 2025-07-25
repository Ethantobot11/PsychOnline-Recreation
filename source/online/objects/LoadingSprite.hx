package online.objects;

import flixel.FlxBasic;
import openfl.geom.Point;
import openfl.geom.Rectangle;

class LoadingSprite extends FlxTypedGroup<FlxBasic> {
    var loadBar:FlxSprite;
    var tasksLength:Float = 0;

	public function new(?tasksLength:Float, ?camera:FlxCamera) {
        super();
        
		var funkayGraphic = Paths.image('funkay', null, false).bitmap;
		if (funkayGraphic.image == null)
		{
			var funkayGroup:FlxSpriteGroup = new FlxSpriteGroup();
			final bg:FlxSprite = new FlxSprite(0, 0).makeGraphic(FlxG.width, FlxG.height, 0xffcaff4d);
			funkayGroup.add(bg);

			var funkay = new FlxSprite(0, 0, Paths.image('funkay'));
			funkay.setGraphicSize(0, FlxG.height);
			funkay.updateHitbox();
			funkay.screenCenter();
			funkayGroup.add(funkay);

			add(funkayGroup);
		}
		else
		{
			var funkay = new FlxSprite();
			funkay.makeGraphic(FlxG.width, FlxG.height, funkayGraphic.getPixel32(0, 0), true, "_funkay"); // kms
			funkayGraphic.image.resize(Std.int(funkayGraphic.image.width * (FlxG.height / funkayGraphic.image.height)), FlxG.height);
			funkay.graphic.bitmap.copyPixels(funkayGraphic, new Rectangle(0, 0, funkay.graphic.bitmap.width, funkay.graphic.bitmap.height),
				new Point(FlxG.width / 2 - funkayGraphic.image.width / 2, 0));
			funkay.antialiasing = ClientPrefs.data.antialiasing;
			add(funkay);
		}

		loadBar = new FlxSprite(0, FlxG.height - 20).makeGraphic(FlxG.width, 10, 0xFFff16d2);
		loadBar.scale.x = 0;
		loadBar.visible = false;
		loadBar.screenCenter(X);
        add(loadBar);

		if (camera != null)
			cameras = [camera];

		this.tasksLength = tasksLength;
    }

    public function addProgress(remaining:Float) {
		loadBar.scale.x += 0.5 * (FlxMath.remapToRange(remaining / tasksLength, 1, 0, 0, 1) - loadBar.scale.x);
        loadBar.visible = true;
    }
}