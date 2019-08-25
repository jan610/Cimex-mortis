//#option_explicit

#constant TRUE		1
#constant FALSE		0
#constant RIGHTD    2
#constant LEFTD     1
 

type range
	min		as float
	max		as float
	shift	as float
endtype

type bounds
	name	as string
	x		as range
	y		as range
	z		as range
endtype

type	color
	r			as float
	g			as float
	b			as float
endtype

type point
	x 			as float
	y 			as float
	z 			as float
endtype

type light
	id			as integer
	name		as string
	pos			as point
	area		as float
	color		as color
endtype

type camera
	camid		as integer
	lookatid	as integer
	lookat		as point
	pos			as point
endtype

type model
	name		as string
	typ			as string	// "model" "clone" or "point"
	id			as integer
	filename	as string
	texture		as integer
	pos			as point
	uv			as string	// "clamp" or "repeat"
	transparent	as string	// "transparent" or "opaque"
	physics 	as string	// "dynamic" "static" or "none"
	shape		as String	// "sphere" or "cylinder" or "none"
	image		as string
	mipmap		as String	// "mipmap" or "normal"
	target		as integer
	response	as integer
endtype

type path
	name		as String
	nodes		as point[]
endtype

type location
	name		as String
	point		as point
endtype

function	LoadScene(folder as string, models ref as model[], paths ref as path[], lights ref as light[], locations ref as location[], boundaries ref as bounds[], camera ref as camera)
	file		as integer
	line		as string
	model		as model
	v			as point
	o			as integer
	i			as integer
	light		as light
	s			as string
	location	as location
	bounds		as bounds
	
	pathNum as  integer:pathNum=0
	
	LoadPaths(folder, paths)
		
	SetDefaultMinFilter(0)
	SetDefaultMagFilter(0)
	
	file = OpenToRead(MakeFilename(folder, folder+".map"))
	
	do
		line = ReadLine(file)		
		if FileEOF(file) = 1
			exit
		endif
		
		if mid(line, 1, 1) = "#"
			continue
		endif
			
		model.filename = GetStringToken2( line, " ", 1 )
		model.name = GetName(model.filename)
		//if model.name="path" 
		//	model.name="path"+str(pathNum):inc pathNum
		//endif	
		
		model.pos.x = ValFloat(GetStringToken2( line, " ", 2 ))	
		model.pos.y = ValFloat(GetStringToken2( line, " ", 3 ))	
		model.pos.z = ValFloat(GetStringToken2( line, " ", 4 ))	
		model.typ = GetStringToken2( line, " ", 5 )
		model.uv = GetStringToken2( line, " ", 6 )
		model.transparent = GetStringToken2( line, " ", 7 )	
		model.physics =	GetStringToken2( line, " ", 8 )	
		model.shape =	GetStringToken2( line, " ", 9 )			
		model.image =	GetStringToken2( line, " ", 10 )	
		model.mipmap =	GetStringToken2( line, " ", 11 )			
		model.texture = 0
		if model.typ = "point" 
			if GetBase(model.name) = "cam"
				camera.pos = model.pos
				camera.camid = CreateObjectBox(1, 1, 1)
				SetObjectVisible(camera.camid, 0)
				SetObjectPosition(camera.camid , camera.pos.x, camera.pos.y, camera.pos.z)					
			elseif GetBase(model.name) = "look"
				camera.lookat = model.pos
				camera.lookatid = CreateObjectBox(1, 1, 1)
				SetObjectColor(camera.lookatid, 0xff, 0, 0, 0xff)	
				SetObjectPosition(camera.lookatid, camera.lookat.x, camera.lookat.y, camera.lookat.z)	
				SetObjectVisible(camera.lookatid, 0)						
			elseif mid(GetBase(model.name),1,1) = "L"
				light.name = model.name
				light.color.r = val(mid(model.transparent, 2, -1), 16)
				light.color.g = light.color.r
				light.color.b = light.color.r
				light.area = val(model.uv)
				light.id = val(mid(model.name, 2, -1))
				CreatePointLight( light.id, model.pos.x, model.pos.y, model.pos.z, light.area, light.color.r, light.color.g, light.color.b ) 
				lights.insert(light)
			else
				location.name = model.name
				location.point.x = model.pos.x
				location.point.y = model.pos.y
				location.point.z = model.pos.z	
				locations.insert(location)							
			endif
		elseif model.typ = "bounds"
			bounds.name = model.name			
			bounds.x.min = model.pos.x
			bounds.y.min = model.pos.y
			bounds.z.min = model.pos.z		
			bounds.x.max = ValFloat(model.uv)
			bounds.y.max = ValFloat(model.transparent)
			bounds.z.max = ValFloat(model.physics)			
			boundaries.insert(bounds)		
		elseif model.typ = "clone"
			models.insert(model)	
		//elseif GetBase(model.typ)="pathPoint"
		//	model.texture = GetTexture(folder, model.image, models)
		//	model.id = LoadObject(MakeFilename(folder, model.filename))	
		//	SetObjectImage(model.id, model.texture, 1)
		//	SetObjectPosition(model.id , model.pos.x, model.pos.y, model.pos.z)	

		else
			if model.mipmap = "mipmap"
				SetGenerateMipmaps(1)
			endif
			
			model.texture = GetTexture(folder, model.image, models) 		
			
			if model.mipmap = "mipmap"
				SetImageMagFilter(model.texture, 1)
				SetImageMinFilter(model.texture, 1)
			endif
			
			SetGenerateMipmaps(0)
			
			model.id = LoadObjectWithChildren(MakeFilename(folder, model.filename))
						
			if GetObjectNumChildren(model.id)>0
				SetChildrenImage(model.id,model.texture)
				PlayObjectAnimation(model.id,"3DSMAsterAnim",0,1,1,1)
			else
				SetObjectImage(model.id, model.texture, 0)
			endif
             
			SetObjectPosition(model.id , model.pos.x, model.pos.y, model.pos.z)
			
			//SetObjectCollisionMode(model.id,0)
			
			if model.uv = "repeat"
				SetImageWrapU( model.texture , 1 ) 	
				SetImageWrapV( model.texture , 1 ) 					
			endif
			
			if model.transparent = "transparent"
				SetObjectAlphaMask(model.id, 1)
				SetObjectTransparency(model.id,1)
				//SetObjectColor(model.id,255,255,255,20)
			endif
			
			if model.physics = "dynamic"			
				Create3DPhysicsDynamicBody( model.id )
			elseif model.physics = "static"
				Create3DPhysicsStaticBody( model.id )	
			endif			
			
			if model.shape = "sphere"			
				SetObjectShapeSphere( model.id  )
			elseif model.shape = "cylinder"
				SetObjectShapeCylinder(model.id, 1)
			elseif model.shape = "cylinderx"
				SetObjectShapeCylinder(model.id, 0)				
			elseif model.shape = "cylindery"
				SetObjectShapeCylinder(model.id, 1)				
			elseif model.shape = "cylinderz"
				SetObjectShapeCylinder(model.id, 2)				
			elseif model.shape = "box"
				SetObjectShapeBox(model.id)		
			elseif model.shape = "poly"
				SetObjectShapeStaticPolygon(model.id)		
			endif			
			
			models.insert(model)			
		endif			
	loop
	
	CloseFile(file)
	
	for i=0 to models.length
		model = models[i]
		if model.typ <> "clone"
			continue
		endif
		for o=0 to models.length
			if models[o].name = model.name and models[o].typ = "model"
				model.name = models[o].name
				
				model.id = CloneObject(models[o].id)
				
				SetObjectPosition(model.id, model.pos.x, model.pos.y, model.pos.z)
				
				if model.physics = "dynamic"			
					Create3DPhysicsDynamicBody( model.id )
				elseif model.physics = "static"
					Create3DPhysicsStaticBody( model.id )	
				endif			
				
				if model.shape = "sphere"			
					SetObjectShapeSphere( model.id  )
				elseif model.shape = "cylinder"
					SetObjectShapeCylinder(model.id, 1)
				endif			
				
				models[i] = model
				exit
			endif
		next

	next
	
	if camera.camid <> 0
		SetObjectPosition(camera.camid, (camera.pos.x - camera.lookat.x), (camera.pos.y - camera.lookat.y),  (camera.pos.z - camera.lookat.z))
		
		FixObjectToObject(camera.camid , camera.lookatid )
	endif



