
Func ReadConfig()
	if FileExists("config.ini") Then
		;Get Leader Names
		GUICtrlSetData($LeaderInput,IniRead("config.ini","Leaders","LeaderChoice", "False"))
		;Get LootData
		SetState($FPickup,IniRead("config.ini","PickupLoot","Pickup","False"))
		SetState($FPickupNo,IniRead("config.ini","PickupLoot","nopickup","False"))
		SetState($FPickupGreen,IniRead("config.ini","PickupLoot","green","False"))
		SetState($FPickupGold,IniRead("config.ini","PickupLoot","gold","False"))
		SetState($FPickupPurple,IniRead("config.ini","PickupLoot","purple","False"))
		SetState($FPickupBlue,IniRead("config.ini","PickupLoot","blue","False"))
		SetState($FPickupWhite,IniRead("config.ini","PickupLoot","white","False"))
		SetState($AllMats,IniRead("config.ini","PickupLoot","allmats","False"))
		SetState($RareMats,IniRead("config.ini","PickupLoot","raremats","False"))
		SetState($PConsLoot,IniRead("config.ini","PickupLoot","pcons","False"))
		SetState($Tomes,IniRead("config.ini","PickupLoot","tomes","False"))
		SetState($OpenChests,IniRead("config.ini","PickupLoot","Openchests","False"))
		;Get FightData
		SetState($FightYes,IniRead("config.ini","FightOptions","FightYes","False"))
		SetState($FightNO,IniRead("config.ini","FightOptions","FightNO","False"))
		GUICtrlSetData($Radio_Placement, "1|2|3|4|5|6|7|8|9|10|11|12|13|14|15|16", IniRead("config.ini","FightOptions","Radio_Placement","False"))
		Local $ChangedPos = GUICtrlRead($Radio_Placement)
		Local $FPos_Array[16] = [$FL1,$FL2,$FL3,$FL4,$FL5,$FL6,$FL7,$FL8,$FL9,$FL10,$FL11,$FL12,$FL13,$FL14,$FL15,$FL16]
		GUICtrlSetColor($FPos_Array[$ChangedPos-1], $ThemeLabelColor)
		;Get SkillData
		SetState($CheckboxSkill[1],IniRead("config.ini","Skills","Skill1","False"))
		SetState($CheckboxSkill[2],IniRead("config.ini","Skills","Skill2","False"))
		SetState($CheckboxSkill[3],IniRead("config.ini","Skills","Skill3","False"))
		SetState($CheckboxSkill[4],IniRead("config.ini","Skills","Skill4","False"))
		SetState($CheckboxSkill[5],IniRead("config.ini","Skills","Skill5","False"))
		SetState($CheckboxSkill[6],IniRead("config.ini","Skills","Skill6","False"))
		SetState($CheckboxSkill[7],IniRead("config.ini","Skills","Skill7","False"))
		SetState($CheckboxSkill[8],IniRead("config.ini","Skills","Skill8","False"))
		Out("Imported settings from config.ini")
	EndIf
EndFunc

Func SetState($GUICtrl,$boolean)
	If $boolean == "True" Then
		GUICtrlSetState($GUICtrl,$GUI_Checked)
	Else
		GUICtrlSetState($GUICtrl,$GUI_UnChecked)
	EndIf
EndFunc

Func ShowInfo()
	ShellExecute("Changelog.txt")
EndFunc

Func StartButton()
	If GUICtrlRead($Follower) <> "" Then
		GUICtrlSetState($Button, $GUI_ENABLE)
	EndIf
EndFunc


Func _Drag_Window()
	DllCall("user32.dll", "bool", "ReleaseCapture")
	DllCall("user32.dll", "lresult", "SendMessageW", "hwnd", $mainGui, "uint", 0xA1, "uintptr", 2, "intptr", 0)
EndFunc

Func gui_CheckboxWriteConfig()
	WriteConfig()
EndFunc

