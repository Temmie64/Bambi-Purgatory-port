package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.input.keyboard.FlxKey;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.transition.TransitionData;
import haxe.Json;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
#if MODS_ALLOWED
import sys.FileSystem;
import sys.io.File;
#end
import options.GraphicsSettingsSubState;
//import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.graphics.frames.FlxFrame;
import flixel.group.FlxGroup;
import flixel.input.gamepad.FlxGamepad;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.sound.FlxSound;
import flixel.system.ui.FlxSoundTray;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flixel.util.FlxGradient;
import openfl.Assets;
import purgatory.PurTitleState;
import trolling.SusState;
import trolling.CheaterState;
import trolling.YouCheatedSomeoneIsComing;
import trolling.CrasherState;

using StringTools;
typedef TitleData =
{

	titlex:Float,
	titley:Float,
	startx:Float,
	starty:Float,
	gfx:Float,
	gfy:Float,
	backgroundSprite:String,
	bpm:Int,
	endY:Float,
}
class TitleState extends MusicBeatState
{
	public static var muteKeys:Array<FlxKey> = [FlxKey.ZERO];
	public static var volumeDownKeys:Array<FlxKey> = [FlxKey.NUMPADMINUS, FlxKey.MINUS];
	public static var volumeUpKeys:Array<FlxKey> = [FlxKey.NUMPADPLUS, FlxKey.PLUS];

	public static var initialized:Bool = false;

	var blackScreen:FlxSprite;
	var credGroup:FlxGroup;
	var credTextShit:Alphabet;
	var textGroup:FlxGroup;
	var ngSpr:FlxSprite;
	
	var titleTextColors:Array<FlxColor> = [0xFF33FFFF, 0xFF3333CC];
	var titleTextAlphas:Array<Float> = [1, .64];

	var gradientBar:FlxSprite = new FlxSprite(0, 0).makeGraphic(FlxG.width, 1, 0xFF0F5FFF);

	var curWacky:Array<String> = [];

	var Timer:Float = 0;

	var fun:Int;

	var wackyImage:FlxSprite;

	var mustUpdate:Bool = false;

	public static var titleJSON:TitleData;

	public static var updateVersion:String = '';

	private var doTheFunny:Bool = false;

	override public function create():Void
	{
		Paths.clearStoredMemory();
		Paths.clearUnusedMemory();

		MusicBeatState.windowNameSuffix = " - Title Screen";
		// ???
		MusicBeatState.windowNameSuffix = "";

		MusicBeatState.windowNamePrefix = Assets.getText(Paths.txt("windowTitleBase", "preload"));

		curWacky = FlxG.random.getObject(getIntroTextShit());

		// DEBUG BULLSHIT

		swagShader = new ColorSwap();
		super.create();

		#if (CHECK_FOR_UPDATES)
		if(ClientPrefs.checkForUpdates && !closedState && !Main.askedToUpdate) {
			trace('checking for update');
			var http = new haxe.Http("https://raw.githubusercontent.com/JordanSantiagoYT/FNF-JS-Engine/main/THECHANGELOG.md");
			var returnedData:Array<String> = [];

			http.onData = function (data:String)
			{
    				var versionEndIndex:Int = data.indexOf(';');
    				returnedData[0] = data.substring(0, versionEndIndex);

    				// Extract the changelog after the version number
    				returnedData[1] = data.substring(versionEndIndex + 1, data.length);
				updateVersion = returnedData[0];
				var curVersion:String = MainMenuState.psychEngineJSVersion.trim();
				trace('version online: ' + updateVersion + ', your version: ' + curVersion);
				if(updateVersion != curVersion) {
					trace('versions arent matching!');
					OutdatedState.currChanges = returnedData[1];
					mustUpdate = true;
					Main.askedToUpdate = true;
				}
				if(updateVersion == curVersion) {
					trace('the versions match!');
				}
			}

			http.onError = function (error) {
				trace('error: $error');
			}

			http.request();
		}
		#end

		Highscore.load();

		// IGNORE THIS!!!
		titleJSON = Json.parse(Paths.getTextFromFile('images/gfDanceTitle.json'));

		if(!initialized)
		{
			if(FlxG.save.data != null && FlxG.save.data.fullscreen)
			{
				FlxG.fullscreen = FlxG.save.data.fullscreen;
			}
			persistentUpdate = true;
			persistentDraw = true;
		}

		if (FlxG.save.data.weekCompleted != null)
		{
			StoryMenuState.weekCompleted = FlxG.save.data.weekCompleted;
		}

		FlxG.mouse.visible = false;
		#if FREEPLAY
		FlxG.switchState(FreeplayState.new);
		#elseif CHARTING
		FlxG.switchState(ChartingState.new);
		#else
		if(FlxG.save.data.flashing == null && !FlashingState.leftState) {
			FlxTransitionableState.skipNextTransIn = true;
			FlxTransitionableState.skipNextTransOut = true;
			FlxG.switchState(FlashingState.new);
		} else {
			if (initialized)
				startIntro();
			else
			{
				new FlxTimer().start(1, function(tmr:FlxTimer)
				{
					startIntro();
				});
			}
		}
		#end
	}