endfunction 



function LoadPaths(folder as string, paths ref as path[])
	file 	as integer
	line 	as string
	i	 	as integer
	c	 	as integer
	p 	 	as point
	path	as path
	s		as string
	
	file = OpenToRead(MakeFilename(folder, folder+".pth"))
	
	do
		line = ReadLine(file)		
		
		if FileEOF(file) = 1
			exit
		endif
		
		if mid(line, 1, 1) = "#"
			continue
		endif
		
		c = CountStringTokens(line, " ")
		path.name = GetStringToken(line, " ", 1)
		path.nodes.length = -1
		
		for i = 2 to c 
			s = GetStringToken(line, " ", i)
			p.x = ValFloat(GetStringToken(s, ",", 1))
			p.y = ValFloat(GetStringToken(s, ",", 2))
			p.z = ValFloat(GetStringToken(s, ",", 3))						
			path.nodes.insert(p)
		next
		
		paths.insert(path)
	loop
	
	
//	paths.sort()
	
	CloseFile(file)
	
endfunction

function GetTexture(folder as string, name as string, models ref as model[])
	i as integer
	n as string
	
	for i=0 to models.length
		if models[i].image = name and models[i].texture > 0
			exitfunction models[i].texture
		endif
	next i
	
	n = MakeFilename(folder, name)
	
	if GetFileExists(n)
		i = LoadImage(n)
	endif
	
