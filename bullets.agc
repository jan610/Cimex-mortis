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
	local BulletLength as float
	BulletLength = 2
	
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

