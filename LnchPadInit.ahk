﻿#SingleInstance, force
#NoEnv  ; Performance and compatibility with future AHK releases.
#Warn, All, OutputDebug
;#Warn, All , MsgBox ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to superior speed & reliability.
; SetBatchLines, -1  ; affects CPU utilization... script will run at max speed
SetWorkingDir %A_ScriptDir%
ListLines, Off
#KeyHistory 0
#MaxMem 512
AutoTrim, Off

Class LnchPadProps
{
	Morrowind
	{
		set
		{
		this._Morrowind := value
		}
		get
		{
		return this._Morrowind
		}
	}
	Oblivion
	{
		set
		{
		this._Oblivion := value
		}
		get
		{
		return this._Oblivion
		}
	}
	Fallout3
	{
		set
		{
		this._Fallout3 := value
		}
		get
		{
		return this._Fallout3
		}
	}
	Fallout4
	{
		set
		{
		this._Fallout4 := value
		}
		get
		{
		return this._Fallout4
		}
	}
	FalloutNV
	{
		set
		{
		this._FalloutNV := value
		}
		get
		{
		return this._FalloutNV
		}
	}
	SSE
	{
		set
		{
		this._SSE := value
		}
		get
		{
		return this._SSE
		}
	}
	GetCurrent(tabStat)
	{
		switch tabStat
		{
			case 1:
			return this.Morrowind
			case 2:
			return this.Oblivion
			case 3:
			return this.SSE
			case 4:
			return this.Fallout3
			case 5:
			return this.FalloutNV
			case 6:
			return this.Fallout4
		}
	}
}

