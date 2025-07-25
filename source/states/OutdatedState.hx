package states;

class OutdatedState extends MusicBeatState
{
	public static var leftState:Bool = false;

	var warnText:FlxText;
	override function create()
	{
		super.create();

		leftState = false;

		final accept:String = (controls.mobileC) ? 'A' : 'ACCEPT';
		final back:String = (controls.mobileC) ? 'B' : 'BACK';

		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		add(bg);

		warnText = new FlxText(0, 0, FlxG.width,
			"Sorry, but you have to update this port
			your current version is '" + Main.PSYCH_ONLINE_VERSION + "' while
			the latest is '" + Main.updateVersion + "'\n
			" + accept + " - Jump into the download page!
			" + back + " - Continue without updating.",
			32);
		warnText.setFormat("VCR OSD Mono", 32, FlxColor.WHITE, CENTER);
		warnText.screenCenter(Y);
		add(warnText);

		addTouchPad('NONE', 'A_B');
	}

	override function update(elapsed:Float)
	{
		if(!leftState) {
			if (controls.ACCEPT) {
				CoolUtil.browserLoad(Main.latestRelease.html_url);
				online.network.Auth.saveClose();
				Sys.exit(1);
			}
			else if(controls.BACK) {
				leftState = true;
			}

			if(leftState)
			{
				FlxG.sound.play(Paths.sound('cancelMenu'));
				FlxTween.tween(warnText, {alpha: 0}, 1, {
					onComplete: function (twn:FlxTween) {
						FlxG.switchState(() -> new MainMenuState());
					}
				});
			}
		}
		super.update(elapsed);
	}
}