Func _GuiRoundCorners($h_win, $iR = 28)
	Local $aPos = WinGetPos($h_win)
	If @error Then Return 0

	Local $iW = $aPos[2]
	Local $iH = $aPos[3]
	Local $hRgn = DllCall("gdi32.dll", "handle", "CreateRoundRectRgn", "int", 0, "int", 0, "int", $iW + 1, "int", $iH + 1, "int", $iR, "int", $iR)[0]
	If Not $hRgn Then Return 0

	Local $aRet = DllCall("user32.dll", "int", "SetWindowRgn", "hwnd", $h_win, "handle", $hRgn, "int", 1)
	If $aRet[0] Then
		Return 1
	Else
		Return 0
	EndIf
EndFunc

Func gui_SkillHandler()
	Local $iSlot = _Gwen_SkillSlotFromCtrl(@GUI_CtrlId)
	If $iSlot = 0 Then Return

	If GUICtrlRead(@GUI_CtrlId) = $GUI_CHECKED Then
		Out("Skill slot " & $iSlot & " enabled")
	Else
		Out("Skill slot " & $iSlot & " disabled")
	EndIf
	WriteConfig()
EndFunc

Func _Gwen_SkillSlotFromCtrl($a_i_CtrlID)
	For $l_i_Idx = 1 To 8
		If $CheckboxSkill[$l_i_Idx] = $a_i_CtrlID Then Return $l_i_Idx
	Next
	Return 0
EndFunc

Func gui_FightHandler()
	switch (@GUI_CtrlId)
		Case $FightNO
			If GUICtrlRead($FightNO) == $GUI_UNCHECKED Then
				GUICtrlSetState($FightYes, $GUI_CHECKED)
			Else
				GUICtrlSetState($FightYes, $GUI_UNCHECKED)
			EndIf
		Case $FightYes
			If GUICtrlRead($FightYes) == $GUI_UNCHECKED Then
				GUICtrlSetState($FightNO, $GUI_CHECKED)
			Else
				GUICtrlSetState($FightNO, $GUI_UNCHECKED)
			EndIf
	endswitch
	WriteConfig()
Endfunc

Func FollowPos()
	Local $ChangedPos = GUICtrlRead($Radio_Placement)
	Local $FPos_Array[16] = [$FL1,$FL2,$FL3,$FL4,$FL5,$FL6,$FL7,$FL8,$FL9,$FL10,$FL11,$FL12,$FL13,$FL14,$FL15,$FL16]
	For $i = 0 to 15
		GUICtrlSetColor($FPos_Array[$i], $LabelColor)
		;GUICtrlSetBkColor($FPos_Array[$i], $GUI_BKCOLOR_TRANSPARENT)
		If ($i+1) = GUICtrlRead($Radio_Placement) Then
			Out("Position "&GUICtrlRead($Radio_Placement)&" selected")
			GUICtrlSetColor($FPos_Array[$i], $ThemeLabelColor)
		;	GUICtrlSetBkColor($FPos_Array[$i], 0x000000)
		EndIf
	Next
	WriteConfig()
EndFunc

