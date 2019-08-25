

Type WorldMap
	HexCells		as HexCell[]
endtype

Type HexCell
	ArenaPieces	as ArenaPiece[] // static object(s) for building the arena scene
	Enemies			as enemy[]
endtype

type vec3
	x				as float
	y				as float
	z				as float
endtype

Type ArenaPiece
	OID				as integer	// Object ID for building the arena
	DiffuseIID		as integer	// Diffuse map
	NormalIID		as integer	// Normal map	
	VShaderID		as integer
	PShaderID		as integer
	Position		as vec3
	Rotation		as vec3
endtype

Type enemy
	OID				as integer
	DiffuseIID		as integer
	NormalIID		as integer
	VShaderID		as integer
	PShaderID		as integer
	Position		as vec3
	Rotation		as vec3
endtype
