package;

import flixel.input.gamepad.FlxGamepad;
import openfl.Lib;
#if windows
import llua.Lua;
#end
import Controls.Control;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.addons.transition.FlxTransitionableState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.keyboard.FlxKey;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import lime.app.Application;
import Sys;

class PauseSubState extends MusicBeatSubstate
{
	var grpMenuShit:FlxTypedGroup<Alphabet>;

	var menuItems:Array<String> = ['Resume', 'Restart Song', 'Edit', 'Botplay', 'Options', 'Quit'];
	var curSelected:Int = 0;

	var pauseMusic:FlxSound;
	
	var offsetChanged:Bool = false;

	var brokenThing:Int = 0;

	public function new(x:Float, y:Float)
	{
		super();

		FlxG.mouse.visible = true;
		
		if (PlayState.instance.useVideo)
		{
			menuItems.remove("Resume");
			if (GlobalVideo.get().playing)
				GlobalVideo.get().pause();
		}

		pauseMusic = new FlxSound().loadEmbedded(Paths.music('breakfast'), true, true);
		pauseMusic.volume = 0;
		pauseMusic.play(false, FlxG.random.int(0, Std.int(pauseMusic.length / 2)));

		FlxG.sound.list.add(pauseMusic);

		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		bg.alpha = 0;
		bg.scrollFactor.set();
		add(bg);

		var levelInfo:FlxText = new FlxText(20, 15, 0, "", 32);
		levelInfo.text += PlayState.SONG.song;
		levelInfo.scrollFactor.set();
		levelInfo.setFormat(Paths.font("vcr.ttf"), 32);
		levelInfo.updateHitbox();
		add(levelInfo);

		var levelDifficulty:FlxText = new FlxText(20, 15 + 32, 0, "", 32);
		levelDifficulty.text += Utility.difficultyFromInt(PlayState.storyDifficulty).toUpperCase();
		levelDifficulty.scrollFactor.set();
		levelDifficulty.setFormat(Paths.font('vcr.ttf'), 32);
		levelDifficulty.updateHitbox();
		add(levelDifficulty);

		levelDifficulty.alpha = 0;
		levelInfo.alpha = 0;

		levelInfo.x = FlxG.width - (levelInfo.width + 20);
		levelDifficulty.x = FlxG.width - (levelDifficulty.width + 20);

		FlxTween.tween(bg, {alpha: 0.6}, 0.4, {ease: FlxEase.quartInOut});
		FlxTween.tween(levelInfo, {alpha: 1, y: 20}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.3});
		FlxTween.tween(levelDifficulty, {alpha: 1, y: levelDifficulty.y + 5}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.5});

		grpMenuShit = new FlxTypedGroup<Alphabet>();
		add(grpMenuShit);
		
		for (i in 0...menuItems.length)
		{
			var songText:Alphabet = new Alphabet(0, (70 * i) + 30, menuItems[i], true, false);
			songText.isMenuItem = true;
			songText.targetY = i;
			grpMenuShit.add(songText);
		}

		changeSelection();

		cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];
	}

	override function update(elapsed:Float)
	{
		if (pauseMusic.volume < 0.5)
			pauseMusic.volume += 0.01 * elapsed;

		super.update(elapsed);

		if (PlayState.instance.useVideo)
			menuItems.remove('Resume');

		var gamepad:FlxGamepad = FlxG.gamepads.lastActive;

		var upP = controls.UP_P;
		var downP = controls.DOWN_P;
		var leftP = controls.LEFT_P;
		var rightP = controls.RIGHT_P;
		var accepted = controls.ACCEPT;
		var oldOffset:Float = 0;

		if (gamepad != null && KeyBinds.gamepad)
		{
			upP = gamepad.justPressed.DPAD_UP;
			downP = gamepad.justPressed.DPAD_DOWN;
			leftP = gamepad.justPressed.DPAD_LEFT;
			rightP = gamepad.justPressed.DPAD_RIGHT;
		}
		
		if (controls.UP_P)
		{
			changeSelection(-1);
	   
		}
		else if (controls.DOWN_P)
		{
			changeSelection(1);
		}
		// pre lowercasing the song name (update)
		var songLowercase = StringTools.replace(PlayState.SONG.song, " ", "-").toLowerCase();
		switch (songLowercase) {
			case 'dad-battle': songLowercase = 'dadbattle';
			case 'philly-nice': songLowercase = 'philly';
		}
		var songPath = 'assets/data/' + songLowercase + '/';

		


		if (accepted)
		{
			var daSelected:String = menuItems[curSelected];

			switch (daSelected)
			{
				case "Resume":
					FlxG.mouse.visible = false;	
					close();
					
				case "Restart Song":
					if (PlayState.instance.useVideo)
					{
						GlobalVideo.get().stop();
						PlayState.instance.remove(PlayState.instance.videoSprite);
						PlayState.instance.removedVideo = true;
					}
					FlxG.resetState();


				case "Edit":
						if (PlayState.instance.useVideo)
						{
							GlobalVideo.get().stop();
							PlayState.instance.remove(PlayState.instance.videoSprite);
							PlayState.instance.removedVideo = true;
						}
						if(PlayState.loadRep)
						{
							FlxG.save.data.botplay = false;
							FlxG.save.data.scrollSpeed = 1;
							FlxG.save.data.downscroll = false;
						}
						PlayState.loadRep = false;
						#if windows
						if (PlayState.modchart != null)
						{
							PlayState.modchart.die();
							PlayState.modchart = null;
						}
						#end
						if (FlxG.save.data.fpsCap > 290)
						{
							(cast (Lib.current.getChildAt(0), Main)).setFPSCap(290);
						}

						GlobalData.latestDiff = PlayState.storyDifficulty;
						editors.ChartingState.fromSongMenu = false;
						FlxG.switchState(new editors.ChartingState());
				case 'Botplay':
					PlayStateChangeables.botPlay = switch(PlayStateChangeables.botPlay){case true: false; case false: true;};
				case "Quit":
					if (PlayState.instance.useVideo)
					{
						GlobalVideo.get().stop();
						PlayState.instance.remove(PlayState.instance.videoSprite);
						PlayState.instance.removedVideo = true;
					}
					if(PlayState.loadRep)
					{
						FlxG.save.data.botplay = false;
						FlxG.save.data.scrollSpeed = 1;
						FlxG.save.data.downscroll = false;
					}
					PlayState.loadRep = false;
					#if windows
					if (PlayState.modchart != null)
					{
						PlayState.modchart.die();
						PlayState.modchart = null;
					}
					#end
					if (FlxG.save.data.fpsCap > 290)
						(cast (Lib.current.getChildAt(0), Main)).setFPSCap(290);
					
					
					if (PlayState.SONG.song == "broken")
					{
						Lib.application.window.title = "Friday Night Funkin': The Cuzsie Mod";
					}
					FlxG.switchState(new MainMenuState());
			}
		}
	}

	override function destroy()
	{
		pauseMusic.destroy();

		super.destroy();
	}

	function changeSelection(change:Int = 0):Void
	{
		curSelected += change;

		if (curSelected < 0)
			curSelected = menuItems.length - 1;
		if (curSelected >= menuItems.length)
			curSelected = 0;

		var bullShit:Int = 0;

		for (item in grpMenuShit.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;

			item.alpha = 0.6;
			// item.setGraphicSize(Std.int(item.width * 0.8));

			if (item.targetY == 0)
			{
				item.alpha = 1;
				// item.setGraphicSize(Std.int(item.width));
			}
		}
	}
}