package mobile.options;

import mobile.backend.MobileScaleMode;
import flixel.input.keyboard.FlxKey;
import options.BaseOptionsMenu;
import options.Option;

class MobileOptionsSubState extends BaseOptionsMenu {
	final exControlTypes:Array<String> = ["NONE", "SINGLE", "DOUBLE"];
	final hintOptions:Array<String> = ["No Gradient", "No Gradient (Old)", "Gradient", "Hidden"];
	var option:Option;

	public function new() {
		title = 'Mobile Options';
		rpcTitle = 'Mobile Options Menu'; // for Discord Rich Presence, fuck it

		option = new Option('Extra Hints', 'Select how many extra hints you prefer to have?\nThey can be used for mechanics with LUA or HScript.',
			'extraHints', 'string', exControlTypes);
		addOption(option);

		option = new Option('Mobile Controls Opacity',
			'Selects the opacity for the mobile buttons (careful not to put it at 0 and lose track of your buttons).', 'controlsAlpha', 'percent');
		option.scrollSpeed = 1;
		option.minValue = 0.001;
		option.maxValue = 1;
		option.changeValue = 0.1;
		option.decimals = 1;
		option.onChange = () -> {
			touchPad.alpha = curOption.getValue();
			ClientPrefs.toggleVolumeKeys();
		};
		addOption(option);

		#if mobile
		option = new Option('Allow Phone Screensaver',
			'If checked, the phone will sleep after going inactive for few seconds.\n(The time depends on your phone\'s options)', 'screensaver', 'bool');
		option.onChange = () -> lime.system.System.allowScreenTimeout = curOption.getValue();
		addOption(option);

		option = new Option('Wide Screen Mode',
			'If checked, The game will stetch to fill your whole screen. (WARNING: Can result in bad visuals & break some mods that resizes the game/cameras)',
			'wideScreen', 'bool');
		option.onChange = () -> FlxG.scaleMode = new MobileScaleMode();
		addOption(option);
		#end

		option = new Option('Hitbox Design', 'Choose how your hitbox should look like.', 'hitboxType', 'string', hintOptions);
		addOption(option);

		option = new Option('Hitbox Position', 'If checked, the hitbox will be put at the bottom of the screen, otherwise will stay at the top.', 'hitboxPos',
			'bool');
		addOption(option);

		option = new Option('Dynamic Controls Color',
			'If checked, the mobile controls color will be set to the notes color in your settings.\n(have effect during gameplay only)', 'dynamicColors',
			'bool');
		addOption(option);

		super();
	}
}
