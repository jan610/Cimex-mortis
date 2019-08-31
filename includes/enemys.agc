Type Character		// can be Player and Enemy
	OID				as integer
	CollisionOID	as integer
	DiffuseIID		as integer
	NormalIID		as integer
	ShaderID		as integer
	Position		as vec3
	Rotation		as vec3
	Velocity		as vec3
	AngularVelocity	as vec3
	Life			as float // Player Health
	MaxLife		as float
	MaxSpeed		as float
	MeleeDamage	as float
	style			as integer
endtype

function EnemyInit(Enemy ref as Character[], Grid ref as PathGrid[][], GridSize as integer)
	local Original as integer[1]
	
	for Index=0 to Enemy.length
		Enemy[Index].style = random2(0,Original.length)
		select Enemy[Index].style
			case 0
				If Original[Enemy[Index].style]=0
					Enemy[Index].OID=LoadObject("virus1.3ds")
					Enemy[Index].DiffuseIID=Loadimage("virus1.png")
					Enemy[Index].NormalIID=Loadimage("virus1.nrm.png")
					Original[Enemy[Index].style]=Index
				else
					OriginalIndex=Original[Enemy[Index].style]
					Enemy[Index]=Enemy[OriginalIndex]
					Enemy[Index].OID=CloneObject(Enemy[OriginalIndex].OID)
				endif
			endcase
			case 1
				If Original[Enemy[Index].style]=0
					Enemy[Index].OID=LoadObject("virus2.3ds")
					Enemy[Index].DiffuseIID=Loadimage("virus2.png")
					Enemy[Index].NormalIID=Loadimage("virus2.nrm.png")
					Original[Enemy[Index].style]=Index
				else
					OriginalIndex=Original[Enemy[Index].style]
					Enemy[Index]=Enemy[OriginalIndex]
					Enemy[Index].OID=CloneObject(Enemy[OriginalIndex].OID)
				endif
			endcase
		endselect
		SetObjectImage(Enemy[Index].OID,Enemy[Index].DiffuseIID,0)
		SetObjectNormalMap(Enemy[Index].OID,Enemy[Index].NormalIID)
		Enemy[Index].MaxSpeed=random(20,50)/10.0
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
	Enemy.Life=100.0
	Enemy.MeleeDamage=17.0
endfunction

