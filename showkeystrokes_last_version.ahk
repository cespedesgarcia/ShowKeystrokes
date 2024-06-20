; save this text in notepad as UTF-16 LE for "✔" symbol to work when saving settings in advanced settings window
; [up] or [down] or [right] or [left] + [Pause] >>> to pause/unpause script (press [Pause] in the end)
; "Words-Exceptions" are words that are triggering script to stop working for some time. f.e.: you start to type your password, and script will stop working for 5 sec. (eng is no case sensitive, but f.e. cyrillic case sensitive (didn't bother with other than ENG languages))
; for OBS if you want to hook up this script window into your scene sources, OBS might draw a background color in it even though its transparent on your monitor, i suggest you to use "chromakey" in OBS filter in this script window source 
; also, for OBS i suggest you to set here in code "transparency = Off", you will not see any keyboard/mouse input with your eyes on your monitor, but you can hook it up in OBS as window source and it will be shown in OBS
#SingleInstance,Force
CoordMode,Mouse,Screen		; for configuring gui location to work better
#MaxHotkeysPerInterval 200	; for not triggering warning (pressing too much hotkeys) window. because showing mousewheel's implemented via hotkeys (and if you are scrolling way too fast, you may exceed the limit)
#MaxThreadsPerHotkey 2		; to avoid bug. when entering word-exception and immediately opening words-exceptions list(exceptions in tray), active thread for entered word-exception would freeze, so if you would turn off pause mode manually you couldnt enter the same word-excpetion again (comment this line or set to 1 to check what am i talking about: 1. enter word-exception, 2. immediately call for exceptions list from tray, 3. turn off pause mode manually(through tray or "ahk+pause" hotkey), 4. try to type again same word exception from "1.")
Process, Priority, , A		; script process priority - above normal, dont put any higher because it may conflict with some windows processes which have high priority 
SetBatchLines, -1			; The default SetBatchLines value makes your script sleep around 10-15.6 milliseconds every line. Make it -1 to not sleep
SetWinDelay, 0				; Sets the delay that will occur after each windowing command
DllCall("ntdll\ZwSetTimerResolution","Int",5000,"Int",1,"Int*",MyCurrentTimerResolution) ; setting the Windows Timer Resolution to 0.5ms, THIS IS A GLOBAL CHANGE. quitting the program that changes the Timer Resolution will set it back to its normal value automatically
;Keyhistory


; to automatically, right after launching script (OR CHANGING SOME SETTINGS(because changing some settings RELOADS script)), switch keyboard language to, f.e.: English\rus, uncomment any of next line
;changeKeyboardLangTo((InputLocaleID:=DllCall("GetKeyboardLayout", "UInt", 0, "UInt"))!=68748313 ? 0x0419 : 0)  ; check if keyboard layout is RUS(RUS: 68748313), and calling for change to "any language" fucntion if its not RUS(RUS: 68748313). passing parameter is code for the language (RUS: 0x0419)
;changeKeyboardLangTo((InputLocaleID:=DllCall("GetKeyboardLayout", "UInt", 0, "UInt"))!=67699721 ? 0x0409 : 0)  ; check if keyboard layout is ENG(ENG: 67699721), and calling for change to "any language" fucntion if its not ENG(ENG: 67699721). passing parameter is code for the language (ENG: 0x0409)


;[Settings]... MAKE SURE THERE ARE "TAB's" between variables values and comments sections("; "), it is necessary in this block (TAB is the main parameter in rewriteCode() function). OTHERWISE CODE MIGHT NOT WORK PROPERLY
; ***************************
backcolor=00B140			; * (00B140) 000000-FFFFFF background color (also "red" or "yellow" etc. is valid) if you had problems with transparency ttry to avoid black color in first four settings lines
fontcolor=FFFFFF			; (000000) 000000-FFFFFF	font color (fontcolor can be the same color as backcolor, but they will eliminate each other) (also "red" or "yellow" etc. is valid) if you had problems with transparency try to avoid black color in first four settings lines
eliminateColorFromUI=00B140	; * (00B140) 000000-FFFFFF eliminates pixels with specified color from UI in "background" mode (also "red" or "yellow" etc. is valid) if you had problems with transparency try to avoid black color in first four settings lines
fontShadowcolor=000001		; (FFFFFF) 000000-FFFFFF font outline color (also "red" or "yellow" etc. is valid) if you had problems with transparency try to avoid black color in first four settings lines. 000001 because 000000 will be bugged in background mode (translucent)
outlineFont=1				; make font outlined (0-1). increases text flickering (looks more buggy than usual), because there were no default outline method for fonts in AHK, so i implemented a workaround with drawing same symbols as main text, but a little bit shifted to the top/bottom left/right and with another color
fontsize=s14 w700			; font (S)size in pixels and (W)boldness (1-1000 (400 normal, 700 bold)). Default: "s14 w700"
myfont=Segoe UI				; font name ("Segoe UI" default). I prefer Calibri. Courier (Courier New). Fixedsys. Tahoma. Trebuchet MS
transparency=255			; (255) 0-255 or "Off"(specifying "Off" is different than specifying 255 because it may improve performance and reduce usage of system resources) (f.e. while using OBS studio, specifying "off" will remove any of your input from your monitor, but OBS will definetely see it)
statusheight=25				; gui height in pixels
statuswidth=1000			; gui length in pixels
statusx=0					; location horizontal in pixels
statusy=0					; location vertical in pixels
; ***************************
aot=0						; default alwaysontop value (change "+" and "-" before "AlwaysOnTop") (you can also trigger it in windows tray)
moveMode=0					; "0" if you want for ui to be - transparent and clickthrough; "1" if you want to move ui somewhere else (you can also edit it through tray)
backgroundMode=0			; 0-1, background clickthrough mode (you can also trigger it in windows tray)
; ***************************
beep1=400					; 1st beep sound frequency for suspending script when you type your "special" words (search here ctrl+f "BLOCKED WORDS...")
beep2=800					; 2nd beep sound frequency for suspending script when you type your "special" words (search here ctrl+f "BLOCKED WORDS...")
beepLength=50				; beep sound frequency length for suspending script in msec when you type your "special" words (search here ctrl+f "BLOCKED WORDS...")
suspendTimerCntr=5			; how many seconds script suspends after typing your "special" words (in seconds) (search here ctrl+f "BLOCKED WORDS...")
showTooltip=1				; show or not to show tooltip countdown for when exception word was typed
; **********************************************************************************
;mainIcon = %SystemRoot%\System32\InputSystemToastIcon.png							; path to icon when Always On Top enabled only (WINDOWS 10)
;mainIconB = %SystemRoot%\System32\KeyboardSystemToastIcon.png						; default icon
;configureIcon = %SystemRoot%\System32\InputSystemToastIcon.contrast-white.png		; path to icon when Always On Top enabled and Move mode enabled
;configureIconB = %SystemRoot%\System32\KeyboardSystemToastIcon.contrast-white.png	; default icon when Move mode only enabled
; **********************************************************************************
;...[Settings]
;------------------------------------------------------------------- ; temp values for Advanced GUI 
;allSettings := {"statusx=":statusx, "statusy=":statusy, "statusheight=":statusheight, "statuswidth=":statuswidth, "aot=":aot, "moveMode=":moveMode, "backgroundmode=":backgroundmode, "backcolor=":backcolor, "fontcolor=":fontcolor, "eliminateColorFromUI=":eliminateColorFromUI, "fontShadowcolor=":fontShadowcolor,"transparency=":transparency,"outlineFont=":outlineFont} ; for rewritecode()
AdvArray_Default := {backcolor:"00B140", fontcolor:"FFFFFF", eliminateColorFromUI:"00B140", fontShadowcolor:"000001", statusx:"0", statusy:"0", statuswidth:"1000", statusheight:"25", fontsize:"s14 w700", myfont:"Segoe UI", suspendTimerCntr:"5",beepLength:"50",beep2:"800",beep1:"400"} ;, transparency:"255"} ; my default values

AdvArray_Temp := AdvArray_Default.clone()	; make copy of default array to temp array
	for k, v in AdvArray_Temp				; go through every key in cloned temp array
		AdvArray_Temp[k]:=%k%				; and store current values (backcolor, fontcolor etc...) in temp array (to remember what values were declared at the start of the script)
	
for scale_keys, scale_vals in monitor_scaling_values := {"1":"14", "1.25":"16", "1.5":"20", "1.75":"22", "2.0":"24", "2.25":"26", "2.5":"30", "3.0":"34", "3.5":"40"} ; for scaling my main gui in MOVE mode, values to help in math when calculating size of main window while MOVE mode is active	
	if Round(A_ScreenDPI/96, 2)=scale_keys
	{
		cur_scale_K := scale_keys
		cur_scale_V := scale_vals
	}
for scaleFont_keys, scaleFont_vals in font_scaling_values := {"96":"1.34", "120":"1.67", "144":"1.99", "168":"2.32", "192":"2.66", "216":"2.99", "240":"3.32", "288":"3.98", "336":"4.64"} ; for scaling my main gui in MOVE mode, values to help in math when calculating size of main window while MOVE mode is active	
	if (A_ScreenDPI=scaleFont_keys)
		global font_scale_V := scaleFont_vals

global ExceptionsTitle:=" Words - Exceptions"						; exceptions MsgBox title
global ExceptionsTitle1:="Add Word"									; exceptions>"Add Word" InputBox title
global ExceptionsTitle2:="Delete Word"								; exceptions>"Delete Word" InputBox title

;------------------------------------------------------------------- ; temp values for Advanced GUI 
;------------------------------------------------------------------ some global variables for script
global htstrngSrchKeyW:=":B0?*:" 									; variable for searching for hotstrings. first occurance of B0?
;-------------------------------------------------------------------
FileRead linesCtr, %A_ScriptFullPath%								; how many lines in script overall
StringReplace linesCtr, linesCtr, `n, `n, All UseErrorLevel			; how many lines in script overall
global linesCtr := ErrorLevel+1										; how many lines in script overall. +1 because last line doesn't contain "`n" and this symbol ("`n") is how we counting lines in script
;------------------------------------------------------------------- some global variables for script

;Keys...-----------------------------------------------------------------------------------------------check for current language vocabulary is at line: ctrl+f "keyarray_arr:="
keyarray_eng:=	["Tab","CapsLock","LShift","LCtrl","LWin","LAlt","Space","RAlt","AltGr","RWin","AppsKey","RCtrl","RShift","Enter"								; when RAlt is pressed, there is no BUG and "RAlt" is shown (because of english lang?)
			,"PrintScreen","ScrollLock","Pause","CtrlBreak","Insert","Home","PgUp","Delete","End","PgDn","Help","Up","Down","Left","Right"
			,"Browser_Back","Browser_Forward","Browser_Refresh","Browser_Stop","Browser_Search","Browser_Favorites","Browser_Home","Volume_Mute"
			,"Volume_Down","Volume_Up","Media_Next","Media_Prev","Media_Stop","Media_Play_Pause","Launch_Mail","Launch_Media","Launch_App1","Launch_App2"
			,"Escape","F1","F2","F3","F4","F5","F6","F7","F8","F9","F10","F11","F12","F13","F14","F15","F16","F17","F18","F19","F20","F21","F22","F23","F24"
			,"NumLock","Numpad0","Numpad1","Numpad2","Numpad3","Numpad4","Numpad5","Numpad6","Numpad7","Numpad8","Numpad9"
			,"NumpadDiv","NumpadMult","NumpadAdd","NumpadSub","NumpadClear","NumpadDot"
			,"``","Q","W","E","R","T","Y","U","I","O","P","A","S","D","F","G","H","J","K","L","Z","X","C","V","B","N","M"
			,"1","2","3","4","5","6","7","8","9","0","-","=","Backspace","[","]","\",";","'",",",".","/"
			,"LButton","MButton","RButton","WheelUp","WheelDown","XButton1","XButton2"]
			
keyarray_ukr:=	["Tab","CapsLock","LShift","LCtrl","LWin","LAlt","Space","RAlt","AltGr","RWin","AppsKey","RCtrl","RShift","Enter"								; when RAlt is pressed, there is a "bug" - "LCtrl RAlt" is shown
			,"PrintScreen","ScrollLock","Pause","CtrlBreak","Insert","Home","PgUp","Delete","End","PgDn","Help","Up","Down","Left","Right"						; keyboard layout in Windows has an "AltGr" key in place of the RAlt key. AltGr is reported by the OS as a combination of RAlt and LCtrl. When a script or program generates an "RAlt" key-press or release, the OS automatically adds an LCtrl key-press or release which may be indistinguishable from a physical key-press.
			,"Browser_Back","Browser_Forward","Browser_Refresh","Browser_Stop","Browser_Search","Browser_Favorites","Browser_Home","Volume_Mute"
			,"Volume_Down","Volume_Up","Media_Next","Media_Prev","Media_Stop","Media_Play_Pause","Launch_Mail","Launch_Media","Launch_App1","Launch_App2"
			,"Escape","F1","F2","F3","F4","F5","F6","F7","F8","F9","F10","F11","F12","F13","F14","F15","F16","F17","F18","F19","F20","F21","F22","F23","F24"
			,"NumLock","Numpad0","Numpad1","Numpad2","Numpad3","Numpad4","Numpad5","Numpad6","Numpad7","Numpad8","Numpad9"
			,"NumpadDiv","NumpadMult","NumpadAdd","NumpadSub","NumpadClear","NumpadDot"
			,"'","Й","Ц","У","К","Е","Н","Ґ","Ш","Щ","З","Х","Ї","Ф","І","В","А","П","Р","О","Л","Д","Ж","Є","Я","Ч","С","М","И","Т","Ь","Б","Ю"
			,"1","2","3","4","5","6","7","8","9","0","-","=","Backspace","\","."
			,"LButton","MButton","RButton","WheelUp","WheelDown","XButton1","XButton2"]

keyarray_rus:=	["Tab","CapsLock","LShift","LCtrl","LWin","LAlt","Space","RAlt","AltGr","RWin","AppsKey","RCtrl","RShift","Enter"								; when RAlt is pressed, there is a "bug" - "LCtrl RAlt" is shown
			,"PrintScreen","ScrollLock","Pause","CtrlBreak","Insert","Home","PgUp","Delete","End","PgDn","Help","Up","Down","Left","Right"						; keyboard layout in Windows has an "AltGr" key in place of the RAlt key. AltGr is reported by the OS as a combination of RAlt and LCtrl. When a script or program generates an "RAlt" key-press or release, the OS automatically adds an LCtrl key-press or release which may be indistinguishable from a physical key-press.
			,"Browser_Back","Browser_Forward","Browser_Refresh","Browser_Stop","Browser_Search","Browser_Favorites","Browser_Home","Volume_Mute"
			,"Volume_Down","Volume_Up","Media_Next","Media_Prev","Media_Stop","Media_Play_Pause","Launch_Mail","Launch_Media","Launch_App1","Launch_App2"
			,"Escape","F1","F2","F3","F4","F5","F6","F7","F8","F9","F10","F11","F12","F13","F14","F15","F16","F17","F18","F19","F20","F21","F22","F23","F24"
			,"NumLock","Numpad0","Numpad1","Numpad2","Numpad3","Numpad4","Numpad5","Numpad6","Numpad7","Numpad8","Numpad9"
			,"NumpadDiv","NumpadMult","NumpadAdd","NumpadSub","NumpadClear","NumpadDot"
			,"Ё","Й","Ц","У","К","Е","Н","Г","Ш","Щ","З","Х","Ъ","Ф","Ы","В","А","П","Р","О","Л","Д","Ж","Э","Я","Ч","С","М","И","Т","Ь","Б","Ю"
			,"1","2","3","4","5","6","7","8","9","0","-","=","Backspace","\","."
			,"LButton","MButton","RButton","WheelUp","WheelDown","XButton1","XButton2"]
			
;------------------------------------------------------------------------------------------------------
;dblKeys		:= 	["WheelUp WheelUp",	"WheelDown WheelDown"]	; list of double keys that needs correction		; dont need it?
;dblKeys_r	:= 	["WheelUp",			"WheelDown"]			; and their corrected replacement					; dont need it?
;------------------------------------------------------------------------------------------------------
;...Keys-----------------------------------------------------------------------------------------------



Gosub,TRAYMENU_alt 					; my little tray


guistart:							; starting gui (i need this, so when i press tray buttons it will assemble gui from scratch with new location and cosmetics parameters)

	OnMessage(0x201, "WM_LBUTTONDOWN")
	OnMessage(0x0232, "WM_EXITSIZEMOVE")
	OnMessage(0x0231, "WM_ENTERSIZEMOVE")
	
	; https://www.autohotkey.com/board/topic/23969-resizable-window-border/?p=155480
	OnMessage(0x84, "WM_NCHITTEST")
	OnMessage(0x83, "WM_NCCALCSIZE")
	OnMessage(0x86, "WM_NCACTIVATE")  ; to not cause visual bugs on first_gui (comment this line and run script, change main_gui height\width, then activate another window, and you will see visual bug on main GUI (BORDERS))
	;------------------------------------------------------------------------------------------------------------------------
	;keyarray_arr:=((InputLocaleID:=DllCall("GetKeyboardLayout", "UInt", 0, "UInt"))=67699721 ? keyarray_eng : keyarray_rus) ; check if keyboard layout is (67699721 eng) or (68748313 rus), and set main array symbols for script to work with accordingly
	keyarray_arr:=(InputLocaleID:=DllCall("GetKeyboardLayout", "UInt", 0, "UInt"))=67699721 ? keyarray_eng : (InputLocaleID:=DllCall("GetKeyboardLayout", "UInt", 0, "UInt"))=4037542946 ? keyarray_ukr : (InputLocaleID:=DllCall("GetKeyboardLayout", "UInt", 0, "UInt"))=68748313 ? keyarray_rus : keyarray_eng ; check if keyboard layout is (67699721 eng) or (4037542946 ukr) or (68748313 rus), and set main array symbols according to current language, for script to work with. if its not eng\ukr\rus it is set to eng
	
	
	makeUI_MOVE_BACKGROUND()		; check the setting of move mode and background mode, and edit gui options before gui created - accordingly
	iconCheck() 					; checking the state of tray icons to show new icon if needed
	
	;SetTimer, uiMove,% (moveMode=1 ? "1" : "Delete") ; to run subroutine for GUI movement (old method)
	
	SetTimer, main, off 			; turn off main loop to not mess up with gui creation
	;------------------------------------------------------------------------------------------------------------------------
	
	Gui, First_GUI:Destroy							; destroy old gui to create new one with new parameters which we are getting after moving gui by pressing Configure button in tray
	
	aotTemp := (aot=1 ? "+" : "-")
	;https://www.autohotkey.com/boards/viewtopic.php?f=6&t=77668
	Gui, First_GUI:+Owner -Caption %aotTemp%AlwaysOnTop +Resize +E0x02000000 +E0x00080000 Hwndmain_window 			; owner removes taskbar button, aot (always on top variable), caption removes borders. CODES: WS_EX_COMPOSITED & WS_EX_LAYERED => Double Buffer (they doesnt help alot in this case, but in other cases(projects) it does help drastically)
	Gui, First_GUI:Color,%backcolor%
	Gui, First_GUI:Font,C%fontcolor% %fontsize% Q3,%myfont%			; Q3: GUI > FONT > NONANTIALIASED_QUALITY   (to reduce text rendering lag) (Q2 might be better but it has problems with macking some background pixels invisible)
	
	Gui, First_GUI:Add,Text,VtextMain x3 y3 c%fontcolor% -Border BackgroundTrans 			; main text
	Gui, First_GUI:Add,Text,VshadowTextBR x4 y4 c%fontShadowcolor% -Border BackgroundTrans	; Bottom Right text shadow
	Gui, First_GUI:Add,Text,VshadowTextTL x2 y2 c%fontShadowcolor% -Border BackgroundTrans 	; Top Left text shadow
	Gui, First_GUI:Add,Text,VshadowTextTR x4 y2 c%fontShadowcolor% -Border BackgroundTrans 	; Top Right text shadow
	Gui, First_GUI:Add,Text,VshadowTextBL x2 y4 c%fontShadowcolor% -Border BackgroundTrans 	; Bottom Left text shadow
		
	Gui, First_GUI:Show,X%statusx% Y%statusy% W%statuswidth% H%statusheight% NoActivate,%A_ScriptName%
	
	;GuiControl, First_GUI:Text,textMain			; main text								
	;GuiControl, First_GUI:Text,shadowTextBR		; Bottom Right text shadow
	;GuiControl, First_GUI:Text,shadowTextTL		; Top Left text shadow
	;GuiControl, First_GUI:Text,shadowTextTR		; Top Right text shadow
	;GuiControl, First_GUI:Text,shadowTextBL		; Bottom Left text shadow
		
	WinSet,%winsetParamFirst%,%winsetParamSecond%,%A_ScriptName%			
	WinSet,ExStyle,%winsetParamThird%,%A_ScriptName%
	
	;------------------------------------------------------------------------------------------------------------------------
	SetTimer, main, 20	; i choose 20, but also 16 - because "Due to the granularity of the OS's time-keeping system, Period is typically rounded up to the nearest multiple of 10 or 15.6 milliseconds" (it could vary i suppose on different machines)
Return

First_GUIGuiSize(GuiHwnd, eventInfo, width, height) 						; helps resize text boxes in main gui (First_GUI)
{ 
	If (eventInfo != MINIMIZED := 1)
	{
		GuiControl First_GUI:Move, textMain, % "w"width "h"height 
		GuiControl First_GUI:Move, shadowTextBR, % "w"width "h"height
		GuiControl First_GUI:Move, shadowTextTL, % "w"width "h"height
		GuiControl First_GUI:Move, shadowTextTR, % "w"width "h"height
		GuiControl First_GUI:Move, shadowTextBL, % "w"width "h"height
	}
}



main:						; main logic for determening pressed keys (not showing them)
	;tooltip % getKeyboardLang() ; check language
	oldkeys:=keys 
	keys=
	
	;---------------------------------------
	for arr_key, key_val in keyarray_arr	; for each on average 3% faster then loop, at least as i measured
	{
		key:=key_val
		if GetKeyState(key,P)				; if physically (P) current key is pushed. Exception: non english languages (f.e.:UKR\RUS), when RAlt is pressed, it triggers LCtrl also, = RAlt + LCtrl if only RAlt is pressed
			keys=%keys% %key%    		 	; this line lets you merge several pressed buttons
	}
	;---------------------------------------
	
	if (keys!=oldkeys) 						; this line (and further absence of "else" line) will force "main" subroutine(settimer) to not draw keys on gui if they are the same from previous loop (if you are holding same keyboard\mouse keys)
		guiText_Outline(keys,outlineFont)
Return



guiText_Outline(byref keys, byref outlineFont)		; function for outlining or not outlining text
{
	if outlineFont=0
		GuiControl,First_GUI:Text,textMain,%keys%			; send to gui variable "text" - "keys" valueelse if outlineFont=0
	else if outlineFont=1
	{
		GuiControl,First_GUI:Text,textMain,%keys%			; send to gui variable "text" - "keys" value
		GuiControl,First_GUI:Text,shadowTextBR,%keys%		; sending text to bottom right(BR) shadow variable for GUI
		GuiControl,First_GUI:Text,shadowTextTL,%keys%		; sending text to top left(TL) shadow variable for GUI
		GuiControl,First_GUI:Text,shadowTextTR,%keys%		; sending text to top right shadow variable for GUI
		GuiControl,First_GUI:Text,shadowTextBL,%keys%		; sending text to bottom left shadow variable for GUI
	}
	else if outlineFont=2
	{
		GuiControl,First_GUI:Text,textMain,%keys%			; send to gui variable "text" - "keys" value
		GuiControl,First_GUI:Text,shadowTextBR				; if gui is rebuilt after otlineFont value is changed we need to clear what was left from previous input
		GuiControl,First_GUI:Text,shadowTextTL				; if gui is rebuilt after otlineFont value is changed we need to clear what was left from previous input
		GuiControl,First_GUI:Text,shadowTextTR				; if gui is rebuilt after otlineFont value is changed we need to clear what was left from previous input
		GuiControl,First_GUI:Text,shadowTextBL				; if gui is rebuilt after otlineFont value is changed we need to clear what was left from previous input
	}
}
return


;-----------------------------------MouseWheels show.....
~*WheelUp::								; "~" - not blocking keys native functions (if f.e. ctrl+mousewheelUP/DOWN it will zoom in/out)
	SetTimer, WheelCheck, -1			; running the timer 1ms from now then disable the timer
return

~*WheelDown::							; "*" - wild card for mousewheel to work properly with ctrl/shift/alt
	SetTimer, WheelCheck, -1
return

WheelCheck:								; if you dont use settimer here(but f.e. Gosub) it skips mousewheels input, especially if you are doing it very slow (i.e. it would be bugged )

;SetTimer,WheelCheck,Off
StringTrimLeft,wheelVar,A_ThisHotkey,7	; 7 because we ignore 6 symbols in " Wheel"(including space at beginning) and start with 7th symbol
if wheelVar=up
{
	keys.=" WheelUp"
	;Gosub, correction
	correction("WheelUp WheelUp", "WheelUp")
} else if wheelVar=down
{
	keys.=" WheelDown"
	;Gosub, correction	
	correction("WheelDown WheelDown", "WheelDown")
}
return

correction(wheel_search, wheel_replace)
{
	Global
	if keys contains % wheel_search
		StringReplace, keys, keys, % wheel_search,% wheel_replace, All
	guiText_Outline(keys,outlineFont)
}
Return

/* 											dont need it?
correction: 									; for double mousewheels correction in gui
for each_key, each_val in dblKeys
{
	if keys contains % dblKeys[A_Index]
		StringReplace, keys, keys, % dblKeys[A_Index],% dblKeys_r[A_Index], All
	guiText_Outline(keys,outlineFont)
}
return
*/ 											; dont need it?

;-----------------------------------.....MouseWheels show

;-----------------------------------Moving UI OLD..... 
/*
uiMove:																	; this one is for moving the gui... 
MouseGetPos,,,whatClassHover
WinGetClass,isAutoHotkeyGUI,ahk_id %whatClassHover%
GetKeyState,mstate,LButton,P
If (mstate="D" && moveMode=1 && isAutoHotkeyGUI="AutoHotkeyGUI")		; check for autohotkey gui, because i had a bug, when dragging gui in "MOVE" mode very quickly while some msgboxes was opened (i had msgboxes at one point when i was writing a code), script will kinda loose grab of GUI and throw an error
{
	MouseGetPos,mx1,my1,mid
    WinGetTitle,stitle,ahk_id %mid%
    If stitle=%A_ScriptName%
    {
		Loop
		{
			MouseGetPos,mx2,my2
			WinGetPos,sx,sy,,,ahk_id %mid%								; getting gui location to sx and sy
			statusx:=sx-mx1+mx2
			statusy:=sy-my1+my2
			WinMove,ahk_id %mid%,,%statusx%,%statusy% 
			mx1:=mx2
			my1:=my2
			GetKeyState,mstate,LButton,P
			If mstate=U
				Break
		} 
    }
}
Return
*/
;-----------------------------------.....Moving UI OLD 
;-----------------------------------Moving UI NEW..... 

;-----------------------------------.....Moving UI NEW 

TRAYMENU_alt:																	; my Tray		  
Menu, Tray, Tip, % "      Double-Click to Reload`n"+							; tooltip in tray
					+"----------------------------------"+						
					+"`n                   Pause:`n"+
					+"  [Up/Down/Left/Right]+[Pause]"							; tooltip in tray
Menu, Tray, NoStandard															; deletes all standard tray menus
Menu, Tray, Add, Reload, ReloadMenu										; adds menu in tray "Reload script" and calls for "ReloadMenu" label
Menu, Tray, Add, Pause, PauseSCRPT
Menu, Tray, Add 																; separator

Menu, Submenu, Add, Move Mode, SettingsMove	
Menu, Submenu, Add, Background Mode, SettingsBackground
Menu, Submenu, Add, Always On Top, SettingsAOT
Menu, Submenu, Add																; separator
Menu, Submenu, Add, Advanced, SettingsAdvanced									; delete next line to make "Advanced" work in tray
;Menu, Submenu, Disable, Advanced												; this disables Advanced menu
Menu, Tray, Add, Settings, :Submenu

Menu, Tray, Add, Exceptions, ShowExceptions
Menu, Tray, Add 																; separator																; separator
Menu, Tray, Add, Exit, CloseExit		
Menu, Tray, Default, Reload 												; makes "Reload script" menu default choice
Menu, Tray, Click, 2															; you can choose click amount to trigger default tray menu when clicked on tray icon (1-2)
Menu, Submenu, % (aot="1" ? "Check" : "Uncheck"), Always On Top 				; ternary if variable aot="1" = check, else = uncheck
Menu, Submenu, % (moveMode="1" ? "check" : "uncheck"), Move Mode 						
Menu, Submenu, % (backgroundMode="1" ? "Check" : "Uncheck"), Background Mode
Menu, Tray, Uncheck, Pause												; start script with unchecked Pause Script menu in tray
Return									

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; unnecessary
#if GetKeyState("Up") || GetKeyState("Down") || GetKeyState("Left") || GetKeyState("Right") 
	Numpad0::	
	Gosub, SettingsAdvanced
	return
#if

#if GetKeyState("Up") || GetKeyState("Down") || GetKeyState("Left") || GetKeyState("Right") 
	Numpad1::	
	;WinGetPos,mX,mY,mW,mH,ahk_id %main_window%
	;tooltip % mx "-" my "-" mw "-" mh,50,50,6
	;SetTimer, checkid, off
	;SetTimer, checkid, -100
	VarSetCapacity(rect, 16, 0)
	DllCall("GetClientRect", uint, main_window, uint, &rect)	; getting main gui width and height
	wmW := Round((NumGet(rect, 8, "int" )) ) ;/(A_ScreenDPI/96))			; /96 - to fit current screen scaling (100%-350% etc.)
	wmH := Round((NumGet(rect, 12, "int" )) ) ;/(A_ScreenDPI/96))
	WinGetPos, wmX, wmY,w,h,ahk_id %main_window%
	tooltip % A_ScreenDPI "-" Round(A_ScreenDPI/96, 2) "`nstatusx:" statusx " - DLLCALL:" " - WinGetPos:" wmX "`n" "statusy:" statusy " - DLLCALL:" " - WinGetPos:" wmY "`n" "statuswidth:" statuswidth " - DLLCALL:" wmW " - WinGetPos:" w "`n" "statusheight:" statusheight " - DLLCALL:" wmH " - WinGetPos:" h "`n",,,7
	Clipboard := "statusx:" statusx " - DLLCALL:" " - WinGetPos:" wmX "`n" "statusy:" statusy " - DLLCALL:" " - WinGetPos:" wmY "`n" "statuswidth:" statuswidth " - DLLCALL:" wmW " - WinGetPos:" w "`n" "statusheight:" statusheight " - DLLCALL:" wmH " - WinGetPos:" h "`n",,,7
	return
