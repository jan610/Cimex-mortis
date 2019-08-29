
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
	BlurHIID=CreateRenderImage(width*0.25,height*0.25,0,0)
	global BlurVIID
	BlurVIID=CreateRenderImage(width*0.25,height*0.25,0,0)
	global BlurHSID
	BlurHSID=LoadFullScreenShader("shader/BlurH.ps")
	SetShaderConstantByName(BlurHSID,"blurScale",4.0,0,0,0)
	global BlurVSID
	BlurVSID=LoadFullScreenShader("shader/BlurV.ps")
	SetShaderConstantByName(BlurVSID,"blurScale",4.0,0,0,0)
	global BloomSID
	BloomSID=LoadFullScreenShader("shader/Bloom.ps")
	
	global ParticleIID
	ParticleIID=loadimage("particles2.png")
	
	global ParticleExpIID
	ParticleIID=loadimage("particles2_b.png")
	
	global GutDiffuseIID
	GutDiffuseIID = LoadImage("guts.png")
	global GutNormalIID
	GutNormalIID = LoadImage("guts.nrm.png")
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
	global underwaterUID as integer
	LaserSoundID.insert(LoadSound("sound/Laser_Shoot.wav"))
	LaserSoundID.insert(LoadSound("sound/Laser_Shoot2.wav"))
	underwaterUID=LoadSound("sound/UnderwaterLoop.wav")
endfunction


function DeleteGameMedia()
	DeleteShader(BulletShaderID)
	DeleteImage(BulletDiffuseIID)
	
	DeleteImage(SceneIID)
	DeleteImage(BlurHIID)
	DeleteImage(BlurVIID)
	DeleteShader(BlurHSID)
	DeleteShader(BlurVSID)
	DeleteShader(BloomSID)
	
	DeleteImage(ParticleIID)
	
	DeleteImage(ParticleExpIID)
	
	DeleteImage(GutDiffuseIID)
	DeleteImage(GutNormalIID)
	DeleteObject(GutOID)
	
	DeleteShader(SelfilluminationSID)
	
	DeleteSound(LaserSoundID[0])
	DeleteSound(LaserSoundID[1])
	DeleteSound(underwaterUID)
	LaserSoundID.length=-1
endfunction
