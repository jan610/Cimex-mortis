// *****************************
/// where do these go ?
Type WorldMap
	HexCells		as HexCell[]
endtype

Type HexCell
	ArenaPieces		as ArenaPiece[] // static object(s) for building the arena scene
	Enemies			as Character[]
endtype

Type ArenaPiece
	OID				as integer	// Object ID for building the arena
	DiffuseIID		as integer	// Diffuse map
	NormalIID		as integer	// Normal map	
	ShaderID		as integer
	Position		as vec3
	Rotation		as vec3
endtype
// *****************************

type int2
	x				as integer
	y				as integer
endtype

type vec2
	x				as float
	y				as float
endtype

type vec3
	x				as float
	y				as float
	z				as float
endtype

function ScreenWidth()
	result# = GetScreenBoundsRight() - GetScreenBoundsLeft()
endfunction result#

function ScreenHeight()
	result# = GetScreenBoundsBottom() - GetScreenBoundsTop()
endfunction result#

function CurveAngle(CurrentAngle#,DestinationAngle#,Steps#)
	Diff#=WrapValue(CurrentAngle#-DestinationAngle#)
	if Diff#<180
		Diff#=-Diff#
	else
		Diff#=360-Diff#
	endif
	NewValue#=WrapValue(CurrentAngle#+Diff#/Steps#)
endfunction NewValue#

function WrapValue(angle#)
	if angle#<0
		angle#=angle#+360
	endif
	if angle#>360
		angle#=angle#-360
	endif
endfunction angle#

function CurveValue(Destination#,Current#,Steps#)
	Current#=Current#+((Destination#-Current#)/Steps#)
endfunction Current#

function Distance(x1#,y1#,z1#,x2#,y2#,z2#)
	DistX#=x2#-x1#
	DistY#=y2#-y1#
	DistZ#=z2#-z1#
	Dist#=sqrt(DistX#*DistX#+DistY#*DistY#+DistZ#*DistZ#)
endfunction Dist#

function Clamp(Value#,Min#,Max#)
	if Value#>Max# then Value#=Max#
	if Value#<Min# then Value#=Min#
endfunction Value#

function Wrap(Value#,Min#,Max#)
	if Value#>Max# then Value#=Min#
	if Value#<Min# then Value#=Max#
endfunction Value#

type Camshaker
	Offset		as vec3[60]
	Start		as float
	Amplitude	as float
endtype

function CamshakeInit(Camshake ref as Camshaker)
	for t = 0 to 60
		Camshake.Offset[t].x=(random2(0,(t-59)*200.0)-((t-59)*200.0)*0.5)*0.0001
		Camshake.Offset[t].y=(random2(0,(t-59)*200.0)-((t-59)*200.0)*0.5)*0.0001
		Camshake.Offset[t].z=(random2(0,(t-59)*200.0)-((t-59)*200.0)*0.5)*0.0001
	next t
endfunction

function CamshakeShake(Camshake ref as Camshaker,Amplitude as float)
	Camshake.Start = timer()
	Camshake.Amplitude = Amplitude
endfunction

function CamshakeUpdate(Camshake ref as Camshaker)
		index = (timer()-Camshake.Start)*60
		if index <=60
			SetCameraPosition(1,getcamerax(1)+Camshake.Offset[index].x*Camshake.Amplitude,getcameray(1)+Camshake.Offset[index].y*Camshake.Amplitude,getcameraz(1)+Camshake.Offset[index].z*Camshake.Amplitude)
		endif
endfunction

