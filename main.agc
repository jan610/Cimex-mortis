// Project: Cimex mortis 
// Created: 2019-08-25

// show all errors
SetErrorMode(2)

// set window properties
SetWindowTitle( "Cimex mortis" )
SetWindowSize( 1024, 768, 0 )
SetWindowAllowResize( 1 ) // allow the user to resize the window

// set display properties
SetVirtualResolution( 100, 100 ) // doesn't have to match the window
SetOrientationAllowed( 1, 1, 1, 1 ) // allow both portrait and landscape on mobile devices
SetSyncRate( 0, 0 ) // 30fps instead of 60 to save battery
SetScissor( 0,0,0,0 ) // use the maximum available screen space, no black borders
UseNewDefaultFonts( 1 ) // since version 2.0.22 we can use nicer default fonts

SetShadowMappingMode(3) // built in shadows (for now at least)

SetAntialiasMode(1)
SetDefaultWrapU(1)
SetDefaultWrapV(1)

#include "types.agc"
#include "constants.agc"
#include "functions.agc"

GameState = -1

do
	Select GameState
		case STATE_GAME_INTRO
			GameState=IntroScreen()
		endcase
		case STATE_MAIN_MENU
			GameState=MainMenu()
		endcase
		case STATE_GAME_MENU
			GameState=GameMenu()
		endcase
		case STATE_GAME
			GameState=Game()
		endcase
	endselect
    Sync()
loop