#if

#if GetKeyState("Up") || GetKeyState("Down") || GetKeyState("Left") || GetKeyState("Right") 
	Numpad7::
	Gui, hwinfo:Destroy
	create_hwinfo_gui()
	hwinfo := (hwinfo!=1 ? 1 : 0)
	settimer, hwinfo, % (hwinfo=1 ? "1000" : "Off")
	if hwinfo=0
		Gui, hwinfo:Destroy
	return
#if

checkid()
{
	Gui First_GUI:+Hwndgui_1_id
	Gui Second_GUI:+Hwndgui_2_id
	MouseGetPos,,,guideUnderCursor,classUnderCursor
	tooltip % guideUnderCursor "`n`n" gui_1_id "`n" gui_2_id "`n`n" classUnderCursor
}
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; unnecessary
	

SettingsAdvanced:
	if WinExist("ahk_id" setting_window)
		Gui,Second_GUI:Destroy	

	Gui,Second_GUI:+AlwaysOnTop -Owner +SysMenu Hwndsetting_window ;ToolWindow +Caption			; +owner - not showing in taskbar,toolwindow - removes minimize button, sysmenu? - removes close and minimize buttons
	;_______________________________________________________________________________________
	global setting_window, main_window													   ;|
	; Tooltips for advanced settings window													|
	global save_TT := "Save & Apply only current value"				 									;|
	global restore_TT := "Restore current value that was at the launch without saving"					;|
	global default_TT := "Restore current default value without saving"				   					;|
	global saveALL_TT := "Save & Apply all current values"												;|
	global restoreALL_TT := "Restore all current values that were at the launch (without saving)`n(except Font and Font Size values from 'Choose Font'`nwindow, to restore them - press 'Restore Font' button)"			   ;|
	global defaultALL_TT := "Restore all current default values without saving`n(except Font and Font Size values from 'Choose Font'`nwindow, to restore them - press 'Default Font' button)"				   				   ;|____
	global transparencyHelp_TT := "Default Transparency: 255.`n'0' = 'Off', it turns off main window visually,`nbut it still can be seen in Broadcast Software"	;|__________________________________
	global color_bar_TT := "Press to choose color without saving"			   								;|
	global eliminateColorFromUIhelp_TT := "To make BACKGROUND or TEXT (Font) INVISIBLE,`nthis value must be the same as 'Background or Font Color' value"   ;|
	global defaultfont_TT := "Restore and Save Default: Font (" AdvArray_Default["myfont"] ") and Font Size (" Substr(AdvArray_Default["fontsize"],2,2)"),`nFont Color (" AdvArray_Default["fontcolor"] ") and Outline Font Color (" AdvArray_Default["fontShadowcolor"] ") values"
	global restorefont_TT := "Restore and Save values that were at the launch:`nFont (" AdvArray_Temp["myfont"] ") and Font Size (" Substr(AdvArray_Temp["fontsize"],2,2)"),`nFont Color (" AdvArray_Temp["fontcolor"] ") and Outline Font Color (" AdvArray_Temp["fontShadowcolor"] ")"
	global choosefont_TT := "Choose and Save: Font, Font Size and Font Color values"
	;_______________________________________________________________________________________________________________________________|
	; Move, AOT and Background Modes CheckBoxes                                      		 |
	adv_SettingsAOT := aot="1" ? "+Checked" : "-Checked"									;|
	adv_SettingsBackground := backgroundMode="1" ? "+Checked" : "-Checked"					;|
	adv_SettingsMove := moveMode="1" ? "+Checked" : "-Checked"								;|___
	adv_outlineFont_checkbox_state := outlineFont="1" ? "+Checked" : "-Checked"					;|___________________________________________
	adv_showTooltip_checkbox_state := showTooltip="1" ? "+Checked" : "-Checked"
	; Outline Font
	Gui Second_GUI:Add, CheckBox, x20 y355 w80 h15 -Border gAdvSet vcheckbox_outlinefont %adv_outlineFont_checkbox_state%, Outline Font		;|
	; AOT Mode
	Gui Second_GUI:Add, CheckBox, x25 y15 w95 h15 -Border gSettingsAOT vcheckbox_aot %adv_SettingsAOT%, Always On Top							;|
	; Background Mode
	Gui Second_GUI:Add, CheckBox, x220 y15 w110 h15 -Border gSettingsBackground vcheckbox_backgroundmode %adv_SettingsBackground%, Background Mode	;|
	; Move Mode
	Gui Second_GUI:Add, CheckBox, x130 y15 w75 h15 -Border gSettingsMove vcheckbox_movemode %adv_SettingsMove%, Move Mode ;________________________|
	; Tooltip Timer
	Gui Second_GUI:Add, CheckBox, x25 y610 w80 h15 -Border gAdvSet vcheckbox_showTooltip %adv_showTooltip_checkbox_state%, Tooltip Timer		;|
	;_______________________________________________________________________________________________________________|
	; ALL buttons																		 |
	;_______________________________________________________________________________________________________________|
	;Gui, Second_GUI:Add, Button, x330 y5 w15 h15 gAdvExit -Theme,✖							;|
	;__________________________________________________________________________________________
	Gui, Second_GUI:Add, Button, x10 y655 w100 h15 gAdvSet vsave_all -Theme, Save All				;|
	Gui, Second_GUI:Add, Button, x125 y655 w100 h15 gAdvSet vrestore_all -Theme, All Restore		;|
	Gui, Second_GUI:Add, Button, hWndhGrpGroupbox x240 y655 w100 h15 gAdvSet vdefault_all -Theme, All Default		;|
	;________________________________________________________________________________________|
	;________________________________________________________________________________________|
	Gui, Second_GUI:Add, GroupBox, x15 y95 w320 h230 -Theme, Application and it's Font Colors									;|'__
	; HEX Background Color																		|
	Gui, Second_GUI:Add, Text, x25 y115 w90 h15 -Border, Background Color: 	   		   ;|
	Gui, Second_GUI:Font,s16
	Gui, Second_GUI:Add, Text, x22 y129 w22 h22 c%backcolor% vbackcolor_bar gchoose_color Center -Border,■	
	Gui, Second_GUI:Font
	Gui, Second_GUI:Add, Edit, x50 y135 w45 h15 vbackcolor_edit gUpdateScript Uppercase, %backcolor%  ;|
	Gui, Second_GUI:Add, Text, x105 y135 w13 h13 c00B140 -Border vbackcolor_check ;✔✖				   ;|
	Gui, Second_GUI:Add, Button, x130 y135 w55 h15 gAdvSet vbackcolor_save, Save			   	   ;|
	Gui, Second_GUI:Add, Button, x200 y135 w55 h15 gAdvSet vbackcolor_restore, Restore		   ;|
	Gui, Second_GUI:Add, Button, x270 y135 w55 h15 gAdvSet vbackcolor_default, Default		   ;|
	; Eliminate (Exclude) Color From UI															|____________________________
	Gui, Second_GUI:Add, Text, x25 y170 w160 h15 -Border veliminateColorFromUI_text, Exclude Color From Background:		;|
	Gui, Second_GUI:Add, Button, x190 y170 w13 h13 +Disabled, ?																;|
	Gui, Second_GUI:Font,s16
	Gui, Second_GUI:Add, Text, x22 y184 w22 h22 c%eliminateColorFromUI% veliminateColorFromUI_bar gchoose_color Center -Border,■	
	Gui, Second_GUI:Font
	Gui, Second_GUI:Add, Edit, x50 y190 w45 h15 veliminateColorFromUI_edit gUpdateScript Uppercase, %eliminateColorFromUI%	   	;|
	Gui, Second_GUI:Add, Text, x105 y190 w13 h13 c00B140 -Border veliminateColorFromUI_check ;✔✖ 				 ___________________;|
	Gui, Second_GUI:Add, Button, x130 y190 w55 h15 gAdvSet veliminateColorFromUI_save, Save		   	   ;|
	Gui, Second_GUI:Add, Button, x200 y190 w55 h15 gAdvSet veliminateColorFromUI_restore, Restore	   ;|
	Gui, Second_GUI:Add, Button, x270 y190 w55 h15 gAdvSet veliminateColorFromUI_default, Default 	   ;|	   
	; HEX Font Color																			  ______|
	Gui, Second_GUI:Add, Text, x25 y225 w55 h15 -Border, Font Color: 			  			;|
	Gui, Second_GUI:Font,s16
	Gui, Second_GUI:Add, Text, x22 y239 w22 h22 c%fontcolor% vfontcolor_bar gchoose_color Center -Border,■	
	Gui, Second_GUI:Font
	Gui, Second_GUI:Add, Edit, x50 y245 w45 h15 vfontcolor_edit gUpdateScript Uppercase, %fontcolor%  ;|
	Gui, Second_GUI:Add, Text, x105 y245 w13 h13 c00B140 -Border vfontcolor_check ;✔✖					;|
	Gui, Second_GUI:Add, Button, x130 y245 w55 h15 gAdvSet vfontcolor_save, Save			    ;|
	Gui, Second_GUI:Add, Button, x200 y245 w55 h15 gAdvSet vfontcolor_restore, Restore		    ;|
	Gui, Second_GUI:Add, Button, x270 y245 w55 h15 gAdvSet vfontcolor_default, Default			;|
	; Font Outline Color																		 |
	Gui, Second_GUI:Add, Text, x25 y280 w95 h15 -Border, Font Outline Color: 			;|___________
	Gui, Second_GUI:Font,s16
	Gui, Second_GUI:Add, Text, x22 y294 w22 h22 c%fontShadowcolor% vfontShadowcolor_bar gchoose_color Center -Border,■	
	Gui, Second_GUI:Font
	Gui, Second_GUI:Add, Edit, x50 y300 w45 h15 vfontShadowcolor_edit gUpdateScript Uppercase, %fontShadowcolor%	;|
	Gui, Second_GUI:Add, Text, x105 y300 w13 h13 c00B140 -Border vfontShadowcolor_check ;✔✖ 			  __________;|
	Gui, Second_GUI:Add, Button, x130 y300 w55 h15 gAdvSet vfontShadowcolor_save, Save			;|
	Gui, Second_GUI:Add, Button, x200 y300 w55 h15 gAdvSet vfontShadowcolor_restore, Restore	;|
	Gui, Second_GUI:Add, Button, x270 y300 w55 h15 gAdvSet vfontShadowcolor_default, Default	;|
	;____________________________________________________________________________________________|__________
	; Position. X - Y - WIDTH - HEIGHT : Block																		|
	Gui, Second_GUI:Add, GroupBox, x45 y390 w260 h100 -Theme, Application Main Window Position
	; [X]-axis
	Gui, Second_GUI:Add, Text, x55 y410 w35 h15 -Border, X-axis: 			 								   ;| X.	number - only numbers, center - text located in center
	Gui, Second_GUI:Add, Edit, x55 y425 w50 h15 vstatusx_edit gUpdateScript Number Center,%statusx%			   ;|
	Gui, Second_GUI:Add, UpDown, gUpdateScript Range-2147483648-2147483647 0x80,%statusx%	   ;| 		0x80 omits visual bug, omits thousands space separator  (2 000 instead of 2000)
    ; [Y]-axis																									|
	Gui, Second_GUI:Add, Text, x55 y450 w35 h15 -Border, Y-axis: 											   ;| Y. 
	Gui, Second_GUI:Add, Edit, x55 y465 w50 h15 vstatusy_edit gUpdateScript Number Center,%statusy%			   ;|
	Gui, Second_GUI:Add, UpDown, gUpdateScript Range-2147483648-2147483647 0x80,%statusy%	   ;|
	; [W]idth																									|
	Gui, Second_GUI:Add, Text, x120 y410 w35 h15 -Border, Width: 												   ;| WIDTH.
	Gui, Second_GUI:Add, Edit, x120 y425 w50 h15 vstatuswidth_edit gUpdateScript Number Center,%statuswidth%	   ;|___
	Gui, Second_GUI:Add, UpDown, gUpdateScript Range-2147483648-2147483647 0x80,%statuswidth%  ;|
	; [H]eight																										|
	Gui, Second_GUI:Add, Text, x120 y450 w35 h15 -Border, Height: 											   ;____| HEIGHT.
	Gui, Second_GUI:Add, Edit, x120 y465 w50 h15 vstatusheight_edit gUpdateScript Number Center,%statusheight% ;|________
	Gui, Second_GUI:Add, UpDown, gUpdateScript Range-2147483648-2147483647 0x80, %statusheight%   ;|
	; XYWH - Buttons
	Gui, Second_GUI:Add, Text, x255 y425 w13 h13 c00B140 -Border vpositionstatus_check ;✔✖
	Gui, Second_GUI:Add, Button, x185 y425 w45 h15 gAdvSet vpositionstatus_save, Save			;|
	Gui, Second_GUI:Add, Button, x185 y465 w45 h15 gAdvSet vpositionstatus_restore, Restore	;|
	Gui, Second_GUI:Add, Button, x240 y465 w45 h15 gAdvSet vpositionstatus_default, Default	;|
	;_______________________________________________________________________________________________________|
	; Transparency Slider																				|
	Gui, Second_GUI:Add, Slider, x25 y45 w300 h20 c000000 -Border vtransparency_edit gtransparency_slider TickInterval15 Range0-255 ToolTip AltSubmit, %transparency% ; AltSubmit, ToolTipBottom - for tooltip
	Gui, Second_GUI:Add, Text, x118 y70 w70 h15 -Border, Transparency:												  
	Gui, Second_GUI:Add, Text, x193 y70 w20 h15 -Border vtransparency_text,%transparency%
	Gui, Second_GUI:Add, Button, x218 y70 w13 h13 +Disabled, ?	
	;_______________________________________________________________________________________________________
	; Choose\Restore\Default Font . Settings
	Gui, Second_GUI:Add, GroupBox, x15 y335 w320 h45 -Theme, Font Settings (affects 'Font Colors' boxes) (auto-saves)
	
	Gui, Second_GUI:Add, Button, x110 y355 w70 h15 vchoose_font gchoose_font, Choose Font	
	Gui, Second_GUI:Add, Button, x185 y355 w70 h15 gresdef_font vrestore_font, Restore Font	;|
	Gui, Second_GUI:Add, Button, x260 y355 w70 h15 gresdef_font vdefault_font, Default Font	;|
	;_______________________________________________________________________________________________________
	; Sounds and Tooltips.
	Gui, Second_GUI:Add, GroupBox, x15 y505 w320 h130 -Theme, Sounds and Tooltip for 'Words - Exceptions'
	; Countdown Beep 1
	Gui, Second_GUI:Add, Text, x25 y525 w300 h15 -Border, Starting Beep (freq.) / Final Beep (freq.) / Beep Length (msec.): 			  			;|
	Gui, Second_GUI:Add, Edit, x45 y550 w30 h15 vbeep1_edit gUpdateScript Number Center, %beep1%	;|
	Gui, Second_GUI:Add, Text, x155 y550 w13 h13 c00B140 -Border vbeep_check ;✔✖ 			  __________;|
	Gui, Second_GUI:Add, Button, x175 y550 w40 h15 gAdvSet vbeep_save, Save			;|
	Gui, Second_GUI:Add, Button, x220 y550 w50 h15 gAdvSet vbeep_restore, Restore	;|
	Gui, Second_GUI:Add, Button, x275 y550 w50 h15 gAdvSet vbeep_default, Default	;|
	Gui, Second_GUI:Add, Button, x25 y550 w15 h15 gAdvSet vbeep_test -Theme, ▶			;| test sounds, play button
	; Countdown Beep 2
	Gui, Second_GUI:Add, Edit, x82 y550 w30 h15 vbeep2_edit gUpdateScript Number Center, %beep2%	;|
	; Countdown Beep Length
	Gui, Second_GUI:Add, Edit, x120 y550 w25 h15 vbeepLength_edit gUpdateScript Number Center, %beepLength%	;|
	; Countdown Suspend Timer Counter
	Gui, Second_GUI:Add, Text, x25 y585 w165 h15 -Border, Suspend Timer Duration (in sec.): 			  			;|
	Gui, Second_GUI:Add, Edit, x115 y610 w30 h15 vsuspendTimerCntr_edit gUpdateScript Number Center, %suspendTimerCntr%	;|
	Gui, Second_GUI:Add, Text, x155 y610 w13 h13 c00B140 -Border vsuspendTimerCntr_check ;✔✖ 			  __________;|
	Gui, Second_GUI:Add, Button, x175 y610 w40 h15 gAdvSet vsuspendTimerCntr_save, Save			;|
	Gui, Second_GUI:Add, Button, x220 y610 w50 h15 gAdvSet vsuspendTimerCntr_restore, Restore	;|
	Gui, Second_GUI:Add, Button, x275 y610 w50 h15 gAdvSet vsuspendTimerCntr_default, Default	;|

	;Gui, Second_GUI:Add, StatusBar,, by pcg ; status bar
		
	Gui, Second_GUI:Add, GroupBox, x-10 y-10 w500 h1000			 ; so tips work properly, without this line "saveall restoreall defaultall" buttons are bugged
	Gui, Second_GUI:Show, w350 h690,Advanced Settings 
	
	Gui, Submit, NoHide 			; because had some bugs with tooltips, may cause new bugs idk
	
	OnMessage(0x200, "WM_MOUSEMOVE")	