Func gui_LootHandler()
	switch (@GUI_CtrlId)
		Case $FPickupNo
			If GUICtrlRead($FPickupNo) == $GUI_UNCHECKED Then
				GUICtrlSetState($FPickup, $GUI_CHECKED)
				GUICtrlSetState($FPickupGreen, $GUI_ENABLE)
				GUICtrlSetState($FPickupGold, $GUI_ENABLE)
				GUICtrlSetState($FPickupPurple, $GUI_ENABLE)
				GUICtrlSetState($FPickupBlue, $GUI_ENABLE)
				GUICtrlSetState($FPickupWhite, $GUI_ENABLE)
				GUICtrlSetState($AllMats, $GUI_ENABLE)
				GUICtrlSetState($RareMats, $GUI_ENABLE)
				GUICtrlSetState($PConsLoot, $GUI_ENABLE)
				GUICtrlSetState($Tomes, $GUI_ENABLE)
				GUICtrlSetState($OpenChests, $GUI_ENABLE)
			Else
				GUICtrlSetState($FPickup, $GUI_UNCHECKED)
				GUICtrlSetState($FPickupGreen, $GUI_DISABLE)
				GUICtrlSetState($FPickupGold, $GUI_DISABLE)
				GUICtrlSetState($FPickupPurple, $GUI_DISABLE)
				GUICtrlSetState($FPickupBlue, $GUI_DISABLE)
				GUICtrlSetState($FPickupWhite, $GUI_DISABLE)
				GUICtrlSetState($AllMats, $GUI_DISABLE)
				GUICtrlSetState($RareMats, $GUI_DISABLE)
				GUICtrlSetState($PConsLoot, $GUI_DISABLE)
				GUICtrlSetState($Tomes, $GUI_DISABLE)
				GUICtrlSetState($OpenChests, $GUI_DISABLE)
			EndIf
		Case $FPickup
			If GUICtrlRead($FPickup) == $GUI_UNCHECKED Then
				GUICtrlSetState($FPickupNo, $GUI_CHECKED)
				GUICtrlSetState($FPickupGreen, $GUI_DISABLE)
				GUICtrlSetState($FPickupGold, $GUI_DISABLE)
				GUICtrlSetState($FPickupPurple, $GUI_DISABLE)
				GUICtrlSetState($FPickupBlue, $GUI_DISABLE)
				GUICtrlSetState($FPickupWhite, $GUI_DISABLE)
				GUICtrlSetState($AllMats, $GUI_DISABLE)
				GUICtrlSetState($RareMats, $GUI_DISABLE)
				GUICtrlSetState($PConsLoot, $GUI_DISABLE)
				GUICtrlSetState($Tomes, $GUI_DISABLE)
				GUICtrlSetState($OpenChests, $GUI_DISABLE)
			Else
				GUICtrlSetState($FPickupNo, $GUI_UNCHECKED)
				GUICtrlSetState($FPickupGreen, $GUI_ENABLE)
				GUICtrlSetState($FPickupGold, $GUI_ENABLE)
				GUICtrlSetState($FPickupPurple, $GUI_ENABLE)
				GUICtrlSetState($FPickupBlue, $GUI_ENABLE)
				GUICtrlSetState($FPickupWhite, $GUI_ENABLE)
				GUICtrlSetState($AllMats, $GUI_ENABLE)
				GUICtrlSetState($RareMats, $GUI_ENABLE)
				GUICtrlSetState($PConsLoot, $GUI_ENABLE)
				GUICtrlSetState($Tomes, $GUI_ENABLE)
				GUICtrlSetState($OpenChests, $GUI_ENABLE)
			EndIf
		Case $FPickupWhite
			If GUICtrlRead($FPickupWhite) == $GUI_UNCHECKED Then
				GUICtrlSetState($AllMats, $GUI_ENABLE)
				GUICtrlSetState($RareMats, $GUI_ENABLE)
				GUICtrlSetState($RareMats, $GUI_CHECKED)
				GUICtrlSetState($PConsLoot, $GUI_ENABLE)
				GUICtrlSetState($PConsLoot, $GUI_CHECKED)
				GUICtrlSetState($Tomes, $GUI_ENABLE)
			Else
				GUICtrlSetState($AllMats, $GUI_CHECKED)
				GUICtrlSetState($AllMats, $GUI_DISABLE)
				GUICtrlSetState($RareMats, $GUI_CHECKED)
				GUICtrlSetState($RareMats, $GUI_DISABLE)
				GUICtrlSetState($PConsLoot, $GUI_CHECKED)
				GUICtrlSetState($PConsLoot, $GUI_DISABLE)
				GUICtrlSetState($Tomes, $GUI_CHECKED)
				GUICtrlSetState($Tomes, $GUI_DISABLE)
			EndIf
	EndSwitch
	WriteConfig()
