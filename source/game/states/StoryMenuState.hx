package game.states;

import game.backend.data.jsons.WeekData;
import game.backend.system.song.Song;
import game.backend.system.states.MusicBeatState;
import game.backend.utils.Difficulty;
import game.backend.utils.Highscore;
import game.objects.Alphabet;
import game.objects.game.HealthIcon;
import game.states.playstate.PlayState;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;

class StoryMenuState extends MusicBeatState
{
	var scoreText:FlxText;
	var txtWeekTitle:FlxText;
	var txtTracklist:FlxText;
	var grpWeekText:FlxTypedGroup<Alphabet>;
	var bgSprite:FlxSprite;

	var weekKeys:Array<String> = [];

	static var curWeek:Int = 0;
	var curDifficulty:Int = 1;

	var selectedWeek:Bool = false;

	override function create()
	{
		Paths.clearUnusedMemory();
		PlayState.isStoryMode = true;

		WeekData.reloadWeeksFiles(true);

		for (key in WeekData.weeksListOrder)
			weekKeys.push(key.file);

		if (weekKeys.length < 1)
		{
			MusicBeatState.switchState(new MainMenuState());
			return;
		}

		if (curWeek >= weekKeys.length) curWeek = 0;

		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, 0xFF2B2B2B);
		add(bg);

		bgSprite = new FlxSprite(0, 56);
		bgSprite.makeGraphic(FlxG.width, 400, 0xFFF9CF51);
		add(bgSprite);

		var topBar:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, 56, FlxColor.BLACK);
		add(topBar);

		grpWeekText = new FlxTypedGroup<Alphabet>();
		add(grpWeekText);

		for (i in 0...weekKeys.length)
		{
			var weekData = WeekData.weeksDatas.get(weekKeys[i]);
			var weekName:String = weekData != null && weekData.data.storyMenu != null ? weekData.data.storyMenu.title : weekKeys[i];
			var weekItem = new Alphabet(0, 480 + (i * 120), weekName, true);
			weekItem.screenCenter(flixel.util.FlxAxes.X);
			weekItem.ID = i;
			grpWeekText.add(weekItem);
		}

		scoreText = new FlxText(10, 10, FlxG.width - 20, "WEEK SCORE: 0", 32);
		scoreText.setFormat(Paths.font('defaultPsych/vcr.ttf'), 32, FlxColor.WHITE);
		add(scoreText);

		txtWeekTitle = new FlxText(0, 10, FlxG.width * 0.3, "", 32);
		txtWeekTitle.setFormat(Paths.font('defaultPsych/vcr.ttf'), 32, FlxColor.WHITE, RIGHT);
		txtWeekTitle.x = FlxG.width * 0.7 - 10;
		txtWeekTitle.alpha = 0.7;
		add(txtWeekTitle);

		txtTracklist = new FlxText(0, bgSprite.y + bgSprite.height + 50, FlxG.width, "", 24);
		txtTracklist.setFormat(Paths.font('defaultPsych/vcr.ttf'), 24, 0xFFE55777, CENTER);
		add(txtTracklist);

		var diffTxt = new FlxText(0, FlxG.height - 40, FlxG.width, "< NORMAL > | ENTER to select | BACKSPACE to go back", 16);
		diffTxt.setFormat(Paths.font('defaultPsych/vcr.ttf'), 16, FlxColor.WHITE, CENTER);
		add(diffTxt);

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
		if (controls.BACK)
		{
			FlxG.sound.play(Paths.sound('cancelMenu'));
			MusicBeatState.switchState(new MainMenuState());
		}

		if (controls.ACCEPT)
			selectWeek();

		updateWeekItems();
		super.update(elapsed);
	}

	function updateWeekItems()
	{
		for (item in grpWeekText.members)
		{
			if (item == null) continue;
			var targetY:Float = 480 + ((item.ID - curWeek) * 120);
			item.y = FlxMath.lerp(item.y, targetY, 0.17);
			item.alpha = (item.ID == curWeek) ? 1.0 : 0.6;
		}
	}

	function changeWeek(change:Int)
	{
		curWeek += change;
		if (curWeek < 0) curWeek = weekKeys.length - 1;
		if (curWeek >= weekKeys.length) curWeek = 0;

		FlxG.sound.play(Paths.sound('scrollMenu'));

		var weekData = WeekData.weeksDatas.get(weekKeys[curWeek]);
		if (weekData != null && weekData.data.storyMenu != null)
		{
			txtWeekTitle.text = weekData.data.storyMenu.title;

			// Update background if week has a bg image
			if (weekData.data.storyMenu.bg != null)
			{
				var bgImg = Paths.image('menubackgrounds/menu_' + weekData.data.storyMenu.bg);
				if (bgImg != null)
				{
					bgSprite.loadGraphic(bgImg);
					bgSprite.setGraphicSize(FlxG.width, 400);
					bgSprite.updateHitbox();
				}
			}
		}

		// Update tracklist
		var trackStr:String = "Tracks:\n";
		if (weekData != null)
		{
			for (song in weekData.data.songs)
				trackStr += song.songName.toUpperCase() + "\n";
		}
		txtTracklist.text = trackStr;

		// Update score
		var weekFile:String = weekKeys[curWeek];
		var scoreData = Highscore.getWeekData(weekFile, Difficulty.getString(curDifficulty));
		scoreText.text = "WEEK SCORE: " + (scoreData != null ? Std.string(scoreData.score) : "0");
	}

	function selectWeek()
	{
		var weekData = WeekData.weeksDatas.get(weekKeys[curWeek]);
		if (weekData == null) return;

		selectedWeek = true;
		FlxG.sound.play(Paths.sound('confirmMenu'));

		// Build playlist
		var songList:Array<String> = [];
		for (song in weekData.data.songs)
			songList.push(song.songName);

		if (songList.length < 1) return;

		// Load first song
		var diffStr:String = Difficulty.getString(curDifficulty);
		PlayState.storyPlaylist = songList;
		PlayState.isStoryMode = true;
		PlayState.storyWeek = curWeek;
		PlayState.storyDifficulty = curDifficulty;

		Difficulty.resetList();
		var diffs = weekData.data.difficulties;
		if (diffs != null && diffs.length > 0)
			Difficulty.list = diffs;

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
		}
	}
}
