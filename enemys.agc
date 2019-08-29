Type Character		// can be Player and Enemy
	OID				as integer
	DiffuseIID		as integer
	NormalIID		as integer
	ShaderID		as integer
	Position		as vec3
	Rotation		as vec3
	Velocity		as vec3
	AngularVelocity	as vec3
	Life			as float // Player Health
	MaxSpeed		as float 
endtype

function EnemyInit(Enemy ref as Character[], Grid ref as PathGrid[][], GridSize as integer)
	for Index=0 to Enemy.length
		Enemy[Index].OID=CreateObjectBox(1,1,1)
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
	Enemy.Life=100
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
			PathClear(Grid)
			PathFinding(Grid, PlayerGrid)
		endif
	endif
	
	for Index=0 to Enemy.length
		if Enemy[Index].Life<=0
			ParticleCreate_explosion(Particles, Enemy[Index].Position.x,Enemy[Index].Position.y,Enemy[Index].Position.z)
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
		
		HitOID=ObjectSphereSlide(0,OldEnemyX#,OldEnemyY#,OldEnemyZ#,Enemy[Index].Position.x,Enemy[Index].Position.y,Enemy[Index].Position.z,0.3)
		if HitOID>0
			HitCount=0
			if Grid[EnemyGridX,EnemyGridZ].Number>0
				Enemy[Index].Position.x=GetObjectRayCastSlideX(0)
				Enemy[Index].Position.z=GetObjectRayCastSlideZ(0)
			endif
			for i=0 to GetObjectRayCastNumHits()-1
				HitOID=GetObjectRayCastHitID(i)
				if HitOID=Player.Character.OID
					EnemySpawn(Enemy[Index], Grid, GridSize)
				endif
			next i
		endif
		
		SetObjectPosition(Enemy[Index].OID,Enemy[Index].Position.x,Enemy[Index].Position.y,Enemy[Index].Position.z)
		SetObjectRotation(Enemy[Index].OID,Enemy[Index].Rotation.x,Enemy[Index].Rotation.y,Enemy[Index].Rotation.z)
	next Index
endfunction
