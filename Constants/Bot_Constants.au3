; ==== Constants ====
Global $Version = "V2.5k"
Global $Botname = "MultiAccount Follow/Fight/Spike bot " & $Version & " by [T7T]Crusher"
Global $BotRunning = False
Global $BotInitialized = False
Global $g_Shutdown = False
Global $LeaderID
Global $LeaderInput
Global $Follower
Global $SavedLeaderID
Global $SavedLeaderX
Global $SavedLeaderY
Global $SavedLeader
Global $distance
Global $SavedMap
Global $LeaderName
Global $nearestenemy
Global $aggrocolor
Global $LabelColor = "0xffffff"
Global $StatusColor = "0xffffff"
Global $StatusBgColor = "0x0a2431"
Global $ThemeLabelColor = "0xff9600"
Global $NRLockpicks = 0
Global $Partyleader = False
Global $DefaultBG
Global $mCharslots
Global $SkillID[9]
Global $CheckboxSkill[9]
Global $AdrenalineSkill[9]
Global $WriteOption
Global $Writevalue
Global Enum $instancetype_outpost, $instancetype_explorable, $instancetype_loading
Global $PlacementDistance
Global $Radio_Placement
Global $AngleDistance = 300


; RANGES
Global Const $adjacent_range = 156
Global Const $nearby_range = 240
Global Const $area_range = 312
Global Const $earshot_range = 1000				
Global Const $spellcasting_range = 1085 + 256		
Global Const $longbow_range = 1320				
Global Const $bowpull_range = 1500				
Global Const $spirit_range = 2500
Global Const $room_range = 3000
Global Const $map_range = 4000
Global Const $compass_range = 5000

; Gwen's Redemption follower defaults (fixed; no longer in GUI)
Global Const $GWEN_SCATTER_RANGE = 1250
Global Const $GWEN_AGGRO_RANGE = 900
Global Const $GWEN_FLAG_MODEL_ID = 5899
Global Const $GWEN_FOLLOW_LOOP_MS = 30
Global Const $GWEN_FOLLOW_MOVE_MS = 75
Global Const $GWEN_FOLLOW_CATCHUP_MOVE_MS = 35
Global Const $GWEN_FOLLOW_LEADER_THRESH = 12
Global Const $GWEN_FOLLOW_STEP_THRESH = 8
Global Const $GWEN_FOLLOW_CATCHUP = 20
Global $g_i_Gwen_PrevLeaderX = 0
Global $g_i_Gwen_PrevLeaderY = 0
Global $g_i_Gwen_LastMoveTime = 0
Global $g_i_Gwen_LastLootScan = 0
Global $g_i_Gwen_LastPconCheck = 0

;START Item drop models
Global Const $Rarity_Green = 2627
Global Const $Rarity_Gold = 2624
Global Const $Rarity_Purple = 2626
Global Const $Rarity_Blue = 2623
Global Const $Rarity_White = 2621
Global Const $Item_ID_Dyes = 146
Global Const $Item_ExtraID_BlackDye = 10
Global Const $Item_ExtraID_WhiteDye = 12
Global Const $Item_ExtraID_PinkDye = 13
Global Const $Item_ID_Lockpicks = 22751
Global Const $TYPE_KEY = 18
Global $MapResignID = 0
Global $g_b_Gwen_ResignedThisZone = False
Global $g_b_Gwen_SkipNextResign = False
;Global $Fpos1, $Fpos2, $Fpos3, $Fpos4, $Fpos5,$Fpos6,$Fpos7,$Fpos8,$Fpos9,$Fpos10,$Fpos11,$Fpos12,$Fpos13,$Fpos14,$Fpos15,$Fpos16
;Global $Fpos_Array[16][2] = [[$Fpos1, 1], [$Fpos2, 2], [$Fpos3, 3], [$Fpos4, 4], [$Fpos5, 5], [$Fpos6, 6], [$Fpos7, 7], [$Fpos8, 8], [$Fpos9, 9], [$Fpos10, 10], [$Fpos11, 11], [$Fpos12, 12], [$Fpos13, 13], [$Fpos14, 14], [$Fpos15, 15], [$Fpos16, 16]]

;Materials to pickup
Global $All_Materials_Array[36] = [921, 922, 923, 925, 926, 927, 928, 929, 930, 931, 932, 933, 934, 935, 936, 937, 938, 939, 940, 941, 942, 943, 944, 945, 946, 948, 949, 950, 951, 952, 953, 954, 955, 956, 6532, 6533]
Global $Common_Materials_Array[11] = [921, 925, 929, 933, 934, 940, 946, 948, 953, 954, 955]
Global $Rare_Materials_Array[25] = [922, 923, 926, 927, 928, 930, 931, 932, 935, 936, 937, 938, 939, 941, 942, 943, 944, 945, 949, 950, 951, 952, 956, 6532, 6533]
;Consumables to pickup
Global $Array_pscon[39]=[910, 5585, 6366, 6375, 22190, 24593, 28435, 30855, 31145, 35124, 36682, 6376, 21809, 21810, 21813, 36683, 21492, 21812, 22269, 22644, 22752, 28436,15837, 21490, 30648, 31020, 6370, 21488, 21489, 22191, 26784, 28433, 5656, 18345, 21491, 37765, 21833, 28433, 28434]
; Model ID and effect skill ID for auto-applied consumables
Global $g_a_Gwen_KnownPcons[9][2] = [ _
	[22269, 1945], [28431, 2605], [22752, 1934], [28432, 2604], [5853, 857], _
	[31153, 2973], [29429, 1926], [28436, 2649], [35121, 3174]]
;Tomes to pickup
Global $All_Tomes_Array[20] = [21796, 21797, 21798, 21799, 21800, 21801, 21802, 21803, 21804, 21805, 21786, 21787, 21788, 21789, 21790, 21791, 21792, 21793, 21794, 21795]


Global $OpenedChestAgentIDs[1]	;dirty fix for not using TargetNearestItem() (black list variable as previously opened chests were not targeted using TargetNearestItem(), now they are)
;when white items not selected still pickup nicks items
Global $NicksItem = IniRead("config.ini","NicksItem","NicksModel","False")
Global $ResignModel = IniRead("config.ini","ResignItem","ResignModel","False") ;31155 =mysterious summoning stone