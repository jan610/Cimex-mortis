
type Voice
	TID			as integer
	InTweenID	as integer
	OutTweenID	as integer
	Text 		as string[]
endtype

function VoicesInit(Voices ref as Voice, FileName$)
	//~ Voices.Text.insert("Inner Voice whispers: Kill them all !")
	//~ Voices.Text.insert("Patient mumbles: Will I survive ?")
	//~ Voices.Text.save(FileName$)
	
	Voices.Text.load(FileName$)
	Voices.TID=CreateText("")
	SetTextAlignment(Voices.TID,1)
	SetTextSize(Voices.TID,7)
	SetTextPosition(Voices.TID,50,GetScreenBoundsBottom()-GetTextSize(Voices.TID))
	Voices.InTweenID=CreateTweenText(1.0)
	SetTweenTextAlpha(Voices.InTweenID,0,255,TweenEaseIn2())
	Voices.OutTweenID=CreateTweenText(1.0)
	SetTweenTextAlpha(Voices.OutTweenID,255,0,TweenEaseOut2())
endfunction

function VoicesUpdate(Voices ref as Voice, VoiceDelay as float)
	Time#=Timer()
	if Time#>VoiceDelay
		VoiceDelay=Time#+random(5,20)
		Index=random(0,Voices.Text.length)
		SetTextString(Voices.TID,Voices.Text[Index])
		PlayTweenText(Voices.InTweenID,Voices.TID,0)
		PlayTweenText(Voices.OutTweenID,Voices.TID,4)
	endif
	UpdateTweenText(Voices.InTweenID,Voices.TID,GetFrameTime())
	UpdateTweenText(Voices.OutTweenID,Voices.TID,GetFrameTime())
endfunction VoiceDelay
