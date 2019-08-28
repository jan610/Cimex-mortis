type Debuging
    Enabled        	as integer
    PathEnabled		as integer
    ShaderEnabled	as integer
    FogEnabled    	as integer
    FogMin    		as float
    FogMax    		as float
endtype


function Debuging (Debug ref as Debuging)
    
    if GetRawKeyPressed (112)        // toggle cheat console and input with F1
        Debug.Enabled = 1 - Debug.Enabled 
    endif
    
    if Debug.Enabled = 1
		
        if GetRawKeyPressed (116)    // F5 to toggle path
            Debug.ShaderEnabled = 1 - Debug.ShaderEnabled
        endif
        
        if GetRawKeyPressed (115)    // F4 to toggle path
            Debug.PathEnabled = 1 - Debug.PathEnabled
        endif
        
        if GetRawKeyPressed (114)    // F3 to toggle fog
            Debug.FogEnabled = 1 - Debug.FogEnabled
            SetFogMode( Debug.FogEnabled ) 
        endif
        
        if GetRawKeyState (49)        // 1 is held down
            Debug.FogMin = Debug.FogMin + GetRawMouseWheelDelta()
            SetFogRange( Debug.FogMin, Debug.FogMax ) 
        endif
        
        if GetRawKeyState (50)        // 2 is held down
            Debug.FogMax = Debug.FogMax + GetRawMouseWheelDelta()
            SetFogRange( Debug.FogMin, Debug.FogMax )
        endif
        
        print ("  CHEAT CONSOLE" + chr(10))
        print ("  FogMode=" + str(Debug.fogEnabled) + "     F3 to toggle" + chr(10))
        print ("  FogMin=" + str(Debug.FogMin) + "     1 + mouse wheel" + chr(10))
        print ("  FogMax=" + str(Debug.FogMax) + "     2 + mouse wheel" + chr(10))
    endif
endfunction

function DebugPath(DebugEnabled as integer, Grid ref as PathGrid[][], GridSize)
	if DebugEnabled
		for x=0 to Grid.length
			for y=0 to Grid[0].length
				TextID=x+y*64
				DeleteText(TextID)
				startx#=GetScreenXFrom3D(x*GridSize,0,y*GridSize)
				starty#=GetScreenYFrom3D(x*GridSize,0,y*GridSize)
				if startx#>GetScreenBoundsLeft() and starty#>GetScreenBoundsTop() and startx#<ScreenWidth() and starty#<ScreenHeight()
					CreateText(TextID,str(Grid[x,y].Number))
					SetTextPosition(TextID,startx#,starty#)
					SetTextSize(TextID,3)
					SetTextAlignment(TextID,1)
					if Grid[x,y].Position.x<>0 or Grid[x,y].Position.y<>0
						endx#=GetScreenXFrom3D(Grid[x,y].Position.x*GridSize,0,Grid[x,y].Position.y*GridSize)
						endy#=GetScreenYFrom3D(Grid[x,y].Position.x*GridSize,0,Grid[x,y].Position.y*GridSize)
						DrawLine(endx#,endy#,startx#,starty#,MakeColor(255,255,255),MakeColor(0,0,255))
					endif
				endif
			next y
		next x
	endif
endfunction
