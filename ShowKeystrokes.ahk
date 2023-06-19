; [up] or [down] or [right] or [left] + [Pause] >>> to pause/unpause script (press [Pause] in the end)
; "Words-Exceptions" are words that are triggering script to stop working for some time("suspendTimerCntr="). f.e.: you start to type your password, and script will stop working for 5 sec. (eng is no case sensitive, but f.e. cyrillic case sensitive (didn't bother with other than ENG languages))
; for OBS if you want to hook up this script window into your scene sources, OBS might draw a background color in it even though its transparent on your monitor, i suggest you to use "chromakey" in OBS filter in this script window source 
; also, for OBS i suggest you to set here in code "transparency=Off", you will not see any keyboard/mouse input with your eyes on your monitor, but you can hook it up in OBS as window source and it will be shown in OBS
#SingleInstance,Force
CoordMode,Mouse,Screen		; for configuring gui location to work better
#MaxHotkeysPerInterval 200	; for not triggering warning (pressing too much hotkeys) window. because showing mousewheel's implemented via hotkeys (and if you are scrolling way too fast, you may exceed the limit)
#MaxThreadsPerHotkey 2		; to avoid bug. when entering word-exception and immediately opening words-exceptions list(exceptions in tray), active thread for entered word-exception would freeze, so if you would turn off pause mode manually you couldnt enter the same word-excpetion again (comment this line or set to 1 to check what am i talking about: 1. enter word-exception, 2. immediately call for exceptions list from tray, 3. turn off pause mode manually(through tray or "ahk+pause" hotkey), 4. try to type again same word exception from "1.")
Process, Priority, , A		; script process priority - above normal, dont put any higher because it may conflict with some windows processes which have high priority 
SetBatchLines, -1			; The default SetBatchLines value makes your script sleep around 10-15.6 milliseconds every line. Make it -1 to not sleep
DllCall("ntdll\ZwSetTimerResolution","Int",5000,"Int",1,"Int*",MyCurrentTimerResolution) ; setting the Windows Timer Resolution to 0.5ms, THIS IS A GLOBAL CHANGE. quitting the program that changes the Timer Resolution will set it back to its normal value automatically
;Keyhistory


; to automatically, right after launching script (OR CHANGING SOME SETTINGS(because changing some settings RELOADS script)), switch keyboard language to, f.e.: English\rus, uncomment any of next line
;changeKeyboardLangTo((InputLocaleID:=DllCall("GetKeyboardLayout", "UInt", 0, "UInt"))!=68748313 ? 0x0419 : 0)  ; check if keyboard layout is RUS(RUS: 68748313), and calling for change to "any language" fucntion if its not RUS(RUS: 68748313). passing parameter is code for the language (RUS: 0x0419)
;changeKeyboardLangTo((InputLocaleID:=DllCall("GetKeyboardLayout", "UInt", 0, "UInt"))!=67699721 ? 0x0409 : 0)  ; check if keyboard layout is ENG(ENG: 67699721), and calling for change to "any language" fucntion if its not ENG(ENG: 67699721). passing parameter is code for the language (ENG: 0x0409)


;[Settings]... MAKE SURE THERE ARE "TAB's" between variables values and comments sections("; "), it is necessary in this block (TAB is the main parameter in rewriteCode() function). OTHERWISE CODE MIGHT NOT WORK PROPERLY
; ***************************
backcolor=00ff00			; * (00ff00) 000000-FFFFFF background color (also "red" or "yellow" etc. is valid) if you had problems with transparency ttry to avoid black color in first four settings lines
fontcolor=ffffff			; (white) 000000-FFFFFF	font color (fontcolor can be the same color as backcolor, but they will eliminate each other) (also "red" or "yellow" etc. is valid) if you had problems with transparency try to avoid black color in first four settings lines
eliminateColorFromUI=00ff00	; * (00ff00) 000000-FFFFFF eliminates pixels with specified color from UI in "background" mode (also "red" or "yellow" etc. is valid) if you had problems with transparency try to avoid black color in first four settings lines
fontShadowcolor=000011		; (000011) 000000-FFFFFF font outline color (also "red" or "yellow" etc. is valid) if you had problems with transparency try to avoid black color in first four settings lines
outlineFont=1				; make font outlined (0-1). increases text flickering (looks more buggy than usual), because there were no default outline method for fonts in AHK, so i implemented a workaround with drawing same symbols as main text, but a little bit shifted to the top/bottom left/right and with another color
fontsize=14					; font size in pixels
boldness=700				; 1-1000	400=normal	700=bold
font=Segoe UI				; font name. I prefer "Arial Rounded MT Bold" with "1" boldness (Calibri. Courier (Courier New). Fixedsys. Segoe UI. Tahoma. Trebuchet MS)
statusheight=35				; gui height in pixels
statuswidth=640				; gui length in pixels
global statusx=3			; location horizontal in pixels
global statusy=5			; location vertical in pixels
transparency=255			; (255) 0-255 or "Off"(specifying "Off" is different than specifying 255 because it may improve performance and reduce usage of system resources) (f.e. while using OBS studio, specifying "off" will remove any of your input from your monitor, but OBS will definetely see it)
; ***************************
trayclicks=2				; amount of tray clicks to trigger deafult tray menu (1-2)
global aot:="+AlwaysOnTop"	; default alwaysontop value (change "+" and "-" before "AlwaysOnTop") (you can also trigger it in windows tray)
global moveMode=0			; "0" if you want for ui to be - transparent and clickthrough; "1" if you want to move ui somewhere else (you can also edit it through tray)
global backgroundmode=0		; 0-1, background clickthrough mode (you can also trigger it in windows tray)
; ***************************
beep1=400					; 1st beep sound frequency for suspending script when you type your "special" words (search here ctrl+f "BLOCKED WORDS...")
beep2=800					; 2nd beep sound frequency for suspending script when you type your "special" words (search here ctrl+f "BLOCKED WORDS...")
beepLength=35				; beep sound frequency length for suspending script in msec when you type your "special" words (search here ctrl+f "BLOCKED WORDS...")
global suspendTimerCntr=5	; how many seconds script suspends after typing your "special" words (in seconds) (search here ctrl+f "BLOCKED WORDS...")
; **********************************************************************************
mainIcon = %SystemRoot%\System32\InputSystemToastIcon.png							; path to icon when Always On Top enabled only (WINDOWS 10)
mainIconB = %SystemRoot%\System32\KeyboardSystemToastIcon.png						; default icon
configureIcon = %SystemRoot%\System32\InputSystemToastIcon.contrast-white.png		; path to icon when Always On Top enabled and Move mode enabled
configureIconB = %SystemRoot%\System32\KeyboardSystemToastIcon.contrast-white.png	; default icon when Move mode only enabled
; **********************************************************************************
;...[Settings]


;------------------------------------------------------------------- some global variables for script
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
;dblKeys		:= 	["WheelUp WheelUp",	"WheelDown WheelDown"]	; list of double keys that needs correction
;dblKeys_r	:= 	["WheelUp",			"WheelDown"]			; and their corrected replacement
;------------------------------------------------------------------------------------------------------
;...Keys-----------------------------------------------------------------------------------------------

Gosub,TRAYMENU_alt 					; my little tray


guistart:							; starting gui (i need this, so when i press tray buttons it will assemble gui from scratch with new location and cosmetics parameters)
;------------------------------------------------------------------------------------------------------------------------
;keyarray_arr:=((InputLocaleID:=DllCall("GetKeyboardLayout", "UInt", 0, "UInt"))=67699721 ? keyarray_eng : keyarray_rus) ; check if keyboard layout is (67699721 eng) or (68748313 rus), and set main array symbols for script to work with accordingly
keyarray_arr:=(InputLocaleID:=DllCall("GetKeyboardLayout", "UInt", 0, "UInt"))=67699721 ? keyarray_eng : (InputLocaleID:=DllCall("GetKeyboardLayout", "UInt", 0, "UInt"))=4037542946 ? keyarray_ukr : (InputLocaleID:=DllCall("GetKeyboardLayout", "UInt", 0, "UInt"))=68748313 ? keyarray_rus : keyarray_eng ; check if keyboard layout is (67699721 eng) or (4037542946 ukr) or (68748313 rus), and set main array symbols according to current language, for script to work with. if its not eng\ukr\rus it is set to eng


rewriteCode()			; write all of changes in code
makeUI_MOVE_BACK()		; check the setting of move mode and background mode, and edit gui options before gui created - accordingly

iconCheck() 			; checking the state of tray icons to show new icon if needed

SetTimer, uiMove,% (moveMode=1 ? "1" : "Delete") ; to run subroutine for GUI movement

SetTimer, main, off 				; turn off main loop to not mess up with gui creation
;------------------------------------------------------------------------------------------------------------------------

Gui,Destroy							; destroy old gui to create new one with new parameters which we are getting after moving gui by pressing Configure button in tray
Gui,+Owner %aot% -Caption			; owner removes taskbar button, aot (always on top variable), caption removes borders
Gui,Color,%backcolor%
Gui,Font,C%fontcolor% S%fontsize% W%boldness% Q3,%font%			; Q3: GUI > FONT > NONANTIALIASED_QUALITY   (to reduce text rendering lag)

Gui,Add,Text,VshadowTextBR x4 y4 c%fontShadowcolor% BackgroundTrans,WWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW		; Bottom Right text shadow
Gui,Add,Text,VshadowTextTL x2 y2 c%fontShadowcolor% BackgroundTrans,WWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW		; Top Left text shadow
Gui,Add,Text,VshadowTextTR x4 y2 c%fontShadowcolor% BackgroundTrans,WWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW		; Top Right text shadow
Gui,Add,Text,VshadowTextBL x2 y4 c%fontShadowcolor% BackgroundTrans,WWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW		; Bottom Left text shadow
Gui,Add,Text,VtextMain x3 y3 c%fontcolor% BackgroundTrans,WWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW				; main text

Gui,Show,X%statusx% Y%statusy% W%statuswidth% H%statusheight% NoActivate,%A_ScriptName%

GuiControl,Text,textMain			; main text								
GuiControl,Text,shadowTextBR		; Bottom Right text shadow
GuiControl,Text,shadowTextTL		; Top Left text shadow
GuiControl,Text,shadowTextTR		; Top Right text shadow
GuiControl,Text,shadowTextBL		; Bottom Left text shadow
WinSet,%winsetParamFirst%,%winsetParamSecond%,%A_ScriptName%		; this two copies the ones that is above (3 lines) but are used to be configurable from tray
WinSet,ExStyle,%winsetParamThird%,%A_ScriptName%	

;------------------------------------------------------------------------------------------------------------------------
SetTimer, main, 20	; i choose 20, but also 16 - because "Due to the granularity of the OS's time-keeping system, Period is typically rounded up to the nearest multiple of 10 or 15.6 milliseconds" (it could vary i suppose on different machines)

;Gosub, SettingsAdvanced

Return


main:						; main logic for determening pressed keys (not showing them)

;tooltip % getKeyboardLang() ; check language
oldkeys:=keys 
keys=

;---------------------------------------"for each" variant.....
for arr_key, key_val in keyarray_arr	; for each on average 3% faster then loop, at least as i measured
{
	key:=key_val
	if GetKeyState(key,P)				; if physically (P) current key is pushed. Exception: non english languages (f.e.:UKR\RUS), when RAlt is pressed, it triggers LCtrl also, = RAlt + LCtrl if only RAlt is pressed
		keys=%keys% %key%    		 	; this line lets you merge several pressed buttons
}
;---------------------------------------....."for each" variant


;---------------------------------------"loop" variant.....
;Loop % keyarray_arr.length()			; loop is on average 3% slower then for each. лупаем кол-о раз, сколько в keyarray строк,служит местом для хранения показателя размера массива
;{
;	key:=keyarray_arr[A_Index] 		 	; assign to "key" a value from all buttons list (array)
;	if (state:=GetKeyState(key,P))
;		keys=%keys% %key%    		 	; this line lets merge several pressed buttons
;}
;---------------------------------------....."loop" variant
	

if (keys!=oldkeys) 						; this line (and further absence of "else" line) will force "main" subroutine(settimer) to not draw keys on gui if they are the same from previous loop (if you are holding same keyboard\mouse keys)
	guiText_Outline(keys,outlineFont)
Return


guiText_Outline(byref keys, byref outlineFont)		; function for outlining or not outlining text
{
	if outlineFont=1
	{
		GuiControl,,textMain,%keys%			; send to gui variable "text" - "keys" value	
		GuiControl,,shadowTextBR,%keys%		; sending text to bottom right(BR) shadow variable for GUI
		GuiControl,,shadowTextTL,%keys%		; sending text to top left(TL) shadow variable for GUI
		GuiControl,,shadowTextTR,%keys%		; sending text to top right shadow variable for GUI
		GuiControl,,shadowTextBL,%keys%		; sending text to bottom left shadow variable for GUI
	} else if outlineFont=0
		GuiControl,,textMain,%keys%			; send to gui variable "text" - "keys" value
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

/*
correction: 									; for double mousewheels correction in gui
for each_key, each_val in dblKeys
{
	if keys contains % dblKeys[A_Index]
		StringReplace, keys, keys, % dblKeys[A_Index],% dblKeys_r[A_Index], All
	guiText_Outline(keys,outlineFont)
}
return
*/

;-----------------------------------.....MouseWheels show

;-----------------------------------Moving UI..... 
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
;-----------------------------------.....Moving UI 

TRAYMENU_alt:																	; my Tray		  
Menu, Tray, Tip, % "      Double-Click to Reload`n"+							; tooltip in tray
					+"----------------------------------"+						
					+"`n               Pause script:`n"+
					+"  [Up/Down/Left/Right]+[Pause]"							; tooltip in tray
Menu, Tray, NoStandard															; deletes all standard tray menus
Menu, Tray, Add, Reload Script, ReloadMenu										; adds menu in tray "Reload script" and calls for "ReloadMenu" label
Menu, Tray, Add, Pause Script, PauseSCRPT
Menu, Tray, Add 																; separator

Menu, Submenu, Add, Move Script, SettingsMove	
Menu, Submenu, Add, Script Background, SettingsBackground
Menu, Submenu, Add, Always On Top, SettingsAOT
Menu, Submenu, Add																; separator
Menu, Submenu, Add, Advanced (test), SettingsAdvanced
Menu, Tray, Add, Settings, :Submenu

Menu, Tray, Add, Exceptions, ShowExceptions
Menu, Tray, Add 																; separator
Menu, Tray, Add, Exit, CloseExit		
Menu, Tray, Default, Reload Script 														; makes "Reload script" menu default choice
Menu, Tray, Click, %trayclicks%															; you can choose click amount to trigger default tray menu when clicked on tray icon (1-2)
Menu, Submenu, % (aot="+AlwaysOnTop" ? "Check" : "Uncheck"), Always On Top 				; ternary if variable aot="+alwaysontop" = check, else = uncheck
Menu, Submenu, % (moveMode="1" ? "check" : "uncheck"), Move Script 						
Menu, Submenu, % (backgroundMode="1" ? "Check" : "Uncheck"), Script Background
Menu, Tray, Uncheck, Pause Script														; start script with unchecked Pause Script menu in tray
Return									

SettingsAdvanced:
	Gui,Destroy	
	
Gui Add, GroupBox, x15 y18 w530 h271, COLORS	
Gui Add, Text, x20 y50 w275 h20 vAdvText, Background Color:
Gui Add, Edit, x20 y65 w146 h15 vAdvEdit, %backcolor%
Gui Add, Button, x175 y65 w55 h15 gAdvSave, &Save
Gui Add, Button, x235 y65 w65 h15 gAdvRestore, &Restore
Gui Add, Button, x305 y65 w65 h15 gAdvDefault, &Default
Gui Add, Text, x150 y35 w120 h15 vAdvText_1 +0x1000, % " Text_1"

Gui Show, w400 h200, testingstuff

backcolor_temp:=backcolor

return

AdvSave:
	GuiControlGet, backcolor,, AdvEdit
	rewriteCode()
return

AdvRestore:
	GuiControl, , AdvEdit, %backcolor_temp%
return

AdvDefault:
	GuiControl, , AdvEdit, 00ff00
return

GuiClose:
	Gosub, ReloadMenu
	;ExitApp
return

ReloadMenu:
	rewriteCode()
	Reload
Return

CloseExit:
	rewriteCode()
	ExitApp
Return


ShowExceptions:

scrptWasPaused:=PauseSCRPT_Var=1 ? 1 : 0							; saving PAUSE state before opening exception window

global ExceptionsTitle:=" Words - Exceptions"						; exceptions MsgBox title
global ExceptionsTitle1:="Add Word"									; exceptions>"Add Word" InputBox title
global ExceptionsTitle2:="Delete Word"								; exceptions>"Delete Word" InputBox title


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
	;IfWinNotExist % ExceptionsTitle1	
	;IfWinNotExist % ExceptionsTitle2
	Menu, Tray, ToggleCheck, Pause Script
	soundbeep % (PauseSCRPT_Var!=1 ? beep1 : beep2), beepLength
	PauseSCRPT_Var:=(PauseSCRPT_Var!=1 ? 1 : 0)
	PauseScript()
return


PauseScript()
{
	Global
	if (PauseSCRPT_Var!=1)				; pay attention, in previous block(PauseSCRPT) we changed value in PauseSCRPT_Var
		Gosub, guistart
	else 
		Gui,Destroy
	Suspend, Toggle						; disables or enables all hotkeys\hotstrings
	SetTimer, main,% (PauseSCRPT_Var=1 ? "Off" : "20") ; !!!!!!!!!!!!!!!!!!!!
}
return



SettingsBackground:
		Menu, Submenu, ToggleCheck, Script Background 
		backgroundMode:=(backgroundMode!=1 ? 1 : 0)
		/*
		if (moveMode=1)												; если галочка MOVE стоит, внезависимости от того в каком состоянии галка BACKGROUND
		{
			backgroundMode:=!backgroundMode							; оставляем MOVE режим активным, но переключаем показатель между прозрачным и бекграунд режимами (все равно потом при отключении режима MOVE функция опросит переменную BACKGROUND прежде чем отрисует GUI)
		} else if (backgroundMode=0 && moveMode=0)					; если BACKGROUND галочка не стояла в то время как галочка MOVE убрана
		if (backgroundMode=0 && moveMode=0)							; если BACKGROUND галочка не стояла в то время как галочка MOVE убрана
		{											
			;backgroundMode:=!backgroundMode								
			winsetParamFirst=TransColor								; бекграунд (прокликиваемый) режим
			winsetParamSecond=zxc %transparency%					; zxc - because it's absolutely random letters and will not interfere with any color. here must be color (f.e. "FFFFFF" or "000000" or "blue"/"red etc.), but it interfere with some inputs from users when configuring colors in settings block
			winsetParamThird=+0x20
		}  else if (backgroundMode=1 && moveMode=0)					; если BACKGROUND галочка стояла в то время как галочка MOVE убрана
		{
			;backgroundMode:=!backgroundMode					
			winsetParamFirst=TransColor								; прозрачный(прокликиваемый) режим
			winsetParamSecond=%eliminateColorFromUI% %transparency%
			winsetParamThird=+0x20
		} 
		*/								
		gui_rewrite()
return


SettingsMove:
	Menu, Submenu, ToggleCheck, Move Script
	moveMode:=(moveMode!=1 ? 1 : 0)	
	;Gosub, CHECKS_MOVE_BACK
	gui_rewrite()
Return


SettingsAOT:
	Menu, Submenu, ToggleCheck, Always On Top
	aot:=(aot="+AlwaysOnTop" ? "-AlwaysOnTop" : "+AlwaysOnTop")
	;Gosub, CHECKS_AOT
	gui_rewrite()
Return

gui_rewrite()
{
	Global						; to read PauseSCRPT_Var value
	if (PauseSCRPT_Var!=1) 		; if pause is turned OFF we start our gui with all of its functions in the beginning
		Gosub, guistart
	else if (PauseSCRPT_Var=1)	; if pause is turned ON we only write changes to code
		rewriteCode()			; write all of changes in code
		;msgbox ,0x30, Script is Paused, Unpause Script!,5
}
Return

/*
CHECKS_AOT:
	aot:=(aot="+AlwaysOnTop" ? "-AlwaysOnTop" : "+AlwaysOnTop")
	;iconCheck()
	rewriteCode()
	;Gosub, guistart	
Return
*/

/*
CHECKS_MOVE_BACK:
	;makeUI_MOVE_BACK(moveMode=1 ? 1 : 0)
																		;makeUI_MOVE_BACK()
																		;SetTimer, uiMove, % (moveMode=1 ? "1" : "Delete")
	;rewriteCode()

if (moveMode=0) 
{
	moveMode:=!moveMode
	makeUI_MOVE_BACK(1)
	;iconCheck()
	SetTimer, uiMove, 1
}
else if (moveMode=1)
{
	moveMode:=!moveMode
	makeUI_MOVE_BACK(0)
	;iconCheck()
	SetTimer, uiMove, Delete
}
;rewriteCode()
Gosub, guistart
																					;iconCheck()
Return
*/

iconCheck()
{
	Global																; To refer to an existing global variable inside a function
	if (winsetParamFirst="TransColor" && aot="+AlwaysOnTop")			; transparent\background mode + АОТ(allways on top)
	{
		IfExist, % mainIcon
		Menu, Tray, Icon, % mainIcon
	} else if (winsetParamFirst="TransColor" && aot="-AlwaysOnTop")		; transparent\background mode - АОТ
	{
		IfExist, % mainIconB
		Menu, Tray, Icon, % mainIconB
	} else if (winsetParamFirst="Transparent" && aot="+AlwaysOnTop")	; mode MOVE + AOT
	{
		IfExist, % configureIcon
		Menu, Tray, Icon, % configureIcon
	} else if (winsetParamFirst="Transparent" && aot="-AlwaysOnTop")	; mode MOVE - AOT
	{
		IfExist, % configureIconB
		Menu, Tray, Icon, % configureIconB
	}
}
return


makeUI_MOVE_BACK() 											
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

/*
check4GUILocation(GUILocationStatus)
{
	Loop, Read, %A_ScriptFullPath%
	{
		if (InStr(A_LoopReadLine, "status" GUILocationStatus)) ; status x= / status y= (incoming "GUILocationStatus" value)
		{
			myGUILocationFromCodeList.=SubStr(A_LoopReadLine, 9, InStr(A_LoopReadLine, ";")-9)
			myGUILocationFromCodeList=%myGUILocationFromCodeList%   ; cleans from whitespaces (AutoTrim is ON by default if using "var=%var%" method
			break
		}
	}
return myGUILocationFromCodeList
}
*/

/*
getHotstringsArr(HSListSetting)			
{
myHSList = Words - Exceptions List:`n`n
myHSListArr := []		
	Loop, Read, %A_ScriptFullPath%
		if (InStr(A_LoopReadLine, htstrngSrchKeyW)) 													; 
			myHSListArr[A_Index] := SubStr(A_LoopReadLine, 7, InStr(A_LoopReadLine, "::")-7) 	; 7 because our keyword "B0?..." is 6 length
	if (HSListSetting=list)																		; 1 is for showing hoststrings list
	{
		for HSArrayLineNums, HSArrayValues in myHSListArr										; to see what is inside array							
			if (a_index>2)																		; ignoring first two occurance's of "B0?". this is for ignoring code logic line and starting showing only real hotstrings from number 1. number 1("ShowPAS") and 2("ЫрщцЗФЫ") and 3 are examples
				myHSList.= a_index-2 ". " HSArrayValues "`n"									; -2  because we are ignoring first occurances (in code where logic is applied)
		;return % RegExReplace(myHSList, "\R+\R", "`r`n")										; regex for removing all blank lines	
		return myHSList
	} else if (HSListSetting="array")	 														; 1 is for showing hoststrings list
		return myHSListArr
return
}
*/

rewriteCode()
{
	Global
	q_m := chr(34)																	; problems with "Double quotes" : ["] so i made them like this. ASCII printable code
	
	lineNumArr := arr_of_srchdLine("global statusx=", A_Tab, "paramFullInfo")		; getting an array and giving it a string to search for "global status x=" and the character on which the string search should be stopped "A_Tab"
	if (linenumarr[5]!=statusx)														; if current value of "statusx" is not equal to what value is literally written in code, then rewrite code
		replaceCodeLine(lineNumArr, statusx, 1)										; replacing the value in the code at "statusx" line with current (changed) "statusx" value while saving the comment part of line

	lineNumArr := arr_of_srchdLine("global statusy=", A_Tab, "paramFullInfo")	
	if (linenumarr[5]!=statusy)
		replaceCodeLine(lineNumArr, statusy, 1)		
												
	lineNumArr := arr_of_srchdLine("global aot:="q_m, q_m A_Tab, "paramFullInfo")	
	if (linenumarr[5]!=aot)
		replaceCodeLine(lineNumArr, aot, 1)
	
	lineNumArr := arr_of_srchdLine("global moveMode=", A_Tab, "paramFullInfo")
	if (linenumarr[5]!=moveMode)	
		replaceCodeLine(lineNumArr, moveMode, 1)
	
	lineNumArr := arr_of_srchdLine("global backgroundmode=", A_Tab, "paramFullInfo")
	if (linenumarr[5]!=backgroundmode)
		replaceCodeLine(lineNumArr, backgroundmode, 1)
		
		
	;;;;;;;;;;;;;;;;;;;;;;
	lineNumArr := arr_of_srchdLine("backcolor=", A_Tab, "paramFullInfo")
	if (linenumarr[5]!=backcolor)
		replaceCodeLine(lineNumArr, backcolor, 1)
	;;;;;;;;;;;;;;;;;;;;;;
return
}

arr_of_srchdLine(receivedKeyword, whenToStop, settingCode)
{
	thatList = Add the words which are first characters of`nyour password, so when you start typing`nyour password, script will pause for %suspendTimerCntr% sec.`n`nWords - Exceptions:`n
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
			if (a_index>2)																; ignoring first 3 occurance's of "B0?" in code. this is for ignoring code logic lines and starting showing only real hotstrings from number 1. number 1("passw") and 2("зфыыц") and 3 which are examples
				thatList.= a_index-2 ". " arrayValues "`n"								; -2  because we are ignoring first occurances (in code where logic is written and applied)
	return settingCode="list" ? thatList : thatArray
}


replaceCodeLine(rcvdArr, writeNewLine, what_to_do) 
{
	oFileReplace := FileOpen(A_ScriptFullPath, "rw")
	;start := oFileReplace.Pos				;original code (looks unnecessary)
	if rcvdArr[1]							; check if we found in file our keyword (so if it is not found the code would not delete every single line of code)
		{
			Loop % what_to_do=3 ? (rcvdArr[1]+writeNewLine) : rcvdArr[1]   						; what_to_do = 3 for deleting. if deleting, writenewline will receive number, Arr[1] is line number
			;Loop % rcvdArr[1] 
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

/*
DeleteLeadingLines(startingDeletionLine, howManyToDelete) 
{
	If (FO := FileOpen(A_ScriptFullPath, "rw")) 
	{
		Loop % (startingDeletionLine+howManyToDelete)
		{
			lastActiveLine := FO.ReadLine()
			if (A_Index = (startingDeletionLine-1))
				StartingPos := FO.Pos	
			if (A_Index = ((startingDeletionLine+howManyToDelete)-1))	
				SavedContent := FO.Read()
		}
				FO.Pos := StartingPos
				FO.Write(SavedContent)
				FO.Length := FO.Pos
				FO.Close()		
   }
}
*/

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
				;tooltip,,,,%tooltipvar%			; cleans tooltip
				tooltip								; cleans tooltip
				return								; stops function
			} 
			if (timeLeftBW>=0)						; reverse countdown
				;tooltip % timeLeftBW,,,tooltipVar
				tooltip % timeLeftBW
			else break								; stops loop
		}	
		;if PauseSCRPT_Var=1							
		Gosub, PauseSCRPT

		;tooltip,,,,%tooltipvar%					
		tooltip
	}
}
return




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
:B0?*:msip::
blckdWord(4)
return

:B0?*:ьышз::
blckdWord(4)
return

:B0?*:alla::
blckdWord(4)
return

:B0?*:фддф::
blckdWord(4)
return

;---------------- .....BLOCKED WORDS ---------------------------;
