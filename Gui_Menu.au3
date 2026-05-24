#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
#include <StaticConstants.au3>
#include <ComboConstants.au3>
#include <ButtonConstants.au3>

If Not IsDeclared("Botname") Then Global $Botname = "Gwen's Redemption"
If Not IsDeclared("ThemeLabelColor") Then Global $ThemeLabelColor = 0xFFFFFF
If Not IsDeclared("LabelColor") Then Global $LabelColor = 0xFFFFFF
Global $WPDefaultFullpath = @ScriptDir & "\images\gwen.jpg"

If Not FileExists($WPDefaultFullpath) Then
    $WPDefaultFullpath = ""
EndIf

; --- Gwen's Redemption GUI globals added for MustDeclareVars ---
Global $DefaultBG = 0
Global $LeaderInput = 0
Global $Follower = 0
Global $OpenChestsLabel = 0
Global $Radio_Placement = 0
Global $CheckboxSkill[9]
Global $SkillID[9]
Global $AdrenalineSkill[9]
Global $NRLockpicks = 0
Global $StatusColor = 0xFFFFFF
Global $StatusBgColor = 0x000000
; ------------------------------------------------------------

#Region ### START Koda GUI section ### Form=
Local Const $GUI_W = 500
Local Const $GUI_H = 540
; Standard window frame with title bar, minimize, and close (like AscEnd).
Global $mainGui = GUICreate($Botname, $GUI_W, $GUI_H, -1, -1, -1, $WS_EX_WINDOWEDGE)
GUISetOnEvent($GUI_EVENT_CLOSE, "_exit")
HotKeySet("{ESC}", "_exit")
If $WPDefaultFullpath <> "" Then
	$DefaultBG = GUICtrlCreatePic($WPDefaultFullpath, 0, 0, $GUI_W, $GUI_H)
	GUICtrlSetState($DefaultBG, $GUI_DISABLE)
Else
	$DefaultBG = GUICtrlCreateLabel("", 0, 0, $GUI_W, $GUI_H)
	GUICtrlSetBkColor(-1, 0x0a2431)
	GUICtrlSetState(-1, $GUI_DISABLE)
EndIf

; --- Layout constants ---
Local Const $GUI_LX = 20
Local Const $GUI_COLW = 127     ; left column width (matches Start button)
Local Const $GUI_ROW = 18       ; standard vertical spacing
Local Const $GUI_FX = 340       ; follower position (left of laptop pair)
Local Const $GUI_FY = 252       ; shared top for follower position + skills
Local Const $GUI_SX = 346       ; skill slots (right of compass)
Local Const $GUI_OPT_Y = 366    ; combat / flag options (left, below skill rows)
Local Const $GUI_OPT_AFTER_FIGHT = 22   ; 5px below fight row
Local Const $GUI_OPT_GAP = 21           ; spacing between dropdown rows (+3px)
Local Const $GUI_LOG_Y = 400
Local Const $GUI_LOG_W = 460
Local Const $GUI_LOG_H = 80
Local Const $GUI_SKILL_Y = 278   ; skill rows (left column, below pickup block)
Local Const $GUI_SKILL_GAP = 30  ; horizontal gap between skill checkboxes
Local Const $GUI_SKILL_SIZE = 15 ; slightly larger click target

Global $LabelLeader = GUICtrlCreateLabel("Leader Name :", $GUI_LX, 28, 95, 17)
	GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
	GUICtrlSetFont(-1, 8, 800, 0, "MS Sans Serif")
	GUICtrlSetColor(-1, $LabelColor)
Global $LeaderInput = GUICtrlCreateCombo("", $GUI_LX, 46, 100, 21)
	GUICtrlSetData(-1, "")
	GUICtrlSetState(-1, $GUI_ENABLE)
Global $iRefresh = GUICtrlCreateButton("", $GUI_LX + 104, 45, 23, 23, $BS_ICON)
	GUICtrlSetImage($iRefresh, "shell32.dll", -239, 0)
	GUICtrlSetOnEvent(-1, "RefreshInterface")

