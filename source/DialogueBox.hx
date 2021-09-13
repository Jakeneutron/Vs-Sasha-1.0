package;

import flixel.system.FlxSound;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.text.FlxTypeText;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxSpriteGroup;
import flixel.input.FlxKeyManager;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;

using StringTools;

class DialogueBox extends FlxSpriteGroup
{
	public static var box:FlxSprite;

	var curCharacter:String = '';
	var curExpression:String = '';
	var curLine:String = '';

	var dialogue:Alphabet;
	var dialogueList:Array<String> = [];

	public var line:FlxSound = FlxG.sound.load(Paths.sound('voicelines/1_scene1'));
	var isTalking:Bool = false;

	// SECOND DIALOGUE FOR THE PIXEL SHIT INSTEAD???
	var swagDialogue:FlxTypeText;

	var dropText:FlxText;

	public var finishThing:Void->Void;

	//Declare Portrait Sprites
	public static var portraitLeft:FlxSprite;
	public static var portraitRight:FlxSprite;
	public static var portraitLeft2:FlxSprite;
	public static var portraitRight2:FlxSprite;

	//var portalSasha:FlxSprite;

	//default x pos of portraits
	var PortraitLeftDefPos:Float;
	var PortraitRightDefPos:Float;
	var port:String = "";

	var handSelect:FlxSprite;
	public static var bgFade:FlxSprite;

	public static var inMiniCutscene:Bool = false;