return
;_________________________________________________________

choose_color:
	StringSplit, split_to_colorChoose, A_GuiControl, "_"	
	Select_Color(null, getNewColor) ; null = nothing, we can set "setting_window" instead, but tooltip will be bugged
	if getNewColor!=
		if getNewColor=0				; visual bug, pure black color (000000 \ 00000 \ ... \ 0) becomes transparent in background mode, so we change it to 000001 !!!!!!!!!!!!!!!!!!!!!!! write about that<<<<
			getNewColor:="000001"
		GuiControl,, %split_to_colorChoose1%_edit, %getNewColor%
return

choose_font:
	GuiControl, Second_GUI:, fontcolor_check,		; cleaning checkmarks
	GuiControl, Second_GUI:, fontshadowcolor_check,	;
	
	new_fontsize:=fontsize
	new_font:=myfont 						; for choose font window not to start with blank font but with current font
	;new_fontcolor:="0x" . fontcolor		; for choose font window not to start with black font color but with current font color. adding 0x is for select_font function, specifically for color part of fucntion
	new_fontcolor:="0x" . fontcolor_edit	; to work with fontcolor from edit box, rather than with color from variable (otherwise it might cause some unintuitive processes during 'choose font' window work)
	
	Select_font(null,new_fontsize,new_font,new_fontcolor) 			; null = nothing ?
	StringTrimLeft, new_fontcolor, new_fontcolor, 2 				; to make color value suitable for our main gui (FFFFFF instead of 0xFFFFFF)
	
	if ((new_font=myfont && new_fontsize=fontsize && new_fontcolor=fontcolor) || (StrLen(new_fontcolor)!=6)) ; if we press cancel in choose font window, we do nothing further
		return
	
	if new_fontsize!=						
		global fontsize:=new_fontsize
	if new_font!=
		global myfont:=new_font
	if new_fontcolor!=
	{
		if new_fontcolor=0				; visual bug, pure black color (000000 \ 00000 \ ... \ 0) becomes transparent in background mode, so we change it to 000001 !!!!!!!!!!!!!!!!!!!!!!! write about that<<<<
			new_fontcolor:="000001"
		GuiControl,, fontcolor_edit, %new_fontcolor%
		global fontcolor:="" . new_fontcolor ; concatenating blank string to make fontcolor value STRING type
	}
	UpdateScript()
	if new_fontcolor!=								; if there is new font color (i.e. we pressed OK in choose font window) we checking the checkmark to show that we saved new font setting
	{
		soundbeep % 500, 50
		save_check_mark("choosefont")				; this three lines are here because previous function UpdateScript() is resetting all checkmarks	
	}
	rewriteCode({"fontsize=":fontsize,"myfont=":myfont,"fontcolor=":fontcolor})