Global $Label2 = GUICtrlCreateLabel("Follower Name :", $GUI_LX, 78, 103, 17)
	GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
	GUICtrlSetFont(-1, 8, 800, 0, "MS Sans Serif")
	GUICtrlSetColor(-1, $LabelColor)
Global $Follower = GUICtrlCreateCombo("", $GUI_LX, 96, 100, 21)
	GUICtrlSetData(-1, "")
	GUICtrlSetState(-1, $GUI_ENABLE)
	GUICtrlSetOnEvent(-1, "StartButton")
Global $iRefresh2 = GUICtrlCreateButton("", $GUI_LX + 104, 95, 23, 23, $BS_ICON)
	GUICtrlSetImage($iRefresh2, "shell32.dll", -239, 0)
	GUICtrlSetOnEvent(-1, "RefreshInterface2")

Global $Button = GUICtrlCreateButton("Start", $GUI_LX, 128, 127, 24)
	GUICtrlSetFont(-1, 8, 800, 0, "MS Sans Serif")
	GUICtrlSetState(-1, $GUI_DISABLE)
	GUICtrlSetOnEvent(-1, "GuiButtonHandler")

;Skill slots (left column - avoids drag handler eating clicks on the right-side artwork)
GUIStartGroup()
GUICtrlCreateLabel("Skills to use :", $GUI_LX, $GUI_SKILL_Y, 90, 15)
	GUICtrlSetFont(-1, 8, 800, 0, "MS Sans Serif")
	GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
	GUICtrlSetColor(-1, $LabelColor)
For $i = 1 To 4
	GUICtrlCreateLabel(String($i), $GUI_LX + 2 + ($i - 1) * $GUI_SKILL_GAP, $GUI_SKILL_Y + 14, 10, 13)
		GUICtrlSetFont(-1, 8, 800, 0, "MS Sans Serif")
		GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
		GUICtrlSetColor(-1, $LabelColor)
	$CheckboxSkill[$i] = GUICtrlCreateCheckbox("", $GUI_LX + ($i - 1) * $GUI_SKILL_GAP, $GUI_SKILL_Y + 28, $GUI_SKILL_SIZE, $GUI_SKILL_SIZE)
		GUICtrlSetOnEvent(-1, "gui_SkillHandler")
Next
For $i = 5 To 8
	GUICtrlCreateLabel(String($i), $GUI_LX + 2 + ($i - 5) * $GUI_SKILL_GAP, $GUI_SKILL_Y + 46, 10, 13)
		GUICtrlSetFont(-1, 8, 800, 0, "MS Sans Serif")
		GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
		GUICtrlSetColor(-1, $LabelColor)
	$CheckboxSkill[$i] = GUICtrlCreateCheckbox("", $GUI_LX + ($i - 5) * $GUI_SKILL_GAP, $GUI_SKILL_Y + 60, $GUI_SKILL_SIZE, $GUI_SKILL_SIZE)
		GUICtrlSetOnEvent(-1, "gui_SkillHandler")
Next

;Pickup loot (compact block below start)
GUIStartGroup()
Global $FPickuplabel = GUICtrlCreateLabel("Pickup loot :", $GUI_LX + 4, 162, 75, 15)
	GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
	GUICtrlSetColor(-1, $LabelColor)
	GUICtrlSetFont(-1, 8, 800, 0, "MS Sans Serif")
Global $FPickup = GUICtrlCreateCheckbox("", $GUI_LX, 178, 13, 13)
	GUICtrlSetOnEvent(-1, "gui_LootHandler")
Local $FPickupYesLabel = GUICtrlCreateLabel("Yes", $GUI_LX + 16, 178, 25, 17)
	GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
	GUICtrlSetColor(-1, $LabelColor)
Global $FPickupNo = GUICtrlCreateCheckbox("", $GUI_LX + 44, 178, 13, 13)
	GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
	GUICtrlSetOnEvent(-1, "gui_LootHandler")
Local $FPickupNoLabel = GUICtrlCreateLabel("No", $GUI_LX + 60, 178, 20, 17)
	GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
	GUICtrlSetColor(-1, $LabelColor)
