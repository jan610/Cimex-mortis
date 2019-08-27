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
	
	PathInit(Grid, 0.5, GridSize)
	PathFinding(Grid, PlayerGrid)
	
	Enemy as Character[50]
	EnemyInit(Enemy, Grid, GridSize)

	Bullets as Bullet[]
	
	// temporary ...help me do this in a nicer way please
	BulletShaderID=LoadShader("shader/Line.vs","shader/Default.ps")
	BulletDiffuseIID=LoadImage("bullet.png")
	
	width=GetDeviceWidth()
	height=GetDeviceHeight()
	SceneIID=CreateRenderImage(width,height,0,0)
	BlurHIID=CreateRenderImage(width*0.5,height*0.5,0,0)
	BlurVIID=CreateRenderImage(width*0.5,height*0.5,0,0)
	QuadOID=CreateObjectQuad()
	BlurHSID=LoadFullScreenShader("shader/BlurH.ps")
	BlurVSID=LoadFullScreenShader("shader/BlurV.ps")
	BloomSID=LoadFullScreenShader("shader/Bloom.ps")
	SetShaderConstantByName(BlurHSID,"blurDir",8.0,0,0,0)
	SetShaderConstantByName(BlurVSID,"blurDir",0.0,8.0,0,0)
	
	do
		Print( ScreenFPS() )
		print (player.state)
		print("Energy:"+str(Player.Energy))
		print("Attack:"+str(Player.Attack))
		print("Life:"+str(Player.Character.Life))
		print("mov-speed:"+str(Player.Character.MaxSpeed))
		
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
		SetRenderToImage(BlurVIID,0)
		ClearScreen()
		DrawObject(QuadOID)
		
		SetObjectImage(QuadOID,SceneIID,0)
		SetObjectImage(QuadOID,BlurVIID,1)
		SetObjectShader(QuadOID,BloomSID)
		SetRenderToScreen()
		ClearScreen()
		DrawObject(QuadOID)
		
		Render2DFront()
		Swap()
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
	repeat
		UpdateTweenSprite(FadeTween,IntroScreenSID,GetFrameTime())
		sync()
	until GetRawLastKey() or GetPointerPressed()
	
	DeleteTween(FadeTween)
	FadeTween = CreateTweenSprite(1)
	SetTweenSpriteAlpha(FadeTween,GetSpriteColorAlpha(IntroScreenSID),0,TweenLinear())
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
	
	OldPlayerX#=GetObjectX(Player.Character.OID)
	OldPlayerY#=GetObjectY(Player.Character.OID)
	OldPlayerZ#=GetObjectZ(Player.Character.OID)
	
	if ObjectSphereSlide(0,OldPlayerX#,OldPlayerY#,OldPlayerZ#,Player.Character.Position.x,Player.Character.Position.y,Player.Character.Position.z,0.3)>0
		Player.Character.Position.x=GetObjectRayCastSlideX(0)
		Player.Character.Position.z=GetObjectRayCastSlideZ(0)
	endif
	
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
	
	SetObjectPosition(Player.Character.OID,Player.Character.Position.x,Player.Character.Position.y,Player.Character.Position.z)
	SetObjectRotation(Player.Character.OID,Player.Character.Rotation.x,Player.Character.Rotation.y,Player.Character.Rotation.z)
	//~ SetCameraPosition(1,Player.Position.x+CameraDistance#*Sin0#,Player.Position.y+CameraDistance#,Player.Position.z+CameraDistance#*Cos0#)
	//~ SetCameraLookAt(1,Player.Position.x,Player.Position.y,Player.Position.z,0)
	SetCameraPosition(1,Player.Character.Position.x,Player.Character.Position.y+CameraDistance#,Player.Character.Position.z-CameraDistance#)
endfunction

function EnemyInit(Enemy ref as Character[], Grid ref as PathGrid[][], GridSize as integer)
	for Index=0 to Enemy.length
		Enemy[Index].OID=CreateObjectBox(1,1,1)
		Enemy[Index].MaxSpeed=random(10,50)/10.0
		EnemySpawn(Enemy[Index],Grid,GridSize)	
		SetObjectPosition(Enemy[Index].OID,Enemy[Index].Position.x,Enemy[Index].Position.y,Enemy[Index].Position.z)
	next Index
endfunction

function EnemySpawn(Enemy ref as Character, Grid ref as PathGrid[][], GridSize as integer)
	repeat
		SpawnX#=random(1,Grid.length)
		SpawnY#=random(1,Grid[0].length)
		
		SpawnGridX=round(SpawnX#/GridSize)
		SpawnGridY=round(SpawnY#/GridSize)
	until Grid[SpawnGridX,SpawnGridY].Number>0
	Enemy.Position.x=SpawnX#
	Enemy.Position.z=SpawnY#
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
			TextID=x+y*64
			DeleteText(TextID)
			startx#=GetScreenXFrom3D(x*GridSize,0,y*GridSize)
			starty#=GetScreenYFrom3D(x*GridSize,0,y*GridSize)
			if startx#>GetScreenBoundsLeft() and starty#>GetScreenBoundsTop() and startx#<ScreenWidth() and starty#<ScreenHeight()
				CreateText(TextID,str(Grid[x,y].Number))
				SetTextPosition(TextID,startx#,starty#)
				SetTextSize(TextID,3)
				SetTextAlignment(TextID,1)
				if Grid[x,y].Position.x<>0 or Grid[x,y].Position.y<>0
					endx#=GetScreenXFrom3D(Grid[x,y].Position.x*GridSize,0,Grid[x,y].Position.y*GridSize)
					endy#=GetScreenYFrom3D(Grid[x,y].Position.x*GridSize,0,Grid[x,y].Position.y*GridSize)
					DrawLine(endx#,endy#,startx#,starty#,MakeColor(255,255,255),MakeColor(0,0,255))
				endif
			endif
		next y
	next x
	
	for Index=0 to Enemy.length
		EnemyGridX=round(Enemy[Index].Position.x/GridSize)
		EnemyGridZ=round(Enemy[Index].Position.z/GridSize)
		if EnemyGridX<0 then EnemyGridX=0
		if EnemyGridZ<0 then EnemyGridZ=0
		if EnemyGridX>Grid.length then EnemyGridX=Grid.length
		if EnemyGridZ>Grid[0].length then EnemyGridZ=Grid[0].length
		
		if Grid[EnemyGridX,EnemyGridZ].Number>0 and Grid[EnemyGridX,EnemyGridZ].Number<3
			EnemySpawn(Enemy[Index], Grid, GridSize)
		endif
		
		// if the Enemy can find a path just run straight to the player
		if Grid[EnemyGridX,EnemyGridZ].Number=0
			TargetX=PlayerGrid.x
			TargetZ=PlayerGrid.y
		else
			TargetX=Grid[EnemyGridX,EnemyGridZ].Position.x
			TargetZ=Grid[EnemyGridX,EnemyGridZ].Position.y
		endif
		
		DistX#=(TargetX*GridSize)-Enemy[Index].Position.x
		DistZ#=(TargetZ*GridSize)-Enemy[Index].Position.z
		
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
		
		if Grid[EnemyGridX,EnemyGridZ].Number>0
			if ObjectSphereSlide(0,OldEnemyX#,OldEnemyY#,OldEnemyZ#,Enemy[Index].Position.x,Enemy[Index].Position.y,Enemy[Index].Position.z,0.3)>0
				Enemy[Index].Position.x=GetObjectRayCastSlideX(0)
				Enemy[Index].Position.z=GetObjectRayCastSlideZ(0)
			endif
		endif
		
		SetObjectPosition(Enemy[Index].OID,Enemy[Index].Position.x,Enemy[Index].Position.y,Enemy[Index].Position.z)
		SetObjectRotation(Enemy[Index].OID,Enemy[Index].Rotation.x,Enemy[Index].Rotation.y,Enemy[Index].Rotation.z)
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

