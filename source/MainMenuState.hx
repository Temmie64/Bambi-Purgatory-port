package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxCamera;
import flixel.addons.transition.FlxTransitionableState;
import flixel.effects.FlxFlicker;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.math.FlxMath;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import lime.app.Application;
import Achievements;
import editors.MasterEditorMenu;
import flixel.input.keyboard.FlxKey;
import flixel.util.FlxTimer;

using StringTools;

class MainMenuState extends MusicBeatState
{
	public static var psychEngineJSVersion:String = '1.33.0'; //This is also used for Discord RPC
	public static var psychEngineVersion:String = '0.6.3'; //This is also used for Discord RPC
	public static var curSelected:Int = 0;

	var menuItems:FlxTypedGroup<FlxSprite>;
	private var camGame:FlxCamera;
	private var camAchievement:FlxCamera;
	
	var optionShit:Array<String> = ['story_mode', 'freeplay', 'extras', 'options'];

	var magenta:FlxSprite;
	var camFollow:FlxObject;
	var camFollowPos:FlxObject;
	var debugKeys:Array<FlxKey>;

	var tipTextMargin:Float = 10;
	var tipTextScrolling:Bool = false;
	var tipBackground:FlxSprite;
	var tipText:FlxText;
	var isTweening:Bool = false;
	var lastString:String = '';

	public static var sexo3:Bool = true;

	public static var firstStart:Bool = true;

	public static var finishedFunnyMove:Bool = false;
	
	public static var daRealEngineVer:String = 'David';

	public static var engineVers:Array<String> = ['David', 'Bandu', 'Bombu', 'Bamburg', 'Golden Tristan', 'Expunged'];

	public static var bgPaths:Array<String> = 
	[
		'backgrounds/SUSSUS AMOGUS',
		'backgrounds/SwagnotrllyTheMod',
		'backgrounds/Olyantwo',
		'backgrounds/morie',
		'backgrounds/mantis',
		'backgrounds/mamakotomi',
		'backgrounds/T5mpler'
	];