Class ListBoxProps
{

	Static LB_GETITEMHEIGHT := 0x01A1
	Static LB_SETITEMHEIGHT := 0x01A0
	Static LB_GETCOUNT := 0x18B
	Static LB_GETSELCOUNT := 0x190
	Static LB_GETSELITEMS := 0x191
	Static LB_GETCARETINDEX := 0x19F
	Static LB_SETSEL := 0x185
	Static LB_GETSEL := 0x187
	Static sizeOfDWORD := 4
	Static LB_ERR := -1
	;Static prgNo := 0
	tmp := 0
; https://autohotkey.com/board/topic/89793-set-height-of-listbox-rows/
	Init ; cannot use__Init() because it is used to initialise above class variables
	{
		set
		{
		this.prgNo := value
		}
	}
	NewItemHeight
	{
		set
		{
		this._NewItemHeight := value
		}
	}
	hWnd
	{
		set
		{
		this._hWnd := value
		}
		get
		{
		return this._hWnd
		}
	}
	GetItemHeight()
	{
	SendMessage, % this.LB_GETITEMHEIGHT, 0, 0, , % "ahk_id" this._hWnd
	return ErrorLevel
	}

	SetItemHeight()
	{
	SendMessage, % this.LB_SETITEMHEIGHT, 0, % this._NewItemHeight, , % "ahk_id" this._hWnd
	WinSet, Redraw, , % "ahk_id" this._hWnd
	return ErrorLevel
	}

	GetItems()
	{
	lbItemArray := [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]

		if (!this.prgNo)
		Msgbox, 8208, LnchPad List, Something broke: prgNo is zero in class!


	SendMessage, % this.LB_GETSELCOUNT, 0, 0, , % "ahk_id" this._hWnd

	wParam := ErrorLevel

		if (wParam < 1)
		return wParam

	VarSetCapacity(lbSelItems, wParam * this.sizeOfDWORD, 0)

	SendMessage, % this.LB_GETSELITEMS, % wParam, % &lbSelItems, , % "ahk_id" this._hWnd

		Loop, % wParam
		lbItemArray[A_Index] := NumGet(lbSelItems, (A_Index - 1) * this.sizeOfDWORD, "UInt") + 1	
	VarSetCapacity(lbSelItems, 0)
	return lbItemArray
	}
	GetOneItem()
	{

	; LB_GETCARETINDEX Retrieves the index of the item that has the focus in a multiple-selection list box.The item may or may not be selected.
	SendMessage, % this.LB_GETCARETINDEX, 0, 0, , % "ahk_id" this._hWnd
	tmp := ErrorLevel + 1

	lbItemArray := [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
	lbItemArray := this.GetItems()
		for i in lbItemArray
		{
			if (tmp == lbItemArray[i])
			break
		}

	;LB_GETSEL: If an item is selected, the return value is greater than zero
	SendMessage, % this.LB_GETSEL, % tmp - 1, 0, , % "ahk_id" this._hWnd
	i := ErrorLevel
		if (i)
		return tmp
		else
		return -tmp
	}
	Down()
	{
	tmp := this.GetOneItem()
		if (tmp == this.prgNo)
		SendMessage, % this.LB_SETSEL, True, 0, , % "ahk_id" this._hWnd
		else
		SendMessage, % this.LB_SETSEL, True, %tmp%, , % "ahk_id" this._hWnd
	}
	Up()
	{
	tmp := this.GetOneItem()
		if (tmp == 1)
		SendMessage, % this.LB_SETSEL, True, % this.prgNo - 1, , % "ahk_id" this._hWnd
		else
		SendMessage, % this.LB_SETSEL, True, % tmp - 2, , % "ahk_id" this._hWnd
	}
}


OnMessage(0x201, "WM_LBUTTONDOWN")
OnMessage(0x0053, "WM_Help")
WM_HELPMSG := 0x0053
WS_EX_CONTEXTHELP := 0x00000400

gameList := ["Morrowind", "Oblivion", "Skyrim", "Fallout 3", "Fallout NV", "Fallout 4", "", "", "", "", "", ""]
gameExes := ["MGEXEgui.exe", "obse_loader.exe", "SKSE_loader.exe", "Fallout3.exe", "nvse_loader.exe", "f4se_loader.exe", "", "", "", "", "", ""]
gameFallBackExes := ["Morrowind.exe", "Oblivion.exe", "SkyrimSE.exe", "fose_loader.exe", "FalloutNV.exe", "Fallout4.exe", "", "", "", "", "", ""]

; FO3.exe, "avoid fose_loader.exe!"
; Skyrim.exe and SkyrimTESV.exe ???

gameExesFullPath := ["", "", "", "", "", "", "", "", "", "", "", ""]
iniNames := ["", "", "", "", "", "", "", "", "", "", "", ""]

PrgLnchIniPath := A_ScriptDir . "\PrgLnch.ini"
gameIniPath := ""
gameListStr := ""
tooltipDriveStr := ""
maxGames := 6
maxDrives := 9 ; it's actually 24 letters, but focus on NFTS
DriveLetter := Object()
DriveLetterBak := Object()
FATDrives := ""
maxBatchPrgs := 6
prgNo := 12
thisGuiW := 0
thisGuiH := 0
tabGuiW := 0
tabGuiH := 0
GuiHwnd := 0

fontDPI := 96 ; To be adjustment factor for windows setting
mControl := 0
buttonBkdChange := 0
currDrive := ""
cancelSearchMsg := 0
SearchSelectedClicked := 0
searchstat := 0
tabStat := 0
lboxSelTol := 0
multcopiesPrgWrn := 0
overWriteIniFile := 0
IniFileShortctSep := "?" ; Change if different in Main!
SelIniChoiceNamePrgLnchUpdated := 0
addGameShortCutIndex := 0 ; game path control variables
addGameShortCutLB := 0


retVal := 0
strTmp := ""
strRetVal := ""
tmp := 0
i := 0

prgName1 := ["Wrye Mash", "MLOX", "Morrowind Code Patch", "Bsa Browser", "MWEdit", "TES3Merge", "TESAME", "TESPCD", "Enchanted Editor", "Morrowind Resources Scanner", "Overunity", "MW Mesh Generator"]
prgName2 := ["Wrye Bash", "BOSS", "Construction Set Extender", "TES4Edit", "BSA Commander", "Multi Purpose Gui", "Landscape LOD Generator", "NifSkope", "TES4LODGen", "DDSOpt", "Merge Plugins", "Land Magic"]
prgName3 := ["Wrye Bash", "Mod Organizer", "LOOT", "xEdit", "Bethesda Archive Extractor", "BodySlide", "DynDOLOD", "NifSkope.exe", "Skyrim Performance Monitor 64", "xTranslator", "Creation Kit", "SSELODGen"]
prgName4 := ["Wrye Flash", "Fallout Mod Manager", "Garden of Eden CK Extender", "FO3Edit", "LOOT", "FO3LODGen", "Merge Plugins", "NifSkope", "BSArch", "Fallout 3 Configator", "FO3Dump", "Nifty Automagic Dismember Tool"]
prgName5 := ["Wrye Flash", "Fallout Mod Manager", "Garden of Eden CK Extender", "FNVEdit", "LOOT", "FNVLODGen", "Merge Plugins", "NifSkope", "BSArch", "New Vegas Configator", "FaceGen Exchange", "FO3 Save Import Utility"]
prgName6 := ["Wrye Bash", "Mod Organizer", "LOOT", "xEdit", "Bethesda Archive Extractor", "BodySlide", "Fallout 4 Config Tool", "NifSkope", "Creation Kit", "xTranslator", "Bsa Browser", "Material Editor"]
prgExe1 := ["mash64.exe", "mlox.exe", "Morrowind Code Patch.exe", "BSA Browser.exe", "MWEdit.exe", "TES3Merge.exe", "TES Advanced Mod Editor.exe", "tespcdv031.exe", "Enchanted.exe", "tes3cmd.exe", "Overunity.exe", "Grass.exe"]
prgExe2 := ["Wrye Bash.exe", "boss.exe", "TESConstructionSet.exe", "TES4Edit.exe", "bsacmd.exe", "mpgui.exe", "tes4ll.exe", "NifSkope.exe", "TES4LODGen.exe", "DDSOpt X64.exe", "MergePlugins.exe", "LandMagic.exe"]
prgExe3 := ["Wrye Bash.exe", "ModOrganizer.exe", "Loot.exe", "SSEEdit.exe", "bae.exe", "BodySlideX64.exe", "DynDOLOD.exe", "NifSkope.exe", "PerformanceMonitor64.exe", "xTranslator.exe", "CreationKit.exe", "SSELODGen.exe"]
prgExe4 := ["Wrye Flash.exe", "fomm.exe", "GECK.exe", "FO3Edit.exe", "Loot.exe", "FO3LODGen.exe", "MergePlugins.exe", "NifSkope.exe", "bsarch.exe", "FO3Configator.exe", "FO3Dump.exe", "nifty.exe"]
prgExe5 := ["Wrye Flash.exe", "fomm.exe", "GECK.exe", "FNVEdit.exe", "Loot.exe", "FNVLODGen.exe", "MergePlugins.exe", "NifSkope.exe", "bsarch.exe", "NVConfigator.exe", "FaceGen Exchange.exe", "FO3 Save Importer.exe"]
prgExe6 := ["Wrye Bash.exe", "ModOrganizer.exe", "Loot.exe", "FO4Edit.exe", "bae.exe", "BodySlideX64.exe", "Fallout4ConfigTool.exe", "NifSkope.exe", "CreationKit.exe", "xTranslator.exe ", "BSA Browser.exe", "Material Editor.exe "]
prgPath1 := ["", "", "", "", "", "", "", "", "", "", "", ""]
prgPath2 := ["", "", "", "", "", "", "", "", "", "", "", ""]
prgPath3 := ["", "", "", "", "", "", "", "", "", "", "", ""]
prgPath4 := ["", "", "", "", "", "", "", "", "", "", "", ""]
prgPath5 := ["", "", "", "", "", "", "", "", "", "", "", ""]
prgPath6 := ["", "", "", "", "", "", "", "", "", "", "", ""]
prgPath1bak := ["", "", "", "", "", "", "", "", "", "", "", ""]
prgPath2bak := ["", "", "", "", "", "", "", "", "", "", "", ""]
prgPath3bak := ["", "", "", "", "", "", "", "", "", "", "", ""]
prgPath4bak := ["", "", "", "", "", "", "", "", "", "", "", ""]
prgPath5bak := ["", "", "", "", "", "", "", "", "", "", "", ""]
prgPath6bak := ["", "", "", "", "", "", "", "", "", "", "", ""]
prgCmd1 := ["", "", "", "", "", "", "", "", "", "", "", ""]
prgCmd2 := ["", "", "", "", "", "", "", "", "", "", "", ""]
prgCmd3 := ["", "", "", "", "", "", "", "", "", "", "", ""]
prgCmd4 := ["", "", "", "", "", "", "", "", "", "", "", ""]
prgCmd5 := ["", "", "", "", "", "", "", "", "", "", "", ""]
prgCmd6 := ["", "", "", "", "", "", "", "", "", "", "", ""]
prgUrl1 := ["", "", "", "", "", "", "", "", "", "", "", ""]
prgUrl2 := ["", "", "", "", "", "", "", "", "", "", "", ""]
prgUrl3 := ["", "", "", "", "", "", "", "", "", "", "", ""]
prgUrl4 := ["", "", "", "", "", "", "", "", "", "", "", ""]
prgUrl5 := ["", "", "", "", "", "", "", "", "", "", "", ""]
prgUrl6 := ["", "", "", "", "", "", "", "", "", "", "", ""]
prgInfUrl1 := ["https://www.nexusmods.com/morrowind/mods/45439", "https://github.com/rfuzzo/mlox", "https://www.nexusmods.com/morrowind/mods/19510", "https://www.nexusmods.com/skyrimspecialedition/mods/1756", "http://mwedit.sourceforge.net", "https://www.nexusmods.com/morrowind/mods/46870", "http://mw.modhistory.com/download-95-5289", "https://www.nexusmods.com/morrowind/mods/3874", "http://mw.modhistory.com/download--1662", "https://mw.modhistory.com/download-p2-i25-95", "https://mw.modhistory.com/download-95-15293", "https://www.nexusmods.com/morrowind/mods/23065"]
prgInfUrl2 := ["https://www.nexusmods.com/oblivion/mods/22368", "https://boss-developers.github.io", "https://www.nexusmods.com/oblivion/mods/36370", "http://tes5edit.github.io", "https://www.nexusmods.com/oblivion/mods/3311", "https://www.nexusmods.com/oblivion/mods/41447", "https://www.nexusmods.com/oblivion/mods/40549", "http://niftools.sourceforge.net/wiki/NifSkope", "https://www.nexusmods.com/oblivion/mods/15781", "https://www.nexusmods.com/skyrim/mods/5755", "https://github.com/matortheeternal/merge-plugins", "https://www.nexusmods.com/oblivion/mods/30519"]
prgInfUrl3 := ["https://www.nexusmods.com/skyrimspecialedition/mods/6837", "https://www.nexusmods.com/skyrimspecialedition/mods/6194", "https://loot.github.io", "http://tes5edit.github.io", "https://www.nexusmods.com/skyrimspecialedition/mods/974", "https://www.nexusmods.com/skyrimspecialedition/mods/201", "https://www.nexusmods.com/skyrim/mods/59721", "http://niftools.sourceforge.net/wiki/NifSkope", "https://www.nexusmods.com/skyrimspecialedition/mods/3826", "https://www.nexusmods.com/skyrimspecialedition/mods/134", "https://store.steampowered.com/app/1946180/Skyrim_Special_Edition_Creation_Kit", "https://www.nexusmods.com/skyrimspecialedition/mods/6642"]
prgInfUrl4 := ["https://www.nexusmods.com/fallout3/mods/11336", "https://www.nexusmods.com/newvegas/mods/54991", "https://www.nexusmods.com/fallout3/mods/23425", "https://www.nexusmods.com/fallout3/mods/637", "https://loot.github.io", "https://www.nexusmods.com/fallout3/mods/21174", "https://www.nexusmods.com/skyrim/mods/69905", "http://niftools.sourceforge.net/wiki/NifSkope", "https://www.nexusmods.com/fallout4/mods/63243", "https://www.nexusmods.com/fallout3/mods/6769", "http://modsreloaded.com/fo3dump", "https://www.nexusmods.com/fallout3/mods/2631"]
prgInfUrl5 := ["https://www.nexusmods.com/newvegas/mods/35003", "https://www.nexusmods.com/newvegas/mods/54991", "https://www.nexusmods.com/newvegas/mods/64888", "https://www.nexusmods.com/newvegas/mods/34703", "https://loot.github.io", "https://www.nexusmods.com/newvegas/mods/58562", "https://www.nexusmods.com/skyrim/mods/69905", "http://niftools.sourceforge.net/wiki/NifSkope", "https://www.nexusmods.com/fallout4/mods/63243", "https://www.nexusmods.com/newvegas/mods/40442", "https://www.nexusmods.com/newvegas/mods/36471", "https://www.nexusmods.com/newvegas/mods/37649"]
prgInfUrl6 := ["https://www.nexusmods.com/fallout4/mods/20032", "https://github.com/ModOrganizer2/modorganizer", "https://loot.github.io", "https://www.nexusmods.com/fallout4/mods/2737", "https://www.nexusmods.com/fallout4/mods/78", "https://www.nexusmods.com/fallout4/mods/25", "https://www.nexusmods.com/fallout4/mods/102", "http://niftools.sourceforge.net/wiki/NifSkope", "https://store.steampowered.com/app/1946160/Fallout_4_Creation_Kit", "https://www.nexusmods.com/skyrimspecialedition/mods/134", "https://www.nexusmods.com/skyrimspecialedition/mods/1756", "https://www.nexusmods.com/fallout4/mods/3635"]
listboxIndices := [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
WS_CLIPSIBLINGS := 0x4000000
WS_EX_TOPMOST := 0x8
WS_CLIPCHILDREN := 0x2000000
LBS_MULTIPLESEL	:= 0x8

Black := "000000"
White := "ffffff"
Onyx := "353839"
Silver := "c0c0c0"
Yellow := "ffff00"
Gold := "FFD700"
Goldenrod := "DAA520"
Green := "00c000"
Olive := "808000"
Viridian := "40826D"
Avocado := "008000"
Lime := "00ff00"
Feldgrau := "5d5d3d"
Blue := "ff0000"
Navy := "000080"
Turquoise := "40E0D0"
Teal := "008080"
Cerulean := "007BA7"
Cyan := "00ffff"
Red := "ff0000"
Maroon := "000080"
Vermilion := "E34234"
Magenta := "F653A6"
Pink  := "ff20ff"
Fuchsia := "ff00ff"
Purple := "800080"
Grape := "6F2DA8"
Violet := "7F00FF"
Plum := "8E4585"
Orange := "FFA500"
Salmon := "fa8072"
DkSalmon := "E9967A"
Peach := "FFE5B4"
Beige := "F5F5DC"
Chestnut := "954535"
Chocolate := "7B3F00"
Taupe := "483C32"
Auburn := "A52A2A"
Gray := "808080"
Steingrau := "555548"
Khakigrau := "746643"

(A_PtrSize = 8)? 64bit := 1 : 64bit := 0 ; ONLY checks .exe bitness

	if FileExist("PrgLnch.ico")
	Menu, Tray, Icon, PrgLnch.ico

	Loop, Files, % A_ScriptDir . "\*.exe"
	{
		if (InStr(A_LoopFileName, "PrgLnch.exe"))
		{
		tmp := 1
		break
		}
	}

	if (!tmp && A_IsCompiled)
	{
	msgbox, 8192, PrgLnch Executable Required!, This cannot be run without Prglnch in the same folder!
	ExitApp
	}


lnchPadPID := DllCall("GetCurrentProcessId")



	for tmp, strRetVal in A_Args  ; For each parameter (or file dropped onto a script):
	{
		if (tmp == 2)
		break
	}

; The "active" slot, in current selection in PrgLnch
SelIniChoiceNamePrgLnch := strRetVal


ListBoxProps.Init() := prgNo

RegRead, fontDPI, HKEY_CURRENT_USER\Control Panel\Desktop\WindowMetrics, AppliedDPI 
	if (ErrorLevel)
	{
	msgbox, 8192, Registry Access, The Applied DPI value in registry is unavailable!`n`nAssuming default font scaling of 96.
	fontDPI := 1
	}
	else
	fontDPI := 96/fontDPI

Gui, +LastFound +%WS_CLIPSIBLINGS% +DPIScale -MaximizeBox -MinimizeBox +OwnDialogs +E%WS_EX_CONTEXTHELP%
GuiHwnd := WinExist()


; This is for  right click help invocation
DllCall("RegisterShellHookWindow", "UInt", GuiHwnd)
MsgSH := DllCall( "RegisterWindowMessage", "Str", "SHELLHOOK" )
OnMessage(MsgSH, "ShellMessage")



	loop, % maxGames
	gameListStr .= gameList[A_Index] . "|"

GetGamePaths()

Gui, Add, Text, x0 y0 Center +E%WS_EX_TOPMOST% gsearchDrive vsearchDrive HWNDsearchDriveHwnd, % "&Search PC for " gameList[1] " Apps"
Gui, Add, Text, Center gaddToLnchPad vaddToLnchPad HWNDaddToLnchPadHwnd wp, % "&Locate " gameList[1] " LnchPad Slot"

	loop % maxDrives
	{
	Gui, Add, Checkbox, vDrive%A_Index% gDrive HWNDDrive%A_Index%Hwnd
	guiControl, Hide, Drive%A_Index%
	}

Gui, Add, Radio, gOverWriteIni voverWriteIni HWNDoverWriteIniHwnd, Overwrite existing Slot with PrgLnch defaults
Gui, Add, Radio, gUpdateIni vupdateIni HWNDupdateIniHwnd, Update existing Ini File with acquired Prg info.
Gui, Add, Checkbox, gAddGameShortCut vaddGameShortCut HWNDaddGameShortCutHwnd, Include shortcut to game extender

GuiControl, Hide, overWriteIni
GuiControl, Hide, updateIni
GuiControl, Hide, addGameShortCut



A_GuiFont := GuiDefaultFont()
A_GuiFontSize := A_LastError

thisGuiW := floor(GetMonWidth(GuiHwnd))
thisGuiH := floor(GetMonHeight(GuiHwnd))

tmp := (thisGuiW > 1400)? ((thisGuiW > 1800)? 4: 2): 1

Gui, Font, % "s" fontDPI * (A_GuiFontSize + tmp)

GuiControl, Font, searchDrive
GuiControl, Font, addToLnchPad
Gui, Font
CtlColors.Attach(searchDriveHwnd, Red, "White")
CtlColors.Attach(addToLnchPadHwnd, Red, "White")

	; Font sizes scale up when resolution decreases
	if (thisGuiW < 400)
	thisGuiW := floor(2 * thisGuiW/3)
	else
	thisGuiW := floor(thisGuiW/2)

	if (thisGuiH < 600)
	thisGuiH := floor(2 * thisGuiH/3)
	else
	thisGuiH := floor(thisGuiH/2)


Gui, Add, Tab2, x0 y0 w%thisguiW% h%thisguiH% vLnchPadTab gLnchPadTab AltSubmit HWNDLnchPadTabHwnd, % substr(gameListStr, 1, StrLen(gameListStr) - 1)

Gui Show, w%thisguiW% h%thisguiH% Hide,

tabguiH := thisguiH - GetTabRibbonHeight(GuiHwnd)
tabguiW := thisguiW - A_LastError

tmp := (prgNo + 1/2) * ListBoxProps.GetItemHeight()

	loop, % maxGames
	{
	Gui, Tab, %A_Index%

	Gui, Add, ListBox, %LBS_MULTIPLESEL% x0 y0 vPrgIndex%A_Index% gPrgListBox HWNDPrgIndex%A_Index%Hwnd
	ListBoxProps.hWnd := PrgIndex%A_Index%Hwnd
	; Not the best....
	tmp := (thisGuiH > 520)? ((thisGuiH > 700)? 4: 3): (thisGuiH > 420)? 2: 1
	Gui, Font, % "s" fontDPI * (A_GuiFontSize + tmp)
	GuiControl, Font, % PrgIndex%A_Index%Hwnd

	Gui, Font
	ListBoxProps.NewItemHeight := floor(3/2 * ListBoxProps.GetItemHeight())
	ListBoxProps.SetItemHeight()

		; Factor for low res
		if (thisGuiH < 300)
		tmp := tabguiH/6
		else
		tmp := tabguiH/4

	GuiControl, Move, PrgIndex%A_Index%, % "x" 11.5 * tabguiW/16 "y" tmp " w" tabguiW/4 "h" (prgNo + 1/2) * ListBoxProps.GetItemHeight()

	CtlColors.Attach(PrgIndex%A_Index%Hwnd, Pink, "White")


	switch A_Index
	{
		case 1:
		{
		tmp = LnchPadMorrowind.jpg
		FileInstall LnchPadMorrowind.jpg, LnchPadMorrowind.jpg
		}
		case 2:
		{
		tmp = LnchPadOblivion.jpg
		FileInstall LnchPadOblivion.jpg, LnchPadOblivion.jpg
		}
		case 3:
		{
		tmp = LnchPadSkyrim.jpg
		FileInstall LnchPadSkyrim.jpg, LnchPadSkyrim.jpg
		}
		case 4:
		{
		tmp = LnchPadFallout 3.jpg
		FileInstall LnchPadFallout 3.jpg, LnchPadFallout 3.jpg
		}
		case 5:
		{
		tmp = LnchPadFallout NV.jpg
		FileInstall LnchPadFallout NV.jpg, LnchPadFallout NV.jpg
		}
		case 6:
		{
		tmp = LnchPadFallout 4.jpg
		FileInstall LnchPadFallout 4.jpg, LnchPadFallout 4.jpg
		}
	}

	; more for uncompiled run- else disaster!
	if (!(FileExist(A_ScriptDir . "\" . tmp)))
	{
	MsgBox, 8208, Game Image File, The file %tmp% cannot be accessed!`nQuitting LnchPad.
	return
	}



	picH := LoadPicture(tmp, GDI+ w%tabguiW% h%tabguiH%)

	Gui Add, Picture, x0 y0 w%tabguiW% h%tabguiH% +%WS_CLIPSIBLINGS% vgamePic%A_Index% ggamePic, % "HBITMAP:*" picH



	PopulateGameList(prgNo, A_Index, prgName%A_Index%)
	
	gosub gamePic

	}


;Gui, Tab

; 8 is default size of MS Shell Dlg for controls

GuiControl, Move, searchDrive, % "x" thisguiW/16 "y" 11 * thisguiH/32 "w" A_GuiFontSize * 5 * thisguiW/(16 * 8) "h" A_GuiFontSize * thisguiH/(16 * 8)

GuiControl, Move, addToLnchPad, % "x" thisguiW/16 "y" 5 * thisguiH/8 "w" A_GuiFontSize * 5 * thisguiW/(16 * 8) "h" A_GuiFontSize * thisguiH/(16 * 8)


ControlGetPos, , , , tmp, , ahk_id %Drive1Hwnd%
	loop % maxDrives
	{
	GuiControl, Move, Drive%A_Index%, % "x" 2*thisguiW/5 "y" ((A_Index - 1) * 2 * tmp + (3 * thisguiH/8))
	CtlColors.Attach(Drive%A_Index%Hwnd, Yellow, "Black") ; CtlColors doesn't do text colour for checkbox/radio.
	}

CtlColors.Attach(updateIniHwnd, Yellow, "Black")
CtlColors.Attach(overWriteIniHwnd, Yellow, "Black")
CtlColors.Attach(addGameShortCutHwnd, Yellow, "Black")
GuiControl, Move, updateIni, % "x" thisguiW/6 "y" 3 * thisguiH/4
GuiControl, Move, overWriteIni, % "x" thisguiW/6 "y" 4 * thisguiH/5
GuiControl, Move, addGameShortCut, % "x" thisguiW/6 "y" 9 * thisguiH/10

tabStat := 1
GoSub LnchPadTab
GuiControl, Choose, LnchPadTab, %tabStat%
Gui Show, xCenter yCenter w%thisguiW% h%thisguiH%, LnchPad Setup
SetTaskBarIcon(GuiHwnd)

WinSet, Redraw,, ahk_id %GuiHwnd%


return

gamePic:
GuiControl, Move, % "HBITMAP:*" picH, % "x" GetTabRibbonHeight() "y" GetTabRibbonHeight(GuiHwnd, 1) "w" tabguiW "h" tabguiH
return

PrgListBox:
Gui, Submit, Nohide

ToolTip

lboxSelTol++


resetSearch(searchStat, tabStat, gameList, maxDrives)


if (PrgIndex%tabStat%hwnd == PrgListBox_SelectedItem_last_hwnd && tabStat)
{
	; tolerance of clicks
	if (lboxSelTol > prgNo)
	{
	GuiControl, Choose, PrgIndex%tabStat%, 0
		loop % prgNo
		{
		prgPath%tabStat%[A_Index] := ""
		}
	ToolTip Max Clicks on Listbox. Switch Tabs or Redo Search!
	}
}

ListBox_SelectedItem := ListBoxProps.GetOneItem()

	if (ListBox_SelectedItem > 0)
	{
	; Restore
		if (addGameShortCutLB != ListBox_SelectedItem)
		prgPath%tabStat%[ListBox_SelectedItem] := prgPath%tabStat%bak[ListBox_SelectedItem]

		; Following deselection not required for LBS_MULTIPLESEL listboxes
		;if (ListBox_SelectedItem = ListBox_SelectedItem_last)
		;{
			;LB_SETSEL:=0x185
			;SendMessage, LB_SETSEL, 0, %ListBox_SelectedItem%, , ahk_id %hwndListBox%
		;}
	}
	else
	{
	; LB_GETCARETINDEX := 0x019F
	SendMessage, 0x019F, 0, 0, , % "ahk_id" . PrgIndex%tabStat%Hwnd
	tmp := ErrorLevel + 1

		if (tmp == addGameShortCutLB)
		GuiControl, Choose, PrgIndex%tabStat%, %tmp%
		else
		prgPath%tabStat%[-ListBox_SelectedItem] := ""
	}
; Want backup array


PrgListBox_SelectedItem_last_hwnd := PrgIndex%tabStat%hwnd
return

searchDrive:

Gui, Submit, Nohide
Tooltip
GuiControlGet, strTmp, , searchDrive
	if (InStr(strTmp, "Search PC"))
	{

		if (!SearchSelectedClicked)
		{
		DriveLetterBak := ""
		DriveLetterBak := Object()
		DriveLetterBak := GetDriveLetters(FATDrives)
		}

		loop % maxDrives
		{
			if (DriveLetterBak[A_Index])
			{
			GuiControl, Show, Drive%A_Index%
			GuiControl, Text, Drive%A_Index%, % DriveLetterBak[A_Index]
			}
		}

	guiControl, , searchDrive, &Search Selected Drives
	}
	else
	{
		; only alternative, but that may change
		if (InStr(strTmp, "Search Selected"))
		{
		SearchSelectedClicked := 1
		guiControl, , searchDrive, &Cancel Search

		Process, priority, %lnchPadPID%, A

		searchStat := -1
		tooltipDriveStr := ""

		GuiControl, Choose, PrgIndex%tabStat%, 0
		lboxSelTol := 0

		setTimer SearchFiles, -1
		}
	}

return


SearchFiles:

;must reset game shortcut
PopulateGameList(prgNo, tabStat, prgName%tabStat%)

	loop %PrgNo%
	{
	prgPath%tabStat%[A_Index] := ""
	prgPath%tabStat%bak[A_Index] := ""
	prgCmd%tabStat%[A_Index] := ""
	prgUrl%tabStat%[A_Index] := ""
	}

GuiControl, , addGameShortCut, 0
GuiControl, Hide, addGameShortCut
GuiControl, Hide, overWriteIni
GuiControl, Hide, updateIni

loop % maxDrives
{
currDrive := DriveLetter[A_Index]

	if (currDrive)
	{
	tmp := 0
	fallBackNotFound := 1
	gameNotFound := 1

	GoSub StartProgress

	if (InStr(FATDrives, currDrive))
	{
	; Slow slow method
	FolderList := ""
	FolderList := Object()

	;FolderList.SetCapacity(65534)
	
		Loop, Files, % currDrive . ":\*", D
		FolderList.Push(A_LoopFilePath)
		; Don't forget root drive
		FolderList.Push(currDrive . ":")

		Loop % FolderList.Length()
		{
			if A_LoopFileAttrib contains H,S
			FolderList[A_Index] := ""
			else
			{
				;i exclude upgrade- temp directories etc- maybe include ProgramData
				if ((InStr(FolderList[A_Index], "tmp\")) || (InStr(FolderList[A_Index], "temp\")) || (InStr(FolderList[A_Index], "old\")) || (InStr(FolderList[A_Index], "$")) || (InStr(FolderList[A_Index], "Winnt\")) || (InStr(FolderList[A_Index], "Windows\")) || (InStr(FolderList[A_Index], "Driver\")) || (InStr(FolderList[A_Index], "inetpub\")) || (InStr(FolderList[A_Index], "Intel\")) || (InStr(FolderList[A_Index], "PerfLogs\")) || (InStr(FolderList[A_Index], "AMD\")) || (InStr(FolderList[A_Index], "ISO\")) || (InStr(FolderList[A_Index], "VirtIO\")) || (InStr(FolderList[A_Index], "Logs\")))
				FolderList[A_Index] := ""
			}
		}
		Progress, 10

		fileList := ""  ; Initialize to be blank.

		Loop % FolderList.Length()
		{
			if (FolderList[A_Index])
			{
				Progress, % 10 + (90 * A_Index//FolderList.Length())
					if (searchStat == -2)
					break
				Loop, Files, % FolderList[A_Index] . "\*.exe", R
				fileList .= A_LoopFileFullPath "`n"
			}
		}



		Loop, parse, fileList, `n
		{
			if (A_LoopField == "")  ; Ignore the blank item at the end of the list.
			continue
			else
			{
				loop % prgNo
				{
				SplitPath, A_Loopfield, strTmp
					if (!strTmp) ; trailing `n in fileList
					break
					if (gameNotFound && strTmp == gameExes[tabStat])
					{
					gameExesFullPath[tabStat] := A_Loopfield
					fallBackNotFound := 0
					gameNotFound := 0
					}
					else
					{
						if (gameNotFound && fallBackNotFound && strTmp == gameFallBackExes[tabStat])
						{
						gameExesFullPath[tabStat] := A_Loopfield
						fallBackNotFound := 0
						}
						else
						{
							if (strTmp == prgExe%tabStat%[A_Index])
							{
								if (prgPath%tabStat%[A_Index])
								{
									if (multcopiesPrgWrn == 1)
									break
									else
									{
										if (!multcopiesPrgWrn)
										{
										MsgBox, 8195, Duplicate Prg, % strTmp " was discovered on a previous drive.`n`nReply:`nYes: Use the " currDrive " drive instead (This will not show again)`nNo: Keep the old Prg. (Warn like this next time)`nCancel: Keep the old Prg (Recommended: This will not show again)"
										GoSub StartProgress
										Progress, 99
											IfMsgBox, No
											break
											else
											{
												IfMsgBox, Yes
												{
												multcopiesPrgWrn := 2
												break
												}
												else
												multcopiesPrgWrn := 1
											}
										}
									prgPath%tabStat%[A_Index] := A_Loopfield
									prgPath%tabStat%bak[A_Index] := A_Loopfield
									GuiControl, Choose, PrgIndex%tabStat%, %A_Index%
									tmp := 1
									}
								}
							break
							}
						}
					}
				}
			}
		}

		if (!tmp)
		tooltipDriveStr .= currDrive . ","
	FolderList.SetCapacity(0)
	}
	else
	{
	fileList := ListMFTfiles(currDrive, prgExe%tabStat%, "," . gameExes[tabStat] . "," . gameFallBackExes[tabStat],, retVal)

		if (fileList)
		{
			Loop, parse, fileList, `n
			{
				loop % prgNo
				{
				SplitPath, A_Loopfield, strTmp
					if (!(strTmp)) ; trailing `n in fileList
					break
					if (gameNotFound && (strTmp == gameExes[tabStat]))
					{
					gameExesFullPath[tabStat] := A_Loopfield
					fallBackNotFound := 0
					gameNotFound := 0
					}
					else
					{
						if (gameNotFound && fallBackNotFound && (strTmp == gameFallBackExes[tabStat]))
						{
						gameExesFullPath[tabStat] := A_Loopfield
						fallBackNotFound := 0
						}
						else
						{
							if (strTmp == prgExe%tabStat%[A_Index])
							{
							prgPath%tabStat%[A_Index] := A_Loopfield
							prgPath%tabStat%bak[A_Index] := A_Loopfield
							GuiControl, Choose, PrgIndex%tabStat%, %A_Index%
							tmp := 1
							break
							}
						}
					}
				}
			}
		}
		else
		tooltipDriveStr .= currDrive . ","
	}
	Progress, Off
		if (searchStat == -2)
		break
	}
}


	if (tooltipDriveStr)
	{
	strTmp := "Nothing found for " SubStr(tooltipDriveStr,1,StrLen(tooltipDriveStr)-1) "."
	(retval)? strTmp .= "`nError code (for NFTS): " retVal:
	Tooltip, % strTmp
	}
	else
	{
	searchStat := 1

	; Fix Wrye Bash
		loop %PrgNo%
		{
			if (InStr(prgPath%tabStat%[A_Index], "Wrye Bash.exe"))
			{
			SplitPath, % gameExesFullPath[tabStat] , , strTmp

				if (!InStr(prgPath%tabStat%[A_Index], strTmp))
				break ; Wrye Bash is for this game!

				
				if (tabStat == 2 || tabStat == 3 || tabStat == 6)
				{
				strTmp := LnchPadProps.GetCurrent(tabStat)
					if (InStr(prgPath%tabStat%[A_Index], strTmp))
					{
					strTmp .= "\Mopy\Wrye Bash.exe"
						if (FileExist(strTmp))
						prgPath%tabStat%[A_Index] := strTmp
					break
					}
				}
			}
		}
	
	}

