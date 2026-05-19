package game.states.editors;

import game.backend.data.jsons.WeekData;
import game.backend.system.states.MusicBeatState;
import game.objects.Alphabet;
import game.objects.FlxStaticText;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.ui.FlxUI;
import flixel.addons.ui.FlxUICheckBox;
import flixel.addons.ui.FlxUIInputText;
import flixel.addons.ui.FlxUINumericStepper;
import flixel.addons.ui.FlxUITabMenu;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;
import flixel.math.FlxMath;
import haxe.Json;
import haxe.io.Path;

#if sys
import sys.FileSystem;
import sys.io.File;
#end

class WeekEditorState extends MusicBeatState
{
	var weekName:String = "New Week";
	var storyName:String = "New Week";
	var songs:Array<String> = [];
	var difficulties:Array<String> = ["easy", "normal", "hard"];
	var weekCharacters:Array<String> = ["bf-pixel", "gf", "bf"];
	var weekBackground:String = "";
	var weekBefore:String = "";
	var hideStoryMode:Bool = false;
	var hideFreeplay:Bool = false;
	var startUnlocked:Bool = true;

	var UI_box:FlxUITabMenu;
	var songListTxt:FlxText;
	var blockPressWhileTypingOn:Array<FlxUIInputText> = [];

	var grpSongs:FlxTypedGroup<Alphabet>;
	var curSongSelected:Int = 0;

	// week list
	var weekFiles:Array<String> = [];
	var curWeekSelected:Int = 0;

	override function create()
	{
		Main.canClearMem = true;
		FlxG.camera.bgColor = FlxColor.BLACK;
		FlxG.mouse.visible = true;

		#if DISCORD_RPC
		DiscordClient.changePresence("Week Editor", null);
		#end

		var bg:FlxSprite = new FlxSprite();
		var bgGraphic = Paths.image('menuDesat');
		if (bgGraphic != null)
			bg.loadGraphic(bgGraphic);
		else
			bg.makeGraphic(FlxG.width, FlxG.height, 0xFF1A3A2A);
		bg.color = 0xFF1A3A2A;
		bg.screenCenter();
		bg.scrollFactor.set();
		add(bg);

		grpSongs = new FlxTypedGroup<Alphabet>();
		add(grpSongs);

		var tabs = [
			{name: "Week", label: "Week Settings"},
			{name: "Songs", label: "Songs List"},
		];

		UI_box = new FlxUITabMenu(null, tabs, true);
		UI_box.resize(350, 400);
		UI_box.x = FlxG.width - UI_box.width - 10;
		UI_box.y = 20;
		UI_box.scrollFactor.set();
		add(UI_box);

		addWeekUI();
		addSongsUI();

		songListTxt = new FlxText(20, FlxG.height - 200, 400, "", 14);
		songListTxt.setFormat(Paths.font('defaultPsych/vcr.ttf'), 14, FlxColor.WHITE);
		songListTxt.borderStyle = FlxTextBorderStyle.OUTLINE;
		songListTxt.borderColor = FlxColor.BLACK;
		songListTxt.scrollFactor.set();
		add(songListTxt);

		var helpTxt = new FlxText(12, FlxG.height - 30, FlxG.width - 24,
			"BACKSPACE - Back to Editors | Week Editor - create and edit week JSON files", 12);
		helpTxt.setFormat(Paths.font('defaultPsych/vcr.ttf'), 12, 0xFFAAAAAA, CENTER);
		helpTxt.scrollFactor.set();
		add(helpTxt);

		loadWeeksList();
		updateSongListDisplay();
		super.create();
	}

	var weekNameInput:FlxUIInputText;
	var storyNameInput:FlxUIInputText;
	var weekBeforeInput:FlxUIInputText;
	var weekBgInput:FlxUIInputText;
	var char1Input:FlxUIInputText;
	var char2Input:FlxUIInputText;
	var char3Input:FlxUIInputText;
	var checkHideStory:FlxUICheckBox;
	var checkHideFreeplay:FlxUICheckBox;
	var checkStartUnlocked:FlxUICheckBox;