return

resdef_font:
	if InStr(a_guicontrol, "restore")		; check what button is pressed ('restore font' or 'default font')
		currentAA:="AdvArray_Temp"			
	else if InStr(a_guicontrol, "default")	; check what button is pressed ('restore font' or 'default font')
		currentAA:="AdvArray_Default"
	
	GuiControl, , fontcolor_edit, % %currentAA%["fontcolor"]				; putting into edit boxes values from default array or temp (restore) array
	GuiControl, , fontShadowcolor_edit, % %currentAA%["fontShadowcolor"]
	global fontsize:=%currentAA%["fontsize"]								; putting values into global variables to rewrite script code and draw script gui correctly
	global myfont:=%currentAA%["myfont"]
	global fontcolor:=%currentAA%["fontcolor"]
	global fontShadowcolor:=%currentAA%["fontShadowcolor"]
	
	UpdateScript()
	soundbeep % 500, 50
	save_check_mark("restore_default_font")
	rewriteCode({"fontsize=":fontsize,"myfont=":myfont,"fontcolor=":fontcolor,"fontShadowcolor=":fontShadowcolor})
return

transparency_slider:
	GuiControlGet, AdvTransparency_slider,, transparency_edit
	if %a_guicontrol%=0
	{
		GuiControl, Second_GUI:Text, transparency_text ,Off	; 0 = Off, because it may improve performance and reduce usage of system resources
		global transparency = "Off"
	}
	else
	{
		GuiControl, Second_GUI:Text, transparency_text ,%AdvTransparency_slider%
		global transparency = %a_guicontrol%
	}
	UpdateScript()
	rewriteCode({"transparency=":transparency})
return


WM_ENTERSIZEMOVE() {
	Global
	MouseGetPos,,,check_hwnd_ENTERSIZEMOVE
	if (check_hwnd_ENTERSIZEMOVE=main_window) ; only resizing main window
		SetTimer, check_XYWH_settings, 20
}
WM_EXITSIZEMOVE() {
	Global
	MouseGetPos,,,check_hwnd_EXITSIZEMOVE
	if (check_hwnd_EXITSIZEMOVE=setting_window) ; not to interact with setting window
		return
	SetTimer, check_XYWH_settings, -1
	;tooltip % statusx " - " statusy,100,100,3
	rewriteCode({"statusx=":statusx,"statusy=":statusy,"statuswidth=":statuswidth,"statusheight=":statusheight}) ;,"outlineFont=":outlineFont}) ; let it rewrite here, because when settings window is off it must be saved somehow
	save_check_mark("statusx") ; you can choose  statusy or statuswidth\statusheight, it doesnt matter because checkmark is for the whole "script position" block
}

WM_LBUTTONDOWN() {
	MouseGetPos,,,check_hwnd_lbuttondown
	static change_cursor := DllCall("LoadCursor", "Uint", 0, "Int", 32646, "Ptr") ; SizeAll = 32646 (cursor changed)
	if (check_hwnd_lbuttondown = main_window || check_hwnd_lbuttondown = hwinfo_window) {
		PostMessage, 0xA1, 2 
		DllCall("SetCursor", "ptr", change_cursor)	
	}
}

UpdateScript()
{
	Global
	Gui, Submit, NoHide
	clean_check_mark()
	
	Loop, Parse, % "statusx_edit,statusy_edit,statuswidth_edit,statusheight_edit,backcolor_edit,eliminateColorFromUI_edit,fontcolor_edit,fontShadowcolor_edit,suspendTimerCntr_edit,beepLength_edit,beep2_edit,beep1_edit", `,  
		if (%A_LoopField%="")											; if we "backspace" (delete whole line) from edit boxes (in advanced setting window), they will be blank which will cause error, so we replace Blank value with 0 instead
			GuiControl, Second_GUI:, %A_LoopField%, % %A_LoopField%:=0	
	;if fontcolor_edit=0					; visual bug in background mode, if variable is 0 or 00 or ... 000000 it wil be transparent, so we change it internally to 000001
	;	GuiControl, Second_GUI:,fontcolor_edit,000001
	;if fontShadowcolor_edit=0			; same visual bug
	;	GuiControl, Second_GUI:,fontShadowcolor_edit,000001
		
	gui_for_visualTest()
}
return

check_XYWH_settings: 
	if GetKeyState("LButton", "P") && (moveMode=1)
	{
		WinGetPos, xywhX, xywhY, xywhW, xywhH, ahk_id %main_window%
		xywhW_v:=Round((xywhW-cur_scale_V)/cur_scale_K)
		xywhH_v:=Round((xywhH-cur_scale_V)/cur_scale_K)
		if ( WinExist("ahk_id" setting_window) && ( (statusx_edit!=xywhX) || (statusy_edit!=xywhY) || (statuswidth_edit!=xywhW_v) || (statusheight_edit!=xywhH_v) ) )
		{
			;tooltip % "X-axis: " xywhX "`nY-axis: " xywhY "`nWidth: " xywhW_v "`nHeight: " xywhH_v,100,100,3
			GuiControl, Second_GUI:, statusx_edit, %xywhX%
			GuiControl, Second_GUI:, statusy_edit, %xywhY%
			GuiControl, Second_GUI:, statuswidth_edit, %xywhW_v%
			GuiControl, Second_GUI:, statusheight_edit, %xywhH_v%
		}	
		statusx:=xywhX, statusy:=xywhY,statuswidth:=xywhW_v,statusheight:=xywhH_v
	} 
return

gui_for_visualTest()
{
	Global

	if (a_guicontrol="choose_font" || A_GuiControl="restore_font" || A_GuiControl="default_font") ; *fontbug*. there is bug, when we change font size, we need to recreate control because font size is changed, but control still shows old size text. so in the end, we have big font, but it is cutted to the size of old control	
		Gui, First_GUI:Destroy

	StringSplit, split_for_paint, A_GuiControl, "_"	; all this block is to paint text bars (color squares)
	GuiControlGet, value_for_paint,, %A_GuiControl%
	Gui, Font, c%value_for_paint% s16
	GuiControl, Font, %split_for_paint1%_bar
	Gui, Font
	;GuiControl, +c%value_for_paint%, %split_for_paint1%_bar ;this is for progressbar in case those colored text squares somehow\somewhat wouldnt work on other pcs (because of UTF-16 LE coding)

	aotTemp := (aot=1 ? "+" : "-")
	Gui, First_GUI:+Owner -Caption %aotTemp%AlwaysOnTop +Resize +E0x02000000 +E0x00080000 Hwndmain_window ; 
	Gui, First_GUI:Color,%backcolor_edit%
	Gui, First_GUI:Font,C%fontcolor_edit% %fontsize% Q3,%myfont%
	GuiControl, First_GUI:Font, textMain
	
	Gui, First_GUI:Font, c%fontShadowcolor_edit% %fontsize% Q3,%myfont%
	GuiControl, First_GUI:Font, shadowTextBR
	GuiControl, First_GUI:Font, shadowTextTL
	GuiControl, First_GUI:Font, shadowTextTR
	GuiControl, First_GUI:Font, shadowTextBL	
	
	if (a_guicontrol="choose_font" || A_GuiControl="restore_font" || A_GuiControl="default_font") ; continuation of repairing font size bug *fontbug*
	{	
		Gui, First_GUI:Add,Text,VtextMain x3 y3 c%fontcolor_edit% w%statuswidth% h%statusheight% -Border BackgroundTrans 			;,WWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW 
		Gui, First_GUI:Add,Text,VshadowTextBR x4 y4 c%fontShadowcolor_edit% w%statuswidth% h%statusheight% -Border BackgroundTrans ;,WWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW		
		Gui, First_GUI:Add,Text,VshadowTextTL x2 y2 c%fontShadowcolor_edit% w%statuswidth% h%statusheight% -Border BackgroundTrans ;,WWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW		
		Gui, First_GUI:Add,Text,VshadowTextTR x4 y2 c%fontShadowcolor_edit% w%statuswidth% h%statusheight% -Border BackgroundTrans ;,WWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW		
		Gui, First_GUI:Add,Text,VshadowTextBL x2 y4 c%fontShadowcolor_edit% w%statuswidth% h%statusheight% -Border BackgroundTrans ;,WWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW	
		;GuiControl, First_GUI:Text,textMain		; to clean text control from "WWWWWW..." we dont need it anymore due to 'GuiSize('
		;GuiControl, First_GUI:Text,shadowTextBR
		;GuiControl, First_GUI:Text,shadowTextTL
		;GuiControl, First_GUI:Text,shadowTextTR
		;GuiControl, First_GUI:Text,shadowTextBL
	}	
	
	Gui, First_GUI:Show, NoActivate x%statusx_edit% y%statusy_edit% w%statuswidth_edit% h%statusheight_edit%, %A_ScriptName%
	
	WinSet,%winsetParamFirst%,% moveMode=1 ? transparency_edit : (moveMode=0 && backgroundMode=0) ? eliminateColorFromUI_edit " " transparency_edit : (moveMode=0 && backgroundMode=1) ? zxc " " transparency_edit : transparency_edit,%A_ScriptName%
	WinSet,ExStyle,%winsetParamThird%,%A_ScriptName%

	if (PauseSCRPT_Var=1)
	{
		if (outlineFont=1)
		{
			GuiControl,First_GUI:Text,textMain,Paused . . .				; send to gui variable "text" - "keys" value	
			GuiControl,First_GUI:Text,shadowTextBR,Paused . . .			; sending text to bottom right(BR) shadow variable for GUI
			GuiControl,First_GUI:Text,shadowTextTL,Paused . . .			; sending text to top left(TL) shadow variable for GUI
			GuiControl,First_GUI:Text,shadowTextTR,Paused . . .			; sending text to top right shadow variable for GUI
			GuiControl,First_GUI:Text,shadowTextBL,Paused . . .			; sending text to bottom left shadow variable for GUI
		}
		else if (outlineFont!=1)
		{
			GuiControl,First_GUI:Text,textMain,Paused . . .			; send to gui variable "text" - "keys" value
			GuiControl,First_GUI:Text,shadowTextBR					; if gui is rebuilt after otlineFont value is changed, you dont need this lines
			GuiControl,First_GUI:Text,shadowTextTL					; if gui is rebuilt after otlineFont value is changed, you dont need this lines
			GuiControl,First_GUI:Text,shadowTextTR					; if gui is rebuilt after otlineFont value is changed, you dont need this lines
			GuiControl,First_GUI:Text,shadowTextBL					; if gui is rebuilt after otlineFont value is changed, you dont need this lines
		}
	}

	;SB_SetText("x:"statusx "   y:" statusy "   w:" statuswidth "   h:" statusheight) ; status bar
}
return

;_________________________________________________________

