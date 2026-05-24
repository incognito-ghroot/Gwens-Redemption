#include-once
; Legacy GWA/GWToolbox-style aliases for Gwen's Redemption on top of GwAu3.

#Region Agent struct cache
Func _Gwen_AgentStructInfo()
    Static $gs_a_Info = 0
    If $gs_a_Info = 0 Then
        $gs_a_Info = Memory_CreateStructure( _
            "long ID[0x2C];" & _
            "float X[0x74];" & _
            "float Y[0x78];" & _
            "float MoveX[0xA0];" & _
            "float MoveY[0xA4];" & _
            "long ExtraType[0xCC];" & _
            "byte Allegiance[0x1B5]")
    EndIf
    Return $gs_a_Info
EndFunc

Func _Gwen_ItemStructInfo()
    Static $gs_a_Info = 0
    If $gs_a_Info = 0 Then
        $gs_a_Info = Memory_CreateStructure( _
            "dword ItemID[0x0];" & _
            "dword AgentID[0x4];" & _
            "byte Type[0x20];" & _
            "byte ExtraID[0x22];" & _
            "dword ModelID[0x2C]")
    EndIf
    Return $gs_a_Info
EndFunc

Func GetAgentByID($a_i_AgentID = -2)
    Static $gs_t_Agent = 0
    Local $l_a_Info = _Gwen_AgentStructInfo()
    If $gs_t_Agent = 0 Then $gs_t_Agent = $l_a_Info[0]

    Local $l_p_Agent = Agent_GetAgentPtr($a_i_AgentID)
    If $l_p_Agent = 0 Then Return $gs_t_Agent

    Memory_ReadToStruct($l_p_Agent, $gs_t_Agent)
    Return $gs_t_Agent
EndFunc

Func GetCurrentTarget()
    Return GetAgentByID(-1)
EndFunc

Func GetAgentPtr($a_i_AgentID = -2)
    Return Agent_GetAgentPtr($a_i_AgentID)
EndFunc
#EndRegion

#Region Client discovery
Func _Gwen_AppendCharName(ByRef $a_s_List, $a_s_Name)
    $a_s_Name = StringStripWS($a_s_Name, 3)
    If $a_s_Name = "" Then Return
    If $a_s_List <> "" Then
        Local $l_a_Parts = StringSplit($a_s_List, "|")
        For $l_i_Idx = 1 To $l_a_Parts[0]
            If StringCompare($l_a_Parts[$l_i_Idx], $a_s_Name, 0) = 0 Then Return
        Next
        $a_s_List &= "|"
    EndIf
    $a_s_List &= $a_s_Name
EndFunc

Func Gwen_GetLoggedCharNames()
    Local $l_s_Names = ""

    Local $l_as_Array = Scanner_ScanGW()
    For $l_i_Idx = 1 To $l_as_Array[0]
        _Gwen_AppendCharName($l_s_Names, $l_as_Array[$l_i_Idx])
    Next
    If $l_s_Names <> "" Then Return $l_s_Names

    Local $l_a_Wins = WinList("[CLASS:" & $GC_S_CLASS_DX_WINDOW & "]")
    For $l_i_Idx = 1 To $l_a_Wins[0][0]
        Local $l_s_Title = $l_a_Wins[$l_i_Idx][0]
        If StringLeft($l_s_Title, 12) = "Guild Wars - " Then
            _Gwen_AppendCharName($l_s_Names, StringMid($l_s_Title, 13))
        EndIf
    Next

    Return $l_s_Names
EndFunc

Func _Gwen_FindPidByCharName($a_s_Char)
    $a_s_Char = StringStripWS($a_s_Char, 3)
    If $a_s_Char = "" Then Return 0

    Local $l_as_ProcessList = ProcessList("gw.exe")
    For $l_i_Idx = 1 To $l_as_ProcessList[0][0]
        Memory_Open($l_as_ProcessList[$l_i_Idx][1])
        If $g_h_GWProcess Then
            Local $l_s_Char = Scanner_ScanForCharname()
            If $l_s_Char <> "" And StringCompare(StringStripWS($l_s_Char, 3), $a_s_Char, 0) = 0 Then
                Memory_Close()
                $g_h_GWProcess = 0
                Return $l_as_ProcessList[$l_i_Idx][1]
            EndIf
        EndIf
        Memory_Close()
        $g_h_GWProcess = 0
    Next

    Local $l_a_Wins = WinList("[CLASS:" & $GC_S_CLASS_DX_WINDOW & "]")
    For $l_i_Idx = 1 To $l_a_Wins[0][0]
        Local $l_s_Title = $l_a_Wins[$l_i_Idx][0]
        If StringLeft($l_s_Title, 12) = "Guild Wars - " Then
            Local $l_s_Char = StringStripWS(StringMid($l_s_Title, 13), 3)
            If StringCompare($l_s_Char, $a_s_Char, 0) = 0 Then Return WinGetProcess($l_a_Wins[$l_i_Idx][1])
        EndIf
    Next

    Return 0