Global $FPickupGreen = GUICtrlCreateCheckbox("", $GUI_LX, 196, 13, 13)
	GUICtrlSetOnEvent(-1, "gui_CheckboxWriteConfig")
Local $GreenLabel = GUICtrlCreateLabel("Green", $GUI_LX + 16, 196, 40, 16)
	GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
	GUICtrlSetColor(-1, $LabelColor)
Global $FPickupGold = GUICtrlCreateCheckbox("", $GUI_LX + 58, 196, 13, 13)
	GUICtrlSetOnEvent(-1, "gui_CheckboxWriteConfig")
Local $GoldLabel = GUICtrlCreateLabel("Gold", $GUI_LX + 74, 196, 40, 16)
	GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
	GUICtrlSetColor(-1, $LabelColor)
Global $FPickupPurple = GUICtrlCreateCheckbox("", $GUI_LX, 212, 13, 13)
	GUICtrlSetOnEvent(-1, "gui_CheckboxWriteConfig")
Local $PurpleLabel = GUICtrlCreateLabel("Purple", $GUI_LX + 16, 212, 45, 16)
	GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
	GUICtrlSetColor(-1, $LabelColor)
Global $FPickupBlue = GUICtrlCreateCheckbox("", $GUI_LX + 58, 212, 13, 13)
	GUICtrlSetOnEvent(-1, "gui_CheckboxWriteConfig")
Local $BlueLabel = GUICtrlCreateLabel("Blue", $GUI_LX + 74, 212, 40, 16)
	GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
	GUICtrlSetColor(-1, $LabelColor)
Global $FPickupWhite = GUICtrlCreateCheckbox("", $GUI_LX, 228, 13, 13)
	GUICtrlSetOnEvent(-1, "gui_LootHandler")
Local $WhiteLabel = GUICtrlCreateLabel("White", $GUI_LX + 16, 228, 40, 16)
	GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
	GUICtrlSetColor(-1, $LabelColor)
Global $AllMats = GUICtrlCreateCheckbox("", $GUI_LX + 58, 228, 13, 13)
	GUICtrlSetOnEvent(-1, "gui_CheckboxWriteConfig")
Local $AllMatsLabel = GUICtrlCreateLabel("Mats", $GUI_LX + 74, 228, 35, 16)
	GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
	GUICtrlSetColor(-1, $LabelColor)
Global $RareMats = GUICtrlCreateCheckbox("", $GUI_LX, 244, 13, 13)
	GUICtrlSetOnEvent(-1, "gui_CheckboxWriteConfig")
Local $RareMatsLabel = GUICtrlCreateLabel("Rare", $GUI_LX + 16, 244, 35, 16)
	GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
	GUICtrlSetColor(-1, $LabelColor)
Global $PConsLoot = GUICtrlCreateCheckbox("", $GUI_LX + 58, 244, 13, 13)
	GUICtrlSetOnEvent(-1, "gui_CheckboxWriteConfig")
Local $PConsLootLabel = GUICtrlCreateLabel("PCons", $GUI_LX + 74, 244, 40, 16)
	GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
	GUICtrlSetColor(-1, $LabelColor)
Global $Tomes = GUICtrlCreateCheckbox("", $GUI_LX, 260, 13, 13)
	GUICtrlSetOnEvent(-1, "gui_CheckboxWriteConfig")
Local $TomesLabel = GUICtrlCreateLabel("Tomes", $GUI_LX + 16, 260, 40, 16)
	GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
	GUICtrlSetColor(-1, $LabelColor)
Global $OpenChests = GUICtrlCreateCheckbox("", $GUI_LX + 58, 260, 13, 13)
	GUICtrlSetTip(-1, "Uses Lockpicks", "")
	GUICtrlSetOnEvent(-1, "gui_CheckboxWriteConfig")
Global $OpenChestsLabel = GUICtrlCreateLabel("Chests(" & $NRLockpicks & ")", $GUI_LX + 74, 260, 70, 16)
	GUICtrlSetTip(-1, "Uses Lockpicks", "")
	GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
	GUICtrlSetColor(-1, $LabelColor)
