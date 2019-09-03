type Player
	Character		as Character
	Energy			as float
	Attack			as float
	OldGrid			as int2
	Boost_TweenID	as integer
	State 			as integer
	LID				as integer
	CameraPosition	as vec3
	ShootDelay		as float
	BlastThreshold	as float
	SuckTime		as float
	alive				as integer
endtype

function PlayerInit(Player ref as Player, CameraDistance#)
	PlayerDiffuseIID=LoadImage("player0001.png")
	PlayerIlluminationIID=LoadImage("player0002a.png")
	Player.Character.OID=LoadObjectWithChildren("player.3ds")
	AnimationName$=GetObjectAnimationName(Player.Character.OID,1)
	AnimationDurration#=GetObjectAnimationDuration(Player.Character.OID,AnimationName$)
	PlayObjectAnimation(Player.Character.OID,AnimationName$,0,AnimationDurration#,1,0.2)
	SetObjectCollisionMode(Player.Character.OID,0)
	SetObjectTransparency(Player.Character.OID,1)
	RotateObjectLocalY(Player.Character.OID,180)
	FixObjectPivot(Player.Character.OID)
	SetObjectShader(Player.Character.OID,SelfilluminationSID)
	SetObjectImage(Player.Character.OID, PlayerDiffuseIID, 0)
	SetObjectImage(Player.Character.OID, PlayerIlluminationIID, 1)
    for Index=1 to GetObjectNumChildren(Player.Character.OID)
        ChildOID = GetObjectChildID(Player.Character.OID,Index)
        SetObjectCollisionMode(ChildOID,0)
        SetObjectShader(ChildOID,SelfilluminationSID)
		SetObjectImage(ChildOID, PlayerDiffuseIID, 0)
		SetObjectImage(ChildOID, PlayerIlluminationIID, 1)
    next
    Player.Character.CollisionOID=CreateObjectBox(1,1,1)
    SetObjectVisible(Player.Character.CollisionOID,0)
	Player.Character.MaxSpeed=8.0
	Player.Character.Position.x=16
	Player.Character.Position.y=0
	Player.Character.Position.z=16
	Player.Character.Life=100.0
	Player.Character.MaxLife=100.0
	Player.Energy=25.0
	Player.Attack = 0.9
	Player.LID = 1
	SetObjectPosition(Player.Character.OID,Player.Character.Position.x,Player.Character.Position.y,Player.Character.Position.z)
	SetCameraPosition(1,Player.Character.Position.x,Player.Character.Position.y+CameraDistance#,Player.Character.Position.z-CameraDistance#)
	SetCameraLookAt(1,Player.Character.Position.x,Player.Character.Position.y,Player.Character.Position.z,0)
	Player.Boost_TweenID = CreateTweenCustom(0.3)
	SetTweenCustomFloat1(Player.Boost_TweenID,100,0,TweenSmooth2())
	CreatePointLight(Player.LID,0,0,0,15,128,255,128)
	SetPointLightMode(Player.LID,1)
endfunction

function DeletePlayer(Player ref as Player)
	DeletePointLight(Player.LID)
	DeleteTween(Player.Boost_TweenID)
	DeleteObject(Player.Character.OID)
	DeleteObject(Player.Character.CollisionOID)
endfunction

function BuoyancyApply(Character ref as Character,BuoyancyAmplitude as float,BuoyancySpeed as float)
	SetObjectPosition(Character.OID,GetObjectX(Character.OID),GetObjectY(Character.OID)+(sin(timer()*BuoyancySpeed)*BuoyancyAmplitude),GetObjectZ(Character.OID))
endfunction

function PlayerControll(Player ref as Player, Bullets ref as Bullet[], Blasts ref as Bullet[], CameraDistance#) // player speed is in the Player character type
	Time#=Timer()
	FrameTime#=GetFrameTime()
	CameraAngleY#=GetCameraAngleY(1)
	PointerX#=GetPointerX()
	PointerY#=GetPointerY()
	
	Sin0#=sin(CameraAngleY#)
	Sin90#=sin(CameraAngleY#+90.0)
	
	if GetPointerState() and Time#>Player.ShootDelay
		Player.ShootDelay=Time#+0.1
		BulletCreate(Bullets, Player, BulletShaderID, BulletDiffuseIID, -1)
	endif
	
	Player.Character.Life=Clamp(Player.Character.Life+1*FrameTime#,0,100)
	
	//if GetRawMouseRightPressed()
	//	Player.BlastThreshold=Time#+2
	//endif
	
	if GetRawKeyPressed(KEY_F)
		if Player.Energy>=50
			Player.BlastThreshold=Time#+2
			Player.Energy=10
			BulletCreateBlast(Blasts, Player, BlastShaderID, NoiseIID)
			CamshakeShake(2.0)
			PlaySound(AOESID)
		endif
	endif
	
	if GetRawMouseRightState()
		// if Time#>Player.BlastThreshold and Player.Energy>=50
		//		Player.BlastThreshold=Time#+2
		//		Player.Energy=0
		//		BulletCreateBlast(Blasts, Player, BlastShaderID, NoiseIID)
		// endif
		player.State=STATE_SUCK
		if SuckSoundInstance = 0 
			SuckSoundInstance = playsound(SuckSoundID,10,1) // loop forever
		endif
		if GetTweenCustomExists(SuckSoundFade_Tween)
			DeleteTween(SuckSoundFade_Tween)
		endif
		SuckSoundFade_Tween = CreateTweenCustom(0.2)
		SetTweenCustomFloat1(SuckSoundFade_Tween,GetSoundInstanceVolume(SuckSoundInstance),10,TweenLinear())
		PlayTweenCustom(SuckSoundFade_Tween,0)
	else
		player.state=0	
	endif

	If GetRawMouseRightReleased() // User has released the RMB
		if GetTweenCustomExists(SuckSoundFade_Tween)
			DeleteTween(SuckSoundFade_Tween)
		endif
		SuckSoundFade_Tween = CreateTweenCustom(0.8)
		SetTweenCustomFloat1(SuckSoundFade_Tween,GetSoundInstanceVolume(SuckSoundInstance),0,TweenEaseout1())
		PlayTweenCustom(SuckSoundFade_Tween,0)
	endif

	if GetTweenCustomExists(SuckSoundFade_Tween)
		if GetTweenCustomPlaying(SuckSoundFade_Tween)
			UpdateTweenCustom(SuckSoundFade_Tween,GetFrameTime())
			SetSoundInstanceVolume(SuckSoundInstance,GetTweenCustomFloat1(SuckSoundFade_Tween))
		endif
	endif
	
	if GetRawKeyPressed(KEY_SPACE)
		PlayTweenCustom(Player.Boost_TweenID,0.0)
	endif
	
	if GetTweenCustomPlaying(player.Boost_TweenID)
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
    
    CameraX#=GetCameraX(1)
	CameraY#=GetCameraY(1)
	CameraZ#=GetCameraZ(1)
	
    LookAtX#=Get3DVectorXFromScreen(PointerX#,PointerY#)
    LookAtY#=Get3DVectorYFromScreen(PointerX#,PointerY#)
    LookAtZ#=Get3DVectorZFromScreen(PointerX#,PointerY#)

    Length#=0-CameraY#/LookAtY#
    LookAtX#=CameraX#+LookAtX#*Length#
    LookAtZ#=CameraZ#+LookAtZ#*Length#
	
    PlayerMovement(Player, (MoveX1#+MoveX2#)*FrameTime#, (MoveZ1#+MoveZ2#)*FrameTime#, LookAtX#, LookAtZ#, CameraDistance#)
endfunction

function PlayerMovement(Player ref as Player,MoveX#, MoveZ#, LookAtX#,LookAtZ#, CameraDistance#)
	Player.Character.Velocity.x=curvevalue(MoveX#,Player.Character.Velocity.x,4.0)
	Player.Character.Velocity.y=curvevalue(0,Player.Character.Velocity.y,0.2)
	Player.Character.Velocity.z=curvevalue(MoveZ#,Player.Character.Velocity.z,4.0)

	Player.Character.Position.x=Player.Character.Position.x+Player.Character.Velocity.x
	Player.Character.Position.y=Player.Character.Position.y+Player.Character.Velocity.y
	Player.Character.Position.z=Player.Character.Position.z+Player.Character.Velocity.z
	
	OldPlayerX#=GetObjectX(Player.Character.OID)
	OldPlayerY#=GetObjectY(Player.Character.OID)
	OldPlayerZ#=GetObjectZ(Player.Character.OID)
	
	HitOID=ObjectSphereSlide(0,OldPlayerX#,OldPlayerY#,OldPlayerZ#,Player.Character.Position.x,Player.Character.Position.y,Player.Character.Position.z,0.3)
	if HitOID>0
		if HitOID<>Player.Character.CollisionOID
			Player.Character.Position.x=GetObjectRayCastSlideX(0)
			Player.Character.Position.z=GetObjectRayCastSlideZ(0)
		endif
	endif
	
	// Player to look at mouse position
	DistX#=LookAtX#-Player.Character.Position.x
	DistZ#=LookAtZ#-Player.Character.Position.z
	
	NewAngle#=-atanfull(DistX#,DistZ#)
	Player.Character.Rotation.y=CurveAngle(Player.Character.Rotation.y,NewAngle#,4.0)
	
	Player.CameraPosition.x=CurveValue(Player.Character.Position.x,Player.CameraPosition.x,3)
	Player.CameraPosition.y=CurveValue(Player.Character.Position.y+CameraDistance#,Player.CameraPosition.y,3)
	Player.CameraPosition.z=CurveValue(Player.Character.Position.z-CameraDistance#,Player.CameraPosition.z,3)
	
	SetObjectPosition(Player.Character.OID,Player.Character.Position.x,Player.Character.Position.y,Player.Character.Position.z)
	SetObjectRotation(Player.Character.OID,Player.Character.Rotation.x,Player.Character.Rotation.y,Player.Character.Rotation.z)
	SetObjectPosition(Player.Character.CollisionOID,Player.Character.Position.x,Player.Character.Position.y,Player.Character.Position.z)
	//~ SetCameraPosition(1,Player.Position.x+CameraDistance#*Sin0#,Player.Position.y+CameraDistance#,Player.Position.z+CameraDistance#*Cos0#)
	//~ SetCameraLookAt(1,Player.Position.x,Player.Position.y,Player.Position.z,0)
	SetCameraPosition(1,Player.CameraPosition.x,Player.CameraPosition.y,Player.CameraPosition.z)
	SetPointLightPosition(Player.LID,Player.Character.Position.x,Player.Character.Position.y,Player.Character.Position.z)
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