EndFunc
#EndRegion

#Region Core connection
Func Initialize($a_s_GW, $a_b_ChangeTitle = True, $a_b_Unused = True)
    If Not ProcessExists("gw.exe") Then Return False

    If IsString($a_s_GW) And $a_s_GW <> "" Then
        Core_Initialize($a_s_GW, $a_b_ChangeTitle)
        If Not $g_h_GWProcess Then
            Local $l_i_Pid = _Gwen_FindPidByCharName($a_s_GW)
            If $l_i_Pid Then Core_Initialize($l_i_Pid, $a_b_ChangeTitle)
        EndIf
    Else
        Core_Initialize($a_s_GW, $a_b_ChangeTitle)
    EndIf

    If Not $g_h_GWProcess Then Return False
    If $g_p_BasePointer = 0 Then Return False

    If IsString($a_s_GW) And $a_s_GW <> "" Then
        Local $l_s_Char = Player_GetCharname()
        If $l_s_Char = "" Then Return False
        If StringCompare(StringStripWS($l_s_Char, 3), StringStripWS($a_s_GW, 3)) <> 0 Then Return False
    EndIf

    Return True
EndFunc

Func GetCharname()
    Return Player_GetCharname()
EndFunc

Func GetWindowHandle()
    Return Scanner_GetWindowHandle()
EndFunc

Func GetMapLoading()
    Return Map_GetInstanceInfo("Type")
EndFunc

Func GetMapID()
    Return Map_GetMapID()
EndFunc

Func MemoryRead($a_p_Address, $a_s_Type = "dword")
    Return Memory_Read($a_p_Address, $a_s_Type)
EndFunc

Func SkipCinematic()
    Return Cinematic_SkipCinematic()
EndFunc

Func Disconnected()
    Out("Waiting for map load...")
    Map_WaitMapLoading(60000)
EndFunc
#EndRegion

#Region Movement and position
Func X($aAgent)
    If IsDllStruct($aAgent) Then Return DllStructGetData($aAgent, "X")
    Return Agent_GetAgentInfo($aAgent, "X")
EndFunc

Func Y($aAgent)
    If IsDllStruct($aAgent) Then Return DllStructGetData($aAgent, "Y")
    Return Agent_GetAgentInfo($aAgent, "Y")
EndFunc

Func GetAgentRotationAngle_Ptr($aAgent)
    Return Agent_GetAgentInfo($aAgent, "Rotation")
EndFunc

Func CheckMovingInOutpost($aX, $aY)
    Return
EndFunc
#EndRegion

#Region Party leader
Func _Gwen_LeaderNameMatches($a_i_AgentID)
    If $a_i_AgentID = 0 Or $LeaderName = "" Then Return False

    Local $l_s_Name = Agent_GetAgentInfo($a_i_AgentID, "Name")
    If $l_s_Name = "" Then Return False
    Return StringCompare(StringStripWS($l_s_Name, 3), StringStripWS($LeaderName, 3), 0) = 0
EndFunc

Func _Gwen_SetLeaderID($a_i_AgentID)
    If $a_i_AgentID = 0 Then Return False
    $LeaderID = $a_i_AgentID
    $SavedMap = GetMapID()
    Return True
EndFunc

