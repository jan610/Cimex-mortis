
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
	BlurHIID=CreateRenderImage(width*0.5,height*0.5,0,0)
	global BlurVIID
	BlurVIID=CreateRenderImage(width*0.5,height*0.5,0,0)
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
	SetObjectPosition(GutOID,24,-0.5,24)
	SetObjectScalePermanent(GutOID,0.022,0.022,0.022)
	
	
	global SelfilluminationSID
	SelfilluminationSID=LoadShader("shader/Normal.vs","shader/Slefillumination.ps")
	SetShaderConstantByName(SelfilluminationSID,"glow",2.0,0,0,0)
	
	global LaserSoundID
	LaserSoundID=LoadSound("sound/Laser_Shoot.wav")
	
endfunction
