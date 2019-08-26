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
	Grid as PathGrid[64,64]
	
	for x=1 to Grid.length-1
		for y=1 to Grid[0].length-1
			Wall=0 // -1 is a wall
			PathSetCell(Grid,x,y,0,0,0,Wall)
		next y
	next x
	
	Enemy as Character[50]
	EnemyInit(Enemy)

	Player as Player
	PlayerInit(Player)
	
	global DebugOID
	DebugOID=CreateObjectSphere(0.2,12,18)
	
	do
		Print( ScreenFPS() )
		
		PlayerControll(Player,10) // player speed set in PlayerInit (Velocity)
		EnemyControll(Enemy, Player, Grid, 1)

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
	for x=0 to Grid.length
		for y=0 to Grid[0].length
			Grid[x,y].Position.x=0
			Grid[x,y].Position.y=0
			Grid[x,y].Number=0
			if Grid[x,y].Visited>0 then Grid[x,y].Visited=0
		next y
	next x
endfunction

function PathFinding(Grid ref as PathGrid[][], Start as int2)
	if Start.x>0 and Start.x<Grid.length and Start.y>0 and Start.y<Grid[0].length
		local FrontierTemp as int2
		local Frontier as int2[]
		local Neighbors as int2[7]

		Neighbors[0].x=1
		Neighbors[0].y=0
		
		Neighbors[1].x=0
		Neighbors[1].y=1

		Neighbors[2].x=-1
		Neighbors[2].y=0
		
		Neighbors[3].x=0
		Neighbors[3].y=-1
		
		Neighbors[4].x=1
		Neighbors[4].y=1
		
		Neighbors[5].x=1
		Neighbors[5].y=-1

		Neighbors[6].x=-1
		Neighbors[6].y=1
		
		Neighbors[7].x=-1
		Neighbors[7].y=-1

		StartX=Start.x
		StartY=Start.y

		FrontierTemp.x=StartX
		FrontierTemp.y=StartY
		Frontier.insert(FrontierTemp)
		
		Grid[StartX,StartY].Position.x=StartX
		Grid[StartX,StartY].Position.y=StartY
		Grid[StartX,StartY].Number=0
		Grid[StartX,StartY].Visited=1

		while Frontier.length>=0
			x=Frontier[0].x
			y=Frontier[0].y
			Frontier.remove(0)

			if x>0 and x<Grid.length and y>0 and y<Grid[0].length
				//~ if Mod((x+y),2)=1
					//~ if Grid[x+1,y].Visited=0
						//~ FrontierTemp.x=x+1
						//~ FrontierTemp.y=y
						//~ Frontier.insert(FrontierTemp)
						//~ Grid[x+1,y].Position.x=x
						//~ Grid[x+1,y].Position.y=y
						//~ Grid[x+1,y].Visited=1
						//~ Grid[x+1,y].Number=Grid[x,y].Number+1
					//~ endif
					//~ if Grid[x,y+1].Visited=0
						//~ FrontierTemp.x=x
						//~ FrontierTemp.y=y+1
						//~ Frontier.insert(FrontierTemp)
						//~ Grid[x,y+1].Position.x=x
						//~ Grid[x,y+1].Position.y=y
						//~ Grid[x,y+1].Visited=1
						//~ Grid[x,y+1].Number=Grid[x,y].Number+1
					//~ endif
					//~ if Grid[x-1,y].Visited=0
						//~ FrontierTemp.x=x-1
						//~ FrontierTemp.y=y
						//~ Frontier.insert(FrontierTemp)
						//~ Grid[x-1,y].Position.x=x
						//~ Grid[x-1,y].Position.y=y
						//~ Grid[x-1,y].Visited=1
						//~ Grid[x-1,y].Number=Grid[x,y].Number+1
					//~ endif
					//~ if Grid[x,y-1].Visited=0
						//~ FrontierTemp.x=x
						//~ FrontierTemp.y=y-1
						//~ Frontier.insert(FrontierTemp)
						//~ Grid[x,y-1].Position.x=x
						//~ Grid[x,y-1].Position.y=y
						//~ Grid[x,y-1].Visited=1
						//~ Grid[x,y-1].Number=Grid[x,y].Number+1
					//~ endif
				//~ else
					//~ if Grid[x,y-1].Visited=0
						//~ FrontierTemp.x=x
						//~ FrontierTemp.y=y-1
						//~ Frontier.insert(FrontierTemp)
						//~ Grid[x,y-1].Position.x=x
						//~ Grid[x,y-1].Position.y=y
						//~ Grid[x,y-1].Visited=1
						//~ Grid[x,y-1].Number=Grid[x,y].Number+1
					//~ endif
					//~ if Grid[x-1,y].Visited=0
						//~ FrontierTemp.x=x-1
						//~ FrontierTemp.y=y
						//~ Frontier.insert(FrontierTemp)
						//~ Grid[x-1,y].Position.x=x
						//~ Grid[x-1,y].Position.y=y
						//~ Grid[x-1,y].Visited=1
						//~ Grid[x-1,y].Number=Grid[x,y].Number+1
					//~ endif
					//~ if Grid[x,y+1].Visited=0
						//~ FrontierTemp.x=x
						//~ FrontierTemp.y=y+1
						//~ Frontier.insert(FrontierTemp)
						//~ Grid[x,y+1].Position.x=x
						//~ Grid[x,y+1].Position.y=y
						//~ Grid[x,y+1].Visited=1
						//~ Grid[x,y+1].Number=Grid[x,y].Number+1
					//~ endif
					//~ if Grid[x+1,y].Visited=0
						//~ FrontierTemp.x=x+1
						//~ FrontierTemp.y=y
						//~ Frontier.insert(FrontierTemp)
						//~ Grid[x+1,y].Position.x=x
						//~ Grid[x+1,y].Position.y=y
						//~ Grid[x+1,y].Visited=1
						//~ Grid[x+1,y].Number=Grid[x,y].Number+1
					//~ endif
				//~ endif
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
	endif
