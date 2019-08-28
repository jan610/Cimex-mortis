type Particle
	PID			as integer
	Position	as vec3
endtype


function ParticleCreate(Particles ref as Particle[], X#, Y#, Z#)
	local TempParticle as Particle
	TempParticle.PID=Create3DParticles(X#,Y#,Z#)
	//~ ImageID=CreateImageColor(255,255,255,255)
	//~ Set3DParticlesImage(TempParticle.PID, ImageID ) // maybe just create a global ImageID until we have a better method
	Set3DParticlesLife(TempParticle.PID,2)
	Set3DParticlesMax(TempParticle.PID,10)
	Set3DParticlesSize(TempParticle.PID,0.1)
	Set3DParticlesFrequency(TempParticle.PID,1)
	Set3DParticlesDirectionRange(TempParticle.PID,180,180)
	Set3DParticlesDirection(TempParticle.PID,0,1,0,1)
	Particles.insert(TempParticle)
endfunction

function ParticleUpdate(Particles ref as Particle[])
	for Index=0 to Particles.length
		Update3DParticles(Particles[Index].PID,0.1)
		//~ for i=0 to 9 //10 times 0.1 to update 10 particles in one second
			//~ Update3DParticles(Particles[Index].PID,0.1)
		//~ next i
		if Get3DParticlesLife(Particles[Index].PID)>2.0
			DeleteParticles(Particles[Index].PID)
			Particles.remove(Index)
		endif
	next Index
endfunction