	public function new(talkingRight:Bool = true, ?dialogueList:Array<String>)
	{
		super();
		//Cutscene Music
		switch (PlayState.SONG.song.toLowerCase())
		{
			case 'senpai':
				FlxG.sound.playMusic(Paths.music('Lunchbox'), 0);
				FlxG.sound.music.fadeIn(1, 0, 0.8);
			case 'thorns':
				FlxG.sound.playMusic(Paths.music('LunchboxScary'), 0);
				FlxG.sound.music.fadeIn(1, 0, 0.8);
			// Vs Sasha Scenes
			case 'heartstomper':
				FlxG.sound.playMusic(Paths.music('cutBobeepo'), 0);
				FlxG.sound.music.fadeIn(1, 0, 0.2);
			case 'barrels hammer':
				FlxG.sound.playMusic(Paths.music('Calamity'), 0);
				FlxG.sound.music.fadeIn(1, 0, 0.2);
			
		}

		bgFade = new FlxSprite(-200, -200).makeGraphic(Std.int(FlxG.width * 1.3), Std.int(FlxG.height * 1.3), 0xffd8b3df);
		bgFade.scrollFactor.set();
		bgFade.alpha = 0;
		add(bgFade);

		new FlxTimer().start(0.83, function(tmr:FlxTimer)
		{
			bgFade.alpha += (1 / 5) * 0.7;
			if (bgFade.alpha > 0.7)
				bgFade.alpha = 0.7;
		}, 5);

		box = new FlxSprite(-20, 45);
		
		var hasDialog = false;

		//Cutscene Stuff?
		switch (PlayState.SONG.song.toLowerCase())
		{
			case 'senpai':
				hasDialog = true;
				box.frames = Paths.getSparrowAtlas('weeb/pixelUI/dialogueBox-pixel');
				box.animation.addByPrefix('normalOpen', 'Text Box Appear', 24, false);
				box.animation.addByIndices('normal', 'Text Box Appear', [4], "", 24);
			case 'roses':
				hasDialog = true;
				FlxG.sound.play(Paths.sound('ANGRY_TEXT_BOX'));

				box.frames = Paths.getSparrowAtlas('weeb/pixelUI/dialogueBox-senpaiMad');
				box.animation.addByPrefix('normalOpen', 'SENPAI ANGRY IMPACT SPEECH', 24, false);
				box.animation.addByIndices('normal', 'SENPAI ANGRY IMPACT SPEECH', [4], "", 24);

			case 'thorns':
				hasDialog = true;
				box.frames = Paths.getSparrowAtlas('weeb/pixelUI/dialogueBox-evil');
				box.animation.addByPrefix('normalOpen', 'Spirit Textbox spawn', 24, false);
				box.animation.addByIndices('normal', 'Spirit Textbox spawn', [11], "", 24);

				var face:FlxSprite = new FlxSprite(320, 170).loadGraphic(Paths.image('weeb/spiritFaceForward'));
				face.setGraphicSize(Std.int(face.width * 6));
				add(face);

			case 'heartstomper':
				hasDialog = true;
				box.frames = Paths.getSparrowAtlas('speech_bubble_talking', 'shared');
				box.animation.addByPrefix('normalOpen', 'Speech Bubble Normal', 24, false);
				box.animation.addByIndices('normal', 'speech bubble normal', [4], "", 24);
				box.width = 200;
				box.height = 200;
				box.x = -100;
				box.y = 375;

			case 'barrels hammer':
				hasDialog = true;
				box.frames = Paths.getSparrowAtlas('speech_bubble_talking', 'shared');
				box.animation.addByPrefix('normalOpen', 'Speech Bubble Normal', 24, false);
				box.animation.addByIndices('normal', 'speech bubble normal', [4], "", 24);
				box.width = 200;
				box.height = 200;
				box.x = -100;
				box.y = 375;
				
		}

		this.dialogueList = dialogueList;
		
		

		if (!hasDialog)
			return;
		

		if (PlayState.SONG.song.toLowerCase()== 'senpai' || PlayState.SONG.song.toLowerCase()== 'roses' || PlayState.SONG.song.toLowerCase()== 'thorns') 
		{
		//Portrait Left
			portraitLeft = new FlxSprite(-20, 40);
			portraitLeft.frames = Paths.getSparrowAtlas('weeb/senpaiPortrait');
			portraitLeft.animation.addByPrefix('enter', 'Senpai Portrait Enter', 24, false);
			portraitLeft.setGraphicSize(Std.int(portraitLeft.width * PlayState.daPixelZoom * 0.9));
			portraitLeft.updateHitbox();
			portraitLeft.scrollFactor.set();
			add(portraitLeft);
			portraitLeft.visible = false;
		} 
		
		else if (PlayState.SONG.song.toLowerCase()== 'heartstomper' || PlayState.SONG.song.toLowerCase()== 'barrels hammer')

		{
			//Portrait Left is sasha
			portraitLeft = new FlxSprite(-1500, 10);
			//box.flipX = false;
			portraitLeft.frames = Paths.getSparrowAtlas('Portraits/sashaPortraits');
			portraitLeft.animation.addByPrefix('enter', 'Sasha_Portraits0000', 24, false);
			portraitLeft.animation.addByPrefix('determined', 'Sasha_Portraits0001', 24, false);
			portraitLeft.animation.addByPrefix('forward determined', 'Sasha_Portraits0002', 24, false);
			portraitLeft.animation.addByPrefix('rock up', 'Sasha_Portraits0003', 24, false);
			portraitLeft.animation.addByPrefix('tongue out', 'Sasha_Portraits0004', 24, false);
			portraitLeft.animation.addByPrefix('snicker', 'Sasha_Portraits0005', 24, false);
			portraitLeft.animation.addByPrefix('pleading', 'Sasha_Portraits0006', 24, false);
			portraitLeft.animation.addByPrefix('laughing', 'Sasha_Portraits0007', 24, false);
			portraitLeft.animation.addByPrefix('shock', 'Sasha_Portraits0008', 24, false);
			portraitLeft.animation.addByPrefix('annoy1', 'Sasha_Portraits0009', 24, false);
			portraitLeft.animation.addByPrefix('annoy2', 'Sasha_Portraits0010', 24, false);
			portraitLeft.setGraphicSize(Std.int(portraitLeft.width * PlayState.daPixelZoom * 0.15));
			portraitLeft.updateHitbox();
			portraitLeft.scrollFactor.set();
			add(portraitLeft);
			portraitLeft.visible = false;
		}

		//Portrait Left is Grime
		portraitLeft2 = new FlxSprite(-1500, 10);
		//box.flipX = false;
		portraitLeft2.frames = Paths.getSparrowAtlas('Portraits/Grime_Portraits');
		portraitLeft2.animation.addByPrefix('enter', 'Grime_Portraits instance 10000', 24, false);
		portraitLeft2.setGraphicSize(Std.int(portraitLeft2.width * PlayState.daPixelZoom * 0.15));
		portraitLeft2.updateHitbox();
		portraitLeft2.scrollFactor.set();
		add(portraitLeft2);
		portraitLeft2.visible = false;

		//Portrait Right
					portraitRight = new FlxSprite(-400, 10);
					portraitRight.flipX = true;
					box.flipX = true;
					portraitRight.frames = Paths.getSparrowAtlas('Portraits/BfPortraits');
					portraitRight.animation.addByPrefix('enter', 'Bf_Portraits instance 10000', 24, false);
					portraitRight.animation.addByPrefix('sus', 'Bf_Portraits instance 10001', 24, false);
					portraitRight.animation.addByPrefix('upset', 'Bf_Portraits instance 10002', 24, false);
					portraitRight.animation.addByPrefix('a joke', 'Bf_Portraits instance 10003', 24, false);
					portraitRight.animation.addByPrefix('yelling', 'Bf_Portraits instance 10004', 24, false);
					portraitRight.animation.addByPrefix('yeah', 'Bf_Portraits instance 10005', 24, false);
					portraitRight.animation.addByPrefix('miss', 'Bf_Portraits instance 10006', 24, false);
					portraitRight.animation.addByPrefix('lets go', 'Bf_Portraits instance 10007', 24, false);
					portraitRight.animation.addByPrefix('what', 'Bf_Portraits instance 10008', 24, false);
					portraitRight.animation.addByPrefix('t', 'Bf_Portraits instance 10009', 24, false);
					portraitRight.animation.addByPrefix('miss 2', 'Bf_Portraits instance 10010', 24, false);
					portraitRight.animation.addByPrefix('sweating', 'Bf_Portraits instance 10011', 24, false);
					portraitRight.animation.addByPrefix('very angry', 'Bf_Portraits instance 10012', 24, false);
					portraitRight.setGraphicSize(Std.int(portraitRight.width * PlayState.daPixelZoom * 0.15));
					portraitRight.updateHitbox();
					portraitRight.scrollFactor.set();
					add(portraitRight);
					portraitRight.visible = false;

				// PortraitRight GF
					portraitRight2 = new FlxSprite(-400, 10);
					portraitRight2.flipX = true;
					//box.flipX = true;
					portraitRight2.frames = Paths.getSparrowAtlas('Portraits/GfPortraits');
					portraitRight2.animation.addByPrefix('enter', 'Gf_Portraits instance 10000', 24, false);
					portraitRight2.animation.addByPrefix('neutral', 'Gf_Portraits instance 10001', 24, false);
					portraitRight2.animation.addByPrefix('sus', 'Gf_Portraits instance 10002', 24, false);
					portraitRight2.animation.addByPrefix('blegh', 'Gf_Portraits instance 10003', 24, false);
					portraitRight2.animation.addByPrefix('ugh', 'Gf_Portraits instance 10004', 24, false);
					portraitRight2.animation.addByPrefix('crying', 'Gf_Portraits instance 10005', 24, false);
					portraitRight2.animation.addByPrefix('cheer', 'Gf_Portraits instance 10006', 24, false);
					portraitRight2.animation.addByPrefix('point1', 'Gf_Portraits instance 10007', 24, false);
					portraitRight2.animation.addByPrefix('pointdown', 'Gf_Portraits instance 10008', 24, false);
					portraitRight2.animation.addByPrefix('pointup', 'Gf_Portraits instance 10009', 24, false);
					portraitRight2.animation.addByPrefix('point2', 'Gf_Portraits instance 10010', 24, false);
					portraitRight2.animation.addByPrefix('scared', 'Gf_Portraits instance 10011', 24, false);
					portraitRight2.animation.addByPrefix('duck', 'Gf_Portraits instance 10012', 24, false);
					portraitRight2.setGraphicSize(Std.int(portraitRight2.width * PlayState.daPixelZoom * 0.15));
					portraitRight2.updateHitbox();
					portraitRight2.scrollFactor.set();
					add(portraitRight2);
					portraitRight2.visible = false;

					
		



		box.animation.play('normalOpen');
		box.setGraphicSize(Std.int(box.width * PlayState.daPixelZoom * 0.9));
		box.updateHitbox();
		add(box);

		box.screenCenter(X);
		portraitLeft.screenCenter(X);

		handSelect = new FlxSprite(FlxG.width * 0.9, FlxG.height * 0.9).loadGraphic(Paths.image('weeb/pixelUI/hand_textbox'));
		add(handSelect);


		if (!talkingRight)
		{
			// box.flipX = true;
		}

		dropText = new FlxText(242, 502, Std.int(FlxG.width * 0.6), "", 32);
		dropText.font = 'Pixel Arial 11 Bold';
		dropText.color = 0xFFD89494;
		add(dropText);

		swagDialogue = new FlxTypeText(240, 500, Std.int(FlxG.width * 0.6), "", 32);
		swagDialogue.font = 'Pixel Arial 11 Bold';
		swagDialogue.color = 0xFF3F2021;
		swagDialogue.sounds = [FlxG.sound.load(Paths.sound('pixelText'), 0.3)];
		add(swagDialogue);

		dialogue = new Alphabet(0, 80, "", false, true);
		// dialogue.x = 90;
		// add(dialogue);
	}

