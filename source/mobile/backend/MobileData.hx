package mobile.backend;

import haxe.ds.Map;
import haxe.Json;
import haxe.io.Path;
import openfl.utils.Assets;
import flixel.math.FlxPoint;
import flixel.util.FlxSave;
import backend.io.PsychFile as File;
import backend.io.PsychFileSystem as FileSystem;

/**
 * ...
 * @author: Karim Akra
 */
class MobileData {
	public static var actionModes:Map<String, TouchButtonsData> = new Map();
	public static var dpadModes:Map<String, TouchButtonsData> = new Map();
	public static var extraActions:Map<String, ExtraActions> = new Map();

	public static var save:FlxSave;

	public static function init() {
		save = new FlxSave();
		save.bind('MobileControls', CoolUtil.getSavePath());

		readDirectory(Paths.getPreloadPath('mobile/DPadModes'), dpadModes);
		readDirectory(Paths.getPreloadPath('mobile/ActionModes'), actionModes);
		#if MODS_ALLOWED
		for (folder in Mods.directoriesWithFile(Paths.getPreloadPath(), 'mobile/')) {
			readDirectory(Path.join([folder, 'DPadModes']), dpadModes);
			readDirectory(Path.join([folder, 'ActionModes']), actionModes);
		}
		#end

		for (data in ExtraActions.createAll())
			extraActions.set(data.getName(), data);
	}

	public static function setButtonsColors(buttonsInstance:Dynamic):Dynamic {
		// Dynamic Controls Color
		var data:Dynamic;
		if (ClientPrefs.data.dynamicColors)
			data = ClientPrefs.data;
		else
			data = ClientPrefs.defaultData;

		buttonsInstance.buttonLeft.color = data.arrowRGB[0][0];
		buttonsInstance.buttonDown.color = data.arrowRGB[1][0];
		buttonsInstance.buttonUp.color = data.arrowRGB[2][0];
		buttonsInstance.buttonRight.color = data.arrowRGB[3][0];

		return buttonsInstance;
	}

	public static function readDirectory(folder:String, map:Dynamic) {
		folder = folder.contains(':') ? folder.split(':')[1] : folder;

		for (file in FileSystem.readDirectory(folder)) {
			var fileWithNoLib:String = file.contains(':') ? file.split(':')[1] : file;
			if (Path.extension(fileWithNoLib) == 'json') {
				file = Path.join([folder, Path.withoutDirectory(file)]);
				var str = File.getContent(file);
				var json:TouchButtonsData = cast Json.parse(str);
				var mapKey:String = Path.withoutDirectory(Path.withoutExtension(fileWithNoLib));
				map.set(mapKey, json);
			}
		}
	}
}

typedef TouchButtonsData = {
	buttons:Array<ButtonsData>
}

typedef ButtonsData = {
	button:String, // what TouchButton should be used, must be a valid TouchButton var from TouchPad as a string.
	graphic:String, // the graphic of the button, usually can be located in the TouchPad xml .
	x:Float, // the button's X position on screen.
	y:Float, // the button's Y position on screen.
	color:String // the button color, default color is white.
}

enum ExtraActions {
	SINGLE;
	DOUBLE;
	NONE;
}