;End pickup loot

;Follower Position (lower-right, over laptop in artwork)
GUIStartGroup()
	GUICtrlCreateLabel("Follower Position", $GUI_FX, $GUI_FY, 110, 17)
	GUICtrlSetFont(-1, 8, 800, 0, "MS Sans Serif")
	GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
	GUICtrlSetColor(-1, $ThemeLabelColor)

	$Radio_Placement = GUICtrlCreateCombo("9", $GUI_FX + 30, $GUI_FY + 49, 40, 17, BitOR($CBS_DROPDOWN,$CBS_AUTOHSCROLL))
	GUICtrlSetFont(-1, 8, 800, 0, "MS Sans Serif")
	GUICtrlSetTip(-1, "Choose follower position", "")
	GUICtrlSetOnEvent(-1, "FollowPos")

Local $FL1 = GUICtrlCreateLabel("1", $GUI_FX + 46, $GUI_FY + 19, 14, 12)
	GUICtrlSetFont(-1, 8, 800, 0, "MS Sans Serif")
	GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
	GUICtrlSetColor(-1, $LabelColor)
Local $FL2 = GUICtrlCreateLabel("2", $GUI_FX + 58, $GUI_FY + 22, 14, 12)
	GUICtrlSetFont(-1, 8, 800, 0, "MS Sans Serif")
	GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
	GUICtrlSetColor(-1, $LabelColor)
Local $FL16 = GUICtrlCreateLabel("16", $GUI_FX + 27, $GUI_FY + 22, 14, 12)
	GUICtrlSetFont(-1, 8, 800, 0, "MS Sans Serif")
	GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
	GUICtrlSetColor(-1, $LabelColor)
Local $FL3 = GUICtrlCreateLabel("3", $GUI_FX + 69, $GUI_FY + 30, 14, 12)
	GUICtrlSetFont(-1, 8, 800, 0, "MS Sans Serif")
	GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
	GUICtrlSetColor(-1, $LabelColor)
Local $FL15 = GUICtrlCreateLabel("15", $GUI_FX + 15, $GUI_FY + 32, 14, 12)
	GUICtrlSetFont(-1, 8, 800, 0, "MS Sans Serif")
	GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
	GUICtrlSetColor(-1, $LabelColor)
Local $FL4 = GUICtrlCreateLabel("4", $GUI_FX + 76, $GUI_FY + 40, 14, 12)
	GUICtrlSetFont(-1, 8, 800, 0, "MS Sans Serif")
	GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
	GUICtrlSetColor(-1, $LabelColor)
Local $FL14 = GUICtrlCreateLabel("14", $GUI_FX + 8, $GUI_FY + 42, 14, 12)
	GUICtrlSetFont(-1, 8, 800, 0, "MS Sans Serif")
	GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
	GUICtrlSetColor(-1, $LabelColor)
Local $FL5 = GUICtrlCreateLabel("5", $GUI_FX + 79, $GUI_FY + 52, 14, 12)
	GUICtrlSetFont(-1, 8, 800, 0, "MS Sans Serif")
	GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
	GUICtrlSetColor(-1, $LabelColor)
Local $FL13 = GUICtrlCreateLabel("13", $GUI_FX + 5, $GUI_FY + 52, 14, 12)
	GUICtrlSetFont(-1, 8, 800, 0, "MS Sans Serif")
	GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
	GUICtrlSetColor(-1, $LabelColor)
Local $FL6 = GUICtrlCreateLabel("6", $GUI_FX + 76, $GUI_FY + 64, 14, 12)
	GUICtrlSetFont(-1, 8, 800, 0, "MS Sans Serif")
	GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
	GUICtrlSetColor(-1, $LabelColor)
Local $FL12 = GUICtrlCreateLabel("12", $GUI_FX + 9, $GUI_FY + 64, 14, 12)
	GUICtrlSetFont(-1, 8, 800, 0, "MS Sans Serif")
	GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
	GUICtrlSetColor(-1, $LabelColor)
