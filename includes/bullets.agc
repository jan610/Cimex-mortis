type Bullet
	OID				as integer
	DiffuseIID		as integer
	NormalIID		as integer
	ShaderID		as integer
	Position		as vec3
	Rotation		as vec3
	Velocity		as vec3
	Time			as float
	Velocity_Tween	as integer
endtype

function BulletCreate(Bullets ref as Bullet[], Player ref as Player, ShaderID as Integer, DiffuseIID as Integer, NormalIID as Integer)
	local MaxSpeed as float
	MaxSpeed = 9
	if Player.Energy > 0
		local TempBullet as Bullet
		TempBullet.OID=CreateObjectPlane(1,1)
		SetObjectPosition(TempBullet.OID,Player.Character.Position.x,Player.Character.Position.y,Player.Character.Position.z)
		SetObjectRotation(TempBullet.OID,0,Player.Character.Rotation.y,0)
		SetObjectImage(TempBullet.OID,DiffuseIID,0)
		//~ SetObjectNormalMap(TempBullet.OID,NormalIID)
		SetObjectCollisionMode(TempBullet.OID,0)
		SetObjectTransparency(TempBullet.OID,1)
		SetObjectShader(TempBullet.OID,ShaderID)
		SetObjectShaderConstantByName(TempBullet.OID,"thickness",0.2,0,0,0)
		//~ SetObjectLightMode(TempBullet.OID,0)
		//~ SetObjectCullMode(TempBullet.OID,0)
		TempBullet.Position.x=Player.Character.Position.x
		TempBullet.Position.y=Player.Character.Position.y
		TempBullet.Position.z=Player.Character.Position.z
		TempBullet.Rotation.y=Player.Character.Rotation.y
		TempBullet.ShaderID=ShaderID
		TempBullet.DiffuseIID=DiffuseIID
		TempBullet.NormalIID=NormalIID
		TempBullet.Velocity.x=sin(Player.Character.Rotation.y)*MaxSpeed
		TempBullet.Velocity.z=cos(Player.Character.Rotation.y)*MaxSpeed
		TempBullet.Velocity_Tween = CreateTweenCustom(Player.Attack)
		SetTweenCustomFloat1(TempBullet.Velocity_Tween,TempBullet.Velocity.x,0,TweenEaseIn2())
		SetTweenCustomFloat2(TempBullet.Velocity_Tween,TempBullet.Velocity.z,0,TweenEaseIn2())
		PlayTweenCustom(TempBullet.Velocity_Tween,0.0)
		TempBullet.Time = Timer()+1
		BulletSoundInstanceID=PlaySound(LaserSoundID[random(0,1)],2)
		Bullets.insert(TempBullet)
		Player.Energy = Player.Energy - 1 
	endif
endfunction

