# AXI Contextual Input Overlay

This project is a keyboard for the NohBoard application developed by TheNohT <https://github.com/ThoNohT/NohBoard/releases>

AXI Contextual Input Overlay Keyboard definition for TheNohT's NohBoard application.
Copy the AXI Contextual Overlay folder to your NohBoard\keyboards directory

![CIO sample](https://github.com/Toscany/axi_cio_keyboard/blob/main/AXI%20CIO%20sample.png)
![CIO Legend](https://github.com/Toscany/axi_cio_keyboard/blob/main/AXI%20Contextual%20Overlay/COI%20-%20Annotated.png)

If you wanted this overlay to be visible to you in game and also for easy discord streaming, then please us AHK v2 and make yourself some keybinds:

; +-----------------------------------------+
; | 				ED.ahk 					|	
; +-----------------------------------------+
; | This .ahk is written to take advantage  |
; | of AutoHotkey.portable ver 2			|
; | 										|
; +-----------------------------------------+

; Steam command line to skip the dumb launcher and launch Ody already
; cmd /c "MinEdLauncher.exe %command% /autorun /autoquit /edo"

; +-----------------------------------------+
; | 				Headers					|	
; +-----------------------------------------+

#UseHook
#MaxThreadsPerHotkey 2
#Warn  ; Enable warnings to assist with detecting common errors.

#SingleInstance force
DetectHiddenWindows true
; +-----------------------------------------+
; | 			Global Variables			|	
; +-----------------------------------------+
wID := "NohBoard"						;	|
if WinExist(wID)						;	|
	wID := WinGetID(wID)				;	|
;-------------------------------------------+


; +-----------------------------------------+
; |				Keyboard Binds				|
; +-----------------------------------------+

^F2:: Reload ; CTRL + F2
F2:: ; NohBoard transparency settings
{
	WinSetAlwaysOnTop -1, wID
	WinSetTransparent 60, wID
	WinSetStyle _NoTitleNoDecorations := "-0xC40000", wID
	WinSetStyle _WinDisabled := "+0x8000000", wID
	WinSetExStyle _Clickthrough := "+0x20", wID
	WinSetRegion "0-0 w380 h550  r100-100", wID
	
	; disable the Windows Default Beep Win + R control mmsys.cpl
	
	;WinSetRegion , wID
}
F3:: ; Enable NohBoard
{
	WinSetStyle _WinDisabled := "-0x8000000", wID
	WinSetExStyle _disClickthrough := "-0x20", wID
}
