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
            Debug.FogMin = Debug.FogMin + debug_mousewheel (10.0)
            SetFogRange( Debug.FogMin, Debug.FogMax ) 
        endif
        
        if GetRawKeyState (50)        // 2 is held down
            Debug.FogMax = Debug.FogMax + debug_mousewheel (10.0)
            SetFogRange( Debug.FogMin, Debug.FogMax )
        endif
        
        print ("  DEBUG CONSOLE" + chr(10))
        print ("  FogMode=" + str(Debug.fogEnabled) + "     F3 to toggle")
        print ("  FogMin=" + str(Debug.FogMin) + "     1 + mouse wheel")
        print ("  FogMax=" + str(Debug.FogMax) + "     2 + mouse wheel")
        print ("  PathMode=" + str(Debug.PathEnabled) + "     F4 to toggle")
        print ("  ShaderMode=" + str(Debug.ShaderEnabled) + "     F5 to toggle")
    endif
endfunction

function debug_mousewheel (wheelMultiplier# as float)
	out# as float
	out# = GetRawMouseWheelDelta() * wheelMultiplier# 
	if GetRawKeyState (257) = 1 then out# = out# * 10.0 // left shift is down = increase
	if GetRawKeyState (258) = 1 then out# = out# * 10.0 // right shift is down = increase
	if GetRawKeyState (259) = 1 then out# = out# * 0.1 // left ctrl is down = decrease
	if GetRawKeyState (260) = 1 then out# = out# * 0.1 // left ctrl is down = decrease
endfunction out#

function DebugPath(Debug ref as Debuging, Grid ref as PathGrid[][], GridSize)
	if Debug.Enabled and Debug.PathEnabled
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
	else
		for TextID=0 to Grid.length*Grid[0].length
			DeleteText(TextID)
		next TextID
	endif
endfunction