	var dialogueOpened:Bool = false;
	var dialogueStarted:Bool = false;

	override function update(elapsed:Float)
	{
		// HARD CODING CUZ IM STUPDI
		if (PlayState.SONG.song.toLowerCase() == 'roses')
			portraitLeft.visible = false;
		if (PlayState.SONG.song.toLowerCase() == 'thorns')
		{
			portraitLeft.color = FlxColor.BLACK;
			swagDialogue.color = FlxColor.WHITE;
			dropText.color = FlxColor.BLACK;
		}

		dropText.text = swagDialogue.text;

		if (box.animation.curAnim != null)
		{
			if (box.animation.curAnim.name == 'normalOpen' && box.animation.curAnim.finished)
			{
				box.animation.play('normal');
				dialogueOpened = true;
			}
		}

		if (dialogueOpened && !dialogueStarted)
		{
			startDialogue();
			dialogueStarted = true;
		}


		// Check if a cutscene is playing
		if (!inMiniCutscene)
			{

				// if not in cutscene react to buttons

				if (FlxG.keys.justPressed.ANY  && dialogueStarted == true)
					{
						remove(dialogue);
							
						FlxG.sound.play(Paths.sound('clickText'), 0.8);
			
						if (dialogueList[1] == null && dialogueList[0] != null)
						{
							if (!isEnding)
							{
								isEnding = true;
			
								if (PlayState.SONG.song.toLowerCase() == 'senpai' || PlayState.SONG.song.toLowerCase() == 'thorns' || PlayState.SONG.song.toLowerCase() == 'heartstomper' || PlayState.SONG.song.toLowerCase() == 'barrels hammer')
									FlxG.sound.music.fadeOut(2.2, 0);
			
								new FlxTimer().start(0.2, function(tmr:FlxTimer)
								{
									box.alpha -= 1 / 5;
									bgFade.alpha -= 1 / 5 * 0.7;
									portraitLeft.visible = false;
									portraitRight.visible = false;
									swagDialogue.alpha -= 1 / 5;
									dropText.alpha = swagDialogue.alpha;
								}, 5);
			
								new FlxTimer().start(1.2, function(tmr:FlxTimer)
								{
									finishThing();
									kill();
								});
							}
						}
						else
						{
							dialogueList.remove(dialogueList[0]);
							startDialogue();
						}
					}
			}

		
		
		super.update(elapsed);
	}

