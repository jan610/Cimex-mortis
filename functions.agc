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
				GameState=STATE_GAME_MENU
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
	MainTID=CreateText("Level Select")
	SetTextSize(MainTID,12)
	
	do
		PointerX#=GetPointerX()
		PointerY#=GetPointerY()
		if GetTextHitTest(MainTID,PointerX#,PointerY#)
			if GetPointerReleased()
				GameState=STATE_GAME
				exit
			endif
		endif
		sync()
	loop
	DeleteText(MainTID)
endfunction GameState

function Game()
	local GridSize
	GridSize=1
	
	Player as Player
	PlayerInit(Player,10)
	
	local PlayerGrid as int2
	PlayerGrid.x=round(Player.Character.Position.x/GridSize)
	PlayerGrid.y=round(Player.Character.Position.z/GridSize)
	
	Grid as PathGrid[64,64]
	
	// create some random walls
	for t = 1 to 10
		wall = CreateObjectBox(random2(10,35),5,1.5)
		SetObjectTransparency(wall,1)
		SetObjectPosition(wall,random2(1,50),2.5,random2(1,50))
		RotateObjectLocalY(wall,random2(0,360))
		setobjectcolor(wall,0,255,0,155)
	next t
	
	PathInit(Grid, 1, GridSize, Player.Character.OID)
	PathFinding(Grid, PlayerGrid)
	
	Enemy as Character[50]
	EnemyInit(Enemy, Grid, GridSize)

	Bullets as Bullet[]
	
	// temporary ...help me do this in a nicer way please
	BulletShaderID=LoadShader("shader/Line.vs","shader/Default.ps")
	BulletDiffuseIID=LoadImage("bullet.png")
	
	do
		Print( ScreenFPS() )
		
		PlayerControll(Player,10) // player speed set in PlayerInit (Velocity)
		EnemyControll(Enemy, Player, Grid, GridSize)
		
		if GetPointerPressed()
			BulletCreate(Bullets,Player.Character.Position.x,Player.Character.Position.y,Player.Character.Position.z,Player.Character.Rotation.y, BulletShaderID, BulletDiffuseIID, -1, Player.Attack)
		endif	
		
		BulletUpdate(Bullets)

		if GetRawKeyReleased(27)
			GameState=STATE_GAME_MENU
			exit
		endif
		print (player.state)
		print("Energy:"+str(Player.Energy))
		print("Attack:"+str(Player.Attack))
		print("Life:"+str(Player.Character.Life))
		print("mov-speed:"+str(Player.Character.MaxSpeed))
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
endfunction STATE_MAIN_MENU
	
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

function PathInit(Grid ref as PathGrid[][], ScanSize as float, GridSize as integer, PlayerOID as integer)
	local gridy as float
	gridy=0.5
	for gridx=0 to Grid.length
		for gridz=0 to Grid[0].length
			HitOID=ObjectSphereCast(0,gridx*GridSize,gridy*GridSize,gridz*GridSize,gridx*GridSize,gridy*GridSize,gridz*GridSize,ScanSize)
			if HitOID>0 and HitOID <> PlayerOID
				PathSetCell(Grid,gridx,gridz,0,0,1,-1) // giving grid number a "1" to stop enemies spawning in walls.
`				PathSetCell(Grid,gridx,gridz,0,0,0,0)
`				PathSetCell(Grid,gridx,gridz,0,0,0,random2(0,1)-1)
			endif
		next gridz
	next gridx
endfunction

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
			 if Mod((x+y),2)=1
				 if Grid[x+1,y].Visited=0
					 FrontierTemp.x=x+1
					 FrontierTemp.y=y
					 Frontier.insert(FrontierTemp)
					 Grid[x+1,y].Position.x=x
					 Grid[x+1,y].Position.y=y
					 Grid[x+1,y].Visited=1
					 Grid[x+1,y].Number=Grid[x,y].Number+1
				 endif
				 if Grid[x,y+1].Visited=0
					 FrontierTemp.x=x
					 FrontierTemp.y=y+1
					 Frontier.insert(FrontierTemp)
					 Grid[x,y+1].Position.x=x
					 Grid[x,y+1].Position.y=y
					 Grid[x,y+1].Visited=1
					 Grid[x,y+1].Number=Grid[x,y].Number+1
				 endif
				 if Grid[x-1,y].Visited=0
					 FrontierTemp.x=x-1
					 FrontierTemp.y=y
					 Frontier.insert(FrontierTemp)
					 Grid[x-1,y].Position.x=x
					 Grid[x-1,y].Position.y=y
					 Grid[x-1,y].Visited=1
					 Grid[x-1,y].Number=Grid[x,y].Number+1
				 endif
				 if Grid[x,y-1].Visited=0
					 FrontierTemp.x=x
					 FrontierTemp.y=y-1
					 Frontier.insert(FrontierTemp)
					 Grid[x,y-1].Position.x=x
					 Grid[x,y-1].Position.y=y
					 Grid[x,y-1].Visited=1
					 Grid[x,y-1].Number=Grid[x,y].Number+1
				 endif
			 else
				 if Grid[x,y-1].Visited=0
					 FrontierTemp.x=x
					 FrontierTemp.y=y-1
					 Frontier.insert(FrontierTemp)
					 Grid[x,y-1].Position.x=x
					 Grid[x,y-1].Position.y=y
					 Grid[x,y-1].Visited=1
					 Grid[x,y-1].Number=Grid[x,y].Number+1
				 endif
				 if Grid[x-1,y].Visited=0
					 FrontierTemp.x=x-1
					 FrontierTemp.y=y
					 Frontier.insert(FrontierTemp)
					 Grid[x-1,y].Position.x=x
					 Grid[x-1,y].Position.y=y
					 Grid[x-1,y].Visited=1
					 Grid[x-1,y].Number=Grid[x,y].Number+1
				 endif
				 if Grid[x,y+1].Visited=0
					 FrontierTemp.x=x
					 FrontierTemp.y=y+1
					 Frontier.insert(FrontierTemp)
					 Grid[x,y+1].Position.x=x
					 Grid[x,y+1].Position.y=y
					 Grid[x,y+1].Visited=1
					 Grid[x,y+1].Number=Grid[x,y].Number+1
				 endif
				 if Grid[x+1,y].Visited=0
					 FrontierTemp.x=x+1
					 FrontierTemp.y=y
					 Frontier.insert(FrontierTemp)
					 Grid[x+1,y].Position.x=x
					 Grid[x+1,y].Position.y=y
					 Grid[x+1,y].Visited=1
					 Grid[x+1,y].Number=Grid[x,y].Number+1
				 endif
			 endif
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

function PlayerInit(Player ref as Player, CameraDistance#)
	Player.Character.OID=CreateObjectBox(1,1,1)
	Player.Character.MaxSpeed=8.0
	Player.Character.Position.x=32
	Player.Character.Position.y=0
	Player.Character.Position.z=32
	Player.Attack = 0.9
	SetObjectPosition(Player.Character.OID,Player.Character.Position.x,Player.Character.Position.y,Player.Character.Position.z)
	SetCameraPosition(1,Player.Character.Position.x,Player.Character.Position.y+CameraDistance#,Player.Character.Position.z-CameraDistance#)
	SetCameraLookAt(1,Player.Character.Position.x,Player.Character.Position.y,Player.Character.Position.z,0)
	Player.Boost_TweenID = CreateTweenCustom(0.3)
	SetTweenCustomFloat1(Player.Boost_TweenID,100,0,TweenSmooth2())
endfunction

function PlayerControll(Player ref as Player, CameraDistance#) // player speed is in the Player character type
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
	
	if GetRawKeyPressed(32)
		PlayTweenCustom(Player.Boost_TweenID,0.0)
	endif
	
	if GetRawMouseRightState() 
		player.State=STATE_SUCK
	else
		player.state=0
	endif
	
	if GetTweenCustomPlaying(player.Boost_TweenID)
		print("Boost")
		UpdateTweenCustom(player.Boost_TweenID,GetFrameTime())
	endif
	
	SpeedBoost# = GetTweenCustomFloat1(player.Boost_TweenID)
	
    if GetRawKeyState(KEY_W)
		MoveZ1#=(Player.Character.MaxSpeed+SpeedBoost#)*Sin90#
		MoveX1#=(Player.Character.MaxSpeed+SpeedBoost#)*Sin0#
    endif
    if GetRawKeyState(KEY_S)
		MoveZ1#=-(Player.Character.MaxSpeed+SpeedBoost#)*Sin90#
		MoveX1#=-(Player.Character.MaxSpeed+SpeedBoost#)*Sin0#
    endif
    if GetRawKeyState(KEY_A)
		MoveZ2#=(Player.Character.MaxSpeed+SpeedBoost#)*Sin0#
		MoveX2#=-(Player.Character.MaxSpeed+SpeedBoost#)*Sin90#
    endif
    if GetRawKeyState(KEY_D)
		MoveZ2#=-(Player.Character.MaxSpeed+SpeedBoost#)*Sin0#
		MoveX2#=(Player.Character.MaxSpeed+SpeedBoost#)*Sin90#
    endif
    
	 
    if GetRawKeyState(KEY_SPACE)
		Select player.state
			
			case STATE_FORWARD
				MoveZ1#=(BOOST_AMMOUNT*(Player.Character.MaxSpeed+SpeedBoost#)*Sin90#)
				MoveX1#=(BOOST_AMMOUNT*(Player.Character.MaxSpeed+SpeedBoost#)*Sin0#)
			endcase
			
			case STATE_BACKWARD
				MoveZ1#=-(BOOST_AMMOUNT*(Player.Character.MaxSpeed+SpeedBoost#)*Sin90#)
				MoveX1#=-(BOOST_AMMOUNT*(Player.Character.MaxSpeed+SpeedBoost#)*Sin0#)
			endcase
					
			case STATE_LEFT
				MoveZ2#=(BOOST_AMMOUNT*(Player.Character.MaxSpeed+SpeedBoost#)*Sin0#)
				MoveX2#=-(BOOST_AMMOUNT*(Player.Character.MaxSpeed+SpeedBoost#)*Sin90#)
			endcase
			
			case STATE_RIGHT
				MoveZ2#=-(BOOST_AMMOUNT*(Player.Character.MaxSpeed+SpeedBoost#)*Sin0#)
				MoveX2#=(BOOST_AMMOUNT*(Player.Character.MaxSpeed+SpeedBoost#)*Sin90#)
			endcase
		endselect		
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
	Player.Character.Rotation.y=CurveAngle(Player.Character.Rotation.y,NewAngle#,6.0)
	
	SetObjectRotation(Player.Character.OID,Player.Character.Rotation.x,Player.Character.Rotation.y,Player.Character.Rotation.z)
endfunction

function EnemyInit(Enemy ref as Character[], Grid ref as PathGrid[][], GridSize)
	for Index=0 to Enemy.length // Test
		Enemy[Index].OID=CreateObjectBox(1,1,1)
		repeat 
			SpawnX#=random2(1,63)
			SpawnY#=random2(1,63)
			
			SpawnGridX=round(SpawnX#/GridSize)
			SpawnGridY=round(SpawnY#/GridSize)
			if Grid[SpawnGridX,SpawnGridY].Number<=0 then FoundSpawn=1
		until FoundSpawn
		Enemy[Index].Position.x=SpawnX#
		Enemy[Index].Position.z=SpawnY#
		Enemy[Index].MaxSpeed=random(10,50)/10.0
	next Index
endfunction

function EnemyControll(Enemy ref as Character[], Player ref as Player, Grid ref as PathGrid[][], GridSize as integer)
	FrameTime#=GetFrameTime()
	PlayerGrid as int2
	PlayerGrid.x=round(Player.Character.Position.x/GridSize)
	PlayerGrid.y=round(Player.Character.Position.z/GridSize)

	// TODO: for each Enemy Cast ray to player and only calculate path if there is an obstacle detected else run straight to player
	// only calculate if the player moves to a new cell
	if PlayerGrid.x>0 and PlayerGrid.x<Grid.length and PlayerGrid.y>0 and PlayerGrid.y<Grid[0].length
		if PlayerGrid.x<>Player.OldGrid.x or PlayerGrid.y<>Player.OldGrid.y
			Player.OldGrid.x=PlayerGrid.x
			Player.OldGrid.y=PlayerGrid.y
			PathClear(Grid)
			PathFinding(Grid, PlayerGrid)
		endif
	endif
	
	// Debugging Lines
	for x=0 to Grid.length
		for y=0 to Grid[0].length
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

			EnemyDirX#=sin(Enemy[Index].Rotation.y)*Enemy[Index].MaxSpeed*FrameTime#
			EnemyDirZ#=cos(Enemy[Index].Rotation.y)*Enemy[Index].MaxSpeed*FrameTime#

			EnemyDirVID=CreateVector3(Enemy[Index].Position.x-Player.Character.Position.x,0,Enemy[Index].Position.z-Player.Character.Position.z)
			Length#=GetVector3Length(EnemyDirVID)
			SetVector3(EnemyDirVID,GetVector3X(EnemyDirVID)/Length#,0,GetVector3Z(EnemyDirVID)/Length#)
			LookDirVID=CreateVector3(sin(Player.Character.Rotation.y),0,cos(Player.Character.Rotation.y))
			
			if player.state=STATE_SUCK and GetVector3Dot(LookDirVID,EnemyDirVID)<-0.5 and Length#<=SUCK_DISTANCE
				Enemy[Index].Position.x=Enemy[Index].Position.x-SUCK_POWER*EnemyDirX#
				Enemy[Index].Position.z=Enemy[Index].Position.z-SUCK_POWER*EnemyDirZ#	
			else	
				Enemy[Index].Position.x=Enemy[Index].Position.x-EnemyDirX#
				Enemy[Index].Position.z=Enemy[Index].Position.z-EnemyDirZ#
			endif
			DeleteVector3(EnemyDirVID)
			DeleteVector3(LookDirVID)
			
			OldEnemyX#=GetObjectX(Enemy[Index].OID)
			OldEnemyY#=GetObjectY(Enemy[Index].OID)
			OldEnemyZ#=GetObjectZ(Enemy[Index].OID)
			
			if ObjectSphereSlide(0,OldEnemyX#,OldEnemyY#,OldEnemyZ#,Enemy[Index].Position.x,Enemy[Index].Position.y,Enemy[Index].Position.z,0.3)>0
				Ray=0
				//~ for Ray=0 to GetObjectRayCastNumHits()
					Enemy[Index].Position.x=GetObjectRayCastSlideX(Ray)
					Enemy[Index].Position.z=GetObjectRayCastSlideZ(Ray)
				//~ next Ray
			endif
			
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

function BulletCreate(Bullets ref as Bullet[], X as Float, Y as Float, Z as Float, AngleY as Float, ShaderID as Integer, DiffuseIID as Integer, NormalIID as Integer,Attack as float)
	local MaxSpeed as float
	MaxSpeed = 9
	
	local TempBullet as Bullet
	TempBullet.OID=CreateObjectPlane(1,1)
	SetObjectPosition(TempBullet.OID,X,Y,Z)
	SetObjectRotation(TempBullet.OID,0,AngleY,0)
	SetObjectImage(TempBullet.OID,DiffuseIID,0)
	//~ SetObjectNormalMap(TempBullet.OID,NormalIID)
	SetObjectTransparency(TempBullet.OID,1)
	SetObjectShader(TempBullet.OID,ShaderID)
	SetObjectShaderConstantByName(TempBullet.OID,"thickness",0.2,0,0,0)
	//~ SetObjectLightMode(TempBullet.OID,0)
	//~ SetObjectCullMode(TempBullet.OID,0)
	TempBullet.Position.x=X
	TempBullet.Position.y=Y
	TempBullet.Position.z=Z
	TempBullet.Rotation.y=AngleY
	TempBullet.ShaderID=ShaderID
	TempBullet.DiffuseIID=DiffuseIID
	TempBullet.NormalIID=NormalIID
	TempBullet.Velocity.x=sin(AngleY)*MaxSpeed
	TempBullet.Velocity.z=cos(AngleY)*MaxSpeed
	TempBullet.Velocity_Tween = CreateTweenCustom(Attack)
	SetTweenCustomFloat1(TempBullet.Velocity_Tween,TempBullet.Velocity.x,0,TweenEaseIn2())
	SetTweenCustomFloat2(TempBullet.Velocity_Tween,TempBullet.Velocity.z,0,TweenEaseIn2())
	PlayTweenCustom(TempBullet.Velocity_Tween,0.0)
	TempBullet.Time = Timer()+3
	Bullets.insert(TempBullet)
endfunction

function BulletUpdate(Bullets ref as Bullet[])
	FrameTime#=GetFrameTime()
	local MaxTime as Float
	local BulletLength as float
	BulletLength = 2
	
	print(Bullets.length)
	for Index=0 to Bullets.length
		UpdateTweenCustom(Bullets[Index].Velocity_Tween,FrameTime#)
		VelocityX#=GetTweenCustomFloat1(Bullets[Index].Velocity_Tween)*FrameTime#
		VelocityZ#=GetTweenCustomFloat2(Bullets[Index].Velocity_Tween)*FrameTime#
		Bullets[Index].Position.x=Bullets[Index].Position.x-VelocityX#
		Bullets[Index].Position.z=Bullets[Index].Position.z-VelocityZ#
`		Bullets[Index].Position.x=Bullets[Index].Position.x-GetTweenCustomFloat1(Bullets[Index].Velocity_Tween)
`		Bullets[Index].Position.z=Bullets[Index].Position.z-GetTweenCustomFloat2(Bullets[Index].Velocity_Tween)
		SetObjectPosition(Bullets[Index].OID,Bullets[Index].Position.x,Bullets[Index].Position.y,Bullets[Index].Position.z)
		SetObjectShaderConstantByName(Bullets[Index].OID,"start",Bullets[Index].Position.x,Bullets[Index].Position.y,Bullets[Index].Position.z, 0)
		SetObjectShaderConstantByName(Bullets[Index].OID,"end",Bullets[Index].Position.x+VelocityX#*BulletLength,Bullets[Index].Position.y,Bullets[Index].Position.z+VelocityZ#*BulletLength, 0)
	
`		if Timer()>Bullets[Index].Time
`			DeleteObject(Bullets[Index].OID)
`			Bullets.remove(Index)
`		endif
		if not GetTweenCustomPlaying(Bullets[Index].Velocity_Tween)
			DeleteObject(Bullets[Index].OID)
			Bullets.remove(Index)
		endif
	next Index
endfunction