Func GetPartyLeader()
    $SavedMap = GetMapID()
    $LeaderID = ""

    If $LeaderName = "" Then Return

    ; Party slot 1 is authoritative when it matches the configured leader (LoginNumber lookup is reliable in explorable areas).
    Local $l_i_PartyLeader = GetMemberAgentID(1)
    If $l_i_PartyLeader <> 0 And _Gwen_LeaderNameMatches($l_i_PartyLeader) Then
        $LeaderID = $l_i_PartyLeader
        Return
    EndIf

    Local $l_ap_Agents = Agent_GetAgentArray($GC_I_AGENT_TYPE_LIVING)
    If Not IsArray($l_ap_Agents) Or $l_ap_Agents[0] = 0 Then Return

    For $l_i_Idx = 1 To $l_ap_Agents[0]
        Local $l_s_Name = Agent_GetAgentInfo($l_ap_Agents[$l_i_Idx], "Name")
        If $l_s_Name = "" Then ContinueLoop
        If StringCompare(StringStripWS($l_s_Name, 3), StringStripWS($LeaderName, 3), 0) = 0 Then
            $LeaderID = Agent_GetAgentInfo($l_ap_Agents[$l_i_Idx], "ID")
            Return
        EndIf
    Next
EndFunc

Func CheckCurrentPartyleader()
    If $LeaderName = "" Then Return

    Local $l_i_LeaderAgent = GetMemberAgentID(1)
    If $l_i_LeaderAgent = 0 Then Return

    If _Gwen_LeaderNameMatches($l_i_LeaderAgent) Then
        _Gwen_SetLeaderID($l_i_LeaderAgent)
    Else
        GetPartyLeader()
    EndIf
EndFunc
#EndRegion

#Region Skills, items, chat
Func GetMaxAgents()
    Return Agent_GetMaxAgents()
EndFunc

Func GetPing()
    Return Other_GetPing()
EndFunc

Func GetSkillbarSkillAdrenaline($a_i_Slot, $a_i_Hero = 0)
    Return Skill_GetSkillbarInfo($a_i_Slot, "Adrenaline", $a_i_Hero)
EndFunc

Func GetSkillbarSkillID($a_i_Slot, $a_i_Hero = 0)
    Return Skill_GetSkillbarInfo($a_i_Slot, "SkillID", $a_i_Hero)
EndFunc

Func GetIsMovable($aAgent)
    Local $l_i_AgentID = $aAgent
    If IsDllStruct($aAgent) Then $l_i_AgentID = DllStructGetData($aAgent, "ID")
    Return Agent_GetAgentInfo($l_i_AgentID, "IsItemType")
EndFunc

Func GetItemByAgentID($a_i_AgentID)
    Static $gs_t_Item = 0
    Local $l_a_Info = _Gwen_ItemStructInfo()
    If $gs_t_Item = 0 Then $gs_t_Item = $l_a_Info[0]

    Local $l_i_ItemID = Item_FindItemByAgentID($a_i_AgentID)
    If $l_i_ItemID = 0 Then Return $gs_t_Item

    Local $l_p_Item = Item_GetItemPtr($l_i_ItemID)
    If $l_p_Item = 0 Then Return $gs_t_Item

    Memory_ReadToStruct($l_p_Item, $gs_t_Item)
    Return $gs_t_Item
EndFunc

Func PickUpItem($a_v_Item)
    If Map_GetInstanceInfo("IsLoading") Then Return False
    If Map_GetInstanceInfo("IsOutpost") Then Return False

    Local $l_i_AgentID = $a_v_Item
    If IsDllStruct($a_v_Item) Then
        $l_i_AgentID = DllStructGetData($a_v_Item, "AgentID")
    ElseIf Not IsNumber($a_v_Item) Then
        $l_i_AgentID = Item_GetItemInfoByPtr($a_v_Item, "AgentID")
    EndIf
    If $l_i_AgentID = 0 Or Agent_GetAgentPtr($l_i_AgentID) = 0 Then Return False
    If Not Agent_GetAgentInfo($l_i_AgentID, "IsItemType") Then Return False
    Return Item_PickUpItem($l_i_AgentID)
EndFunc

Func GetRarity($aItem)
    If IsDllStruct($aItem) Then
        Local $l_i_AgentID = DllStructGetData($aItem, "AgentID")
        If $l_i_AgentID <> 0 Then Return Item_GetItemInfoByAgentID($l_i_AgentID, "Rarity")
    ElseIf IsPtr($aItem) Then
        Return Item_GetItemInfoByPtr($aItem, "Rarity")
    EndIf
    Return 0
EndFunc

