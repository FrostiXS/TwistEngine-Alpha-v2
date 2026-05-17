package game.states;

import game.backend.assets.ModsFolder;
import game.backend.system.states.MusicBeatState;
import game.objects.Alphabet;
import game.objects.FlxStaticText;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.math.FlxMath;

#if sys
import sys.FileSystem;
import sys.io.File;
#end

class ModsMenuState extends MusicBeatState
{
	var grpMods:FlxTypedGroup<Alphabet>;
	var modsList:Array<String> = [];
	var enabledMods:Array<Bool> = [];
	var descriptionTxt:FlxText;
	var statusTxt:FlxText;

	static var curSelected:Int = 0;

	override function create()
	{
		Main.canClearMem = true;
		FlxG.camera.bgColor = FlxColor.BLACK;
		#if DISCORD_RPC
		DiscordClient.changePresence("Mods Menu", null);
		#end

		var bg:FlxSprite = new FlxSprite(Paths.image('menuDesat'));
		bg.color = 0xFF4A235A;
		bg.screenCenter();
		add(bg);

		grpMods = new FlxTypedGroup<Alphabet>();
		add(grpMods);

		reloadModsList();

		var titleTxt = new FlxStaticText(0, 12, FlxG.width, "MODS MANAGER", 32);
		titleTxt.setFormat(Paths.font('defaultPsych/vcr.ttf'), 32, FlxColor.WHITE, CENTER);
		titleTxt.borderStyle = FlxTextBorderStyle.OUTLINE;
		titleTxt.borderColor = FlxColor.BLACK;
		titleTxt.scrollFactor.set();
		add(titleTxt);

		descriptionTxt = new FlxText(40, FlxG.height - 100, FlxG.width - 80, "", 16);
		descriptionTxt.setFormat(Paths.font('defaultPsych/vcr.ttf'), 16, FlxColor.WHITE, CENTER);
		descriptionTxt.borderStyle = FlxTextBorderStyle.OUTLINE;
		descriptionTxt.borderColor = FlxColor.BLACK;
		descriptionTxt.scrollFactor.set();
		add(descriptionTxt);

		statusTxt = new FlxText(40, FlxG.height - 40, FlxG.width - 80, "", 14);
		statusTxt.setFormat(Paths.font('defaultPsych/vcr.ttf'), 14, 0xFF00FF00, CENTER);
		statusTxt.borderStyle = FlxTextBorderStyle.OUTLINE;
		statusTxt.borderColor = FlxColor.BLACK;
		statusTxt.scrollFactor.set();
		add(statusTxt);

		var helpTxt = new FlxText(12, FlxG.height - 24, FlxG.width - 24, "ENTER - Switch Mod | BACKSPACE - Back to Menu", 12);
		helpTxt.setFormat(Paths.font('defaultPsych/vcr.ttf'), 12, 0xFFAAAAAA, CENTER);
		helpTxt.scrollFactor.set();
		add(helpTxt);

		changeSelection();
		super.create();

		Paths.clearUnusedMemory();
		FlxG.mouse.visible = false;
		persistentUpdate = true;
	}

	function reloadModsList()
	{
		modsList = [];
		grpMods.clear();

		#if MODS_ALLOWED
		ModsFolder.updateModsList();
		for (modPath in ModsFolder.listMods)
		{
			var modName = haxe.io.Path.withoutDirectory(modPath);
			if (modName.length < 1)
				modName = modPath;
			modsList.push(modPath);
		}
		#end

		if (modsList.length == 0)
		{
			modsList.push("");
			var noModsTxt:Alphabet = new Alphabet(90, 320, "No mods found", true);
			noModsTxt.isMenuItem = true;
			noModsTxt.targetY = 0;
			grpMods.add(noModsTxt);
			noModsTxt.snapToPosition();
		}
		else
		{
			for (i in 0...modsList.length)
			{
				var modName = haxe.io.Path.withoutDirectory(modsList[i]);
				if (modName.length < 1)
					modName = modsList[i];
				var leText:Alphabet = new Alphabet(90, 320, modName, true);
				leText.isMenuItem = true;
				leText.targetY = i;
				grpMods.add(leText);
				leText.snapToPosition();
			}
		}

		if (curSelected >= modsList.length)
			curSelected = 0;
	}

	override function update(elapsed:Float)
	{
		if (FlxG.mouse.wheel != 0)
			changeSelection(FlxG.mouse.wheel > 0 ? -1 : 1);
		else
		{
			if (controls.UI_UP_P)	changeSelection(-1);
			if (controls.UI_DOWN_P)	changeSelection(1);
		}

		if (controls.BACK)
		{
			FlxG.sound.play(Paths.sound('cancelMenu'));
			MusicBeatState.switchState(new MainMenuState());
		}

		if (controls.ACCEPT || FlxG.mouse.justPressed)
		{
			if (modsList.length > 0 && modsList[curSelected] != null && modsList[curSelected].length > 0)
			{
				FlxG.sound.play(Paths.sound('confirmMenu'));
				#if MODS_ALLOWED
				ModsFolder.switchMod(modsList[curSelected]);
				#end
				statusTxt.text = 'Switched to mod: ' + haxe.io.Path.withoutDirectory(modsList[curSelected]);
				statusTxt.color = 0xFF00FF00;
			}
		}

		super.update(elapsed);
	}

	function changeSelection(change:Int = 0)
	{
		if (modsList.length <= 0) return;
		curSelected = FlxMath.wrap(curSelected + change, 0, modsList.length - 1);
		if (change != 0)
			FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

		for (i => item in grpMods.members)
		{
			item.targetY = i - curSelected;
			item.alpha = item.targetY == 0 ? 1 : 0.6;
		}

		updateDescription();
	}

	function updateDescription()
	{
		if (modsList.length <= 0 || modsList[curSelected] == null || modsList[curSelected].length < 1)
		{
			descriptionTxt.text = "No mods available.\nPlace mod folders in the 'mods' directory.";
			return;
		}

		var modPath = modsList[curSelected];
		var modName = haxe.io.Path.withoutDirectory(modPath);
		var desc = 'Mod: $modName';

		#if sys
		var packJsonPath = modPath + "/pack.json";
		if (FileSystem.exists(packJsonPath))
		{
			try
			{
				var packData:Dynamic = haxe.Json.parse(File.getContent(packJsonPath));
				if (packData.name != null)
					desc = Std.string(packData.name);
				if (packData.description != null)
					desc += '\n' + Std.string(packData.description);
			}
			catch(e) {}
		}
		else
		{
			desc += '\nNo pack.json found - add one for description';
		}
		#end

		var isCurrent = (modPath == ModsFolder.currentModFolderPath);
		statusTxt.text = isCurrent ? '[ ACTIVE ]' : '';
		statusTxt.color = isCurrent ? 0xFF00FF00 : 0xFFFFFFFF;

		descriptionTxt.text = desc;
	}
}
