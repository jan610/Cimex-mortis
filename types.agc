

Type WorldMap
	HexCells		as HexCell[]
endtype

Type HexCell
	ArenaPieces	as ArenaPiece[] // static object(s) for building the arena scene
	Enemies			as enemy[]
endtype

type vec3
	x				as integer
	y				as integer
	z				as integer
endtype

Type ArenaPiece
	OID				as integer	// Object ID for building the arena
	DiffuseIID		as integer	// Diffuse map
	NormalIID		as integer	// Normal map	
	VShaderID		as integer
	PShaderID		as integer
	position		as vec3
	rotation		as vec3
endtype

Type enemy
	OID				as integer
	DiffuseIID		as integer
	NormalIID		as integer
	VShaderID		as integer
	PShaderID		as integer
	Position		as vec3
	rotation		as vec3
endtype
