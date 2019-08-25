

function MainMenu()
	PlayTID=CreateText("Play")
	SetTextSize(PlayTID,12)
	ExitTID=CreateText("Exit")
	SetTextSize(ExitTID,12)
	SetTextPosition(ExitTID,0,12)
	do
		PointerX#=GetPointerX()
		PointerY#=GetPointerY()
		if GetTextHitTest(PlayTID,PointerX#,PointerY#)
			if GetPointerReleased()
				GameState=STATE_GAME
				exit
			endif
		endif
		if GetTextHitTest(ExitTID,PointerX#,PointerY#)
			if GetPointerReleased()
				GameState=-1
				end
			endif
		endif
		sync()
	loop
	DeleteText(PlayTID)
	DeleteText(ExitTID)
endfunction GameState

function GameMenu()
	MainTID=CreateText("Main Menu")
	SetTextSize(MainTID,12)
	do
		PointerX#=GetPointerX()
		PointerY#=GetPointerY()
		if GetTextHitTest(MainTID,PointerX#,PointerY#)
			if GetPointerReleased()
				GameState=STATE_MAIN_MENU
				exit
			endif
		endif
		sync()
	loop
	DeleteText(MainTID)
endfunction GameState

function Game()
	do
		Print( ScreenFPS() )
		
		if GetRawKeyReleased(27)
			GameState=STATE_GAME_MENU
			exit
		endif
		
		Sync()
	loop
endfunction GameState

function CentreTextToSprite(t as integer, s as integer)
	if GetTextAlignment(t) = 0
		SetTextPosition(t,GetSpriteXByOffset(s)-GetTextTotalWidth(t)*0.5,GetSpriteYByOffset(s)-GetTextTotalHeight(t)*0.5)
	elseif GetTextAlignment(t) = 1
		SetTextPosition(t,GetSpriteXByOffset(s),GetSpriteYByOffset(s)-GetTextTotalHeight(t)*0.5)
	else
		SetTextPosition(t,GetSpriteXByOffset(s)+GetTextTotalWidth(t)*0.5,GetSpriteYByOffset(s)-GetTextTotalHeight(t)*0.5)
	endif
endfunction

		
function IntroScreen()
	FadeTween = CreateTweenSprite(1)
	SetTweenSpriteAlpha(FadeTween,0,255,TweenLinear())
	IntroScreenIID = loadimage("Intro_Screen.png")
	IntroScreenSID = CreateSprite(IntroScreenIID)
	SetSpriteSize(IntroScreenSID,ScreenWidth(),ScreenHeight())
	SetSpritePosition(IntroScreenSID,GetScreenBoundsLeft(),GetScreenBoundsTop())
	PlayTweenSprite(FadeTween,IntroScreenSID,0)
	while GetTweenSpritePlaying(FadeTween,IntroScreenSID)
		UpdateTweenSprite(FadeTween,IntroScreenSID,GetFrameTime())
		sync()
	endwhile
	
	while Not GetRawLastKey() and Not GetPointerPressed()
		Sync()
	endwhile
	
	DeleteTween(FadeTween)
	FadeTween = CreateTweenSprite(1)
	SetTweenSpriteAlpha(FadeTween,255,0,TweenLinear())
	PlayTweenSprite(FadeTween,IntroScreenSID,0)
	while GetTweenSpritePlaying(FadeTween,IntroScreenSID)
		UpdateTweenSprite(FadeTween,IntroScreenSID,GetFrameTime())
		sync()
	endwhile
endfunction 0
	
function ScreenWidth()
	result# = GetScreenBoundsRight() - GetScreenBoundsLeft()
endfunction result#

function ScreenHeight()
	result# = GetScreenBoundsBottom() - GetScreenBoundsTop()
endfunction result#
