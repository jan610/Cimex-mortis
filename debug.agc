type Debuging
    Enabled        	as integer
    PathEnabled		as integer
    globalLightEnabled		as integer
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
        
        if GetRawKeyPressed (117)    // F6 to toggle global light
            Debug.globalLightEnabled = 1 - Debug.globalLightEnabled
            SetSunActive( Debug.globalLightEnabled ) 
        endif
        

        
        if GetRawKeyState (49)        // 1 is held down
            Debug.FogMin = Debug.FogMin + debug_mousewheel (10.0)
            SetFogRange( Debug.FogMin, Debug.FogMax ) 
        endif
        
        if GetRawKeyState (50)        // 2 is held down
            Debug.FogMax = Debug.FogMax + debug_mousewheel (10.0)
            SetFogRange( Debug.FogMin, Debug.FogMax )
        endif
        
        if GetRawKeyPressed (120)    // F9 to paste hex color into suncolor
			   clipGet$ = GetClipboardText()
			   clipGet$ = ReplaceString( clipGet$, "#", "", -1 ) 
            SetSunColor(Val(Mid(clipGet$,1, 2 ) ,16), Val(Mid(clipGet$,3, 2 ) ,16), Val(Mid(clipGet$,5, 2 ) ,16) ) 
        endif
        
        if GetRawKeyPressed (121)		// F10 to paste hex color into clearcolor
			   clipGet$ = GetClipboardText()
			   clipGet$ = ReplaceString( clipGet$, "#", "", -1 ) 
			   setClearColor(Val(Mid(clipGet$,1, 2 ) ,16), Val(Mid(clipGet$,3, 2 ) ,16), Val(Mid(clipGet$,5, 2 ) ,16) )
		  endif
        
        if GetRawKeyPressed (122)		// F11 to paste hex color into fogcolor
			   clipGet$ = GetClipboardText()
			   clipGet$ = ReplaceString( clipGet$, "#", "", -1 ) 
			   setFogColor(Val(Mid(clipGet$,1, 2 ) ,16), Val(Mid(clipGet$,3, 2 ) ,16), Val(Mid(clipGet$,5, 2 ) ,16) )
		  endif
        
        if GetRawKeyPressed (123)		// F12 to paste hex color into ambientcolor
			   clipGet$ = GetClipboardText()
			   clipGet$ = ReplaceString( clipGet$, "#", "", -1 ) 
			   SetAmbientColor(Val(Mid(clipGet$,1, 2 ) ,16), Val(Mid(clipGet$,3, 2 ) ,16), Val(Mid(clipGet$,5, 2 ) ,16) )
		  endif
        

        print ("  DEBUG CONSOLE" + chr(10))
        print ("  FogMode=" + str(Debug.fogEnabled) + "     F3 to toggle")
        print ("  FogMin=" + str(Debug.FogMin) + "     1 + mouse wheel")
        print ("  FogMax=" + str(Debug.FogMax) + "     2 + mouse wheel")
        print ("  PathMode=" + str(Debug.PathEnabled) + "     F4 to toggle")
        print ("  ShaderMode=" + str(Debug.ShaderEnabled) + "     F5 to toggle")
        print ("  sun=" + str(Debug.globalLightEnabled) + "F6 to toggle")
        print ("  F9 to paste hex color value into suncolor")
        print ("  F10 to paste hex color value into clearcolor")
        print ("  F11 to paste hex color value into fogColor")
        print ("  F12 to paste hex color value into ambientColor")
        print ("  Mouse X: " + str(GetRawMouseX()))
        print ("  Mouse Y: " + str(GetRawMouseY()))
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
				TextID=x+y*48
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