Process, priority, %lnchPadPID%, B

resetSearch(searchStat, tabStat, gameList, maxDrives)
cancelSearchMsg := 0
return

Drive:
Gui, Submit, Nohide
GuiControlGet, i, , %A_GuiControl%
tmp := substr(A_GuiControl, 0)
	if (i)
	DriveLetter[tmp] := DriveLetterBak[tmp]
	else
	DriveLetter[tmp] := ""
return

OverWriteIni:
Gui, Submit, Nohide
GuiControlGet, overWriteIniFile, , overWriteIni
GuiControl, Focus, addToLnchPad
return


UpdateIni:
Gui, Submit, Nohide
overWriteIniFile := 0
GuiControl, Focus, addToLnchPad
return

AddGameShortCut:
Gui, Submit, Nohide
GuiControlGet, addGameShortCutLB, , addGameShortCut
GameShortcutBiz(prgNo, addGameShortCutLB, tabStat, gameList, PrgName%tabStat%, PrgIndex%tabStat%)

	if (addGameShortCutLB > 0)
	{
	addGameShortCutIndex := 0
		loop %PrgNo%
		{
			if (prgPath%tabStat%[A_Index] == "")
			{
			addGameShortCutIndex := A_Index
			prgPath%tabStat%[addGameShortCutIndex] := gameExesFullPath[tabStat]
			break
			}
		}
		if (!addGameShortCutIndex)
		MsgBox, 8192, % "Shortcut to " . gameList[tabStat], No room for game!
	}
	else
	{
	prgPath%tabStat%[addGameShortCutIndex] := ""
	; Because "-editor" pops in when testing for game just before AddToIniProc
	prgCmd%tabStat%[addGameShortCutIndex] := ""
	prgUrl%tabStat%[addGameShortCutIndex] := ""
	addGameShortCutLB := 0
	addGameShortCutIndex := 0
	}

GuiControl, Focus, addToLnchPad
Return

addToLnchPad:
Gui, Submit, Nohide
Tooltip
GuiControlGet, strTmp, , addToLnchPad
gameIniPath := A_ScriptDir . "\" . gameList[tabStat] . ".ini"

	if (InStr(strTmp, "Locate"))
	{
	tmp := 0
		loop % prgNo
		{
		; Case of user deselection
			if (prgPath%tabStat%[A_Index])
			tmp++
		}

		if (!tmp)
		{
		Tooltip, Nothing to Add!
		return
		}

	tmp := 0
		Loop, Files, % A_ScriptDir . "\*.ini"
		{
			if (A_LoopFileName)
			{
			tmp:= 1
			break
			}
		}

		if (tmp && FileExist(PrgLnchIniPath))
		{
		IniRead, strTmp, %PrgLnchIniPath%, General, IniChoiceNames
		tmp := 0
		i := 0

			Loop, Parse, strTmp, CSV, %A_Space%%A_Tab%
			{
			iniNames[A_Index] := A_LoopField

				if (A_LoopField)
				{
				i++
					if (A_LoopField == gameList[tabStat])
					tmp++
				}
			}

			if (tmp)
			{
				if (FileExist(gameIniPath)) ; game ini exists!
				{
				GuiControl, Show, overWriteIni
				GuiControl, Show, updateIni
				GuiControl,, overWriteIni, % overWriteIniFile
				GuiControl,, updateIni, % !overWriteIniFile
				}
				else ; The ini file is referenced in Prglnch.ini but does not exist
				overWriteIniFile := 1
			}
			else
			{
				if (FileExist(gameIniPath))
				{
					if (i == prgNo)	; The ini file for this game has no reference in Prglnch.ini
					{
					Tooltip, % "The LnchPad Preset Ini File already exists for " gameList[tabStat] ",`nhowever PrgLnch has no available slots!"
					return
					}
					else
					{
					GuiControl, Show, overWriteIni
					GuiControl, Show, updateIni
					GuiControl,, overWriteIni, % overWriteIniFile
					GuiControl,, updateIni, % !overWriteIniFile
					}
				}
				else
				overWriteIniFile := 1
			}

			if (gameExesFullPath[tabStat])
			GuiControl, Show, addGameShortCut
		}
		else
		{
		Tooltip, The PrgLnch ini file is missing. Cannot continue!
		return
		}
	guiControl, , addToLnchPad, % "&Add to " gameList[tabStat] " LnchPad Slot"

	}
	else ; Update LnchPad Slots
	{
	GoSub StartProgress
	strRetVal := ""

	strTmp := (FileExist(gameIniPath))? gameList[tabStat]:

		if (overWriteIniFile)
		{
			if (strTmp) ; preferred to overwrite
			FileRecycle, % gameIniPath
		sleep 20
			if (strTmp := FileCopy(PrgLnchIniPath, gameIniPath))
			MsgBox, 8192, FileCopy, %strTmp%

		}
		else
		{
			if (!strTmp)
			{
				if (strTmp := FileCopy(PrgLnchIniPath, gameIniPath))
				MsgBox, 8192, FileCopy, %strTmp%
			}
		}

		if (ErrorLevel)
		{
		strRetVal := "Problem with " . gameList[tabStat] . ".ini file. Cannot continue!"
		return
		}
		else
		{
		; Clear data in new file
		Progress, 10

			if (overWriteIniFile)
			CreateIniData(prgNo, maxBatchPrgs, gameIniPath)
		Progress, 40

		; In case addGameShortCut was not clicked
		if (!addGameShortCutLB)
		{
			loop % PrgNo
			{
				if (gameExesFullPath[tabStat] == prgPath%tabStat%[A_Index] && (!inStr(PrgCmd%tabStat%[A_Index], "-editor")))
				{
				prgPath%tabStat%[A_Index] := ""
				break
				}
			}
		}
	strTmp := gameExesFullPath[tabStat]
	SplitPath, strTmp, , strTmp

; Check installs

	switch tabStat
	{
		case 1:
		strRetVal := "`nMorrowind"
		case 2:
		{
		strRetVal := "`nOblivion"
		; Fix editor extender
			loop % PrgNo
			{
				if (Instr(prgPath%tabStat%[A_Index], "TESConstructionSet.exe") && Instr(gameExesFullPath[tabStat], "obse_loader.exe"))
				{
				prgPath%tabStat%[A_Index] := gameExesFullPath[tabStat]
				prgCmd%tabStat%[A_Index] := "-editor -notimeout"
				break
				}
			}
		}
		case 3:
		strRetVal := "`nSSE"
		case 4:
		{
		strRetVal := "`nFallout 3"
		; Fix editor extender
			loop % PrgNo
			{
				if (Instr(prgPath%tabStat%[A_Index], "GECK.exe"))
				{
				;FO3.exe, "avoid fose_loader.exe!" to launch game
				strTmp := gameExesFullPath[tabStat]
				SplitPath, strTmp, , strTmp
				;ASSUME fose_loader.exe exists for Geck.exe, the Garden of Eden Creation Kit
				prgPath%tabStat%[A_Index] := strTmp . "\fose_loader.exe"
				prgCmd%tabStat%[A_Index] := "-editor"
				break
				}
			}
		}
		case 5:
		strRetVal := "`nFallout New Vegas"
		case 6:
		strRetVal := "`nFallout 4"
	}

	if (tmp := LnchPadProps.GetCurrent(tabStat))
	{
		if (strTmp && (strTmp != tmp))
		strRetVal .= " registry install path not the same as given executable path."
		else
		strRetVal := ""
		
	}
	else
	strRetVal .= " is not installed."



		strRetVal := AddToIniProc(prgNo, tabStat, gameList[tabStat], gameExes[tabStat], gameIniPath, prgPath%tabStat%, prgCmd%tabStat%, prgUrl%tabStat%, addGameShortCutIndex, IniFileShortctSep) . strRetVal
		tmp := 0
			Loop, % prgNo
			{
				if (iniNames[A_Index] == gameList[tabStat])
				{
				tmp := A_Index
				break
				}
			}

			if (!tmp)
			{
				Loop, % prgNo
				{
					if (!iniNames[A_Index])
					{
					tmp := A_Index
					iniNames[tmp] := gameList[tabStat]
					break
					}
				}
			}
			Progress, 70
			if (tmp)
			; Write updated slots to PrgLnch.ini
			UpdateAllIni(prgNo, tmp, PrgLnchIniPath, iniNames)
			else
			strRetVal := "LnchPad Slots full! Cannot continue!"

		}

	sleep, 100
	Progress, 100
	overWriteIniFile := 0
	GuiControl,, overWriteIni, 0
	GuiControl,, updateIni, 0
	GuiControl, Hide, overWriteIni
	GuiControl, Hide, updateIni
	GuiControl, Hide, addGameShortCut
	guiControl, , addToLnchPad, % "&Locate " gameList[tabStat] " LnchPad Slot"
	Progress, Off

		if (strRetVal && (!InStr(Substr(strRetVal, 1, 1), "1")))
		Tooltip, % strRetVal
		else
		{
			; PrgLnch restart flag activated
			if (SelIniChoiceNamePrgLnch == gameList[tabStat])
			SelIniChoiceNamePrgLnchUpdated := 1

			if (strRetval)
			Tooltip % Substr(strRetVal, 2)
			else
			Tooltip, Prgs Added!
		}
	}

