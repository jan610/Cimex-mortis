
function LoadGameMedia()
	width=GetDeviceWidth()
	height=GetDeviceHeight()
	
	global crosshairSID
	CrosshairIID = loadimage("crosshair.png")
	crosshairSID = CreateSprite( crosshairIID ) 
	setSpriteSize (crosshairSID, 7.0, 7.0)
	SetRawMouseVisible( 0 )
	
	global BulletShaderID
	BulletShaderID=LoadShader("shader/Line.vs","shader/Default.ps")
	global BulletDiffuseIID
	BulletDiffuseIID=LoadImage("bullet.png")
	
	global BlastShaderID
	BlastShaderID=LoadShader("shader/Shockwave.vs","shader/Shockwave.ps")
	global NoiseIID
	NoiseIID=LoadImage("noise.jpg")
	
	global SceneIID
	SceneIID=CreateRenderImage(width,height,0,0)
	global BlurHIID
	BlurHIID=CreateRenderImage(width,height,0,0)
	global BlurVIID
	BlurVIID=CreateRenderImage(width,height,0,0)
	global BlurHSID
	BlurHSID=LoadFullScreenShader("shader/BlurH.ps")
	SetShaderConstantByName(BlurHSID,"blurScale",6.0,0,0,0)
	global BlurVSID
	BlurVSID=LoadFullScreenShader("shader/BlurV.ps")
	SetShaderConstantByName(BlurVSID,"blurScale",6.0,0,0,0)
	
	global ParticleIID
	ParticleIID=loadimage("particles2.png")
	
	global ParticleExpIID
	ParticleExpIID=loadimage("particle_bubble.png")
`	ParticleExpIID=loadimage("particle_blob.png")
`	ParticleIID=loadimage("particles2_b.png")

	global ParticleAmbIID
	ParticleAmbIID=loadimage("particle_blob.png")
	
	global ParticleExplotionIID
	ParticleExplotionIID=loadimage("particle_explotion.png")
	
	// WALL IMAGE 1
	global GutDiffuseIID
	GutDiffuseIID = LoadImage("wall_small_diffuse.png")
	global GutNormalIID
	GutNormalIID = LoadImage("wall_small_normal.png")
	
	global GutOID
`	GutOID = LoadObject("ground.3ds")
	GutOID = LoadObject("arena.3ds")
	SetObjectImage(GutOID, GutDiffuseIID, 0)
	//~ SetObjectUVScale(GutOID,0,5,5)
	SetObjectNormalMap(GutOID,GutNormalIID)
	SetObjectPosition(GutOID,24,0,24)
	//~ SetObjectScalePermanent(GutOID,1.5,1.5,1.5)
	//~ RotateObjectLocalY(GutOID,30)
	
	global SelfilluminationSID
	SelfilluminationSID=LoadShader("shader/Normal.vs","shader/Slefillumination.ps")
	SetShaderConstantByName(SelfilluminationSID,"glow",2.0,0,0,0)
	global LaserSoundID as integer[]
	LaserSoundID.insert(LoadSound("sound/Laser_Shoot.wav"))
	LaserSoundID.insert(LoadSound("sound/Laser_Shoot2.wav"))
	
	global AmbientSoundID
	AmbientSoundID=LoadSound("sound/UnderwaterLoop.wav")
	PlaySound(AmbientSoundID,15,1)
	
	global WallHitSoundID
	WallHitSoundID=LoadSound("sound/low_dark_hit.wav")
	
	//~ global GobalPlayerOID
	//~ GobalPlayerOID=LoadObjectWithChildren("player.3ds")
	
	global SuckSoundID
	SuckSoundID = LoadSound("sound/sucky.wav")
	global SuckSoundInstance as integer
	SuckSoundInstance = 0
	global SuckSoundFade_Tween as integer
	SuckSoundFade_Tween = 0
endfunction


function DeleteGameMedia()
	DeleteShader(BulletShaderID)
	DeleteImage(BulletDiffuseIID)
	
	DeleteImage(SceneIID)
	DeleteImage(BlurHIID)
	DeleteImage(BlurVIID)
	DeleteShader(BlurHSID)
	DeleteShader(BlurVSID)
	
	DeleteImage(ParticleIID)
	
	DeleteImage(ParticleExpIID)
	
	DeleteImage(GutDiffuseIID)
	DeleteImage(GutNormalIID)
	//~ DeleteObject(GutOID)
	
	DeleteShader(SelfilluminationSID)
	
	DeleteSound(LaserSoundID[0])
	DeleteSound(LaserSoundID[1])
	LaserSoundID.length=-1
	
	DeleteSound(AmbientSoundID)
	DeleteSound(WallHitSoundID)
	DeleteSound(SuckSoundID)
	if GetTweenExists(SuckSoundFade_Tween)
		DeleteTween(SuckSoundFade_Tween)
	endif
endfunction

function SetChildrenImage(id as integer, img as integer, stage as integer)
    i as integer
    h as integer
    for i=1 to GetObjectNumChildren(id)
        h = GetObjectChildID(id, i)
        SetObjectImage(h, img, stage)
    next
endfunction