AdvSet:																						; instead of creating Gosub for every button (cause there would be too many of them) to do smth, when button in advanced setting window is pressed, this function will do stuff depending on what button was pressed
	Gui, Submit, NoHide		; !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! had bug, play sound in advanced setting window button, its tooltip, didnt show values from first\second beep and beep length sometimes. may cause bugs idk, didnt encounter them
	StringSplit, AdvSet_split_array, A_GuiControl, "_"										; checking last pressed button variable (in advanced setting window). it looks smth like "fontcolor_save"
	
	if InStr(AdvSet_split_array1,"beep")		; beep sound(test)\save\restore\default buttons
	{
		if (AdvSet_split_array2="test")			; if test beep sound is pressed
		{
			soundbeep %beep1_edit%, %beepLength_edit%
			sleep 200
			soundbeep %beep2_edit%, %beepLength_edit%
			return
		} else if (AdvSet_split_array2="save")
		{
			Loop, Parse, % "beep1,beep2,beepLength", `,
			{
				GuiControlGet, %A_LoopField%,, %A_LoopField%_edit					; get value from edit box and store it in variable (f.e.: fontcolor)
				rewriteCode({A_LoopField "=" : %A_LoopField%})
			} 
			save_check_mark("beep")
			soundbeep % 500, 50
			return
		} else if ((AdvSet_split_array2="restore") || (AdvSet_split_array2="default"))
		{
			Loop, Parse, % "beep1,beep2,beepLength", `,
			{
				for key_restore_deafult_beep, val_restore_deafult_beep in AdvArray_Default	
				{
					if ((key_restore_deafult_beep = A_LoopField) && (AdvSet_split_array2="restore"))
						GuiControl, , %A_LoopField%_edit, % AdvArray_Temp[key_restore_deafult_beep]
					else if ((key_restore_deafult_beep = A_LoopField) && (AdvSet_split_array2="default"))
						GuiControl, , %A_LoopField%_edit, % AdvArray_Default[key_restore_deafult_beep]	
				}
			}
			return
		}
	}	
	if (AdvSet_split_array2="showTooltip") && (AdvSet_split_array1!="positionstatus") 		; tooltip timer checkbox
	{
		showTooltip := showTooltip=1 ? 0 : 1												; change showTooltip value	
		rewriteCode({"showTooltip=":showTooltip})
		return
	}
	if (AdvSet_split_array2="outlinefont") && (AdvSet_split_array1!="positionstatus") 														
	{
		outlineFont := outlineFont=1 ? 2 : 1												; change outlineFont value	
		UpdateScript() ; for outlinefont checkbox in pause mode to work while setting window is ON
		rewriteCode({"outlineFont=":outlinefont})
		return
	}
	if (AdvSet_split_array2="save") && (AdvSet_split_array1!="positionstatus") && (AdvSet_split_array1!="beep")														; if variables second part is "save" 																; if variables second part is "save" 		
	{ 
		GuiControlGet, %AdvSet_split_array1%,, %AdvSet_split_array1%_edit					; get value from edit box and store it in variable (f.e.: fontcolor)
		save_check_mark(AdvSet_split_array1)
		rewriteCode({AdvSet_split_array1 "=" : %AdvSet_split_array1%}) 
		soundbeep % 500, 50
		return
	}
	if (AdvSet_split_array2="restore") && (AdvSet_split_array1!="positionstatus") && (AdvSet_split_array1!="beep")	 														; if variables second part is "restore"													; if variables second part is "restore"
	{
		for kr, vr in AdvArray_Temp															; go through temp array, where we stored at the beginning of script current values of all main variables
			if (kr = AdvSet_split_array1)													; if first part of variable name from pressed button in advanced setting window is equal to any key in array
				GuiControl, , %AdvSet_split_array1%_edit, % AdvArray_Temp[kr]				; get value accordingly to key and store it in edit box
		return
	}
	if (AdvSet_split_array2="default") && (AdvSet_split_array1!="positionstatus") && (AdvSet_split_array1!="beep")															; if variables second part is "default"														; if variables second part is "default"
	{
		GuiControl, , %AdvSet_split_array1%_edit, % AdvArray_Default[AdvSet_split_array1]	; get value accordingly to pressed button in advanced setting window from default array that we created at beginning of script and store it in edit box
		return
	}
	if (AdvSet_split_array1="Save" && AdvSet_split_array2="all")							; if "save all" button pressed in advanced setting window
	{
		for ksa, vsa in AdvArray_Default														; go through default array (that we created at start of the script) just to get all keys names (variables needed for script functioning)
		{
			if (("" . ksa="fontsize") || ("" . ksa="myfont"))									; not to write blank values into fontsize and myfont variable. "" . ksa - means that we make ksa STRING type
				Continue
				
			GuiControlGet, %ksa%,, %ksa%_edit													; store into all main variables values from all edit boxes
			if (ksa="beep1" || ksa="beep2" || ksa="beeplength")
				save_check_mark("beep")
			else 
				save_check_mark(ksa)
			;gui_rewrite_ifpause({ksa "=" : %ksa%})
		}
		rewriteCode({"statusx=":statusx, "statusy=":statusy, "statusheight=":statusheight, "statuswidth=":statuswidth, "backcolor=":backcolor, "fontcolor=":fontcolor, "eliminateColorFromUI=":eliminateColorFromUI, "fontShadowcolor=":fontShadowcolor, "suspendTimerCntr=":suspendTimerCntr, "beepLength=":beepLength, "beep2=":beep2, "beep1=":beep1})
		soundbeep % 500, 50
		return
	}
	if (AdvSet_split_array1="Default" && AdvSet_split_array2="all")							; if "all default" button pressed in advanced setting window
	{
		for kda, vda in AdvArray_Default														; go through default array (that we created at start of the script) just to get all keys names (variables needed for script functioning)
			GuiControl, , %kda%_edit, %vda%														; store in all edit boxes values from default array (that we created at start of the script)
		;gosub, resdef_font
		;GuiControl, Second_GUI:, transparency_text,% AdvArray_Default["transparency"]											; just so transparency slider text also changed to default
		;gosub, default_font
		return
	}
	if (AdvSet_split_array1="Restore" && AdvSet_split_array2="all")							; if "restore all" button pressed in advanced setting window
	{
		for kra, vra in AdvArray_Temp															; go through temp array (that we created at start of the script) just to get all values (values that script had from launch)
			GuiControl, , %kra%_edit, %vra%														; store in all edit boxes values from temp array (that we created at start of the script)
		;gosub, resdef_font
		;GuiControl, Second_GUI:, transparency_text, % AdvArray_Temp["transparency"]				; just so transparency slider text also changed to restored value
		;transparency := AdvArray_Temp["transparency"]											; so when we exit setting window it will surely save the value (because we didnt drag it by our hands in previous line it didnt save to main variable)
		;rewriteCode({"transparency=":transparency})
		return
	}
	if (AdvSet_split_array1="positionstatus") && (AdvSet_split_array2="save") 												; script position block (x-y-w-h)
	{
		parsing_values("save_positionstatus")	
		save_check_mark(AdvSet_split_array1)
		rewriteCode({"statusx=":statusx,"statusy=":statusy,"statuswidth=":statuswidth,"statusheight=":statusheight}) ;,"transparency=":transparency, "outlineFont=":outlineFont})
		soundbeep % 500, 50
		return
	}
	if (AdvSet_split_array1="positionstatus") && (AdvSet_split_array2="restore") 												; script position block (x-y-w-h)
	{
		parsing_values("restore_positionstatus")
		return
	}
	if (AdvSet_split_array1="positionstatus") && (AdvSet_split_array2="default") 
	{
		parsing_values("default_positionstatus")
		return
	}
return

;_____________________________________________	
save_check_mark(cmark_val)
{
	Global
	if WinExist("ahk_id" setting_window)
		if (cmark_val="statusx" || cmark_val="statusy" || cmark_val="statuswidth" || cmark_val="statusheight") ; || cmark_val="positionstatus")
		{
			GuiControl, Second_GUI:, positionstatus_check,✔			; if cmark_val=x-y-w-h -> only change one checkmark (one thaat represents script position block)
			return
		}
		else if (cmark_val="choosefont")
		{
			GuiControl, Second_GUI:, fontcolor_check,✔
			return
		}
		else if (cmark_val="restore_default_font")
		{
			GuiControl, Second_GUI:, fontcolor_check,✔
			GuiControl, Second_GUI:, fontshadowcolor_check,✔
			return
		}
		else 
			GuiControl, Second_GUI:, %cmark_val%_check,✔
}
return

clean_check_mark()
{
	Global
	edit_clean_arr1:= 		; clean so it won't store(save) in itself previous values from previous calls
	StringSplit, edit_clean_arr, A_GuiControl, "_"
	if WinExist("ahk_id" setting_window)
		if (edit_clean_arr1="statusx" || edit_clean_arr1="statusy" || edit_clean_arr1="statuswidth" || edit_clean_arr1="statusheight")
			GuiControl, Second_GUI:, positionstatus_check,	; clean position status check_mark
		else if (edit_clean_arr1="beep1" || edit_clean_arr1="beep2" || edit_clean_arr1="beepLength")
			GuiControl, Second_GUI:, beep_check,			; clean beep status check_mark
		else
			GuiControl, Second_GUI:, %edit_clean_arr1%_check,
}
return

parsing_values(parse_mode)						; working with values from edit boxes in advanced setting window (restoring them, resetting to default values, restoring and saving) 
{												; for when you manually enter values in edit boxes and then click on checkboxes, main ui redraws and resets its position and colors to previous(saved) values but in setting window ui in edit boxes values do not corresponds with where ui located. and we need for those values to be the same as current redrawn main ui
	Global
	;if (what_to_parse="position")
	Loop, Parse, % "statusx,statusy,statuswidth,statusheight", `,	
		if (parse_mode="save_positionstatus")
			GuiControlGet, %A_LoopField%,, %A_LoopField%_edit
		else if (parse_mode="restore_positionstatus") 
			GuiControl, ,%A_LoopField%_edit, % AdvArray_Temp[A_LoopField]	
		else if (parse_mode="default_positionstatus") 
			GuiControl, ,%A_LoopField%_edit, % AdvArray_Default[A_LoopField]
	;else if (what_to_parse="all")
	;	Loop, Parse, % "statusx,statusy,statuswidth,statusheight,backcolor,eliminateColorFromUI,fontcolor,fontShadowcolor", `,
	;		if (parse_mode="reset")	; if you press checkboxes(or slider) while edit box values in advanced setting window are changed but not saved, gui position will reset to its saved values and this 2 lines will synchronize x-y-w-h edit boxes in setting window with current (saved) values 
	;			GuiControl, ,%A_LoopField%_edit, % %A_LoopField%
}
return

;_____________________________________________

WM_MOUSEMOVE() {												; tooltips for buttons and controls in gui
	Global
	MouseGetPos,,,mousemove_win,help_buttons_wm
	;coordmode, tooltip, screen
	;ToolTip , % a_guicontrol "`n" mousemove_win "`n" help_buttons_wm, 500, 500, 4
	if ( (mousemove_win=setting_window) && ( (InStr(help_buttons_wm, "button")) || (InStr(A_GuiControl, "_bar")) ) ) ; ;if cursor is above setting window and above any button control or slider. this is for not to trigger "disptip:" all the time, but only when above controls with tips.
	{	
		Static CurrControl, PrevControl	 							; to remember values between calls?
		mousemove_split_array := StrSplit(A_GuiControl,"_")

		CurrControl := A_GuiControl
		GuiControlGet, help_buttons_check_wm,,%help_buttons_wm%

		if ((CurrControl!=PrevControl || help_buttons_check_wm!="?") && !(InStr(help_buttons_wm, "button9") || InStr(help_buttons_wm, "button23") || InStr(help_buttons_wm, "button32") || InStr(help_buttons_wm, "button40") || InStr(help_buttons_wm, "button28")))		; or text from mouse hover control doesnt equal "?" (which is help button). exception buttonXX controls (group boxes) 
			SetTimer, DispTip, -500
		else if ((CurrControl!=PrevControl || help_buttons_check_wm="?") && !(InStr(help_buttons_wm, "button9") || InStr(help_buttons_wm, "button23") || InStr(help_buttons_wm, "button32") || InStr(help_buttons_wm, "button40") || InStr(help_buttons_wm, "button28")))	; or text from mouse hover control equals "?" (which is help button). exception buttonXX controls (group boxes) 
			SetTimer, DispTip, -1
		if (CurrControl = "" && help_buttons_check_wm!="?")				; if current mouse hover control is absent (you are not hovering any control) and (if you hover "help" button, which is disabled, you got no control infromation about it, its blank, but! you can get info about its disabled button text, which is "?") disabled button you might be hovering doesnt have "?" text
			tooltip 													; to remove tooltip when cursor is not hovering
		PrevControl := CurrControl
	}
}
return

DispTip:		; display tips in advanced settings gui
	MouseGetPos,,,,help_buttons_dt,0
	;coordmode, tooltip, screen
	;tooltip % mousemove_split_array[1] "`n" mousemove_split_array[2] "`n" a_guicontrol "`n" help_buttons_dt,300,300,3
	Loop, Parse, % "save,restore,default,help,choose", `,  ; choose for choose font button
	{
		if (!InStr(CurrControl, " ") && (mousemove_split_array[2]=A_LoopField))				; InStr - not to mess with objects in gui that has SPACES in their names (they cause bugs) (spaces can be present when gui object doesnt have its variable, if it doesn't have variable it will show as variable objects visual name in gui (f.e. if button called "move mode" its variable would be shown as "move mode"))		
			tooltip % %A_LoopField%_TT														; common buttons (save\restore\default) tooltips
		else if (!InStr(CurrControl, " ") && (mousemove_split_array[2]="all") && (mousemove_split_array[1]=A_LoopField))	; save\restore\default -ALL buttons tootlips
			tooltip % %A_LoopField%ALL_TT
		else if (!InStr(CurrControl, " ") && (help_buttons_dt="button13"))			; help disabled button tooltip for (exclude color from background). we need to set here button number because button is disabled and its variable is not visible for script 
			tooltip % eliminateColorFromUIhelp_TT   
		else if (!InStr(CurrControl, " ") && (help_buttons_dt="button27"))			; transparency slider help button
			tooltip % transparencyHelp_TT
		else if (!InStr(CurrControl, " ") && (mousemove_split_array[2]="bar"))		; color bars
			tooltip % color_bar_TT
		else if (!InStr(CurrControl, " ") && (mousemove_split_array[1]=A_LoopField) && (mousemove_split_array[2]="font"))		; choose\restore\default font buttons
			tooltip % %A_LoopField%font_TT
		else if (!InStr(CurrControl, " ") && (InStr(mousemove_split_array[1], "beep")) && (mousemove_split_array[2]="test"))		; test beep sounds
			tooltip % "Press to test-play Beep sounds frequencies (" beep1_edit " and " beep2_edit ") for " beepLength_edit " milliseconds each"	
	}
return

;AdvExit:
Second_GUIGuiClose:
	Gui,Second_GUI:Destroy	; exiting only from advanced settings window
	;outlineFont := (outlineFont=1 ? 1 : 0) ; fix for the outlinefont test mode in setting window checkbox (dont bother understanding)
	
	if (PauseSCRPT_Var=1)			; if you turn off setting window while pause is on you are closing(hiding) the main ui
		Gui, First_GUI:Hide
		
	gui_rewrite_ifpause({"statusx=":statusx, "statusy=":statusy, "statusheight=":statusheight, "statuswidth=":statuswidth, "aot=":aot, "moveMode=":moveMode, "backgroundmode=":backgroundmode, "backcolor=":backcolor, "fontcolor=":fontcolor, "eliminateColorFromUI=":eliminateColorFromUI, "fontShadowcolor=":fontShadowcolor,"transparency=":transparency,"outlineFont=":outlineFont,"fontsize=":fontsize,"myfont=":myfont}) ; "suspendTimerCntr=":suspendTimerCntr,"beepLength=":beepLength,"beep2=":beep2,"beep1=":beep1
	;gui_rewrite_ifpause({"transparency=":transparency,"outlineFont=":outlineFont}) ; for transparency slider to save only when exiting, and outlinefont checkmark in setting window to work properly (if you check the mark it will turn on the ouutline font to TEST mode where it shows how it looks but do not save it, and when you exiting script, it will actually save. we cannot save immediately when we check the checkbox, because it will rewrite gui and reset all other settings to saved ones)
	;gui_rewrite_ifpause(allSettings) ; for transparency slider to save only when exiting, and outlinefont checkmark in setting window to work properly (if you check the mark it will turn on the ouutline font to TEST mode where it shows how it looks but do not save it, and when you exiting script, it will actually save. we cannot save immediately when we check the checkbox, because it will rewrite gui and reset all other settings to saved ones)
return

;_______________________________________________________________________________________________________
ReloadMenu:
	;outlineFont := (outlineFont=1 ? 1 : 0) ; fix for the outlinefont test mode in setting window checkbox (dont bother understanding)
	rewriteCode({"statusx=":statusx, "statusy=":statusy, "statusheight=":statusheight, "statuswidth=":statuswidth, "aot=":aot, "moveMode=":moveMode, "backgroundmode=":backgroundmode, "backcolor=":backcolor, "fontcolor=":fontcolor, "eliminateColorFromUI=":eliminateColorFromUI, "fontShadowcolor=":fontShadowcolor,"transparency=":transparency,"outlineFont=":outlineFont,"fontsize=":fontsize,"myfont=":myfont})
	;rewriteCode({"transparency=":transparency,"outlineFont=":outlineFont})
	Reload
Return

CloseExit:
	;outlineFont := (outlineFont=1 ? 1 : 0) ; fix for the outlinefont test mode in setting window checkbox (dont bother understanding)
	rewriteCode({"statusx=":statusx, "statusy=":statusy, "statusheight=":statusheight, "statuswidth=":statuswidth, "aot=":aot, "moveMode=":moveMode, "backgroundmode=":backgroundmode, "backcolor=":backcolor, "fontcolor=":fontcolor, "eliminateColorFromUI=":eliminateColorFromUI, "fontShadowcolor=":fontShadowcolor,"transparency=":transparency,"outlineFont=":outlineFont,"fontsize=":fontsize,"myfont=":myfont})
	;rewriteCode({"transparency=":transparency,"outlineFont=":outlineFont})
	ExitApp
Return

SettingsBackground:
	Menu, Submenu, ToggleCheck, Background Mode
	backgroundMode:=(backgroundMode!=1 ? 1 : 0)	
	move_aot_back_checkSync("backgroundMode")	; synchronize checkmarks in setting window and in tray

	;parsing_values("reset","all")
	;gui_rewrite_ifpause({"backgroundmode=":backgroundmode,"outlineFont=":outlineFont})
	
	move_aot_back_tray_AdvSet({"backgroundMode=":backgroundMode}) ; call for aot\move\back modes check, icons check, updating our gui, rewriting code(if called from setting window) + restarting (redrawing) gui if called from tray
return


SettingsMove:
	Menu, Submenu, ToggleCheck, Move Mode
	moveMode:=(moveMode!=1 ? 1 : 0)	
	move_aot_back_checkSync("moveMode")

	;parsing_values("reset","all")
	;if moveMode=1										; if we just turned on moveMode we only save moveMode value
	;	gui_rewrite_ifpause({"moveMode=":moveMode,"outlineFont=":outlineFont})				
	;else if moveMode!=1									; if we just turned off moveMode we save moveMode value	and x-y-w-h values
	;	gui_rewrite_ifpause({"moveMode=":moveMode,"statusx=":statusx,"statusy=":statusy,"statuswidth=":statuswidth,"statusheight=":statusheight,"outlineFont=":outlineFont})

	move_aot_back_tray_AdvSet({"moveMode=":moveMode})
Return


SettingsAOT:
	Menu, Submenu, ToggleCheck, Always On Top
	aot:=(aot!=1 ? 1 : 0)
	move_aot_back_checkSync("aot")

	;parsing_values("reset","all")
	;gui_rewrite_ifpause({"aot=":aot,"outlineFont=":outlineFont})
	
	move_aot_back_tray_AdvSet({"aot=":aot})
Return

gui_rewrite_ifpause(whatTo_rewrite)				; if script is on pause not to mess with pausing\unpausing we will just rewrite code without unpausing
{
	Global						; to read PauseSCRPT_Var value
	
	;if WinExist("ahk_id" setting_window)
	;	GuiControl, Second_GUI:, xywhSave,✔
	if (PauseSCRPT_Var!=1) 		; if pause is turned OFF we start our gui with all of its functions in the beginning
	{
		rewriteCode(whatTo_rewrite)			; write all of changes in code
		Gosub, guistart
	}
	else if (PauseSCRPT_Var=1)	; if pause is turned ON we only write changes to code
		rewriteCode(whatTo_rewrite)			; write all of changes in code
		;msgbox ,0x30, Script is Paused, Unpause Script!,0.5 ;comment this
}
Return

move_aot_back_checkSync(mab_var)				; if setting window opened and aot\move\background checkbox is clicked, it will also change the check state in tray settings mode
{
	;tooltip % mab_var "`n" %mab_var%,100,100,3
	if WinExist("ahk_id" setting_window) 
		GuiControl Second_GUI:,checkbox_%mab_var%, % (%mab_var%=1 ? 1 : 0)
			
}
return

