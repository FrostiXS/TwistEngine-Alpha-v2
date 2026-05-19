package game.objects.ui;

import flixel.FlxG;
import flixel.FlxCamera;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.input.keyboard.FlxKey;

/**
 * Global Debug Console for Twist Engine.
 * Shows script errors, trace messages, and warnings in real-time.
 * Toggle with configurable key (default: F2).
 */
class DebugConsole extends FlxSpriteGroup
{
	public static var instance:DebugConsole;
	static var globalLog:Array<{text:String, color:FlxColor, time:Float}> = [];

	var consoleBg:FlxSprite;
	var logText:FlxText;
	var titleText:FlxText;
	var isVisible:Bool = false;
	var maxLines:Int = 30;
	var consoleCamera:FlxCamera;
	var scrollOffset:Int = 0;

	public function new()
	{
		super();
		instance = this;

		consoleCamera = new FlxCamera();
		consoleCamera.bgColor = 0x00000000;
		FlxG.cameras.add(consoleCamera, false);

		// Semi-transparent background
		consoleBg = new FlxSprite();
		consoleBg.makeGraphic(FlxG.width, FlxG.height, 0xCC111111);
		consoleBg.scrollFactor.set();
		add(consoleBg);

		// Title bar
		var titleBg = new FlxSprite();
		titleBg.makeGraphic(FlxG.width, 28, 0xFF1a1a2e);
		titleBg.scrollFactor.set();
		add(titleBg);

		titleText = new FlxText(10, 4, FlxG.width - 20, "TWIST ENGINE — DEBUG CONSOLE (F2 to close)", 14);
		titleText.setFormat(null, 14, 0xFF00d4ff, LEFT);
		titleText.scrollFactor.set();
		add(titleText);

		// Log text area
		logText = new FlxText(10, 34, FlxG.width - 20, "", 11);
		logText.setFormat(null, 11, FlxColor.WHITE, LEFT);
		logText.scrollFactor.set();
		add(logText);

		cameras = [consoleCamera];
		visible = false;
		active = true;
	}

	/**
	 * Add a log message to the console. Can be called from anywhere.
	 */
	public static function log(text:String, ?color:FlxColor)
	{
		if (color == null) color = FlxColor.WHITE;
		var timestamp = Date.now();
		var timeStr = '[${StringTools.lpad(Std.string(timestamp.getHours()), "0", 2)}:${StringTools.lpad(Std.string(timestamp.getMinutes()), "0", 2)}:${StringTools.lpad(Std.string(timestamp.getSeconds()), "0", 2)}]';
		globalLog.push({text: '$timeStr $text', color: color, time: 0});

		// Limit log size
		if (globalLog.length > 500)
			globalLog.shift();

		// Update display if visible
		if (instance != null && instance.isVisible)
			instance.refreshDisplay();

		#if debug
		trace('[DebugConsole] $text');
		#end
	}

	/**
	 * Log an error (red text)
	 */
	public static function logError(text:String)
		log('ERROR: $text', FlxColor.RED);

	/**
	 * Log a warning (yellow text)
	 */
	public static function logWarning(text:String)
		log('WARN: $text', FlxColor.YELLOW);

	/**
	 * Log a success message (green text)
	 */
	public static function logSuccess(text:String)
		log('OK: $text', FlxColor.GREEN);

	/**
	 * Log script-related info (cyan text)
	 */
	public static function logScript(text:String)
		log('SCRIPT: $text', 0xFF00d4ff);

	public function toggle()
	{
		isVisible = !isVisible;
		visible = isVisible;

		if (isVisible)
		{
			scrollOffset = 0;
			refreshDisplay();
		}
	}

	function refreshDisplay()
	{
		if (logText == null) return;

		var lines:Array<String> = [];
		var startIdx = Std.int(Math.max(0, globalLog.length - maxLines - scrollOffset));
		var endIdx = Std.int(Math.max(0, globalLog.length - scrollOffset));

		for (i in startIdx...endIdx)
		{
			if (i >= 0 && i < globalLog.length)
				lines.push(globalLog[i].text);
		}

		if (lines.length == 0)
			logText.text = "No messages yet. Script errors and traces will appear here.";
		else
			logText.text = lines.join("\n");
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
		
		var togglePressed = false;
		if (game.backend.utils.ClientPrefs.instance.keyBinds.exists("debug_console"))
		{
			if (FlxG.keys.anyJustPressed(game.backend.utils.ClientPrefs.instance.keyBinds.get("debug_console")))
				togglePressed = true;
		}
		else if (FlxG.keys.justPressed.F2)
			togglePressed = true;

		if (togglePressed) toggle();

		if (isVisible)
		{
			// Scroll with mouse wheel
			if (FlxG.mouse.wheel != 0)
			{
				scrollOffset += FlxG.mouse.wheel > 0 ? 3 : -3;
				scrollOffset = Std.int(Math.max(0, Math.min(scrollOffset, globalLog.length - maxLines)));
				refreshDisplay();
			}

			// Clear log with DELETE key
			if (FlxG.keys.justPressed.DELETE)
			{
				globalLog = [];
				refreshDisplay();
			}
		}
	}

	override public function destroy()
	{
		if (consoleCamera != null)
			FlxG.cameras.remove(consoleCamera, true);
		instance = null;
		super.destroy();
	}
}