endfunction i


function	MakeFilename(folder as string, name as string)
	f as string	
	r as String
	
	f = ReplaceString(r+folder, "\", "/", -1)		
	
	name = f+"/"+name
	
endfunction name

function	GetBase(name as string)
	s as String
	
	s = GetStringToken(name, "~.", 1)
	
endfunction s

function	GetName(name as string)
	s as String

	s = GetStringToken(name, "~.", 1)
	
endfunction s

function	GetNumber(s as string)
	n as string
	i as integer
	c as string
	
	for i=1 to len(s)
		c = mid(s, i, 1)
		if c >= "0" and c =< "9"
			n = n + c
		endif
	next
	
endfunction n


//	GetObjectDirectionVector()
//
//	Fills empty vector with a normalized direction vector.
//
// 	1 = FWD, 2 = REV, 3 = UP, 4 = DOWN, 5 = RIGHT, 6 = LEFT
//
Function GetObjectDirectionVector( objID as integer, direction as integer, speed as float)
	vector	as point
	tempObj as integer
	
    tempObj = CreateObjectBox( 1.0, 1.0, 1.0 )
    
    SetObjectPosition( tempObj, GetObjectWorldX( objID ), GetObjectWorldY( objID ), GetObjectWorldZ( objID ) )
    SetObjectRotation( tempObj, GetobjectWorldAngleX( objID ), GetobjectWorldAngleY(objID), GetobjectWorldAngleZ( objID ) )
    
    select direction
        case 1 :
            MoveObjectLocalZ( tempObj, speed )
        endcase
        case 2 :
            MoveObjectLocalZ( tempObj, -speed)
        endcase
        case 3 :
            MoveObjectLocalY( tempObj, speed )
        endcase
        case 4 :
            MoveObjectLocalY( tempObj, -speed )
        endcase
        case 5 :
            MoveObjectLocalX( tempObj, speed )
        endcase 
        case 6 :
            MoveObjectLocalX( tempObj, -speed )
        endcase 
    endselect
    
    vector.x = GetObjectWorldX( tempObj ) - GetObjectWorldX( objID )
    vector.y = GetObjectWorldY( tempObj ) - GetObjectWorldY( objID )
    vector.z = GetObjectWorldZ( tempObj ) - GetObjectWorldZ( objID )
    
    DeleteObject(tempObj)
    
EndFunction vector

//
// Centers an object using the position of another object
//
// object - The object whose center will become the position of center
//
// center - The object containing the target center
//
// x = TRUE/FALSE center along the x-axis
//
// y = TRUE/FALSE center along the y-axis
//
// z = TRUE/FALSE center along the z-axis
//
function	CenterObjectAtObject(object as integer, center as integer, x as integer, y as integer, z as integer)
	o 	as point
	c	as point
	d	as point
	n	as point
	
	o.x = GetObjectX(object)
	o.y = GetObjectY(object)
	o.z = GetObjectZ(object)
	
	c.x = GetObjectX(center)
	c.y = GetObjectY(center)		
	c.z = GetObjectZ(center)
		
	d.x = c.x - o.x
	d.y = c.y - o.y
	d.z = c.z - o.z
	
	n.x = 0
	n.y = 0
	n.z = 0
	
	if x = TRUE
		n.x = d.x * -1.0
	endif
		
	if y = TRUE
		n.y = d.y * -1.0
	endif

	if z = TRUE
		n.z = d.z * -1.0
	endif
	
	SetObjectPosition(object, n.x, n.y, n.z)
	FixObjectPivot(object)

	if x = TRUE
		o.x = c.x
	endif
		
	if y = TRUE
		o.y = c.y 
	endif

	if z = TRUE
		o.z = c.z
	endif
	
	SetObjectPosition(object, o.x, o.y, o.z)
			
endfunction

function Distance2D(p1 as point, p2 as point)
	dist as float

	dist=sqrt((p2.x - p1.x)^2 + (p2.y - p1.y)^2)

endfunction dist

function	Distance3D(fp as point, tp as point)
	dist 		as float
	dist = sqrt((fp.x - tp.x)^2 + (fp.y - tp.y)^2 + (fp.z - tp.z)^2 )				
endfunction dist

function	Draw3DHLine(fp as point, tp as point, vis as integer, r as integer, g as integer, b as integer )
	o			as integer
	dist 		as float
	angley		as float
	
	o = CreateObjectPlane(.5,.5)
	RotateObjectLocalX(o, 90)
	SetObjectPosition(o, 0, 0, .25)
	FixObjectPivot(o)
	SetObjectPosition(o, fp.x, fp.y, fp.z)
	setobjectcolor(o, r, g, b, 0xff)
	dist = sqrt((fp.x - tp.x)^2 + (fp.y - tp.y)^2 + (fp.z - tp.z)^2 )				
	SetObjectScale(o, 1, 1, dist * 2)
	SetObjectLookAt(o, tp.x, tp.y, tp.z, 0)
	SetObjectVisible(o, vis)
endfunction o

function	Draw3DLine(fp as point, tp as point, vis as integer, r as integer, g as integer, b as integer )
	o			as integer
	dist 		as float
	angley		as float
	linewidth 	as float 
	
	linewidth = 1
	
	o = CreateObjectPlane(linewidth,linewidth)
	RotateObjectLocalX(o, 90)
	SetObjectPosition(o, 0, 0, linewidth / 2)
	FixObjectPivot(o)
	SetObjectPosition(o, fp.x, fp.y, fp.z)
	setobjectcolor(o, r, g, b, 0xff)
	dist = sqrt((fp.x - tp.x)^2 + (fp.y - tp.y)^2 + (fp.z - tp.z)^2 )				
	SetObjectScale(o, 1, 1, dist * (linewidth / 4.0))
	SetObjectLookAt(o, tp.x, tp.y, tp.z, 0)
	SetObjectVisible(o, vis)
endfunction 


function SetObjectPos(id as integer, pos as point)
	SetObjectPosition(id, pos.x, pos.y, pos.z)
endfunction

function GetObjectPos(id as integer)
	pos as point
	pos.x = GetObjectX(id)
	pos.y = GetObjectY(id)
	pos.z = GetObjectZ(id)		
endfunction pos

function SetChildrenImage(id as integer, img as integer)
	i as integer
	h as integer
	for i=1 to GetObjectNumChildren(id)
		h = GetObjectChildID(id, i)
		SetObjectImage(h, img, 0)
		SetObjectLightMode(h, 0)
	next
endfunction

function SetChildrenShader(id as integer,shader as integer)
	i as integer
	h as integer
	for i=1 to GetObjectNumChildren(id)
		h = GetObjectChildID(id, i)
		SetObjectTransparency(h,1)
		SetObjectDepthWrite(h,1)
		SetObjectShader(h,shader)	
	next
endfunction	
	

