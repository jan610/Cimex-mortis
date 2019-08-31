// Project: Cimex mortis 
// Created: 2019-08-25

// show all errors
SetErrorMode(2)

// set window properties
SetWindowTitle( "Cimex mortis" )
`SetWindowSize( 1920, 1080, 1 )
SetWindowSize( 960, 540, 1 )
SetWindowAllowResize( 1 ) // allow the user to resize the window

// set display properties
SetVirtualResolution( 100, 100 ) // doesn't have to match the window
SetOrientationAllowed( 1, 1, 1, 1 ) // allow both portrait and landscape on mobile devices
//~SetSyncRate( 30, 0 ) // 30fps instead of 60 to save battery
SetVsync(1)
SetScissor( 0,0,0,0 ) // use the maximum available screen space, no black borders
UseNewDefaultFonts( 1 ) // since version 2.0.22 we can use nicer default fonts

//~ SetShadowMappingMode(3) // built in shadows (for now at least)

//~ SetAntialiasMode(1)
SetDefaultWrapU(1)
SetDefaultWrapV(1)
SetCameraRange(1,1,38)

#include "includes/constants.agc"
#include "includes/common.agc"
#include "includes/bullets.agc"
#include "includes/enemys.agc"
#include "includes/path.agc"
#include "includes/player.agc"
#include "includes/debug.agc"
#include "includes/particles.agc"
#include "includes/media.agc"
#include "includes/voices.agc"

global Camshake as Camshaker
global isItfullscreen = 0

GameState = -1

do
	Select GameState
		case STATE_GAME_INTRO
			GameState=IntroScreen()
		endcase
		case STATE_MAIN_MENU
			GameState=MainMenu()
		endcase
		//~ case STATE_GAME_MENU
			//~ GameState=GameMenu()
		//~ endcase
		case STATE_GAME
			GameState=Game()
		endcase
	endselect
    Sync()
loop

function MainMenu()
	setClearColor(26,6,13)
	
	logoIID = LoadImage("agk2.png")
	logoSID = createSprite(logoIID)
	setSpriteSize(logoSID,14.0,14.0)
	setSpritePosition (logoSID,GetScreenBoundsRight()-17, GetScreenBoundsBottom()-17)
	SetSpriteColor(logoSID, 255,255,255,190)
	
	PlayTID=CreateText("PLAY")
	SetTextSize(PlayTID,8.0)
	SetTextPosition(PlayTID,50-(GetTextTotalWidth( PlayTID )*0.5),45-(GetTextTotalHeight(PlayTID)*0.6))
	setTextColor(PlayTID, 140,28,28,255)
	
	ExitTID=CreateText("EXIT")
	SetTextSize(ExitTID,8.0)
	SetTextPosition( ExitTID, GetTextX( PlayTID ),45+(GetTextTotalHeight(ExitTID)*0.6))
	setTextColor(ExitTID, 140,28,28,255)
	
	helpStr as string
	helpStr = helpStr + "WASD to move" + chr(10)
	helpStr = helpStr + "LEFT MOUSE to shoot" + chr(10)
	helpStr = helpStr + "RIGHT MOUSE sucks" + chr(10)
	helpStr = helpStr + "F triggers AOE" + chr(10)
	helpStr = helpStr + "SPACE boost" + chr(10)
	helpStr = helpStr + "F11 fullscreen" + chr(10)
	helpTID=CreateText(helpStr)
	SetTextSize(helpTID,3.5)
	setTextColor(helpTID, 140,28,28,255)
	SetTextPosition(helpTID,GetScreenBoundsLeft()+5,95-GetTextTotalHeight(helpTID))
	
	do
		PointerX#=GetPointerX()
		PointerY#=GetPointerY()
		basicInput()
		setTextColor(PlayTID, 140,28,28,255)
		setTextColor(ExitTID, 140,28,28,255)
		if GetTextHitTest(PlayTID,PointerX#,PointerY#)
			setTextColor(PlayTID, 195,78,68,255)
			if GetPointerReleased()
				//~ GameState=STATE_GAME_MENU
				GameState=STATE_GAME
				exit
			endif
		endif
		if GetTextHitTest(ExitTID,PointerX#,PointerY#)
			setTextColor(ExitTID, 195,78,68,255)
			if GetPointerReleased()
				GameState=-1
				end
			endif
		endif
		sync()
	loop
	DeleteImage(logoIID)
	DeleteSprite(logoSID)
	DeleteText(PlayTID)
	DeleteText(ExitTID)
	DeleteText(helpTID)
endfunction GameState

	type MapCells
		OID					as integer
		Position			as vec3
		ConnectingCells		as integer[] // MapCell index to connecting cells
		Complete			as integer
		Unlocked			as integer
	endtype
	
function GameMenu()
	
	SetFogMode(0)
	SetSunActive(0)
	//setClearColor(0,0,0)
	setClearColor(26,6,13)
	SetAmbientColor(146,146,146)
	

/*
	// make some map cell objects
	MapCells as MapCells[6]

	// setup cell connections
	// centre cell (connects with all surrounding cells)
	MapCells[0].ConnectingCells.length = 6
	for index = 1 to 6
		MapCells[0].ConnectingCells[index] = index  
	next index
	for CellIndex = 1 to 6
		MapCells[CellIndex].ConnectingCells.length = 2
		MapCells[CellIndex].ConnectingCells[0] = 0
		MapCells[CellIndex].ConnectingCells[1] = mod(CellIndex-1,6)
		MapCells[CellIndex].ConnectingCells[2] = mod(CellIndex+1,6)
	next CellIndex
		
	MapCells[1].Unlocked = 1
	MapCells[0].Position.x = 50
	MapCells[0].Position.y = 1
	MapCells[0].Position.z = 50	
	MapCells[1].Position.x = 50
	MapCells[1].Position.y = 1
	MapCells[1].Position.z = 60
	MapCells[2].Position.x = 65
	MapCells[2].Position.y = 1
	MapCells[2].Position.z = 55
	MapCells[3].Position.x = 65
	MapCells[3].Position.y = 1
	MapCells[3].Position.z = 45
	MapCells[4].Position.x = 50
	MapCells[4].Position.y = 1
	MapCells[4].Position.z = 40
	MapCells[5].Position.x = 35
	MapCells[5].Position.y = 1
	MapCells[5].Position.z = 45
	MapCells[6].Position.x = 35
	MapCells[6].Position.y = 1
	MapCells[6].Position.z = 55
	
	MapCells.save("worlmapdata.json")
	
	*/
	MapCells as MapCells[]
		
	MapCells.load("worlmapdata.json")
	
	Cell_DiffuseIID = LoadImage("abc_dif2.jpg")
	for index = 0 to 6
		MapCells[index].OID = LoadObject("hexcell.fbx")
		SetObjectImage(MapCells[index].OID,Cell_DiffuseIID,0)
		RotateObjectLocalY(MapCells[index].OID,90)
		SetObjectScalePermanent(MapCells[Index].OID,0.05,0.05,0.05)
		if MapCells[index].Complete = 1
			SetObjectColorEmissive(MapCells[Index].OID,55,55,55) // make object look dark if stage is complete
		endif
		if MapCells[index].Unlocked = 1
			SetObjectColorEmissive(MapCells[Index].OID,50,50,355) // cell blue if it is unlocked
		endif
	next index

	
	// position the map cell objects
	for index = 0 to 6
		SetObjectPosition(MapCells[index].OID,MapCells[index].Position.x,MapCells[index].Position.y,MapCells[index].Position.z)
	next index

	SetCameraPosition(1,50,55,40)
	SetCameraLookAt(1,50,0,50,0)
	
	SelectTID=CreateText("LEVEL SELECT")
	SetTextSize(SelectTID,8.0)
	setTextColor(SelectTID, 140,28,28,255)
	SetTextPosition(SelectTID,0,4)
	ExitTID=CreateText("EXIT")
	SetTextSize(ExitTID,8.0)
	setTextColor(ExitTID, 140,28,28,255)
	SetTextPosition(ExitTID,0,12)
	do
		PointerX#=GetPointerX()
		PointerY#=GetPointerY()
		
		basicInput()
		setTextColor(SelectTID, 140,28,28,255)
		setTextColor(ExitTID, 140,28,28,255)
		
		if GetTextHitTest(SelectTID,PointerX#,PointerY#)
			setTextColor(SelectTID, 195,78,68,255)			
			if GetPointerReleased()

				GameState=STATE_GAME
				exit
			endif
		endif
		if GetTextHitTest(ExitTID,PointerX#,PointerY#) or GetRawKeyState(27)
			setTextColor(ExitTID, 195,78,68,255)			
			if GetPointerReleased() or GetRawKeyPressed(27)
				GameState=STATE_MAIN_MENU
				exit
			endif
		endif
		sync()
	loop
	DeleteText(SelectTID)
	DeleteText(ExitTID)
	
	
	for index = 0 to 6
		DeleteObject(MapCells[index].OID)
	next index
	Deleteimage(Cell_DiffuseIID)
endfunction GameState

function Game()
	// This defines the lightning in the level
	SetFogMode(1)
	SetSunActive(1)
	SetFogRange(-9.0,69.0)
	SetSunColor(182,54,51)
	setClearColor(7,11,37)
	setFogColor(0,10,87)
	SetAmbientColor(145,145,145)
	
	LoadGameMedia()
	
	/*
	hudLifeSID = CreateSprite( 0 )
	setSpriteSize (hudLifeSID, 37.0, 2.0)
	setSpriteColor (hudLifeSID, 143, 7, 40,255)
	SetSpritePosition (hudLifeSID, GetScreenBoundsLeft()+4,4)
	setSpriteDepth (hudLifeSID, 7)
	
	hudLifeBgSID = CreateSprite( 0 )
	setSpriteSize (hudLifeBgSID,  37.0, 2.0)
	setSpriteColor (hudLifeBgSID, 80, 14, 36,255)
	SetSpritePosition (hudLifeBgSID, GetScreenBoundsLeft()+4,4)
	setSpriteDepth (hudLifeBgSID, 8)
	*/
	
	
	Width=ScreenWidth()
	Height=ScreenHeight()
	
	local GridSize
	GridSize=1
	
	Player as Player
	PlayerInit(Player,10)
	
	local PlayerGrid as int2
	PlayerGrid.x=round(Player.Character.Position.x/GridSize)
	PlayerGrid.y=round(Player.Character.Position.z/GridSize)
	
	Grid as PathGrid[48,48]
	
	// create some random walls
	ArenaWallOID=LoadObject("wall.3ds")
	ArenaWallOID=LoadObject("walls.3ds")
	//~ SetObjectTransparency(ArenaWallOID,1)
	//~ SetObjectPosition(ArenaWallOID,random2(1,48),-2,random2(1,48))
	SetObjectPosition(ArenaWallOID,24,-2,24)
	RotateObjectLocalY(ArenaWallOID,random2(0,360))
	SetObjectImage(ArenaWallOID, GutDiffuseIID, 0)
	SetObjectUVScale(ArenaWallOID,0,5,5)
	SetObjectNormalMap(ArenaWallOID,GutNormalIID)
	//~ for w = 1 to 15
		//~ wallOID = CloneObject(ArenaWallOID)
		//~ SetObjectPosition(wallOID,random2(1,48),-2,random2(1,48))
		//~ RotateObjectLocalY(wallOID,random2(0,360))
	//~ next w
	
	PathInit(Grid, 0.75, GridSize)
	PathFinding(Grid, PlayerGrid, 0, 0, Grid.length, Grid[0].length)
	
	Enemys as Character[40]
	EnemyInit(Enemys, Grid, GridSize)
	
	Voices as Voice
	
	VoicesInit(Voices,"Voices.json")

	Bullets as Bullet[]
	Blasts as Bullet[]
	
	Particles as Particle[]
	
	Debug as Debuging
	
	ParticleCreate_ambient(Particles,24,0,24,0.4)
	ParticleCreate_ambient(Particles,24,0,24,0.25)
	ParticleCreate_ambient(Particles,24,0,24,0.1)
	
	QuadOID=CreateObjectQuad()
	
	InfoTID=CreateText("")
	SetTextPosition(InfoTID,GetScreenBoundsLeft(),GetScreenBoundsTop())
	
	for runParticlesSeveralTimes = 1 to 200
		ParticleUpdate(Particles)
	next

	CamshakeInit()
	Player.alive = 1
	
	SpinVortex# = 0.0
	
	do
		Time#=Timer()
		basicInput()
		//SetSpriteSize( hudLifeSID, getSpriteWidth(hudLifeBgSID)*Player.Character.Life*0.01, getSpriteHeight(hudLifeBgSID) ) 
		
		setSpritePosition(crosshairSID, GetRawMouseX()-(getSpriteWidth(crosshairSID)*0.5), GetRawMouseY()-(getSpriteHeight(crosshairSID)*0.5))  
		
		if ScreenWidth()<>Width or Height<>ScreenHeight()
			SetTextPosition(InfoTID,GetScreenBoundsLeft(),GetScreenBoundsTop())
		endif
		String$="FPS: "+str(ScreenFPS(),0)+chr(10)+"Energy: "+str(Player.Energy,0)+chr(10)+"Life: "+str(Player.Character.Life,0)
		SetTextString(InfoTID,String$)

		if Player.Character.Life < 0.0
			if Player.alive = 1
				ParticleCreate_playerExplosion(Particles, Player.Character.Position.x, Player.Character.Position.y, Player.Character.position.z)
				changeVisibility (Player, 0)
				eggTimer = Time# + 2.0
				Player.alive = 0
			else
				if Time# > eggTimer
					SetRawMouseVisible( 1 ) 
					//~ GameState=STATE_GAME_MENU
					GameState=STATE_MAIN_MENU
					exit
				endif
			endif
		endif 
		
		if Player.alive = 1 then PlayerControll(Player, Bullets, Blasts, 10) // player speed set in PlayerInit (Velocity)
		EnemyControll(Enemys, Player, Grid, GridSize, Particles)
		
		BulletUpdate(Bullets, Enemys, Particles, Player)
		BulletUpdateBlast(Blasts, Enemys, Particles)
		ParticleUpdate(Particles)
		VoiceDelay#=VoicesUpdate(Voices, VoiceDelay#)
		
		Debuging(Debug, Player)

		if GetRawKeyReleased(27)
			SetRawMouseVisible( 1 ) 
			//~ GameState=STATE_GAME_MENU
			GameState=STATE_MAIN_MENU
			exit
		endif
		
		CamshakeUpdate()
		BuoyancyApply(Player.Character,0.2,150.0)
		
		SetObjectPosition(VortexOID,GetObjectX(Player.Character.OID),GetObjectY(Player.Character.OID),GetObjectZ(Player.Character.OID))
		SetObjectRotation(VortexOID,GetObjectAngleX(Player.Character.OID),GetObjectAngleY(Player.Character.OID),GetObjectAngleZ(Player.Character.OID))
		SpinVortex# = SpinVortex# -0.05
		SetObjectUVOffset(VortexOID,0,SpinVortex#,0)
		SetObjectColor(VortexOID,255,255,255,GetSoundInstanceVolume(SuckSoundInstance)*10)
		
		
		if Debug.ShaderEnabled=0
			Update(0)
			Render2DBack()
			
			SetRenderToImage(SceneIID,-1)
			ClearScreen()
			Render3D()
			
			SetObjectImage(QuadOID,SceneIID,0)
			SetObjectShader(QuadOID,BlurHSID)
			SetRenderToImage(BlurHIID,0)
			ClearScreen()
			DrawObject(QuadOID)
			
			SetObjectImage(QuadOID,BlurHIID,0)
			SetObjectShader(QuadOID,BlurVSID)
			SetRenderToScreen()
			ClearScreen()
			DrawObject(QuadOID)
			
			DebugPath(Debug, Grid, GridSize)
			
			Render2DFront()
			Swap()
		else
			DebugPath(Debug, Grid, GridSize)
			sync()
		endif
	loop
	DeleteGameMedia()
	DeletePlayer(Player)
	DeleteParicles(Particles)
	DeleteAllObjects()
	DeleteAllText()
	DeleteAllImages()
	DeleteAllSprites()
endfunction GameState

function IntroScreen()
	TitleDrone=LoadMusicOGG("sound/title_drone.ogg")
	FadeTween = CreateTweenSprite(1)
	SetTweenSpriteAlpha(FadeTween,0,255,TweenLinear())
	IntroScreenIID = loadimage("intro_screen.jpg")
	IntroScreenSID = CreateSprite(IntroScreenIID)
	Width=ScreenWidth()
	Height=ScreenHeight()
	SetSpriteSize(IntroScreenSID,Width,Height)
	SetSpritePositionByOffset(IntroScreenSID,50,50)
	PlayTweenSprite(FadeTween,IntroScreenSID,0)
	PlayMusicOGG(TitleDrone)
	repeat
		basicInput()
		UpdateTweenSprite(FadeTween,IntroScreenSID,GetFrameTime())
		if ScreenWidth()<>Width or Height<>ScreenHeight()
			SetSpriteSize(IntroScreenSID,ScreenWidth(),ScreenHeight())
		endif
		sync()
	until GetRawLastKey() or GetPointerPressed()
	
	DeleteTween(FadeTween)
	FadeTween = CreateTweenSprite(1)
	SetTweenSpriteAlpha(FadeTween,GetSpriteColorAlpha(IntroScreenSID),0,TweenLinear())
	PlayTweenSprite(FadeTween,IntroScreenSID,0)
	while GetTweenSpritePlaying(FadeTween,IntroScreenSID)
		basicInput()
		UpdateTweenSprite(FadeTween,IntroScreenSID,GetFrameTime())
		SetMusicVolumeOGG(TitleDrone,GetSpriteColorAlpha(IntroScreenSID)*0.39)
		sync()
	endwhile

	StopMusicOGG(TitleDrone)
	DeleteMusicOGG(TitleDrone)

	DeleteSprite(IntroScreenSID)
	DeleteImage(IntroScreenIID)
	
endfunction STATE_MAIN_MENU


function basicInput()
	// Use Alt+F4 to end
	if GetRawKeyState(18) = 1
		if GetRawKeyPressed(115) = 1
			end
		endif
	endif
	// F11 to toggle fullscreen
	if GetRawKeyPressed (122) = 1
		isItfullscreen = 1-isItfullscreen
		SetWindowSize( 960, 540, isItfullscreen )
	endif
endfunction  


function changeVisibility (Player ref as Player, mode as integer)
	setObjectVisible(Player.Character.OID, mode)
	for Index=1 to GetObjectNumChildren(Player.Character.OID)
		setObjectVisible(GetObjectChildID(Player.Character.OID,Index), mode)
	next
	
endfunction