	var logoBl:FlxSprite;
	var gfDance:FlxSprite;
	var danceLeft:Bool = false;
	var titleText:FlxSprite;
	var arrowshit:FlxSprite;
	var swagShader:ColorSwap = null;

	function startIntro()
	{
		if (!initialized)
		{
			FlxG.camera.zoom = 1.5;
			FlxG.camera.angle = 30;

			FlxTween.tween(FlxG.camera, {zoom:1}, 0.95, {ease: FlxEase.quadOut});
			FlxTween.tween(FlxG.camera, {angle:0}, 0.95, {ease: FlxEase.quadOut});

			if(FlxG.sound.music == null) {
				FlxG.sound.playMusic(Paths.music('freakyMenu-' + ClientPrefs.daMenuMusic), 0);
				FlxG.sound.music.fadeIn(1, 0, 0.8);
			}

			FlxG.sound.music.fadeIn(4, 0, 0.7);
		}

		switch(ClientPrefs.daMenuMusic) // change this if you're making a source mod, like add your own or something
		{
			case 'Mashup' | 'VS Impostor' | 'VS Nonsense V2': 
				Conductor.changeBPM(102);
			case 'Dave & Bambi':
				Conductor.changeBPM(148);
			case 'Dave & Bambi (Old)':
				Conductor.changeBPM(150);
			case 'DDTO+':
				Conductor.changeBPM(120);
			case 'Anniversary':
				Conductor.changeBPM(115);
			case 'Base Game' | 'Default': // just in case you're not making a source mod & wanna change this
				Conductor.changeBPM(titleJSON.bpm);
			default: // fallback
				Conductor.changeBPM(titleJSON.bpm);
		}
		persistentUpdate = true;

		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		// bg.antialiasing = ClientPrefs.globalAntialiasing;
		// bg.setGraphicSize(Std.int(bg.width * 0.6));
		// bg.updateHitbox();
		add(bg);

		if (titleJSON.backgroundSprite != null && titleJSON.backgroundSprite.length > 0 && titleJSON.backgroundSprite != "none"){
			bg.loadGraphic(Paths.image(titleJSON.backgroundSprite));
		}else{
			bg.makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		}
		add(bg);

		logoBl = new FlxSprite(titleJSON.titlex, titleJSON.titley);
		logoBl.frames = Paths.getSparrowAtlas('logoBumpin');

		logoBl.antialiasing = ClientPrefs.globalAntialiasing;
		logoBl.animation.addByPrefix('bump', 'logo bumpin', 24, false);
		logoBl.animation.play('bump');
		logoBl.updateHitbox();

		swagShader = new ColorSwap();
		gfDance = new FlxSprite(titleJSON.gfx, titleJSON.gfy);

		gfDance.frames = Paths.getSparrowAtlas('gfDanceTitle');
		gfDance.animation.addByIndices('danceLeft', 'gfDance', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
		gfDance.animation.addByIndices('danceRight', 'gfDance', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);
		gfDance.antialiasing = ClientPrefs.globalAntialiasing;

		add(gfDance);
		gfDance.shader = swagShader.shader;
		add(logoBl);
		logoBl.shader = swagShader.shader;

		titleText = new FlxSprite(titleJSON.startx, titleJSON.starty);
		#if (desktop && MODS_ALLOWED)
		var path = "mods/" + Paths.currentModDirectory + "/images/titleEnter.png";
		//trace(path, FileSystem.exists(path));
		if (!FileSystem.exists(path)){
			path = "mods/images/titleEnter.png";
		}
		//trace(path, FileSystem.exists(path));
		if (!FileSystem.exists(path)){
			path = "assets/images/titleEnter.png";
		}
		//trace(path, FileSystem.exists(path));
		titleText.frames = FlxAtlasFrames.fromSparrow(BitmapData.fromFile(path),File.getContent(StringTools.replace(path,".png",".xml")));
		#else

		titleText.frames = Paths.getSparrowAtlas('titleEnter');
		#end
		var animFrames:Array<FlxFrame> = [];
		@:privateAccess {
			titleText.animation.findByPrefix(animFrames, "ENTER IDLE");
			titleText.animation.findByPrefix(animFrames, "ENTER FREEZE");
		}
		
		if (animFrames.length > 0) {
			newTitle = true;
			
			titleText.animation.addByPrefix('idle', "ENTER IDLE", 24);
			titleText.animation.addByPrefix('press', ClientPrefs.flashing ? "ENTER PRESSED" : "ENTER FREEZE", 24);
		}
		else {
			newTitle = false;
			
			titleText.animation.addByPrefix('idle', "Press Enter to Begin", 24);
			titleText.animation.addByPrefix('press', "ENTER PRESSED", 24);
		}
		
		titleText.antialiasing = ClientPrefs.globalAntialiasing;
		titleText.animation.play('idle');
		titleText.updateHitbox();
		add(titleText);

		credGroup = new FlxGroup();
		add(credGroup);
		textGroup = new FlxGroup();

		blackScreen = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		credGroup.add(blackScreen);

		credTextShit = new Alphabet(0, 0, "", true);
		credTextShit.screenCenter();

		credTextShit.visible = false;

		ngSpr = new FlxSprite(0, FlxG.height * 0.4).loadGraphic(Paths.image('newgrounds_logo'));
		add(ngSpr);
		ngSpr.visible = false;
		ngSpr.setGraphicSize(Std.int(ngSpr.width * 0.55));
		ngSpr.updateHitbox();
		ngSpr.screenCenter(X);
		ngSpr.antialiasing = ClientPrefs.globalAntialiasing;

		arrowshit = new FlxSprite(-80).loadGraphic(Paths.image('stupidarrows'));
		arrowshit.setGraphicSize(Std.int(arrowshit.width * 1));
		arrowshit.updateHitbox();
		arrowshit.screenCenter();
		arrowshit.antialiasing = ClientPrefs.globalAntialiasing;

		FlxTween.tween(credTextShit, {y: credTextShit.y + 20}, 2.9, {ease: FlxEase.quadInOut, type: PINGPONG});

		if (initialized)
			skipIntro();
		else
			initialized = true;

		// credGroup.add(credTextShit);
	}

	function getIntroTextShit():Array<Array<String>>
	{
		var fullText:String = Assets.getText(Paths.txt('introText'));

		var firstArray:Array<String> = fullText.split('\n');
		var swagGoodArray:Array<Array<String>> = [];

		for (i in firstArray)
		{
			swagGoodArray.push(i.split('--'));
		}

		return swagGoodArray;
	}

	var transitioning:Bool = false;
	
	var newTitle:Bool = false;
	var titleTimer:Float = 0;

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music != null)
			Conductor.songPosition = FlxG.sound.music.time;
		// FlxG.watch.addQuick('amp', FlxG.sound.music.amplitude);