return

GetGamePaths()
{
tmp := ""
SetRegView 32
RegRead, tmp, HKEY_LOCAL_MACHINE\Software\Bethesda Softworks\Morrowind, Installed Path
LnchPadProps.Morrowind := RTrim(tmp, "\")
RegRead, tmp, HKEY_LOCAL_MACHINE\Software\Bethesda Softworks\Oblivion, Installed Path
LnchPadProps.Oblivion := RTrim(tmp, "\")
RegRead, tmp, HKEY_LOCAL_MACHINE\Software\Bethesda Softworks\Fallout3, Installed Path
LnchPadProps.Fallout3 := RTrim(tmp, "\")
RegRead, tmp, HKEY_LOCAL_MACHINE\Software\Bethesda Softworks\Fallout4, Installed Path
LnchPadProps.Fallout4 := RTrim(tmp, "\")
RegRead, tmp, HKEY_LOCAL_MACHINE\Software\Bethesda Softworks\FalloutNV, Installed Path
LnchPadProps.FalloutNV := RTrim(tmp, "\")

SetRegView 32
RegRead, tmp, HKEY_LOCAL_MACHINE\Software\Bethesda Softworks\Skyrim Special Edition, Installed Path
	if (!tmp)
	{
	SetRegView 64
	RegRead, tmp, HKEY_LOCAL_MACHINE\Software\Bethesda Softworks\Skyrim Special Edition, Installed Path
	}
LnchPadProps.SSE := RTrim(tmp, "\")
}

PopulateGameList(prgNo, tabStat, prgNameTabStat, gameName := "", index := 0)
{
PrgIndexList := ""

	if (index)
	{
		loop, % prgNo
		{
		if (A_Index == index)
		PrgIndexList .= "|" . gameName . "|"
		else
		PrgIndexList .= "|" . prgNameTabStat[A_Index] . "|"
		}
	}
	else
	{
		loop, % prgNo
		PrgIndexList .= "|" . prgNameTabStat[A_Index] . "|"
	}

;GuiControl, , prgIndex%tabStat%, % prgIndexList
GuiControl, , prgIndex%tabStat%, % substr(prgIndexList, 1, StrLen(prgIndexList) - 1)

GuiControl, Choose, PrgIndex%tabStat%, 0

; Alternate for deselect all items:
; LB_SETSEL:= 0x185
; SendMessage, %LB_SETSEL%, 0, -1, , % "ahk_id" PrgIndex%tabStat%hwnd
}

GameShortcutBiz(prgNo, ByRef addGameShortCut, tabStat, gameList, PrgNameTabStat, PrgIndexTabStat)
{
static tabStatOld := 0, prgIndexReplaced := [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]

prgNameSelected := ["", "", "", "", "", "", "", "", "", "", "", ""]
prgSelectedIndices := [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
tmp := 0

prgSelectedIndices := ListBoxProps.GetItems()

	if (addGameShortCut)
	{

		for i in prgSelectedIndices
		{
		tmp := prgSelectedIndices[i]

			strTmp := prgNameSelected[tmp] := PrgNameTabStat[tmp]
				if (strTmp == gameList[tabStat])
				;already allocated
				return
		}

	tmp := 0
		loop %prgNo%
		{
			if (!prgNameSelected[A_Index])
			{
			prgIndexReplaced[tabStat] := A_Index
			break
			}
		}

		if (prgIndexReplaced[tabStat])
		{
		PopulateGameList(prgNo, tabStat, prgNameTabStat, gameList[tabStat], prgIndexReplaced[tabStat])
			loop %prgNo%
			{
			tmp := prgIndexReplaced[tabStat] == A_Index
				if (prgNameSelected[A_Index] || tmp)
				{
				GuiControl, Choose, PrgIndex%tabStat%, %A_Index%
					if (tmp)
					addGameShortCut := A_Index
				}
			}
		}
		else
		{
		; no available slots
		MsgBox, 8192, LnchPad Slots, LnchPad slots full!
		}

	}
	else
	{
		for i in prgSelectedIndices
		{
		tmp := prgSelectedIndices[i]
		prgNameSelected[tmp] := PrgNameTabStat[tmp]
		}

	PopulateGameList(prgNo, tabStat, prgNameTabStat, PrgNameTabStat[prgIndexReplaced[tabStat]], prgIndexReplaced[tabStat])

		loop %prgNo%
		{
			if (prgNameSelected[A_Index] && prgIndexReplaced[tabStat] != A_Index)
			GuiControl, Choose, PrgIndex%tabStat%, %A_Index%
		}
	addGameShortCut := -prgIndexReplaced[tabStat]
	}
}

CreateIniData(prgNo, maxBatchPrgs, gameIniPath)
{

IniWrite, None, %gameIniPath%, Prgs, StartupPrgName
IniWrite, %A_Space%, %gameIniPath%, Prgs, PrgBatchIniStartup
IniWrite, %A_Space%, %gameIniPath%, Prgs, PresetNames

	loop % maxBatchPrgs
	IniWrite, %A_Space%, %gameIniPath%, Prgs, PrgBatchIni%A_Index%



; Get def monitor res data via command line
	for tmp, strRetVal in A_Args  ; For each parameter (or file dropped onto a script):
	{
		if (tmp == 1)
		break
	}


;Get primary monitor if non-standard config, ensure longest entry is always primary monitor
tmp := 0
IniRead, strTmp, %gameIniPath%, Prgs, PrgMon
	Loop, parse, strTmp, CSV , %A_Space%%A_Tab%
	{
		if (strLen(A_Loopfield) == 3)
		{
		tmp := A_Index
		break
		}
	}

	; no primary?
	if (!tmp)
	tmp := 1


strTmp := tmp . ",0,0,-1,-1,0,0,0,-1"


	loop % prgNo
	{
	IniDelete, %gameIniPath%, Prg%A_Index%

	IniWrite, %A_Space%, %gameIniPath%, Prg%A_Index%, PrgName
	IniWrite, %A_Space%, %gameIniPath%, Prg%A_Index%, PrgPath
	IniWrite, %A_Space%, %gameIniPath%, Prg%A_Index%, PrgCmdLine
	IniWrite, %strRetVal%, %gameIniPath%, Prg%A_Index%, PrgRes
	IniWrite, %A_Space%, %gameIniPath%, Prg%A_Index%, PrgUrl
	IniWrite, %A_Space%, %gameIniPath%, Prg%A_Index%, PrgVer
	IniWrite, %strTmp%, %gameIniPath%, Prg%A_Index%, PrgMisc
		if (A_Index == floor(prgNo/2))
		Progress, 25
	}
}

AddToIniProc(prgNo, tabStat, gameListtabStat, gameExestabStat, gameIniPath, prgPathtabStat, prgCmdtabStat, prgUrltabStat, addGameShortCutIndex, IniFileShortctSep)
{
WrittentoSlotArrayCt := 0
AllocatedtoSlotArrayCt := 0
prgPathtabStatCt := 0
strTmp := ""
strRetVal := ""
PrgPathWrittentoSlotArray := ["", "", "", "", "", "", "", "", "", "", "", ""]
PrgPathNotWrittentoSlotArray := ["", "", "", "", "", "", "", "", "", "", "", ""]
freeSlotArray := [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]

gameShortcut := LnchPadProps.GetCurrent(tabStat) . "\" . gameExestabStat

	loop % prgNo
	{
	IniRead, strTmp, %gameIniPath%, Prg%A_Index%, PrgPath
	; Reading and comparing existingPrgCmdLine & PrgUrl possible, but a bit complicated
	; Check each PrgPath in the ini. Also consider name check:
	; IniRead, SelIniChoiceName, %PrgLnchIniPath%, Prg%A_Index%, PrgName ,,, if (InStr(SelIniChoiceName, gameList[tabStat]))

		if (strTmp)
		{
		freeSlotArray[A_Index] := 1
		; retrieve possible link 
		tmp := InStr(strTmp, IniFileShortctSep)
			; They should be direct exe links anyway, but...
			if (tmp)
			{
			strRetVal := SubStr(strTmp, tmp + 1)
				; No lnks etc
				if (!strRetVal)
				Continue
			strTmp := Substr(strTmp, 1, tmp)
			SplitPath, strRetVal ,,,, SelIniChoiceName
			}
			else
			{
			SplitPath, strTmp ,,,, SelIniChoiceName
			strTmp := ""
			}

		tmp := A_Index
			if (gameExestabStat == (SelIniChoiceName . ".exe")) ; check string twice saves unnecessary inireads
			IniRead, prgStr, %gameIniPath%, Prg%A_Index%, PrgCmdLine


		; The following loops check that the filename in the path strings correspond.
		if (gameExestabStat == (SelIniChoiceName . ".exe") && (!inStr(prgStr, "-editor")))
		{
			if (!addGameShortCutIndex)
			continue

			loop % prgNo
			{
				if (prgStr := prgPathtabStat[A_Index])
				{
					if (prgStr == gameShortcut && (!inStr(prgCmdtabStat[A_Index], "-editor")))
					{
					SplitPath, % prgStr ,,,, strRetVal
						if (InStr(SelIniChoiceName, strRetVal) || InStr(strRetVal, SelIniChoiceName))
						{
						WrittentoSlotArrayCt++
						PrgPathWrittentoSlotArray[WrittentoSlotArrayCt] := "**"
						IniWrite, % strTmp . prgStr, %gameIniPath%, Prg%tmp%, PrgPath
							if (prgCmdtabStat[A_Index])
							IniWrite, % prgCmdtabStat[A_Index], %gameIniPath%, Prg%tmp%, PrgCmdLine
							if (prgUrltabStat[A_Index])
							IniWrite, % prgUrltabStat[A_Index], %gameIniPath%, Prg%tmp%, PrgUrl
							; Else: Policy: existing urls not erased.
							; Make the element unique
							prgPathtabStat[A_Index] := "**"
							break
						}
					}
				}
			}

		}
		else
		{
			loop % prgNo
			{
				if (prgStr := prgPathtabStat[A_Index])
				{
					if (prgStr == gameShortcut && (!inStr(prgCmdtabStat[A_Index], "-editor")))
					continue
					else
					{
					;  Not handling associations here
					SplitPath, % prgStr ,,,, strRetVal
						if (InStr(SelIniChoiceName, strRetVal) || InStr(strRetVal, SelIniChoiceName))
						{
						WrittentoSlotArrayCt++
						PrgPathWrittentoSlotArray[WrittentoSlotArrayCt] := prgStr
						IniWrite, % strTmp . prgStr, %gameIniPath%, Prg%tmp%, PrgPath
							if (prgCmdtabStat[A_Index])
							IniWrite, % prgCmdtabStat[A_Index], %gameIniPath%, Prg%tmp%, PrgCmdLine
							if (prgUrltabStat[A_Index])
							IniWrite, % prgUrltabStat[A_Index], %gameIniPath%, Prg%tmp%, PrgUrl
							; Else: Policy: existing urls not erased.
						}
					}
				}
			}
		}	
		}
		
	}

	loop % prgNo
	{
		if (prgPathtabStat[A_Index])
		prgPathtabStatCt++
	}

; Existing entries excluded
;AdjustedprgPathtabStatCt := prgPathtabStatCt - 
oldWrittentoSlotArrayCt := WrittentoSlotArrayCt

; Fine - we may want commandline Parms as well- e.g. Wrye Bash.exe -debug
AllocatedtoSlotArrayCt := 0

	loop, % prgNo
	{
		if (addGameShortCutIndex && (strTmp := prgPathtabStat[A_Index]) && (strTmp == gameShortcut) && (!inStr(prgCmdtabStat[A_Index], "-editor")))
		prgPathtabStat[A_Index] := "??"
	}


	loop, % prgNo
	{
	tmp := 0
		if (strTmp := prgPathtabStat[A_Index])
		{
			if (strTmp == "**")
			continue

			loop, % prgNo
			{
				if (strTmp == PrgPathWrittentoSlotArray[A_Index])
				{
				tmp := 1
				break
				}
			}

			if (!tmp)
			{

				Loop, % prgNo
				{
					if (!PrgPathWrittentoSlotArray[A_Index])
					{
					AllocatedtoSlotArrayCt++
					PrgPathNotWrittentoSlotArray[AllocatedtoSlotArrayCt] := strTmp
					break
					}
				}
			}
		}
	}
	; ALSO NAMES & URLS
	; write the path to a new Prg
	loop, % prgNo
	{
		if (strTmp := PrgPathNotWrittentoSlotArray[A_Index])
		{
			; revert to game path
			if (strTmp == "??")
			strTmp := gameShortcut

			loop, % prgNo
			{
				if (!freeSlotArray[A_Index])
				{
				WrittentoSlotArrayCt++

				IniWrite, % strTmp, %gameIniPath%, Prg%A_Index%, PrgPath

					; Problematic if non TES prgs have "-editor" in their command line
					if (strTmp == gameShortcut)
					{
						if (instr(prgCmdtabStat[A_Index], "-editor"))
						{
							switch tabStat
							{
							case 2:
							IniWrite, TES Construction Set, %gameIniPath%, Prg%A_Index%, PrgName
							case 4:
							IniWrite, G.E.C.K, %gameIniPath%, Prg%A_Index%, PrgName
							default:
							{
							SplitPath, strTmp ,,,, SelIniChoiceName					
							IniWrite, %SelIniChoiceName%, %gameIniPath%, Prg%A_Index%, PrgName
							}
							}
						}
						else
						{
						; Add game
							if (addGameShortCutIndex)
							IniWrite, % "*" . gameListtabStat , %gameIniPath%, Prg%A_Index%, PrgName
						}
					}
					else
					{
					SplitPath, strTmp ,,,, SelIniChoiceName					
					IniWrite, %SelIniChoiceName%, %gameIniPath%, Prg%A_Index%, PrgName
					}

					if (prgCmdtabStat[A_Index])
					IniWrite, % prgCmdtabStat[A_Index], %gameIniPath%, Prg%A_Index%, PrgCmdLine
					if (prgUrltabStat[A_Index])
					IniWrite, % prgUrltabStat[A_Index], %gameIniPath%, Prg%A_Index%, PrgUrl
				freeSlotArray[A_Index] := 1
				break
				}
			}
		}
	}

	strRetVal := ""

	if (oldWrittentoSlotArrayCt && !AllocatedtoSlotArrayCt)
	strRetVal := "1All of the " . oldWrittentoSlotArrayCt . " Prg entries were updated!"
	else
	{
		if (!WrittentoSlotArrayCt && !oldWrittentoSlotArrayCt)
		strRetVal := "None of the new " . AllocatedtoSlotArrayCt . " Prg entries could be written to the LnchPad Slot!"
		else
		{
			if (!oldWrittentoSlotArrayCt && WrittentoSlotArrayCt == AllocatedtoSlotArrayCt)
			strRetVal := "1All " . WrittentoSlotArrayCt . " Prg entries added!"
			else
			{
				if (WrittentoSlotArrayCt - oldWrittentoSlotArrayCt == AllocatedtoSlotArrayCt)
				strRetVal := "1Existing Prgs updated: " . oldWrittentoSlotArrayCt . ", and " . AllocatedtoSlotArrayCt . " new Prg entries were written to the LnchPad Slot!"
				else
				{
					if (WrittentoSlotArrayCt - oldWrittentoSlotArrayCt < AllocatedtoSlotArrayCt)
					{
						if (oldWrittentoSlotArrayCt)
						strRetVal := "1Existing Prgs updated: " . oldWrittentoSlotArrayCt . "`nOnly "
						else
						strRetVal := "1Only "

					strRetVal .= (WrittentoSlotArrayCt - oldWrittentoSlotArrayCt) . " of the new " . AllocatedtoSlotArrayCt . " Prg entries could be written to the LnchPad Slot!"
					}
					else
					strRetVal := "Error: Slot Allocations reported an error: try again."
				}
			}
		}
	}


return strRetVal


}


UpdateAllIni(prgNo, iniSel, PrgLnchIni, IniChoiceNames)
{
spr := "", strTmp := "", tmp := 0
IniChoicePaths := ["", "", "", "", "", "", "", "", "", "", "", ""]
fileExistRec := [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]

strTmp := (IniChoiceNames[iniSel])? IniChoiceNames[iniSel]: A_Space

	; inipad slot currently selected?
	if (FileExist(PrgLnchIni))
	IniRead, existSelIniChoiceName, %PrgLnchIni%, General, SelIniChoiceName
	else
	{
	MsgBox, 8208, Ini File Read,Unable to locate the PrgLnch ini file!`nPlease rerun PrgLnch to recreate it.
	return
	}

	
	if (existSelIniChoiceName == "ERROR")
	existSelIniChoiceName := ""

	if (existSelIniChoiceName)
	{
		Loop % prgNo
		{
			if (IniChoiceNames[A_Index] == existSelIniChoiceName)
			{
			tmp := 1
			break
			}
		}
	}


	Loop % prgNo
	{
		if (IniChoiceNames[A_Index])
		{
		spr .= IniChoiceNames[A_Index] . ","
		IniChoicePaths[A_Index] := A_ScriptDir . "\" . IniChoiceNames[A_Index] . ".ini"
			if (fileExistRec[A_Index] := FileExist(IniChoicePaths[A_Index]))
			{
				if (tmp)
				IniWrite, %strTmp%, % IniChoicePaths[A_Index], General, SelIniChoiceName
			}
			else
			{
			MsgBox, 8196, LnchPad Ini Update, % "The LnchPad file " . """" . IniChoiceNames[A_Index] . ".ini " . """" . " does not exist.`n`nReply:`nYes: Attempt to update the others (Recommended) `nNo: Quit updating the LnchPads. `n"
				IfMsgBox, No
				return
			}

			if (Errorlevel)
			{
			MsgBox, 8196, LnchPad Ini Update, % "The following LnchPad file could not be written to:`n" IniChoiceNames[A_Index] "`n`nReply:`nYes: Continue updating the others (Recommended) `nNo: Quit updating the LnchPads. `n"
				IfMsgBox, No
				return
			}
		sleep, 10
		}
		else
		spr .= ","

	}
	
	if (tmp)
	IniWrite, %strTmp%, %PrgLnchIni%, General, SelIniChoiceName


	if (Errorlevel)
	MsgBox, 8192, LnchPad: PrgLnch Ini Update, % "The following (possibly blank) value could not be written to PrgLnch.ini:`n" strTmp
	
	
	sleep, 10
	; Trim last ","
	spr := SubStr(spr, 1, StrLen(spr) - 1)
	Loop % prgNo
	{
		if (IniChoicePaths[A_Index] && fileExistRec[A_Index])
		{
		IniWrite, %spr%, % IniChoicePaths[A_Index], General, IniChoiceNames
		sleep, 10
		}
	}
	IniWrite, %spr%, %PrgLnchIni%, General, IniChoiceNames
	sleep, 10
}

LnchPadTab:

Gui, Submit, Nohide

	if (searchStat < 0)
	{
		if (searchStat == -1)
		{
		GuiControl, Choose, LnchPadTab, % tabStat
		Progress, -A
		Progress, +A
		return
		}
		else
		{
		Progress, Off
		ResetDrives(DriveLetterBak, DriveLetter, maxDrives)
		}
	}

SearchSelectedClicked := 0
lboxSelTol := 0
GuiControlGet, tabStat, , LnchPadTab

ControlGet, strTmp, List,,, % "ahk_id" PrgIndex%tabStat%Hwnd

tmp := 0
	Loop, Parse, strTmp, `n
	{
		if (A_LoopField == gameList[tabStat])
		{
		tmp := 1
		break
		}
	}

	if (tmp)
	GuiControl, , addGameShortCut, 1
	else
	GuiControl, , addGameShortCut, 0

ListBoxProps.hWnd := PrgIndex%tabStat%Hwnd

switch tabStat
{
	case 1:
	{
	CtlColors.Change(PrgIndex1Hwnd, Chocolate, "Yellow")
	CtlColors.Change(searchDriveHwnd, Chocolate, "Yellow")
	CtlColors.Change(addToLnchPadHwnd, Chestnut, "Yellow")
	}
	case 2:
	{
	CtlColors.Change(PrgIndex2Hwnd, Taupe, "Goldenrod")
	CtlColors.Change(searchDriveHwnd, Taupe, "Goldenrod")
	CtlColors.Change(addToLnchPadHwnd, Khakigrau, "Goldenrod")
	}
	case 3:
	{
	CtlColors.Change(PrgIndex3Hwnd, Black, "Silver")
	CtlColors.Change(searchDriveHwnd, Black, "Silver")
	CtlColors.Change(addToLnchPadHwnd, Onyx, "Silver")
	}
	case 4:
	{
	CtlColors.Change(PrgIndex4Hwnd, Steingrau, "Goldenrod")
	CtlColors.Change(searchDriveHwnd, Steingrau, "Goldenrod")
	CtlColors.Change(addToLnchPadHwnd, Feldgrau, "Goldenrod")
	}
	case 5:
	{
	CtlColors.Change(PrgIndex5Hwnd, Auburn, "Yellow")
	CtlColors.Change(searchDriveHwnd, Auburn, "Yellow")
	CtlColors.Change(addToLnchPadHwnd, Vermilion, "Yellow")
	}
	case 6:
	{
	CtlColors.Change(PrgIndex6Hwnd, Steingrau, "White")
	CtlColors.Change(searchDriveHwnd, Steingrau, "White")
	CtlColors.Change(addToLnchPadHwnd, Khakigrau, "White")
	}
}
buttonBkdChange := 0 ; just in case

	if (searchStat >= 0)
	{
	tooltip
	resetSearch(searchStat, tabStat, gameList, maxDrives)
	}

return

StartProgress:
Progress, off
Progress, Hide
W := thisGuiW /2
H := thisGuiH /8
	if (buttonBkdChange == 1)
	Progress, A W%W% H%H% b p0 M,, Getting Headers. %currDrive%: ...,
	else
	Progress, A W%W% H%H% b p0 M,, Updating LnchPad Ini Slot: ...,
return

Esc::
Quit:
GuiClose:

CtlColors.Free()

	if (SelIniChoiceNamePrgLnchUpdated)
	{
	SetTitleMatchMode, 3
	WinGet, tmp, PID , PrgLnch
		if (tmp)
		{
		MsgBox, 8193, LnchPad Slot Changed, % "Current LnchPad Slot has been modified in PrgLnch!`n`PrgLnch should relaunch if the Slot has any active Prgs.`n`nClick Ok for PrgLnch relaunch, or Cancel to continue."
		; cold  start
			IfMsgBox, OK
			{
			Process, Close , %tmp%
			sleep 30
				try
				{
				Run, % """" . A_ScriptDir . "\PrgLnch.exe" . """" . " /restart ", %A_ScriptDir%, UseErrorLevel
				}
				catch tmp
				{
				MsgBox, 8192, PrgLnch ReLaunch, % "PrgLnch has a problem with restart.`n`Error: " A_LastError "."
				}
			}
		}
	}
ExitApp





GetTabRibbonHeight(LnchPadTabHwnd := 0, WindozeBorder := 0)
{

SM_CXEDGE := 45 ; assume 3D		
SM_CYEDGE := 46 ; assume 3D		

	if (LnchPadTabHwnd)
	{
	SysGet, tmp, %SM_CYEDGE%
		DetectHiddenWindows, On	
		if WinExist("ahk_id " LnchPadTabHwnd)
		{
		DetectHiddenWindows, Off
		VarSetCapacity(rect, 16, 0)
		DllCall("GetWindowRect", "Ptr", LnchPadTabHwnd, "Ptr", &rect)
		W := NumGet(rect, 8, "int") - NumGet(rect, 0, "int")
		H := NumGet(rect, 12, "int") - NumGet(rect, 4, "int")
		VarSetCapacity(rect, 16, 0)
		DllCall("GetClientRect", "Ptr", LnchPadTabHwnd, "Ptr", &rect)
		W := W - NumGet(rect, 8, "int")
		DllCall( "SetLastError", "Uint", W) 
		return % H - NumGet(rect, 12, "int") - WindozeBorder * tmp
		}
		else
		Msgbox, 8208, LnchPad Tabs, Problem with Tab display!
	}
	else
	{
	SysGet, tmp, %SM_CXEDGE%	
	return % tmp
	}

}


GuiDefaultFont()
{
;https://autohotkey.com/board/topic/7984-ahk-functions-incache-cache-list-of-recent-items/://autohotkey.com/board/topic/7984-ahk-functions-incache-cache-list-of-recent-items/page-10?&#entry443622
hwnd := 0 ; entire screen
hFont := DllCall("GetStockObject", "UInt", 17) ; DEFAULT_GUI_FONT
VarSetCapacity(LF, szLF := 60*((A_IsUnicode)? 2:1))
DllCall("GetObject", "UInt", hFont, "Int", szLF, "UInt",&LF)
hDC := DllCall("GetDC", "UInt", hwnd ), DPI := DllCall( "GetDeviceCaps", "UInt", hDC, "Int", 90)
DllCall( "ReleaseDC", "Int", 0, "UInt", hDC ), S := Round((-NumGet(LF,0, "Int") * 72) / DPI) ; S is fonstsize
return DllCall( "MulDiv", "Int", &LF+28, "Int", 1, "Int", 1, "Str"), DllCall( "SetLastError", "UInt", S ) ; sneaky way of returning a second value without using function parameters
}


#IfWinActive LnchPad Setup
{
Down::
GuiControlGet, tmp, FocusV
	if (tmp == (tmp := PrgIndex%tabStat%))
	ListBoxProps.Down()
return
Up::
GuiControlGet, tmp, FocusV
	if (tmp == (tmp := PrgIndex%tabStat%))
	ListBoxProps.Up()
return
}

~RButton::

goSub chmRButton
return

chmRButton:

	While(getKeyState("RButton", "P"))
	{
		MouseGetPos, , , mWin, mControl
		GuiControlGet, tmp, Name, % mControl
		if (InStr(mControl, "Listbox"))
		{
		GuiControlGet, tmp, , LnchPadTab

		strTmp := tabStat . LBEX_ItemFromCursor(PrgIndex%tmp%Hwnd)
		retVal := RunChm("LnchPad Setup`\LnchPad Setup", strTmp)
		;WinActivate, LnchPad Setup
		WinSet, Top, , % "ahk_id" this._hWnd
		;WinSet, Redraw, , % "ahk_id" this._hWnd
		;GuiControl, Show, ahk_id PrgIndex%tmp%Hwnd

/*
if (ItemHandle = overWriteIniHwnd)
retVal := RunChm("LnchPad Setup`\LnchPad Setup", "overWriteExisting")

if (retVal) ; error
{
	if (retVal < 0)
	MsgBox, 8192, , Could not find the Help file. Has it, or the script been moved?
	else
	MsgBox, 8192, , There is a problem with the help file. Code: %retVal%.
}
*/

		}
	}
return


LBEX_ItemFromCursor(HLB)
{
;https://www.autohotkey.com/boards/viewtopic.php?t=13008
	LB_ITEMFROMPOINT := 0x01A9
	VarSetCapacity(Point, 8, 0) ; POINT structure -> msdn.microsoft.com/en-us/library/dd162805(v=vs.85).aspx
	DllCall("GetCursorPos", "Ptr", &Point) ; -> msdn.microsoft.com/en-us/library/ms648390(v=vs.85).aspx
	DllCall("ScreenToClient", "Ptr", HLB, "Ptr", &Point) ; -> msdn.microsoft.com/en-us/library/dd162952(v=vs.85).aspx
	X := NumGet(Point, 0, "UShort") ; only 16 bits are used by LB_ITEMFROMPOINT
	Y := NumGet(Point, 4, "UShort") << 16 ; only 16 bits are used by LB_ITEMFROMPOINT
	SendMessage, %LB_ITEMFROMPOINT%, 0, % (X + Y), , ahk_id %HLB% ; msdn.microsoft.com/en-us/library/bb761323(v=vs.85).aspx
		if (ErrorLevel & 0xFFFF0000) ; the HIWORD of the return value is one if the cursor is outside the client area.
		return 0
	return (ErrorLevel & 0xFFFF) + 1 ; the return value contains the 0-based index of the item in the LOWORD.
}

;~LButton::
WM_LBUTTONDOWN(wParam, lParam, Msg, hWnd)
{
Global
	if (buttonBkdChange)
	return

	if (Msg == WM_HELPMSG)
	WM_HELP(0, lParam, WM_HELPMSG, hWnd)
	else
	{
	MouseGetPos, , , mWin, mControl ; mX relative to FORM
	;cX relative to FORM
	GuiControlGet, tmp, Name, % mControl
		if (InStr(mControl, "Static"))
		{
			if (InStr(tmp, "gamePic"))
			{
				GuiControlGet, tmp, , searchDrive
					if (!InStr(tmp, "Cancel Search"))
					resetSearch(searchStat, tabStat, gameList, maxDrives)
				return
			}
			if (InStr(tmp, "searchDrive" ))
			{
			CtlColors.Change(searchDriveHwnd, Vermilion, "White")
			buttonBkdChange := 1
			}
			else
			{
				if (InStr(tmp, "addToLnchPad"))
				{

				CtlColors.Change(addToLnchPadHwnd, Vermilion, "White")

				buttonBkdChange := 2
				if (searchStat > -1)
				resetSearch(searchStat, tabStat, gameList, maxDrives)
				}
			}
		SetTimer, MouseOffButton, 10
		}
		else
		{
			if (InStr(mControl, "Button")) ; Radio Controls
			{
			buttonBkdChange := 3
			GuiControl, Focus, addToLnchPad
			SetTimer, MouseOffButton, 10
			}
			else
			{
				if (InStr(mControl, "SysTabControl"))
				{

					if (searchStat == -1)
					{

					MsgBox, 8193, Active process on Tab, An operation is still active on the current tab.`n`nClick OK to cancel the operation and continue, or,`nCancel to wait until the operation has completed.
						IfMsgBox, OK
						searchStat := -2

					gosub LnchPadTab

					}

				}
				else
				{
				WinGetClass, class, ahk_id %hWnd%
					if (class == "tooltips_class32")
					ToolTip
				}
			}
		}
	}
		
return
}
MouseOffButton:
	if (getKeyState("LButton", "P"))
	return
MouseGetPos, , , , mControl ; mX relative to FORM
ControlGetPos, cX, cY, cWidth, cHeight, % mControl, A
GuiControlGet, tmp, Name, % mControl
	if (buttonBkdChange == 1)
	{
		if (InStr(tmp, "searchDrive" ))
		return

		switch tabStat
		{
		case 1:
		CtlColors.Change(searchDriveHwnd, Chocolate, "Yellow")
		case 2:
		CtlColors.Change(searchDriveHwnd, Taupe, "Goldenrod")
		case 3:
		CtlColors.Change(searchDriveHwnd, Black, "Silver")
		case 4:
		CtlColors.Change(searchDriveHwnd, Steingrau, "Goldenrod")
		case 5:
		CtlColors.Change(searchDriveHwnd, Auburn, "Yellow")
		case 6:
		CtlColors.Change(searchDriveHwnd, Steingrau, "White")
		}

	}
	else
	{
		if (InStr(tmp, "addToLnchPad"))
		return

		switch tabStat
		{
		case 1:
		CtlColors.Change(addToLnchPadHwnd, Chestnut, "Yellow")
		case 2:
		CtlColors.Change(addToLnchPadHwnd, Khakigrau, "Goldenrod")
		case 3:
		CtlColors.Change(addToLnchPadHwnd, Onyx, "Silver")
		case 4:
		CtlColors.Change(addToLnchPadHwnd, Feldgrau, "Goldenrod")
		case 5:
		CtlColors.Change(addToLnchPadHwnd, Vermilion, "Yellow")
		case 6:
		CtlColors.Change(addToLnchPadHwnd, Khakigrau, "White")
		}
	}
buttonBkdChange := 0
SetTimer, MouseOffButton, Off
return

GetDriveLetters(ByRef FATDrives)
{
;https://autohotkey.com/board/topic/89345-physical-hard-drive-information/
for Prt in (ComObjGet("winmgmts:{impersonationLevel=impersonate}!\\" & strComputer & "\root\cimv2").ExecQuery("Select * FROM Win32_LogicalDiskToPartition"),DP:=[])
    DP.Insert(RegExReplace(Prt.Antecedent " " Prt.Dependent,"^.*?""|"".*"))

for Prp in (ComObjGet("winmgmts:{impersonationLevel=impersonate}!\\" & strComputer & "\root\cimv2").ExecQuery("Select * FROM Win32_LogicalDisk"),DINF:=[],i:=1)
    (f:=Prp.FileSystem) ? DINF.Insert(DP[i++] " FileSystem: " f " DriveLetter: " Prp.Name):

; Place Info in Disp ( Temp Display ) Variable.
; Recall Array Element using: DINF[*some number*] 
; The below for-loop and msgbox can be removed!
;DriveLetter := []
DriveLetter := ""
DriveLetter := Object()
FATDrivesTmp := ""
FATDrivesTmp := Object()

	for i in (DINF)
	{
		if (InStr(DINF[i], "NTFS")) || (InStr(DINF[i], "FAT"))
		{
		;tmp := SubStr(DINF[i], -1, 1)
		DriveLetter.Push(SubStr(DINF[i], -1, 1))
			if (InStr(DINF[i], "FAT"))
			FATDrivesTmp.Push(SubStr(DINF[i], -1, 1))
		}
		;Disp.=DINF[i] "`r`n"
	}
FATDrives := join(FATDrivesTmp)
return DriveLetter
}
ResetDrives(ByRef DriveLetterBak, ByRef DriveLetter, maxDrives)
{
	loop % maxDrives
	{
		if (DriveLetterBak[A_Index])
		{
		GuiControl, , Drive%A_Index%, 0
		DriveLetter[A_Index] := ""
		}
	}
DriveLetterBak := ""
}
resetSearch(ByRef searchStat, tabStat, gameList, maxDrives)
{
searchStat := 0

	loop % maxDrives
	{
	guiControl, Hide, Drive%A_Index%
	}
guiControl, , searchDrive, % "&Search PC for " gameList[tabStat] " Apps"
GuiControl,, addToLnchPad, % "&Locate " gameList[tabStat] " LnchPad Slot"

overWriteIniFile := 1
GuiControl,, overWriteIni, 0
GuiControl,, updateIni, 0
;addGameShortCut value changed on tab switch
GuiControl, Hide, overWriteIni
GuiControl, Hide, updateIni
GuiControl, Hide, addGameShortCut

}

join(strArray)
{
s := ""
	for i,v in strArray
	s .= "," . v
return substr(s, 2)
}

FileCopy(Src, Dst, Overwrite := 0)
{
strRetVal := ""
	Try
	{
	FileCopy, %Src%, %Dst%, %Overwrite%
	}
	Catch e
	{
	strRetVal := Src . " could not be copied with error: " . e
	}
return strRetVal
}
; https://www.autohotkey.com/boards/viewtopic.php?f=6&t=68842
; path:
;	where to search, drive or fully specified folder, for example C:\folder
; matchList:
;	comma separated list of search strings
; delim:
;	fileList delimiter, default is newline `n
; num:
;	variable that receives number of files returned or error status when trying to obtain:
;	-1, -2: root folder handle or info, -3, -4: path handle or info (To be done), -5,  Createfile root handle
;	 -6: Query Journal fail ,-7: volume handle or info, -8: USN journal handle
;
; return VALUE:
;	fileList or empty string if error occured (also see 'num' parameter)

ListMFTfiles(Drive, matchList1 := "", matchList2 := "", delim := "`n", byref numF := "")
{
; Fun fact: NTFS max files is 4,294,967,295  (2³² minus 1 file)
;Windows 2000 Change Journal Explained:  https://docs.microsoft.com/en-us/previous-versions/windows/it-pro/windows-2000-server/bb742450(v=technet.10)
;Nfts Workings: https://docs.microsoft.com/en-us/previous-versions/windows/it-pro/windows-server-2003/cc781134(v=ws.10)
;=== init
	Static FILE_FLAG_BACKUP_SEMANTICS := 0x02000000, FILE_FLAG_SEQUENTIAL_SCAN := 0x08000000
	Static FSCTL_CREATE_USN_JOURNAL := 0x000900e7, FSCTL_GET_NTFS_VOLUME_DATA := 0x000900F4
	Static FSCTL_QUERY_USN_JOURNAL := 0x000900f4, FSCTL_ENUM_USN_DATA := 0x000900b3
	Static SHARE_RW := 0x00000003 ;FILE_SHARE_READ | FILE_SHARE_WRITE 
	Static GENERIC_RW := 0xC0000000 ;GENERIC_READ | GENERIC_WRITE
	Static sz_voldata := 96, DWORDLONG_SIZE := 8, STATUS_SUCCESS := 1, OPEN_EXISTING := 0x00000003

	Global searchStat

	t0 := A_TickCount
	strTmp := ""
	Drive := Drive . ":"


	;Thread, NoTimers & Critical prevents the searchStat interrupt below

	;=== get root folder ("\") refnumber

	hRoot := dllCall("CreateFile", "wstr", "\\.\" drive "\", "uint", 0, "uint", SHARE_RW, "uint", 0
					, "uint", OPEN_EXISTING, "uint", FILE_FLAG_BACKUP_SEMANTICS, "Ptr", 0, "Ptr")
		if (hRoot == -1)
		{
		numF := -1
		return
		}
	;BY_HANDLE_FILE_INFORMATION
	;	0	DWORD dwFileAttributes;
	;	4	FILETIME ftCreationTime: DWORD Lodate DWORD Hidate
	;	12	FILETIME ftLastAccessTime; DWORD Lodate DWORD HIdate
	;	20	FILETIME ftLastWriteTime;
	;	28	DWORD dwVolumeSerialNumber;
	;	32	DWORD nFileSizeHigh;
	;	36	DWORD nFileSizeLow;
	;	40	DWORD nNumberOfLinks;
	;	44	DWORD nFileIndexHigh;
	;	48	DWORD nFileIndexLow;
	;	See note in DOCs:  Windows Server 2012 requires GetFileInformationByHandleEx for hRoot, which is 128 bits  on that system.
	;	Else it will not work on Windows Server 2012 running the Refs filesystem!
	VarSetCapacity(fi, 52, 0)

		if (dllCall("GetFileInformationByHandle", "uint", hRoot, "uint", &fi) != STATUS_SUCCESS)
		{
		dllCall("CloseHandle", "uint", hRoot)
		numF := -2
		return
		}
	dllCall("CloseHandle", "uint", hRoot)
	dirDict := {}
	refMax := ((numget(fi, 44)<<32) + numget(fi, 48)) ;nFileIndex: combined Lo Hi to get a 16 digit file identifier of root
	; The big one!
	dirDict[refMax] := {"name":drive, "parent":"0", "files":{}}


;=== open volume

	hJRoot := dllCall("CreateFile", "wstr", "\\.\" drive, "uint", GENERIC_RW, "uint", SHARE_RW, "uint", 0
				, "uint", OPEN_EXISTING, "uint", FILE_FLAG_SEQUENTIAL_SCAN, "Ptr")
		if(hJRoot == -1)
		{
		numF := -5
		return
		}

;=== open Update Sequence Number (USN) journal ("not to be confused with NTFS, a journaling file system which uses the NTFS Log ($LogFile) to record metadata changes to the volume")
; Ref https://blog.synsysit.com/smack-your-head-with-usn-journal-everything-you-ever-wanted-to-know-about-this-digital-forensic-artifact/

	; Not sure if the following works on pre NTFS 3.0 (introduced on Win2K)
	VarSetCapacity(cujd, 16) ;CREATE_USN_JOURNAL_DATA: cujd
	numput(0x800000, cujd, 0, "uint64") ;DWORDLONG: MaximumSize: target maximum size that the NTFS file system allocates for the change journal, in bytes
	numput(0x100000, cujd, 8, "uint64") ;DWORDLONG: AllocationDelta: size of memory allocation that is added to the end and removed from the beginning of the change journal, in bytes
	; FSCTL_* in this function supported in Windows Server 2012 only with a Cluster Shared Volume File System (CsvFS)
	; FSCTL_CREATE_USN_JOURNAL requires Admin privileges
	; cb receives a null ptr- it seems the documentation wants it there as a dummy.

		if (dllCall("DeviceIoControl", "uint", hJRoot, "uint", FSCTL_CREATE_USN_JOURNAL
		, "Ptr", &cujd, "uint", 16, "Ptr", 0, "uint", 0, "uint*", cb, "Ptr", 0) != STATUS_SUCCESS)
		{
		dllCall("CloseHandle", "uint", hJRoot)
		numF := -6
		return
		}
/*
Common errors
ERROR_INVALID_FUNCTION
The specified volume does not support change journals.

ERROR_INVALID_PARAMETER
One or more parameters is invalid, for example, DeviceIoControl returns this error code if the handle supplied is not a volume handle.

ERROR_JOURNAL_DELETE_IN_PROGRESS
An attempt is made to read from, create, delete, or modify the journal while a journal deletion is in process, or an attempt is made to write a USN record while a journal deletion is in process.
*/


;=== estimate overall number of files

	; NTFS_VOLUME_DATA_BUFFER (is not documented in MS Docs anymore)
	;	0	LARGE_INTEGER (unique) VolumeSerialNumber;
	;	8	LARGE_INTEGER NumberSectors;
	;	16	LARGE_INTEGER TotalClusters (used and free) ;
	;	24	LARGE_INTEGER FreeClusters;
	;	32	LARGE_INTEGER TotalReserved;
	;	40	DWORD         BytesPerSector;
	;	44	DWORD         BytesPerCluster (cluster factor);
	;	48	DWORD         BytesPerFileRecordSegment;
	;	52	DWORD         ClustersPerFileRecordSegment;
	;	56	LARGE_INTEGER MftValidDataLength (length of the master file table, in bytes);
	;	64	LARGE_INTEGER MftStartLcn (starting logical cluster number of the master file table);
	;	72	LARGE_INTEGER Mft2StartLcn (starting logical cluster number of the master file table mirror);
	;	80	LARGE_INTEGER MftZoneStart (starting logical cluster number of the master file table zone);
	;	88	LARGE_INTEGER MftZoneEnd (ending logical cluster number of the master file table zone);

	VarSetCapacity(voldata, sz_voldata, 0)
	mftFiles := 0
	mftFilesMax := 0
	; see https://docs.microsoft.com/en-us/openspecs/windows_protocols/ms-fscc/a5bae3a3-9025-4f07-b70d-e2247b01faa6
	; cb a pointer to a variable that receives the size of voldata, in bytes.

		if (dllCall("DeviceIoControl", "uint", hJRoot, "uint", FSCTL_GET_NTFS_VOLUME_DATA
		, "Ptr", 0, "uint", 0, "Ptr", &voldata, "uint", sz_voldata, "uint*", cb, "Ptr", 0) == STATUS_SUCCESS)
		{
			if (i := numget(voldata, 48, "uint"))
			mftFilesMax := numget(voldata, 56, "uint64")//i ;MftValidDataLength/BytesPerFileRecordSegment
		}
		else
		{
		numF := -7
		return
		}
	/*
	Common errors
	STATUS_INVALID_PARAMETER

	0xC000000D

	The handle specified is not open.

	STATUS_VOLUME_DISMOUNTED

	0xC000026E

	The specified volume is no longer mounted.

	STATUS_BUFFER_TOO_SMALL

	0xC0000023
	*/

	;=== USN journal query

	;USN_JOURNAL_DATA_V0 returned in object ujd
	;USN_JOURNAL_DATA_V1 is not supported before Windows 8 and Windows Server 2012. USN_JOURNAL_DATA_V2 is not supported before Windows 8.1 and Windows Server 2012 R2.
	;	0	DWORDLONG UsnJournalID (The NTFS file system uses this current journal identifier for an integrity check)
	;	8	USN FirstUsn (number of first record that can be read from the journal)
	;	16	USN NextUsn (number of next record to be written to the journal)
	;	24	USN LowestValidUsn (First record written into the journal for this journal instance)
	;	32	USN MaxUsn (The largest USN that the change journal supports.)
	;	40	DWORDLONG MaximumSize (target maximum size for the change journal, in bytes)
	;	48	DWORDLONG AllocationDelta (number of bytes of disk memory added to the end and removed from the beginning of the change journal each time memory is allocated or deallocated)
	;	V1
	;	56	WORD MinSupportedMajorVersion (minimum supported version of the USN change journal supported by the filesystem)
	;	58	WORD MaxSupportedMajorVersion (maximum supported version of the USN change journal supported by the filesystem)
	;	V2
	;	60	DWORD Flags (A toggle: FLAG_USN_TRACK_MODIFIED_RANGES_ENABLE := 0x00000001 Range tracking is turned on for the volume, 0 otherwise)
	;	64	DWORDLONG RangeTrackChunkSize (granularity of tracked ranges, valid when flags above := 1)
	;	72	LONGLONG RangeTrackFileSizeThreshold (File size threshold to start tracking range for files with equal or larger size, valid when flags above := 1)
	VarSetCapacity(ujd, 56, 0)
	; cb a pointer to a variable that receives the size of ujd, in bytes.
		if( dllCall("DeviceIoControl", "uint", hJRoot, "uint", FSCTL_QUERY_USN_JOURNAL
		, "Ptr", 0, "uint", 0, "Ptr", &ujd, "uint", 56, "uint*", cb, "Ptr", 0) != STATUS_SUCCESS)
		{
		dllCall("CloseHandle", "uint", hJRoot)
		numF := -8
		return
		}
/*
Common errors
ERROR_INVALID_FUNCTION
The specified volume does not support change journals. Where supported, change journals can also be deleted.

ERROR_INVALID_PARAMETER
One or more parameters is invalid.

For example, DeviceIoControl returns this error code if the handle supplied is not a volume handle.

ERROR_JOURNAL_DELETE_IN_PROGRESS
An attempt is made to read from, create, delete, or modify the journal while a journal deletion is in process, or an attempt is made to write a USN record while a journal deletion is in process.

ERROR_JOURNAL_NOT_ACTIVE
An attempt is made to write a USN record or to read the change journal while the journal is inactive.

*/

	JournalMaxSize := numget(ujd, 40, "uint64") + numget(ujd, 48, "uint64") ;MaximumSize + AllocationDelta
	JournalChunkSize := 0x100000 ;1MB chunk, ~10-20 read ops for 150k files
		if (!mftFilesMax) ; then get an estimate (which might impact performance a little)
		mftFilesMax := JournalMaxSize/JournalChunkSize ;

	t1 := A_TickCount
	Progress, Show
;=== enumerate USN journal

	cb := 0
	numF := 0
	numD := 0
	VarSetCapacity(pData, DWORDLONG_SIZE + JournalChunkSize, 0)
	dirDict.SetCapacity(JournalMaxSize//(128 * 50)) ;average file name ~64 widechars, dircount is ~1/50 of filecount. dirDict[refMax] is preserved, of course

	;MFT_ENUM_DATA for med.
	;	0	DWORDLONG StartFileReferenceNumber (ordinal position within the files on the current volume at which the enumeration is to begin);
	;	8	USN LowUsn (lower bounds of range of USN values used to filter which records are returned);
	;	16	USN HighUsn(upper bounds of range of USN values used to filter which files are returned);
	;	V1 (Only for Windows Server 2012)
	;	24	WORD MinMajorVersion (minimum supported major version for the USN change journal)
	;	26	WORD MaxMajorVersion (maximum supported major version for the USN change journal: 2 or 3 dependent on USN_RECORD_V2 or USN_RECORD_V3)
	VarSetCapacity(med, 24, 0)
	numput(numget(ujd, 16, "uint64"), med, 16, "uint64") ;med.HighUsn=ujd.NextUsn
		; Outer loop is through JournalChunkSize. cb a pointer to a variable that receives the size of med, in bytes.
		while (dllCall("DeviceIoControl", "uint", hJRoot, "uint", FSCTL_ENUM_USN_DATA
		, "Ptr", &med, "uint", 24, "Ptr", &pData, "uint", DWORDLONG_SIZE + JournalChunkSize, "uint*", cb, "Ptr", 0))
		{

/*
Common errors

ERROR_INVALID_FUNCTION
The file system on the specified volume does not support this control code.

ERROR_INVALID_PARAMETER
One or more parameters is invalid e.g. handle supplied is not a volume handle.
*/
		
			if (searchStat == -2)
			return 0
			else
			Progress, % (mftFiles*86)//mftFilesMax


		t1a := A_TickCount
		

		strTmp := join(matchList1) . matchList2
		pUSN := &pData + DWORDLONG_SIZE ; &pData: A pointer to the output buffer that ***receives a USN*** followed by zero or more USN_RECORD_V2 or USN_RECORD_V3 structures so...
										; The USN first received may not be the same as the USN in following the USN_RECORD structure. A USN is DWORDLONG.
			while (cb > DWORDLONG_SIZE) ;cb decrements by USN.RecordLength as pUSN increments by USN.RecordLength
			{
			mftFiles++
			; 	USN_RECORD_COMMON_HEADER applies to USN_RECORD_V2, USN_RECORD_V3 and USN_RECORD_V4
			;	0	DWORD RecordLength (total length of a record, in bytes);
			;	4	WORD   MajorVersion (major version number of the change journal software for this record, here it's 3);
			;	6	WORD   MinorVersion (minor version number of the change journal software for this record);
			
			;	USN_RECORD V2 (XP & Server 2003)... (V3 (Win8+ & Win Server 2012) looks like this structure- but FileReferenceNumber & ParentFileReferenceNumber are 128 bit)
			;	https://docs.microsoft.com/en-us/openspecs/windows_protocols/ms-fscc/d2a2b53e-bf78-4ef3-90c7-21b918fab304
			;	8	DWORDLONG FileReferenceNumber (64 bit ordinal number of the file or directory for which this record notes changes);
			;	16	DWORDLONG ParentFileReferenceNumber (64-bit ordinal number of the directory where the file or directory that is associated with this record is located);
			;	24	USN Usn (USN of this record);
			;	32	LARGE_INTEGER TimeStamp (standard UTC time stamp (FILETIME) of this record, in 64-bit format.);
			;	40	DWORD Reason ( flags that identify reasons for changes that have accumulated in this file or directory journal record since the file or directory opened see: https://docs.microsoft.com/en-us/windows/win32/api/winioctl/ns-winioctl-usn_record_v3);
			;	44	DWORD SourceInfo (Additional info on the source of the change, set by the FSCTL_MARK_HANDLE of the DeviceIoControl operation);
			;	48	DWORD SecurityId (unique security identifier assigned to the file or directory associated with this record);
			;	52	DWORD FileAttributes (attributes for the file or directory associated with this record, as returned by the GetFileAttributes);
			;	56	WORD   FileNameLength (length of the name of the file or directory associated with this record, in bytes);
			;	58	WORD   FileNameOffset ( offset of the FileName member from the beginning of the structure.);
			;	60	WCHAR FileName[1] (name of the file or directory associated with this record in Unicode format. This file or directory name is of variable length);
			;	USN_RECORD_V4 record is only output when range tracking is turned on. Suitable tor Win8.1+, the structure varies from the above e.g. TimeStamp
			fnsize := numget(pUSN + 56, "ushort")

			fname := strget(pUSN + 60, fnsize//2, "UTF-16")
			isdir := numget(pUSN + 52) & 0x10 ;USN.FileAttributes & FILE_ATTRIBUTE_DIRECTORY
			ref := numget(pUSN + 8, "uint64") ;USN.FileReferenceNumber
			refparent := numget(pUSN + 16, "uint64") ;USN.ParentFileReferenceNumber

				if (isdir)
				{
				v := dirDict[ref]
					if (v == "") ;Not populated yet
					{
					v := {}
					v.files := {}
					}
				v.setCapacity(4) ;MaxItems: 4th value 'dir' is created later in resolveFolder()
				v.setCapacity("name", fnsize), v.name := fname
				v.setCapacity("parent", strlen(refparent)), v.parent := refparent
				; "Windows computes the file reference number as follows: 48 bits are the index of the file's primary record in the master file table (MFT), and the other 16 bits are a sequence number"
				; The following bit shift will fail for nested directories of > Some_To_be_Tested_Value (20 at least). If the bits in a refparent are joined, its length looks to be pretty much the same irrespective of its distance from Root.
				;v.setCapacity("parent", strlen(refparent)<<1), v.parent := refparent
				dirDict[ref] := v
				numD++
				}
				else
				{
					if fname contains %strTmp%
					{
					v := dirDict[refparent]
						if (v == "")
						{
						v := {}
						dirDict[refparent] := {"files":v}
						}
						else
						v := v.files

					; 3rd value of v
					v.SetCapacity(ref, fnsize), v[ref] := fname
					numF++
					}
				}
			
			; Numget: "Do not pass a variable reference if the variable contains the target address; in that case, pass an expression such as MyVar+0"
			i := numget(pUSN + 0, "UInt") ;USN.RecordLength
			pUSN += i
			cb -= i
			}

		nextUSN := numget(pData, "uint64")
		numput(nextUSN, med, "uint64")

		t1b += A_TickCount - t1a
		}

	dllCall("CloseHandle", "uint", hJRoot)

	t2 := A_TickCount
	Progress, 87




;=== connect files to parent folders & build new cache
	VarSetCapacity(fileList, numF*200) ;average full filepath ~100 widechars
	numF := 0

	for dk, dv in dirDict
		if (dv.files.getCapacity())
		{
			dir := _ListMFTfiles_resolveFolder(dirDict, dk)
				for k, v in dv.files
				{
				fileList .= drive . dir . v . delim
				numF++ ; trailing ~n
				}
		}

	dirDict=
	VarSetCapacity(fileList, -1) ;Specify -1 for RequestedCapacity to update the variable's internally-stored string length to the length of its current contents.

	t3 := A_TickCount
	Progress, 98

;=== sort
	Sort, fileList, D%delim%


	t4:=A_TickCount
	;Msgbox, 8192,, % "init`tenum`twinapi`tconnect`tsort`ttotal, ms`n" (t1-t0) "`t" t1b "`t" (t2-t1-t1b) "`t" (t3-t2) "`t" (t4-t3) "`t" (t4-t0) "`n`ndirs:`t" numD "`nfiles:`t" numF
	Progress, 100

	return fileList

}

_ListMFTfiles_resolveFolder(byref dirDict, byref ddref)
{
	p := dirDict[ddref], pd := p.dir
	if (!pd)
	{
		pd := (p.parent ? _ListMFTfiles_resolveFolder(dirDict, p.parent) : "") p.name "\"
		p.setCapacity("dir", strlen(pd )* 2) ; wchar_t
		p.dir := pd
	}
	return pd
}

; ======================================================================================================================
; AHK 1.1+
; ======================================================================================================================
; Function:          Auxiliary object to color controls on WM_CTLCOLOR... notifications.
;                    Supported controls are: Checkbox, ComboBox, DropDownList, Edit, ListBox, Radio, Text.
;                    Checkboxes and Radios accept only background colors due to design.
; Namespace:         CtlColors
; Tested with:       1.1.25.02
; Tested on:         Win 10 (x64)
; Change log:        1.0.04.00/2017-10-30/just me  -  added transparent background (BkColor = "Trans").
;                    1.0.03.00/2015-07-06/just me  -  fixed Change() to run properly for ComboBoxes.
;                    1.0.02.00/2014-06-07/just me  -  fixed __New() to run properly with compiled scripts.
;                    1.0.01.00/2014-02-15/just me  -  changed class initialization.
;                    1.0.00.00/2014-02-14/just me  -  initial release.
; ======================================================================================================================
; This software is provided 'as-is', without any express or implied warranty.
; In no event will the authors be held liable for any damages arising from the use of this software.
; ======================================================================================================================
Class CtlColors
{
; ===================================================================================================================
; Class variables
; ===================================================================================================================
; Registered Controls
Static Attached := {}
; OnMessage Handlers
Static HandledMessages := {Edit: 0, ListBox: 0, Static: 0}
; Message Handler Function
Static MessageHandler := "CtlColors_OnMessage"
; Windows Messages
Static WM_CTLCOLOR := {Edit: 0x0133, ListBox: 0x134, Static: 0x0138}
; HTML Colors (BGR NOT RGB)
Static HTML := {CYAN: 0xFFFF00, BLACK: 0x000000, BLUE: 0xFF0000, FUCHSIA: 0xFF00FF, GRAY: 0x808080, AUBURN: 0XA52A2A
 , LIME: 0X00FF00, MAROON: 0X000080, NAVY: 0X800000, OLIVE: 0X008080, PURPLE: 0X800080, RED: 0X0000FF, FELDGRAU: 0X5d5d3d
 , SILVER: 0XC0C0C0, TEAL: 0X808000, WHITE: 0XFFFFFF, YELLOW: 0X00FFFF, ORANGE: 0X00A5FF, BEIGE: 0XDCF5F5, AVOCADO: 0X008000
 , CHESTNUT: 0X354595, CHOCOLATE: 0X003F7B, TAUPE: 0X323C48, SALMON: 0X7280FA, VIOLET: 0XFF007F, GRAPE: 0XA82D6F, STEINGRAU: 0X555548
 , PEACH: 0XB4E5FF, VERMILION: 0X3442E3, CERULEAN: 0XA77B00, TURQUOISE: 0XD0E040, VIRIDIAN: 0X6D8240, DKSALMON: 0XE9967A
 , PLUM: 0X85458E, MAGENTA: 0XA653F6, GOLD: 0X00D7FF, GOLDENROD: 0X20A5DA, GREEN: 0X008000, ONYX: 0X393835, KHAKIGRAU: 0X746643}

 ; Transparent Brush
Static NullBrush := DllCall("GetStockObject", "Int", 5, "UPtr")
; System Colors
Static SYSCOLORS := {Edit: "", ListBox: "", Static: ""}
; Error message in case of errors
Static ErrorMsg := ""
; Class initialization
Static InitClass := CtlColors.ClassInit()
; ===================================================================================================================
; Constructor / Destructor
; ===================================================================================================================
__New()
{ ; You must not instantiate this class!
	if (This.InitClass == "!DONE!") { ; external call after class initialization
	This["!Access_Denied!"] := True
return False
}
}
; ----------------------------------------------------------------------------------------------------------------
__Delete()
{
	if This["!Access_Denied!"]
	return
This.Free() ; free GDI resources
}
; ===================================================================================================================
; ClassInit       Internal creation of a new instance to ensure that __Delete() will be called.
; ===================================================================================================================
ClassInit()
{
CtlColors := New CtlColors
return "!DONE!"
}
; ===================================================================================================================
; CheckBkColor    Internal check for parameter BkColor.
; ===================================================================================================================
CheckBkColor(ByRef BkColor, Class)
{
This.ErrorMsg := ""

	if (BkColor != "") && !This.HTML.HasKey(BkColor) && !RegExMatch(BkColor, "^[[:xdigit:]]{6}$")
	{
	This.ErrorMsg := "Invalid parameter BkColor: " . BkColor
	return False
	}
BkColor := BkColor = "" ? This.SYSCOLORS[Class]
:  This.HTML.HasKey(BkColor) ? This.HTML[BkColor]
:  "0x" . SubStr(BkColor, 5, 2) . SubStr(BkColor, 3, 2) . SubStr(BkColor, 1, 2)
return True
}
; ===================================================================================================================
; CheckTxColor    Internal check for parameter TxColor.
; ===================================================================================================================
CheckTxColor(ByRef TxColor)
{
This.ErrorMsg := ""

	if (TxColor != "") && !This.HTML.HasKey(TxColor) && !RegExMatch(TxColor, "i)^[[:xdigit:]]{6}$")
	{
	This.ErrorMsg := "Invalid parameter TextColor: " . TxColor
	return False
	}
TxColor := TxColor = "" ? ""
:  This.HTML.HasKey(TxColor) ? This.HTML[TxColor]
:  "0x" . SubStr(TxColor, 5, 2) . SubStr(TxColor, 3, 2) . SubStr(TxColor, 1, 2)
return True
}
; ===================================================================================================================
; Attach          Registers a control for coloring.
; Parameters:     HWND        - HWND of the GUI control                                   
;                 BkColor     - HTML color name, 6-digit hexadecimal RGB value, or "" for default color
;                 ----------- Optional 
;                 TxColor     - HTML color name, 6-digit hexadecimal RGB value, or "" for default color
; return values:  On success  - True
;                 On failure  - False, CtlColors.ErrorMsg contains additional informations
; ===================================================================================================================
Attach(HWND, BkColor, TxColor := "")
{
; Names of supported classes
Static ClassNames := {Button: "", ComboBox: "", Edit: "", ListBox: "", Static: ""}
; Button styles
Static BS_CHECKBOX := 0x2, BS_RADIOBUTTON := 0x8
; Editstyles
Static ES_READONLY := 0x800
; Default class background colors
Static COLOR_3DFACE := 15, COLOR_WINDOW := 5

This.ErrorMsg := ""

; Initialize default background colors on first call -------------------------------------------------------------
	if (This.SYSCOLORS.Edit == "")
	{
	This.SYSCOLORS.Static := DllCall("User32.dll\GetSysColor", "Int", COLOR_3DFACE, "Uint")
	This.SYSCOLORS.Edit := DllCall("User32.dll\GetSysColor", "Int", COLOR_WINDOW, "Uint")
	This.SYSCOLORS.ListBox := This.SYSCOLORS.Edit
	}

	; Check colors ---------------------------------------------------------------------------------------------------
	If (BkColor == "") && (TxColor == "")
	{
	This.ErrorMsg := "Both parameters BkColor and TxColor are empty!"
	return False
	}

	; Check HWND -----------------------------------------------------------------------------------------------------
	if !(CtrlHwnd := HWND + 0) || !DllCall("User32.dll\IsWindow", "UPtr", HWND, "Uint")
	{
	This.ErrorMsg := "Invalid parameter HWND: " . HWND
	return False
	}
	if This.Attached.HasKey(HWND)
	{
	This.ErrorMsg := "Control " . HWND . " is already registered!"
	return False
	}

Hwnds := [CtrlHwnd]

; Check control's class ------------------------------------------------------------------------------------------
Classes := ""
WinGetClass, CtrlClass, ahk_id %CtrlHwnd%
This.ErrorMsg := "Unsupported control class: " . CtrlClass

	if !ClassNames.HasKey(CtrlClass)
	return False
ControlGet, CtrlStyle, Style, , , ahk_id %CtrlHwnd%

	if (CtrlClass == "Edit")
	Classes := ["Edit", "Static"]
	else if (CtrlClass == "Button")
	{
		if (CtrlStyle & BS_RADIOBUTTON) || (CtrlStyle & BS_CHECKBOX)
		Classes := ["Static"]
		else
		return False
	}
	else if (CtrlClass == "ComboBox")
	{
	VarSetCapacity(CBBI, 40 + (A_PtrSize * 3), 0)
	NumPut(40 + (A_PtrSize * 3), CBBI, 0, "Uint")
	DllCall("User32.dll\GetComboBoxInfo", "Ptr", CtrlHwnd, "Ptr", &CBBI)
	Hwnds.Insert(NumGet(CBBI, 40 + (A_PtrSize * 2, "UPtr")) + 0)
	Hwnds.Insert(Numget(CBBI, 40 + A_PtrSize, "UPtr") + 0)
	Classes := ["Edit", "Static", "ListBox"]
	}

	if !IsObject(Classes)
	Classes := [CtrlClass]

	; Check background color -----------------------------------------------------------------------------------------
	if (BkColor <> "Trans")
		if !This.CheckBkColor(BkColor, Classes[1])
		return False
	; Check text color -----------------------------------------------------------------------------------------------
	if !This.CheckTxColor(TxColor)
	return False
	; Activate message handling on the first call for a class --------------------------------------------------------
	for I, V In Classes
	{
	if (This.HandledMessages[V] == 0)
	OnMessage(This.WM_CTLCOLOR[V], This.MessageHandler)
	This.HandledMessages[V] += 1
	}

	; Store values for HWND ------------------------------------------------------------------------------------------
	if (BkColor == "Trans")
	Brush := This.NullBrush
	else
	Brush := DllCall("Gdi32.dll\CreateSolidBrush", "Uint", BkColor, "UPtr")

	for I, V In Hwnds
	This.Attached[V] := {Brush: Brush, TxColor: TxColor, BkColor: BkColor, Classes: Classes, Hwnds: Hwnds}

; Redraw control -------------------------------------------------------------------------------------------------
DllCall("User32.dll\InvalidateRect", "Ptr", HWND, "Ptr", 0, "Int", 1)
This.ErrorMsg := ""
return True
}
; ===================================================================================================================
; Change          Change control colors.
; Parameters:     HWND        - HWND of the GUI control
;                 BkColor     - HTML color name, 6-digit hexadecimal RGB value, or "" for default color
;                 ----------- Optional 
;                 TxColor     - HTML color name, 6-digit hexadecimal RGB value, or "" for default color
; return values:  On success  - True
;                 On failure  - False, CtlColors.ErrorMsg contains additional informations
; Remarks:        If the control isn't registered yet, Add() is called instead internally.
; ===================================================================================================================
Change(HWND, BkColor, TxColor := "")
{
; Check HWND -----------------------------------------------------------------------------------------------------
This.ErrorMsg := ""
HWND += 0
	if !This.Attached.HasKey(HWND)
	return This.Attach(HWND, BkColor, TxColor)
CTL := This.Attached[HWND]
; Check BkColor --------------------------------------------------------------------------------------------------
	if (BkColor <> "Trans")
		if !This.CheckBkColor(BkColor, CTL.Classes[1])
		return False
	; Check TxColor ------------------------------------------------------------------------------------------------
	if !This.CheckTxColor(TxColor)
	return False
; Store Colors ---------------------------------------------------------------------------------------------------
	if (BkColor <> CTL.BkColor)
	{
		if (CTL.Brush)
		{
			if (Ctl.Brush <> This.NullBrush)
			DllCall("Gdi32.dll\DeleteObject", "Prt", CTL.Brush)
		This.Attached[HWND].Brush := 0
		}

		if (BkColor == "Trans")
		Brush := This.NullBrush
		else
		Brush := DllCall("Gdi32.dll\CreateSolidBrush", "Uint", BkColor, "UPtr")

		for I, V In CTL.Hwnds
		{
		This.Attached[V].Brush := Brush
		This.Attached[V].BkColor := BkColor
		}
	}
	for I, V In Ctl.Hwnds
	This.Attached[V].TxColor := TxColor
This.ErrorMsg := ""
DllCall("User32.dll\InvalidateRect", "Ptr", HWND, "Ptr", 0, "Int", 1)
return True
}
; ===================================================================================================================
; Detach          Stop control coloring.
; Parameters:     HWND        - HWND of the GUI control
; return values:  On success  - True
;                 On failure  - False, CtlColors.ErrorMsg contains additional informations
; ===================================================================================================================
Detach(HWND)
{
This.ErrorMsg := ""
HWND += 0
	if This.Attached.HasKey(HWND)
	{
	CTL := This.Attached[HWND].Clone()
	if (CTL.Brush) && (CTL.Brush <> This.NullBrush)
	DllCall("Gdi32.dll\DeleteObject", "Prt", CTL.Brush)
		for I, V In CTL.Classes
		{
			if This.HandledMessages[V] > 0
			{
			This.HandledMessages[V] -= 1
				if This.HandledMessages[V] == 0
				OnMessage(This.WM_CTLCOLOR[V], "")
			}
		}
		for I, V In CTL.Hwnds
		This.Attached.Remove(V, "")

	DllCall("User32.dll\InvalidateRect", "Ptr", HWND, "Ptr", 0, "Int", 1)
	CTL := ""
	return True
	}
This.ErrorMsg := "Control " . HWND . " is not registered!"
return False
}
; ===================================================================================================================
; Free            Stop coloring for all controls and free resources.
; return values:  Always True.
; ===================================================================================================================
Free()
{
	for K, V In This.Attached
	{
		if (V.Brush) && (V.Brush <> This.NullBrush)
		DllCall("Gdi32.dll\DeleteObject", "Ptr", V.Brush)
	}

	for K, V In This.HandledMessages
	{
		if (V > 0)
		{
		OnMessage(This.WM_CTLCOLOR[K], "")
		This.HandledMessages[K] := 0
		}
	}
This.Attached := {}
return True
}
; ===================================================================================================================
; IsAttached      Check if the control is registered for coloring.
; Parameters:     HWND        - HWND of the GUI control
; return values:  On success  - True
;                 On failure  - False
; ===================================================================================================================
IsAttached(HWND)
{
return This.Attached.HasKey(HWND)
}


}
; END CLASS
; ======================================================================================================================
; ======================================================================================================================
; CtlColors_OnMessage
; This function handles CTLCOLOR messages. There's no reason to call it manually!
; ======================================================================================================================
CtlColors_OnMessage(HDC, HWND)
{
Critical
	if CtlColors.IsAttached(HWND)
	{
	CTL := CtlColors.Attached[HWND]
		if (CTL.TxColor != "")
		DllCall("Gdi32.dll\SetTextColor", "Ptr", HDC, "Uint", CTL.TxColor)

		if (CTL.BkColor == "Trans")
		DllCall("Gdi32.dll\SetBkMode", "Ptr", HDC, "Uint", 1) ; TRANSPARENT = 1
		else
		DllCall("Gdi32.dll\SetBkColor", "Ptr", HDC, "Uint", CTL.BkColor)
	return CTL.Brush
	}
}
SetTaskBarIcon(Hwnd)
{
WM_SETICON := 0x80
LR_LOADFROMFILE := 0x10
IconFile := A_ScriptDir . "\PrgLnch.ico"
hIcon := DllCall("LoadImage", "uint", 0, "str", IconFile, "uint", 1, "int", 0, "int", 0, "uint", LR_LOADFROMFILE)

	if (!hIcon)
	{
	MsgBox, 8192, Icon File, PrgLnch icon file missing or invalid!
	return
	}
;hIcon := Format("0x{:x}", hIcon + 0) : ; hIcon does not want hex formatting for ahk_id...
SendMessage, %WM_SETICON%, 0, %hIcon%,, % "ahk_id " . Hwnd
}

WM_HELP(wp_notused, lParam, _msg, _hwnd)
{
local Size         := NumGet(lParam +  0, "uint")
local ContextType  := NumGet(lParam +  4, "int")
local CtrlId       := Numget(lParam +  8, "int")
local ItemHandle   := Numget(lParam + 12 + 64bit * 4, "ptr")
local ContextId    := NumGet(lParam + 16 + 64bit * 8, "uint")
local MousePosX    := NumGet(lParam + 20 + 64bit * 8, "int")
local MousePosY    := NumGet(lParam + 24 + 64bit * 8, "int")

local retVal := 0, tmp := 0
;This key must be set to 1!
;HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced >> EnableBalloonTips

if (ItemHandle == searchDriveHwnd)
retVal := RunChm("LnchPad Setup`\LnchPad Setup", "SearchDrive")
else
if (ItemHandle == addToLnchPadHwnd)
retVal := RunChm("LnchPad Setup`\LnchPad Setup", "LocateSlot")
else
if (ItemHandle == updateIniHwnd)
retVal := RunChm("LnchPad Setup`\LnchPad Setup", "UpdateExisting")
else
if (ItemHandle == overWriteIniHwnd)
retVal := RunChm("LnchPad Setup`\LnchPad Setup", "overWriteExisting")
else
if (ItemHandle == addGameShortCutHwnd)
retVal := RunChm("LnchPad Setup`\LnchPad Setup", "includeGame")
else
{
	Loop, % maxGames
	{
		if (ItemHandle == PrgIndex%A_Index%Hwnd)
		{
		retVal := RunChm("LnchPad Setup`\LnchPad Setup", "Listbox")
		tmp := 1
		break
		}
	}
if (!tmp)
retVal := RunChm()
}

if (retVal) ; error
{
	if (retVal < 0)
	MsgBox, 8192, , Could not find the Help file. Has it, or the script been moved?
	else
	MsgBox, 8192, , There is a problem with the help file. Code: %retVal%.
}


}
RunChm(chmTopic := 0, Anchor := "", noActivate := 0)
{
x := 0, y := 0, w := 0, h := 0, tmp := 0, htmlHelp := "C:\Windows\hh.exe ms-its"

if (!(FileExist(A_ScriptDir . "\PrgLnch.chm")))
return -1

;Close existing
WinGet, tmp, List
	Loop, %tmp%
	{
	i := tmp%A_Index%
	WinGetTitle, strTmp, % "ahk_id " i

		if (strTmp == "PrgLnch_Help")
		{
		WinClose, ahk_id %i%
		sizeSet := 1
		}
	}

Sleep 30


WinGetPos, x, y, w, h, A


	if (chmTopic)
	run, %htmlHelp%:%A_ScriptDir%\PrgLnch.chm::/%chmTopic%.htm#%Anchor%,, UseErrorLevel
	else
	run, %htmlHelp%:%A_ScriptDir%\PrgLnch.chm::/About%A_Space%PrgLnch.htm,, UseErrorLevel

retVal := A_LastError
sleep, 120


if (!retVal && !sizeSet)
{
tmp := 0

	Loop
	{
	Sleep 30
	tmp++
		if (tmp == 1000)
		{
		msgbox, 8196, LnchPad: PrgLnch Help, Help has not started.`nReply:`n`nYes: Continue to wait.`nNo: Continue without waiting.
			IfMsgBox, Yes
			tmp := 0
			else
			break
		}
	} Until (WinActive("PrgLnch_Help"))



	if (WinExist())
	{
	;if  not maximised
	WinGetTitle, strTmp , A

		; Too bad if we missed it
		if (strTmp != "PrgLnch_Help")
		return retVal

	WinGet, tmp, MinMax
	;Tablet mode perhaps? https://autohotkey.com/boards/viewtopic.php?f=6&t=15619
	;We are launching as "normal" but just in case this is overidden by user modifying shortcut properties. (probably not)
		if (tmp)
		WinRestore
	WinGetPos, , , , tmp
	sleep, 60
	SysGet, md, MonitorWorkArea, % GetPrgLnchMonNum()

	dx := Round(mdleft + (mdRight - mdleft)/2)
	dy := Round(mdTop + (mdBottom - mdTop)/2)

	WinMove, A , , % mdRight - w, % mdTop, %w%, Floor(3*h/4)

	}
}
return retVal
}
ShellMessage(wParam, lParam)
{
WinGetTitle, strTmp, ahk_id %lParam%
;HSHELL_WINDOWACTIVATED || HSHELL_RUDEAPPACTIVATED
	if (wParam == 4 || wParam == 32772)
	{
		if (strTmp == "LnchPad Setup")
		goSub chmRButton
	}
}

GetMonWidth(GuiHwnd)
{
	SysGet, md, MonitorWorkArea, % GetPrgLnchMonNum(GuiHwnd)
	dx := mdRight - mdleft
	return dx
}
GetMonHeight(GuiHwnd)
{
	SysGet, md, MonitorWorkArea, % GetPrgLnchMonNum(GuiHwnd)
	dy := mdBottom - mdTop
	return dy
}
GetPrgLnchMonNum(Hwnd := 0)
{
iDevNumb := 9, monitorHandle := 0,  MONITOR_DEFAULTTONULL := 0, strTmp := ""
VarSetCapacity(monitorInfo, 40)
NumPut(40, monitorInfo)


	if (Hwnd)
	{
		if (monitorHandle := DllCall("MonitorFromWindow", "uint", hWnd, "uint", MONITOR_DEFAULTTONULL)) 
			&& DllCall("GetMonitorInfo", "uint", monitorHandle, "uint", &monitorInfo) 
		{
		msLeft :=		NumGet(monitorInfo, 4, "Int")
		msTop := 		NumGet(monitorInfo, 8, "Int")
		msRight := 		NumGet(monitorInfo, 12, "Int")
		msBottom := 	NumGet(monitorInfo, 16, "Int")
		mswLeft := 		NumGet(monitorInfo, 20, "Int")
		mswTop := 		NumGet(monitorInfo, 24, "Int")
		mswRight := 	NumGet(monitorInfo, 28, "Int")
		mswBottom :=	NumGet(monitorInfo, 32, "Int")
		mswPrimary :=	NumGet(monitorInfo, 36, "Int") & 1
		}
	}
	else
	{
	strTmp := A_CoordModeMouse
	CoordMode, Mouse, Screen
	MouseGetPos, x, y
	CoordMode, Mouse, % strTmp
	}

	; GetMonitorIndexFromWindow(windowHandle)

	Loop %iDevNumb%
	{
		SysGet, mt, Monitor, %A_Index%

		; Compare location to determine the monitor index.
		if (Hwnd)
		{
			if ((msLeft == mtLeft) and (msTop == mtTop)
				and (msRight == mtRight) and (msBottom == mtBottom))
			{
			msI := A_Index
			break
			}
		}
		else
		{
			if (x >= mtLeft && x <= mtRight && y <= mtBottom && y >= mtTop)
			{

			msI := A_Index
			break
			}
		}
	}


VarSetCapacity(monitorInfo, 0)
	if (msI)
	return msI
	else ; should never get here
	{
	strTmp := "Cannot retrieve Monitor info from the"
		if (fromMouse)
		MsgBox, 8192, Monitor Error, %strTmp% mouse cursor!
		else
		MsgBox, 8192, Monitor Error, %strTmp% target window!
	return 1 ;hopefully this monitor is the one!
	}
}