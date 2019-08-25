

function MainMenu()
	PlayTID=CreateText("Play")
	SetTextSize(PlayTID,12)
	ExitTID=CreateText("Exit")
	SetTextSize(ExitTID,12)
	SetTextPosition(ExitTID,0,12)
	do
		PointerX#=GetPointerX()
		PointerY#=GetPointerY()
		if GetTextHitTest(PlayTID,PointerX#,PointerY#)
			if GetPointerReleased()
				GameState=STATE_GAME
				exit
			endif
		endif
		if GetTextHitTest(ExitTID,PointerX#,PointerY#)
			if GetPointerReleased()
				GameState=-1
				end
			endif
		endif
		sync()
	loop
	DeleteText(PlayTID)
	DeleteText(ExitTID)
endfunction GameState

function GameMenu()
	MainTID=CreateText("Main Menu")
	SetTextSize(MainTID,12)
	do
		PointerX#=GetPointerX()
		PointerY#=GetPointerY()
		if GetTextHitTest(MainTID,PointerX#,PointerY#)
			if GetPointerReleased()
				GameState=STATE_MAIN_MENU
				exit
			endif
		endif
		sync()
	loop
	DeleteText(MainTID)
endfunction GameState

function Game()
	// ***************************************************************
	// This is temporary, just to show the usecase
	Grid as PathGrid[64,64]
	
	for x=1 to Grid.length-1
		for y=1 to Grid[0].length-1
			PathSetCell(Grid,x,y,0,0,0,-1) // -1 is a wall
		next y
	next x
	PlayerPositionOnGrid as int3
	PlayerPositionOnGrid.x=32
	PlayerPositionOnGrid.y=32
	PathFinding(Grid, PlayerPositionOnGrid)
	// The enemy only has to folow the Target position of it's Cell
	// ***************************************************************
	
	for i=0 to 10 // Test
		SphereOID=CreateObjectSphere(1,12,18)
		SetObjectPosition(SphereOID,random(0,10)-5,0,random(0,10)-5)
	next i
	
	Player as Character
	PlayerInit(Player)
	
	do
		Print( ScreenFPS() )
		
		PlayerControll(Player,8.0,10)
		
		if GetRawKeyReleased(27)
			GameState=STATE_GAME_MENU
			exit
		endif
		
		Sync()
	loop
endfunction GameState

function CentreTextToSprite(t as integer, s as integer)
	if GetTextAlignment(t) = 0
		SetTextPosition(t,GetSpriteXByOffset(s)-GetTextTotalWidth(t)*0.5,GetSpriteYByOffset(s)-GetTextTotalHeight(t)*0.5)
	elseif GetTextAlignment(t) = 1
		SetTextPosition(t,GetSpriteXByOffset(s),GetSpriteYByOffset(s)-GetTextTotalHeight(t)*0.5)
	else
		SetTextPosition(t,GetSpriteXByOffset(s)+GetTextTotalWidth(t)*0.5,GetSpriteYByOffset(s)-GetTextTotalHeight(t)*0.5)
	endif
endfunction

function IntroScreen()
	FadeTween = CreateTweenSprite(1)
	SetTweenSpriteAlpha(FadeTween,0,255,TweenLinear())
	IntroScreenIID = loadimage("Intro_Screen.png")
	IntroScreenSID = CreateSprite(IntroScreenIID)
	SetSpriteSize(IntroScreenSID,ScreenWidth(),ScreenHeight())
	SetSpritePosition(IntroScreenSID,GetScreenBoundsLeft(),GetScreenBoundsTop())
	PlayTweenSprite(FadeTween,IntroScreenSID,0)
	while GetTweenSpritePlaying(FadeTween,IntroScreenSID)
		UpdateTweenSprite(FadeTween,IntroScreenSID,GetFrameTime())
		sync()
	endwhile
	
	while Not GetRawLastKey() and Not GetPointerPressed()
		Sync()
	endwhile
	
	DeleteTween(FadeTween)
	FadeTween = CreateTweenSprite(1)
	SetTweenSpriteAlpha(FadeTween,255,0,TweenLinear())
	PlayTweenSprite(FadeTween,IntroScreenSID,0)
	while GetTweenSpritePlaying(FadeTween,IntroScreenSID)
		UpdateTweenSprite(FadeTween,IntroScreenSID,GetFrameTime())
		sync()
	endwhile
endfunction 0
	
function ScreenWidth()
	result# = GetScreenBoundsRight() - GetScreenBoundsLeft()
endfunction result#

function ScreenHeight()
	result# = GetScreenBoundsBottom() - GetScreenBoundsTop()
endfunction result#

function CurveAngle(CurrentAngle#,DestinationAngle#,Steps#)
	Diff#=WrapValue(CurrentAngle#-DestinationAngle#)
	if Diff#<180
		Diff#=-Diff#
	else
		Diff#=360-Diff#
	endif
	NewValue#=WrapValue(CurrentAngle#+Diff#/Steps#)
endfunction NewValue#

function WrapValue(angle#)
	if angle#<0
		angle#=angle#+360
	endif
	if angle#>360
		angle#=angle#-360
	endif
endfunction angle#

function CurveValue(Destination#,Current#,Steps#)
	Current#=Current#+((Destination#-Current#)/Steps#)
endfunction Current#

function Distance(x1#,y1#,z1#,x2#,y2#,z2#)
	DistX#=x2#-x1#
	DistY#=y2#-y1#
	DistZ#=z2#-z1#
	Dist#=sqrt(DistX#*DistX#+DistY#*DistY#+DistZ#*DistZ#)
endfunction Dist#

function Clamp(Value#,Min#,Max#)
	if Value#>Max# then Value#=Max#
	if Value#<Min# then Value#=Min#
endfunction Value#

function Wrap(Value#,Min#,Max#)
	if Value#>Max# then Value#=Min#
	if Value#<Min# then Value#=Max#
endfunction Value#

function PathSetCell(Grid ref as PathGrid[][], x as integer, y as integer, TargetX as integer, TargetY as integer, Number as integer, Visited as integer)
	Grid[x,y].Position.x=TargetX
	Grid[x,y].Position.y=TargetY
	Grid[x,y].Number=Number
	Grid[x,y].Visited=Visited
endfunction

function PathClear(Grid ref as PathGrid[][])
	for x=1 to Grid.length-1
		for y=1 to Grid[0].length-1
			Grid[x,y].Position.x=0
			Grid[x,y].Position.y=0
			Grid[x,y].Number=0
			if Grid[x,y].Visited>0 then Grid[x,y].Visited=0
		next y
	next x
endfunction

function PathFinding(Grid ref as PathGrid[][], Start as int3)
	local FrontierTemp as int3
	local Frontier as int3[]
	local Neighbors as int3[3]

	Neighbors[0].x=1
	Neighbors[0].y=0
	
	Neighbors[1].x=0
	Neighbors[1].y=1

	Neighbors[2].x=-1
	Neighbors[2].y=0
	
	Neighbors[3].x=0
	Neighbors[3].y=-1

	StartX=Start.x
	StartY=Start.y

	FrontierTemp.X=StartX
	FrontierTemp.Y=StartY
	Frontier.insert(FrontierTemp)
	
	Grid[StartX,StartY].Position.x=StartX
	Grid[StartX,StartY].Position.y=StartY
	Grid[StartX,StartY].Number=0
	Grid[StartX,StartY].Visited=1

	while Frontier.length>=0
		x=Frontier[0].x
		y=Frontier[0].y
		Frontier.remove(0)

		if x>1 and x<Grid.length-1 and y>1 and y<Grid[0].length-1
			for n=0 to Neighbors.length
				nx=x+Neighbors[n].x
				ny=y+Neighbors[n].y
				if Grid[nx,ny].Visited=0
					FrontierTemp.x=nx
					FrontierTemp.y=ny
					Frontier.insert(FrontierTemp)
					Grid[nx,ny].Position.x=x
					Grid[nx,ny].Position.y=y
					Grid[nx,ny].Visited=1
					Grid[nx,ny].Number=Grid[x,y].Number+1
				endif
			next n
		endif
	endwhile
endfunction

function PlayerInit(Player ref as Character)
	Player.OID=CreateObjectBox(1,1,1)
	SetCameraPosition(1,0,10,-10)
	SetCameraLookAt(1,GetobjectX(Player.OID),GetobjectY(Player.OID),GetobjectZ(Player.OID),0)
endfunction

function PlayerControll(Player ref as Character,PlayerSpeed#,CameraDistance#)
	FrameTime#=GetFrameTime()
	CameraAngleY#=GetCameraAngleY(1)
	CameraX#=GetCameraX(1)
	CameraZ#=GetCameraZ(1)
	
	Sin0#=sin(CameraAngleY#)
	Sin90#=sin(CameraAngleY#+90.0)
	Cos0#=cos(CameraAngleY#)
	
    if GetRawKeyState(KEY_W)
		MoveZ1#=PlayerSpeed#*Sin90#
		MoveX1#=PlayerSpeed#*Sin0#
    endif
    if GetRawKeyState(KEY_S)
		MoveZ1#=-PlayerSpeed#*Sin90#
		MoveX1#=-PlayerSpeed#*Sin0#
    endif
    if GetRawKeyState(KEY_A)
		MoveZ2#=PlayerSpeed#*Sin0#
		MoveX2#=-PlayerSpeed#*Sin90#
    endif
    if GetRawKeyState(KEY_D)
		MoveZ2#=-PlayerSpeed#*Sin0#
		MoveX2#=PlayerSpeed#*Sin90#
    endif
    
    MoveY#=0
	Player.Velocity.x=curvevalue((MoveX1#+MoveX2#)*FrameTime#,Player.Velocity.x,3.0)
	Player.Velocity.y=curvevalue((MoveY#)*FrameTime#,Player.Velocity.y,0.2)
	Player.Velocity.z=curvevalue((MoveZ1#+MoveZ2#)*FrameTime#,Player.Velocity.z,3.0)
	
	Player.Position.x=Player.Position.x+Player.Velocity.x
	Player.Position.y=Player.Position.y+Player.Velocity.y
	Player.Position.z=Player.Position.z+Player.Velocity.z
	SetObjectPosition(Player.OID,Player.Position.x,Player.Position.y,Player.Position.z)
	
	//~ SetCameraPosition(1,Player.Position.x+CameraDistance#*Sin0#,Player.Position.y+CameraDistance#,Player.Position.z+CameraDistance#*Cos0#)
	//~ SetCameraLookAt(1,Player.Position.x,Player.Position.y,Player.Position.z,0)
	SetCameraPosition(1,Player.Position.x,Player.Position.y+CameraDistance#,Player.Position.z-CameraDistance#)
	
	print(GetCameraX(1))
	print(GetCameraY(1))
	print(GetCameraZ(1))
endfunction