Local $FL7 = GUICtrlCreateLabel("7", $GUI_FX + 69, $GUI_FY + 76, 14, 12)
	GUICtrlSetFont(-1, 8, 800, 0, "MS Sans Serif")
	GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
	GUICtrlSetColor(-1, $LabelColor)
Local $FL11 = GUICtrlCreateLabel("11", $GUI_FX + 16, $GUI_FY + 76, 14, 12)
	GUICtrlSetFont(-1, 8, 800, 0, "MS Sans Serif")
	GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
	GUICtrlSetColor(-1, $LabelColor)
Local $FL8 = GUICtrlCreateLabel("8", $GUI_FX + 58, $GUI_FY + 84, 14, 12)
	GUICtrlSetFont(-1, 8, 800, 0, "MS Sans Serif")
	GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
	GUICtrlSetColor(-1, $LabelColor)
Local $FL10 = GUICtrlCreateLabel("10", $GUI_FX + 29, $GUI_FY + 84, 14, 12)
	GUICtrlSetFont(-1, 8, 800, 0, "MS Sans Serif")
	GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
	GUICtrlSetColor(-1, $LabelColor)
Local $FL9 = GUICtrlCreateLabel("9", $GUI_FX + 46, $GUI_FY + 88, 14, 12)
	GUICtrlSetFont(-1, 8, 800, 0, "MS Sans Serif")
	GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
	GUICtrlSetColor(-1, $LabelColor)

;Combat options (left, below pickup)
GUIStartGroup()
Local $Fightlabel = GUICtrlCreateLabel("Fight :", $GUI_LX, $GUI_OPT_Y, 40, 15)
	GUICtrlSetFont(-1, 8, 800, 0, "MS Sans Serif")
	GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
	GUICtrlSetColor(-1, $LabelColor)
Global $FightYes = GUICtrlCreateCheckbox("", $GUI_LX + 44, $GUI_OPT_Y, 13, 13)
	GUICtrlSetOnEvent(-1, "gui_FightHandler")
Local $FightYesLabel = GUICtrlCreateLabel("Yes", $GUI_LX + 60, $GUI_OPT_Y, 25, 17)
	GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
	GUICtrlSetColor(-1, $LabelColor)
Global $FightNO = GUICtrlCreateCheckbox("", $GUI_LX + 84, $GUI_OPT_Y, 13, 13)
	GUICtrlSetOnEvent(-1, "gui_FightHandler")
Local $FightNoLabel = GUICtrlCreateLabel("No", $GUI_LX + 100, $GUI_OPT_Y, 25, 17)
	GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
	GUICtrlSetColor(-1, $LabelColor)

;Status log (full-width footer)
Global $StatusLabel = GUICtrlCreateEdit("-Leader account must be at top of party window." & @CRLF & "-Start multiple clients to follow/fight with more accounts." & @CRLF & "-Bot prioritizes called targets." & @CRLF & "-Scatter range: 700 | Aggro range: 900 (fixed)." & @CRLF & "-Pickup: dyes and lockpicks are always collected when loot is enabled." & @CRLF & "-Consumables in inventory are used automatically when their effect expires." & @CRLF & "-In explorable areas, drop a Superior ID Kit (model 5899) near the leader to halt followers." & @CRLF & "====================================================" & @CRLF, $GUI_LX, $GUI_LOG_Y, $GUI_LOG_W, $GUI_LOG_H, BitOR($ES_AUTOVSCROLL, $ES_WANTRETURN, $WS_VSCROLL))
	GUICtrlSetColor(-1, $StatusColor)
	GUICtrlSetBkColor(-1, $StatusBgColor)

Local $bInfo = GUICtrlCreateButton("Info", $GUI_LX + $GUI_LOG_W - 48, $GUI_LOG_Y - 24, 45, 20)
GUICtrlSetOnEvent(-1, "ShowInfo")

GUISetState(@SW_SHOW)
#EndRegion ###
;get GUI settings from config.ini
ReadConfig()
If ProcessExists("gw.exe") Then
	RefreshInterface()
	RefreshInterface2()
EndIf