Endfunc


Func GuiButtonHandler()
	If $BotRunning Then
		Out("Pausing...")
		GUICtrlSetState($Button, $GUI_DISABLE)
		$BotRunning = False
	ElseIf $BotInitialized Then
		GUICtrlSetData($Button, "Pause")
		$BotRunning = True
	Else
		Out("Initializing followerbot")
		$LeaderName = GUICtrlRead($LeaderInput)
		Local $FollowerName = GUICtrlRead($Follower)
		If $FollowerName=="" Then
			If Initialize(ProcessExists("gw.exe")) == False Then
				MsgBox(0, "Error", "Guild Wars is not running.")
				Exit
			EndIf
		ElseIf Initialize($FollowerName, True, True) == False Then
				MsgBox(0, "Error", "Could not find a Guild Wars client with a character named '"&$FollowerName&"'")
				Exit
		Else
			If $FollowerName==$LeaderName Or $LeaderName== 0 Then
				MsgBox(0, "Error", "Leader and Follower must be selected, and not be the same.")
				Exit
			EndIf
		EndIf
		GUICtrlSetState($LeaderInput, $GUI_DISABLE)
		GUICtrlSetState($Follower, $GUI_DISABLE)
		GUICtrlSetState($iRefresh, $GUI_DISABLE)
		GUICtrlSetState($iRefresh2, $GUI_DISABLE)
		GUICtrlSetData($Button, "Pause")
		WinSetTitle($mainGui, "", GetCharname() & " is following " & $LeaderName)
		_Gwen_InitMapResignTracking()
		GetPartyLeader()
		If $LeaderID <> "" Then
			Out("Tracking leader: " & $LeaderName)
		Else
			Out("Leader not visible yet; will retry in explorable area.")
		EndIf
		$BotRunning = True
		$BotInitialized = True
		$NRLockpicks = CountInventoryItem($Item_ID_Lockpicks)
		GUICtrlSetData($OpenChestsLabel, "Chests(" & $NRLockpicks & ")")

		For $i = 1 To 8
			GUICtrlSetState($CheckboxSkill[$i], $GUI_DISABLE)
		Next

	WriteConfig()

	;Read Skillbar and determine SkillID's
		$SkillID[1] = GetSkillbarSkillID(1, 0)
		$SkillID[2] = GetSkillbarSkillID(2, 0)
		$SkillID[3] = GetSkillbarSkillID(3, 0)
		$SkillID[4] = GetSkillbarSkillID(4, 0)
		$SkillID[5] = GetSkillbarSkillID(5, 0)
		$SkillID[6] = GetSkillbarSkillID(6, 0)
		$SkillID[7] = GetSkillbarSkillID(7, 0)
		$SkillID[8] = GetSkillbarSkillID(8, 0)
	;Get adrenaline requirements and store them cause function UseSkillEx() does not check adrenaline values
		$AdrenalineSkill[1] = $aArray_Of_Skill_Data[$SkillID[1]][18]
		$AdrenalineSkill[2] = $aArray_Of_Skill_Data[$SkillID[2]][18]
		$AdrenalineSkill[3] = $aArray_Of_Skill_Data[$SkillID[3]][18]
		$AdrenalineSkill[4] = $aArray_Of_Skill_Data[$SkillID[4]][18]
		$AdrenalineSkill[5] = $aArray_Of_Skill_Data[$SkillID[5]][18]
		$AdrenalineSkill[6] = $aArray_Of_Skill_Data[$SkillID[6]][18]
		$AdrenalineSkill[7] = $aArray_Of_Skill_Data[$SkillID[7]][18]
		$AdrenalineSkill[8] = $aArray_Of_Skill_Data[$SkillID[8]][18]
	EndIf
	EndFunc

