#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=..\satisfactory_YtH_icon.ico
#AutoIt3Wrapper_Compression=4
#AutoIt3Wrapper_Res_Comment=A15 forever
#AutoIt3Wrapper_Res_Description=BogSatisfactoryHelper
#AutoIt3Wrapper_Res_Fileversion=1.1.0.2
#AutoIt3Wrapper_Res_Fileversion_AutoIncrement=p
#AutoIt3Wrapper_Res_LegalCopyright=© 2019
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
#cs ----------------------------------------------------------------------------
	Author: Bog (jeffbogg@gmail.com)
	Date: 05/31/2019
	Script Function: ARK Auto-Run, Auto-Craft

	Instructions for Auto-Run,Auto-Gather:
	!!MAKE SURE YOIO THE OPTION "Hold to Sprint" OFF IN THE OPTIONS SO YOU CAN AUTO-SPRINT WITHOUT HOLDING THE KEY
	TILDE KEY: Use to toggle your forward movement key on or off.

	Instructions for Auto-Craft:
	ALT + F5: Sets location of craft item button - leave mouse over craft item button while hitting alt + F5 - MUST BE SET BEFORE THE NEXT TWO OPTIONS WILL WORK!
	F6: Press to hold down craft button
	F7: Press to stop crafting

	Abort:
	ALT + End: If for any reason this script has issues and does not work or gets hung up, ALT+END will kill it.
#ce ----------------------------------------------------------------------------
#include <Timers.au3>
#include <Array.au3>
#include <Misc.au3>
#include <AutoItConstants.au3>

Opt("MouseClickDragDelay", 0) ; Alters the length of the brief pause at the start and end of a mouse drag operation.
Opt("MouseCoordMode", 1) ; Sets the way coords are used in the mouse functions, 0 = relative coords to the active window
Opt("SendCapslockMode", 0)

If Not FileExists(@ScriptDir & "\SH_Macros.ini") Then
	IniWrite(@ScriptDir & "\SH_Macros.ini", "Craft", "X", "0")
	IniWrite(@ScriptDir & "\SH_Macros.ini", "Craft", "Y", "0")
	Sleep(500)
EndIf

HotKeySet("z", "run_toggle") ; Press 'Tilde' key once to autorun, again to stop.
HotKeySet("!5", "_SetCraftCoords") ; Hold mouse over CRAFT button and press 'Alt'+'F5' to set the location of your button.
HotKeySet("!6", "_ClickCraft") ; Press F6 to start crafting
HotKeySet("!7", "_UnClickCraft") ; Press F7 to stop crafting
HotKeySet("!{END}", "Terminate") ; Hit Alt+End to kill the script no matter what operation is taking place

Global $Paused
Global $autorun = 0
Global $S = 0
Global $CraftTargetX = IniRead(@ScriptDir & "\SH_Macros.ini", "Craft", "X", "0")
Global $CraftTargetY = IniRead(@ScriptDir & "\SH_Macros.ini", "Craft", "Y", "0")
Global $user32dll = DllOpen("user32.dll") ; should be cleaned up at exit
Global $key_down_too_long = 1000 ; if key held down over a second reset it
; Global Array for timer functions corresponding to keys defined below
Global $key_timer[8] = [0, 0, 0, 0, 0, 0, 0, 0]
; Keys of interest are hotkey modifiers for ctrl, alt, win, and shift
Global Const $keys[8] = [0xa0, 0xa1, 0xa2, 0xa3, 0xa4, 0xa5, 0x5b, 0x5c]
;0xa0	LSHIFT
;0xa1	RSHIFT
;0xa2	LCTRL
;0xa3	RCTRL
;0xa4	LALT
;0xa5	RALT
;0x5b	LWIN
;0x5c	RWIN
Global $vkvalue = [0xa4, 0x5b, 14, 0xa0, 0xa2]
Global $handle = WinGetHandle("[TITLE:Satisfactory  ; CLASS:UnrealWindow]")

Func unstick_keys($force_unstick = False)
	Local $i

	;Format of DllCall to press/release a key
	;DllCall($dll,"int","keybd_event","int",$vkvalue,"int",0,"long",0,"long",0) 		;To press a key
	;DllCall($user32dll,"int","keybd_event","int",$vkvalue,"int",0,"long",2,"long",0) 	;To release a key

	If $force_unstick Then
		For $vkvalue In $keys
			DllCall($user32dll, "int", "keybd_event", "int", $vkvalue, "int", 0, "long", 2, "long", 0) ;Release each key
		Next
	Else
		$i = 0
		For $vkvalue In $keys
			If _IsPressed($vkvalue) Then
				If $key_timer[$i] = 0 Then
					$key_timer[$i] = _Timer_Init() ; initialize a timer to watch this key
				ElseIf TimerDiff($key_timer[$i]) >= $key_down_too_long Then ; check elapsed time
					DllCall($user32dll, "int", "keybd_event", "int", $vkvalue, "int", 0, "long", 2, "long", 0) ; release the key
					$key_timer[$i] = 0 ; reset the timer
				EndIf
			EndIf
			$i = $i + 1
		Next
	EndIf
EndFunc   ;==>unstick_keys

Func run_toggle()
	If $autorun = 0 Then
		Sleep(100)
		ControlSend($handle, Default, $handle, "{w DOWN}")
		Sleep(100)
		$autorun = 1
		unstick_keys()
		HotKeySet("{`}")
		HotKeySet("{`}", "run_toggle")
	Else
		Sleep(100)
		ControlSend($handle, Default, $handle, "{w UP}")
		Sleep(100)
		$autorun = 0
		unstick_keys()
		HotKeySet("{`}")
		HotKeySet("{`}", "run_toggle")
	EndIf
EndFunc   ;==>run_toggle
; Idle
While 1
	Sleep(10)
WEnd


Func _SetCraftCoords()
	$MousePos = MouseGetPos()
	IniWrite(@ScriptDir & "\SH_Macros.ini", "Craft", "X", $MousePos[0])
	IniWrite(@ScriptDir & "\SH_Macros.ini", "Craft", "Y", $MousePos[1])
	$CraftTargetX = $MousePos[0]
	$CraftTargetY = $MousePos[1]
	unstick_keys()
EndFunc   ;==>_SetCraftCoords

Func _ClickCraft()
	$MousePos = MouseGetPos()
		MouseMove($CraftTargetX, $CraftTargetY, 1)
		Sleep(50)
		MouseDown("left") ; Set the left mouse button state as down.
		;unstick_keys()
EndFunc   ;==>_ClickCraft

Func _UnClickCraft()
	$MousePos = MouseGetPos()
		MouseMove($CraftTargetX, $CraftTargetY, 1)
		Sleep(50)
		MouseUp("left") ; Set the left mouse button state as down.
		unstick_keys()
EndFunc   ;==>_UnClickCraft

Func Terminate()
	Exit
	unstick_keys(True)
	DllClose($user32dll)
	GUIDelete()
EndFunc   ;==>Terminate