	function addWeekUI()
	{
		var tab = new FlxUI(null, UI_box);
		tab.name = "Week";

		var yPos:Float = 10;

		tab.add(new FlxStaticText(10, yPos, 0, "Week File Name:"));
		yPos += 16;
		weekNameInput = new FlxUIInputText(10, yPos, 200, weekName, 8);
		blockPressWhileTypingOn.push(weekNameInput);
		tab.add(weekNameInput);
		yPos += 25;

		tab.add(new FlxStaticText(10, yPos, 0, "Story Display Name:"));
		yPos += 16;
		storyNameInput = new FlxUIInputText(10, yPos, 200, storyName, 8);
		blockPressWhileTypingOn.push(storyNameInput);
		tab.add(storyNameInput);
		yPos += 25;

		tab.add(new FlxStaticText(10, yPos, 0, "Week Before (unlock chain):"));
		yPos += 16;
		weekBeforeInput = new FlxUIInputText(10, yPos, 200, weekBefore, 8);
		blockPressWhileTypingOn.push(weekBeforeInput);
		tab.add(weekBeforeInput);
		yPos += 25;

		tab.add(new FlxStaticText(10, yPos, 0, "Background:"));
		yPos += 16;
		weekBgInput = new FlxUIInputText(10, yPos, 200, weekBackground, 8);
		blockPressWhileTypingOn.push(weekBgInput);
		tab.add(weekBgInput);
		yPos += 25;

		tab.add(new FlxStaticText(10, yPos, 0, "Characters (left, center, right):"));
		yPos += 16;
		char1Input = new FlxUIInputText(10, yPos, 90, weekCharacters[0], 8);
		char2Input = new FlxUIInputText(105, yPos, 90, weekCharacters[1], 8);
		char3Input = new FlxUIInputText(200, yPos, 90, weekCharacters[2], 8);
		blockPressWhileTypingOn.push(char1Input);
		blockPressWhileTypingOn.push(char2Input);
		blockPressWhileTypingOn.push(char3Input);
		tab.add(char1Input);
		tab.add(char2Input);
		tab.add(char3Input);
		yPos += 25;

		checkHideStory = new FlxUICheckBox(10, yPos, null, null, "Hide in Story Mode", 120);
		checkHideStory.checked = hideStoryMode;
		tab.add(checkHideStory);
		yPos += 22;

		checkHideFreeplay = new FlxUICheckBox(10, yPos, null, null, "Hide in Freeplay", 120);
		checkHideFreeplay.checked = hideFreeplay;
		tab.add(checkHideFreeplay);
		yPos += 22;

		checkStartUnlocked = new FlxUICheckBox(10, yPos, null, null, "Start Unlocked", 120);
		checkStartUnlocked.checked = startUnlocked;
		tab.add(checkStartUnlocked);
		yPos += 30;

		var saveBtn = new FlxButton(10, yPos, "Save Week", function() { saveWeek(); });
		saveBtn.color = 0xFF00AA00;
		saveBtn.label.color = FlxColor.WHITE;
		tab.add(saveBtn);

		var loadBtn = new FlxButton(saveBtn.x + 100, yPos, "Load Week", function() { loadSelectedWeek(); });
		tab.add(loadBtn);

		UI_box.addGroup(tab);
	}

	var addSongInput:FlxUIInputText;

	function addSongsUI()
	{
		var tab = new FlxUI(null, UI_box);
		tab.name = "Songs";

		var yPos:Float = 10;

		tab.add(new FlxStaticText(10, yPos, 0, "Song name to add:"));
		yPos += 16;
		addSongInput = new FlxUIInputText(10, yPos, 200, "", 8);
		blockPressWhileTypingOn.push(addSongInput);
		tab.add(addSongInput);
		yPos += 25;

		var addBtn = new FlxButton(10, yPos, "Add Song", function() {
			var name = addSongInput.text.trim();
			if (name.length > 0)
			{
				songs.push(name);
				addSongInput.text = "";
				updateSongListDisplay();
			}
		});
		addBtn.color = 0xFF00AA00;
		addBtn.label.color = FlxColor.WHITE;
		tab.add(addBtn);

		var removeBtn = new FlxButton(addBtn.x + 100, yPos, "Remove Last", function() {
			if (songs.length > 0)
			{
				songs.pop();
				updateSongListDisplay();
			}
		});
		removeBtn.color = FlxColor.RED;
		removeBtn.label.color = FlxColor.WHITE;
		tab.add(removeBtn);
		yPos += 35;

		var clearBtn = new FlxButton(10, yPos, "Clear All Songs", function() {
			songs = [];
			updateSongListDisplay();
		});
		clearBtn.color = FlxColor.RED;
		clearBtn.label.color = FlxColor.WHITE;
		tab.add(clearBtn);

		UI_box.addGroup(tab);
	}

	function updateSongListDisplay()
	{
		var txt = "Songs in week:\n";
		if (songs.length == 0)
			txt += "  (none)\n";
		else
			for (i in 0...songs.length)
				txt += '  ${i + 1}. ${songs[i]}\n';
		songListTxt.text = txt;
	}

	function loadWeeksList()
	{
		weekFiles = [];
		#if sys
		var weeksDir = #if MODS_ALLOWED
			(ModsFolder.currentModFolderPath != null && ModsFolder.currentModFolderPath.length > 0)
				? ModsFolder.currentModFolderPath + "/weeks" : "assets/weeks";
		#else "assets/weeks"; #end
		if (FileSystem.exists(weeksDir) && FileSystem.isDirectory(weeksDir))
		{
			for (file in FileSystem.readDirectory(weeksDir))
			{
				if (file.endsWith('.json'))
					weekFiles.push(file);
			}
		}
		#end
	}