		Timer += 1;
		gradientBar.scale.y += Math.sin(Timer / 10) * 0.001;
		gradientBar.updateHitbox();
		gradientBar.y = FlxG.height - gradientBar.height;
		// gradientBar = FlxGradient.createGradientFlxSprite(Math.round(FlxG.width), Math.round(gradientBar.height), [0x00ff0000, 0xaaAE59E4, 0xff19ECFF], 1, 90, true);

		if (FlxG.keys.justPressed.F)
		{
			FlxG.fullscreen = !FlxG.fullscreen;
		}

		var pressedEnter:Bool = FlxG.keys.justPressed.ENTER || controls.ACCEPT;

		var gamepad:FlxGamepad = FlxG.gamepads.lastActive;

		if (gamepad != null)
		{
			if (gamepad.justPressed.START)
				pressedEnter = true;

			#if switch
			if (gamepad.justPressed.B)
				pressedEnter = true;
			#end
		}

		var pressLeftNright:Bool = FlxG.keys.justPressed.LEFT || FlxG.keys.justPressed.RIGHT #if android || _virtualpad.buttonC.justPressed #end;

		var gamepad:FlxGamepad = FlxG.gamepads.lastActive;

		if (gamepad != null)
		{
			if (gamepad.justPressed.Y)
				pressLeftNright = true;
	
			#if switch
			if (gamepad.justPressed.Y)
				pressLeftNright = true;
			#end
		}
		