function EnemyControll(Enemy ref as Character[], Player ref as Player, Grid ref as PathGrid[][], GridSize as integer, Particles ref as Particle[])
	FrameTime#=GetFrameTime()
	PlayerGrid as int2
	PlayerGrid.x=round(Player.Character.Position.x/GridSize)
	PlayerGrid.y=round(Player.Character.Position.z/GridSize)
	
	// TODO: for each Enemy Cast ray to player and only calculate path if there is an obstacle detected else run straight to player
	// only calculate if the player moves to a new cell
	if PlayerGrid.x<>Player.OldGrid.x or PlayerGrid.y<>Player.OldGrid.y
		Player.OldGrid.x=PlayerGrid.x
		Player.OldGrid.y=PlayerGrid.y
		if PlayerGrid.x>0 and PlayerGrid.y>0 and PlayerGrid.x<Grid.length and PlayerGrid.y<Grid[0].length
			MinX=PlayerGrid.x-14
			MinY=PlayerGrid.y-14
			MaxX=PlayerGrid.x+14
			MaxY=PlayerGrid.y+14
			if MinX<0 then MinX=0
			if MinY<0 then MinY=0
			if MaxX>Grid.length then MaxX=Grid.length
			if MaxY>Grid[0].length then MaxY=Grid[0].length
			PathClear(Grid, MinX, MinY, MaxX, MaxY)
			PathFinding(Grid, PlayerGrid, MinX, MinY, MaxX, MaxY)
		endif
	endif
	
	for Index=0 to Enemy.length
		if Enemy[Index].Life<=0
			ParticleCreate_explosion(Particles, Enemy[Index].Position.x,Enemy[Index].Position.y,Enemy[Index].Position.z)
			ParticleCreate_realExplosion(Particles, Enemy[Index].Position.x,Enemy[Index].Position.y,Enemy[Index].Position.z)
			ParticleCreate_bubbles(Particles, Enemy[Index].Position.x,Enemy[Index].Position.y,Enemy[Index].Position.z)
			EnemySpawn(Enemy[Index], Grid, GridSize)
			continue
		endif
		EnemyGridX=round(Enemy[Index].Position.x/GridSize)
		EnemyGridZ=round(Enemy[Index].Position.z/GridSize)
		if EnemyGridX<0 then EnemyGridX=0
		if EnemyGridZ<0 then EnemyGridZ=0
		if EnemyGridX>Grid.length then EnemyGridX=Grid.length
		if EnemyGridZ>Grid[0].length then EnemyGridZ=Grid[0].length
		
		//~ if Grid[EnemyGridX,EnemyGridZ].Number>0 and Grid[EnemyGridX,EnemyGridZ].Number<3
			//~ EnemySpawn(Enemy[Index], Grid, GridSize)
		//~ endif
		
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
		
		if Enemy[index].style=0
			NewAngle#=-atanfull(DistX#,DistZ#)
		else
			NewAngle#=atan2(DistX#,DistZ#)
		endif
		Enemy[Index].Rotation.y=CurveAngle(Enemy[Index].Rotation.y,NewAngle#,9.0)

		JellyfishMovement#=pow(1.0+sin(Enemy[Index].Position.x*Enemy[Index].Position.z+Timer()*500)*0.5+0.5,2)/3
		EnemyDirX#=sin(Enemy[Index].Rotation.y)
		EnemyDirZ#=cos(Enemy[Index].Rotation.y)

		EnemySpeedX#=EnemyDirX#*Enemy[Index].MaxSpeed*JellyfishMovement#*FrameTime#
		EnemySpeedZ#=EnemyDirZ#*Enemy[Index].MaxSpeed*JellyfishMovement#*FrameTime#
		
		EnemyDirVID=CreateVector3(Enemy[Index].Position.x-Player.Character.Position.x,0,Enemy[Index].Position.z-Player.Character.Position.z)
		Length#=GetVector3Length(EnemyDirVID)
		SetVector3(EnemyDirVID,GetVector3X(EnemyDirVID)/Length#,0,GetVector3Z(EnemyDirVID)/Length#)
		LookDirVID=CreateVector3(sin(Player.Character.Rotation.y),0,cos(Player.Character.Rotation.y))
		if Enemy[Index].style = 1
			if Player.state=STATE_SUCK and GetVector3Dot(LookDirVID,EnemyDirVID)<-0.5 and Length#<=SUCK_DISTANCE
				EnemySpeedX#=-(SUCK_POWER*EnemyDirX#*Enemy[Index].MaxSpeed*FrameTime#)
				EnemySpeedZ#=-(SUCK_POWER*EnemyDirZ#*Enemy[Index].MaxSpeed*FrameTime#)
			endif
		endif
		DeleteVector3(EnemyDirVID)
		DeleteVector3(LookDirVID)
		
		Enemy[Index].Position.x=Enemy[Index].Position.x-EnemySpeedX#
		Enemy[Index].Position.z=Enemy[Index].Position.z-EnemySpeedZ#
		
		OldEnemyX#=GetObjectX(Enemy[Index].OID)
		OldEnemyY#=GetObjectY(Enemy[Index].OID)
		OldEnemyZ#=GetObjectZ(Enemy[Index].OID)
		
		HitOID=ObjectSphereSlide(0,OldEnemyX#,OldEnemyY#,OldEnemyZ#,Enemy[Index].Position.x,Enemy[Index].Position.y,Enemy[Index].Position.z,0.3)
		if HitOID>0 and HitOID<>Enemy[Index].OID
		`	if Grid[EnemyGridX,EnemyGridZ].Number>0
				Enemy[Index].Position.x=GetObjectRayCastSlideX(0)
				Enemy[Index].Position.z=GetObjectRayCastSlideZ(0)
		`	endif
			for i=0 to GetObjectRayCastNumHits()-1
				HitOID=GetObjectRayCastHitID(i)
				if HitOID=Player.Character.CollisionOID
					if Enemy[Index].style = 0
						Player.Character.Life = Player.Character.Life - Enemy[Index].MeleeDamage
						EnemySpawn(Enemy[Index], Grid, GridSize)
					else
						Player.Energy = Player.Energy + Enemy[Index].MeleeDamage
						EnemySpawn(Enemy[Index], Grid, GridSize)
					endif
				endif
			next i
		endif
		
		SetObjectPosition(Enemy[Index].OID,Enemy[Index].Position.x,Enemy[Index].Position.y,Enemy[Index].Position.z)
		SetObjectRotation(Enemy[Index].OID,Enemy[Index].Rotation.x,Enemy[Index].Rotation.y,Enemy[Index].Rotation.z)
	next Index
endfunction