function BulletUpdate(Bullets ref as Bullet[], Enemy ref as Character[], Particles ref as Particle[], Player as Player)
	FrameTime#=GetFrameTime()
	local BulletLength as float
	BulletLength = 1
	local Damage as integer
	Damage=50
	
	for Index=0 to Bullets.length
		Delete=0
		UpdateTweenCustom(Bullets[Index].Velocity_Tween,FrameTime#)
		//~ VelocityX#=GetTweenCustomFloat1(Bullets[Index].Velocity_Tween)*FrameTime#
		//~ VelocityZ#=GetTweenCustomFloat2(Bullets[Index].Velocity_Tween)*FrameTime#
		VelocityX#=Bullets[Index].Velocity.x*FrameTime#
		VelocityZ#=Bullets[Index].Velocity.z*FrameTime#
		Bullets[Index].Position.x=Bullets[Index].Position.x-VelocityX#
		Bullets[Index].Position.z=Bullets[Index].Position.z-VelocityZ#
		OldBulletX#=GetObjectX(Bullets[Index].OID)
		OldBulletZ#=GetObjectZ(Bullets[Index].OID)
		SetObjectPosition(Bullets[Index].OID,Bullets[Index].Position.x,Bullets[Index].Position.y,Bullets[Index].Position.z)
		Length#=sqrt(VelocityX#*VelocityX#+VelocityZ#*VelocityZ#)
		DirX#=VelocityX#/Length#
		DirZ#=VelocityZ#/Length#
		EndX#=Bullets[Index].Position.x-DirX#*BulletLength
		EndZ#=Bullets[Index].Position.z-DirZ#*BulletLength
		SetObjectShaderConstantByName(Bullets[Index].OID,"start",Bullets[Index].Position.x,Bullets[Index].Position.y,Bullets[Index].Position.z, 0)
		SetObjectShaderConstantByName(Bullets[Index].OID,"end",EndX#,Bullets[Index].Position.y,EndZ#, 0)
		HitOID=ObjectRayCast(0,Bullets[Index].Position.x,Bullets[Index].Position.y,Bullets[Index].Position.z,EndX#,Bullets[Index].Position.y,EndZ#)
		if HitOID>0 and HitOID<>Player.Character.CollisionOID
			HitEnemy=0
			for e=0 to Enemy.length
				if HitOID=Enemy[e].OID
					Enemy[e].Life=Enemy[e].Life-Damage
					ParticleCreate_bullet(Particles, Bullets[Index].Position.x,Bullets[Index].Position.y,Bullets[Index].Position.z)
					ParticleCreate_cuteExplosion(Particles, Bullets[Index].Position.x,Bullets[Index].Position.y,Bullets[Index].Position.z)
					HitEnemy=1
					exit
				endif
			next e
			if HitEnemy=0 
				CamshakeShake(0.2)
				PlaySound(WallHitSoundID,random2(20,50))
			endif
			
			DeleteObject(Bullets[Index].OID)
			Bullets.remove(Index)
			continue
		endif
		
		if Timer()>Bullets[Index].Time
			DeleteObject(Bullets[Index].OID)
			Bullets.remove(Index)
			continue
		endif
		//~ if not GetTweenCustomPlaying(Bullets[Index].Velocity_Tween)
			//~ DeleteObject(Bullets[Index].OID)
			//~ Bullets.remove(Index)
			//~ continue
		//~ endif
	next Index
endfunction

function BulletCreateBlast(Bullets ref as Bullet[], Player ref as Player, ShaderID as Integer, DiffuseIID as Integer)
	local TempBullet as Bullet
	TempBullet.OID=CreateObjectPlane(32,32)
	RotateObjectLocalX(TempBullet.OID,90)
	SetObjectPosition(TempBullet.OID,Player.Character.Position.x,Player.Character.Position.y,Player.Character.Position.z)
	SetObjectShader(TempBullet.OID,ShaderID)
	SetObjectImage(TempBullet.OID,DiffuseIID,0)
	SetObjectCollisionMode(TempBullet.OID,0)
	SetObjectTransparency(TempBullet.OID,1)
	TempBullet.Time = Timer()+1
	Bullets.insert(TempBullet)
endfunction

function BulletUpdateBlast(Bullets ref as Bullet[], Enemy ref as Character[], Particles ref as Particle[])
	Damage=1
	Time#=Timer()
	for Index=0 to Bullets.length
		WaveTime#=Bullets[Index].Time-Time#
		WaveTime#=(1.0 - WaveTime#)
		SetObjectShaderConstantByName(Bullets[Index].OID,"waveTime",WaveTime#*0.5,0,0,0)
		print(WaveTime#)
		for e=0 to Enemy.length
			//~ DistX#=Enemy[e].Position.x-Bullets[Index].Position.x
			//~ DistZ#=Enemy[e].Position.z-Bullets[Index].Position.z
			//~ Dist#=sqrt(DistX#*DistX#+DistZ#*DistZ#)
			if Enemy[e].Life>0
				//~ if Dist#>WaveTime#*32-2 and Dist#<WaveTime#*32+2
					Enemy[e].Life=Enemy[e].Life-Damage
				//~ endif
			endif
		next e
		
		if Time#>Bullets[Index].Time
			DeleteObject(Bullets[Index].OID)
			Bullets.remove(Index)
			continue
		endif
	next Index
endfunction