		if (newTitle) {
			titleTimer += CoolUtil.boundTo(elapsed, 0, 1);
			if (titleTimer > 2) titleTimer -= 2;
		}

		// for testing purposes
		/*
		if (FlxG.keys.checkStatus(FlxKey.SEVEN, JUST_PRESSED))
			throw 'Crash test';
		*/

		// EASTER EGG

		if (initialized && !transitioning && skippedIntro)
		{
			if (newTitle && !pressedEnter)
			{
				var timer:Float = titleTimer;
				if (timer >= 1)
					timer = (-timer) + 2;
				
				timer = FlxEase.quadInOut(timer);
				
				titleText.color = FlxColor.interpolate(titleTextColors[0], titleTextColors[1], timer);
				titleText.alpha = FlxMath.lerp(titleTextAlphas[0], titleTextAlphas[1], timer);
			}
			
			if(pressedEnter)
			{
				titleText.color = FlxColor.WHITE;
				titleText.alpha = 1;
				
				if(titleText != null) titleText.animation.play('press');

				FlxG.camera.flash(ClientPrefs.flashing ? FlxColor.WHITE : 0x4CFFFFFF, 1);
				FlxG.sound.play(Paths.sound('confirmMenu'), 0.7);

				transitioning = true;

				new FlxTimer().start(1, function(tmr:FlxTimer)
				{
					if (mustUpdate) {
						FlxG.switchState(WarningState.new);
					} else {
						FlxG.switchState(WarningState.new);
					}
					closedState = true;
					MainMenuState.sexo3 = true;
				});
			}

			if(pressLeftNright)
			{
				FlxG.camera.flash(ClientPrefs.flashing ? FlxColor.WHITE : 0x4CFFFFFF, 1);
				FlxG.sound.play(Paths.sound('confirmMenu'), 0.7);
	
				FlxTween.tween(FlxG.camera, {y: FlxG.height}, 1.2, {ease: FlxEase.expoIn, startDelay: 0.4});
	
				transitioning = true;
				// FlxG.sound.music.stop();
	
				MainMenuState.firstStart = true;
				MainMenuState.finishedFunnyMove = false;
		
				MainMenuState.firstStart = true;

				new FlxTimer().start(1, function(tmr:FlxTimer)
				{
					if (mustUpdate) {
						FlxG.switchState(PurTitleState.new);
					} else {
						FlxG.switchState(PurTitleState.new);
					}
					closedState = true;
					MainMenuState.sexo3 = false;
				});

				FlxG.sound.music.stop();
			}
		}

