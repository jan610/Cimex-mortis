
function LoadGameMedia()
	width=GetDeviceWidth()
	height=GetDeviceHeight()
	
	global BulletShaderID
	BulletShaderID=LoadShader("shader/Line.vs","shader/Default.ps")
	global BulletDiffuseIID
	BulletDiffuseIID=LoadImage("bullet.png")
	
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
	ParticleIID=loadimage("particle_blob.png")
`	ParticleIID=loadimage("particles2_b.png")
	
	global GutDiffuseIID
	//GutDiffuseIID = LoadImage("guts.png")
	GutDiffuseIID = LoadImage("abc_dif2.jpg")
	global GutNormalIID
	//GutNormalIID = LoadImage("guts.nrm.png")
	GutNormalIID = LoadImage("abc_nrm3.jpg")
	global GutOID
	GutOID = LoadObject("ground.3ds")
	SetObjectImage(GutOID, GutDiffuseIID, 0)
	SetObjectNormalMap(GutOID,GutNormalIID)
	SetObjectPosition(GutOID,24,-2,24)
	SetObjectScalePermanent(GutOID,0.022,0.022,0.022)
	
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
	DeleteObject(GutOID)
	
	DeleteShader(SelfilluminationSID)
	
	DeleteSound(LaserSoundID[0])
	DeleteSound(LaserSoundID[1])
	LaserSoundID.length=-1
	
	DeleteSound(AmbientSoundID)
	DeleteSound(WallHitSoundID)

endfunction