move_aot_back_tray_AdvSet(arrVal)
{
	if WinExist("ahk_id" setting_window) 
	{
		makeUI_MOVE_BACKGROUND() 
		iconCheck()
		UpdateScript()
		rewriteCode(arrVal)	
		return
	}
	gui_rewrite_ifpause(arrVal)
}
return

ShowExceptions:

scrptWasPaused:=PauseSCRPT_Var=1 ? 1 : 0							; saving PAUSE state before opening exception window

ShowExceptions_Active:											; to avoid rewriting "scrptWasPaused" variable. because if i change its value while window is open, it will rewrite itself, and will not contain the REAL value of "if it was paused or unpaused before firstly launching this window"
If WinExist(ExceptionsTitle) or WinExist(ExceptionsTitle1) or WinExist(ExceptionsTitle2)	; to avoid several instances, if any of script windows exist, do not do anything further
	return
SetTimer, workWithMsgbox, -35								; looking at fact that some internal windowsOS delays are around 15-16 msec, i chose 35 msec to wait and run subroutine once until it shuts itself down
msgbox,0x40043,% ExceptionsTitle,% arr_of_srchdLine(htstrngSrchKeyW, "::", "list") 
    
if (MsgBoxGetResult() = "Yes")								; if ADD button pressed
{
	scrptWasPaused_ADD:=PauseSCRPT_Var=1 ? 1 : 0		; save the PAUSE state of script right after ADD button was pressed (to return to previous PAUSE state after we exit ADD InputBox window)
	Gosub,% scrptWasPaused_ADD!=1 ? "PauseSCRPT" : "GOSUB_NULL"				; if it was NOT on PAUSE right after ADD was pressed then we (PAUSING) call for pause function, otherwise - do nothing
	InputBox, addWordVar, % ExceptionsTitle1,% "`t     Add`n           Exception-Word",,200,150
	if ErrorLevel=1								; if CANCEL ADDing pressed
		pause_UNpause_showEXC(scrptWasPaused_ADD)	; unpausing depending on state right after ADD was pressed, and reloading msgbox from "ShowExceptions_Active" point
	else 										; if anything else pressed ( OK button )
	{											
		if addWordVar!=							; if there is any input in inputbox
		{
			for keyAddBtn, valAddBtn in arr_of_srchdLine(htstrngSrchKeyW, "::", "array")	; looping whole array of our hotstrings. checking if new hotstring is already available in out script code
			{
				if (addWordVar=valAddBtn) 						; if any word from array the same as string from inputbox (means that if we already have same hotstring in code as what we are trying to add)
				{
					msgbox ,0x10,%ExceptionsTitle1%,Hotstring Already Available!,5	
					pause_UNpause_showEXC(scrptWasPaused_ADD)	; unpausing depending on state right after ADD was pressed, and reloading msgbox from "ShowExceptions_Active" point
					return										; this RETURN is crucial (without it there are bugs when you pressed different buttons except CANCEL, and in the end try to press CANCEL)
				}
			}
			if (StrLen(addWordVar)>40)														; if inputbox string is more than 40 symbols. 40 symbols limit for Hotstrings
			{
				msgbox ,0x10,%ExceptionsTitle1%,40 Symbols Limit!,5
			}
			else if (StrLen(addWordVar)<=40)												; if inputbox string is less or equals than 40 symbols. 40 symbols limit for Hotstrings							
			{
				ADDing_Hotstring := "`n:B0?*:" addWordVar "::`nblckdWord(4)`nreturn`n" 		; creating new hotstring in code with predetermined lines of code here. (btw, second occurance of "B0?")
				tempAdd_Button_arr:=[]														; creating a temp array
				tempAdd_Button_arr[1]:=arr_of_srchdLine(htstrngSrchKeyW, "::", "array").MaxIndex()+3				; adding to an array last occurence of existing in code hotstring line number, (array, not variable - because our function where we send values needs an array as first parameter, otherwise it would be a simple variable). +3 because our hotstrings has 3 lines, and we need line number where we would start our new hotstring
				replaceCodeLine(tempAdd_Button_arr, ADDing_Hotstring, 2) 					; rewriting code function. sending line to start with, and text to add to code, 2 is for hotstrings (not settings) editing
				msgbox ,0x40,%ExceptionsTitle1%, % "Hotstring '" addwordvar "' added!",5
				Reload																		; reload to immediately work with our new added hotstring
			}  
		} 	
		else if addWordVar=																	; if there is no string entered in inputbox after pressing "ADD"
			msgbox ,0x10,%ExceptionsTitle1%,Nothing is Entered!,5
		pause_UNpause_showEXC(scrptWasPaused_ADD)								; unpausing depending on state right after ADD was pressed, and reloading msgbox from "ShowExceptions_Active" point				
		return
	}
	return
}
else if (MsgBoxGetResult() = "No")					; if DELETE button pressed
{
	scrptWasPaused_DEL:=PauseSCRPT_Var=1 ? 1 : 0  ; save the PAUSE state of script right after DELETE button was pressed (to return to previous PAUSE state after we exit DELETE InputBox window)
	Gosub,% scrptWasPaused_DEL!=1 ? "PauseSCRPT" : "GOSUB_NULL"			; if it was NOT on PAUSE right after DELETE was pressed then we (PAUSING) call for pause function, otherwise - do nothing
	InputBox, deleteWordVar, % ExceptionsTitle2,% "`t   Delete`n           Exception-Word",,200,150
	if ErrorLevel=1									; if CANCEL DELETing pressed
		pause_UNpause_showEXC(scrptWasPaused_DEL)	; unpausing depending on state right after DELETE was pressed, and reloading msgbox from "ShowExceptions_Active" point
	else								; if anything else pressed (not CANCEL but OK)
	{
		if deleteWordVar!=				; if there is any input in inputbox
		{
			for keyDelBtn, valDelBtn in arr_of_srchdLine(htstrngSrchKeyW, "::", "array")							; looping whole array of our hotstrings. checking if new hotstring is already available in out script code
			{
				if (deleteWordVar=valDelBtn) 														; if any word from array the same as string from inputbox (means that if we already have same hotstring in code as what we are trying to delete)
				{
					msgbox ,0x34, %ExceptionsTitle2%, % "Deleting '" deleteWordVar "'`nAre You Sure?"
					if (MsgBoxGetResult() = "Yes")													; if we pressed YES after msgbox asked "are we sure about deleting"
					{
						;DeleteLeadingLines(keyDelBtn, 4) 
						keyDelBtnArr:=[]											; temp array
						keyDelBtnArr[1]:=keyDelBtn 									; assigning line number in code of our hotstring that we are trying to delete
						replaceCodeLine(keyDelBtnArr, 4, 3)								; rewriting code, deleting hotstring. 1st parameter - sending array ( we created array only because function needs an array, otherwise any variable would be sufficient). parameter 4 = how many lines we delete (3 lines are hotstrings and +1 is blank line). parameter 3 = settings key for function
						msgbox ,0x40,%ExceptionsTitle2%, % "Hotstring '" deleteWordVar "' deleted!",5	
						Reload													; reload to immediately work with script where we deleted hotstring
					}
					else if (MsgBoxGetResult() = "No")											; if we pressed NO after msgbox asked "are we sure about deleting"
						msgbox ,0x10, %ExceptionsTitle2%, Nothing Deleted!,5
					pause_UNpause_showEXC(scrptWasPaused_DEL)		; unpausing depending on state right after DELETE was pressed, and reloading msgbox from "ShowExceptions_Active" point
					return											; this RETURN is crucial (without it there are bugs when you press NO button in inputbox windows, and in the end try to press CANCEL in msgbox windows)
				} 
			}
			msgbox ,0x10,%ExceptionsTitle2%,No such Hotstring!,5			; if there are no hotstrings in code that are the same as our string from inputbox
		}
		else if deleteWordVar=												; if inputbox string is blank
			msgbox ,0x10,%ExceptionsTitle2%,Nothing is Entered!,5
		pause_UNpause_showEXC(scrptWasPaused_DEL)							; unpausing depending on state right after DELETE was pressed, and reloading msgbox from "ShowExceptions_Active" point
		return																
	}
	return
}
;else if (MsgBoxGetResult() != "Cancel" && PauseSCRPT_Var=1) ; 
else if (MsgBoxGetResult() = "Cancel" && ((scrptWasPaused=0 && PauseSCRPT_Var=1) || (scrptWasPaused=1 && PauseSCRPT_Var=0)))	; if before window launch there was pause or it wasn't there, but after we close the window we have reverse situation (before window launch there was pause and after closing window it is not) - we are restoring the state of pause that we had before window launch
	Gosub, PauseSCRPT
return

pause_UNpause_showEXC(WasPaused)
{		
	Gosub,% WasPaused!=1 ? "PauseSCRPT" : "GOSUB_NULL"
	Gosub, ShowExceptions_Active
}
return

GOSUB_NULL:			; don't delete, its for ternary expressions, here nothing happens
return

workWithMsgbox:
WinGetClass, getExceptionsMsgbxClass, % ExceptionsTitle
ExceptionsWinClassName:="ahk_class "								; we need to create new string in variable from scratch every iteration
ExceptionsWinClassName.=getExceptionsMsgbxClass
ControlSetText, Button1, % "Add Word", %ExceptionsWinClassName%
ControlSetText, Button2, % "Delete Word", %ExceptionsWinClassName%
ControlSetText, Button3, % "Close", %ExceptionsWinClassName%
return

MsgBoxGetResult()
{
	Loop, Parse, % "Timeout,OK,Cancel,Yes,No,Abort,Ignore,Retry,Continue,TryAgain", % ","
		IfMsgBox, % msgboxVarResult := A_LoopField
			break
	return msgboxVarResult
}
return


#if GetKeyState("Up") || GetKeyState("Down") || GetKeyState("Left") || GetKeyState("Right") ; press [Up] or [Down] or [Right] or [Left] + [Pause] (pause need to be pressed in the end) to pause script
	pause::					; PAUSE hotkey for If statement
	Suspend, Permit			; Does nothing except marking the current subroutine as being exempt from suspension
	Gosub, PauseSCRPT
	return
#if

PauseSCRPT:
	If WinExist(ExceptionsTitle1) or WinExist(ExceptionsTitle2) 		; if ADD or DELETE InputBox is active
		return															; exit subroutine
	Menu, Tray, ToggleCheck, Pause
	soundbeep % (PauseSCRPT_Var!=1 ? beep1 : beep2), beepLength
	PauseSCRPT_Var:=(PauseSCRPT_Var!=1 ? 1 : 0)
	PauseScript()
	
return


PauseScript()
{
	Global
	if (PauseSCRPT_Var!=1)				; pay attention, in previous block(PauseSCRPT) we changed value in PauseSCRPT_Var
	{
		Gosub, guistart
		if WinExist("ahk_id" setting_window) ; if you changed values in setting windows while pause, and exit pause, this line will make sure that your changed values will be shown
			UpdateScript()
	}
	else if (PauseSCRPT_Var=1)
	{	
		if WinExist("ahk_id" setting_window)
			gui_for_visualTest()	; if setting window opened, pause will force test mode for main UI (where no input shown, but only static phrase to see what you are changing visually in main window) 
		else
			Gui, First_GUI:Hide ; hide instead of destroy because in setting mode nothing will work (i mean main ui wont work)
	}
	
	Suspend, Toggle						; disables or enables all hotkeys\hotstrings
	SetTimer, main,% (PauseSCRPT_Var=1 ? "Off" : "20") ; !!!!!!!!!!!!!!!!!!!!
}
return

iconCheck() 
{
	Global																; To refer to an existing global variable inside a function
	;if ((FileExist(mainIcon)="") || (FileExist(mainIconB)="") || (FileExist(configureIcon)="") || (FileExist(configureIconB)=""))
	;{
	;	;Menu, Tray, Icon, pifmgr.dll, 13				; 
	;	return
	;}
	if (winsetParamFirst="TransColor" && aot=1)			; transparent\background mode + АОТ(allways on top)
	{
		;IfExist, % mainIcon
		;Menu, Tray, Icon, % mainIcon
		Menu, Tray, Icon, ddores.dll, 106
	} else if (winsetParamFirst="TransColor" && aot=0)		; transparent\background mode - АОТ
	{
		;IfExist, % mainIconB
		;Menu, Tray, Icon, % mainIconB
		Menu, Tray, Icon, ddores.dll, 108				; 
	} else if (winsetParamFirst="Transparent" && aot=1)	; mode MOVE + AOT
	{
		;IfExist, % configureIcon
		;Menu, Tray, Icon, % configureIcon
		Menu, Tray, Icon, imageres.dll, 324
	} else if (winsetParamFirst="Transparent" && aot=0)	; mode MOVE - AOT
	{
		;IfExist, % configureIconB
		;Menu, Tray, Icon, % configureIconB
		Menu, Tray, Icon, imageres.dll, 324
	}
}
return



makeUI_MOVE_BACKGROUND() 											
{	
	global															; To refer to an existing global variables inside a function
	if (moveMode=1)													; if MOVE checkmark(in tray) is present and it doesnt matter if the checkmark BACKROUND is present
	{
		winsetParamFirst=Transparent								; activating MOVE mode
		winsetParamSecond=%transparency%
		winsetParamThird=-0x20	
	} else if (moveMode=0 && backgroundMode=0)						; checkmark MOVE is removed while chekcmark BACKGROUND is also removed
	{
		winsetParamFirst=TransColor									; transparent (and click-through-able) mode
		winsetParamSecond=%eliminateColorFromUI% %transparency%
		winsetParamThird=+0x20
	}  else if (moveMode=0 && backgroundMode=1)						; checkmark MOVE is removed while checkmark BACKGROUND is present
	{
		winsetParamFirst=TransColor									; background (and click-through-able) mode
		winsetParamSecond=zxc %transparency%						; zxc - because it's absolutely random letters and will not interfere with any color. here must be color (f.e. "FFFFFF" or "000000" or "blue"/"red etc.), but it interfere with some inputs from users when configuring colors in settings block
		winsetParamThird=+0x20
	}
}
return



getKeyboardLang()
{
	WinGet, WinID,, A
	ThreadID:=DllCall("GetWindowThreadProcessId", "UInt", WinID, "UInt", 0)
	InputLocaleID:=DllCall("GetKeyboardLayout", "UInt", ThreadID, "UInt")	
	return % InputLocaleID=4037542946 ? "ukr" : InputLocaleID=67699721 ? "eng" : InputLocaleID=68748313 ? "rus" : InputLocaleID
}
return


