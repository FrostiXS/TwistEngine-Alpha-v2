package game.states;

import game.backend.data.jsons.WeekData;
import game.backend.system.song.Song;
import game.backend.system.states.MusicBeatState;
import game.backend.utils.Difficulty;
import game.backend.utils.Highscore;
import game.states.playstate.PlayState;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;

class StoryMenuState extends MusicBeatState
{
	var scoreText:FlxText;
	var txtWeekTitle:FlxText;
	var txtTracklist:FlxText;
	var diffText:FlxText;
	var bgSprite:FlxSprite;

	var weekKeys:Array<String> = [];
	var weekDisplayNames:Array<String> = [];
	var weekItems:Array<FlxText> = [];

	static var curWeek:Int = 0;
	var curDifficulty:Int = 0;

	var selectedWeek:Bool = false;

	override function create()
	{
		Paths.clearUnusedMemory();
		PlayState.isStoryMode = true;

		DiscordClient.changePresence("Story Mode", null);

		WeekData.reloadWeeksFiles(true);

		for (key in WeekData.weeksListOrder)
		{
			var fileKey:String = key.file;
			weekKeys.push(fileKey);

			var weekData = WeekData.weeksDatas.get(fileKey);
			var displayName:String = fileKey;
			if (weekData != null && weekData.data.storyMenu != null && weekData.data.storyMenu.title != null)
				displayName = weekData.data.storyMenu.title;
			else
			{
				// Extract clean name from path like "weeks/week1.json" -> "Week 1"
				var name = haxe.io.Path.withoutExtension(haxe.io.Path.withoutDirectory(fileKey));
				displayName = name.charAt(0).toUpperCase() + name.substr(1);
			}
			weekDisplayNames.push(displayName);
		}

		if (weekKeys.length < 1)
		{
			MusicBeatState.switchState(new MainMenuState());
			return;
		}

		if (curWeek >= weekKeys.length) curWeek = 0;

		// Background
		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, 0xFF2B2B2B);
		add(bg);

		bgSprite = new FlxSprite(0, 56);
		bgSprite.makeGraphic(FlxG.width, 400, 0xFFF9CF51);
		add(bgSprite);