	override function create()
	{
		MusicBeatState.windowNameSuffix = " - Main Menu";
		Paths.clearStoredMemory();
		Paths.clearUnusedMemory();

		#if MODS_ALLOWED
		Paths.pushGlobalMods();
		#end
		WeekData.loadTheFirstEnabledMod();

		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end
		debugKeys = ClientPrefs.copyKey(ClientPrefs.keyBinds.get('debug_1'));

		camGame = initPsychCamera();
		camAchievement = new FlxCamera();
		camAchievement.bgColor.alpha = 0;

		FlxG.cameras.add(camAchievement, false);

		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;

		persistentUpdate = persistentDraw = true;

		var yScroll:Float = Math.max(0.1 - (0.03 * (optionShit.length - 4)), 0.1);
		var bg:FlxSprite = new FlxSprite(-80).loadGraphic(randomizeBG());
		bg.scrollFactor.set(0, yScroll);
		bg.setGraphicSize(Std.int(bg.width * 1.175));
		bg.updateHitbox();
		bg.screenCenter();
		bg.antialiasing = ClientPrefs.globalAntialiasing;
		bg.color = 0xFFfd719b;
		add(bg);


		camFollow = new FlxObject(0, 0, 1, 1);
		camFollowPos = new FlxObject(0, 0, 1, 1);
		add(camFollow);
		add(camFollowPos);

		magenta = new FlxSprite(-80).loadGraphic(bg.graphic);
		magenta.scrollFactor.set(0, yScroll);
		magenta.setGraphicSize(Std.int(magenta.width * 1.175));
		magenta.updateHitbox();
		magenta.screenCenter();
		magenta.antialiasing = ClientPrefs.globalAntialiasing;
		magenta.color = 0xFFFDE871;
		add(magenta);
		
		// magenta.scrollFactor.set();

		menuItems = new FlxTypedGroup<FlxSprite>();
		add(menuItems);

		var scale:Float = 1;
		/*if(optionShit.length > 6) {
			scale = 6 / optionShit.length;
		}*/

		for (i in 0...optionShit.length)
		{
			var offset:Float = 108 - (Math.max(optionShit.length, 4) - 4) * 80;
			var menuItem:FlxSprite = new FlxSprite(0, (i * 140)  + offset);
			menuItem.scale.x = scale;
			menuItem.scale.y = scale;
			menuItem.frames = Paths.getSparrowAtlas('mainmenu/menu_' + optionShit[i]);
			menuItem.animation.addByPrefix('idle', optionShit[i] + " basic", 24);
			menuItem.animation.addByPrefix('selected', optionShit[i] + " white", 24);
			menuItem.animation.play('idle');
			menuItem.ID = i;
			menuItem.screenCenter(X);
			menuItems.add(menuItem);
			var scr:Float = (optionShit.length - 4) * 0.135;
			if(optionShit.length < 6) scr = 0;
			menuItem.scrollFactor.set(0, scr);
			menuItem.antialiasing = ClientPrefs.globalAntialiasing;
			//menuItem.setGraphicSize(Std.int(menuItem.width * 0.58));
			menuItem.updateHitbox();

			if (firstStart)
				FlxTween.tween(menuItem,{y: 60 + (i * 160)},1 + (i * 0.25) ,{ease: FlxEase.expoInOut, onComplete: function(flxTween:FlxTween) 
					{ 
						finishedFunnyMove = true; 
						changeItem();
					}});
			else
				menuItem.y = 60 + (i * 160);
		}

		FlxG.camera.follow(camFollow, null, 1);

		FlxG.camera.follow(camFollowPos, null, 1);

		var versionShit:FlxText = new FlxText(12, FlxG.height - 64, 0, "JS Engine v" + psychEngineJSVersion, 12);
		versionShit.scrollFactor.set();
		versionShit.setFormat("Comic Sans MS Bold", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versionShit);
		var versionShit:FlxText = new FlxText(12, FlxG.height - 44, 0, "Psych Engine v" + psychEngineVersion, 12);
		versionShit.scrollFactor.set();
		versionShit.setFormat("Comic Sans MS Bold", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versionShit);
		var versionShit:FlxText = new FlxText(12, FlxG.height - 24, 0, "Friday Night Funkin' v" + Application.current.meta.get('version'), 12);
		versionShit.scrollFactor.set();
		versionShit.setFormat("Comic Sans MS Bold", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versionShit);

		// NG.core.calls.event.logEvent('swag').send();

		tipBackground = new FlxSprite();
		tipBackground.scrollFactor.set();
		tipBackground.alpha = 0.7;
		tipBackground.visible = ClientPrefs.tipTexts;
		add(tipBackground);

		tipText = new FlxText(0, 0, 0, "");
		tipText.scrollFactor.set();
		tipText.setFormat("Comic Sans MS Bold", 24, FlxColor.WHITE, CENTER);
		tipText.updateHitbox();
		tipText.visible = ClientPrefs.tipTexts;
		add(tipText);

		tipBackground.makeGraphic(FlxG.width, Std.int((tipTextMargin * 2) + tipText.height), FlxColor.BLACK);

		changeItem();

		#if ACHIEVEMENTS_ALLOWED
		// Unlocks "Freaky on a Friday Night" achievement if it's a Friday and between 18:00 PM and 23:59 PM
		var leDate = Date.now();
		if (leDate.getDay() == 5 && leDate.getHours() >= 18)
			Achievements.unlock('friday_night_play');

		#if MODS_ALLOWED
		Achievements.reloadList();
		#end
		#end

		changeItem();
		tipTextStartScrolling();

		super.create();
	}

	var selectedSomethin:Bool = false;
	//credit to stefan2008 and sb engine for this code
	function tipTextStartScrolling()
	{
		tipText.x = tipTextMargin;
		tipText.y = -tipText.height;

		new FlxTimer().start(1.0, function(timer:FlxTimer)
		{
			FlxTween.tween(tipText, {y: tipTextMargin}, 0.3);
			new FlxTimer().start(2.25, function(timer:FlxTimer)
			{
				tipTextScrolling = true;
			});
		});
	}

	function changeTipText() {
		var selectedText:String = '';
		var textArray:Array<String> = CoolUtil.coolTextFile(Paths.txt('funnyTips'));

		tipText.alpha = 1;
		isTweening = true;
		selectedText = textArray[FlxG.random.int(0, (textArray.length - 1))].replace('--', '\n');
		FlxTween.tween(tipText, {alpha: 0}, 1, {
			ease: FlxEase.linear,
			onComplete: function(freak:FlxTween) {
				if (selectedText != lastString) {
					tipText.text = selectedText;
					lastString = selectedText;
				} else {
					selectedText = textArray[FlxG.random.int(0, (textArray.length - 1))].replace('--', '\n');
					tipText.text = selectedText;
				}

				tipText.alpha = 0;

				FlxTween.tween(tipText, {alpha: 1}, 1, {
					ease: FlxEase.linear,
					onComplete: function(freak:FlxTween) {
						isTweening = false;
					}
				});
			}
		});
	}