changeKeyboardLangTo(getKeyboardLangVar)	; do not change anything here in order for it to work, especially dont touch 0x050 code
{
	if (getKeyboardLangVar!=0)
	{
		WinExist("a")
		ControlGetFocus, CtrlInFocus
		PostMessage, 0x050, 0, getKeyboardLangVar, %CtrlInFocus% 
		Reload
	}
}
Return

;rewriteCode(search_for, var_to_read) ; old not optimized version 999
rewritecode(search_read_arr)
{
	Global
	
	;outlineFont := (outlineFont=1 ? 1 : 0) ; to always check outlinefont, because it works not as everything else, otherwise it will be bugged or wont work as i wanted it to work
	;tooltip % statusx " - " statusy ,200,200,5
	for srK, srV in search_read_arr											
	{
		;msgbox % srk "`n" srv
		if (srK="outlinefont=")
			srV:=(srV=1 ? 1 : 0)	; CAN BE 2 BUT WE CANT SAVE 2!... to always check outlinefont, because it works not as everything else, otherwise it will be bugged or wont work as i wanted it to work

		lineNumArr := arr_of_srchdLine(srK, A_Tab, "paramFullInfo")				; getting a first key from key-value array and giving it to (arr_of_srchdLine) function to search for (srK) key, and the character on which the string search should be stopped "A_Tab", with (paramFullInfo) setting in this function meaning we want full info
		;msgbox % "rewritecode`n`nin code: " linenumarr[5] "`n" srk srV
		;if (( linenumarr[4]!="outlinefont=" || linenumarr[4]!="transparency=") && (linenumarr[5]!=srV))			; if current value of (srV) is not equal to what value is literally written in code, then rewrite code			
		if ("" . linenumarr[5]!="" . srV)			; if current (!string!. because we concatenate "" to our value and by this we transform value to string)) value of (srV) is not equal to what value is literally written in code, then rewrite code			
			replaceCodeLine(lineNumArr, srV, 1)									; replacing the value in the code at (srV) line with current (changed) (srV) value while saving the comment part of line
		;else if (linenumarr[4]="outlinefont=" && linenumarr[5]!=outlinefont)	; to always check outlinefont. because of how checkbox of outlinefont works in setting window, there were some cosmetical and logical bugs. when you check or uncheck, it will reset all unsaved data, so i turned on this reset, and when i turned outlinefont off visual bugs were present, so etc etc, alot of different stuff came up
			;replaceCodeLine(lineNumArr, outlinefont, 1)							; to always check outlinefont
		;else if (linenumarr[4]="transparency=" && linenumarr[5]!=transparency)	; to always check outlinefont. because we save transparency slider value only when exiting or reloadiing setting window or script. just so there were no unsaved values reset in etting window when we sliding the slider
			;replaceCodeLine(lineNumArr, transparency, 1)							; to always check outlinefont
	}
	/*
	Loop % search_for.MaxIndex() 																		; looping n-times (n=number of values in received array (could be any of two received arrays, doesnt matter, they always must have the same count))
	{
		lineNumArr := arr_of_srchdLine(search_for[A_Index], A_Tab, "paramFullInfo")						; getting an array and giving it a string to search for (search_for[A_Index]), and the character on which the string search should be stopped "A_Tab"
		if (linenumarr[5]!=var_to_read[A_Index])														; if current value of (var_to_read[A_Index]) is not equal to what value is literally written in code, then rewrite code
			replaceCodeLine(lineNumArr, var_to_read[A_Index], 1)										; replacing the value in the code at (var_to_read[A_Index]) line with current (changed) (var_to_read[A_Index]) value while saving the comment part of line
	}
	*/
	/*
	lineNumArr := arr_of_srchdLine("global statusx=", A_Tab, "paramFullInfo")		; getting an array and giving it a string to search for "global status x=" and the character on which the string search should be stopped "A_Tab"
	if (linenumarr[5]!=statusx)														; if current value of "statusx" is not equal to what value is literally written in code, then rewrite code
		replaceCodeLine(lineNumArr, statusx, 1)										; replacing the value in the code at "statusx" line with current (changed) "statusx" value while saving the comment part of line
	*/
}
return

arr_of_srchdLine(receivedKeyword, whenToStop, settingCode)
{
	global suspendTimerCntr ; make this variable global
	thatList = Add the words which are first characters of`nyour password, so when you start typing`nyour password, application will pause for %suspendTimerCntr% sec.`n`nWords - Exceptions:`n
	thatArray:=[]
	Loop, Read, %A_ScriptFullPath%
	{
		if (InStr(A_LoopReadLine, receivedKeyword))
		{	
			if (settingCode="array" || settingCode="list")
				thatArray[A_Index] := SubStr(A_LoopReadLine, (StrLen(receivedKeyword)+1), InStr(A_LoopReadLine, whenToStop)-((StrLen(receivedKeyword)+1)))
			else if (settingCode="paramFullInfo")	
			{
				valueFromVar_Code.=SubStr(A_LoopReadLine, (StrLen(receivedKeyword)+1), InStr(A_LoopReadLine, whenToStop)-((StrLen(receivedKeyword)+1))) 		; this line is when(if) i figure out how to force program to rewrite its code only in-between value and commentary
				commentaryFromVar_Code.=SubStr(A_LoopReadLine, (StrLen(valueFromVar_Code) + StrLen(receivedKeyword)+1)) 	; +1 because in "statusx=" 8 characters, but we are reading from 9th character
				thatArray[6]:=commentaryFromVar_Code				; only commentary part
				thatArray[5]:=valueFromVar_Code						; only value after *receivedKeyword* and before *whenToStop*
				thatArray[4]:=receivedKeyword						; only string that we are searching for
				thatArray[3]:=receivedKeyword . valueFromVar_Code	; only variable and value
				thatArray[2]:=A_LoopReadLine						; whole line
				thatArray[1]:=A_Index								; number of line
				break												; break means that it will stop only at first occurence of receivedKeyword
			}
		}
	}	
	/*																				; unquote
	explanationArray:=[]															; to see what is inside array
	explanationArray[1]:="Line number"
	explanationArray[2]:="Whole line"
	explanationArray[3]:="Variable and value"
	explanationArray[4]:="Searched string"
	explanationArray[5]:="Value of searched string (variable)"					
	explanationArray[6]:="String after variable and value (commentary)"
	For k, v in thatarray															; to see what is inside array
	{
		thatarrayV.=k ". " explanationArray[k] ":`n[" v "]`n`n"						; to see what is inside array
	}
	msgbox % thatArrayV																; to see what is inside array
	*/																				; unquote
	if (settingCode="list")
		for arrayLineNums, arrayValues in thatArray																	
			if (a_index>2)																; ignoring first 3? (it seems we have only 2) occurance's of "B0?" in code. this is for ignoring code logic lines and starting showing only real hotstrings from number 1. number 1("passw") and 2("зфыыц") and 3 which are examples
				thatList.= a_index-2 ". " arrayValues "`n"								; -2  because we are ignoring first occurances (in code where logic is written and applied)
	return settingCode="list" ? thatList : thatArray
}


replaceCodeLine(rcvdArr, writeNewLine, what_to_do) 
{
	;msgbox % "replaceCodeLine"
	oFileReplace := FileOpen(A_ScriptFullPath, "rw")
	;start := oFileReplace.Pos				;original code (looks unnecessary)
	if rcvdArr[1]							; check if we found in file our keyword (so if it is not found the code would not delete every single line of code)
		{
			Loop % what_to_do=3 ? (rcvdArr[1]+writeNewLine) : rcvdArr[1]   						; what_to_do = 3 for deleting. if deleting, writenewline will receive number, Arr[1] is line number
			{
				lastActiveLine := oFileReplace.ReadLine()										; remembering line that we are reading, also .ReadLine - Reads a line of text from the file and advances the file pointer
				if (A_Index = (rcvdArr[1] - 1))													; -1 because ReadLine advanced pointer to next line, and for further editing we need exact line without any advancing to next line
					replaceLinePos := oFileReplace.Pos											; saving pointer location at the start of next line (the line we actually need, remember ReadLine advancing file pointer)
				;if (A_Index = rcvdArr[1] && notEOF := true)									; original code	
				;if (A_Index = rcvdArr[1])		
				if (a_Index = (what_to_do=3 ? (rcvdArr[1]+writeNewLine-1) : rcvdArr[1]))		; what_to_do = 3 for deleting. i dont remember for sure, but: rcvdarr[1] is number of line for hotstring that we are searcing, and writenewline-1 (because writenewline is always 4 (3 lines of hotstring code + 1 blank line), but we need to work with f.e.: 456th line of code - where our hostring is, + 1 - next line of code which is calling for function, + 1 - "return" line of code, + 1 - blank line of code = 459 (not 456+4 which would be 460, but 456+3=459)) 
					restOfText := oFileReplace.Read()											; rest of text after our keyword line
			}	until oFileReplace.AtEOF														; seems unnecessary but w\e. reading line until AtEOF (i guess it means at end of file)
			;if (notEOF && (linesCtr>=rcvdArr[1]))												; original code
			if (linesCtr>=rcvdArr[1])															; if overall number of lines in our script is more than line number that we are searching for (check for avoiding any bugs, this line may be unnecessary)
			{
				oFileReplace.Pos := replaceLinePos												; making our current pointer position at the start of line that we are searcing for
				;oFileReplace.Write(writeNewLine . RegExReplace(lastActiveLine, "[^`r`n]+"))	; original code
				if (what_to_do=1)																; this one is for checking for working with "script settings" value (f.e. statusx\moveMode etc.)
				{
					StringReplace, lastActiveLineEdit, lastActiveLine, % rcvdArr[3], % (rcvdArr[4] . writeNewLine)
					;tooltip % lastActiveLineEdit "`n" lastActiveLine "`n" rcvdArr[3] "`n" (rcvdArr[4] . writeNewLine)
					oFileReplace.Write(lastActiveLineEdit)
				} else if (what_to_do=2)														; this one for "hotstrings"
				{
					oFileReplace.WriteLine(writeNewLine)
				}
			}
			oFileReplace.Write(restOfText)														; writing rest of our text after editting lines
			oFileReplace.Length := oFileReplace.Pos												; this one is mandatory to prevent bug when, at the end of the file last text symbols from file, being duplicated for no reason	
		}
	oFileReplace.Close()
	Return
}

blckdWord(tooltipVar)							; function that stops script from showing keys if you start typing your "blocked word" (see "BLOCKED WORDS..." section)
{	
	Global
	Gosub, PauseSCRPT
	
	ifWinNotExist % ExceptionsTitle					; if "Words-Exceptions" Window is not launched
	{
		startTime:=Floor(a_tickcount/1000)			; starting point for reverse countdown
		Loop
		{	
			timeLeftBW:=suspendTimerCntr-(Floor((a_tickcount/1000) - starttime))
			if (PauseSCRPT_Var!=1)					; if you turn off pause mode manually while this function is working (while tooltip countdown is ticking)
			{
				tooltip								; cleans tooltip
				return								; stops function
			} 
			if (timeLeftBW>=0 && showTooltip=1)						; reverse countdown
				tooltip % timeLeftBW
			else if (timeLeftBW>=0 && showTooltip=0)				; reverse countdown
				continue
			else break								; stops loop
		}								
		Gosub, PauseSCRPT				
		tooltip
	}
}
return

tooltipShow()							; UNUSED TOOLTIP SHOWing
{
	Global
	;tooltip_Var := A_Temp "\temp_curSpoTrack.txt"
	tooltipStartTime := A_TickCount
	tTip_elapsedTime:=
	SetTimer, tooltipTimer, 1
}
tooltipTimer:
	if (tTip_elapsedTime>=(suspendTimerCntr*1000))
	{
		ToolTip, , , , 18
		SetTimer, tooltipTimer, Delete
	} else 
	{
		tTip_elapsedTime := A_TickCount-tooltipStartTime
		ToolTip, % (spoTrack_Tray!=1 ? "Spotify .txt file - Disabled!" : "Spotify .txt file - Enabled!") "`nPath to Spotify .txt file copied to Clipboard!`n" Round(((suspendTimerCntr*1000)-tTip_elapsedTime)/1000) " . . ." , , , 18
	}
return

