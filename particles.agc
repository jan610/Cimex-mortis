#include "constants.agc"
type Particle
	PID			as integer
	Position	as vec3
endtype

function ParticleCreate_ambient(Particles ref as Particle[], X#, Y#, Z#)
    pLife# as float = 30.0
    local TempParticle as Particle
    TempParticle.PID=Create3DParticles(X#,Y#,Z#)
	Set3DParticlesLife(TempParticle.PID, pLife#)
    Set3DParticlesMax(TempParticle.PID, -1)
    Set3DParticlesSize(TempParticle.PID, 0.8)
    Set3DParticlesFrequency(TempParticle.PID,30)
    Set3DParticlesDirectionRange(TempParticle.PID,0,0)
    Set3DParticlesDirection(TempParticle.PID, 0.0, 0.0, -0.1, 0)
    Set3DParticlesStartZone( TempParticle.PID, -24.0, 0.0, -24.0, 24.0, 6.0, 24.0 )
    //~ Set3DParticlesStartZone( TempParticle.PID, 0.3, 0.3, 0.3, 0.3, 0.3, 0.3 )
    Set3DParticlesPosition( TempParticle.PID, X#, Y#, Z# ) 
    Set3DParticlesImage( TempParticle.PID, ParticleIID )
    Set3DParticlesColorInterpolation( TempParticle.PID, 1 ) // fade the particles out before they die
    Add3DParticlesColorKeyFrame( TempParticle.PID, 0, 255, 255, 255,0 )
    Add3DParticlesColorKeyFrame( TempParticle.PID, pLife#*0.25, 255, 255, 255,255) // fade to transparence
    Add3DParticlesColorKeyFrame( TempParticle.PID, pLife#*0.75, 255, 255, 255,255)
    Add3DParticlesColorKeyFrame( TempParticle.PID, pLife#, 255, 255, 255, 0 ) // fade to transparence
    Particles.insert(TempParticle)
endfunction

function ParticleCreate_explosion(Particles ref as Particle[], X#, Y#, Z#)
    pLife# as float = 3.0
    local TempParticle as Particle
    TempParticle.PID=Create3DParticles(X#,Y#,Z#)
	Set3DParticlesLife(TempParticle.PID, pLife#)
    Set3DParticlesMax(TempParticle.PID, 200)
    Set3DParticlesSize(TempParticle.PID, 0.8)
    Set3DParticlesFrequency(TempParticle.PID,10000)
    Set3DParticlesDirectionRange(TempParticle.PID,180,180)
    Set3DParticlesDirection(TempParticle.PID, 0.0, 0.8, 0.0, 0.8)
    //Set3DParticlesStartZone( TempParticle.PID, -100.0, -50.0, -100.0, 100.0, 50.0, 100.0 )
    Set3DParticlesStartZone( TempParticle.PID, 0.3, 0.3, 0.3, 0.3, 0.3, 0.3 )
    Set3DParticlesPosition( TempParticle.PID, X#, Y#, Z# ) 
    Set3DParticlesImage( TempParticle.PID, ParticleIID )
    Set3DParticlesColorInterpolation( TempParticle.PID, 1 ) // fade the particles out before they die
    Add3DParticlesColorKeyFrame( TempParticle.PID, 0, 255, 255, 255,255 )
    Add3DParticlesColorKeyFrame( TempParticle.PID, pLife#, 255, 255, 255, 0 ) // fade to transparence
    Particles.insert(TempParticle)
endfunction

function ParticleCreate_bullet(Particles ref as Particle[], X#, Y#, Z#)
    pLife# as float = 0.4
    local TempParticle as Particle
    TempParticle.PID=Create3DParticles(X#,Y#,Z#)
	Set3DParticlesLife(TempParticle.PID, pLife#)
    Set3DParticlesMax(TempParticle.PID, 200)
    Set3DParticlesSize(TempParticle.PID, 0.8)
    Set3DParticlesFrequency(TempParticle.PID,1000)
    Set3DParticlesDirectionRange(TempParticle.PID,180,180)
    Set3DParticlesDirection(TempParticle.PID, 0.0, 1.4, 0.0, 1.4)
    //Set3DParticlesStartZone( TempParticle.PID, -100.0, -50.0, -100.0, 100.0, 50.0, 100.0 )
    Set3DParticlesStartZone( TempParticle.PID, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1 )
    Set3DParticlesPosition( TempParticle.PID, X#, Y#, Z# ) 
    Set3DParticlesImage( TempParticle.PID, ParticleIID )
    Set3DParticlesColorInterpolation( TempParticle.PID, 1 ) // fade the particles out before they die
    Add3DParticlesColorKeyFrame( TempParticle.PID, 0, 255, 255, 255,255 )
    Add3DParticlesColorKeyFrame( TempParticle.PID, pLife#, 255, 255, 255, 0 ) // fade to transparence
    Particles.insert(TempParticle)
endfunction

function ParticleUpdate(Particles ref as Particle[])
	for Index=0 to Particles.length
		Update3DParticles(Particles[Index].PID,GetFrameTime())
		//~ for i=0 to 9 //10 times 0.1 to update 10 particles in one second
			//~ Update3DParticles(Particles[Index].PID,0.1)
		//~ next i
		
		if Get3DParticlesMaxReached(Particles[Index].PID)
			DeleteParticles(Particles[Index].PID)
			Particles.remove(Index)
		endif
	next Index
endfunction

function DeleteParicles(Particles ref as Particle[])
	for p=0 to Particles.length
		DeleteParticles(Particles[p].PID)
	next p
	Particles.length=-1
endfunction
