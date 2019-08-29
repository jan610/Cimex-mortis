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

type cam_shaker
	shake_offset	as vec3[60]
	shake_start		as float
endtype

function init_camshake(cam_shake ref as cam_shaker)
	for t = 0 to 60
		cam_shake.shake_offset[t].x=(random2(0,(t-59)*200.0)-((t-59)*200.0)*0.5)*0.0001
		cam_shake.shake_offset[t].y=(random2(0,(t-59)*200.0)-((t-59)*200.0)*0.5)*0.0001
		cam_shake.shake_offset[t].z=(random2(0,(t-59)*200.0)-((t-59)*200.0)*0.5)*0.0001
	next t
endfunction

function do_cam_shake(cam_shake ref as cam_shaker)
	cam_shake.shake_start = timer()
endfunction

function update_cam_shake(cam_shake ref as cam_shaker)
		index = (timer()-cam_shake.shake_start)*60
		if index <=60
			SetCameraPosition(1,getcamerax(1)+cam_shake.shake_offset[index].x,getcameray(1)+cam_shake.shake_offset[index].y,getcameraz(1)+cam_shake.shake_offset[index].z)
		endif
endfunction