;https://autohotkey.com/boards/viewtopic.php?p=112730#p112730
;------------------Choose Color Box---------------------------------------------
;-------------------------------------------------------------------------------
Select_Color(hGui, ByRef Color) { ; using comdlg32.dll
;-------------------------------------------------------------------------------

    ; CHOOSECOLOR structure expects text color in BGR format
    BGR := convert_Color(Color)

    ; unused, but a valid pointer to the structure
    VarSetCapacity(CUSTOM, 64, 0)


    ;-----------------------------------
    ; CHOOSECOLOR structure
    ;-----------------------------------

    If (A_PtrSize = 8) { ; 64 bit
        VarSetCapacity(CHOOSECOLOR, 72, 0)
        NumPut(     72, CHOOSECOLOR,  0) ; StructSize
        NumPut(   hGui, CHOOSECOLOR,  8) ; hwndOwner
        NumPut(    BGR, CHOOSECOLOR, 24) ; bgrColor
        NumPut(&CUSTOM, CHOOSECOLOR, 32) ; lpCustColors
        NumPut(  0x103, CHOOSECOLOR, 40) ; Flags
    }

    Else { ; 32 bit
        VarSetCapacity(CHOOSECOLOR, 36, 0)
        NumPut(     36, CHOOSECOLOR,  0) ; StructSize
        NumPut(   hGui, CHOOSECOLOR,  4) ; hwndOwner
        NumPut(    BGR, CHOOSECOLOR, 12) ; bgrColor
        NumPut(&CUSTOM, CHOOSECOLOR, 16) ; lpCustColors
        NumPut(  0x103, CHOOSECOLOR, 20) ; Flags
    }


    ;-----------------------------------
    ; call ChooseColorA function
    ;-----------------------------------

    If Not DllCall("comdlg32\ChooseColorA", "UInt", &CHOOSECOLOR)
        Return, False

    ;-----------------------------------
    ; result to return
    ;-----------------------------------

    ; chosen color
    RGB := convert_Color(NumGet(CHOOSECOLOR, A_PtrSize = 8 ? 24 : 12, "UInt"))
    Color := SubStr("0x00000", 1, 10 - StrLen(RGB)) SubStr(RGB, 3)
	StringTrimLeft, Color, Color, 2 ; my (pcg) edit
    Return, True
}
;-------------------------------------------------------------------------------
convert_Color(Color) { ; convert RGB <--> BGR
;-------------------------------------------------------------------------------
    $_FormatInteger := A_FormatInteger
    SetFormat, Integer, Hex
    Result := (Color & 0xFF) << 16 | Color & 0xFF00 | (Color >> 16) & 0xFF
    SetFormat, Integer, % $_FormatInteger
    Return, Result
}
;------------------Choose Color Box---------------------------------------------
Select_Font(hGui, ByRef Style, ByRef Name, ByRef Color) { ; using comdlg32.dll
;-------------------------------------------------------------------------------
    static SubKey := "SOFTWARE\Microsoft\Windows NT\CurrentVersion\FontDPI"
    ;-----------------------------------
    ; LOGFONT structure
    ;-----------------------------------
    VarSetCapacity(LOGFONT, 128, 0)

    If RegExMatch(Style, "s\K\d+", s) {

        RegRead, LogPixels, HKLM, %SubKey%, LogPixels
        ;NumPut(s * (LogPixels // 72), LOGFONT, 0, "Int")	; old code
		NumPut(s * font_scale_V, LOGFONT, 0, "Int") 		; my edit, pcg
    }

    If RegExMatch(Style, "w\K\d+", w)
        NumPut(w, LOGFONT, 16, "Int")

    If InStr(Style, "italic")
        NumPut(255, LOGFONT, 20, "Int")

    If InStr(Style, "underline")
        NumPut(1, LOGFONT, 21, "Int")

    If InStr(Style, "strikeout")
        NumPut(1, LOGFONT, 22, "Int")

    StrPut(Name, &LOGFONT + 28, StrLen(Name) + 1)

    ;-----------------------------------
    ; CHOOSEFONT structure
    ;-----------------------------------

    ; CHOOSEFONT structure expects text color in BGR format

    BGR := convert_Color(Color)

    If (A_PtrSize = 8) { ; 64 bit
        VarSetCapacity(CHOOSEFONT, 104, 0)
        NumPut(     104, CHOOSEFONT,  0, "UInt") ; StructSize
        NumPut(    hGui, CHOOSEFONT,  8, "UInt") ; hwndOwner
        NumPut(&LOGFONT, CHOOSEFONT, 24, "UInt") ; lpLogFont
        NumPut(   0x141, CHOOSEFONT, 36, "UInt") ; Flags
        NumPut(     BGR, CHOOSEFONT, 40, "UInt") ; bgrColor
    }

    Else { ; 32 bit
        VarSetCapacity(CHOOSEFONT, 60, 0)
        NumPut(      60, CHOOSEFONT,  0, "UInt") ; StructSize
        NumPut(    hGui, CHOOSEFONT,  4, "UInt") ; hwndOwner
        NumPut(&LOGFONT, CHOOSEFONT, 12, "UInt") ; lpLogFont
        NumPut(   0x141, CHOOSEFONT, 20, "UInt") ; Flags
        NumPut(     BGR, CHOOSEFONT, 24, "UInt") ; bgrColor
    }

    ;-----------------------------------
    ; call ChooseFont function
    ;-----------------------------------



    FuncName := "comdlg32\ChooseFont" (A_IsUnicode ? "W" : "A")
    If Not DllCall(FuncName, "UInt", &CHOOSEFONT)
        Return, False
		
    ;-----------------------------------
    ; results to return
    ;-----------------------------------

    ; style
    Style := "s" NumGet(CHOOSEFONT, A_PtrSize = 8 ? 32 : 16, "Int") // 10
    Style .= " w" NumGet(LOGFONT, 16)
    If NumGet(LOGFONT, 20, "UChar")
        Style .= " italic"
    If NumGet(LOGFONT, 21, "UChar")
        Style .= " underline"
    If NumGet(LOGFONT, 22, "UChar")
        Style .= " strikeout"

    ; name
    Name := StrGet(&LOGFONT + 28)

    ; chosen color
    RGB := convert_Color(NumGet(CHOOSEFONT, A_PtrSize = 8 ? 40 : 24, "UInt"))
    Color := SubStr("0x00000", 1, 10 - StrLen(RGB)) SubStr(RGB, 3)
	;StringTrimLeft, Color, Color, 2 ; my (pcg) edit
    Return, True
	
}
;-------------------------------------------------------------------------------
WM_NCCALCSIZE(wParam, lParam)
{
    if (A_Gui="First_GUI")
        return 0
}

; Prevents a border from being drawn when the window is activated.
WM_NCACTIVATE(wParam, lParam)
{
    if (A_Gui="First_GUI")
        return 1
}
; Redefine where the sizing borders are.  This is necessary since
; returning 0 for WM_NCCALCSIZE effectively gives borders zero size.
WM_NCHITTEST(wParam, lParam)
{
    static border_size = 6
    
    if (A_Gui!="First_Gui")
        return
    
    WinGetPos, gX, gY, gW, gH
	
    x := lParam<<48>>48, y := lParam<<32>>48
    
    hit_left    := x <  gX+border_size
    hit_right   := x >= gX+gW-border_size
    hit_top     := y <  gY+border_size
    hit_bottom  := y >= gY+gH-border_size
    
    if hit_top
    {
        if hit_left
            return 0xD
        else if hit_right
            return 0xE
        else
            return 0xC
    }
    else if hit_bottom
    {
        if hit_left
            return 0x10
        else if hit_right
            return 0x11
        else
            return 0xF
    }
    else if hit_left
        return 0xA
    else if hit_right
        return 0xB
    
    ; else let default hit-testing be done
}

;----------------------------------------------------------------------------------------------------------------------
global hwinfo,hwinfo_window,hwinfo_text,hwinfo_textBR,hwinfo_textTL,hwinfo_textTR,hwinfo_textBL,hwinfo_text0,hwinfo_text0BR,hwinfo_text0TL,hwinfo_text0TR,hwinfo_text0BL
create_hwinfo_gui()
{
	Gui, hwinfo:+Owner -Caption +AlwaysOnTop +E0x02000000 +E0x00080000 Hwndhwinfo_window ; +E0x02000000 +E0x00080000  Double Buffer Style WS_EX_COMPOSITED = True & WS_EX_LAYERED = true. https://www.autohotkey.com/boards/viewtopic.php?t=77668
	Gui, hwinfo:Color,00B140
	Gui, hwinfo:Font, S20 W700 Q3,Segoe UI

	Gui, hwinfo:Add,Text,Vhwinfo_text0 x3 y3 h249 w249 Cwhite BackgroundTrans			; main text
	;Gui, hwinfo:Add,Text,Vhwinfo_text0BR x4 y4 h199 w199 Cblack BackgroundTrans		; Bottom Right text shadow
	;Gui, hwinfo:Add,Text,Vhwinfo_text0TL x2 y2 h199 w199 Cblack BackgroundTrans		; Top Left text shadow
	;Gui, hwinfo:Add,Text,Vhwinfo_text0TR x4 y2 h199 w199 Cblack BackgroundTrans		; Top Right text shadow
	;Gui, hwinfo:Add,Text,Vhwinfo_text0BL x3 y4 h199 w199 Cblack BackgroundTrans		; Bottom Left text shadow
	
	GuiControl,hwinfo:,hwinfo_text0 	;,CPU`nGPU`nENC`nCPU°C`nGPU°C
	;GuiControl,hwinfo:,hwinfo_text0BR 	;,CPU`nGPU`nENC`nCPU°C`nGPU°C
	;GuiControl,hwinfo:,hwinfo_text0TL	;,CPU`nGPU`nENC`nCPU°C`nGPU°C	
	;GuiControl,hwinfo:,hwinfo_text0TR 	;,CPU`nGPU`nENC`nCPU°C`nGPU°C
	;GuiControl,hwinfo:,hwinfo_text0BL 	;,CPU`nGPU`nENC`nCPU°C`nGPU°C

	Gui, hwinfo:Add,Text,vhwinfo_text x3 y3 h249 w249 Cwhite BackgroundTrans			; main text
	;Gui, hwinfo:Add,Text,Vhwinfo_textBR x4 y4 h199 w199 Cblack BackgroundTrans		; Bottom Right text shadow
	;Gui, hwinfo:Add,Text,Vhwinfo_textTL x2 y2 h199 w199 Cblack BackgroundTrans		; Top Left text shadow
	;Gui, hwinfo:Add,Text,Vhwinfo_textTR x4 y2 h199 w199 Cblack BackgroundTrans		; Top Right text shadow
	;Gui, hwinfo:Add,Text,Vhwinfo_textBL x3 y4 h199 w199 Cblack BackgroundTrans		; Bottom Left text shadow

	Gui, hwinfo:Show, x1 y1 w250 h250 NoActivate, hwinfo-ahk									;!!!!!!!!!!!!!!!!!!!!!!!!!!! if we add more rows or name of rows are longer - we need more height and width, FOR hwinfo:Add,Text BOXES ALSO!!!!!

	;WinSet,Transparent,255,hwinfo-ahk				; just comment next line, no need to uncomment this one
	WinSet,Transcolor,00B140 255,hwinfo-ahk			; just comment this line, no need to uncomment previous one
	WinSet,ExStyle,-0x20,hwinfo-ahk	
return
}

hwinfo:  
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	hwinfo_appName:="HWiNFO64 v7.14-4610 Sensor Status"
	hwinfo_column_ToRead:=2					; what column to read
	hwinfo_show_valueNames:=0 				; delete value names (1777 MHz = 1777). It deletes everything after first space. e.g.: '1777 MHz' = '1777';	'2199 Spins per second' = '2199 Spins per';
	hwinfo_array:=[	 "CPU  %"
					,"GPU  %"
					,"vENC %"
					,"RAM  %"
					,"CPU °C"
					,"GPU °C"]
	hwinfo_array_Renamed:=[  "CPU"
							,"GPU"
							,"ENC"
							,"RAM"
							,"CPU°"
							,"GPU°"]
	hwinfo_Errors:=[]						
	hwinfo_Rows:=[]	
	hwinfo_Columns:=[]
	hwinfo_finalArr:=[]
	
	ControlGet, hwinfo_get_allValues, List , , SysListView321, %hwinfo_appName%  ; https://www.autohotkey.com/docs/v1/lib/ControlGet.htm#List . getting whole text of all values from hwinfo
	Loop, Parse, hwinfo_get_allValues, `n  			; Rows - parsed by linefeeds (`n).
	{
		hwinfo_RowNum:=A_Index						; Current Row Number
		hwinfo_RowString:=A_LoopField				; Current Full Row String		
		Loop, Parse, A_LoopField, %A_Tab% 			; Columns - parsing by Tabs (`t)
		{
			hwinfo_ColNum:=A_Index					; Current Row - Column Number
			hwinfo_ColString:=A_LoopField			; Current Row Column String
			for hwArr_key, hwArr_val in hwinfo_array	; getting every value from out Input Sensors Array
			{
				if (hwinfo_ColString = hwArr_val)
				{
					hwinfo_Errors.Push("Input Sensors:`t" hwArr_key " - '" hwArr_val "'`nHWiNFO Row:`t" hwinfo_RowNum " - '" hwinfo_ColString "'`n")	; for errors checking (if 'Sensors' repeats)
					hwinfo_Rows[hwArr_key]:=hwinfo_RowNum	; gettin rows number for lines that we need	
				}	
			;msgbox % "Row " hwinfo_RowNum "`t-`t" hwinfo_RowString "`n`nColumn " hwinfo_ColNum "`t-`t" hwinfo_ColString		; whole info about every column and row
			}
		}
	}
	ControlGet, hwinfo_get_rowValues, List , Col%hwinfo_column_ToRead%, SysListView321, %hwinfo_appName%	; https://www.autohotkey.com/docs/v1/lib/ControlGet.htm#List 
	Loop, Parse, hwinfo_get_rowValues, `n  								; Rows parsed by linefeeds (`n).
	{
		hwinfo_RowNum:=A_Index						; Current Row Number
		hwinfo_RowString:=A_LoopField				; Current Full Row String		
		Loop, Parse, A_LoopField, %A_Tab% 								; Columns - parsing by Tabs (`t)
		{
			hwinfo_ColNum:=A_Index					; Current Row - Column Number
			hwinfo_ColString:=A_LoopField			; Current Row Column String
			for hwArr_key, hwArr_val in hwinfo_Rows
				if (hwArr_val=hwinfo_RowNum)
				{
					if (hwinfo_show_valueNames=1)
						hwinfo_Columns[hwArr_key]:=hwinfo_ColString
					else if (hwinfo_show_valueNames=0)
					{
						if (Instr(hwinfo_ColString,A_Space))	; getting rid of text after last space if space is encountered
						{
							StringReplace, hwinfo_ColString, hwinfo_ColString, %A_Space% , %A_Space%, UseErrorLevel		;counting spaces
							;msgbox % ErrorLevel " >" hwinfo_ColString "<"
							hwinfo_Columns[hwArr_key]:=SubStr(hwinfo_ColString, 1, InStr(hwinfo_ColString,A_Space,,,ErrorLevel)-1) ; gettin rows number for lines that we need. all before last space (errorlevel) (e.g.: '1777 MHz' = '1777';	'2199 Spins per second' = '2199 Spins per';)
						}
						else
							hwinfo_Columns[hwArr_key]:=hwinfo_ColString  	; gettin rows number for lines that we need	
					}
				}
			;msgbox % "Row " hwinfo_RowNum "`t-`t" hwinfo_RowString "`n`nColumn " hwinfo_ColNum "`t-`t" hwinfo_ColString		; whole info about every column and row
		}
	}	


	if !(hwinfo_Errors.Length() = hwinfo_array.Length())	; if we have errors
	{
		hwinfo_msgbox_showRow:="ERROR!`nToo many or less 'Sensors' reading. Check Clipboard and this window!`n`nYour Input Sensors:`n`n"
		for k,l in hwinfo_array			; showing original Input Sensors was
			hwinfo_msgbox_showRow.=k ".`t" l "`n"
		hwinfo_msgbox_showRow.="`n----------`n`nWhat program See's:`n`n"
		for a,b in hwinfo_Errors		; showing what programs sees
			hwinfo_msgbox_showRow.=a ".`n" b "`n"
	
		Clipboard := hwinfo_get_allValues
		msgbox ,0x40000,Rows,%hwinfo_msgbox_showRow%
		reload
	}
	else 
	{
		hwinfo_msgbox_showRow=
		for c,d in hwinfo_Rows
			hwinfo_msgbox_showRow.=d "`n"
	}
	
	;hwinfo_msgbox_showRowColVal=
	;for e,f in hwinfo_Columns
	;	hwinfo_msgbox_showRowColVal.=f "`n"	
	;msgbox ,0x40000,Rows,%hwinfo_msgbox_showRow%
	;msgbox ,0x40000,Rows-Columns Values,%hwinfo_msgbox_showRowColVal%
		
	for g,h in hwinfo_array		; getting original array length (to be sure that final results has the same length)
		hwinfo_finalArr[g]:=hwinfo_array_Renamed[g] "`t" hwinfo_Columns[g]		; composing here final array! renamed names of sensors - it's values
		
	hwinfo_msgbox_showFinal= 
	for i,j in hwinfo_finalArr
		hwinfo_msgbox_showFinal.=j "`n"

	;msgbox ,0x40000,Final,%hwinfo_msgbox_showFinal%
	
	;tooltip % hwinfo_msgbox_showFinal
	;RETURN
	
	;clipboard:=
	;reload	; delete
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
	/* ; uncomment if you want to return to old method
	ControlGet, column2_5rows, List , Col2, SysListView321, HWiNFO64 v7.14-4610 Sensor Status 	
	show_hwinfo := SubStr(column2_5rows,1,25)													
	
	GuiControl,hwinfo:,hwinfo_text,%show_hwinfo%			
	GuiControl,hwinfo:,hwinfo_textBR,%show_hwinfo%		
	GuiControl,hwinfo:,hwinfo_textTL,%show_hwinfo%		
	GuiControl,hwinfo:,hwinfo_textTR,%show_hwinfo%		
	GuiControl,hwinfo:,hwinfo_textBL,%show_hwinfo%	
	*/ ; uncomment if you want to return to old method

	GuiControl,hwinfo:,hwinfo_text,%hwinfo_msgbox_showFinal%		; delete
	;GuiControl,hwinfo:,hwinfo_textBR,%hwinfo_msgbox_showFinal%		; delete
	;GuiControl,hwinfo:,hwinfo_textTL,%hwinfo_msgbox_showFinal%		; delete
	;GuiControl,hwinfo:,hwinfo_textTR,%hwinfo_msgbox_showFinal%		; delete
	;GuiControl,hwinfo:,hwinfo_textBL,%hwinfo_msgbox_showFinal%		; delete

return
;-----------------------------------------------------------------------------------------------------------------------

;-----------------------------------------------------------------

;---------------- BLOCKED WORDS..... ---------------------------;		; stops showing your input keys for n-amount of seconds (suspendTimerCntr) if you start typing your, f.e. password
																;
;-------------------Example..... -------------------------------
																;
:B0?*:passw::		; "password" password example. type anywhere "passw" while script is running (case or NO CASE!!! sensitive (eng symbols are no case sensitive)).
blckdWord(1)		; tooltip pointer-number, for every hotstring to have his own tooltip(it was bugged at one point of development, so i added separate tooltips, now it might be useless cause i fixed those bugs, so i dont use it anymore in code) btw TOOLTIP COUNT LIMIT IS 20 !!!
return

:B0?*:зфыыц::		; "password" password example. type anywhere "зфыыц" (same word as previous, but in 'russian' (CASE SENSITIVE!!! (maybe because of cyrillic symbols) keyboard layout) 
blckdWord(2)													;
return															;
																;
:B0?*:this_line_can_only_contain_forty_symbols:: 				; Each hotstring can be no more than 40 characters long
blckdWord(3)													;
return															; 
;-------------------.....Example -------------------------------
:B0?*:aaa::
blckdWord(4)
return

:B0?*:ффф::
blckdWord(4)
return

:B0?*:sss::
blckdWord(4)
return

:B0?*:ыыы::
blckdWord(4)
return

:B0?*:123::
blckdWord(4)
return

;---------------- .....BLOCKED WORDS ---------------------------;
