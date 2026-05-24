#RequireAdmin

#include "../../API/_GwAu3.au3"
#include "Constants/Bot_Constants.au3"
#include "Constants/Skill_Array.au3"
#include "Constants/Map_ID.au3"
#include "GwAu3_AddOns.au3"
#include "Gwens_Compat.au3"
#include "Gui_Functions.au3"

Opt("GUIOnEventMode", 1)

Global $Botname = "Gwen's Redemption"
Global $BotRunning = False

#include "Gui_Menu.au3"
#include "../../API/Plugins/UtilityAI/_UtilityAI.au3"

While Not $BotRunning
	If $g_Shutdown Then Exit
	Sleep(100)
WEnd

While True
	If $g_Shutdown Then Exit

	If Not $BotRunning Then
		Out("Gwen's Redemption is paused.")
		GUICtrlSetState($Button, $GUI_ENABLE)
		GUICtrlSetData($Button, "Start")

		While Not $BotRunning
			If $g_Shutdown Then Exit
			Sleep(100)
		WEnd
	EndIf

	If Map_GetInstanceInfo("IsLoading") Then
		$g_b_Gwen_ResignedThisZone = False
		$g_b_Gwen_SkipNextResign = False
		$g_i_Gwen_LastPconCheck = 0
	ElseIf Map_GetInstanceInfo("IsExplorable") Then
		; Run follow/fight FIRST after zoning so the follower does not stand still
		; while resign/pcon checks are running.
		If $BotRunning Then Main()

		; Resign once per new explorable, after the follow logic has had a chance to move.
		If $BotRunning Then _Gwen_TryResignOnZoneEntry()

		; Pcons are useful after portals, but scanning inventory every 30ms blocks follow.
		; Run immediately once per new map, then only every 5 seconds.
		If $BotRunning Then
			If $g_i_Gwen_LastPconCheck = 0 Or TimerDiff($g_i_Gwen_LastPconCheck) > 5000 Then
				UsePCons()
				$g_i_Gwen_LastPconCheck = TimerInit()
			EndIf
		EndIf
	Else
		If $BotRunning Then Main()
	EndIf

	Sleep($GWEN_FOLLOW_LOOP_MS)
WEnd
