type PathGrid
	Position 		as int2
	Visited 		as integer
	Number			as integer
endtype

function PathInit(Grid ref as PathGrid[][], ScanSize as float, GridSize as integer)
	local y as float
	y=0.5
	for x=0 to Grid.length
		for z=0 to Grid[0].length
			HitOID=ObjectSphereCast(0,x*GridSize,y*GridSize,z*GridSize,x*GridSize,y*GridSize,z*GridSize,ScanSize)
			if HitOID>0
				PathSetCell(Grid,x,z,x,z,0,-1)
			else
				PathSetCell(Grid,x,z,x,z,0,0)
			endif
		next z
	next x
	y=0
	for x=0 to Grid.length
		PathSetCell(Grid,x,y,x,y,0,-1)
	next x
	y=Grid[0].length
	for x=0 to Grid.length
		PathSetCell(Grid,x,y,x,y,0,-1)
	next x
	x=0
	for y=0 to Grid.length
		PathSetCell(Grid,x,y,x,y,0,-1)
	next y
	x=Grid.length
	for y=0 to Grid.length
		PathSetCell(Grid,x,y,x,y,0,-1)
	next y
endfunction

function PathSetCell(Grid ref as PathGrid[][], x as integer, y as integer, TargetX as integer, TargetY as integer, Number as integer, Visited as integer)
	Grid[x,y].Position.x=TargetX
	Grid[x,y].Position.y=TargetY
	Grid[x,y].Number=Number
	Grid[x,y].Visited=Visited
endfunction

function PathClear(Grid ref as PathGrid[][])
	for x=0 to Grid.length
		for y=0 to Grid[0].length
			Grid[x,y].Position.x=0
			Grid[x,y].Position.y=0
			Grid[x,y].Number=0
			if Grid[x,y].Visited>0 then Grid[x,y].Visited=0
		next y
	next x
endfunction

function PathFinding(Grid ref as PathGrid[][], Start as int2)
	if Start.x>0 and Start.y>0 and Start.x<Grid.length and Start.y<Grid[0].length
		local FrontierTemp as int2
		local Frontier as int2[]
		local Neighbors as int2[7]

		Neighbors[0].x=1
		Neighbors[0].y=0
		
		Neighbors[1].x=0
		Neighbors[1].y=1

		Neighbors[2].x=-1
		Neighbors[2].y=0
		
		Neighbors[3].x=0
		Neighbors[3].y=-1
		
		Neighbors[4].x=1
		Neighbors[4].y=1
		
		Neighbors[5].x=1
		Neighbors[5].y=-1

		Neighbors[6].x=-1
		Neighbors[6].y=1
		
		Neighbors[7].x=-1
		Neighbors[7].y=-1

		FrontierTemp.x=Start.x
		FrontierTemp.y=Start.y
		Frontier.insert(FrontierTemp)
		
		Grid[Start.x,Start.y].Position.x=Start.x
		Grid[Start.x,Start.y].Position.y=Start.y
		Grid[Start.x,Start.y].Number=0
		Grid[Start.x,Start.y].Visited=1
		
		while Frontier.length>=0
			x=Frontier[0].x
			y=Frontier[0].y
			Frontier.remove(0)

			//~ if x>0 and x<Grid.length and y>0 and y<Grid[0].length
				for n=0 to Neighbors.length
					nx=x+Neighbors[n].x
					ny=y+Neighbors[n].y
					if Grid[nx,ny].Visited=0
						FrontierTemp.x=nx
						FrontierTemp.y=ny
						Frontier.insert(FrontierTemp)
						Grid[nx,ny].Position.x=x
						Grid[nx,ny].Position.y=y
						Grid[nx,ny].Visited=1
						Grid[nx,ny].Number=Grid[x,y].Number+1
					endif
				next n
			//~ endif
		endwhile
	endif
endfunction