		// Top bar
		var topBar:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, 56, FlxColor.BLACK);
		add(topBar);

		// Score text (top left)
		scoreText = new FlxText(10, 10, FlxG.width * 0.5, "WEEK SCORE: 0", 32);
		scoreText.setFormat(Paths.font('defaultPsych/vcr.ttf'), 32, FlxColor.WHITE);
		scoreText.scrollFactor.set();
		add(scoreText);

		// Week title (top right)
		txtWeekTitle = new FlxText(FlxG.width * 0.5, 10, FlxG.width * 0.5 - 10, "", 32);
		txtWeekTitle.setFormat(Paths.font('defaultPsych/vcr.ttf'), 32, FlxColor.WHITE, RIGHT);
		txtWeekTitle.alpha = 0.7;
		txtWeekTitle.scrollFactor.set();
		add(txtWeekTitle);

		// Week list items (below yellow area)
		var startY:Float = 470;
		var itemHeight:Float = 50;
		for (i in 0...weekKeys.length)
		{
			var item = new FlxText(0, startY + (i * itemHeight), FlxG.width, weekDisplayNames[i], 32);
			item.setFormat(Paths.font('defaultPsych/vcr.ttf'), 32, FlxColor.WHITE, CENTER);
			item.borderStyle = FlxTextBorderStyle.OUTLINE;
			item.borderColor = FlxColor.BLACK;
			item.borderSize = 2;
			item.scrollFactor.set();
			item.ID = i;
			add(item);
			weekItems.push(item);
		}

		// Tracklist (inside yellow area)
		txtTracklist = new FlxText(FlxG.width * 0.6, 80, FlxG.width * 0.35, "", 20);
		txtTracklist.setFormat(Paths.font('defaultPsych/vcr.ttf'), 20, 0xFFE55777, CENTER);
		txtTracklist.scrollFactor.set();
		add(txtTracklist);

		// Difficulty + controls
		diffText = new FlxText(0, FlxG.height - 60, FlxG.width, "", 20);
		diffText.setFormat(Paths.font('defaultPsych/vcr.ttf'), 20, FlxColor.WHITE, CENTER);
		diffText.scrollFactor.set();
		add(diffText);

		var helpTxt = new FlxText(0, FlxG.height - 30, FlxG.width, "ENTER - select | BACKSPACE - back | LEFT/RIGHT - difficulty", 14);
		helpTxt.setFormat(Paths.font('defaultPsych/vcr.ttf'), 14, 0xFFAAAAAA, CENTER);
		helpTxt.scrollFactor.set();
		add(helpTxt);

		changeWeek(0);
		super.create();
	}

	override function update(elapsed:Float)
	{
		if (selectedWeek)
		{
			super.update(elapsed);
			return;
		}

		if (controls.UI_UP_P)
			changeWeek(-1);
		if (controls.UI_DOWN_P)
			changeWeek(1);
		if (controls.UI_LEFT_P)
			changeDifficulty(-1);
		if (controls.UI_RIGHT_P)
			changeDifficulty(1);
		if (controls.BACK)
		{
			FlxG.sound.play(Paths.sound('cancelMenu'));
			MusicBeatState.switchState(new MainMenuState());
		}

		if (controls.ACCEPT)
			selectWeek();

		updateWeekItems(elapsed);
		super.update(elapsed);
	}

	function updateWeekItems(elapsed:Float)
	{
		var startY:Float = 470;
		var itemHeight:Float = 50;
		for (item in weekItems)
		{
			if (item == null) continue;
			var targetY:Float = startY + ((item.ID - curWeek) * itemHeight);
			item.y = FlxMath.lerp(item.y, targetY, Math.min(elapsed * 12, 1));
			item.alpha = (item.ID == curWeek) ? 1.0 : 0.4;
		}
	}

	function changeWeek(change:Int)
	{
		curWeek += change;
		if (curWeek < 0) curWeek = weekKeys.length - 1;
		if (curWeek >= weekKeys.length) curWeek = 0;

		FlxG.sound.play(Paths.sound('scrollMenu'));

		var weekData = WeekData.weeksDatas.get(weekKeys[curWeek]);
		txtWeekTitle.text = weekDisplayNames[curWeek];

		if (weekData != null && weekData.data.storyMenu != null)
		{
			if (weekData.data.storyMenu.bg != null)
			{
				var bgImg = Paths.image('menubackgrounds/menu_' + weekData.data.storyMenu.bg);
				if (bgImg != null)
				{
					bgSprite.loadGraphic(bgImg);
					bgSprite.setGraphicSize(FlxG.width, 400);
					bgSprite.updateHitbox();
					bgSprite.x = 0;
					bgSprite.y = 56;
				}
			}
		}

		// Tracklist
		var trackStr:String = "Tracks\n\n";
		if (weekData != null)
		{
			for (song in weekData.data.songs)
				trackStr += song.songName.toUpperCase() + "\n";
		}
		txtTracklist.text = trackStr;

		// Score
		var weekFile:String = weekKeys[curWeek];
		var scoreData = Highscore.getWeekData(weekFile, Difficulty.getString(curDifficulty));
		scoreText.text = "WEEK SCORE: " + (scoreData != null ? Std.string(scoreData.score) : "0");

		updateDifficultyText();
	}

	function changeDifficulty(change:Int)
	{
		var diffList = getDifficultyList();
		if (diffList.length <= 1) return;

		curDifficulty += change;
		if (curDifficulty < 0) curDifficulty = diffList.length - 1;
		if (curDifficulty >= diffList.length) curDifficulty = 0;

		FlxG.sound.play(Paths.sound('scrollMenu'));
		updateDifficultyText();
	}

	function getDifficultyList():Array<String>
	{
		var weekData = WeekData.weeksDatas.get(weekKeys[curWeek]);
		if (weekData != null && weekData.data.difficulties != null && weekData.data.difficulties.length > 0)
			return weekData.data.difficulties;
		return Difficulty.defaultList;
	}

	function updateDifficultyText()
	{
		var diffList = getDifficultyList();
		if (curDifficulty >= diffList.length) curDifficulty = 0;
		var diffName = diffList.length > 0 ? diffList[curDifficulty].toUpperCase() : "NORMAL";
		diffText.text = "< " + diffName + " >";
	}

	function selectWeek()
	{
		var weekData = WeekData.weeksDatas.get(weekKeys[curWeek]);
		if (weekData == null) return;

		selectedWeek = true;
		FlxG.sound.play(Paths.sound('confirmMenu'));

		// Highlight selected
		for (item in weekItems)
		{
			if (item != null && item.ID == curWeek)
				item.color = 0xFF00FF00;
		}

		// Build playlist
		var songList:Array<String> = [];
		for (song in weekData.data.songs)
			songList.push(song.songName);

		if (songList.length < 1)
		{
			selectedWeek = false;
			return;
		}

		PlayState.storyPlaylist = songList;
		PlayState.isStoryMode = true;
		PlayState.storyWeek = curWeek;

		var diffList = getDifficultyList();
		if (curDifficulty >= diffList.length) curDifficulty = 0;
		PlayState.storyDifficulty = curDifficulty;

		Difficulty.resetList();
		if (diffList.length > 0)
			Difficulty.list = diffList;

		var firstSong = Paths.formatToSongPath(songList[0]);
		var song = Song.loadFromJson(firstSong, firstSong);
		if (song != null)
		{
			PlayState.SONG = song;
			new FlxTimer().start(1.0, function(_) {
				MusicBeatState.switchState(new PlayState());
			});
		}
		else
		{
			selectedWeek = false;
			for (item in weekItems)
			{
				if (item != null && item.ID == curWeek)
					item.color = FlxColor.WHITE;
			}
		}
	}
}