	var isEnding:Bool = false;

	function startDialogue():Void
	{
		cleanDialog();
		// var theDialog:Alphabet = new Alphabet(0, 70, dialogueList[0], false, true);
		// dialogue = theDialog;
		// add(theDialog);

		// swagDialogue.text = ;
		swagDialogue.resetText(dialogueList[0]);
		swagDialogue.start(0.04, true);

		//Activate Portraits
		switch (curCharacter)
		{
			//Amphibia
			case 'sash':
				//Update Expression
				if (curExpression != '')
					{
					portraitLeft.animation.play(curExpression);
					}
				if (port != 'sash')
					{
						portraitLeft.visible = false;
						portraitRight.visible = false;
						portraitRight2.visible = false;
						box.flipX = true;
						if (!portraitLeft.visible)
						{
							//Set initial alpha and x position
							portraitLeft.x = -500;
							portraitLeft.alpha = 0.0;
							port = 'sash';
							portraitLeft.visible = true;

							//Camera Point to Sasha
							PlayState.camFollow.x = 300;
							PlayState.camFollow.y = PlayState.camStageStarty;
							//Slide on Screen
							FlxTween.tween(portraitLeft, { x: 0}, 0.8, { type: FlxTweenType.ONESHOT, ease: FlxEase.quadOut});
							//Fade into View
							FlxTween.tween(portraitLeft, {alpha : 1.0}, 0.8, { type: FlxTweenType.ONESHOT, ease: FlxEase.quadOut});
						}
					}
				
			case 'grime':
				if (port != 'grime')
					{
						portraitRight.visible = false;
						portraitLeft.visible = false;
						portraitLeft2.visible = false;
						box.flipX = true;
						//if (!portraitLeft.visible)
						//{
							//Set initial alpha and x position
							portraitLeft2.x = -500;
							portraitLeft2.alpha = 0.0;
							port = 'grime';
							portraitLeft2.visible = true;
							portraitLeft2.animation.play('enter');
		
							//Slide on Screen
							FlxTween.tween(portraitLeft2, { x: 0}, 0.8, { type: FlxTweenType.ONESHOT, ease: FlxEase.quadOut});
							//Fade into View
							FlxTween.tween(portraitLeft2, {alpha : 1.0}, 0.8, { type: FlxTweenType.ONESHOT, ease: FlxEase.quadOut});
						//}
		
					}
				
            // FNF
			case 'bf':
				//Update Expression
				if (curExpression != '')
					{
					portraitRight.animation.play(curExpression);
					}

				if (port != 'bf')
					{
						portraitLeft.visible = false;
						portraitRight2.visible = false;
						portraitLeft2.visible = false;
						box.flipX = false;
						//if (!portraitRight.visible)
						//{
							//Set initial alpha and x position
							portraitRight.x = 500;
							portraitRight.alpha = 0.0;
							port = 'bf';
							portraitRight.visible = true;

							//Camera Point to BF
							PlayState.camFollow.x = 1100;
							PlayState.camFollow.y = PlayState.camStageStarty + 100;
						
							//Slide on Screen
							FlxTween.tween(portraitRight, { x: 0}, 0.8, { type: FlxTweenType.ONESHOT, ease: FlxEase.quadOut});
							//Fade into View
							FlxTween.tween(portraitRight, {alpha : 1.0}, 0.8, { type: FlxTweenType.ONESHOT, ease: FlxEase.quadOut});
						//}
					}
				
			case 'gf':
				//Update Expression
				if (curExpression != '')
					{
				portraitRight2.animation.play(curExpression);
					}
					
				if (port != 'gf')
					{
						portraitLeft.visible = false;
						portraitRight.visible = false;
						portraitLeft2.visible = false;
						box.flipX = false;
						//if (!portraitRight.visible)
						//{
							//Set initial alpha and x position
							portraitRight2.x = 500;
							portraitRight2.alpha = 0.0;
							port = 'gf';
							portraitRight2.visible = true;

							//Camera Point to GF
							PlayState.camFollow.x = 800;
							PlayState.camFollow.y = PlayState.camStageStarty - 50;
							
							//Slide on Screen
							FlxTween.tween(portraitRight2, { x: 0}, 0.8, { type: FlxTweenType.ONESHOT, ease: FlxEase.quadOut});
							//Fade into View
							FlxTween.tween(portraitRight2, {alpha : 1.0}, 0.8, { type: FlxTweenType.ONESHOT, ease: FlxEase.quadOut});
						//}
					}
			case 'event1' :
		//Return Camera to Stage Normal

			//Returned Position
			PlayState.camFollow.x = PlayState.camStageStartx;
				
			// Returned Zoom
			FlxTween.tween(FlxG.camera, {zoom : PlayState.camStageStartzoom}, 0.4, {type: FlxTweenType.ONESHOT, ease: FlxEase.quadOut});
			
			//Remove dialouge
			inMiniCutscene = true;
			hideDialogue();

			// Enter Sasha
			PlayState.enterSasha();
			FlxG.sound.play(Paths.sound('PortalSound'));
			FlxG.sound.music.fadeOut(0.5, 0);

			//FlxG.sound.playMusic(Paths.music('cutBobeepo'), 0);


			//FlxG.camera.zoom = PlayState.camStageStartzoom;
			//PlayState.dad.alpha = 1.0;
				//FlxG.camera.zoom = PlayState.defaultCamZoom;

				case 'event2' :

				inMiniCutscene = true;
				hideDialogue();	
				PlayState.calamitySasha();
				//PlayState.dad.curCharacter = 'sasha-alt';
		}

		//Line based events
		switch (curLine)
		{
			case '9':
				if (PlayState.SONG.song.toLowerCase() == 'heartstomper')
					{
					//Bring Dialouge back
					showDialogue();
					}


			case '10' :
				if (PlayState.SONG.song.toLowerCase() == 'heartstomper')
					{
						//Play Sasha track
						FlxG.sound.playMusic(Paths.music('Nostalgia'), 0);
						FlxG.sound.music.fadeIn(1, 0, 0.2);
					}
			case '25':
				if (PlayState.SONG.song.toLowerCase() == 'barrels hammer')
					{
					//Bring Dialouge back
					showDialogue();
					}
				

		}


		//Play Voice Line

		/*
			isTalking = line.playing();			
			if (isTalking)
				{
					line.stop();
				}
				*/

			//Heartstomper lines
			if (PlayState.SONG.song.toLowerCase() == 'heartstomper')
				{
					line.stop();
					line = FlxG.sound.load(Paths.sound('voicelines/'+curLine+'_scene1'), 0.7, false);
					line.play();
				}

			//Barrel's Hammer Lines
			if (PlayState.SONG.song.toLowerCase() == 'barrels hammer')
				{
					line.stop();
					line = FlxG.sound.load(Paths.sound('voicelines/'+curLine+'_scene2'), 0.7, false);
					line.play();
				}
			
	}
	
	/*
	function playSashaTheme()
	{
		FlxG.sound.playMusic(Paths.music('Nostalgia'), 0);
		FlxG.sound.music.fadeOut(1, 0, 0.7);
	}
	*/

	//check if sasha on screen

	public static function hideDialogue()
		{
			bgFade.alpha = 0;
			box.alpha = 0;
			portraitLeft.alpha = 0;
			portraitRight.alpha = 0;
			portraitLeft2.alpha = 0;
			portraitRight2.alpha = 0;
		}

	public static function showDialogue()
		{
			bgFade.alpha = 0.7;
			box.alpha = 1;
			portraitLeft.alpha = 1;
			portraitRight.alpha = 1;
			portraitLeft2.alpha = 1;
			portraitRight2.alpha = 1;
		}	
	

	function cleanDialog():Void
	{
		var splitName:Array<String> = dialogueList[0].split(":");
		curCharacter = splitName[2];
		curExpression = splitName[1];
		curLine = splitName[0];
		dialogueList[0] = dialogueList[0].substr(splitName[2].length + splitName[1].length + splitName[0].length + 3).trim();
	}
}