	override function update(elapsed:Float)
	{
		FlxG.camera.followLerp = 7.5;
		if (tipTextScrolling)
		{
			tipText.x -= elapsed * 130;
			if (tipText.x < -tipText.width)
			{
				tipTextScrolling = false;
				tipTextStartScrolling();
				changeTipText();
			}
		}
		if (FlxG.sound.music.volume < 0.8)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
			if(FreeplayState.vocals != null) FreeplayState.vocals.volume += 0.5 * elapsed;
		}

		var lerpVal:Float = CoolUtil.boundTo(elapsed * 5.6, 0, 1);
		camFollowPos.setPosition(FlxMath.lerp(camFollowPos.x, camFollow.x, lerpVal), FlxMath.lerp(camFollowPos.y, camFollow.y, lerpVal));

		if (!selectedSomethin)
		{
			if (controls.UI_UP_P)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(-1);
			}

			if (controls.UI_DOWN_P)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(1);
			}

			if (controls.BACK)
			{
				selectedSomethin = true;
				FlxG.sound.play(Paths.sound('cancelMenu'));
				FlxG.switchState(TitleState.new);
				sexo3 = false;
			}

			if (controls.ACCEPT)
			{
				if (optionShit[curSelected] == 'donate')
				{
					CoolUtil.browserLoad('https://github.com/JordanSantiagoYT/FNF-JS-Engine');
				}
				else
				{
					selectedSomethin = true;
					FlxG.sound.play(Paths.sound('confirmMenu'));

					if(ClientPrefs.flashing) FlxFlicker.flicker(magenta, 1.1, 0.15, false);

					FlxTween.tween(FlxG.camera, {zoom:1.35}, 1.45, {ease: FlxEase.expoIn});

					menuItems.forEach(function(spr:FlxSprite)
					{
						if (curSelected != spr.ID)
						{
							FlxTween.tween(spr, {alpha: 0}, 1.3, {
								ease: FlxEase.quadOut,
								onComplete: function(twn:FlxTween)
								{
									spr.kill();
								}
							});
						}
						else
						{
							FlxFlicker.flicker(spr, 1, 0.06, false, false, function(flick:FlxFlicker)
							{
								goToState();								
							});
						}
					});
				}
			}
		#if (desktop)
		else if (FlxG.keys.anyJustPressed(debugKeys)) {
			FlxG.switchState(MasterEditorMenu.new);
		}
		#end
		}

		super.update(elapsed);

		menuItems.forEach(function(spr:FlxSprite)
		{
			spr.screenCenter(X);
		});
	}

	function changeItem(huh:Int = 0)
	{
		curSelected += huh;

		if (curSelected >= menuItems.length)
			curSelected = 0;
		if (curSelected < 0)
			curSelected = menuItems.length - 1;

		menuItems.forEach(function(spr:FlxSprite)
		{
			spr.animation.play('idle');
			spr.updateHitbox();

			if (spr.ID == curSelected)
			{
				spr.animation.play('selected');
				var add:Float = 0;
				if(menuItems.length > 4) {
					add = menuItems.length * 8;
				}
				camFollow.setPosition(spr.getGraphicMidpoint().x, spr.getGraphicMidpoint().y - add);
				spr.centerOffsets();
			}
		});
	}

	function goToState()
	{								
		var daChoice:String = optionShit[curSelected];
	
		switch (daChoice)
		{
			case 'story_mode':
				FlxG.switchState(StoryMenuState.new);
			case 'freeplay':
				FlxG.switchState(FreeplayState.new);
			case 'extras':
				FlxG.switchState(new ExtrasMenuState());
			case 'credits':
				FlxG.switchState(CreditsState.new);
			case 'awards':
				LoadingState.loadAndSwitchState(AchievementsMenuState.new);
			case 'options':
				LoadingState.loadAndSwitchState(options.OptionsState.new);
		}
	}

	public static function randomizeBG():flixel.system.FlxAssets.FlxGraphicAsset
	{
		var chance:Int = FlxG.random.int(0, bgPaths.length - 1);
		return Paths.image('backgrounds/${bgPaths[chance]}');
	}

	/*public static function randomizeBG():flixel.system.FlxAssets.FlxGraphicAsset
	{
		var date = Date.now();
		var chance:Int = FlxG.random.int(0, bgPaths.length - 1);
		if(date.getMonth() == 3 && date.getDate() == 1)
		{
			return Paths.image('backgrounds/ramzgaming');
		}
		else
		{
			return Paths.image('backgrounds/${bgPaths[chance]}');
		}
	}*/
}