Func WriteConfig()

	Local $LootData = "Pickup="&GetChecked($FPickup)&@LF&"nopickup="&GetChecked($FPickupNo)&@LF&"green="&GetChecked($FPickupGreen)&@LF&"gold="&GetChecked($FPickupGold)&@LF&"purple="&GetChecked($FPickupPurple)&@LF&"blue="&GetChecked($FPickupBlue)&@LF&"white="&GetChecked($FPickupWhite)&@LF&"allmats="&GetChecked($AllMats)&@LF&"raremats="&GetChecked($RareMats)&@LF&"pcons="&GetChecked($PConsLoot)&@LF&"tomes="&GetChecked($Tomes)&@LF&"Openchests="&GetChecked($OpenChests)
	IniWriteSection("config.ini", "PickupLoot", $LootData)

	Local $FightData = "FightYes="&GetChecked($FightYes)&@LF&"FightNO="&GetChecked($FightNO)&@LF&"Radio_Placement="&GUICtrlRead($Radio_Placement)
	IniWriteSection("config.ini", "FightOptions", $FightData)

	Local $SkillData = "Skill1="&GetChecked($CheckboxSkill[1])&@LF&"Skill2="&GetChecked($CheckboxSkill[2])&@LF&"Skill3="&GetChecked($CheckboxSkill[3])&@LF&"Skill4="&GetChecked($CheckboxSkill[4])&@LF&"Skill5="&GetChecked($CheckboxSkill[5])&@LF&"Skill6="&GetChecked($CheckboxSkill[6])&@LF&"Skill7="&GetChecked($CheckboxSkill[7])&@LF&"Skill8="&GetChecked($CheckboxSkill[8])
	IniWriteSection("config.ini", "Skills", $SkillData)
	Out("Saved settings to config.ini")
EndFunc

Func GetChecked($GUICtrl)
	Return (GUICtrlRead($GUICtrl)==$GUI_Checked)
EndFunc


 ;~ Print to console
Func Out($msg)
	GUICtrlSetData($StatusLabel, GUICtrlRead($StatusLabel) & "[" & @HOUR & ":" & @MIN & ":" & @SEC & "]" & " " & $msg & @CRLF)
   _GUICtrlEdit_Scroll($StatusLabel, $SB_SCROLLCARET)
   _GUICtrlEdit_Scroll($StatusLabel, $SB_LINEUP)
EndFunc

Func _exit()
	$g_Shutdown = True
	$BotRunning = False
	HotKeySet("{ESC}")
	If IsHWnd($mainGui) Then GUIDelete($mainGui)
	ProcessClose(@AutoItPID)
EndFunc

Func _Gwen_RefreshClientCombo($a_h_Combo, $a_s_Label)
	Local $l_i_GWCount = ProcessList("gw.exe")[0][0]

	If $l_i_GWCount = 0 Then
		MsgBox(16, "Gwen's Redemption", "No Guild Wars client (gw.exe) is running." & @CRLF & @CRLF & "Start the game, log into a character, then click Refresh.")
		Return
	EndIf

	Local $l_s_CharNames = Gwen_GetLoggedCharNames()

	If $l_s_CharNames = "" Then
		MsgBox(16, "Gwen's Redemption", "Found " & $l_i_GWCount & " Guild Wars client(s), but could not read character names." & @CRLF & @CRLF & "Make sure each client is fully logged in (not at the login screen)." & @CRLF & "Run this script as Administrator using 32-bit AutoIt." & @CRLF & @CRLF & "Then click Refresh again.")
		Return
	EndIf

	GUICtrlSetData($a_h_Combo, "")
	GUICtrlSetData($a_h_Combo, $l_s_CharNames)
	Out("Found " & $a_s_Label & " clients: " & StringReplace($l_s_CharNames, "|", ", "))
EndFunc

Func RefreshInterface()
	_Gwen_RefreshClientCombo($LeaderInput, "leader")
EndFunc

Func RefreshInterface2()
	_Gwen_RefreshClientCombo($Follower, "follower")
EndFunc

Func CheckOnTop()
EndFunc

Func CheckRendering()
EndFunc