Func GetAssignedToMe($aAgent)
    Local $l_i_AgentID = $aAgent
    If IsDllStruct($aAgent) Then $l_i_AgentID = DllStructGetData($aAgent, "ID")
    Return Agent_GetAgentInfo($l_i_AgentID, "CanPickUp")
EndFunc

Func CountAllEmptySlots()
    Return CountSlots()
EndFunc

Func GetAgentArraySorted($a_i_Type = 0)
    Local $l_ap_Agents = Agent_GetAgentArray($a_i_Type)
    If Not IsArray($l_ap_Agents) Or $l_ap_Agents[0] = 0 Then
        Local $l_a_Empty[0][2]
        Return $l_a_Empty
    EndIf

    Local $l_a_Sorted[$l_ap_Agents[0]][2]
    Local $l_i_Count = 0
    For $l_i_Idx = 1 To $l_ap_Agents[0]
        Local $l_i_AgentID = Agent_GetAgentInfo($l_ap_Agents[$l_i_Idx], "ID")
        If $l_i_AgentID = 0 Then ContinueLoop
        $l_a_Sorted[$l_i_Count][0] = $l_i_AgentID
        $l_a_Sorted[$l_i_Count][1] = Agent_GetDistance($l_i_AgentID)
        $l_i_Count += 1
    Next

    If $l_i_Count = 0 Then
        Local $l_a_Empty[0][2]
        Return $l_a_Empty
    EndIf
    ReDim $l_a_Sorted[$l_i_Count][2]

    For $l_i_Outer = 0 To $l_i_Count - 2
        For $l_i_Inner = $l_i_Outer + 1 To $l_i_Count - 1
            If $l_a_Sorted[$l_i_Inner][1] < $l_a_Sorted[$l_i_Outer][1] Then
                Local $l_i_TempID = $l_a_Sorted[$l_i_Outer][0]
                Local $l_f_TempDist = $l_a_Sorted[$l_i_Outer][1]
                $l_a_Sorted[$l_i_Outer][0] = $l_a_Sorted[$l_i_Inner][0]
                $l_a_Sorted[$l_i_Outer][1] = $l_a_Sorted[$l_i_Inner][1]
                $l_a_Sorted[$l_i_Inner][0] = $l_i_TempID
                $l_a_Sorted[$l_i_Inner][1] = $l_f_TempDist
            EndIf
        Next
    Next

    Return $l_a_Sorted
EndFunc

Func CountInventoryItem($a_i_ModelID)
    Local $l_i_Count = 0
    Local $l_ap_Items = Item_GetItemArray()
    If Not IsArray($l_ap_Items) Then Return 0

    For $l_i_Idx = 1 To $l_ap_Items[0]
        Local $l_p_Item = $l_ap_Items[$l_i_Idx]
        If Memory_Read($l_p_Item + 0x2C, "dword") <> $a_i_ModelID Then ContinueLoop
        $l_i_Count += Item_GetItemInfoByPtr($l_p_Item, "Quantity")
    Next

    Return $l_i_Count
EndFunc

Func GetItemInInventory($a_i_ModelID)
    Return Item_FindItemByModelID($a_i_ModelID)
EndFunc

Func UseItem($a_v_Item)
    Return Item_UseItem($a_v_Item)
EndFunc

Func GetEffectTimeRemaining($a_i_EffectID, $a_i_Agent = -2)
    Return Agent_GetAgentEffectInfo($a_i_Agent, $a_i_EffectID, "TimeRemaining")
EndFunc

Func SendWhisper($a_s_Receiver, $a_s_Message)
    Return Chat_SendWhisper($a_s_Receiver, $a_s_Message)
EndFunc

Func GoSignpost($aAgent)
    If IsDllStruct($aAgent) Then Return Agent_GoSignpost(DllStructGetData($aAgent, "ID"))
    Return Agent_GoSignpost($aAgent)
EndFunc

Func OpenChest($a_b_WithLockpick = True)
    Return Item_OpenChest($a_b_WithLockpick)
EndFunc
#EndRegion

#Region Sleep
; IniWriteSection is a built-in AutoIt function (do not redefine it here).
Func RndSleep($a_i_Ms, $a_f_Random = 0.05)
    Other_RndSleep($a_i_Ms, $a_f_Random)
EndFunc
#EndRegion