endfunction

function PlayerInit(Player ref as Player)
	Player.Character.OID=CreateObjectBox(1,1,1)
	Player.Character.MaxSpeed = 8.0
	SetCameraPosition(1,0,10,-10)
	SetCameraLookAt(1,GetobjectX(Player.Character.OID),GetobjectY(Player.Character.OID),GetobjectZ(Player.Character.OID),0)
endfunction

function PlayerControll(Player ref as Player,CameraDistance#) // player speed is in the Player character type
	FrameTime#=GetFrameTime()
	CameraAngleY#=GetCameraAngleY(1)
	CameraX#=GetCameraX(1)
	CameraY#=GetCameraY(1)
	CameraZ#=GetCameraZ(1)
	PointerX#=GetPointerX()
	PointerY#=GetPointerY()
	
	Sin0#=sin(CameraAngleY#)
	Sin90#=sin(CameraAngleY#+90.0)
	Cos0#=cos(CameraAngleY#)
	
    if GetRawKeyState(KEY_W)
		MoveZ1#=Player.Character.MaxSpeed*Sin90#
		MoveX1#=Player.Character.MaxSpeed*Sin0#
    endif
    if GetRawKeyState(KEY_S)
		MoveZ1#=-Player.Character.MaxSpeed*Sin90#
		MoveX1#=-Player.Character.MaxSpeed*Sin0#
    endif
    if GetRawKeyState(KEY_A)
		MoveZ2#=Player.Character.MaxSpeed*Sin0#
		MoveX2#=-Player.Character.MaxSpeed*Sin90#
    endif
    if GetRawKeyState(KEY_D)
		MoveZ2#=-Player.Character.MaxSpeed*Sin0#
		MoveX2#=Player.Character.MaxSpeed*Sin90#
    endif
    
    MoveY#=0
	Player.Character.Velocity.x=curvevalue((MoveX1#+MoveX2#)*FrameTime#,Player.Character.Velocity.x,3.0)
	Player.Character.Velocity.y=curvevalue((MoveY#)*FrameTime#,Player.Character.Velocity.y,0.2)
	Player.Character.Velocity.z=curvevalue((MoveZ1#+MoveZ2#)*FrameTime#,Player.Character.Velocity.z,3.0)

	Player.Character.Position.x=Player.Character.Position.x+Player.Character.Velocity.x
	Player.Character.Position.y=Player.Character.Position.y+Player.Character.Velocity.y
	Player.Character.Position.z=Player.Character.Position.z+Player.Character.Velocity.z
	SetObjectPosition(Player.Character.OID,Player.Character.Position.x,Player.Character.Position.y,Player.Character.Position.z)
	
	//~ SetCameraPosition(1,Player.Position.x+CameraDistance#*Sin0#,Player.Position.y+CameraDistance#,Player.Position.z+CameraDistance#*Cos0#)
	//~ SetCameraLookAt(1,Player.Position.x,Player.Position.y,Player.Position.z,0)
	SetCameraPosition(1,Player.Character.Position.x,Player.Character.Position.y+CameraDistance#,Player.Character.Position.z-CameraDistance#)
	
	// Player to look at mouse position
	Pointer3DX#=Get3DVectorXFromScreen(PointerX#,PointerY#)
    Pointer3DY#=Get3DVectorYFromScreen(PointerX#,PointerY#)
    Pointer3DZ#=Get3DVectorZFromScreen(PointerX#,PointerY#)

    Length#=-CameraY#/Pointer3DY#

    Pointer3DX#=CameraX#+Pointer3DX#*Length#
    Pointer3DY#=Player.Character.Position.y
    Pointer3DZ#=CameraZ#+Pointer3DZ#*Length#

	DistX#=Pointer3DX#-Player.Character.Position.x
	DistZ#=Pointer3DZ#-Player.Character.Position.z
	
	NewAngle#=-atanfull(DistX#,DistZ#)
	Player.Character.Rotation.y=CurveAngle(Player.Character.Rotation.y,NewAngle#,9.0)
	
	SetObjectRotation(Player.Character.OID,Player.Character.Rotation.x,Player.Character.Rotation.y,Player.Character.Rotation.z)
endfunction

function EnemyInit(Enemy ref as Character[])
	for Index=0 to Enemy.length // Test
		Enemy[Index].OID=CreateObjectBox(1,1,1)
		Enemy[Index].Position.x=random(0,20)
		Enemy[Index].Position.z=random(0,20)
		Enemy[Index].MaxSpeed=random(10,50)/10.0
	next Index
endfunction

function EnemyControll(Enemy ref as Character[], Player ref as Player, Grid ref as PathGrid[][], GridSize as integer)
	PlayerGrid as int2
	PlayerGrid.x=round(Player.Character.Position.x/GridSize)
	PlayerGrid.y=round(Player.Character.Position.z/GridSize)

	// TODO: for each Enemy Cast ray to player and only calculate path if there is an obstacle detected else run straight to player
	// only calculate if the player moves to a new cell
	if PlayerGrid.x<>Player.OldGrid.x or PlayerGrid.y<>Player.OldGrid.y
		Player.OldGrid.x=PlayerGrid.x
		Player.OldGrid.y=PlayerGrid.y
		PathClear(Grid)
		PathFinding(Grid, PlayerGrid)
	endif
	
	// Debugging Lines
	for x=1 to Grid.length-1
		for y=1 to Grid[0].length-1
			linestartx#=GetScreenXFrom3D(Grid[x,y].Position.x*GridSize,0,Grid[x,y].Position.y*GridSize)
			linestarty#=GetScreenYFrom3D(Grid[x,y].Position.x*GridSize,0,Grid[x,y].Position.y*GridSize)
			linesendx#=GetScreenXFrom3D(x*GridSize,0,y*GridSize)
			linesendy#=GetScreenYFrom3D(x*GridSize,0,y*GridSize)
			DrawLine(linestartx#,linestarty#,linesendx#,linesendy#,MakeColor(255,255,255),MakeColor(0,0,255))
		next y
	next x
	
	for Index=0 to Enemy.length
		EnemyGridX=round(Enemy[Index].Position.x/GridSize)
		EnemyGridZ=round(Enemy[Index].Position.z/GridSize)

		if EnemyGridX>0 and EnemyGridX<Grid.length and EnemyGridZ>0 and EnemyGridZ<Grid[0].length
			DistX#=(Grid[EnemyGridX,EnemyGridZ].Position.x*GridSize)-Enemy[Index].Position.x
			DistZ#=(Grid[EnemyGridX,EnemyGridZ].Position.y*GridSize)-Enemy[Index].Position.z
			
			NewAngle#=-atanfull(DistX#,DistZ#)
			Enemy[Index].Rotation.y=CurveAngle(Enemy[Index].Rotation.y,NewAngle#,9.0)
			
			EnemyDirX#=sin(Enemy[Index].Rotation.y)*Enemy[Index].MaxSpeed*GetFrameTime()
			EnemyDirZ#=cos(Enemy[Index].Rotation.y)*Enemy[Index].MaxSpeed*GetFrameTime()

			Enemy[Index].Position.x=Enemy[Index].Position.x-EnemyDirX#
			Enemy[Index].Position.z=Enemy[Index].Position.z-EnemyDirZ#
			
			SetObjectPosition(Enemy[Index].OID,Enemy[Index].Position.x,Enemy[Index].Position.y,Enemy[Index].Position.z)
			SetObjectRotation(Enemy[Index].OID,Enemy[Index].Rotation.x,Enemy[Index].Rotation.y,Enemy[Index].Rotation.z)
		endif
	next Index
endfunction

function Pick(X# as float, Y# as float) // returns 3D object ID from screen x/y coordinates.
	Result = -1
	WorldX# = Get3DVectorXFromScreen( X#, Y# ) * 800
    WorldY# = Get3DVectorYFromScreen( X#, Y# ) * 800
    WorldZ# = Get3DVectorZFromScreen( X#, Y# ) * 800
    WorldX# = WorldX# + GetCameraX( 1 )
    WorldY# = WorldY# + GetCameraY( 1 )
    WorldZ# = WorldZ# + GetCameraZ( 1 )
 
 	Result=ObjectRayCast(0,getcamerax(1),getcameray(1),getcameraz(1), Worldx#,Worldy#,Worldz#)
endfunction Result