	function saveWeek()
	{
		weekName = weekNameInput.text.trim();
		storyName = storyNameInput.text.trim();
		weekBefore = weekBeforeInput.text.trim();
		weekBackground = weekBgInput.text.trim();
		weekCharacters = [char1Input.text.trim(), char2Input.text.trim(), char3Input.text.trim()];
		hideStoryMode = checkHideStory.checked;
		hideFreeplay = checkHideFreeplay.checked;
		startUnlocked = checkStartUnlocked.checked;

		if (weekName.length < 1)
		{
			FlxG.log.error("Week name cannot be empty!");
			return;
		}

		var weekData:WeekFilePsych = {
			songs: [for (s in songs) [s, "bf", [146, 113, 253]]],
			weekCharacters: weekCharacters,
			weekBackground: weekBackground,
			weekBefore: weekBefore,
			storyName: storyName.length > 0 ? storyName : weekName,
			weekName: weekName,
			freeplayColor: [146, 113, 253],
			startUnlocked: startUnlocked,
			hiddenUntilUnlocked: false,
			hideStoryMode: hideStoryMode,
			hideFreeplay: hideFreeplay,
			difficulties: "Easy, Normal, Hard"
		};

		var jsonStr = Json.stringify(weekData, "\t");
		var fileName = Paths.formatToSongPath(weekName);

		#if sys
		var root:String = #if MODS_ALLOWED
			(ModsFolder.currentModFolderPath != null && ModsFolder.currentModFolderPath.length > 0)
				? ModsFolder.currentModFolderPath : "assets";
		#else "assets"; #end
		var weeksDir = root + "/weeks";
		if (!FileSystem.exists(weeksDir))
			FileSystem.createDirectory(weeksDir);

		var savePath = weeksDir + "/" + fileName + ".json";
		FileUtil.browseForSaveFile([FileUtil.FILE_FILTER_JSON],
			path -> {
				File.saveContent(path, jsonStr);
				FlxG.log.notice('Week "$weekName" saved!');
				loadWeeksList();
			},
			() -> FlxG.log.error("Save cancelled"),
			savePath,
			'Save Week "$weekName"');
		#end
	}

	function loadSelectedWeek()
	{
		#if sys
		var weeksDir = #if MODS_ALLOWED
			(ModsFolder.currentModFolderPath != null && ModsFolder.currentModFolderPath.length > 0)
				? ModsFolder.currentModFolderPath + "/weeks" : "assets/weeks";
		#else "assets/weeks"; #end

		if (weekFiles.length == 0)
		{
			FlxG.log.notice("No week files found to load.");
			return;
		}

		var file = weekFiles[curWeekSelected % weekFiles.length];
		var fullPath = weeksDir + "/" + file;
		if (!FileSystem.exists(fullPath)) return;

		try
		{
			var data:Dynamic = Json.parse(File.getContent(fullPath));
			if (data.weekName != null) weekNameInput.text = Std.string(data.weekName);
			if (data.storyName != null) storyNameInput.text = Std.string(data.storyName);
			if (data.weekBefore != null) weekBeforeInput.text = Std.string(data.weekBefore);
			if (data.weekBackground != null) weekBgInput.text = Std.string(data.weekBackground);
			if (data.weekCharacters != null)
			{
				var chars:Array<Dynamic> = data.weekCharacters;
				if (chars.length > 0) char1Input.text = Std.string(chars[0]);
				if (chars.length > 1) char2Input.text = Std.string(chars[1]);
				if (chars.length > 2) char3Input.text = Std.string(chars[2]);
			}
			if (data.hideStoryMode != null) checkHideStory.checked = data.hideStoryMode;
			if (data.hideFreeplay != null) checkHideFreeplay.checked = data.hideFreeplay;
			if (data.startUnlocked != null) checkStartUnlocked.checked = data.startUnlocked;

			songs = [];
			if (data.songs != null)
			{
				var songsArr:Array<Dynamic> = data.songs;
				for (s in songsArr)
				{
					if (Std.isOfType(s, Array))
					{
						var arr:Array<Dynamic> = cast s;
						if (arr.length > 0) songs.push(Std.string(arr[0]));
					}
				}
			}
			updateSongListDisplay();
			FlxG.log.notice('Loaded week: $file');
		}
		catch(e)
		{
			FlxG.log.error('Failed to load week: $e');
		}
		#end
	}

	override function update(elapsed:Float)
	{
		var blockInput = false;
		for (input in blockPressWhileTypingOn)
		{
			if (input.hasFocus)
			{
				blockInput = true;
				break;
			}
		}

		if (!blockInput)
		{
			if (controls.BACK)
			{
				FlxG.sound.play(Paths.sound('cancelMenu'));
				MusicBeatState.switchState(new MasterEditorMenu());
			}

			if (FlxG.keys.justPressed.LEFT)
			{
				curWeekSelected = FlxMath.wrap(curWeekSelected - 1, 0, Std.int(Math.max(0, weekFiles.length - 1)));
			}
			if (FlxG.keys.justPressed.RIGHT)
			{
				curWeekSelected = FlxMath.wrap(curWeekSelected + 1, 0, Std.int(Math.max(0, weekFiles.length - 1)));
			}
		}

		super.update(elapsed);
	}
}