		if (initialized && pressedEnter && !skippedIntro)
		{
			skipIntro();
		}
		if (pressLeftNright && !skippedIntro)
		{
			skipIntro2();
		}

		if(swagShader != null)
		{
			if(controls.UI_LEFT) swagShader.hue -= elapsed * 0.1;
			if(controls.UI_RIGHT) swagShader.hue += elapsed * 0.1;
		}

		super.update(elapsed);
	}

	function createCoolText(textArray:Array<String>, ?offset:Float = 0)
	{
		for (i in 0...textArray.length)
		{
			var money:Alphabet = new Alphabet(0, 0, textArray[i], true);
			money.screenCenter(X);
			money.y += (i * 60) + 200 + offset;
			if(credGroup != null && textGroup != null) {
				credGroup.add(money);
				textGroup.add(money);
			}
		}
	}

	function addMoreText(text:String, ?offset:Float = 0)
	{
		if(textGroup != null && credGroup != null) {
			var coolText:Alphabet = new Alphabet(0, 0, text, true);
			coolText.screenCenter(X);
			coolText.y += (textGroup.length * 60) + 200 + offset;
			credGroup.add(coolText);
			textGroup.add(coolText);
		}
	}

	function deleteCoolText()
	{
		while (textGroup.members.length > 0)
		{
			credGroup.remove(textGroup.members[0], true);
			textGroup.remove(textGroup.members[0], true);
		}
	}

	private var sickBeats:Int = 0; //Basically curBeat but won't be skipped if you hold the tab or resize the screen
	public static var closedState:Bool = false;
	override function beatHit()
	{
		super.beatHit();

		FlxG.camera.zoom += 0.015;

		FlxTween.tween(FlxG.camera, {zoom: 1}, Conductor.crochet / 1200, {ease: FlxEase.quadOut});

		if(logoBl != null)
			logoBl.animation.play('bump', true);

		if(gfDance != null) {
			danceLeft = !danceLeft;
			if (danceLeft)
				gfDance.animation.play('danceRight');
			else
				gfDance.animation.play('danceLeft');
		}

		if(!closedState) {
			sickBeats++;
			switch (sickBeats)
			{
				case 1:
					//FlxG.sound.music.stop();
					FlxG.sound.playMusic(Paths.music('freakyMenu-' + ClientPrefs.daMenuMusic), 0);
					FlxG.sound.music.fadeIn(4, 0, 0.7);
				case 2:
					createCoolText([' '], 45);
				// credTextShit.visible = true;
				case 3:
					addMoreText('Psych Engine by\nShadow Mario\nRiverOaken\nbb-panzu', 45);
				// credTextShit.text += '\npresent...';
				// credTextShit.addText();
				case 4:
					deleteCoolText();
				// credTextShit.visible = false;
				// credTextShit.text = 'In association \nwith';
				// credTextShit.screenCenter();
				case 5:
					createCoolText(['A fan tweak and mod of\nThis mod down below'], -60);
					ngSpr.visible = true;
				case 7:
					deleteCoolText();
					ngSpr.visible = false;
				// credTextShit.visible = false;
					// credTextShit.text = 'Shoutouts Tom Fulp';
				// credTextShit.screenCenter();
				//createCoolText(['MoldyGH', 'Rapparep', 'Krisspo', 'TheBuilderXD']);
				// credTextShit.visible = true;
				case 8:
					createCoolText(['VS Dave & Bambi by'], -60);
				case 9:
					addMoreText('MoldyGH, MissingTextureMan101', -60);
				case 10:
					addMoreText('rapparep lol, TheBuilderXD', -60);
				case 11:
					addMoreText('T5mpler, Erizur, Billy Bobbo', -60);
				case 12:
					addMoreText('Cuszie, Marcello_TIMEnice30', -60);
				case 13:
					deleteCoolText();
				case 14:
					createCoolText(['VS D&B Definitive Edition', "And Bambi's Purgatory", 'by']);
				case 15:
					addMoreText('WhatsDown, ztgds, MijaeLio, Voidsslime\nEpicRandomness11, Pyramix, Shredboi, Aadsta,\nReginald Reborn, BombasticHype, BezieAnims');
				case 16:
					deleteCoolText();
				case 17:
					createCoolText(['And Special thanks to our contributors']);
				case 18:
					addMoreText('NewReal, Cynda, Grantare, Lancey, rapparep lol\nBilly Bobbo, TheBuilder, and More!');
				case 19:
					deleteCoolText();
				case 20:
					addMoreText('Supernovae by ArchWk');
				case 21:
					addMoreText('Glitch by DeadShadow PixelGH');
				case 22:
					deleteCoolText();
				case 23:
					createCoolText([curWacky[0]]);
				case 24:
					addMoreText(curWacky[1]);
				case 25:
					deleteCoolText();
				case 26:
					addMoreText('VS Dave');
				case 27:
					addMoreText('& Bambi');
				case 28:
					addMoreText('Definitive Edition\n+ Bambis Purgatory'); 
				case 29:
					skipIntro();
			}
		}
	}

	var skippedIntro:Bool = false;
	var increaseVolume:Bool = false;

	function skipIntro2():Void
	{
	    if (!skippedIntro)
		{
			doTheFunny = true;

			gradientBar = FlxGradient.createGradientFlxSprite(Math.round(FlxG.width), 512, [0x00, 0x553D0468, 0xAA0F5FFF], 1, 90, true);
	    	gradientBar.y = FlxG.height - gradientBar.height;
	     	gradientBar.scale.y = 0;
	    	gradientBar.updateHitbox();
	    	add(gradientBar);
	     	FlxTween.tween(gradientBar, {'scale.y': 1.3}, 4, {ease: FlxEase.quadInOut});

			add(arrowshit);

			titleText = new FlxSprite(100, FlxG.height * 0.8);
			titleText.frames = Paths.getSparrowAtlas('titleEnter');
			titleText.animation.addByPrefix('idle', "Press Enter to Begin", 24);
			if(ClientPrefs.flashing) { titleText.animation.addByPrefix('press', "ENTER PRESSED", 24); }
			titleText.antialiasing = ClientPrefs.globalAntialiasing;
			titleText.animation.play('idle');
			titleText.updateHitbox();
		    // titleText.screenCenter(X);
			add(titleText);

			FlxTween.tween(logoBl,{x: 15}, 1.4, {ease: FlxEase.expoInOut});

			logoBl.angle = -7;
			if(logoBl.angle == -7) 
			FlxTween.angle(logoBl, logoBl.angle, 7, 7, {ease: FlxEase.quartInOut});
			if (logoBl.angle == 7) 
			FlxTween.angle(logoBl, logoBl.angle, -7, 7, {ease: FlxEase.quartInOut});

			if(ClientPrefs.flashing) {FlxG.camera.flash(FlxColor.WHITE, 4); }
			remove(credGroup);
			skippedIntro = true;
		}
	}
	
	function skipIntro():Void
	{
		if (!skippedIntro)
		{
			FlxTween.tween(logoBl, {y: titleJSON.endY}, 1.4, {ease: FlxEase.expoInOut});

			logoBl.angle = -4;

			new FlxTimer().start(0.01, function(tmr:FlxTimer)
			{
				if (logoBl.angle == -4)
					FlxTween.angle(logoBl, logoBl.angle, 4, 4, {ease: FlxEase.quartInOut});
				if (logoBl.angle == 4)
					FlxTween.angle(logoBl, logoBl.angle, -4, 4, {ease: FlxEase.quartInOut});
			}, 0);

			remove(ngSpr);
			remove(credGroup);
			FlxG.camera.flash(FlxColor.WHITE, 4);
			skippedIntro = true;
		}
	}
}
