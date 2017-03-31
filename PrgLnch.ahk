;AutoHotkey /Debug C:\Users\New\Desktop\PrgLnch\PrgLnch.ahk
#SingleInstance, force
#NoEnv  ; Performance and compatibility with future AHK releases.
;#Warn, All , MsgBox ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
WorkingDirectory(0, A_ScriptDir) ; Ensures a consistent starting directory.
SetTitleMatchMode, 2
#MaxThreads 3
#Persistent
#Warn UseUnsetLocal, OutputDebug  ; Warn when a local variable is used before it's set; send to OutputDebug
; ListVars for debugging
SetBatchLines, 20ms
;https://autohotkey.com/boards/viewtopic.php?p=114554#p114554
IfNotExist, PrgLnchLoading.jpg
FileInstall PrgLnchLoading.jpg, PrgLnchLoading.jpg
sleep, 200

;Issues: chm file not deleted if in use
;XP: pictures in chm don't show
;Res changes occur when switching only between active Prgs and Prglnch ATM . Not other applications or  switching between active Prgs.

/*If !A_IsAdmin {
Run *RunAs "%A_ScriptFullPath%"
ExitApp
}
*/

;https://msdn.microsoft.com/en-us/library/vs/alm/dd145136(v=vs.85).aspx

Class PrgLnchOpt
	{
	temp := 0
	Hwnd()
	{
	Gui, PrgLnchOpt: +Hwndtemp
	This.PrgHwnd := temp
	Return This.PrgHwnd
	}
	X()
	{
	WinGetPos, X, , , , % "ahk_id" This.PrgHwnd
	Return X
	}
	Y()
	{
	WinGetPos, ,Y , , , % "ahk_id" This.PrgHwnd
	Return Y
	}
	Height()
	{
	WinGetPos, , , ,Height , % "ahk_id" This.PrgHwnd
	Return Height
	}
	Width()
	{
	WinGetPos, , ,Width , , % "ahk_id" This.PrgHwnd
	Return Width
	}
	}

Class PrgLnch
	{
	temp := 0
	static Title := "PrgLnch" ;
	static Title1 := "Notepad++"
	static NplusplusClass := "ahk_exe Notepad++.exe"
	static ProcScpt := "ahk_exe PrgLnch.exe"
	static ProcAHK := "ahk_exe AutoHotkey.exe"
	static PrgHwnd := ""
	
	Hwnd()
	{
	Gui, PrgLnch: +Hwndtemp
	This.PrgHwnd := temp
	Return This.PrgHwnd
	}
	Class()
	{
	temp := This.ProcAHK
	;temp := This.ProcScpt
	;temp := This.NplusplusClass
	text := ""
	WinGetClass, temp, % temp
	if (!temp)
	{
	Gui, PrgLnch: +LastFound
	WinGetClass, temp, % temp
	}
	;WinGetText, text, ahk_class %temp%
	;For N++ t& ProcScpt his is the entire script!
	Return temp
	}
	PID()
	{
	Process, Exist
	If !ErrorLevel
	MsgBox, 8192, , Cannot retrieve the PID of PrgLnch!
	Return ErrorLevel
	}
	Activate() ;Activates window with Title - This.Title
	{
		IfWinExist, This.Title
		WinActivate
		else
		IfWinExist, This.Title1
		WinActivate
	}
	__New()
	{
		ObjInsert(this,"",[])
	}
	__GET(what){
			Return this["",what]
	}
	__SET(what,value){
		Return this["",what]:=value
	}
	
	}




SplashImage, PrgLnchLoading.jpg, A B,,,LnchSplash


(A_PtrSize = 8)? 64bit := 1 : 64bit := 0 ; ONLY checks .exe bitness
updateStatus := 1
;Change display flags
CDS_TEST := 0x00000002
CDS_RESET := 0x40000000
CDS_FULLSCREEN := 0x00000004
OffsetDWORD := 4
WS_CAPTION := 0x00C00000
WS_SIZEBOX := 0x00040000
WindowStyle := WS_CAPTION|WS_SIZEBOX
WS_EX_CONTEXTHELP := 0x00000400
;listBox
LB_GETITEMHEIGHT := 0x01A1
LB_GETCOUNT := 0x018B
LB_SETCURSEL := 0x0186
;HWND
PresetHwnd := 0
BtchPrgHwnd := 0
batchPrgStatusHwnd := 0

;combo
PrgChoiceHwnd := 0
;Dropdown
DevNumHwnd := 0
;edit
cmdLinHwnd := 0
PresetNameHwnd := 0
UpdturlHwnd := 0
;check
PrgIntervalHwnd := 0
DefPresetHwnd := 0
PrgExitTermChkHwnd := 0
DefaultPrgHwnd := 0
RegoHwnd := 0
allModesHwnd := 0
PrgLnchHdHwnd := 0
BordlessHwnd := 0
PrgPriorityHwnd := 0
PrgCanBeShortctHwnd := 0
;Radio
TestHwnd := 0
HWNDFModeHwnd := 0
DynamicHwnd := 0
TmpHwnd := 0
;Button
RunBatchPrgHwnd := 0
GoConfigHwnd := 0
quitHwnd := 0
MkShortcutHwnd := 0
PrgLAAHwnd := 0
RnPrgLnchHwnd := 0
UpdtPrgLnchHwnd := 0
BackToPrgLnchHwnd := 0
;CDS_VIDEOPARAMETERS := 0x00000020 ;https://msdn.microsoft.com/en-us/library/windows/desktop/dd145196%28v=vs.85%29.aspx?f=255&MSPPError=-2147217396

PrgVer := 0
PrgVerOld := 0
PrgNo := 12
PrgPID := 0 ; PID for test run Prgs
PrgStyle := 0 ;Storage for styles
PrgMinMax := 0 ; -1 Min, 0 in Between, 1 Max
PrgIntervalLnch := -1
PrgCanBeShortcut := 0
batchPrgNo := 0 ;actually no of Prgs configured
currBatchNo := 0 ;no of Prgs in selected preset limited by maxBatchPrgs
boundListBtchCtl := 0 ; PrgList sel or Updown toggle
btchPrgPresetSel := 0 ;What preset is currently selected- 0 for none
PrgBatchIniStartup := 0 ;Batch Preset read from Startup
maxBatchPrgs := 6
batchActive := 0 ; Batch is Active for current Preset
lnchPrgStat := 0 ; (PrgIndex) Run, (0) Change Res or -(PrgIndex) Cancel
lnchStat := 0 ; (-1) Test Run; (1) Batch Run; (0) BatchPrgStatus Select
listPrgVar := 0 ;copy of BatchPrgs listbox id
presetNoTest := 1 ; config screen or batch screen?
prgSwitchIndex := 0 ; saves index of Prg switched to when active
waitBreak := 0 ; Switch to break the Prg watch
PrgPos := [0, 0, 0, 0]
PrgLnchHide := [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
PrgChgResonSwitch := [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
PrgRnPriority := [-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1] ;indetermined values are "normal"
PrgCmdLine := ["", "", "", "", "", "", "", "", "", "", "", ""]
PrgMonToRn := [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
PrgBordless := [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
PrgListIndex := [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
PrgListIndexTmp := [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
PrgBdyBtchTog := [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
PrgBdyBtchTogTmp := [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
PresetNames := ["", "", "", "", "", ""]
ProgPIDMast := [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
Loop, %maxBatchPrgs%
{
PrgBatchIni%A_Index% := [0, 0, 0, 0, 0, 0]
PrgListPID%A_Index% := [0, 0, 0, 0, 0, 0] ; NS = not started
}
disclaimtxt := "Welcome to the PrgLnch Disclaimer Dialog! `n`nTHE SOFTWARE IS PROVIDED ""AS IS"", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, TITLE AND NON-INFRINGEMENT. IN NO EVENT SHALL THE COPYRIGHT HOLDERS OR ANYONE DISTRIBUTING THE SOFTWARE BE LIABLE FOR ANY DAMAGES OR OTHER LIABILITY, WHETHER IN CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE... `n`nBy clicking ""Yes"" you accept the above terms of usage."
disclaimer := 0

Test := 0 ;Resmode read data
Fmode := 0
Dynamic := 0
Tmp := 1

PrgTermExit := 0
Rego := 0
PrgChoiceNames := ["", "", "", "", "", "", "", "", "", "", "", ""]
PrgChoicePaths := ["", "", "", "", "", "", "", "", "", "", "", ""]
PrgLnkInf := [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
PrgUrl := ["", "", "", "", "", "", "", "", "", "", "", ""]
strPrgChoice := "|None|"
defPrgStrng := "None"
selPrgChoice := 1
selPrgChoiceTimer := 0
PrgChoiceClicked := 1
txtPrgChoice := ""
txtCmd := 0


; General temp variables
foundPos := 0
temp := 0
fTemp := 0
;Prevents unecessary extra reads when this counter exceeds 4
inputOnceOnly := 0

PrgLnchIni := SubStr( A_ScriptName, 1, -3 ) . "ini"

dispMonNames := [0, 0, 0, 0, 0, 0, 0, 0, 0]
ResArray := [[],[],[]]
iDevNumArray := [0, 0, 0, 0, 0, 0, 0, 0, 0]
scrWidthDefArr := [0, 0, 0, 0, 0, 0, 0, 0, 0]
scrHeightDefArr := [0, 0, 0, 0, 0, 0, 0, 0, 0]
scrFreqDefArr := [0, 0, 0, 0, 0, 0, 0, 0, 0]
scrWidthArr := [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
scrHeightArr := [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
scrFreqArr := [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
dispMonNamesNo := 9 ;No more than 9 displays!?
PrgLnchMon := 0 ; Device PrgLnch is run from
targMonitorNum := 1
ResIndexList := ""
scrWidth := 0
scrHeight := 0
scrFreq := 0
scrWidthDef := 0
scrHeightDef := 0
scrFreqDef := 0
x := 0
y := 0
w := 0
h := 0
dx := 0
dy := 0



temp := PrgLnch.Title
DetectHiddenWindows, On
WinGet, foundpos, List, % temp

if (foundpos > 1 && !%0%) ; No command line parms! See ComboBugFix
{
	while foundpos%A_Index%
	{
	temp := foundpos%A_Index%
	WinGetClass, temp, % "ahk_id" temp

	if (InStr(temp, PrgLnch.Class()) || InStr(PrgLnch.Class(), temp))
	fTemp += 1
	if (ftemp > 1)
	{
	MsgBox, 8192, PrgLnch Running!,Already Running: only one instance in memory!
	GoSub PrgLnchGuiClose
	}

	} 
}

IniProc(scrWidth, scrHeight, scrFreq)
sleep 120




IniRead, disclaimer, %A_ScriptDir%`\%PrgLnchIni%, General, Disclaimer
	if (!disclaimer || disclaimer = "Error")
	{
	msgbox, 8196 ,Disclaimer, % disclaimtxt
		IfMsgBox, Yes
		{
		IniWrite, 1, %A_ScriptDir%`\%PrgLnchIni%, General, Disclaimer
		FileInstall PrgLnch.chm, PrgLnch.chm
		sleep, 300
		temp := A_ScriptDir . "\" . PrgLnchIni
		IniSpaceCleaner(temp, 1) ;  fix old version
		sleep, 120
		SetTimer, RnChmWelcome, 3000
		}
		else
		{
		FileDelete %PrgLnchIni%	
		GoSub PrgLnchGuiClose
		}
	}
	else
	{
	ifnotexist PrgLnch.chm
	FileInstall PrgLnch.chm, PrgLnch.chm
	sleep, 100
		if A_Min < 22 ; Do this approx every 3 runs
		{
		temp := A_ScriptDir . "\" . PrgLnchIni
		IniSpaceCleaner(temp)
		}
	}



; Init the lnk info list
loop % PrgNo
{
	fTemp := PrgChoicePaths[A_Index]
	foundpos := IsPrgaLnk(fTemp)
	PrgLnkInf[A_Index] := foundpos
}


Gui, PrgLnchOpt: New
Gui, PrgLnchOpt: -MaximizeBox -MinimizeBox +OwnDialogs +E%WS_EX_CONTEXTHELP%
Gui, PrgLnchOpt: Color, FFFFCC

Gui, PrgLnchOpt: Add, ComboBox, vPrgChoice gPrgChoice HWNDPrgChoiceHwnd
Gui, PrgLnchOpt: Add, Button, gMakeShortcut vMkShortcut HWNDMkShortcutHwnd, &Just Change Res.
Gui, PrgLnchOpt: Add, Edit, vCmdLinPrm gCmdLinPrmSub HWNDcmdLinHwnd
Gui, PrgLnchOpt: Add, Text, vMonitors HWNDMonitorsHwnd wp ; wp is width of previous control
Gui, PrgLnchOpt: Add, DropDownList, AltSubmit viDevNum HWNDDevNumHwnd giDevNo
Gui, PrgLnchOpt: Add, Checkbox, ys vDefaultPrg gCheckDefaultPrg HWNDDefaultPrgHwnd, Show at Startup ;Tip: g-labels can be used for more than one control
Gui, PrgLnchOpt: Add, text,, Res Options:  ; Save this control's position and start a new section.
Gui, PrgLnchOpt: Add, Radio, gTestMode vTest HWNDTestHwnd, TestMode
GuiControl, PrgLnchOpt: , Test, % Test
Gui, PrgLnchOpt:Add, Radio, gChangeMode vFMode HWNDFModeHwnd, Change at every mode
GuiControl, PrgLnchOpt: , FMode, % FMode
Gui, PrgLnchOpt:Add, Radio, gDynamicMode vDynamic HWNDDynamicHwnd, Dynamic (All running Apps)
GuiControl, PrgLnchOpt: , Dynamic, % Dynamic
Gui, PrgLnchOpt:Add, Radio, gTmpMode vTmp HWNDTmpHwnd, Temporary (recommended)
GuiControl, PrgLnchOpt: , Tmp, % Tmp
Gui, PrgLnchOpt: Add, Checkbox, vRego gRegoCheck HWNDRegoHwnd, Pull values from registry
; Save this control's position and start a new section.
Gui, PrgLnchOpt: Add, Text, ys, % "Default Resolution:   "
Gui, PrgLnchOpt: Add, Text, vcurrRes HWNDcurrResHwnd wp
Gui, PrgLnchOpt: Add, Checkbox, vallModes gCheckModes HWNDallModesHwnd, List all compatible


;ini section

GuiControl, PrgLnchOpt: , Rego, % Rego

;Can do the following the Control way but....
GuiControl, PrgLnchOpt:, PrgChoice, %strPrgChoice%


if (defPrgStrng = "None")
	GuiControl, PrgLnchOpt: Choose, PrgChoice, 1
else
{
	GuiControl, PrgLnchOpt:, MkShortcut, Make Shortcut
		loop % PrgNo
		{
		If (PrgChoiceNames[A_Index] = defPrgStrng)
		{
		selPrgChoice := A_Index
		GuiControl, PrgLnchOpt: , DefaultPrg, 1
		Break
		}
		}
	GuiControl, PrgLnchOpt: Choose, PrgChoice, % selPrgChoice + 1
}




;Monitors % Reslist

Gui, PrgLnchOpt: Add, ListBox, vResIndex gResListBox HWNDResIndexHwnd


;Get def. mon list...
GetDisplayData(PrgLnchMon, targMonitorNum, dispMonNamesNo, iDevNumArray, dispMonNames, scrDPI, scrWidth, scrHeight, scrInterlace, scrFreq, -3)

; Sanitize- just in case: use current monitor if invalid one saved
PrgLnchMon := GetPrgLnchMonNum(iDevNumArray, dispMonNamesNo)

loop %PrgNo% 
{
j := PrgMonToRn[A_Index]
if (j && (iDevNumArray[j] < 10) && PrgChoiceNames[A_Index])
PrgMonToRn[A_Index] := PrgLnchMon
}



if (PrgMonToRn[selPrgChoice] && !(defPrgStrng = "None"))
{
scrWidth := scrWidthArr[selPrgChoice]
scrHeight := scrHeightArr[selPrgChoice]
scrFreq := scrFreqArr[selPrgChoice]
targMonitorNum := PrgMonToRn[selPrgChoice]
GoSub iDevNo
}
else
{
GoSub CheckModes
scrWidthDef := scrWidth
scrHeightDef := scrHeight
scrFreqDef := scrFreq
}


GuiControl, PrgLnchOpt:, Monitors, % dispMonNames[targMonitorNum]
;Build monitor list
Loop, % dispMonNamesNo
{
	if iDevNumArray[A_Index] < 10 ;dec masks
	{
	GuiControl, PrgLnchOpt:, iDevNum, % SubStr(iDevNumArray[A_Index], 1, 1) " |"
	}
	else
	{
		if iDevNumArray[A_Index] > 99
		{
		GuiControl, PrgLnchOpt:, iDevNum, % SubStr(iDevNumArray[A_Index], 3, 1) " |"
		if (!selPrgChoice || defPrgStrng = "None")
		GuiControl, PrgLnchOpt: ChooseString, iDevNum, % SubStr(iDevNumArray[A_Index], 1, 1)
		}
		else
		{
		GuiControl, PrgLnchOpt:, iDevNum, % SubStr(iDevNumArray[A_Index], 2, 1) " |"
		}
	}
}


GoSub FixMonColours
Gui, PrgLnchOpt: font ;factory  defaults

Gui, PrgLnchOpt: Add, Checkbox, vChgResonSwitch gChgResonSwitchChk HWNDChgResonSwitchHwnd, Change Res on Switch
GuiControl, PrgLnchOpt: Disable, ChgResonSwitch
Gui, PrgLnchOpt: Add, Checkbox, ys vPrgLnchHd gPrgLnchHideChk HWNDPrgLnchHdHwnd, Hide PrgLnch On Run
GuiControl, PrgLnchOpt: Disable, PrgLnchHd
Gui, PrgLnchOpt: Add, Checkbox, vBordless gBordlessChk HWNDBordlessHwnd wp, Borderless
GuiControl, PrgLnchOpt: Disable, Bordless
Gui, PrgLnchOpt: Add, Checkbox, vPrgPriority gPrgPriorityChk HWNDPrgPriorityHwnd Check3 wp, Prg Priority (N-BN-H)
;check3 enables 3 values in checkbox
GuiControl, PrgLnchOpt: Enable, PrgPriority
GuiControl, PrgLnchOpt:, PrgPriority, -1
Gui, PrgLnchOpt: Add, Checkbox, vPrgCanBeShortct gPrgCanBeShortctChk HWNDPrgCanBeShortctHwnd wp, Prg Can Be a Shortcut to File
GuiControl, PrgLnchOpt: Enable, PrgCanBeShortct
GuiControl, PrgLnchOpt:, PrgCanBeShortct, % PrgCanBeShortcut
Gui, PrgLnchOpt: Add, Button, vPrgLAA gPrgLAARn HWNDPrgLAAHwnd wp, Apply LAA Flag



Gui, PrgLnchOpt: Add, Button, ys vRnPrgLnch gLnchPrgLnch HWNDRnPrgLnchHwnd wp, &Test Run Prg  ; ym topmost, xm puts it at the bottom left corner.
Gui, PrgLnchOpt: Add, Button, vUpdtPrgLnch gUpdtPrg HWNDUpdtPrgLnchHwnd wp, &Update Prg
Gui, PrgLnchOpt: Add, Edit, vUpdturlPrgLnch gUpdturlPrgLnchText HWNDUpdturlHwnd wp
Gui, PrgLnchOpt: Add, Text, vnewVerPrg HWNDnewVerPrgHwnd wp
Gui, PrgLnchOpt: Add, Button, cdefault gBackToPrgLnch HWNDBackToPrgLnchHwnd wp, &Back to PrgLnch ;cdefault colour

GuiControlGet, txtPrgChoice, PrgLnchOpt:, PrgChoice



if (ChkPrgNames(txtPrgChoice)) ;shouldn't happen on load
	GuiControl, PrgLnchOpt: Text, PrgChoice, None

if (txtPrgChoice = "None")
	{
	GuiControl, PrgLnchOpt: Enable, RnPrgLnch
	GuiControl, PrgLnchOpt:, RnPrgLnch, Change Res`.
	GuiControl, PrgLnchOpt: Disable, DefaultPrg
	GuiControl, PrgLnchOpt:, MkShortcut, Just Change Res.
	GuiControl, PrgLnchOpt: Disable, Just Change Res.
	DisableVariousResCtrls()
	}
else
	{

	GuiControl, PrgLnchOpt:, MkShortcut, Change Shortcut
	PrgURLEnable(selPrgChoice, selPrgChoiceTimer, PrgLnkInf, PrgUrl, PrgVer, PrgVerOld, UpdturlHwnd)


	PrgCmdLineEnable(selPrgChoice, PrgLnkInf, PrgCmdLine, cmdLinHwnd)
	GuiControl, PrgLnchOpt: ChooseString, iDevNum, %targMonitorNum%
	GuiControl, PrgLnchOpt: Enable, PrgLnchHd
	GuiControl, PrgLnchOpt:, PrgLnchHd, % PrgLnchHide[selPrgChoice]
	GuiControl, PrgLnchOpt: Enable, Bordless
	GuiControl, PrgLnchOpt:, Bordless, % PrgBordless[selPrgChoice]
	GuiControl, PrgLnchOpt:, PrgPriority, % PrgRnPriority[selPrgChoice]
	GuiControl, PrgLnchOpt: Enable, ChgResonSwitch
	GuiControl, PrgLnchOpt:, ChgResonSwitch, % PrgChgResonSwitch[selPrgChoice]


	GuiControl, PrgLnchOpt: Enable, PrgLAA		
	}





Gui, PrgLnchOpt: Show, Hide, PrgLnchOpt

WinMover(PrgLnchOpt.Hwnd(),"d r")   ; "dr" means "down, right"

if !FindStoredRes(PrgLnchIni, scrWidth, scrHeight, scrFreq)
GuiControl, PrgLnchOpt: ChooseString, ResIndex, %currRes%
;ChooseString may fail if frequencies differ. Meh!


IniProc(scrWidth, scrHeight, scrFreq, 100) ;initialises Prgmon in ini











































































;Frontend form
Gui, PrgLnch: New
Gui PrgLnch:Default  	;A_DefaultGui is name of default gui
Gui PrgLnch: -MaximizeBox -MinimizeBox +OwnDialogs +E%WS_EX_CONTEXTHELP%
Gui, PrgLnch: Color, FFFFCC

Gui, PrgLnch: Add, Text, vPresetLabel gPresetLabelSub HWNDPresetLabelHwnd, Batch Presets
GuiControlGet, temp, PrgLnch: Pos, %PresetLabelHwnd%
GuiControl, PrgLnch: Move, PresetLabel, % "w" tempw*1.6
Gui, PrgLnch: Add, Edit, vPresetName gPresetNameSub HWNDPresetNameHwnd
Gui, PrgLnch: Add, ListBox, vBtchPrgPreset gBtchPrgPresetSub HWNDPresetHwnd AltSubmit


Gui, PrgLnch: Add, Text, ys vbatchListPrg wp, Batch Prgs
;initialise batch
retVal := % PopBtchListBox(PrgChoiceNames, PrgNo, PrgMonToRn, PrgBdyBtchTog, PrgListIndex, batchPrgNo, 1)
temp := batchPrgNo-1
Gui, PrgLnch: Add, ListBox, vListPrg gListPrgProc HWNDBtchPrgHwnd AltSubmit
Gui, PrgLnch: Add, UpDown, vMovePrg gMovePrgProc HWNDMovePrgHwnd Range%temp%-0 ;MovePrg ZERO based: https://autohotkey.com/boards/viewtopic.php?f=5&t=26703&p=125603#p125603

Gui, PrgLnch: Add, Text, ys vstatic wp, Prg Status
Gui, PrgLnch: Add, ListBox, vbatchPrgStatus gbatchPrgStatusSub HWNDbatchPrgStatusHwnd AltSubmit
Gui, PrgLnch: Add, Checkbox, vPrgInterval gPrgIntervalChk HWNDPrgIntervalHwnd Check3 wp, Prg Lnch Interval: (Med-Short-Long)
GuiControl, PrgLnch: Enable, PrgInterval
GuiControl, PrgLnch:, PrgInterval, % PrgIntervalLnch


Gui, PrgLnch: Add, Checkbox, ys vDefPreset gDefPresetSub HWNDDefPresetHwnd, This Preset at Load
Gui, PrgLnch: Add, Checkbox, vPrgExitTerm gPrgExitTermChk HWNDPrgExitTermChkHwnd wp, Terminate Prg(s) on PrgLnch Exit
GuiControl, PrgLnch: Enable, PrgExitTerm
GuiControl, PrgLnch:, PrgExitTerm, % PrgTermExit
Gui, PrgLnch: Add, Button, cdefault vRunBatchPrg gRunBatchPrgSub HWNDRunBatchPrgHwnd wp, &Run Batch
Gui, PrgLnch: Add, Button, cdefault gGoConfig HWNDGoConfigHwnd wp, &Prg Config
Gui, PrgLnch: Add, Button, cdefault HWNDquitHwnd Wp, &Quit_PrgLnch

; init conditions
FrontendInit:
sleep 100
Thread, NoTimers

btchPrgPresetSel := PrgBatchIniStartup
currBatchNo := 0
retVal := "|"

loop, %maxBatchPrgs% ;Preset limit is also Prgs_in_preset limit! 
{
if 	PresetNames[A_Index]
retVal := retVal . PresetNames[A_Index] . "|"
else
retVal := retVal . "Preset" . A_Index . "|"
}
GuiControl, PrgLnch:, BtchPrgPreset, %retVal%

if (PrgBatchIniStartup)
{

EnableBatchCtrls(PresetNameHwnd, btchPrgPresetSel, PresetNames)

GuiControl, PrgLnch: Choose, BtchPrgPreset, % btchPrgPresetSel
GuiControl, PrgLnch:, DefPreset, 1

sleep 100

GuiControl, PrgLnch:, batchPrgStatus, % ReorgBatch(batchPrgNo, maxBatchPrgs, btchPrgPresetSel, PrgMonToRn, PrgBatchIni%btchPrgPresetSel%, currBatchNo, PrgListIndex, PrgBdyBtchTog, PrgBatchIni%PrgBatchIniStartup%)

}
else
{
;load "none"
EnableBatchCtrls(PresetNameHwnd, btchPrgPresetSel, PresetNames, 1)

}
retVal := % PopBtchListBox(PrgChoiceNames, PrgNo, PrgMonToRn, PrgBdyBtchTog, PrgListIndex, batchPrgNo)
sleep 100
GuiControl, PrgLnch:, ListPrg, % retVal
Thread, NoTimers, false




; Just Me: https://autohotkey.com/boards/viewtopic.php?t=1403
SendMessage, % LB_GETITEMHEIGHT, 0, 0, , % "ahk_id " . BtchPrgHwnd
temp := % ErrorLevel
SendMessage, % LB_GETCOUNT, 0, 0, , % "ahk_id " . BtchPrgHwnd
temp :=  (temp * (ErrorLevel + 1)) ; + 8 for the margins

if (temp > .65 * PrgLnchOpt.Height())
temp:= .65 * PrgLnchOpt.Height() 
GuiControl, PrgLnch: Move, ListPrg, h%temp%

GuiControl, PrgLnch: Move, MovePrg, h%temp%

temp:= .50 * PrgLnchOpt.Height() 
GuiControl, PrgLnch: Move, BtchPrgPreset, h%temp%
GuiControl, PrgLnch: Move, batchPrgStatus, h%temp%

GuiControlGet, batchPrgStatus, PrgLnch: Pos ;current selection

GuiControl, PrgLnch: Move, PrgInterval, % "y" 1.2 * batchPrgStatusY + batchPrgStatusH




Gui, PrgLnch: Show, Hide, PrgLnch
WinMover(PrgLnch.Hwnd(),"d r", PrgLnchOpt.Width() * 3/4, PrgLnchOpt.Height())

Gui, PrgLnch: Show

SetWinDelay, 100

OnMessage(0x112, "WM_SYSCOMMAND")
OnMessage(0x0053, "WM_Help")
;"WS_EX_CONTEXTHELP"
SplashImage, PrgLnchLoading.jpg, Hide,,,LnchSplash

Return

^!p::
CoordMode, Mouse, Screen
MouseGetPos, x, y

if WinExist("PrgLnch.ahk") or WinExist("ahk_class" . PrgLnch) or WinExist ("ahk_class AutoHotkeyGUI")
WinActivate
else
{
MsgBox, 8196, , Problem with Finding the PrgLnch Window! Quit PrgLnch?
IfMsgBox, Yes
GoSub PrgLnchGuiClose
}

IfWinExist, PrgLnch
WinMove, PrgLnch, , %x%, %y%
else
{
MsgBox, 8196, , Cannot retrieve PrgLnch! Quit PrgLnch?
IfMsgBox, Yes
GoSub PrgLnchGuiClose
}

IfWinExist, PrgLnchOpt
WinMove, PrgLnchOpt, , %x%, %y%
else
{
MsgBox, 8196, , Cannot retrieve PrgLnch! Quit PrgLnch?
IfMsgBox, Yes
GoSub PrgLnchGuiClose
}

Return


MovePrgProc:

boundListBtchCtl := % MovePrg + 1
Gui, PrgLnch: Submit, Nohide

if (IsCurrentBatchRunning(currBatchNo, PrgListPID%btchPrgPresetSel%))
Return

if (listPrgVar)
{
	Loop, % batchPrgNo
	{
		if (MovePrg + 1 = A_Index)
		{
			if !(MovePrg + 1 = listPrgVar)
			{
				if (listPrgVar < MovePrg + 1) ; down :A_Index increases(PrgListIndex[A_Index] < A_Index) ;swap with item below
				{
				if (A_Index > 1)
					{
					temp := PrgListIndex[A_Index - 1]
					PrgListIndex[A_Index - 1] := PrgListIndex[A_Index]
					PrgListIndex[A_Index] := temp
					temp := PrgBdyBtchTog[A_Index - 1]
					PrgBdyBtchTog[A_Index - 1] := PrgBdyBtchTog[A_Index]
						if (currBatchNo < maxBatchPrgs)
						{
							if !temp
							currBatchNo += 1
							temp := PrgListIndex[A_Index]
							PrgBdyBtchTog[A_Index] := MonStr(PrgMonToRn, temp)
						}
						else
						PrgBdyBtchTog[A_Index] := temp
					}
				}
				else
				; up :A_Index decreases ;swap with item above
				{
					if (A_Index < batchPrgNo)
					{
					temp := PrgListIndex[A_Index]
					PrgListIndex[A_Index] := PrgListIndex[A_Index + 1]
					PrgListIndex[A_Index + 1] := temp
					temp := PrgBdyBtchTog[A_Index + 1]
					PrgBdyBtchTog[A_Index + 1] := PrgBdyBtchTog[A_Index]
						if (currBatchNo < maxBatchPrgs)
						{
							if !temp
							currBatchNo += 1
							temp := PrgListIndex[A_Index]
							PrgBdyBtchTog[A_Index] := MonStr(PrgMonToRn, temp)
						}
						else
						PrgBdyBtchTog[A_Index] := temp

					}

				}
			listPrgVar := MovePrg + 1
			}
			else
			{
				if (A_Index = batchPrgNo) ;down: move the rest up
				{
					Loop % batchPrgNo - 1
					{
						PrgListIndexTmp[A_Index + 1] := PrgListIndex[A_Index]
						PrgBdyBtchTogTmp[A_Index + 1] := PrgBdyBtchTog[A_Index]
					}
					PrgListIndexTmp[1] := PrgListIndex[batchPrgNo]
					listPrgVar := 1
						if (currBatchNo < maxBatchPrgs) ; only set if under limit
						{
							if !(PrgBdyBtchTog[batchPrgNo])
							currBatchNo += 1
							temp := PrgListIndex[A_Index]
							PrgBdyBtchTogTmp[1] := MonStr(PrgMonToRn, temp)
						}
						else
						PrgBdyBtchTogTmp[1] := PrgBdyBtchTogTmp[batchPrgNo]
				}
				else ;up: move the rest down
				{
					Loop % batchPrgNo - 1
					{
						PrgListIndexTmp[A_Index] := PrgListIndex[A_Index + 1]
						PrgBdyBtchTogTmp[A_Index] := PrgBdyBtchTog[A_Index + 1]
					}
					PrgListIndexTmp[batchPrgNo] := PrgListIndex[1]
					listPrgVar := batchPrgNo
						if (currBatchNo < maxBatchPrgs)
						{
							if !(PrgBdyBtchTog[1])
							currBatchNo += 1
							temp := PrgListIndex[A_Index]
							PrgBdyBtchTogTmp[batchPrgNo] := MonStr(PrgMonToRn, temp)
						}
						else
						PrgBdyBtchTogTmp[batchPrgNo] := PrgBdyBtchTogTmp[1]
				}
				Loop
				{
					PrgListIndex[A_Index] := PrgListIndexTmp[A_Index]
					PrgBdyBtchTog[A_Index] := PrgBdyBtchTogTmp[A_Index]
				} Until (A_Index = batchPrgNo)
			}				
		Break
		}
	}

GuiControl, PrgLnch:, ListPrg, % PopBtchListBox(PrgChoiceNames, PrgNo, PrgMonToRn, PrgBdyBtchTog, PrgListIndex, batchPrgNo)
GuiControl, PrgLnch: Choose, ListPrg, % listPrgVar
GuiControl, PrgLnch: Show, ListPrg

}
Return

ListPrgProc:
Gui, PrgLnch: Submit, Nohide
;ToolTip
;Disable if any active
if (btchPrgPresetSel)
{
if (IsCurrentBatchRunning(currBatchNo, PrgListPID%btchPrgPresetSel%))
Return
}

if !boundListBtchCtl
	{
	GuiControl, PrgLnch:, MovePrg, % ListPrg + 1
	listPrgVar := 1
	boundListBtchCtl := 1
	;called once: MovePrg Initialised if no presets loaded!
	}

	MouseGetPos,,,,temp,3
	if (temp = BtchPrgHwnd) ;actually clicked the Listbox
	{

	ftemp := PrgListIndex[listPrg]
	if (PrgBdyBtchTog[listPrg] = MonStr(PrgMonToRn, ftemp))
	{
	PrgBdyBtchTog[listPrg] := ""
	currBatchNo -= 1
	if currBatchNo < 0
	currBatchNo := 0
	if !(currBatchNo)
	EnableBatchCtrls(PresetNameHwnd, btchPrgPresetSel, PresetNames, 1)
	}
	else
	{
		if (currBatchNo < maxBatchPrgs)
		{
		if !(currBatchNo)
		EnableBatchCtrls(PresetNameHwnd, btchPrgPresetSel, PresetNames)

		if !(PrgBdyBtchTog[listPrg])
		currBatchNo += 1
		ftemp := PrgListIndex[listPrg]
		PrgBdyBtchTog[listPrg] := MonStr(PrgMonToRn, ftemp)
		}
		else
		{
		PrgBdyBtchTog[listPrg] := "" ; In case set to "MonStr(PrgMonToRn, PrgListIndex[A_Index]) " in the updown
		;ToolTip , "Batch Prg Limit Reached."
		}
	}

	
	GuiControl, PrgLnch:, ListPrg, % PopBtchListBox(PrgChoiceNames, PrgNo, PrgMonToRn, PrgBdyBtchTog, PrgListIndex, batchPrgNo)
	GuiControl, PrgLnch: Choose, ListPrg, % ListPrg
	GuiControl, PrgLnch: Show, ListPrg
	}
;commit preset to file each click
if (btchPrgPresetSel)
{
;For some  reason, variables and arrays do not  update without the sleep!
sleep, 120
	foundpos := "|"
	Loop, % currBatchNo
	{
	foundpos .= "Unknown" . "|"
	}
	GuiControl, PrgLnch:, batchPrgStatus, %foundpos%

	Loop, % maxBatchPrgs
	{
	PrgBatchIni%btchPrgPresetSel%[A_Index] := 0
	}

	ftemp := 0
	Loop, % batchPrgNo
	{
	temp := PrgListIndex[A_Index]
	if (PrgBdyBtchTog[A_Index] = MonStr(PrgMonToRn, temp))
	{
	ftemp += 1
	PrgBatchIni%btchPrgPresetSel%[ftemp] := temp
	}
	}
	if ftemp
	{
	; Write if preset selected
	temp := ""
	Loop % maxBatchPrgs
	{
	if (A_Index > 1)
	temp := temp . ","
	ftemp := PrgBatchIni%btchPrgPresetSel%[A_Index]
	temp := temp . ftemp
	}
	IniWrite, %temp%, %A_ScriptDir%`\%PrgLnchIni%, Prgs, PrgBatchIni%btchPrgPresetSel%
	}
	else
	IniWrite, %A_Space%, %A_ScriptDir%`\%PrgLnchIni%, Prgs, PrgBatchIni%btchPrgPresetSel%
	 ; Nothing to write!

	;If PrgProperties window is showing, update it
	DetectHiddenWindows, Off
	Gui, PrgProperties: +LastFoundExist
	IfWinExist
	{
	DetectHiddenWindows, On
	PopPrgProperties(iDevNumArray, dispMonNamesNo, currBatchNo, btchPrgPresetSel, PrgBatchIni%btchPrgPresetSel%, PrgChoiceNames, PrgChoicePaths, PrgLnkInf, PrgLnchOpt.X(), PrgLnchOpt.Y(), PrgLnchOpt.Width())
	}
}


Return




BtchPrgPresetSub:
Gui, PrgLnch: Submit, Nohide
temp := 0
DetectHiddenWindows, Off

waitBreak := 1 ; breaks the timer loop

if (btchPrgPresetSel)
GuiControlGet, temp, PrgLnch:, BtchPrgPreset ;sel another preset?
else
GuiControlGet, btchPrgPresetSel, PrgLnch:, BtchPrgPreset


;Backup last good PID

PidMaster(PrgNo, currBatchNo, btchPrgPresetSel, PrgBatchIni%btchPrgPresetSel%, PrgListPID%btchPrgPresetSel%, ProgPIDMast, 1)


if (btchPrgPresetSel = temp)
{
	; cannot disable if batch active
	if (IsCurrentBatchRunning(currBatchNo, PrgListPID%btchPrgPresetSel%))
	Return

	SetTimer, WatchSwitchBack, Delete
	SetTimer, WatchSwitchOut, Delete
	Thread, NoTimers
	
	;Nothing selected so not using presets
	Gui, PrgProperties: +LastFoundExist
	IfWinExist
	Gui, PrgProperties: Destroy


	loop, % currBatchNo
	{
	PrgBdyBtchTog[A_Index] = ""
	}
	currBatchNo := 0
	;must remove ini entry
	IniWrite, %A_Space% , %A_ScriptDir%`\%PrgLnchIni%, Prgs, PrgBatchIni%btchPrgPresetSel%
	if (PrgBatchIniStartup = btchPrgPresetSel)
	IniWrite, 0, %A_ScriptDir%`\%PrgLnchIni%, Prgs, PrgBatchIniStartup
	PresetNames[btchPrgPresetSel] := ""
	btchPrgPresetSel := 0
	SendMessage, LB_SETCURSEL, -1, 0, , ahk_id %PresetHwnd% ; deselects
	GuiControl, PrgLnch:, batchPrgStatus
	EnableBatchCtrls(PresetNameHwnd, btchPrgPresetSel, PresetNames, 1)
}
else
{
	;we have just clicked a new preset after selecting another preset so set read_from_ini flag. Check for an intervening ListPrg msg!
	
	foundpos := btchPrgPresetSel ; save old preset
	if (temp)
	btchPrgPresetSel := temp
	ftemp := 0

	IniReadStart:
	IniRead, temp, %A_ScriptDir%`\%PrgLnchIni%, Prgs, PrgBatchIni%btchPrgPresetSel%
	sleep, 150
	if (temp = "ERROR")
	{
		MsgBox, 8196, , Problem reading the Ini file! Try again?
		IfMsgBox, Yes
		Goto IniReadStart
	}
	; No key and defaults to "ERROR"
	if (temp && !(temp = "ERROR"))
	{
		currBatchNo := 0
		loop, parse, temp, CSV
		{
			if (A_LoopField)
			{
			currBatchNo += 1
			ftemp := A_LoopField
			PrgBatchIni%btchPrgPresetSel%[A_Index] := ftemp
			}
			else
			PrgBatchIni%btchPrgPresetSel%[A_Index] := 0
		}
	}
	if (ftemp)
	{
	; just load new preset in:- first reset entire list as at load


	GuiControl, PrgLnch:, ListPrg, % PopBtchListBox(PrgChoiceNames, PrgNo, PrgMonToRn, PrgBdyBtchTog, PrgListIndex, batchPrgNo, 1)

	; Restore PID
	PidMaster(PrgNo, currBatchNo, btchPrgPresetSel, PrgBatchIni%btchPrgPresetSel%, PrgListPID%btchPrgPresetSel%, ProgPIDMast)

	GuiControl, PrgLnch:, batchPrgStatus, % ReorgBatch(batchPrgNo, maxBatchPrgs, btchPrgPresetSel, PrgMonToRn, PrgBatchIni%btchPrgPresetSel%, currBatchNo, PrgListIndex, PrgBdyBtchTog)


		if (btchPrgPresetSel = PrgBatchIniStartup)
		GuiControl, PrgLnch:, DefPreset, 1
		else
		GuiControl, PrgLnch:, DefPreset, 0	


	GuiControl, PrgLnch:, ListPrg, % PopBtchListBox(PrgChoiceNames, PrgNo, PrgMonToRn, PrgBdyBtchTog, PrgListIndex, batchPrgNo)
	GuiControl, PrgLnch: Show, ListPrg


	;If PrgProperties window is showing, update it
	Gui, PrgProperties: +LastFoundExist
		IfWinExist
		{
		DetectHiddenWindows, On
		PopPrgProperties(iDevNumArray, dispMonNamesNo, currBatchNo, btchPrgPresetSel, PrgBatchIni%btchPrgPresetSel%, PrgChoiceNames, PrgChoicePaths, PrgLnkInf, PrgLnchOpt.X(), PrgLnchOpt.Y(), PrgLnchOpt.Width())
		}

	}
	else ;nothing in ini to restore, so write to it!
	{
		;sanitize
		Loop, % maxBatchPrgs
		{
		PrgBatchIni%btchPrgPresetSel%[A_Index] := 0
		}

		currBatchNo := 0
		
		Loop, % batchPrgNo
		{
			temp := PrgListIndex[A_Index]
			if (PrgBdyBtchTog[A_Index] = MonStr(PrgMonToRn, temp))
			{
			currBatchNo += 1
			PrgBatchIni%btchPrgPresetSel%[currBatchNo] := PrgListIndex[A_Index]
			}
		}

		if (currBatchNo)
		{

		temp := ""
			Loop % maxBatchPrgs
			{
			if (A_Index > 1)
			temp := temp . ","
			temp := temp . PrgBatchIni%btchPrgPresetSel%[A_Index]
			}
		IniWrite, %temp%, %A_ScriptDir%`\%PrgLnchIni%, Prgs, PrgBatchIni%btchPrgPresetSel%
		; copy active Prgs over
			loop, % currBatchNo
			{
			PrgListPID%btchPrgPresetSel%[A_Index] := PrgListPID%foundpos%[A_Index]
			}
		}
		else
		{
		; Nothing Nothing
		Gui, PrgProperties: +LastFoundExist
		IfWinExist
		Gui, PrgProperties: Destroy
		DetectHiddenWindows, On
		EnableBatchCtrls(PresetNameHwnd, btchPrgPresetSel, PresetNames, 1)
		Return
		}
		
	}

EnableBatchCtrls(PresetNameHwnd, btchPrgPresetSel, PresetNames)
Thread, NoTimers, false

if (IsCurrentBatchRunning(currBatchNo, PrgListPID%btchPrgPresetSel%))
{
	batchActive := 1
	SetTimer, WatchSwitchOut, -1000
}
else
batchActive := 0

if (batchActive)
GuiControl, PrgLnch:, RunBatchPrg, &Cancel Batch
else
{
	retVal := "|"
	loop, % currBatchNo
	{
	retVal := retVal . "Not Active" . "|"
	}
GuiControl, PrgLnch:, batchPrgStatus, % retVal
GuiControl, PrgLnch:, RunBatchPrg, &Run Batch
}

}

DetectHiddenWindows, On
Return


DefPresetSub:
Gui, PrgLnch: Submit, Nohide

if (DefPreset)
PrgBatchIniStartup := btchPrgPresetSel
else
PrgBatchIniStartup := 0

IniWrite, %PrgBatchIniStartup%, %A_ScriptDir%`\%PrgLnchIni%, Prgs, PrgBatchIniStartup
Return


batchPrgStatusSub:
Gui, PrgLnch: Submit, Nohide


if (A_GuiEvent = "DoubleClick")
{

	waitBreak := 1
	Thread, NoTimers
	SetTimer, WatchSwitchBack, Delete
	SetTimer, WatchSwitchOut, Delete
	sleep, 200
	foundpos := "|"
	if !batchPrgStatus
	Return

	; check before launching not cancelling
	temp := PrgListPID%btchPrgPresetSel%[batchPrgStatus]
	if (temp = "NS" || temp = "FAILED" || temp = "ENDED" || !temp)
	{

		ftemp := ChkExistingProcess(batchPrgStatus, currBatchNo, PrgBatchIni%btchPrgPresetSel%, PrgListIndex, PrgChoicePaths, btchPrgPresetSel)

		if (ftemp)
		{
			IniRead, ftemp, %A_ScriptDir%`\%PrgLnchIni%, General, PrgAlreadyMsg
			if !ftemp
			{
			MsgBox, 8195, , Selected Prg matches a process already running with `nthe same name. Might be an issue depending on instance requisites.`n`"%ftemp%`"`n`nReply:`nYes: Continue (Warn like this next time) `nNo: Continue (This will not show again) `nCancel: Do nothing: `n
				IfMsgBox, Yes
				ftemp := 0 ; dummy condition
				else
				{
				IfMsgBox, No
				IniWrite, 1, %A_ScriptDir%`\%PrgLnchIni%, General, PrgAlreadyMsg
				else
				return
				}
			}
		}

		IfNotExist PrgLaunching.jpg
		FileInstall PrgLaunching.jpg, PrgLaunching.jpg
		sleep 200
	
	
	if !(temp)
	{
	; Initialise all to batch
		loop, % currBatchNo
		{
		if !(PrgListPID%btchPrgPresetSel%[A_Index])
		PrgListPID%btchPrgPresetSel%[A_Index] := "NS"
		}
	}
	
	;Hide the quit and config buttons!
	GuiControl, PrgLnch: Hide, ListPrg
	GuiControl, PrgLnch: Hide, PresetName
	GuiControl, PrgLnch: Hide, BtchPrgPreset
	GuiControl, PrgLnch: Hide, RunBatchPrg
	GuiControl, PrgLnch: Hide, % quitHwnd
	GuiControl, PrgLnch: Hide, % GoConfigHwnd
	lnchPrgStat := PrgBatchIni%btchPrgPresetSel%[batchPrgStatus]
		temp := PrgChoicePaths[lnchPrgStat]
		if !(PrgLnchHide[lnchPrgStat])
		SplashImage, PrgLaunching.jpg, A B,,,LnchSplash
	sleep, % (!PrgIntervalLnch)? 2000: (PrgIntervalLnch = -1)? 4000: 6000

	scrWidth := scrWidthArr[lnchPrgStat]
	scrHeight := scrHeightArr[lnchPrgStat]
	scrFreq := scrFreqArr[lnchPrgStat]
	targMonitorNum := PrgMonToRn[lnchPrgStat]
	}		
	else
	{
	lnchPrgStat := -PrgBatchIni%btchPrgPresetSel%[batchPrgStatus]
	temp := PrgChoicePaths[-lnchPrgStat]
	scrWidth := scrWidthArr[-lnchPrgStat]
	scrHeight := scrHeightArr[-lnchPrgStat]
	scrFreq := scrFreqArr[-lnchPrgStat]
	targMonitorNum := PrgMonToRn[-lnchPrgStat]
	}

	lnchStat := 0


	retVal := LnchPrgOff(PrgLnchIni, batchPrgStatus, lnchStat, temp, currBatchno, lnchPrgStat, PrgCmdLine, iDevNumArray, dispMonNamesNo, WindowStyle, PrgBordless, PrgRnPriority, scrWidth, scrHeight, scrFreq, scrWidthDef, scrHeightDef, scrFreqDef, targMonitorNum, PrgPID, PrgListPID%btchPrgPresetSel%, PrgPos, PrgMinMax, PrgStyle, x, y, w, h, dx, dy, Fmode)


	loop, % currBatchNo
	{
	ftemp := PrgListPID%btchPrgPresetSel%[A_Index]
		if (A_Index = batchPrgStatus)
		{
		SplashImage, PrgLaunching.jpg, Hide,,,LnchSplash
		GuiControl, PrgLnch: Show, ListPrg
		GuiControl, PrgLnch: Show, PresetName
		GuiControl, PrgLnch: Show, BtchPrgPreset
		GuiControl, PrgLnch: Show, RunBatchPrg
		GuiControl, PrgLnch: Show, % quitHwnd
		GuiControl, PrgLnch: Show, % GoConfigHwnd

		if (retval) ;Lnch fail
		{
			if (lnchPrgStat > 0)
			{
			foundpos .= "Failed" . "|"
			MsgBox, 8192, , % retVal
			}
		}
		else
		{
			SetResDefaults(targMonitorNum, currRes, Dynamic, FMode, scrWidth, scrHeight, scrFreq, scrWidthDef, scrHeightDef, scrFreqDef, scrWidthDefArr, scrHeightDefArr, scrFreqDefArr)
			if (lnchPrgStat > 0)
			{
					if (PrgLnchHide[lnchPrgStat])
					Gui, PrgLnch: Show, Hide, PrgLnch
					else
					Gui, PrgLnch: Show

				foundpos .= "Active" . "|"
			}
			else
			{
			; ASSUME it's cancelled
			if (lnchPrgStat < 0)
			foundpos .= "Not Active" . "|"
			}
		}
		; Update Master
			if lnchPrgStat > 0
			{
				if (retVal)
				ProgPIDMast[lnchPrgStat] := 0
				else
				ProgPIDMast[lnchPrgStat] := ftemp
			}
			else
			ProgPIDMast[-lnchPrgStat] := ftemp
		}
		else
		{
			if (ftemp = "NS" || ftemp = "FAILED" || ftemp = "TERM" || ftemp = "ENDED")
			foundpos .= "Not Active" . "|"	
			else
			foundpos .= "Active" . "|"
		}
	}

GuiControl, PrgLnch:, batchPrgStatus, %foundpos%

;Fix buttons and timer
Thread, NoTimers, false

	if (IsCurrentBatchRunning(currBatchNo, PrgListPID%btchPrgPresetSel%))
	batchActive := 1
	else
	batchActive := 0

	if (batchActive)
	{
	GuiControl, PrgLnch:, RunBatchPrg, &Cancel Batch
	waitBreak := 0
	SetTimer, WatchSwitchOut, -1000
	}
	else
		if (PrgPID)
		{
		waitBreak := 0
		SetTimer, WatchSwitchOut, -1000
		}
	GuiControl, PrgLnch:, RunBatchPrg, &Run Batch
	}

Return

PresetNameSub:
GuiControlGet, temp, PrgLnch: FocusV
if (temp = "PresetName")
{
Gui, PrgLnch: Submit, Nohide

GuiControlGet, ftemp, PrgLnch:, PresetName
sleep, 60
if (ftemp)
{
	if (strlen(ftemp) > 3000) ;length: 6 X 30000 < 20000 being a reasonable limit
	{
	ftemp := SubStr(PresetName, 1, 3000)
	GuiControl, PrgLnch:, PresetName, %ftemp%
	}
PresetNames[btchPrgPresetSel] := ftemp

}
else
PresetNames[btchPrgPresetSel] := ""
sleep, 60

ftemp := ""
Loop, % maxbatchPrgs
{
	if (A_Index = 1)
	{
	ftemp .= PresetNames[1]
	temp := ftemp
	if temp
	temp := "|" . ftemp . "|"
	else
	temp := "|Preset1|"
	}
	else
	{
	ftemp .= "," . PresetNames[A_Index]
		if 	(PresetNames[A_Index])
		temp := temp . PresetNames[A_Index] . "|"
		else
		temp := temp . "Preset" . A_Index . "|"
	}
}
IniWrite, %ftemp%, %A_ScriptDir%`\%PrgLnchIni%, Prgs, PresetNames
GuiControl, PrgLnch:, BtchPrgPreset, %temp%
Gui, PrgLnch: Submit, Nohide

}
Return

RunBatchPrgSub:

if btchPrgPresetSel
GoSub LnchPrgLnch

Return

GoConfig:
presetNoTest := 0

PidMaster(PrgNo, currBatchNo, btchPrgPresetSel, PrgBatchIni%btchPrgPresetSel%, PrgListPID%btchPrgPresetSel%, ProgPIDMast, 1)

if (PrgPID)
{
	Process, Exist, % PrgPID
	if !(ErrorLevel)
	{
	PrgPID := 0
	HideShowTestRunCtrls(1)
	GuiControl, PrgLnchOpt:, RnPrgLnch, &Test Run Prg
	}
}

btchPrgPresetSel := 0
currBatchno := 0
Gui, PrgLnchOpt: Show
sleep, 100
Gui, PrgLnch: Show, Hide, PrgLnch
Return


PrgExitTermChk:
Gui, PrgLnch: Submit, Nohide
PrgTermExit := PrgExitTerm
if (PrgTermExit)
IniWrite, %PrgTermExit%, %A_ScriptDir%`\%PrgLnchIni%, Prgs, PrgTermExit
else
IniWrite, %A_Space%, %A_ScriptDir%`\%PrgLnchIni%, Prgs, PrgTermExit
Return

PrgIntervalChk:
Gui, PrgLnch: Submit, Nohide
PrgIntervalLnch := PrgInterval
if (PrgIntervalLnch)
IniWrite, %PrgIntervalLnch%, %A_ScriptDir%`\%PrgLnchIni%, Prgs, PrgInterval
else
IniWrite, %A_Space%, %A_ScriptDir%`\%PrgLnchIni%, Prgs, PrgInterval
Return

PresetLabelSub:
if (btchPrgPresetSel && currBatchNo)
PopPrgProperties(iDevNumArray, dispMonNamesNo, currBatchNo, btchPrgPresetSel, PrgBatchIni%btchPrgPresetSel%, PrgChoiceNames, PrgChoicePaths, PrgLnkInf, PrgLnchOpt.X(), PrgLnchOpt.Y(), PrgLnchOpt.Width())
Return


































;More Frontend functions
IsCurrentBatchRunning(currBatchNo, PrgListPIDbtchPrgPresetSel)
{
ftemp := 0
; return 1 if any running
	Loop, % currBatchNo
	{
		ftemp := PrgListPIDbtchPrgPresetSel[A_Index]
		if !(ftemp = "NS" || ftemp = "FAILED" || ftemp = "TERM" || ftemp = "ENDED" || !ftemp)
		return 1
	}

Return 0
}
ReorgBatch(batchPrgNo, maxBatchPrgs, btchPrgPresetSel, PrgMonToRn, PrgBatchInibtchPrgPresetSel, ByRef currBatchNo, ByRef PrgListIndex, ByRef PrgBdyBtchTog, ByRef PrgBatchIniStartup := 0)
{
;confirm new items and merge, swapping entries
temp := 0, ftemp := 0, foundpos := 0, x := 0, retVal := "|"
currBatchNo := 0

	loop, % maxBatchPrgs
	{
		if (PrgBatchIniStartup)
		temp := PrgBatchIniStartup[A_Index]
		else
		temp := PrgBatchInibtchPrgPresetSel[A_Index]
		if (temp)
		{
		loop, % batchPrgNo
		{
			if (temp = PrgListIndex[A_Index])
			{
			currBatchNo += 1
			ftemp := PrgListIndex[A_Index]
			PrgBdyBtchTog[A_Index] := MonStr(PrgMonToRn, ftemp)
			break
			}
		}
	}
	}

ftemp := 0

Loop, % currBatchNo
{
	ftemp += 1 ;ftemp is saved index: Get swap index
	x += 1
	

	Loop, % BatchPrgno
	{
		if (PrgListIndex[A_Index] = PrgBatchInibtchPrgPresetSel[x])
		{
		foundpos := A_Index
		Break
		}
	}

	if (foundpos > ftemp)
	{
	temp := PrgListIndex[foundpos]
	PrgListIndex[foundpos] := PrgListIndex[ftemp]
	PrgListIndex[ftemp] := temp
	temp := PrgBdyBtchTog[foundpos]
	PrgBdyBtchTog[foundpos] := PrgBdyBtchTog[ftemp]
	PrgBdyBtchTog[ftemp] := temp
	}

	;init Status List
	retVal := retVal . "Unknown" . "|"

}
return retval
}
EnableBatchCtrls(PresetNameHwnd, btchPrgPresetSel, PresetNames, disableThem := 0)
{
if (disableThem)
	{
	GuiControl, PrgLnch: Disable, RunBatchPrg
	GuiControl, PrgLnch: Disable, DefPreset
	GuiControl, PrgLnch:, DefPreset, 0
	GuiControl, PrgLnch: Disable, PresetName
	Gui, PrgLnch: Font, cA96915
	GuiControl, PrgLnch: Font, PresetLabel
	GuiControl, PrgLnch:, PresetLabel, Batch Presets
	SetEditCueBanner(PresetNameHwnd, "Preset Name")
	}
else
	{
	if (btchPrgPresetSel)
	{
	GuiControl, PrgLnch: Enable, RunBatchPrg
	GuiControl, PrgLnch:, RunBatchPrg, &Run Batch
	GuiControl, PrgLnch: Enable, DefPreset
	GuiControl, PrgLnch: Enable, PresetName
	Gui, PrgLnch: Font, cTeal Bold, Verdana
	GuiControl, PrgLnch:, PresetLabel, Preset Selected
	GuiControl, PrgLnch: Font, PresetLabel
		if (PresetNames[btchPrgPresetSel])
		GuiControl, PrgLnch:, PresetName, % PresetNames[btchPrgPresetSel]
		else
		{
		GuiControl, PrgLnch:, PresetName, 
		sleep, 120
		SetEditCueBanner(PresetNameHwnd, "Preset Name")
		}
	}
	}
Gui, PrgLnch: Font
}

PopBtchListBox(PrgChoiceNames, PrgNo, PrgMonToRn, ByRef PrgBdyBtchTog, ByRef PrgListIndex, ByRef batchPrgNo, AtLoad := 0)
{
temp := 0, ftemp := 0, retVal := "|" ;vital, or listBox won't refresh


if (AtLoad)
{
	batchPrgNo := 0
	Loop, % PrgNo
	{
	temp := PrgChoiceNames[A_Index]
	if (temp)
		{
		batchPrgNo += 1
		retVal := retVal . temp . "|"
		PrgListIndex[batchPrgNo] := A_Index
		PrgBdyBtchTog[batchPrgNo] := "" ;sanitize as well!
		}
	}

	if !(batchPrgNo)
	retVal := retVal . "No Prgs Configured |"
}
else
{
Loop, % PrgNo
{

}
	Loop, % batchPrgNo
		{
		temp := PrgListIndex[A_Index]
		ftemp := MonStr(PrgMonToRn, temp)
		if (PrgBdyBtchTog[A_Index] = ftemp)
		retVal := retVal . ftemp . A_Space . PrgChoiceNames[temp] . "|"
		else
		retVal := retVal . PrgChoiceNames[temp] . "|"
		}
	}
return retVal
}
MonStr(PrgMonToRn, selPrgChoice)
; Rather than worry about multi-select listboxes, we have this to show selection ... - and monitor number!
{
Return "*" . PrgMonToRn[selPrgChoice] . "*"
}

MsgOnceTerminate(PrgLnchIni, ftemp)
{
retVal := 0, TermPrgMsgOnce := 0
IniRead, TermPrgMsgOnce, %A_ScriptDir%`\%PrgLnchIni%, General, TermPrgMsg
if !(TermPrgMsgOnce)
	{
	MsgBox, 8195, , A Prg or Batched Prg is still running! It can be terminated `nat exit by switching on "Terminate Prg(s) on PrgLnch Exit". `n `"%ftemp%`"`n`nReply:`nYes: Continue (Warn like this next time)`nNo: Continue (This will not show again) `nCancel: Do nothing: `n
	IfMsgBox, Yes
	retVal := 0
	else
	{
	IfMsgBox, No
	{
	TermPrgMsgOnce := 1
	IniWrite, %TermPrgMsgOnce%, %A_ScriptDir%`\%PrgLnchIni%, General, TermPrgMsg
	}
	else
	retVal := 1
	}
	}
Return retVal
}

PidMaster(PrgNo, currBatchNo, btchPrgPresetSel, PrgBatchInibtchPrgPresetSel, ByRef PrgListPIDbtchPrgPresetSel, ByRef ProgPIDMast, ToPid := 0)
{
	temp := 0
	if (ToPid)
	{
		;Backup current last selected
		loop, % currBatchNo
		{
		temp := PrgBatchInibtchPrgPresetSel[A_Index]
			if (temp)
			{
				if !(temp = "NS" || temp = "FAILED" || temp = "TERM" || temp = "ENDED" || !temp)
				ProgPIDMast[temp] := PrgListPIDbtchPrgPresetSel[A_Index]
			}
		}

	 ; sanitize master last
	loop, % PrgNo
	{
		temp := ProgPIDMast[A_Index]
		if (temp)
		{
		ifWinNotExist, ahk_pid%temp%
		ProgPIDMast[A_Index] := 0
		}
	}


	}
	else
	{

	 ; sanitize master first
	loop, % PrgNo
	{
		temp := ProgPIDMast[A_Index]
		if (temp)
		{
		ifWinNotExist, ahk_pid%temp%
		ProgPIDMast[A_Index] := 0
		}
	}

	loop, % currBatchNo
	{
	temp := PrgBatchInibtchPrgPresetSel[A_Index]
		if (temp)
		PrgListPIDbtchPrgPresetSel[A_Index] := ProgPIDMast[temp]
	}
	}

}



PrgLnchButtonQuit_PrgLnch:
PrgLnchGuiClose:
PrgLnchGuiEscape:


if (PrgTermExit)
{ ;cancel Prgs

	loop, % PrgNo
		{ 
		temp := ProgPIDMast[A_Index]
		if (temp)
		WinClose, ahk_pid%temp%
		sleep, 200
		if (temp)
		KillPrg(temp)
		}
	if (PrgPID)
	{
	WinClose, ahk_pid%PrgPID%
	sleep, 200
	if (PrgPID)
	KillPrg(PrgPID)
	}
}
else
{
	if (presetNoTest)
	{
	ftemp := ""
	temp := ""
	loop, % PrgNo
	{
		foundpos := ProgPIDMast[A_Index]
		if (foundpos)
		{
			Process, Exist, % foundpos
			if (ErrorLevel)
			{
			retVal := PrgChoicePaths[A_Index]

			if (retVal := GetProcFromPath(retVal))
			{
			if (temp)
			ftemp .= temp . retVal
			else
			{
			temp := ", "
			ftemp := retVal
			}
			}
			}
		}
	}
		if (ftemp)
		{
			if (MsgOnceTerminate(PrgLnchIni, ftemp))
			Return
		}
	}

	if (PrgPID)
	{
		Process, Exist, %PrgPID%
		if (ErrorLevel)
			{
			retval := "`[Test Run`]"
			retVal .= PrgChoicePaths[selPrgChoice]

				if (retVal := GetProcFromPath(retVal))
				{
				if (MsgOnceTerminate(PrgLnchIni, retVal))
				Return
				}
			}
	}

}


SetTimer, NewThreadforDownload, Delete ;Cleanup
Gui, PrgLnchOpt:Submit  ; Save each control's contents to its associated variable.
WorkingDirectory(0, A_ScriptDir)
ifexist, PrgLnchLoading.jpg ; Is cleaning up after each run such a big drama these days?
FileDelete, PrgLnchLoading.jpg
ifexist, PrgLaunching.jpg
FileDelete, PrgLaunching.jpg
ifexist, PrgLnchProperties.jpg
FileDelete, PrgLnchProperties.jpg
ifexist, PrgLnch.chm
FileDelete, PrgLnch.chm
ifexist, taskkillPrg.bat
FileDelete, taskkillPrg.bat
ExitApp

WM_HELP(wp_notused, lParam, _msg, _hwnd)
{
local retVal := 0 ;using local this is now a global function



(A_PtrSize = 8)? 64bit := 1 : 64bit := 0


Size         := NumGet(lParam +  0, "uint")
ContextType  := NumGet(lParam +  4, "int")
CtrlId       := Numget(lParam +  8, "int")
ItemHandle   := Numget(lParam + 12 + 64bit * 4, "ptr")
ContextId    := NumGet(lParam + 16 + 64bit * 8, "uint")
MousePosX    := NumGet(lParam + 20 + 64bit * 8, "int")
MousePosY    := NumGet(lParam + 24 + 64bit * 8, "int")

;This key must be set to 1!
;HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced >> EnableBalloonTips

if (ItemHandle = PresetLabelHwnd)
{
if (btchPrgPresetSel && currBatchNo)
PopPrgProperties(iDevNumArray, dispMonNamesNo, currBatchNo, btchPrgPresetSel, PrgBatchIni%btchPrgPresetSel%, PrgChoiceNames, PrgChoicePaths, PrgLnkInf, PrgLnchOpt.X(), PrgLnchOpt.Y(), PrgLnchOpt.Width())
else
retVal := RunChm("PrgLnch Batch`\PrgLnch Batch", "BatchPresetsLabel")
}
else
if (ItemHandle = MonitorsHwnd)
retVal := RunChm("PrgLnch Config`\PrgLnch Config", "MonitorName")
else
if (ItemHandle = currResHwnd)
retVal := RunChm("PrgLnch Config`\PrgLnch Config", "DefaultResolution")
else
if (ItemHandle = newVerPrgHwnd)
retVal := RunChm("PrgLnch Config`\PrgLnch Config", "PrgUpdateStatus")
else
if (ItemHandle = MovePrgHwnd)
retVal := RunChm("PrgLnch Batch`\PrgLnch Batch", "BatchPrgs")
else
if (ItemHandle = PresetHwnd)
retVal := RunChm("PrgLnch Batch`\PrgLnch Batch", "BatchPresets")
else
if (ItemHandle = BtchPrgHwnd)
retVal := RunChm("PrgLnch Batch`\PrgLnch Batch", "BatchPrgs")
else
if (ItemHandle = batchPrgStatusHwnd)
retVal := RunChm("PrgLnch Batch`\PrgLnch Batch", "PrgStatus")
else
if (ItemHandle = PrgChoiceHwnd)
retVal := RunChm("PrgLnch Config`\PrgLnch Config", "ShortcutSlots")
else
if (ItemHandle = DevNumHwnd)
retVal := RunChm("PrgLnch Config`\PrgLnch Config", "MonitorList")
else
if (ItemHandle = ResIndexHwnd)
retVal := RunChm("PrgLnch Config`\PrgLnch Config", "ResolutionModes")
else
if (ItemHandle = cmdLinHwnd)
retVal := RunChm("PrgLnch Config`\PrgLnch Config", "CmdLineExtras")
else
if (ItemHandle = PresetNameHwnd)
retVal := RunChm("PrgLnch Batch`\PrgLnch Batch", "BatchPresetName")
else
if (ItemHandle = UpdturlHwnd)
retVal := RunChm("PrgLnch Config`\PrgLnch Config", "UrlName")
else
if (ItemHandle = PrgIntervalHwnd)
retVal := RunChm("PrgLnch Batch`\PrgLnch Batch", "PrgLnchInterval")
else
if (ItemHandle = DefPresetHwnd)
retVal := RunChm("PrgLnch Batch`\PrgLnch Batch", "ThisPresetatLoad")
else
if (ItemHandle = PrgExitTermChkHwnd)
retVal := RunChm("PrgLnch Batch`\PrgLnch Batch", "TerminatePrgs")
else
if (ItemHandle = DefaultPrgHwnd)
retVal := RunChm("PrgLnch Config`\PrgLnch Config", "ShowAtStartup")
else
if (ItemHandle = RegoHwnd)
retVal := RunChm("PrgLnch Config`\PrgLnch Config", "PullValuesFromRegistry")
else
if (ItemHandle = allModesHwnd)
retVal := RunChm("PrgLnch Config`\PrgLnch Config", "ListAllCompatible")
else
if (ItemHandle = ChgResonSwitchHwnd)
retVal := RunChm("PrgLnch Config`\PrgLnch Config", "ChgResonSwitch")
else
if (ItemHandle = PrgLnchHdHwnd)
retVal := RunChm("PrgLnch Config`\PrgLnch Config", "HidePrgLnchonRun")
else
if (ItemHandle = BordlessHwnd)
retVal := RunChm("PrgLnch Config`\PrgLnch Config", "Borderless")
else
if (ItemHandle = PrgPriorityHwnd)
retVal := RunChm("PrgLnch Config`\PrgLnch Config", "Priority")
else
if (ItemHandle = PrgCanBeShortctHwnd)
retVal := RunChm("PrgLnch Config`\PrgLnch Config", "PrgCanBeShortcutToFile")
else
if (ItemHandle = TestHwnd)
retVal := RunChm("PrgLnch Config`\PrgLnch Config", "TestMode")
else
if (ItemHandle = FModeHwnd)
retVal := RunChm("PrgLnch Config`\PrgLnch Config", "ChangeAtEveryMode")
else
if (ItemHandle = DynamicHwnd)
retVal := RunChm("PrgLnch Config`\PrgLnch Config", "Dynamic")
else
if (ItemHandle = TmpHwnd)
retVal := RunChm("PrgLnch Config`\PrgLnch Config", "Temporary")
else
if (ItemHandle = RunBatchPrgHwnd)
retVal := RunChm("PrgLnch Batch`\PrgLnch Batch", "RunBatch")
else
if (ItemHandle = GoConfigHwnd)
retVal := RunChm("PrgLnch Batch`\PrgLnch Batch", "PrgConfig")
else
if (ItemHandle = quitHwnd)
retVal := RunChm("PrgLnch Batch`\PrgLnch Batch", "QuitPrgLnch")
else
if (ItemHandle = MkShortcutHwnd)
retVal := RunChm("PrgLnch Config`\PrgLnch Config", "ModifyShortcut")
else
if (ItemHandle = PrgLAAHwnd)
retVal := RunChm("PrgLnch Config`\PrgLnch Config", "ApplyLAAFlag")
else
if (ItemHandle = RnPrgLnchHwnd)
retVal := RunChm("PrgLnch Config`\PrgLnch Config", "TestRunPrg")
else
if (ItemHandle = UpdtPrgLnchHwnd)
retVal := RunChm("PrgLnch Config`\PrgLnch Config", "UpdatePrg")
else
if (ItemHandle = BackToPrgLnchHwnd)
retVal := RunChm("PrgLnch Config`\PrgLnch Config", "BackToPrglnch")
else
{
retVal := RunChm()
}

if (retVal) ; error
{
if retVal < 0
MsgBox, 8192, , Could not find the Help file. Has it or the script been moved?
else
MsgBox, 8192, , There is a problem with the help file. Code: %retVal%.
}


}
WM_SYSCOMMAND(wParam)
{
temp := 0
    if (A_Gui && wParam = 0xF060) ; SC_CLOSE Thanks Lex
    {
		WinGet, temp, , A
		if (temp = PrgLnchOpt.Hwnd() || temp = PrgLnch.Hwnd())
		return 0
		else
		Gui, PrgProperties: Destroy
    }
}
RunChm(chmTopic := 0, Anchor := "")
{
x := 0, y := 0, w := 0, temp := 0, htmlHelp := "C:\Windows\hh.exe ms-its"

ifnotexist, %A_ScriptDir%\PrgLnch.chm
return -1

WinGetPos, x, y, w, , A

if chmTopic
run %htmlHelp%:%A_ScriptDir%\PrgLnch.chm::/%chmTopic%.htm#%Anchor%,, UseErrorLevel
else
run %htmlHelp%:%A_ScriptDir%\PrgLnch.chm::/About%A_Space%PrgLnch.htm,, UseErrorLevel
sleep, 120


if !(A_LastError) ; uses last found window
{
if WinExist("PrgLnch_Help")
	{
	;if  not maximised
	WinGet, temp, MinMax
	;Tablet mode perhaps? https://autohotkey.com/boards/viewtopic.php?f=6&t=15619
	;We are launching as "normal" but just in case this is overidden by user modifying shortcut properties. (probably not)
	if !(temp)
	{
	WinRestore
	sleep, 120
	}
	WinGetPos, , , , temp
		if (y > temp)
		WinMove, , , x, % y - temp, w
		else
		WinMove, , , x, % temp - y, w
	}
}
return A_LastError 
}
RnChmWelcome:
if (WinActive("A") = PrgLnch.Hwnd() || WinActive("A") = PrgLnchOpt.Hwnd())
{
RunChm("Welcome")
SetTimer, RnChmWelcome, Delete
}
Return








































BackToPrgLnch:
Tooltip
UDM_SETRANGE := 0X0465

SplashImage, PrgLnchLoading.jpg, A B,,, LnchSplash
WinGetPos, , , w, h, LnchSplash

WinMove, LnchSplash, , % PrgLnchOpt.X() + (PrgLnchOpt.Width() - w)/2, % PrgLnchOpt.Y() + (PrgLnchOpt.Height() - h)

retVal := % PopBtchListBox(PrgChoiceNames, PrgNo, PrgBdyBtchTog, PrgListIndex, batchPrgNo, 1)
GuiControl, PrgLnch:, ListPrg, % retval
;fix the updown
temp := batchPrgNo-1
ftemp := 0
ftemp := MakeLong(ftemp, temp)
SendMessage, %UDM_SETRANGE%, , %ftemp%, , ahk_id %MovePrgHwnd%

Gosub FrontendInit
presetNoTest := 1

PidMaster(PrgNo, currBatchNo, btchPrgPresetSel, PrgBatchIni%btchPrgPresetSel%, PrgListPID%btchPrgPresetSel%, ProgPIDMast)


if (currBatchNo) ; defpreset set
{
	if (IsCurrentBatchRunning(currBatchNo, PrgListPID%btchPrgPresetSel%))
	{
	SetTimer, WatchSwitchOut, -1000
	GuiControl, PrgLnch:, RunBatchPrg, &Cancel Batch
	}
	else
	{
			retVal := "|"
			loop, % currBatchNo
			{
			retVal := retVal . "Not Active" . "|"
			}
		GuiControl, PrgLnch:, batchPrgStatus, % retVal
		GuiControl, PrgLnch:, RunBatchPrg, &Run Batch
	}
}
else
{
	loop, % PrgNo
	{
		if (ProgPIDMast[A_Index])
		{
		SetTimer, WatchSwitchOut, 1000
		Break
		}
	}
	
}

Gui, PrgLnchOpt: Show, Hide, PrgLnchOpt
SplashImage, PrgLnchLoading.jpg, Hide,,,LnchSplash
Return

CheckVerPrg:
if !(selPrgChoiceTimer = selPrgChoice)
Return ; have clicked on!
if (PrgVerOld=PrgVer)
GuiControl, PrgLnchOpt:, newVerPrg, % "  Prg is up to date"
else
GuiControl, PrgLnchOpt:, newVerPrg, % "  Update Available"
SetTimer, CheckVerPrg, Delete

IniProc(scrWidth, scrHeight, scrFreq, selPrgChoice)
Return

TestMode:
Gui, PrgLnchOpt: Submit, Nohide
Tooltip
IniProc(scrWidth, scrHeight, scrFreq, selPrgChoice)
Return
ChangeMode:
Gui, PrgLnchOpt: Submit, Nohide
Tooltip
IniProc(scrWidth, scrHeight, scrFreq, selPrgChoice)
Return
DynamicMode:
Gui, PrgLnchOpt: Submit, Nohide
Tooltip
IniProc(scrWidth, scrHeight, scrFreq, selPrgChoice)
Return
TmpMode:
Gui, PrgLnchOpt: Submit, Nohide
Tooltip
IniProc(scrWidth, scrHeight, scrFreq, selPrgChoice)
Return

ChgResonSwitchChk:
Gui, PrgLnchOpt: Submit, Nohide
Tooltip
PrgChgResonSwitch[selPrgChoice] := ChgResonSwitch
IniProc(scrWidth, scrHeight, scrFreq, selPrgChoice)
Return

PrgLnchHideChk:
Gui, PrgLnchOpt: Submit, Nohide
Tooltip
PrgLnchHide[selPrgChoice] := PrgLnchHd
IniProc(scrWidth, scrHeight, scrFreq, selPrgChoice)
Return

BordlessChk:
Gui, PrgLnchOpt: Submit, Nohide
Tooltip
PrgBordless[selPrgChoice] := Bordless
IniProc(scrWidth, scrHeight, scrFreq, selPrgChoice)
if (PrgPID) ;test only from config
BordlessProc(PrgPos, PrgMinMax, PrgStyle, dx, dy, scrWidth, scrHeight, PrgPID, WindowStyle)
Return

PrgPriorityChk:
Gui, PrgLnchOpt: Submit, Nohide
Tooltip
PrgRnPriority[selPrgChoice] := PrgPriority
IniProc(scrWidth, scrHeight, scrFreq, selPrgChoice)
if (PrgPID) ;test only from config
{
(!PrgPriority)? temp := "B": (PrgPriority = 1)? temp := "H": temp := "N"
Process, priority, %PrgPID%, % temp
}
Return

PrgCanBeShortctChk:
Gui, PrgLnchOpt: Submit, Nohide
Tooltip
PrgCanBeShortcut := PrgCanBeShortct
IniProc(scrWidth, scrHeight, scrFreq, selPrgChoice)
Return


PrgLAARn:
Tooltip
DoLAAPatch(PrgChoicePaths[selPrgChoice])
Return

UpdturlPrgLnchText:
Tooltip
GuiControlGet, temp, PrgLnchOpt: FocusV
if (temp = "MkShortcut")
Return
Gui, PrgLnchOpt: Submit, Nohide

	if (temp = "UpdturlPrgLnch")
	{
	if (strlen(UpdturlPrgLnch) > 2082) ;http://stackoverflow.com/questions/417142/what-is-the-maximum-length-of-a-url-in-different-browsers
	{
	MsgBox, 8192, , Too long! ;Probably bombs the script anyway

	UpdturlPrgLnch := ""
	}
	if (!PrgUrl[selPrgChoice])
	ToolTip , "Click `"Update Prg`" to save."
	PrgUrl[selPrgChoice] := UpdturlPrgLnch
	}
Return

CheckDefaultPrg:
Gui, PrgLnchOpt: Submit, Nohide
Tooltip
if DefaultPrg
{
defPrgStrng := PrgChoiceNames[selPrgChoice]
IniWrite, %defPrgStrng%, %PrgLnchIni%, Prgs, StartupPrgName
}
else
{
defPrgStrng := "None"
IniWrite, None, %PrgLnchIni%, Prgs, StartupPrgName
}
Return

RegoCheck:
Gui, PrgLnchOpt: Submit, Nohide
Tooltip
IniProc(scrWidth, scrHeight, scrFreq, selPrgChoice)
Return

CmdLinPrmSub:
Gui, PrgLnchOpt: Submit, Nohide
Tooltip
sleep 200 ;slow input
GuiControlGet, ftemp, PrgLnchOpt:, CmdLinPrm
if (ftemp)
{
	if (strlen(ftemp) > 20000) ;length?
	{
	ftemp := SubStr(txtPrgChoice, 1, 20000)
	GuiControl, PrgLnchOpt:, CmdLinPrm, %ftemp%
	}
}
PrgCmdLine[selPrgChoice] := ftemp
IniProc(scrWidth, scrHeight, scrFreq, selPrgChoice)
Return

SetEditCueBanner(HWND, Cue)
{
; requires AHL_L: JustMe
Static EM_SETCUEBANNER := (0x1500 + 1)
Return DllCall("User32.dll\SendMessageW", "Ptr", HWND, "Uint", EM_SETCUEBANNER, "Ptr", True, "WStr", Cue)
}
MakeLong(LoWord, HiWord) ; courtesy Chris
{
return (HiWord << 16) | (LoWord & 0xffff)
}






















iDevNo:
Gui, PrgLnchOpt: Submit, Nohide
Tooltip
GuiControlGet, ftemp, PrgLnchOpt:, iDevNum
GuiControlGet, temp, PrgLnchOpt: FocusV

if (temp = "iDevNum")
{
	if !(ftemp = targMonitorNum)
	{
	targMonitorNum := ftemp
	GuiControl, ,PrgLnchOpt: allModes, 0
	}

	SetResDefaults(targMonitorNum, currRes, Dynamic, FMode, scrWidth, scrHeight, scrFreq, scrWidthDef, scrHeightDef, scrFreqDef, scrWidthDefArr, scrHeightDefArr, scrFreqDefArr, 1)
	;Must reset reslist
	GoSub CheckModes

	if (PrgMonToRn[selPrgChoice]) ; save it if a Prg
	{
		; invalid monitor?
		if (iDevNumArray[targMonitorNum] < 10)
		targMonitorNum := PrgLnchMon
		PrgMonToRn[selPrgChoice] := targMonitorNum
		IniProc(scrWidth, scrHeight, scrFreq, selPrgChoice)
		if !FindStoredRes(PrgLnchIni, scrWidth, scrHeight, scrFreq)
		GuiControl, PrgLnchOpt: ChooseString, ResIndex, %currRes%

	}
	GoSub FixMonColours
}
else
{
	SetResDefaults(ftemp, currRes, Dynamic, FMode, scrWidth, scrHeight, scrFreq, scrWidthDef, scrHeightDef, scrFreqDef, scrWidthDefArr, scrHeightDefArr, scrFreqDefArr, 1)
	;Must reset reslist
	GoSub CheckModes
}

Return


FixMonColours:
	GuiControl, PrgLnchOpt:, Monitors, % dispMonNames[targMonitorNum]

	if iDevNumArray[targMonitorNum] < 10 ;dec masks
	{
	GuiControl, PrgLnchOpt: Disable, ResIndex
	GuiControl, PrgLnchOpt: Disable, currRes
	GuiControl, PrgLnchOpt: Disable, allModes
	Gui, PrgLnchOpt: Font, cGrey Bold, Verdana
	}
	else
	{
	GuiControl, PrgLnchOpt: Enable, ResIndex
	GuiControl, PrgLnchOpt: Enable, currRes
	GuiControl, PrgLnchOpt: Enable, allModes

		if iDevNumArray[targMonitorNum] > 99
		{
		GuiControl, PrgLnchOpt: ChooseString, iDevNum, % SubStr(iDevNumArray[targMonitorNum], 3, 1)
		Gui, PrgLnchOpt: Font, cTeal Bold, Verdana
		}
		else
		{
		GuiControl, PrgLnchOpt: ChooseString, iDevNum, % SubStr(iDevNumArray[targMonitorNum], 2, 1)
		Gui, PrgLnchOpt: Font, cA96915 Bold, Verdana
		}
	}
	GuiControl, PrgLnchOpt: Font, Monitors
Return


CheckModes:

Gui, PrgLnchOpt: Submit, Nohide
Tooltip

	temp := GetPrgLnchMonNum(iDevNumArray, dispMonNamesNo)
	if (targMonitorNum = 1)
	{
		if !(temp = targMonitorNum)
		{
			IniRead, ftemp, %A_ScriptDir%`\%PrgLnchIni%, General, LnchPrgMonWarn
			if !(ftemp)
			{
			MsgBox, 8195, , PrgLnch was run from monitor %temp% but the`n current monitor is set at %targMonitorNum%. This may be intended.`n`nReply:`nYes: Continue (Warn like this next time)`nNo: Continue (This will not show again) `nCancel: Change the default monitor back to 1: `n
			IfMsgBox, Cancel
			PrgLnchMon := targMonitorNum
			else
			{
			IfMsgBox, No
			IniWrite, 1, %A_ScriptDir%`\%PrgLnchIni%, General, LnchPrgMonWarn
			}
			}
		}
	}

	ResIndexList := GetResList(PrgLnchMon, targMonitorNum, dispMonNamesNo, iDevNumArray, dispMonNames, ResArray, scrWidthDef, scrHeightDef, scrFreqDef, allModes, -1)
	GuiControlGet Tmp, PrgLnchOpt:, Tmp ; Why?

	if !(PresetLabelHwnd)  ;Update all at Load
	{
		GuiControl, PrgLnchOpt:, currRes, % substr(ResIndexList, 1, StrLen(ResIndexList) - 1)
		if (defPrgStrng = "None")
		{
		scrWidth := scrWidthDef
		scrHeight := scrHeightDef
		scrFreq := scrFreqDef
		}
	}
	else
	{
	if (Fmode || Dynamic)
	GuiControl, PrgLnchOpt:, currRes, % substr(ResIndexList, 1, StrLen(ResIndexList) - 1)
	}
	ResIndexList := % "|" . GetResList(PrgLnchMon, targMonitorNum, dispMonNamesNo, iDevNumArray, dispMonNames, ResArray, scrWidthDef, scrHeightDef, scrFreqDef, allModes)

;Not the g-label ResListBox!
GuiControl, PrgLnchOpt:, ResIndex, %ResIndexList%
GuiControlGet currRes, PrgLnchOpt:, currRes
GuiControl, PrgLnchOpt: ChooseString, ResIndex, %currRes%
GuiControl, PrgLnchOpt: Show, ResIndex
Return


ResListBox:
Tooltip
if !Allmodes
{
GuiControlGet, ftemp, PrgLnchOpt:, ResIndex
	Loop, Parse, ResIndexList, |
	{
	If (ftemp = A_Loopfield)
	{
	ftemp := A_Index
	Break
	}
	}
scrWidth := ResArray[ftemp - 1, 1]
scrHeight := ResArray[ftemp - 1, 2]
scrFreq := ResArray[ftemp - 1, 3]
}

if (PrgChoicePaths[selPrgChoice])
{
IniProc(scrWidth, scrHeight, scrFreq, selPrgChoice)
}

Return

FindStoredRes(PrgLnchIni, scrWidth, scrHeight, scrFreq)
{
	Stat := 0, temp := 0, ftemp := 0

	ControlGet, ftemp, List,, ListBox1, % "ahk_id" PrgLnchOpt.Hwnd()
	Loop, Parse, ftemp, `n
	{
	temp := ""
	temp .= scrWidth . " `, " . scrHeight . " @ " . scrFreq . "Hz "
	if (temp = A_LoopField)
	{
	GuiControl, PrgLnchOpt: ChooseString, ResIndex, % temp
	Stat := 1
	Break
	}
	}
if !stat
{
	IniRead, ftemp, %A_ScriptDir%`\%PrgLnchIni%, General, ResClashMsg
	if !(ftemp)
	{
	MsgBox, 8196, , % "Mismatch detected in desired resolution data for this monitor! This usually involves differing frequency values appertaining to the same resolution preset.`nExcerpt from MSDN: `n`n""In Windows 7 and newer versions of Windows, when a user selects 60Hz, the OS stores a value of 59.94Hz. However, 59Hz is shown in the Screen refresh rate in Control Panel, even though the user selected 60Hz."" `n`nThe current resolution mode might have also been set from the ""List all Compatible"" selection. `n`n`nYes: Continue (Warn like this next time) `nNo: Continue (This will not show again) `n"
		IfMsgBox, Yes
		ftemp := 0 ; dummy condition
		else
		{
		IfMsgBox, No
		IniWrite, 1, %A_ScriptDir%`\%PrgLnchIni%, General, ResClashMsg
		}
	}
}
Return stat
}
SetResDefaults(targMonitorNum, currRes, Dynamic, FMode, ByRef scrWidth, ByRef scrHeight, ByRef scrFreq, ByRef scrWidthDef, ByRef scrHeightDef, ByRef scrFreqDef, ByRef scrWidthDefArr, ByRef scrHeightDefArr, ByRef scrFreqDefArr, SaveVars := 0)
{
temp := 0, ftemp := 0
	if (SaveVars)
	{
		if scrWidthDefArr[targMonitorNum] ;no need if  values have been read already
			{
			scrWidthDef := scrWidthDefArr[targMonitorNum]
			scrHeightDef := scrHeightDefArr[targMonitorNum]
			scrFreqDef := scrFreqDefArr[targMonitorNum]
			}
		else
			{
			scrWidthDefArr[targMonitorNum] := scrWidthDef
			scrHeightDefArr[targMonitorNum] := scrHeightDef
			scrFreqDefArr[targMonitorNum] := scrFreqDef
			}
	}
	else ; on init
	{
	;Sets new defaults according to resolution changes when changing res
		if (Dynamic || FMode)
		{
		scrWidthDef := scrWidth
		scrHeightDef := scrHeight
		scrFreqDef := scrFreq
		scrWidthDefArr[targMonitorNum] := scrWidthDef
		scrHeightDefArr[targMonitorNum] := scrHeightDef
		scrFreqDefArr[targMonitorNum] := scrFreqDef
		GuiControlGet currRes, PrgLnchOpt:, ResIndex
		GuiControl, PrgLnchOpt:, currRes, % currRes
		}
	}
}


























PrgChoice:
Gui, PrgLnchOpt: Submit, Nohide
Tooltip
SendMessage 0x147, 0, 0, , ahk_id %PrgChoiceHwnd%  ; CB_GETCURSEL


If ErrorLevel = "FAIL"
	{
	Gui, PrgLnchOpt: Submit, Nohide
	MsgBox, 8192, , CB_GETCURSEL Failed
	}
else
	{
	
	retVal := ErrorLevel << 32 >> 32
	if (retVal < 0) ;Did the user type?
		{
		sleep 200 ;slow down input?
		PrgChoiceClicked := 0
		GuiControlGet, txtPrgChoice, PrgLnchOpt:, PrgChoice
	
		;Pre-validation
		if (txtPrgChoice = "None")
		txtPrgChoice := "Nada"
		else
		{
		loop, %maxbatchPrgs% ; also used for mon numbers
			{
			temp := "*" . A_Index . "* "  ; Required for Batch selection
			if (InStr(txtPrgChoice, temp))
			txtPrgChoice := StrReplace(txtPrgChoice, temp, "*" . A_Index . "*")
			}
		
			if (txtPrgChoice = "|")
			txtPrgChoice := Prg%selPrgChoice%
			else
			{
			if (InStr(txtPrgChoice, "|"))
			txtPrgChoice := StrReplace(txtPrgChoice, "|", "1")
			}
		}

		if (strlen(txtPrgChoice) > 20000) ;length?
		{
		txtPrgChoice := SubStr(txtPrgChoice, 1, 20000)
		GuiControl, PrgLnchOpt: Text, PrgChoice, %txtPrgChoice%
		}
		GuiControlGet temp, PrgLnchOpt:, MkShortcut

		if !(temp = "Just Change Res.") ; Otherwise don't care if typed over "None"
		{
			if (ChkPrgNames(txtPrgChoice))
			{
			;"0" happens rarely on "timing glitch??"
			txtPrgChoice := "PrgName"
			GuiControl, PrgLnchOpt: Text, PrgChoice, %txtPrgChoice%
			}
			else
			{
				if (txtPrgChoice)
				{
					if (temp="Make Shortcut")
					ToolTip , "Click `"Make Shortcut`" to save."
					else
					{
					ToolTip , "Click `"Change Shortcut`" to save."
					GuiControl, PrgLnchOpt:, Remove Shortcut, Change Shortcut
					}
				}
				else
				{
				GuiControl, PrgLnchOpt:, MkShortcut, Remove Shortcut
					if (PrgChoicePaths[selPrgChoice]) ;Path already exist?
					ToolTip , "Click `"Remove Shortcut`" or hit Del to confirm."
					else
					ToolTip , "Click `"Remove Shortcut`" or hit Del to remove unexpected data from reference."
				}
			}
		}
			
		}
	else ; Clicked here
		{
		SetTimer, CheckVerPrg, Delete ;vital

		PrgChoiceClicked := 1
		selPrgChoice := retVal
		if (retVal)
			{
			GuiControlGet, txtPrgChoice, PrgLnchOpt:, PrgChoice ;one of the list items
			GuiControl, PrgLnchOpt:, RnPrgLnch, &Test Run Prg
				if (PrgChoiceNames[selPrgChoice])
				{
				fTemp := PrgChoicePaths[selPrgChoice]
				;gets, tests working directory of possible lnk, if any
				foundpos := PrgLnkInf[selPrgChoice]
					if (foundpos && !(foundpos = "*"))
					WorkingDirectory(1, foundpos)
					else
					WorkingDirectory(1, fTemp)		


				scrWidth := scrWidthArr[selPrgChoice]
				scrHeight := scrHeightArr[selPrgChoice]
				scrFreq := scrFreqArr[selPrgChoice]

				PrgCmdLineEnable(selPrgChoice, PrgLnkInf, PrgCmdLine, cmdLinHwnd)
				GuiControl, PrgLnchOpt: Enable, MkShortcut
				GuiControl, PrgLnchOpt:, MkShortcut, Change Shortcut
				GuiControl, PrgLnchOpt: Enable, RnPrgLnch
				PrgURLEnable(selPrgChoice, selPrgChoiceTimer, PrgLnkInf, PrgUrl, PrgVer, PrgVerOld, UpdturlHwnd)

				GuiControl, PrgLnchOpt: Enable, PrgLnchHd
				GuiControl, PrgLnchOpt:, PrgLnchHd, % PrgLnchHide[selPrgChoice]
				GuiControl, PrgLnchOpt: Enable, Bordless
				GuiControl, PrgLnchOpt:, Bordless, % PrgBordless[selPrgChoice]
				GuiControl, PrgLnchOpt: Enable, PrgPriority
				GuiControl, PrgLnchOpt:, PrgPriority, % PrgRnPriority[selPrgChoice]
				GuiControl, PrgLnchOpt: Enable, ChgResonSwitch
				GuiControl, PrgLnchOpt:, ChgResonSwitch, % PrgChgResonSwitch[selPrgChoice]

				GuiControl, PrgLnchOpt: Enable, PrgLAA

				GuiControlGet, targMonitorNum, PrgLnchOpt:, iDevNum

				if !(targMonitorNum = PrgMonToRn[selPrgChoice])
					{
					targMonitorNum := PrgMonToRn[selPrgChoice]
					GoSub iDevNo
					GoSub FixMonColours
					GuiControl, PrgLnchOpt: ChooseString, iDevNum, %targMonitorNum%
					}
				


				if !FindStoredRes(PrgLnchIni, scrWidth, scrHeight, scrFreq)
				GuiControl, PrgLnchOpt: ChooseString, ResIndex, %currRes%


				}
				else
				{

				GuiControl, PrgLnchOpt: Enable, MkShortcut
				GuiControl, PrgLnchOpt:, MkShortcut, Make Shortcut
				GuiControl, PrgLnchOpt: Disable, RnPrgLnch
				DisableVariousResCtrls()
				}

			}
		else
			{
				selPrgChoice := 1
				GuiControl, PrgLnchOpt: Enable, RnPrgLnch
				GuiControl, PrgLnchOpt:, RnPrgLnch, Change Res`.
				GuiControl, PrgLnchOpt: Disable, DefaultPrg
				GuiControl, PrgLnchOpt:, MkShortcut, Just Change Res.
				GuiControl, PrgLnchOpt: Disable, Just Change Res.

				DisableVariousResCtrls()

				GuiControlGet, targMonitorNum, PrgLnchOpt:, iDevNum
				if (iDevNumArray[targMonitorNum] < 10)
				targMonitorNum := PrgLnchMon
				GoSub CheckModes
				GuiControl, PrgLnchOpt: ChooseString, iDevNum, %targMonitorNum%
				GoSub FixMonColours

			}

		}
	;Startup Default?
	IniRead, defPrgStrng, %PrgLnchIni%, Prgs, StartupPrgName, %A_Space%
	GuiControlGet temp, PrgLnchOpt:, MkShortcut
	if (temp = "Just Change Res.") ; Otherwise don't care if typed over "None"
	{
	GuiControl, PrgLnchOpt: , DefaultPrg, 0
	GuiControl, PrgLnchOpt: Disable, DefaultPrg
	}
	else
	{
		if (PrgChoiceNames[selPrgChoice] = defPrgStrng) ;Default here
		{
		GuiControl, PrgLnchOpt: , DefaultPrg, 1
		GuiControl, PrgLnchOpt: Enable, DefaultPrg
		}
		else
		{
		GuiControl, PrgLnchOpt: , DefaultPrg, 0
			if (PrgChoiceNames[selPrgChoice])
			{
			GuiControl, PrgLnchOpt: Enable, DefaultPrg
			}
			else
			{
			GuiControl, PrgLnchOpt: Disable, DefaultPrg
			}
		}
	}


	}

Return


MakeShortcut:
Gui, PrgLnchOpt: Submit, Nohide
Tooltip
Gui, PrgLnchOpt: +OwnDialogs
if (txtPrgChoice = "")
{
	
	Loop, % PrgNo
	{
	temp := ProgPIDMast[A_Index]
		if (temp)
		{
		MsgBox, 8192, , % "Sorry, Prgs cannot be removed while any are active in Batch!"
		Return
		}
	}
	
	;SelPrgChoice is last selected
	MsgBox, 8193, , Remove Shortcut?
	IfMsgBox, Ok
	{
	SetTimer, CheckVerPrg, Delete ;vital to do first

	;Remove default
	IniRead, defPrgStrng, %PrgLnchIni%, Prgs, StartupPrgName ;Space just in case None is absent
	if (defPrgStrng = PrgChoiceNames[selPrgChoice])
	{
	defPrgStrng := "None"
	IniWrite, None, %PrgLnchIni%, Prgs, StartupPrgName
	}
	GuiControl, PrgLnchOpt: , DefaultPrg, 0
	GuiControl, PrgLnchOpt: Disable, DefaultPrg

	PrgChoiceClicked := 1
	txtPrgChoice := "Prg Removed"
	WorkingDirectory(0, A_ScriptDir)
	IniProc(scrWidth, scrHeight, scrFreq, selPrgChoice, 1)
	strPrgChoice := ComboBugFix(strPrgChoice, Prgno)
	PrgChoiceNames[selPrgChoice] := 
	PrgChoiceNames[selPrgChoice] := "" ;yeah weird but get's it empty
	PrgChoicePaths[selPrgChoice] := ""
	PrgCmdLine[selPrgChoice] := 0
	PrgUrl[selPrgChoice] := ""
	PrgLnchHide[selPrgChoice] := 0
	PrgMonToRn[selPrgChoice] := 0
	PrgLnkInf[selPrgChoice] := 0

	GuiControl, PrgLnchOpt:, PrgChoice, %strPrgChoice%
	GuiControl, PrgLnchOpt: Choose, PrgChoice, % selPrgChoice + 1
	GuiControl, PrgLnchOpt:, MkShortcut, Make Shortcut
	GuiControl, PrgLnchOpt: Disable, RnPrgLnch

	DisableVariousResCtrls()
	iDevNum := 1
	GuiControl, PrgLnchOpt:, Choose, iDevNum
	GoSub FixMonColours


	}

}
else
{
	;Watch out for TIMERS!
	Thread, NoTimers
	if (PrgCanBeShortcut)
	FileSelectFile, fTemp, 35,, Open a file or Shortcut, (*.exe; *.bat; *.com; *.cmd; *.pif; *.msc; *.lnk)
	else
	FileSelectFile, fTemp, 3,, Open a file, (*.exe; *.bat; *.com; *.cmd; *.pif; *.msc)
	Thread, NoTimers, false
	if (!ErrorLevel)
		{
			if (PrgChoiceClicked) ;No typing in Combobox
			{
			PrgChoicePaths[selPrgChoice] := fTemp
			temp := SubStr(fTemp, 1, InStr(fTemp, ".") - 1)
			PrgChoiceNames[selPrgChoice] := SubStr(temp, InStr(temp, "\",, -1) + 1)
			}
			else
			{
			PrgChoiceNames[selPrgChoice] := txtPrgChoice
			}
		
		;check dup names
		Loop, % PrgNo
		{
		if !(selPrgChoice = A_Index)
		{
		if (PrgChoiceNames[selPrgChoice] = PrgChoiceNames[A_Index])
		PrgChoiceNames[selPrgChoice] := PrgChoiceNames[selPrgChoice] . selPrgChoice
		}
		}
		

		PrgChoiceClicked := 1

		GuiControlGet, targMonitorNum, PrgLnchOpt:, iDevNum
		;valid monitor?
		if (iDevNumArray[targMonitorNum] < 10)
		targMonitorNum := PrgLnchMon
		PrgMonToRn[selPrgChoice] := targMonitorNum

		PrgLnchHide[selPrgChoice] := 0
		strPrgChoice := ComboBugFix(strPrgChoice, Prgno)
		IniProc(scrWidth, scrHeight, scrFreq, selPrgChoice)
		fTemp := PrgChoicePaths[selPrgChoice]
		;gets working directory of lnk, if any
		foundpos := IsPrgaLnk(fTemp)
		PrgLnkInf[selPrgChoice] := foundpos
		if (foundpos && !(foundpos = "*"))
		WorkingDirectory(1, foundpos)
		else
		WorkingDirectory(1, fTemp)		
		PrgCmdLineEnable(selPrgChoice, PrgLnkInf, PrgCmdLine, cmdLinHwnd)

		GuiControl, PrgLnchOpt:, MkShortcut, Change Shortcut		
		GuiControl, PrgLnchOpt:, PrgChoice, %strPrgChoice%
		GuiControl, PrgLnchOpt: Choose, PrgChoice, % selPrgChoice + 1
		GuiControl, PrgLnchOpt: Enable, DefaultPrg
		GuiControl, PrgLnchOpt: Enable, RnPrgLnch
		GuiControl, PrgLnchOpt: Enable, PrgLnchHd
		GuiControl, PrgLnchOpt:, PrgLnchHd, % PrgLnchHide[selPrgChoice]
		GuiControl, PrgLnchOpt: Enable, Bordless
		GuiControl, PrgLnchOpt:, Bordless, % PrgBordless[selPrgChoice]
		GuiControl, PrgLnchOpt: Enable, PrgPriority
		GuiControl, PrgLnchOpt:, PrgPriority, % PrgRnPriority[selPrgChoice]
		GuiControl, PrgLnchOpt: Enable, ChgResonSwitch
		GuiControl, PrgLnchOpt:, ChgResonSwitch, % PrgChgResonSwitch[selPrgChoice]


		GuiControl, PrgLnchOpt: Enable, PrgLAA

		GoSub iDevNo
		GoSub FixMonColours

		GuiControl, PrgLnchOpt: ChooseString, iDevNum, %targMonitorNum%

		if !FindStoredRes(PrgLnchIni, scrWidth, scrHeight, scrFreq)
		GuiControl, PrgLnchOpt: ChooseString, ResIndex, %currRes%


		PrgURLEnable(selPrgChoice, selPrgChoiceTimer, PrgLnkInf, PrgUrl, PrgVer, PrgVerOld, UpdturlHwnd)

		}
	;else PrgChoicePaths is made blank
}
Return
ChkPrgNames(testName)
{
if (testName = "0" || testName = "Prg1" || testName = "Prg2" || testName = "Prg3" || testName = "Prg4" || testName = "Prg5" || testName = "Prg6" || testName = "Prg7" || testName = "Prg8" || testName = "Prg9")
return 1
else
return 0
}
ComboBugFix(strPrgChoice, PrgNo)
{
temp := 0, temp1 := 0, foundpos1 := 0, foundpos := InStr(strPrgChoice, "||")
;Addresses weird bug when partially matched names are removed and added to the combobox

StringReplace, temp, strPrgChoice, |, |, UseErrorLevel ; finds all occurrences of needle in haystack

	if !(ErrorLevel = PrgNo + 2)
	{
	MsgBox, 8192, , PrgLnch has an encountered an unexpected error! Attempting Restart!
	WorkingDirectory(0, A_ScriptDir)
	Run, PrgLnch.exe Force
	ExitApp
	}


	if (foundpos)
	{
		Loop, % PrgNo
		{
		if (InStr(strPrgChoice, "|",,, A_Index + 1) = foundpos)
		{
		temp := Substr(strPrgChoice, 1, foundpos) . "Prg" . A_Index

		temp1 := Substr(strPrgChoice, foundpos + 1)
		foundpos1 := InStr(temp1, "||") ;' yikes already checked! Null terminator removed?
		if (foundpos1)
		temp1 := "|Prg" . A_Index + 1 . Substr(temp1, foundpos1 + 1)
		
		Return temp . temp1
		}
		}
	}
	else
	return strPrgChoice
}
PrgCmdLineEnable(selPrgChoice, PrgLnkInf, PrgCmdLine, cmdLinHwnd)
{
if (PrgLnkInf[selPrgChoice])
	{
	SetEditCueBanner(cmdLinHwnd, "Cmd Line Extras")
	GuiControl, PrgLnchOpt: Disable, CmdLinPrm
	}
	else
	{
	GuiControl, PrgLnchOpt: Enable, CmdLinPrm
		if (PrgCmdLine[selPrgChoice])
		GuiControl, PrgLnchOpt:, CmdLinPrm, % PrgCmdLine[selPrgChoice]
		else
		SetEditCueBanner(cmdLinHwnd, "Cmd Line Extras")
	}
}
PrgURLEnable(selPrgChoice, selPrgChoiceTimer, PrgLnkInf, PrgUrl, PrgVer, PrgVerOld, UpdturlHwnd)
{
temp := PrgUrl[selPrgChoice]
GuiControl, PrgLnchOpt: -ReadOnly, UpdturlPrgLnch
	if (temp && !PrgLnkInf[selPrgChoice])
		{
			GuiControl, PrgLnchOpt: Enable, UpdtPrgLnch
			GuiControl, PrgLnchOpt: Enable, UpdturlPrgLnch
			GuiControl, PrgLnchOpt:, UpdturlPrgLnch, % temp
			PrgVerOld := PrgVer
			selPrgChoiceTimer := selPrgChoice
				if (GetPrgVersion(temp, PrgVer))
				GuiControl, PrgLnchOpt:, newVerPrg, Info unavailable
				else
				{
				GuiControl, PrgLnchOpt:, newVerPrg, % "  Checking Update..." ; … ellipsis wait for Unicode build
				SetTimer, CheckVerPrg, 5000
				}
		}
		else
		{
		GuiControl, PrgLnchOpt:, newVerPrg
		GuiControl, PrgLnchOpt:, UpdturlPrgLnch
		GuiControl, PrgLnchOpt: Disable, UpdtPrgLnch
		if !(PrgLnkInf[selPrgChoice])
		{
		GuiControl, PrgLnchOpt: Enable, UpdturlPrgLnch
		SetEditCueBanner(UpdturlHwnd, "Url Progenitor of Prg") ;Replaced Get Focus & Send, ^a & Tooltip
		}
		else
		GuiControl, PrgLnchOpt: Disable, UpdturlPrgLnch
		}

}

#IfWinActive PrgLnchOpt
{
Del::
GuiControlGet, ftemp, PrgLnchOpt: FocusV
GuiControlGet, temp, PrgLnchOpt:, MkShortcut
	if (temp = "Change Shortcut" &&  ftemp = "PrgChoice")
	{
	txtPrgChoice := ""
	ControlSetText,,,ahk_id %PrgChoiceHwnd%
	GuiControl, PrgLnchOpt:, MkShortcut, Remove Shortcut
	if (PrgChoicePaths[selPrgChoice])
	ToolTip , "Click `"Remove Shortcut`" or hit Del to confirm."
	else
	ToolTip , "Click `"Remove Shortcut`" or hit Del to remove unexpected data from reference."
	Return
	}
	else
	{
		if (temp = "Remove Shortcut" && (ftemp = "MkShortcut" || ftemp = "PrgChoice"))
		{
		txtPrgChoice := ""
		Gosub, MakeShortcut
		}
		else ; Do something else? Fine
		Tooltip
	}
Return
}




























LnchPrgLnch:
Tooltip
Thread, NoTimers
if (PrgUrl[selPrgChoice])
{
SetTimer, CheckVerPrg, Delete
GuiControl, PrgLnchOpt:, newVerPrg,
}
waitBreak := 1
SetTimer, WatchSwitchBack, Delete
SetTimer, WatchSwitchOut, Delete

; set lnchPrgStat, lnchStat 
GuiControlGet temp, PrgLnchOpt:, RnPrgLnch
GuiControlGet ftemp, PrgLnch:, RunBatchPrg
if ((presetNoTest) && ftemp = "&Run Batch" || !(presetNoTest) && temp = "&Test Run Prg")
{
	lnchPrgStat := 100 ; changes shortly
	foundpos := ChkExistingProcess(selPrgChoice, currBatchNo, PrgBatchIni%btchPrgPresetSel%, PrgListIndex, PrgChoicePaths)

	if (foundpos)
	{
		IniRead, ftemp, %A_ScriptDir%`\%PrgLnchIni%, General, PrgAlreadyMsg
		if !ftemp
		{
		MsgBox, 8195, , One or more Prgs scheduled for start matches a process running with `nthe same name. Might be an issue depending on instance requisites.`n`"%foundpos%`"`n`nReply:`nYes: Continue (Warn like this next time) `nNo: Continue (This will not show again) `nCancel: Do nothing: `n
			IfMsgBox, Yes
			ftemp := 0 ; dummy condition
			else
			{
				IfMsgBox, No
				IniWrite, 1, %A_ScriptDir%`\%PrgLnchIni%, General, PrgAlreadyMsg
				else
				return
			}
		}

	}

	if !(presetNoTest) && (temp = "&Test Run Prg")
	{
	lnchStat := -1
	targMonitorNum := PrgMonToRn[selPrgChoice]
	}
	else
	lnchStat := 1

	IfNotExist PrgLaunching.jpg
	{
	FileInstall PrgLaunching.jpg, PrgLaunching.jpg
	sleep 200
	}


}
else
{
	if (!(presetNoTest) && temp = "Change Res`.")
	{
	lnchPrgStat := 0
	GuiControlGet, targMonitorNum, PrgLnchOpt:, iDevNum
	}
	else ; cancel
	{
		if (presetNoTest)
		{
		lnchStat := 1
		lnchPrgStat := -100 ; changes shortly
		}
		else
		lnchStat := -1
	}
}

;init status list vars
ftemp := PrgChoicePaths[selPrgChoice]
foundpos := "|" ;Building PrgStatus list


loop, % ((presetNoTest)? currBatchno: 1)
{

; Update Prg index
	if (presetNoTest)
	{
		if (lnchPrgStat > 0)
		{
		;Init all to batch
		PrgListPID%btchPrgPresetSel%[A_Index] := "NS"
		;Hide the quit and config buttons!
		GuiControl, PrgLnch: Hide, PresetName
		GuiControl, PrgLnch: Hide, ListPrg
		GuiControl, PrgLnch: Hide, BtchPrgPreset
		GuiControl, PrgLnch: Hide, RunBatchPrg
		GuiControl, PrgLnch: Hide, % quitHwnd
		GuiControl, PrgLnch: Hide, % GoConfigHwnd

		lnchPrgStat := PrgBatchIni%btchPrgPresetSel%[A_Index]
		temp := PrgChoicePaths[lnchPrgStat]
		if !(PrgLnchHide[lnchPrgStat])
		SplashImage, PrgLaunching.jpg, A B,,,LnchSplash
		sleep, % (!PrgIntervalLnch)? 2000: (PrgIntervalLnch = -1)? 4000: 6000
		}
		else
		{
		lnchPrgStat := -PrgBatchIni%btchPrgPresetSel%[A_Index]
		temp := PrgChoicePaths[-lnchPrgStat]
		}		
	scrWidth := scrWidthArr[lnchPrgStat]
	scrHeight := scrHeightArr[lnchPrgStat]
	scrFreq := scrFreqArr[lnchPrgStat]
	targMonitorNum := PrgMonToRn[lnchPrgStat]
	}

	retVal := LnchPrgOff(PrgLnchIni, A_Index, lnchStat, (presetNoTest)? temp: ftemp, (presetNoTest)? currBatchno: 1, (presetNoTest)? lnchPrgStat: selPrgChoice, PrgCmdLine, iDevNumArray, dispMonNamesNo, WindowStyle, PrgBordless, PrgRnPriority, scrWidth, scrHeight, scrFreq, scrWidthDef, scrHeightDef, scrFreqDef, targMonitorNum, PrgPID, PrgListPID%btchPrgPresetSel%, PrgPos, PrgMinMax, PrgStyle, x, y, w, h, dx, dy, Fmode)

	if (retVal)
	{  ;Lnch failed for current Prg
	if (lnchPrgStat > 0)
		{
		if (lnchStat = 1)
		foundpos .= "Failed" . "|"

		MsgBox, 8192, , % retVal
		}
	}
	else
	{
	SetResDefaults(targMonitorNum, currRes, Dynamic, FMode, scrWidth, scrHeight, scrFreq, scrWidthDef, scrHeightDef, scrFreqDef, scrWidthDefArr, scrHeightDefArr, scrFreqDefArr)
		if (presetNoTest)
		{
			if (lnchPrgStat > 0)
			{
				if (PrgLnchHide[lnchPrgStat])
				Gui, PrgLnch: Show, Hide, PrgLnch
				batchActive := 1
				foundpos .= "Active" . "|"
			}
			else
			{
			; Cancelling the lot!
			if (lnchPrgStat < 0)
			foundpos .= "Not Active" . "|"
			}
			; Update Master
			ProgPIDMast[lnchPrgStat] := PrgListPID%btchPrgPresetSel%[A_Index]
		}
		else
		{
			if (lnchPrgStat > 0)
			{
				if (PrgLnchHide[selPrgChoice])
				Gui, PrgLnchOpt: Show, Hide, PrgLnchOpt
				else
				{
				HideShowTestRunCtrls()
				GuiControl, PrgLnchOpt:, RnPrgLnch, &Cancel Prg
				}
			}
			else ;just cancelled- but not from a hidden form!
			{
			if (lnchPrgStat < 0)
				{
				HideShowTestRunCtrls(1)
				GuiControl, PrgLnchOpt:, RnPrgLnch, &Test Run Prg
				}
			}
	
		}
	}
SplashImage, PrgLaunching.jpg, Hide,,,LnchSplash
}


;Start Timer & update status list & fix buttons
Thread, NoTimers, false


if (presetNoTest)
	{
	GuiControl, PrgLnch:, batchPrgStatus, %foundpos%

	GuiControl, PrgLnch: Show, PresetName
	GuiControl, PrgLnch: Show, BtchPrgPreset
	GuiControl, PrgLnch: Show, ListPrg
	GuiControl, PrgLnch: Show, RunBatchPrg
	GuiControl, PrgLnch: Show, % quitHwnd
	GuiControl, PrgLnch: Show, % GoConfigHwnd

	temp := 0

	loop, % currBatchno
		{
		ftemp := PrgListPID%btchPrgPresetSel%[A_Index]
		if !(ftemp = "NS" || ftemp = "FAILED" || ftemp = "TERM" || ftemp = "ENDED")
			{
				temp := 1
				Break
			}
		}

		if (temp)
		{
		GuiControl, PrgLnch:, RunBatchPrg, &Cancel Batch
		waitBreak := 0
		SetTimer, WatchSwitchOut, -1000
		}
		else
		if (PrgPID)
		{
		waitBreak := 0
		SetTimer, WatchSwitchOut, -1000
		}
		GuiControl, PrgLnch:, RunBatchPrg, &Run Batch
	}
	else
	{
		if (PrgPID)
		{
		waitBreak := 0
		SetTimer, WatchSwitchOut, -1000
		}
		else ;in case something else running
		{
			loop, % PrgNo
			{
				if (ProgPIDMast[A_Index])
				{
				waitBreak := 0
				SetTimer, WatchSwitchOut, -1000
				Break
				}
			}
		}
	}


Return

LnchPrgOff(PrgLnchIni, prgIndex, lnchStat, PrgPaths, currBatchno, lnchPrgStat, PrgCmdLine, iDevNumArray, dispMonNamesNo, WindowStyle, PrgBordless, PrgRnPriority, ByRef scrWidth, ByRef scrHeight, ByRef scrFreq, ByRef scrWidthDef, ByRef scrHeightDef, ByRef scrFreqDef, ByRef targMonitorNum, ByRef PrgPID, ByRef PrgListPID, ByRef PrgPos, ByRef PrgMinMax, ByRef PrgStyle, ByRef x, ByRef y, ByRef w, ByRef h, ByRef dx, ByRef dy, Fmode)
{
currMon := 0, temp := 0, fTemp := 0, ms := 0, md := 0, msw := 0, mdw := 0, msh := 0, mdh := 0, PrgPIDtmp := 0, PrgPrty := "N", mdRight := 0, mdLeft := 0, mdBottom := 0, mdTop := 0, msRight := 0, msLeft := 0, msBottom := 0, msTop := 0

if (DefResNoMatchRes(PrgLnchIni, Fmode, scrWidth, scrHeight, scrWidthDef, scrHeightDef) < 0)
Return "Cancelled by User!"


if (lnchPrgStat > 0) ;Running
{
	;Fix priority
	temp := (PrgRnPriority[lnchPrgStat])
	(!temp)? PrgPrty := "B": (temp = 1)? PrgPrty := "H": PrgPrty := "N"


	WorkingDirectory(1, PrgPaths)

	IfExist, % PrgPaths
	;If Notepad, copy Notepad exe to  %A_ScriptDir% and it will not run! (Windows 10 1607)
	{
	PrgPaths := PrgPaths . A_Space . PrgCmdLine[lnchPrgStat]

	currMon := GetPrgLnchMonNum(iDevNumArray, dispMonNamesNo)

	if !(currMon = targMonitorNum) && (targMonitorNum = 1)
	{
		IniRead, ftemp, %A_ScriptDir%`\%PrgLnchIni%, General, LnchPrgMonWarn
		if !(ftemp)
		{
		MsgBox, 8196, , PrgLnch was run from monitor %currMon% but the Prg`n is to run at default %targMonitorNum%. This may be intended.`n`nReply:`nYes: Continue (Warn like this next time)`nNo: Continue (This will not show again) `n
		IfMsgBox, No
		IniWrite, 1, %A_ScriptDir%`\%PrgLnchIni%, General, LnchPrgMonWarn
		}
	}

	if (targMonitorNum = currMon)
	{

	;WinHide ahk_class Shell_TrayWnd ;Necessary?

	if (scrWidth <= 1024)
		{
		IniRead, ftemp, %A_ScriptDir%`\%PrgLnchIni%, General, LoseGuiChangeResWrn
			if !(ftemp)
			{
			MsgBox, 8195, , It's possible the PrgLnch Gui can be positioned off the screen after `nswitching to low resolutions. Use <CTRL-Alt-P> to return it to focus.`n`nReply:`nYes: Continue (Warn like this next time)`nNo: Continue (This will not show again) `nCancel: Do nothing: `n
			IfMsgBox, No
			IniWrite, 1, %A_ScriptDir%`\%PrgLnchIni%, General, LnchPrgMonWarn
			else
			{
				IfMsgBox, Cancel
				Return "Cancelled by user!"
			}
			}
		}
		if (DefResNoMatchRes(PrgLnchIni, Fmode, scrWidth, scrHeight, scrWidthDef, scrHeightDef))
			{
			ChangeResolution(scrWidth, scrHeight, scrFreq, targMonitorNum)
			Sleep 1200
			}

	Run, % PrgPaths, , UseErrorLevel, PrgPIDtmp
	sleep, 120
		if (A_LastError)
		{

			;Add to PID list
			PrgPIDtmp := "TERM"
			FixPrgPIDStatus(currBatchno, prgIndex, lnchStat, PrgPIDtmp, PrgPID, PrgListPID)


			;WinShow ahk_class Shell_TrayWnd
			if (DefResNoMatchRes(PrgLnchIni, Fmode, scrWidth, scrHeight, scrWidthDef, scrHeightDef))
			{
			ChangeResolution(scrWidthDef, scrHeightDef, scrFreqDef, targMonitorNum) ;defaults for the monitor
			sleep, 1000
			scrWidth := scrWidthDef
			scrHeight := scrHeightDef
			scrFreq := scrFreqDef
			}
		return "Prg could not launch with error" %A_LastError%
		}
		else
		{
		Process, Priority, PrgPIDtmp, % PrgPrty
		;Add to PID list

		
		WinGetPos, x, y, w, h, % "ahk_pid" PrgPIDtmp
		; Possible the default window co-ords are in another monitor from a previous run here
		loop % dispMonNamesNo
		{
		SysGet, ms, MonitorWorkArea, % A_Index
		if (x >= msLeft && x <= msRight && y >= msTop && y <= msBottom)
			{
				if (A_Index = currMon)
				{
				Break
				}
				else
				{
					SysGet, md, MonitorWorkArea, % currMon
					mdw := mdRight - mdLeft, mdh := mdBottom - mdTop
					msw := msRight - msLeft, msh := msBottom - msTop

					; Calculate new size for new monitor.
					dx := mdLeft + (x-msLeft)*(mdw/msw)
					dy := mdTop + (y-msTop)*(mdh/msh)

					if (wp_IsResizable())
					{
					w := Round(w*(mdw/msw))
					h := Round(h*(mdh/msh))
					}

					; Move window, using resolution difference to scale co-ordinates.
					WinMove, ahk_pid%PrgPIDtmp%, , dx, dy, w, h

					;move mouse
					DllCall("SetCursorPos", int, dx + w/2, int, dy + h/2)
				}
			}
		}



		FixPrgPIDStatus(currBatchno, prgIndex, lnchStat, PrgPIDtmp, PrgPID, PrgListPID)
		Sleep 500

		if (PrgBordless[lnchPrgStat])
		BordlessProc(PrgPos, PrgMinMax, PrgStyle, 0, 0, scrWidth, scrHeight, PrgPIDtmp, WindowStyle)
		}	


	;WinShow ahk_class Shell_TrayWnd
	}
	else ; monitor other than current
	{

			if (DefResNoMatchRes(PrgLnchIni, Fmode, scrWidth, scrHeight, scrWidthDef, scrHeightDef))
			{
			ChangeResolution(scrWidth, scrHeight, scrFreq, targMonitorNum)
			Sleep 1200
			}
		Run, % PrgPaths, , UseErrorLevel, PrgPIDtmp

		sleep, 120
		if (A_LastError)
		{
		;Add to PID list
			PrgPIDtmp := "TERM"
			FixPrgPIDStatus(currBatchno, prgIndex, lnchStat, PrgPIDtmp, PrgPID, PrgListPID)
			
			if (DefResNoMatchRes(PrgLnchIni, Fmode, scrWidth, scrHeight, scrWidthDef, scrHeightDef))
			{
			ChangeResolution(scrWidthDef, scrHeightDef, scrFreqDef, targMonitorNum)
			sleep, 1000
			scrWidth := scrWidthDef
			scrHeight := scrHeightDef
			scrFreq := scrFreqDef
			}
			return "Prg could not launch with error" %A_LastError%
		}
		else
		{
			Process, Priority, PrgPIDtmp, % PrgPrty

			
			FixPrgPIDStatus(currBatchno, prgIndex, lnchStat, PrgPIDtmp, PrgPID, PrgListPID)
			Sleep 500

			WinGet, temp, MinMax, ahk_pid%PrgPIDtmp%
			if temp
			WinRestore, ahk_pid%PrgPIDtmp%

			WinGetPos, x, y, w, h, % "ahk_pid" PrgPIDtmp

			;change res, launch Prg, move window of Prg 
			; Get source and destination work areas (excludes taskbar-reserved space.)

			SysGet, md, MonitorWorkArea, % targMonitorNum


			; Possible the default window co-ords are in the other monitor from a previous run here
			if !(x >= mdLeft && x <= mdRight && y >= mdTop && y <= mdBottom)
				{
				SysGet, ms, MonitorWorkArea, % currMon
				msw := msRight - msLeft, msh := msBottom - msTop
				mdw := mdRight - mdLeft, mdh := mdBottom - mdTop


				; Calculate new size for new monitor.
				dx := mdLeft + (x-msLeft)*(mdw/msw)
				dy := mdTop + (y-msTop)*(mdh/msh)

				if (wp_IsResizable())
				{
				w := Round(w*(mdw/msw))
				h := Round(h*(mdh/msh))
				}

				; Move window, using resolution difference to scale co-ordinates.
				WinMove, ahk_pid%PrgPIDtmp%, , dx, dy, w, h

				;move mouse
				DllCall("SetCursorPos", int, dx + w/2, int, dy + h/2)
			}	
			if (PrgBordless[lnchPrgStat])
			BordlessProc(PrgPos, PrgMinMax, PrgStyle, dx, dy, scrWidth, scrHeight, PrgPIDtmp, WindowStyle)

			;Then we can Move window
			;WinGetPos,,, W, H, A
			;WinMove, A ,, mswLeft + (mswRight - mswLeft) // 2 - W // 2, mswTop + (mswBottom - mswTop) // 2 - H // 2

		}
	}
	;pillarboxing see https://msdn.microsoft.com/en-us/library/windows/desktop/bb530115(v=vs.85).aspx


	;showhide taskbar
	;WinHide ahk_class Shell_TrayWnd
	;WinShow ahk_class Shell_TrayWnd
	}
else
	{
		PrgPIDtmp := "TERM"
		FixPrgPIDStatus(currBatchno, prgIndex, lnchStat, PrgPIDtmp, PrgPID, PrgListPID)
		return "Unable to determine the location of `n" . PrgPaths
	}

;WinWaitClose What about suspended task?


}
else
{

	if (lnchPrgStat = 0) ;Just Change Res
	{
		GuiControlGet, targMonitorNum, PrgLnchOpt:, iDevNum

		if (DefResNoMatchRes(PrgLnchIni, Fmode, scrWidth, scrHeight, scrWidthDef, scrHeightDef))
		{
		ChangeResolution(scrWidth, scrHeight, scrFreq, targMonitorNum)
		sleep, 1200
		}
	}
	else ;Cancel Prg: Either this or Waitclose
	{

		;Get batch no
		if (lnchStat = -1)
		{
		PrgPIDtmp := PrgPID
		PrgPID := 0
		}
		else
		{
		sleep, 120
		PrgPIDtmp := PrgListPID[prgIndex]
		PrgListPID[prgIndex] := 0
		;do not set PrgPID to 0 as it may be running in the frontend.
		}

		if (PrgPIDtmp && !(PrgPIDtmp = "FAILED") && !(PrgPIDtmp = "NS") && !(PrgPIDtmp = "TERM") && !(PrgPIDtmp = "ENDED"))
		{
		temp := GetProcFromPath(PrgPaths)	
		Process, Exist, %PrgPIDtmp%
		if (ErrorLevel)
		{
			;gets here if exists
			Process, Priority, %PrgPIDtmp%, H
			;set script priority high
			Process, Priority, , H
			WinClose, ahk_pid %PrgPIDtmp%
			sleep 200
			;Try again
			Process, Exist, %PrgPIDtmp%
			if ErrorLevel
			{
				if !(PrgPIDtmp = "")
				{

				WinClose, ahk_pid %PrgPIDtmp%
				sleep, 200
				}

				if !(PrgPIDtmp = "")
				{
				MsgBox, 8193, , There was a problem closing a Prg. It may have `njust closed but can be force terminated just in case.`n`"%temp%`"
					IfMsgBox, OK
					KillPrg(PrgPIDtmp)
					else
					PrgPIDtmp := ""
				}
				;set script priority back
				Process, Priority, , % PrgPrty
			}
			; Don't care if  PrgPIDtmp != "" still
		}
		else
		{
			IniRead, ftemp, %A_ScriptDir%`\%PrgLnchIni%, General, ClosePrgWarn
			if !(ftemp)
			{
				MsgBox, 8196, , An attempt was made to close a Prg `nwhich has already terminated by itself.`n`"%temp%`"`n`nReply:`nYes: Continue (Warn like this next time)`nNo: Continue (This will not show again) `n
				IfMsgBox, Yes
				PrgPIDtmp := ""
				else
				IniWrite, 1, %A_ScriptDir%`\%PrgLnchIni%, General, ClosePrgWarn
			}

		}
		}
		;  else we assume it was invalid or cancelled via the timer

		PrgStyle := 0
		dx := 0
		dy:= 0

	}
}

Return 0
}

FixPrgPIDStatus(currBatchno, prgIndex, lnchStat, PrgPIDtmp, ByRef PrgPID, ByRef PrgListPID)
{
ftemp := 0
if (lnchStat = -1)
	{
		if (PrgPID = "TERM")
		PrgPID := 0
	}
	else
	{
		if (lnchStat = 1)
		{
		loop, % currBatchno
		{
		ftemp := PrgListPID[A_Index]
		if (ftemp = "NS" || ftemp = "FAILED" || ftemp = "TERM" || ftemp = "ENDED")
		{
			if !(ftemp = "TERM")
			{
			PrgListPID[A_Index] := PrgPIDtmp
			Break
			}
		}
		else
		{
		Process, Exist, % ftemp
		if !(ErrorLevel)
		PrgListPID[A_Index] := "ENDED"
		}

		}
		}
		else
		PrgListPID[prgIndex] := PrgPIDtmp
	}
}


WatchSwitchBack:

;Problem is, this only deals with switching to and from Prglnch ATM . Not other apps.
WinWaitActive, PrgLnch
IfWinActive, PrgLnch
{

		if ((prgSwitchIndex)? PrgChgResonSwitch[prgSwitchIndex]: PrgChgResonSwitch[selPrgChoice])
		{
		scrWidth := scrWidthDef
		scrHeight := scrHeightDef
		scrFreq := scrFreqDef
		targMonitorNum := (lnchStat < 0)? PrgMonToRn[selPrgChoice]: PrgMonToRn[prgSwitchIndex]
			if (PrgLnchMon = targMonitorNum)
			{
			ChangeResolution(scrWidthDef, scrHeightDef, scrFreqDef, PrgLnchMon)
			sleep, 1000
			}
		}
	SetTimer, WatchSwitchBack, Off
	SetTimer, WatchSwitchOut, -1000
}
Return

WatchSwitchOut:

	if (presetNoTest) ; in the Prglnch screen
	{
		x := 0
		if (batchActive)
		{
		temp := "|"	
			loop, % currBatchno
			{
			ftemp := PrgListPID%btchPrgPresetSel%[A_Index]
			if (ftemp = "TERM")
			{
			temp .= "Failed" . "|"
			PrgListPID%btchPrgPresetSel%[A_Index] := "Failed"
			}
			else
			{
			if (ftemp = "FAILED")
			temp .= "Failed" . "|"
			else
			{
			if (ftemp = "NS")
			temp .= "Not Started" . "|"
			else
			{
			if (ftemp)
				{
				Process, Exist, % ftemp
					if (ErrorLevel)
					{
					temp .= "Active" . "|"
					x := 1
					}
					else
					{
					PrgListPID%btchPrgPresetSel%[A_Index] := "ENDED"
					temp .= "Not Active" . "|"
					}

				}
				else
				temp .= "Not Active" . "|"		
			}
			}
			}
			}
			GuiControl, PrgLnch:, batchPrgStatus, %temp%
		}
		if (x)
		batchActive := 1
		else
		{
		batchActive := 0
		CleanupPID(PrgLnchIni, currBatchNo, PrgLnchMon, PrgMonToRn, PrgNo, ProgPIDMast, presetNoTest, batchActive, PrgListPID%btchPrgPresetSel%, PrgStyle, dx, dy, PrgLnchHide, PrgPID, selPrgChoice, Fmode, scrWidth, scrHeight, scrWidthDef, scrHeightDef, scrFreqDef)
		if !(PrgPID)
		Return
		}
	}
	else
	{
		if (PrgPID)
		{
			Process, Exist, %PrgPID%
			if !ErrorLevel
			{
			CleanupPID(PrgLnchIni, currBatchNo, PrgLnchMon, PrgMonToRn, PrgNo, ProgPIDMast, presetNoTest, batchActive, PrgListPID%btchPrgPresetSel%, PrgStyle, dx, dy, PrgLnchHide, PrgPID, selPrgChoice, Fmode, scrWidth, scrHeight, scrWidthDef, scrHeightDef, scrFreqDef)
			Return
			}
		}
	}


If (WinWaiter(PrgLnch))
{
	; check the PID of app. If it matches a Prg, use the index to retrieve the resolution

	ftemp := FindMatchingPID(lnchStat, currBatchNo, PrgListPID%btchPrgPresetSel%, PrgPID)

	if (ftemp)
	{
	(lnchStat < 0)? prgSwitchIndex := 0: prgSwitchIndex := PrgBatchIni%btchPrgPresetSel%[ftemp]
		if ((prgSwitchIndex)? PrgChgResonSwitch[prgSwitchIndex]: PrgChgResonSwitch[selPrgChoice])
		{
		scrWidth := (lnchStat < 0)? scrWidthArr[selPrgChoice]: scrWidthArr[prgSwitchIndex]
		scrHeight := (lnchStat < 0)? scrHeightArr[selPrgChoice]: scrHeightArr[prgSwitchIndex]
		scrFreq := (lnchStat < 0)? scrFreqArr[selPrgChoice]: scrFreqArr[prgSwitchIndex]
		targMonitorNum := (lnchStat < 0)? PrgMonToRn[selPrgChoice]: PrgMonToRn[prgSwitchIndex]
		if (DefResNoMatchRes(PrgLnchIni, Fmode, scrWidth, scrHeight, scrWidthDef, scrHeightDef) && (PrgLnchMon = targMonitorNum))
			{
			ChangeResolution(scrWidth, scrHeight, scrFreq, targMonitorNum)
			sleep, 1000
			}
		}
	}
	SetTimer, WatchSwitchOut, Off
	SetTimer, WatchSwitchBack, -1000

}

Return

WinWaiter(winText := "", timeOut:= 0)
{
global
; https://autohotkey.com/boards/viewtopic.php?f=5&t=29822
	(timeOut) && local t1 := A_TickCount

	Loop
	{

	Sleep -1

	} Until (!WinActive(winText) && local state := "inactive")

	|| (waitBreak && local state := "break")

	|| (t1 && A_TickCount-t1 >= timeOut && local state := "timeout")

	return state
}

CleanupPID(PrgLnchIni, currBatchNo, PrgLnchMon, PrgMonToRn, PrgNo, ProgPIDMast, presetNoTest, batchActive, ByRef PrgListPIDbtchPrgPresetSel, ByRef PrgStyle, ByRef dx, ByRef dy, PrgLnchHide, ByRef PrgPID := 0, selPrgChoice := 0, Fmode := 0, scrWidth := 0, scrHeight := 0, scrWidthDef := 0, scrHeightDef := 0, scrFreqDef := 0)
{
temp := 0, PrgStyle := 0, dx := 0, dy:= 0
WorkingDirectory(0, A_ScriptDir)
if (presetNoTest)
{
	Process, Exist, % PrgPID
	if (ErrorLevel)
	{
		if (!batchActive && !(PrgMonToRn[selPrgChoice] = PrgLnchMon))
		{
		SplashImage, Hide, A B,,,LnchSplash
		GuiControl, PrgLnch:, RunBatchPrg, &Run Batch
		;must zero array
		Loop, % currBatchNo
		{
		PrgListPIDbtchPrgPresetSel[A_Index] := 0
		}
		IniRead, temp, %A_ScriptDir%`\%PrgLnchIni%, General, PrgAlreadyLaunchedMsg
		sleep, 120
			if !temp
			{
				MsgBox, 8195, , Batch has completed but a Prg has been launched via Test Run.`nIt's possible the Batch Prgs used other monitors.`nDo you wish to change the resolution of the monitor`n PrgLnch was run from back to its default resolution now?`n`nReply:`nYes: Change resolution (Warn like this next time) `nNo: Change resolution (This will not show again) `nCancel: Do not change resolution (This will not show again)`n
				IfMsgBox, Cancel
				IniWrite, 2, %A_ScriptDir%`\%PrgLnchIni%, General, PrgAlreadyMsg
				else
				{
					if (DefResNoMatchRes(PrgLnchIni, Fmode, scrWidth, scrHeight, scrWidthDef, scrHeightDef))
					ChangeResolution(scrWidthDef, scrHeightDef, scrFreqDef, PrgLnchMon)
					IfMsgBox, No
					IniWrite, 1, %A_ScriptDir%`\%PrgLnchIni%, General, PrgAlreadyMsg
					sleep, 1000
				}
			}
			else
			{
				if (temp = 1)
				{
				if (DefResNoMatchRes(PrgLnchIni, Fmode, scrWidth, scrHeight, scrWidthDef, scrHeightDef))
				ChangeResolution(scrWidthDef, scrHeightDef, scrFreqDef, PrgLnchMon)
				sleep, 1000
				}
			}
		}
	}
	else
	{
	SetTimer, WatchSwitchBack, Delete
	SetTimer, WatchSwitchOut, Delete
	PrgPID := 0
	if (DefResNoMatchRes(PrgLnchIni, Fmode, scrWidth, scrHeight, scrWidthDef, scrHeightDef))
	ChangeResolution(scrWidthDef, scrHeightDef, scrFreqDef, PrgLnchMon)
	sleep, 1000
	}
	if !(batchActive)
	{
	Gui, PrgLnch: Show
	}
}
else
{
PrgPID := 0
HideShowTestRunCtrls(1)
GuiControl, PrgLnchOpt:, RnPrgLnch, &Test Run Prg

Loop, % PrgNo
{
	if (ProgPIDMast[A_Index])
	{
	temp := 1
	Break
	}
}
if !(temp)
	{
		if (PrgMonToRn[selPrgChoice] = PrgLnchMon)
		{
		if (DefResNoMatchRes(PrgLnchIni, Fmode, scrWidth, scrHeight, scrWidthDef, scrHeightDef))
		ChangeResolution(scrWidthDef, scrHeightDef, scrFreqDef, PrgLnchMon)
		sleep, 1000
		}
	SetTimer, WatchSwitchBack, Delete
	SetTimer, WatchSwitchOut, Delete
	}

if PrgLnchHide[selPrgChoice]
Gui, PrgLnchOpt: Show
}

}











































;More General file & process routines
FindMatchingPID(lnchStat, currBatchNo, PrgListPIDbtchPrgPresetSel, PrgPID)
{
	temp := 0

	WinGet, temp, PID, A

	if (lnchStat < 0)
	{
		if (temp = PrgPID)
		Return -1
	}
	else
	{
		loop, % currBatchNo
		{
			if (temp = PrgListPIDbtchPrgPresetSel[A_Index])
			Return A_Index
		}
	}
Return 0
}

KillPrg(poorPID)
{
ftemp := 0
Process, Close, ahk_pid %poorPID%
sleep, 200

if (poorPID)
	{
	WorkingDirectory(0, A_ScriptDir)
	if FileExist(taskkillPrg.bat)
		{
		FileDelete, taskkillPrg.bat
		sleep, 200
		}
	ftemp := "taskkill /pid "
	ftemp .= poorPID . " /f /t"
	FileAppend, %ftemp%, taskkillPrg.bat
	sleep, 200
	Run, taskkillPrg.bat,, Hide UseErrorLevel
	sleep, 200
	FileDelete, taskkillPrg.bat
	}
}

GetProcFromPath(ftemp)
{

retVal := SubStr(ftemp, InStr(ftemp, "\",, -1) + 1)
	if !(retVal)
		{
			MsgBox, 8192, , Invalid path! Cannot continue process check.
		}
Return retVal
}

ChkExistingProcess(selPrgChoice, currBatchNo, PrgBatchIni, PrgListIndex, PrgChoicePaths, btchPrgPresetSel := 0)
{
dupList := "", temp := 0, ftemp := 0

if (currBatchNo && !btchPrgPresetSel)
{
loop, % currBatchNo
	{
	temp := PrgBatchIni[A_Index]
	ftemp := PrgChoicePaths[temp]
	if !(ftemp := GetProcFromPath(ftemp))
	Return 0

		for process in ComObjGet("winmgmts:").ExecQuery("Select * from Win32_Process")
		{
			temp := ""
			if (ftemp = process.Name)
			{
			duplist .= temp . ftemp
			temp := ", "
			Break
			}
		}
	}
}
else
{
	if (btchPrgPresetSel)
	{
	temp := PrgBatchIni[selPrgChoice]
	ftemp := PrgChoicePaths[temp]
	}
	else
	ftemp := PrgChoicePaths[selPrgChoice]

	if !(ftemp := GetProcFromPath(ftemp))
	Return 0

	for process in ComObjGet("winmgmts:").ExecQuery("Select * from Win32_Process")
	{
		temp := ""
		if (ftemp = process.Name)
		{
		duplist .= temp . ftemp
		temp := ", "
		Break
		}
	}
}

Return duplist
}
GetPrgLnchMonNum(iDevNumArray, dispMonNamesNo, monitorHandle := 0)
{
	iDevNumb := 0, MONITOR_DEFAULTTONULL := 0
	VarSetCapacity(monitorInfo, 40)
	NumPut(40, monitorInfo)

	
	hWnd := PrgLnchOpt.Hwnd()
	If !hWnd
	{
	MsgBox, 8192, , % "Cannot get handle of Script! Error: " A_LastError
	Return -1
	}
	;winHandle := WinExist("A") ; LastWindow: The PrgLnch Window if clicked on
	
	loop %dispMonNamesNo%
	{
	if (iDevNumArray[A_Index] > 99 || iDevNumArray[A_Index] > 9)
	iDevNumb += 1
	}
	
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


		; GetMonitorIndexFromWindow(windowHandle)	

		Loop, %iDevNumb%
		{
			SysGet, mt, Monitor, %A_Index%

			; Compare location to determine the monitor index.
			if ((msLeft = mtLeft) and (msTop = mtTop)
				and (msRight = mtRight) and (msBottom = mtBottom))
			{
				msI := A_Index
				break
			}
		}

	}
if (msI)
return msI
else ; should never get here
MsgBox, 8192, , Cannot retrieve the Monitor for the current window!
return 1 ;hopefully this is the one!
}
IsPrgaLnk(ftemp)
{
	workDir := "", temp := 0
	; ATM PrgLnch does not modify the fields of the Wscript shortcut component in anyway.
	;http://superuser.com/questions/392061/how-to-make-a-shortcut-from-cmd
	temp := SubStr(fTemp, InStr(fTemp, ".") + 1)

	if (temp = "lnk")
	{
	FileGetShortcut, % fTemp , , workDir

	if !(workDir)
	workDir := "*"
	; dummy character- definitely not a valid path
	}
	return workDir
}
WorkingDirectory(noSet, fTemp)
{
	retVal := 0, temp := 0
		if noSet
		SetWorkingDir %A_ScriptDir% ; Caution: Working Dir can be altered by other processes
		else
		{
		temp := InStr(fTemp, "\", false, -1)
		temp := SubStr(fTemp, 1, temp)
		SetWorkingDir %temp%
		If (ErrorLevel) & (ftemp = A_ScriptDir)
		SetWorkingDir %A_WorkingDir%
		}
	If (ErrorLevel)
	{
	retVal := false
	MsgBox, 8192, , % "Cannot set working directory! Is " ftemp " accessible? `nError: " ErrorLevel
	}
	else
	{
	retVal := false
	}

if !noSet
SetWorkingDir %A_ScriptDir%
Return retVal
}

/*
===============================================================================
Function:   wp_IsResizable
    Determine if we should attempt to resize the last found window.
Returns:
    True or False
     
Author(s):
    Original - Lexikos - http://www.autohotkey.com/forum/topic21703.html
===============================================================================
*/
wp_IsResizable()
{
WinGetClass, Class
	if Class in Chrome_XPFrame,MozillaUIWindowClass,IEFrame,OpWindow
	return true
	WinGet, CurrStyle, Style
	return (CurrStyle & 0x40000) ; WS_SIZEBOX
}
BordlessProc(ByRef PrgPos, ByRef PrgMinMax, ByRef PrgStyle, dx, dy, scrWidth, scrHeight, PrgPID, WindowStyle)
{
; https://autohotkey.com/boards/viewtopic.php?p=123166#p123166
s:=0, PrgStyleTmp := 0, x:= 0, y:= 0, w := 0, h := 0
WinGet, S, Style, ahk_pid%PrgPID%

if (PrgStyle)
{
PrgStyleTmp := S & WindowStyle
}
else
{
PrgStyle := S & WindowStyle
PrgStyleTmp := PrgStyle
}


if (PrgStyleTmp) ;check flags not Borderless
{
; Store existing style
WinGet, IsMaxed, MinMax, ahk_pid%PrgPID%
; Get/store whether the window is maximized
if (PrgMinMax := IsMaxed = 1 ? true : false)
WinRestore, ahk_pid%PrgPID%
;move window to max perims
WinGetPos, x, y, w, h, ahk_pid%PrgPID%

PrgPos[1] := x, PrgPos[2] := y, PrgPos[3] := w, PrgPos[4] := h
; Remove borders
winSet, Style, % -windowStyle, ahk_pid%PrgPID%

WinMove, ahk_pid%PrgPID%, , dx, dy, scrWidth, scrHeight
}
else
{
; If borderless, reapply borders
WinSet, Style, % "+" PrgStyle, ahk_pid%PrgPID%

WinMove, ahk_pid%PrgPID%,, PrgPos[1], PrgPos[2], PrgPos[3], PrgPos[4]
; Return to original position & maximize if required
if (PrgMinMax)
WinMaximize, ahk_pid%PrgPID%
}
}






































;Monitor routines
GetDisplayData(PrgLnchMon, targMonitorNum, ByRef dispMonNamesNo := 0, ByRef iDevNumArray := 0, ByRef dispMonNames := 0, ByRef scrDPI := 0, ByRef scrWidth := 0, ByRef scrHeight := 0, ByRef scrInterlace := 0, ByRef scrFreq := 0, iMode := -2, iChange := 0)
{
Device_Mode := 0, iDevNumb = 0, retVal := 0, DM_Position := 0, devFlags := 0, devKey := 0, OffsetDWORD := 4 ; Defined above but not global fn
iLocDevNumArray := [0, 0, 0, 0, 0, 0, 0, 0, 0]
	
	if (iMode = -3)
	{


			if (A_IsUnicode)
			{
			offsetWordStr := 64
			OffsetLongStr := 256
			; Note Union in Devmode structure is either/or printer stuff screen stuff

			}
			else
			{
			offsetWordStr := 32
			OffsetLongStr := 128
			}



		; devFlags
		DISPLAY_DEVICE_ATTACHED_TO_DESKTOP := 0x00000001
		DISPLAY_DEVICE_PRIMARY_DEVICE:= 0x00000004
		DISPLAY_DEVICE_MIRRORING_DRIVER := 0x00000008
		DISPLAY_DEVICE_VGA_COMPATIBLE := 0x00000010
		; devKey:		Path to the device's registry key relative to HKEY_LOCAL_MACHINE.


		loop % dispMonNamesNo
		{
		
		cbDISPDEV := OffsetDWORD + OffsetDWORD + offsetWordStr + 3 * OffsetLongStr
		VarSetCapacity(DISPLAY_DEVICE, cbDISPDEV, 0)
		NumPut(cbDISPDEV, DISPLAY_DEVICE, 0) ; initialising cb (byte counts) or size member
		
		if !DllCall("EnumDisplayDevices", PTR,0, UInt,iDevNumb, PTR,&DISPLAY_DEVICE, UInt,0)
		{
		dispMonNamesNo := iDevNumb
		break
		}

		
		
		devFlags := NumGet(DISPLAY_DEVICE, OffsetDWORD + offsetWordStr + OffsetLongStr, UInt)
		devKey := StrGet(&DISPLAY_DEVICE + OffsetDWORD + OffsetDWORD + offsetWordStr + OffsetLongStr + OffsetLongStr, OffsetLongStr)
		
		If !(devFlags & DISPLAY_DEVICE_MIRRORING_DRIVER)
		{

		iDevNumb := iDevNumb + 1
		
			;How do we differentiate between ....
			If (devFlags & DISPLAY_DEVICE_PRIMARY_DEVICE)
				{
				If (devFlags & DISPLAY_DEVICE_ATTACHED_TO_DESKTOP)
					{
					iLocDevNumArray[iDevNumb] := iDevNumb + 110
					}
				else
				{
				iLocDevNumArray[iDevNumb] := iDevNumb + 100
				}	
				}
			else
				{
				If (devFlags & DISPLAY_DEVICE_ATTACHED_TO_DESKTOP)
					{
					iLocDevNumArray[iDevNumb] := iDevNumb + 10
					}
				else
					iLocDevNumArray[iDevNumb] := iDevNumb
				}
			
			if (!iDevNumArray[iDevNumb])
			iDevNumArray[iDevNumb] := iLocDevNumArray[iDevNumb]
			else
			{
			if !(iDevNumArray[iDevNumb] = iLocDevNumArray[iDevNumb])
			MsgBox, 8192, , "A configurational change in the monitor setup has been detected. This may affect how some Prgs run."
			}

			dispMonNames[iDevNumb] := StrGet(&DISPLAY_DEVICE + OffsetDWORD, offsetWordStr)

		}

		}
	
		


	}


	else
	{


		;dmDeviceName ; 5 words, 5 short, 17 Dwords, 2 longs (POINTL:="x,y")... 5 * 2 + 5 * 2 + 16 * 4  + 2 * 4 = 92 structure has TWO Unions
		if (A_IsUnicode)
		{
		OffsetdevMode := 2 * 32
		offsetWordStr := 64
		}
		else
		{
		OffsetdevMode := 32
		offsetWordStr := 32
		}
		;(A_PtrSize = 8)? 64bit := 1 : 64bit := 0 ; not required for DM
		
		cbdevMode := 92 + 32 + 32 + OffsetdevMode
		VarSetCapacity(Device_Mode, cbdevMode, 0)
		NumPut(cbdevMode, Device_Mode, OffsetDWORD + offsetWordStr, Ushort) ; initialise cbsize member

	if iChange
	{
	retVal := DllCall("EnumDisplaySettings", PTR,dispMonNames[targMonitorNum], UInt,iMode, PTR,&Device_Mode)
	}
	else ;current display device
	retVal := DllCall("EnumDisplaySettings", PTR,dispMonNames[PrgLnchMon], UInt,iMode, PTR,&Device_Mode)


	;NumGet(Device_Mode, 64bit*32 + 4 +OffsetdevMode/2,UShort) ;dmSize, (before the 2nd Tchar)
	;NumGet(Device_Mode, 64bit*32 + 6 +OffsetdevMode/2,UShort) ;dmDriverExtra
	;NumGet(Device_Mode, 64bit*32 + 8 + OffsetdevMode/2,UInt) ; dmFields,don't need these
	;scrdmPostionX:=NumGet(Device_Mode, 64bit*32 + 12 +OffsetdevMode/2,UInt) ;Union POINTL
	;scrdmPostionY:=NumGet(Device_Mode, 64bit*32 + 12 +OffsetdevMode/2,UInt) ;

	;The following settings are applicable to other monitors
	scrDPI:=NumGet(Device_Mode, 104+OffsetdevMode,UInt) ; colour depth (pel is pixel) or A_ScreenDPI
	scrWidth:=NumGet(Device_Mode, 108+OffsetdevMode,UInt) ; dmPelsWidth or A_ScreenWidth
	scrHeight:=NumGet(Device_Mode, 112+OffsetdevMode,UInt) ; dmPelsHeight or A_ScreenHeight
	scrInterlace:=NumGet(Device_Mode, 116+OffsetdevMode,UInt) ; DM_GRAYSCALE, DM_INTERLACED (non interlaced if not specified)
	scrFreq:=NumGet(Device_Mode, 120+OffsetdevMode,UInt) ; Do not change 
	;https://support.microsoft.com/en-au/kb/2006076
	if (scrFreq = 59)
	scrFreq := scrFreq + 1			

	;Do not touch 148 dmPanningWidth or 152 dmPanningHeight
	}
	Return retVal
}


ChangeResolution(scrWidth := 1920, scrHeight := 1080, scrFreq := 60, targMonitorNum := 1)
{
	local Device_Mode := 0, monName := 0, devFlags := 0 , CDSopt := 0, scrInterlace := 0, scrDPI := 32

	GuiControlGet Test, PrgLnchOpt:, Test
		If (Test)
		CDSopt := CDS_TEST
	GuiControlGet FMode, PrgLnchOpt:, FMode
		If (FMode)
		CDSopt := CDS_RESET
	GuiControlGet Tmp, PrgLnchOpt:, Tmp
		If (Tmp)
		CDSopt := CDS_FULLSCREEN

		if (A_IsUnicode)
		{
		cbSize := 220 ;  2 + 2 +  64
		offsetWord := 64
		VarSetCapacity(Device_Mode, cbSize, 0)
		NumPut(cbSize, Device_Mode, OffsetDWORD + 64, "Ushort")
		}
		else
		{
		cbSize := 156 ;  2 + 2 +  32
		offsetWord := 0
		VarSetCapacity(Device_Mode,cbSize,0)
		NumPut(cbSize, Device_Mode, OffsetDWORD + 32, "Ushort")
		}

		if (Rego)
		{
		ENUM_REGISTRY_SETTINGS := -2
		GetDisplayData(PrgLnchMon, targMonitorNum, dispMonNamesNo, , , scrDPI, , , scrInterlace, , ENUM_REGISTRY_SETTINGS, 1)
		}
		else
		{
		GetDisplayData(PrgLnchMon, targMonitorNum, dispMonNamesNo, , , scrDPI, , , scrInterlace, , -1, 1)
		}




	;The following values should never change, but just in case!
	;offsetWord of dmPosition = 44
	;offsetWord of dmDisplayOrientation = 52
	;offsetWord of dmDisplayFixedOutput = 56

	NumPut(scrDPI,Device_Mode,104+offsetWord, "UInt")
	NumPut(scrInterlace,Device_Mode,116+offsetWord, "UInt")
	NumPut(scrWidth,Device_Mode,108+offsetWord, "UInt") ; A_ScreenWidth
	NumPut(scrHeight,Device_Mode,112+offsetWord, "UInt") ; A_ScreenHeight
	NumPut(scrFreq,Device_Mode,120+offsetWord, "UInt") ;

	
	
	NumPut(0, Device_Mode,38+offsetWord/2, "Ushort") ;dmDriverExtra
	


	if (targMonitorNum > 1)
	{
	devFlags := 0x00000020		; DM_POSITION
				| 0x00080000	; DM_PELSWIDTH
				| 0x00100000	; DM_PELSHEIGHT
	;dmFields, a POINTL:="x,y" structure is a union of structs
	VarSetCapacity(DM_Position,8,0)
	Numput(mdLeft + 1,DM_Position, 0, "UInt")
	Numput(mdTop + 1,DM_Position, 4, "UInt")
	Numput(&DM_Position,Device_Mode,44+offsetWord/2)
	}
	else
	{
	devFlags := 0x00080000 | 0x00100000
	}
	NumPut(devFlags, Device_Mode,40+offsetWord/2, "UInt")
	;offsetWord of dmDisplayOrientation = 52
	;offsetWord of dmDisplayFixedOutput = 56

	

	
	monName := dispMonNames[targMonitorNum]

	;to change state CDS_UPDATEREGISTRY | CDS_NORESET then recall fn with NULL for all parms
	retVal := DllCall("ChangeDisplaySettingsEx", "Ptr",&monName, "Ptr",&Device_Mode, "Ptr",0, "UInt",CDSopt, "Ptr",0)
	Sleep 100


	;ChangeDisplaySettingsEx for all monitors (need EnumDisplayDevices)
	
	; for position of monitor (Primary at 0,0)

	;retVal = 0: Success
	if (retVal = 0)
	{
	If (Test)
	traytip, Resolution Test, "Resolution Test Succeeded!"
	}
	else
	{
	if (retVal = DISP_CHANGE_BADDUALVIEW) ;-6
	MsgBox, 8192, , "Change Settings Failed: (Windows XP & later) The settings change was unsuccessful because system is DualView capable."
	else
	{
		if (retVal = DISP_CHANGE_BADPARAM) ;-5
		MsgBox, 8192, , "Change Settings Failed: An invalid parameter was passed in. This can include an invalid flag or combination of flags."
		else
		{
		if (retVal = DISP_CHANGE_BADFLAGS) ;-4
		MsgBox, 8192, , "An invalid set of flags was passed in."
		else
		{
		if (retVal = DISP_CHANGE_NOTUPDATED) ;-3
		MsgBox, 8192, , "(Windows NT/2000/XP: Unable to write settings to the registry."
		else
		{
		if (retVal = DISP_CHANGE_BADMODE) ;-2
		MsgBox, 8192, , "The graphics mode is not supported."
		else
		{
		if (retVal = DISP_CHANGE_FAILED) ;-1
		MsgBox, 8192, , "The display driver failed the specified graphics mode."
		else
		if (retVal = DISP_CHANGE_RESTART) ;1
		MsgBox, 8192, , "The computer must be restarted in order for the graphics mode to work."
		}
		}
		}
		}

	}
	}

}





GetResList(PrgLnchMon, targMonitorNum, dispMonNamesNo, iDevNumArray, dispMonNames, ByRef ResArray, ByRef scrWidthDef, ByRef scrHeightDef, ByRef scrFreqDef, allModes:= 0, iMode := 0)
{
ResList := "", Strng := ""
iModeval := iMode, iModeCt := 0, ENUM_CURRENT_SETTINGS := -1
scrWidth := 0, scrHeight := 0, scrDPI := 0, scrInterlace := 0, scrFreq := 0
scrWidthlast := 0, scrHeightlast := 0, scrDPIlast := 0, scrInterlacelast := 0, scrFreqlast := 0

	while GetDisplayData(PrgLnchMon, targMonitorNum, dispMonNamesNo, iDevNumArray, dispMonNames, scrDPI, scrWidth, scrHeight, scrInterlace, scrFreq, iModeval)
	{
	;imode = 0 caches the data for EnumSettings

		
		if (scrWidthlast = scrWidth)
		{
			;many iModes here are equivalent for the above params. scrFreq may vary for a subset of those
			if  (allModes && !(scrFreqlast = scrFreq))
			{
			iModeCt += 1
			Strng := scrWidth . " `, " . scrHeight . " @ " . scrFreq . "Hz |"
			ResArray[iModeCt, 1] := scrWidth
			ResArray[iModeCt, 2] := scrHeight
			ResArray[iModeCt, 3] := scrFreq
			if (iMode = ENUM_CURRENT_SETTINGS)
				{

				scrWidthDef := scrWidth
				scrHeightDef := scrHeight
				scrFreqDef := scrFreq
				Return Strng
				}
				else
				{
				ResList .= Strng
				}
			}
		}
		else
		{
		iModeCt += 1
		scrWidthlast := scrWidth
		scrHeightlast := scrHeight
		scrDPIlast := scrDPI
		scrInterlacelast := scrInterlace
		scrFreqlast := scrFreq
		
		;https://autohotkey.com/boards/viewtopic.php?f=5&t=23021&p=108567#p108567
		Strng := scrWidth . " `, " . scrHeight . " @ " . scrFreq "Hz |"
			ResArray[iModeCt, 1] := scrWidth
			ResArray[iModeCt, 2] := scrHeight
			ResArray[iModeCt, 3] := scrFreq
			if (iMode = ENUM_CURRENT_SETTINGS)
			{
				scrWidthDef := scrWidth
				scrHeightDef := scrHeight
				scrFreqDef := scrFreq		
				Return Strng
			}
			else
			{
			ResList .= Strng
			}
		}
		iModeval += 1
	}
Return ResList
}
DefResNoMatchRes(PrgLnchIni, Fmode, scrWidth, scrHeight, scrWidthDef, scrHeightDef)
{
defResmsg := 0

if (scrWidth=scrWidthDef && scrHeight=scrHeightDef)
{
if (Fmode) ;always change
Return 1

IniRead, defResmsg, %A_ScriptDir%`\%PrgLnchIni%, General, DefResmsg
	if (defResmsg)
	{
		if (defResmsg = 1)
		Return 0
		else
		Return 1
	}
	else
	{
	MsgBox, 8195, Resolution Change, The resolution on the target monitor is the same as the current resolution. `n(It's automatic if "Change at every mode" in "Res Options" is selected) `n`nReply:`nYes: Change resolution (This will not show again)`nNo: Do not change resolution: (Recommended: This will not show again) `n `nCancel: Do nothing: `n
	;note msgbox isn't modal if called from function
		IfMsgBox, No
		{
		IniWrite, 1, %A_ScriptDir%`\%PrgLnchIni%, General, defResmsg
		Return 0
		}
		else
		{
			ifMsgBox, Yes
			{
			IniWrite, 2, %A_ScriptDir%`\%PrgLnchIni%, General, defResmsg
			Return 1
			}
			else
			Return -1
		}
	}
}
else
Return 1
}















































UpdtPrg:
GuiEscape:
Gui, PrgLnchOpt: +OwnDialogs
Gui, PrgLnchOpt: Submit, Nohide
GuiControlGet, temp, PrgLnchOpt: FocusV

;If !(A_IsCritical)
;Critical

if !(temp = "UpdtPrgLnch")
GoSub PrgLnchGuiClose


Tooltip
GuiControlGet temp, PrgLnchOpt:, % A_GuiControl


If (temp="&Update Prg")
	{
	SetTimer, NewThreadforDownload, 200
	Return
	}
else ;interrupted download but wish to continue
{

if (!updateStatus)
	{
	MsgBox, 8193, , Cancel the download?, 5  ; 5-second timeout
		IfMsgBox, OK
		{
			updateStatus := -1
			Return
		}
		IfMsgBox, Timeout
		{
			updateStatus := -1
			Return	; i.e. Assume "OK" if it timed out
		}
	; Otherwise, continue:
	}
}
Return


NewThreadforDownload: ;Timer!
	HideShowCtrls(1)
	GuiControl, PrgLnchOpt: , UpdtPrgLnch, &Cancel (Esc)
	
	;In most cases only the file names in the url will want encoding-else only spaces in folders or user names
	;https://github.com/ahkscript/libcrypt.ahk/blob/master/src/URI.ahk
	;https://tools.ietf.org/html/rfc3986
	;We don't know if the URL works, but write it to ini anyway
	IniProc(scrWidth, scrHeight, scrFreq, selPrgChoice)




	fTemp := PrgUrl[selPrgChoice]
	fTemp := SubStr(fTemp, InStr(fTemp, "/",, -1) + 1)


	if (InStr(PrgUrl[selPrgChoice], "%"))
	DownloadFile(LC_UrlDecode(PrgUrl[selPrgChoice]), fTemp, updateStatus)
	else
	DownloadFile(LC_UrlEncode(PrgUrl[selPrgChoice]), fTemp, updateStatus)


		if (updateStatus < 0)
		{
			if (updateStatus = -1)
			{
			Sleep, 100 ;Do events
			FileDelete, % fTemp
			If (ErrorLevel) ;Try once more
				{
				Sleep, 100
					Try
					{
					FileDelete, % fTemp
					}
					catch retVal
					{
					MsgBox, 8208, File Download, Error deleting (broken) file! `nSpecifically: %retVal%
					}
				}
			}
		}
		else
		{

		Runwait, % fTemp, , Max UseErrorLevel ; might be a self extracting package
		if ErrorLevel
		MsgBox, 8192, , The file could not be launched with error %ErrorLevel%
		}
	;Critical, Off
	HideShowCtrls()
	GuiControl, PrgLnchOpt: , UpdtPrgLnch, &Update Prg
	updateStatus := 1
	SetTimer, NewThreadforDownload, Off
Return



;http://www.codeproject.com/Article.aspx?tag=198374993737746150&_z=11114232
DownloadFile(UrlToFile, SaveFileAs, ByRef updateStatus)
{
	X :=0, Y:=0, temp:=0, timedOut := False, progWid := PrgLnchOpt.Width()/3, progHght := PrgLnchOpt.Height()/2
	;Check if the file already exists and if we must not overwrite it

	If (updateStatus > 0)
		{
		FileSelectFile, temp, S 19, % SaveFileAs , % "Save as " SaveFileAs
			if (!temp)
			{
			updateStatus := -2
			Gui, PrgLnchOpt: -OwnDialogs
			Return
			}
			else
			updateStatus := 0
			SaveFileAs := temp
			Gui, PrgLnchOpt: -OwnDialogs
		}
	
	;Check if the user wants a progressbar
	;Initialize the WinHttpRequest Object
	WebRequest := ComObjCreate("WinHttp.WinHttpRequest.5.1")
	;Download the headers
	WebRequest.Open("HEAD", UrlToFile, true)
	WebRequest.Send()
	WebRequest.WaitForResponse()
	;Store the header which holds the file size in a variable:
	FinalSize := WebRequest.GetResponseHeader("Content-Length")
	;Create the progressbar and the timer
	GuiControl, PrgLnchOpt: , UpdtPrgLnch, Preparing...
	Sleep, 2000 ;timeout: 2 seconds (should not time out)
	ComObjError(False)
	WinHttpReq.Status
	If (A_LastError) ;if WinHttpReq.Status was not set (no response received yet)
    timedOut := True
	ComObjError(True)
	
	GuiControl, PrgLnchOpt: , UpdtPrgLnch, &Update Prg
	If (timedOut)
	MsgBox, 8192, , Timed out
    
	
	Progress, Hide ,, Downloading...
	WinGet, Hwnd, ID,,, Downloading...
	SysGet, X, 45 ;Progress bar border B1 corresponds with SM_CXEDGE?
	SysGet, Y, 4 ;Height of a caption area?
	
	X := PrgLnchOpt.X() - progWid - (2 * X)
	Y := PrgLnchOpt.Y() + PrgLnchOpt.Height() - progHght - (2 * Y)
	
	if (X < 0) ;form was moved to the left
	X := PrgLnchOpt.X() + PrgLnchOpt.Width()



	Progress, X%X% Y%Y% H%progHght% W%progWid% M,, Downloading..., %UrlToFile%
	Progress Show

	
	SetTimer, __UpdateProgressBar, 200
	
	;Download the file
	try
	{
	UrlDownloadToFile, %UrlToFile%, %SaveFileAs%
	}
	catch e
	{
	msgbox, 8208, FileDownload, Error with the download!`nSpecifically: %e%
	PercentDone = 100
	updateStatus := -1
	Progress, Off
	SetTimer, __UpdateProgressBar, Delete
	Return
	}
	;Remove the timer and the progressbar because the download has finished
	Progress, Off
	SetTimer, __UpdateProgressBar, Delete
	Return



	;TIMER HERE:	The label that updates the progressbar
	__UpdateProgressBar:
	if (updateStatus = -1)
	{
	PercentDone := 100
	}
	else
	{
	;Get the current filesize and tick
	CurrentSize := FileOpen(SaveFileAs, "r").Length ;FileGetSize wouldn't Return reliable results
	CurrentSizeTick := A_TickCount
	;Calculate the downloadspeed
	Speed := Round((CurrentSize/1024-LastSize/1024)/((CurrentSizeTick-LastSizeTick)/1000)) . " kB/s"
	;Save the current filesize and tick for the next time
	LastSizeTick := CurrentSizeTick
	LastSize := FileOpen(SaveFileAs, "r").Length
	;Calculate percent done
	PercentDone := Round(CurrentSize/FinalSize*100)
	}
	;Update the ProgressBar
	Progress, %PercentDone%, %PercentDone%`% Done, Downloading...  (%Speed%), Downloading %SaveFileAs% (%PercentDone%`%)
	Return
}


; Modified by GeekDude from http://goo.gl/0a0iJq
LC_UrlEncode(Url)
{ ; keep ":/;?@,&=+$#."
	Return LC_UriEncode(Url, "[0-9a-zA-Z:/;?@,&=+$#.]")
}
LC_UriEncode(Uri, RE="[0-9A-Za-z]")
{

	VarSetCapacity(Var, StrPut(Uri, "UTF-8"), 0), StrPut(Uri, &Var, "UTF-8")

	While Code := NumGet(Var, A_Index - 1, "UChar")

		Res .= (Chr:=Chr(Code)) ~= RE ? Chr : Format("%{:02X}", Code)

	Return, Res
}
LC_UrlDecode(url)
{
	Return LC_UriDecode(url)
}
LC_UriDecode(Uri)
{

	Pos := 1

	While Pos := RegExMatch(Uri, "i)(%[\da-f]{2})+", Code, Pos)

	{
		VarSetCapacity(Var, StrLen(Code) // 3, 0), Code := SubStr(Code,2)

		Loop, Parse, Code, `%

		NumPut("0x" A_LoopField, Var, A_Index-1, "UChar")

		Decoded := StrGet(&Var, "UTF-8")

		Uri := SubStr(Uri, 1, Pos-1) . Decoded . SubStr(Uri, Pos+StrLen(Code)+1)

		Pos += StrLen(Decoded)+1

	}
	Return, Uri
}
GetPrgVersion(ByRef currPrgUrl, ByRef PrgVer := 0)
{
err := 0
; Example: Make an asynchronous HTTP request.
req := ComObjCreate("WinHttp.WinHttpRequest.5.1")
; Open a request with async enabled.

foundPos := InStr(currPrgUrl, "/", false, -1)
verLoc := SubStr(currPrgUrl, 1, foundPos)
verLoctmp := verLoc
verLoc .= "version.txt"

req.SetTimeouts(1000,1000,1000,1000)
	try
	{
	if (InStr(verLoc, "%"))
	req.Open("GET", LC_UrlDecode(verLoc), true)
	else
	req.Open("GET", LC_UrlEncode(verLoc), true)
	req.Send()
	req.WaitForResponse()
	PrgVer := req.ResponseText
	;version is never going to exceed 1000 bytes, so Returns junk if version.txt not found
	if (!PrgVer || StrLen(PrgVer)>1000)
	{
	MsgBox, 4112,, % "version.txt not at " verLoctmp
	Return 1
	}
	}
	Catch err ;http://stackoverflow.com/questions/32616959/winhttprequest-timeouts
	{
		For eachKey, Line in StrSplit(err.Message, "`n", "`r")
		{
		Results := InStr(Line, "Description:") ? StrReplace(Line, "Description:") : ""
		Results := Trim(Results)
		If (Results <> "")
		Break
		}
	MsgBox, 8198,, %Results% and version.txt not found at `n%verLoctmp%`n If no URL displayed, it's a timing issue or a temporary error.
	Return 1
	}
	Return 0
}


DoLAAPatch(targExe)
{
e_lfanew := 0, e_magic := 0, ntHeaders32 := 0, temp := 0

IMAGE_DOS_SIGNATURE_BIG_ENDIAN := 0x4D5A
IMAGE_DOS_SIGNATURE := 0x5A4D ; first 2 bytes 23117
IMAGE_NT_HEADERS32 := 0x4550 ;17744: Not interested in IMAGE_NT_HEADERS64
IMAGE_SIZEOF_FILE_HEADER := 20
PE_HEADER_OFFSET_ADDRESS := 0X3C ; 60
CHARACTERISTICS_OFFSET := 0X12 ;18 


IMAGE_FILE_RELOCS_STRIPPED := 0x0001 ;basing
IMAGE_FILE_EXECUTABLE_IMAGE := 0x0002
IMAGE_FILE_LINE_NUMS_STRIPPED := 0x0004
IMAGE_FILE_LOCAL_SYMS_STRIPPED := 0x0008
IMAGE_FILE_AGGRESIVE_WS_TRIM := 0x0010 ;obsolete
IMAGE_FILE_LARGE_ADDRESS_AWARE := 0x0020
IMAGE_FILE_16BIT_MACHINE := 0x0040 ; reserved
IMAGE_FILE_BYTES_REVERSED_LO := 0x0080 ;obsolete
IMAGE_FILE_32BIT_MACHINE := 0x0100
IMAGE_FILE_DEBUG_STRIPPED := 0x0200
IMAGE_FILE_REMOVABLE_RUN_FROM_SWAP := 0x0400
IMAGE_FILE_NET_RUN_FROM_SWAP := 0x0800
IMAGE_FILE_SYSTEM := 0x1000
IMAGE_FILE_DLL := 0x2000
IMAGE_FILE_UP_SYSTEM_ONLY := 0x4000 ; What's an UP machine?
IMAGE_FILE_BYTES_REVERSED_HI := 0x8000 ;obsolete


exeStr := FileOpen(targExe, "rw" "-rwd")

if IsObject(exeStr)
{

; Verify EXE signature or "MZ"
e_magic := SeekProc(exeStr, 0, "ushort", 0)

if (e_magic = IMAGE_DOS_SIGNATURE)
	{
	; Next is the stub "This program cannot be run in DOS mode." This takes us up to offset PE_HEADER_OFFSET
	; Get offset to pointer of IMAGE_NT_HEADERS struct: This is okay for either 32 or 64bit builds
	e_lfanew := SeekProc(exeStr, PE_HEADER_OFFSET_ADDRESS, "int", 0)
	; Verify NT header:
	ntHeaders32 := SeekProc(exeStr, e_lfanew, "uint", 0)
		if (ntHeaders32 = IMAGE_NT_HEADERS32)
		{
		; LAA offset is e_lfanew + 0x12 or 18
		lAA := SeekProc(exeStr, e_lfanew + CHARACTERISTICS_OFFSET + 4, "ushort", "check")



			GuiControlGet, labPrgLAA, PrgLnchOpt:, PrgLAA

			if (labPrgLAA = "Remove LAA Flag")
			{
			;Toggle flag off
			lAA := lAA & ~IMAGE_FILE_LARGE_ADDRESS_AWARE

			if (SeekProc(exeStr, e_lfanew + CHARACTERISTICS_OFFSET + 4, "ushort", lAA))
				{
				MsgBox, 8192, , % "LAA Flag Removed"
				GuiControl, PrgLnchOpt:, PrgLAA, Apply LAA Flag
				}
			else
				MsgBox, 8192, , % "Unable to remove LAA Flag. Is Prg opened in an editor?"
			}
			else
			{

			;lAA := lAA | IMAGE_FILE_LARGE_ADDRESS_AWARE
			
			if (lAA & IMAGE_FILE_LARGE_ADDRESS_AWARE)
			MsgBox, 8192, , %  "Prg already has the LAA patch!"
			else
			{
			; check at least one of the flags exist
			if (lAA & IMAGE_FILE_RELOCS_STRIPPED) || (lAA & IMAGE_FILE_EXECUTABLE_IMAGE) || (lAA & IMAGE_FILE_LINE_NUMS_STRIPPED) || (lAA & IMAGE_FILE_LOCAL_SYMS_STRIPPED) || (lAA & IMAGE_FILE_AGGRESIVE_WS_TRIM) || (lAA & IMAGE_FILE_16BIT_MACHINE) || (lAA & IMAGE_FILE_BYTES_REVERSED_LO) || (lAA & MAGE_FILE_32BIT_MACHINE) || (lAA & IMAGE_FILE_DEBUG_STRIPPED) || (lAA & IMAGE_FILE_REMOVABLE_RUN_FROM_SWAP) || (lAA & IMAGE_FILE_NET_RUN_FROM_SWAP) || (lAA & IMAGE_FILE_SYSTEM) || (lAA & IMAGE_FILE_DLL) || (lAA & IMAGE_FILE_UP_SYSTEM_ONLY) || (lAA & IMAGE_FILE_BYTES_REVERSED_HI)
			{
			lAA := lAA ^ IMAGE_FILE_LARGE_ADDRESS_AWARE

			;Toggle flag off
			;lAA := lAA & ~IMAGE_FILE_LARGE_ADDRESS_AWARE

			if (SeekProc(exeStr, e_lfanew + CHARACTERISTICS_OFFSET + 4, "ushort", lAA))
				{
				MsgBox, 8192, , % "LAA Flag Written"
				GuiControl, PrgLnchOpt:, PrgLAA, Remove LAA Flag
				}
			else
				MsgBox, 8192, , % "Unable to write LAA Flag. Is Prg opened in an editor?"
			}
			else
			MsgBox, 8192, , %  "Unexpected data in Characteristics field. LAA flag cannot not be written!"
			}
			}

		}
		else
		{
		MsgBox, 8192, , %  "Bad exe file: no NT Headers"
		}

	}
	else
	{
		if (e_magic == IMAGE_DOS_SIGNATURE_BIG_ENDIAN)
		MsgBox, 8192, , %  "No can do! This executable runs on a Big_Endian system!"
		else
		{
		MsgBox, 8192, , %  "Bad exe file: no DOS sig."
		;creates empty file if non-existent
		exeStr.Close()
		FileGetSize temp, %targExe%
		if !(temp)
		FileDelete, %targExe%
		Return
		}
	}
	exeStr.Close()
}
else
{
MsgBox, 8192, , %  "Could not open the Prg executable! Error: " A_LastError
}
}
; SeekProc: Seek to absolute offset and read a number of the specified type.
SeekProc(stream, offset, type, action)
{
retval := 0
stream.Seek(offset)
VarSetCapacity(v,8)

if (action == "check")
{
	retVal := stream.ReadShort()
	return retVal
}
else
{
	/*
	; We could possibly swap Big_Endian in a new pass:
	SwapEndian(ByRef Var, Bytes)
	{
	VarSetCapacity(BE, 8, 0)
	loop,% Bytes
	{
		NumPut(NumGet(Var, Bytes-A_Index, "Uint"), BE, A_Index-1, "Uint")
	}
	return NumGet(BE, "Uint")
	}
	*/
	if (action)
	{
	bytesToProcess := NumPut(action,v,0,type) - &v ;Numput returns the address to the "right" of  item just written
	return stream.RawWrite(v, bytesToProcess)
	}

	else
	{


	bytesToProcess := NumPut(0,v,0,type) - &v ;Numput returns the address to the "right" of  item just written
	bytesRead := stream.RawRead(v, bytesToProcess)
	;if !(DllCall("ReadFile", "uint", stream, "uint", &v, "uint", bytesToProcess, "uint*", bytesRead, "uint", 0) && bytesRead == bytesToProcess)
	if (v)
	{
	MsgBox, 8192, , % " Read failed"
	return 0
	}
	else
	{
	return NumGet(v, 0, type)

	}
	}
}
}


WinMover(Hwnd, position, Width:=0, Height:=0)
{
	x:= 0, y := 0, w := 0, h:= 0
	if (Width)
	WinMove, ahk_id %Hwnd%,,,, Width, Height
	;by Learning one
	; position: l=left, hc=horizontal center, r=right, u=up, vc= vertical center, d=down, b=bottom (same as down)
	SysGet, Mon, MonitorWorkArea
	oldDHW := A_DetectHiddenWindows
	DetectHiddenWindows, On
	WinGetPos,ix,iy,w,h, ahk_id %Hwnd%
	StringReplace,position,position,b,d,all ;b=bottom (same as down)
	x := InStr(position,"l") ? MonLeft : InStr(position,"hc") ?  (MonRight-w)/2 : InStr(position,"r") ? MonRight - w : ix
	y := InStr(position,"u") ? MonTop : InStr(position,"vc") ?  (MonBottom-h)/2 : InStr(position,"d") ? MonBottom - h : iy

	WinMove, ahk_id %Hwnd%,,x,y
	DetectHiddenWindows, %oldDHW%
}

DisableVariousResCtrls()
{	
	GuiControl, PrgLnchOpt: Disable, CmdLinPrm
	GuiControl, PrgLnchOpt:, CmdLinPrm
	GuiControl, PrgLnchOpt: Disable, UpdtPrgLnch
	GuiControl, PrgLnchOpt:, UpdturlPrgLnch
	GuiControl, PrgLnchOpt: +ReadOnly, UpdturlPrgLnch
	GuiControl, PrgLnchOpt:, newVerPrg
	GuiControl, PrgLnchOpt:, PrgLnchHd, 0
	GuiControl, PrgLnchOpt: Disable ,PrgLnchHd
	GuiControl, PrgLnchOpt:, Bordless, 0
	GuiControl, PrgLnchOpt: Disable, Bordless
	GuiControl, PrgLnchOpt:, PrgPriority, -1				
	GuiControl, PrgLnchOpt: Disable, PrgPriority
	GuiControl, PrgLnchOpt:, ChgResonSwitch, 0
	GuiControl, PrgLnchOpt: Disable, ChgResonSwitch
	GuiControl, PrgLnchOpt: Disable, PrgLAA
}

HideShowTestRunCtrls(ByRef show := 0)
{
if (show)
{
	GuiControl, PrgLnchOpt: Show, Allmodes
	GuiControl, PrgLnchOpt: Show, ResIndex
	GuiControl, PrgLnchOpt: Show, iDevNum
	GuiControl, PrgLnchOpt: Show, MkShortcut
	GuiControl, PrgLnchOpt: Show, UpdturlPrgLnch
	GuiControl, PrgLnchOpt: Show, PrgLAA
	GuiControl, PrgLnchOpt: Show, PrgLnchHd
	GuiControl, PrgLnchOpt: Show, PrgChoice

}
else
{
	GuiControl, PrgLnchOpt: Hide, Allmodes
	GuiControl, PrgLnchOpt: Hide, iDevNum
	GuiControl, PrgLnchOpt: Hide, ResIndex
	GuiControl, PrgLnchOpt: Hide, MkShortcut
	GuiControl, PrgLnchOpt: Hide, UpdturlPrgLnch
	GuiControl, PrgLnchOpt: Hide, PrgLAA
	GuiControl, PrgLnchOpt: Hide, PrgLnchHd
	GuiControl, PrgLnchOpt: Hide, PrgChoice
}
}
HideShowCtrls(ByRef show := 0)
{
if (show)
{

GuiControl, PrgLnchOpt: Hide, PrgChoice

GuiControl, PrgLnchOpt: Hide, Make Shortcut
GuiControl, PrgLnchOpt: Hide, Change Shortcut

GuiControl, PrgLnchOpt: Hide, DefaultPrg
GuiControl, PrgLnchOpt: Hide, Monitors
GuiControl, PrgLnchOpt: Hide, iDevNum
GuiControl, PrgLnchOpt: Hide, Test
GuiControl, PrgLnchOpt: Hide, FMode
GuiControl, PrgLnchOpt: Hide, Dynamic
GuiControl, PrgLnchOpt: Hide, Tmp
GuiControl, PrgLnchOpt: Hide, Rego
GuiControl, PrgLnchOpt: Hide, allModes
GuiControl, PrgLnchOpt: Hide, ResIndex
GuiControl, PrgLnchOpt: Hide, RnPrgLnch
GuiControl, PrgLnchOpt: Hide, CmdLinPrm
GuiControl, PrgLnchOpt: Hide, UpdturlPrgLnch
GuiControl, PrgLnchOpt: Hide, Quit_PrgLnch
GuiControl, PrgLnchOpt: Hide, PrgLnchHd
GuiControl, PrgLnchOpt: Hide, Bordless
GuiControl, PrgLnchOpt: Hide, PrgPriority
GuiControl, PrgLnchOpt: Hide, ChgResonSwitch
GuiControl, PrgLnchOpt: Hide, PrgCanBeShortct
GuiControl, PrgLnchOpt: Hide, PrgLAA
}
else
{
GuiControl, PrgLnchOpt: Show, PrgChoice

GuiControl, PrgLnchOpt: Show, Make Shortcut
GuiControl, PrgLnchOpt: Show, Change Shortcut

GuiControl, PrgLnchOpt: Show, DefaultPrg
GuiControl, PrgLnchOpt: Show, Monitors
GuiControl, PrgLnchOpt: Show, iDevNum
GuiControl, PrgLnchOpt: Show, Test
GuiControl, PrgLnchOpt: Show, FMode
GuiControl, PrgLnchOpt: Show, Dynamic
GuiControl, PrgLnchOpt: Show, Tmp
GuiControl, PrgLnchOpt: Show, Rego
GuiControl, PrgLnchOpt: Show, allModes
GuiControl, PrgLnchOpt: Show, ResIndex
GuiControl, PrgLnchOpt: Show, RnPrgLnch
GuiControl, PrgLnchOpt: Show, CmdLinPrm
GuiControl, PrgLnchOpt: Show, UpdturlPrgLnch
GuiControl, PrgLnchOpt: Show, Quit_PrgLnch
GuiControl, PrgLnchOpt: Show, PrgLnchHd
GuiControl, PrgLnchOpt: Show, Bordless
GuiControl, PrgLnchOpt: show, PrgPriority
GuiControl, PrgLnchOpt: show, ChgResonSwitch
GuiControl, PrgLnchOpt: Show, PrgCanBeShortct
GuiControl, PrgLnchOpt: Show, PrgLAA

}

}



IniProc(ByRef scrWidth := 1920, ByRef scrHeight := 1080, ByRef scrFreq := 60, selPrgChoice := 0, removeRec := 0)
{

IniProcStart:

Local foundPosOld := 0, recCount := -1, sectCount := 0, c := 0, p := 0, s := 0, k := 0, spr := 0

; local implies golbal function
if !FileExist(PrgLnchIni)
	{
	IniWrite, %A_Space%, %A_ScriptDir%`\%PrgLnchIni%, General, Disclaimer
	IniWrite, %A_Space%, %A_ScriptDir%`\%PrgLnchIni%, General, DefResmsg
	IniWrite, %A_Space%, %A_ScriptDir%`\%PrgLnchIni%, General, TermPrgMsg
	IniWrite, %A_Space%, %A_ScriptDir%`\%PrgLnchIni%, General, PrgAlreadyMsg
	IniWrite, %A_Space%, %A_ScriptDir%`\%PrgLnchIni%, General, ClosePrgWarn
	IniWrite, %A_Space%, %A_ScriptDir%`\%PrgLnchIni%, General, ResClashMsg
	IniWrite, %A_Space%, %A_ScriptDir%`\%PrgLnchIni%, General, LnchPrgMonWarn
	IniWrite, %A_Space%, %A_ScriptDir%`\%PrgLnchIni%, General, LoseGuiChangeResWrn
	IniWrite, %A_Space%, %A_ScriptDir%`\%PrgLnchIni%, General, PrgAlreadyLaunchedMsg

	; %A_ScriptDir%`\%PrgLnchIni% as long as the current directory isn't changed while this loads
	spr := "0,0,0,1"
	IniWrite, %spr%, %PrgLnchIni%, General, ResMode
	IniWrite, %A_Space%, %PrgLnchIni%, General, UseReg


	IniWrite, None, %PrgLnchIni%, Prgs, StartupPrgName
	IniWrite, %A_Space%, %PrgLnchIni%, Prgs, PrgCanBeShortcut
	IniWrite, %A_Space%, %PrgLnchIni%, Prgs, PrgMon
	IniWrite, %A_Space%, %PrgLnchIni%, Prgs, PrgBatchIniStartup
	IniWrite, %A_Space%, %PrgLnchIni%, Prgs, PrgTermExit
	IniWrite, %A_Space%, %PrgLnchIni%, Prgs, PrgInterval
	IniWrite, %A_Space%, %PrgLnchIni%, Prgs, PresetNames

	Loop , %maxBatchPrgs%
	{
		IniWrite, %A_Space%, %PrgLnchIni%, Prgs, PrgBatchIni%A_Index%
	}

		loop % PrgNo
		{
		;PrgChoiceNames.push([0])


		strPrgChoice .= "Prg" . A_Index . "|"
		spr := "Prg" . %A_Index%
		IniWrite, %spr%, %PrgLnchIni%, Prg%A_Index%, PrgName
		IniWrite, %A_Space%, %PrgLnchIni%, Prg%A_Index%, PrgName
		IniWrite, %A_Space%, %PrgLnchIni%, Prg%A_Index%, PrgPath ;for  each PrgChoicePaths[%A_Index%]
		IniWrite, %A_Space%, %PrgLnchIni%, Prg%A_Index%, PrgCmdLine
		IniWrite, %A_Space%, %PrgLnchIni%, Prg%A_Index%, PrgRes
		IniWrite, %A_Space%, %PrgLnchIni%, Prg%A_Index%, PrgUrl
		IniWrite, %A_Space%, %PrgLnchIni%, Prg%A_Index%, PrgVer
		IniWrite, %A_Space%, %PrgLnchIni%, Prg%A_Index%, PrgMisc
		}

	}
	else
	{

	FileRead, s, %PrgLnchIni%

	Loop, Parse, s, `n`r, %A_Space%%A_Tab%
		{

		c := SubStr(A_LoopField, 1, 1)
		if (c="[")
			{
				sectCount := 0

				k := SubStr(A_LoopField, 1)

				spr := SubStr(k, 2, 3)
				if (spr = "Prg")
				{
				recCount := recCount + 1
				}
				else	;Process  General section
				{
				Continue ;Just in case any new sub nodes
				}
				
			}
			else 
			{
				if (c=";" || c="*/") ;comments
				continue
				if (c="/*")
				{
					MsgBox, 8192, , % "Can't handle " c " if not eof!"
					Return -1
				}


				;if !selPrgChoice && !recCount
				;if p && recCount
				p := InStr(A_LoopField, "=")

				if (p)
				{
					k := SubStr(A_LoopField, p + 1)
					sectCount := sectCount + 1
					if (recCount < 0) ;General section
					{
						if (sectCount < 10)
						{
						Continue ;don't care about the "Don't show me first" || (sectCount = 3)
						}
						else
						{

							if (sectCount = 10)
							{
								if (selPrgChoice)
								{
								spr := Test ? Test : Fmode? Fmode: Dynamic? Dynamic: Tmp
									if (Test = 1)
									spr := spr . ",0,0,0"
									else
									{
									if (FMode = 1)
									spr := "0," . spr . ",0,0"
									else
									{
									if (Dynamic = 1)
									spr := "0,0," . spr . ",0"
									else
									{
									spr := "0,0,0," . spr
									}
									}
									}
								IniWrite, %spr%, %PrgLnchIni%, General, ResMode
								}
								else
								{
								if (k)
								{
								Test := SubStr(k, 1, 1)
								FMode := SubStr(k, 3, 1)
								Dynamic := SubStr(k, 5, 1)
								Tmp := SubStr(k, 7)
								}
								}

							}
							else
							{
							if (sectCount = 11)
							{
								if (selPrgChoice)
								{
								IniWrite, %Rego%, %PrgLnchIni%, General, UseReg
								}
								else
								{
								;spr := SubStr(A_LoopField, 2, -1)
								;if (spr = "UseReg")
								;{
								if (k)
								Rego := k
								;}
								;else
								}
							}
							}
						}
					}
					else
					{
					if (recCount = 0) ;Prgs section
					{
						if (sectCount = 1)
						{
						;strPrgChoice := % "|None|" ;why was this in?
							if (!selPrgChoice)
							{
								if (k)
								IniRead, defPrgStrng , %PrgLnchIni%, Prgs, StartupPrgName, %A_Space% ;Space just in case None is absent
							}
						
						}
						else
						{
							if (sectCount = 2)
							{
								if (selPrgChoice)
								{
								IniWrite, %PrgCanBeShortcut%, %PrgLnchIni%, Prgs, PrgCanBeShortcut
								}
								else
								{
								if (k)
								PrgCanBeShortcut := k
								}
							}
							else
							{
							if (sectCount = 3)
							{
								if (selPrgChoice)
								{

									if (selPrgChoice = 100) ;write record at selPrgChoice
									{
									spr := ""
									loop % dispMonNamesNo - 1
									{
									spr .= iDevNumArray[A_Index] . ","
									}
									spr .= iDevNumArray[dispMonNamesNo]

									IniWrite, %spr%, %PrgLnchIni%, Prgs, PrgMon
									}

								}
								else  ;reading entire file
								{
								if (k)
								{
								foundPos := 0
								loop % dispMonNamesNo
								{
								foundPosOld := foundPos
								foundPos := InStr(k, ",", A_Index)
								if (!foundPos)
								Break
								iDevNumArray[A_Index] = SubStr(k, foundPosOld + 1, foundPos-1)
								}
								}
								}
							}
							else ;Only reading the following sections- writing at control labels
							{
							if (sectCount = 4)
							{
								if !(inputOnceOnly)
								{
								if (k)
								PrgBatchIniStartup := k
								}
							}
							else
							{
							if (sectCount = 5)
							{
								if !(inputOnceOnly)
								{
								if (k)
								PrgTermExit := k
								}
							}
							else
							{
							if (sectCount = 6)
							{
								if !(inputOnceOnly)
								{
								if (k)
								PrgIntervalLnch := k
								}
							}
							else
							{
							if (sectCount = 7)
							{
								if !(inputOnceOnly)
								{
								temp := sectCount - 7
									Loop, parse, k, CSV , %A_Space%%A_Tab%
									{
									PresetNames[A_Index] := A_Loopfield
									}
								}
							}
							else
							{
							if !(inputOnceOnly)
							{

							if (sectCount > 7)
							{
								if (k)
								{
								temp := sectCount - 7
									Loop, parse, k, CSV , %A_Space%%A_Tab%
									{
									PrgBatchIni%temp%[A_Index] := A_Loopfield
									}
								}
							if (sectCount = 7 + maxBatchPrgs)
							inputOnceOnly := 1
							}

							}
							}
							}
							}
							}
							}
							}
						}
					}
					else
					{
						if (sectCount = 1)
						{
						if (selPrgChoice)
							{
							if (selPrgChoice = recCount) ;write record at selPrgChoice
							{
							spr := ""
								if (removeRec)
								{
								spr .= "Prg" . recCount
								IniWrite, %A_Space%, %PrgLnchIni%, %spr%, PrgName
								}
								else
								{
								spr .= PrgChoiceNames[recCount]
								IniWrite, %spr%, %PrgLnchIni%, Prg%recCount%, PrgName
								}
							foundPos := InStr(strPrgChoice,"|", false,1, recCount + 1)
							spr := SubStr(strPrgChoice,1,foundPos) . spr ;Bar is  to replace, not append  the  gui control string
							foundPos := InStr(strPrgChoice, "|", false, foundPos + 1)
							strPrgChoice := spr . SubStr(strPrgChoice, foundPos)
							}
							}
						else ;reading entire file
							{
							If (k)
								{
								strPrgChoice .= k . "|"
								PrgChoiceNames[recCount] := k
								}
								else
								{
								strPrgChoice .= "Prg" . recCount . "|"
								PrgChoiceNames[recCount] := ""
								}
							}
						}
						else
						{
							if (sectCount = 2)
							{
								if (selPrgChoice)
								{
									if (selPrgChoice = recCount) ;write record at selPrgChoice
									{
									if (removeRec)
									{
									IniWrite, %A_Space%, %PrgLnchIni%, Prg%recCount%, PrgPath
									}
									else
									{
									spr := PrgChoicePaths[recCount]
									IniWrite, %spr%, %PrgLnchIni%, Prg%recCount%, PrgPath
									}
									}
								}
								else  ;reading entire file
								{
								if (k)
								{
								PrgChoicePaths[recCount] := k
								If (!k && PrgChoiceNames[recCount])
								MsgBox, 8192, , % "Error: " PrgChoiceNames[recCount] " has no paths!"
								}
								}
							}
							else
							{
							if (sectCount = 3)
							{
								if (selPrgChoice)
								{
								if (selPrgChoice = recCount)
								{
									if (PrgCmdLine[selPrgChoice])
									IniWrite, % PrgCmdLine[selPrgChoice], %PrgLnchIni%, Prg%recCount%, PrgCmdLine
									else
									IniWrite, %A_Space%, %PrgLnchIni%, Prg%recCount%, PrgCmdLine									
									}
								}
								else
								{
								if (k)
								{
								PrgCmdLine[reccount] := k
								}
								}
							}
							else
							{
							if (sectCount = 4)
							{
								if (selPrgChoice)
								{
									if (selPrgChoice = recCount) ;write record at selPrgChoice
									{
									if (removeRec)
									{
									scrWidthArr[selPrgChoice] := ""
									scrHeightArr[selPrgChoice] := ""
									scrFreqArr[selPrgChoice] := ""

									IniWrite, %A_Space%, %PrgLnchIni%, Prg%recCount%, PrgRes
									}
									else
									{
									if (PrgChoiceNames[recCount])
									{
									spr := % scrWidth . "," . scrHeight . "," . scrFreq . "," 0
									;extra 0 for interlace which migh implement later
									IniWrite, %spr%, %PrgLnchIni%, Prg%recCount%, PrgRes
									scrWidthArr[selPrgChoice] := scrWidth
									scrHeightArr[selPrgChoice] := scrHeight
									scrFreqArr[selPrgChoice] := scrFreq
									}
									}
									}
								}
								else  ;reading entire file
								{
								if (k)
								{
									{
									foundPos := InStr(k, ",", 1)
									scrWidth := SubStr(k, 1, foundPos-1)
									spr := InStr(k, ",",,,2)
									scrHeight := SubStr(k, foundPos + 1, spr - foundPos - 1)
									foundPos := InStr(k, ",",,,3)
									scrFreq := SubStr(k, spr + 1 , foundPos - spr - 1)
									scrWidthArr[recCount] := scrWidth
									scrHeightArr[recCount] := scrHeight
									scrFreqArr[recCount] := scrFreq

									}
								}
								}
							}
							else
							{
							if (sectCount = 5)
							{
								if (selPrgChoice)
								{
									if (selPrgChoice = recCount) ;write record at selPrgChoice
									{
									if (removeRec)
									{
									IniWrite, %A_Space%, %PrgLnchIni%, Prg%recCount%, PrgUrl
									}
									else
									{
									if (PrgChoiceNames[recCount])
									IniWrite, % PrgUrl[recCount], %PrgLnchIni%, Prg%recCount%, PrgUrl
									}
									}
								}
								else  ;reading entire file
								{
								if (k)
								PrgUrl[recCount] := k
								}
							}
							else
							{
							if (sectCount = 6)
							{
								if (selPrgChoice)
								{
									if (selPrgChoice = recCount) ;write record at selPrgChoice
									{
									if (removeRec)
									{
									IniWrite, %A_Space%, %PrgLnchIni%, Prg%recCount%, PrgVer
									}
									else
									{
									if (PrgChoiceNames[recCount])
									IniWrite, % PrgVer, %PrgLnchIni%, Prg%recCount%, PrgVer
									}
									}
								}
								else  ;reading entire file
								{
								if (k)
								PrgVer := k
								}
							}


							
							else
							{
							if (sectCount = 7) ;Various Prg settings
							{
								if (selPrgChoice)
								{
									if (selPrgChoice = recCount) ;write record at selPrgChoice
									{
									if (removeRec)
									{
									IniWrite, %A_Space%, %PrgLnchIni%, Prg%recCount%, PrgMisc
									}
									else
									{
									if (PrgChoiceNames[recCount])
									{
									spr := PrgLnchHide[selPrgChoice]
									spr .= "," . PrgMonToRn[selPrgChoice]
									spr .= "," . PrgBordless[selPrgChoice]
									spr .= "," . PrgRnPriority[selPrgChoice]
									spr .= "," . PrgChgResonSwitch[selPrgChoice]
									}
									IniWrite, %spr%, %PrgLnchIni%, Prg%recCount%, PrgMisc
									}
									}
								}
								else  ;reading entire file
								{
								if (k)
								{
								Loop, Parse, k, CSV, %A_Space%%A_Tab%
								{
								if (A_Index = 1)
								PrgLnchHide[recCount] := A_LoopField
								else
								{
								if (A_Index = 2)
								{
								PrgMonToRn[recCount] := A_LoopField
								}
								else
								{
								if (A_Index = 3)
								{
								PrgBordless[recCount] := A_LoopField
								}
								else
								{
								if (A_Index = 4)
								{
								PrgRnPriority[recCount] := A_LoopField
								}
								else
								{
								if (A_Index = 5)
								{
								PrgChgResonSwitch[recCount] := A_LoopField
								}
								}
								}
								}
								}
								}
								}
								}
							}
							}
							}
							}
							}
							}
						}

					}
					}
				}
				
				else
				
				{
				if A_LoopField ; No equals character!
				{
				MsgBox, 8193, , Problem with ini file. The recommended course of action is to delete it. Continue?
				IfMsgBox, Cancel
				Continue
				else
				{
					Try
					{
					FileDelete %PrgLnchIni%
					}
					catch spr
					{
					MsgBox, 8208, Ini File Delete, Error deleting (broken) file! `nSpecifically: %spr%
					}
				strPrgChoice := "|None|"
				goto IniProcStart
				}
				}
				}

			}
		}
		
	}
}
IniSpaceCleaner(IniFile, oldVerChg := 0)
{
; https://autohotkey.com/boards/viewtopic.php?f=13&t=26556&p=124630#p124630
retVal := 0, temp := ""
Thread, NoTimers
try
{
FileRead, retVal, %IniFile%
if (oldVerChg)
{
	if !(InStr(retVal, "LoseGuiChangeResWrn"))
	{
	StringReplace, retVal, retVal, ResMode= , LoseGuiChangeResWrn= `nPrgAlreadyLaunchedMsg= `nResMode= 
	}
}
else
retVal := RegExReplace(retVal, "m) +$", " ") ;m multilineselect; " +" one or more spaces; $ only at EOL

FileDelete, %Inifile%
sleep, 100
FileAppend, %retVal%, %IniFile%
sleep, 100
}
catch e
{
MsgBox, 8208, IniSpaceCleaner, Error with Ini file! `nSpecifically: %e%
}
Thread, NoTimers, false
}























;Properties routines
PopPrgProperties(iDevNumArray, dispMonNamesNo, currBatchNo, btchPrgPresetSel, PrgBatchInibtchPrgPresetSel, PrgChoiceNames, PrgChoicePaths, PrgLnkInf, x, y, w)
{
ftemp := 0, temp := 0, foundpos := 0, batchPos := 0, pathCol := 0, pathColH := 0, pathColHOld := 0, defCol := 0, defColW := 0, defColH := 0, propX := 0, propY := 0, propW := 0, propH := 0, truncFileName := "", errorText := "", retval := "", fileName := ""
static tabName := 0





IfNotExist, PrgLnchProperties.jpg
FileInstall PrgLnchProperties.jpg, PrgLnchProperties.jpg
sleep, 200
SplashImage, PrgLnchProperties.jpg, A B,,,LnchSplash
WinGetPos,, propY, propW, propH, LnchSplash

	if (y > propY)
	WinMove, LnchSplash, , % x + (w - propW)/2, y - propY
	else
	WinMove, LnchSplash, , % x + (w - propW)/2, propY -Y



Gui, PrgProperties: Destroy

sleep, 120

Gui, PrgProperties: New,, Prg_Properties
Gui, PrgProperties: -MaximizeBox -MinimizeBox +OwnDialogs +HwndPrgPropertiesHwnd
Gui, PrgProperties: Color, FFFFCC



CLEARTYPE_QUALITY := 5

loop, % currBatchNo
{
	batchPos := PrgBatchInibtchPrgPresetSel[A_Index]
	fileName := PrgChoicePaths[batchPos]
	ftemp := PrgChoiceNames[batchPos]
	
	IfExist, % fileName
	{
		if (strlen(ftemp) > 12)
		{
		ftemp := SubStr(ftemp, 1, 12) . "..."
		}
	retval .= "|" . ftemp
	}
	else
	retval .= "|" . "No File!"
}

retval := SubStr(retval, 2)
;remove first pipe
Gui, PrgProperties: Add, Tab3, w%w% vtabName -Theme -wrap AltSubmit, % retval


loop, % currBatchNo
{
Gui, PrgProperties: Tab, %A_Index%


batchPos := PrgBatchInibtchPrgPresetSel[A_Index]
fileName := PrgChoicePaths[batchPos]

IfExist, % fileName
{

	errorText := ""

		Gui, PrgProperties: Add, Text, HWNDsprHwnd, Path

		if !(defColW)
		{
		GuiControlGet, defCol, PrgProperties: Pos, % sprHwnd
		defColW := defColW * 2
		}

	FileGetSize, foundpos, %fileName%, K ;kB
	sleep, 60 ; cache should work for following calls
		if (A_LastError)
		{
		errorText .= "Problem with file size.`n"
		foundpos := 0
		}

		FileGetAttrib, temp, % fileName
		if (A_LastError)
		{
		errorText .= "Problem with file size.`n"
		temp := 0
		}

		GuiControl, PrgProperties:, %sprHwnd%, `"%temp%`" attributes and %foundpos%kB filesize for the following Prg...
		GuiControl, PrgProperties: Move, %sprHwnd%, % "w" PrgLnchOpt.Width()/2


	temp := PrgLnchOpt.Width()
	Gui, PrgProperties: Add, Text, w%temp% +wrap HWNDpathHwnd, % fileName
	GuiControlGet, pathCol, PrgProperties: Pos, % pathHwnd
	pathColHOld := pathColH
		if (pathColH + 6 > 3 * defColH)
		{
		temp := fileName
		While (pathColH + 6 > 3 * defColH)
		{
		; bisect string
		temp := substr(temp, strlen(temp)/2, strlen(temp))
		GuiControl, PrgProperties:, %pathHwnd%, % temp
		GuiControl, PrgProperties: Move, %pathHwnd%, % "h" pathColH/2
		GuiControlGet, pathCol, PrgProperties: Pos, % pathHwnd
		}
		pathColH := 5*pathColH/4
		GuiControl, PrgProperties: Move, %pathHwnd%, % "h" pathColH
		GuiControl, PrgProperties: , %pathHwnd%, % substr(temp, 1, 3) . "..." . temp
		}
		


	temp := 2*defColW, ftemp := 16*defColH
	pathColHOld := pathColHOld - pathColH
	Gui, PrgProperties: Add, GroupBox, Section y+-%pathColHOld% w%temp% h%ftemp%


		FileRead temp, % fileName
		if (temp)
		{
			sleep, 120
			temp := CRC32(temp,foundpos)

			if (temp)
				{
				Gui, PrgProperties: Add, Text, xs ys+%defColH% HWNDsprHwnd, CRC
				PrgPropFont(sprHwnd)
				
				ftemp := 3*defColH
				Gui, PrgProperties: Add, Text, xs ys+%ftemp%, % temp
				}
			else
				errorText .= "Problem with CRC.`n"
		}
		else
		errorText .= "Problem with file read for CRC.`n"

	FileGetTime, foundpos, % fileName, C
		if (ErrorLevel)
		errorText .= "Problem with file creation time.`n"
		else
		{
			ftemp := 5*defColH
			Gui, PrgProperties: Add, Text, xs ys+%ftemp% HWNDsprHwnd, Creation Date
			PrgPropFont(sprHwnd)

			FormatTime, foundpos, % foundpos, ShortDate
			ftemp := 7*defColH
			Gui, PrgProperties: Add, Text, xs ys+%ftemp%, % foundpos
		}


	FileGetTime, foundpos, % fileName
		if (ErrorLevel)
		errorText .= "Problem with file modification time.`n"
		else
		{
			ftemp := 9*defColH
			Gui, PrgProperties: Add, Text, xs ys+%ftemp% HWNDsprHwnd, Modification Date
			PrgPropFont(sprHwnd)

			FormatTime, foundpos, % foundpos, ShortDate
			ftemp := 11*defColH
			Gui, PrgProperties: Add, Text, xs ys+%ftemp%, % foundpos
		}

	if !(PrgLnkInf[batchPos])
	{
		FileGetVersion, foundpos, % fileName
			if (ErrorLevel)
			errorText .= "Problem with file version.`n"
			else
			{
			ftemp := 13*defColH
			Gui, PrgProperties: Add, Text, xs ys+%ftemp% HWNDsprHwnd, File Version Number
			PrgPropFont(sprHwnd)

			ftemp := 15*defColH
			Gui, PrgProperties: Add, Text, xs ys+%ftemp%, % foundpos
			}

			
		retval := FileGetInfo(Filename).ProductName
		if (retval = "GetFileVersionInfoSizeFail")
		errorText .= "Unable to retrieve extended information from the file.`n"
		else
		{

		temp := PrgLnchOpt.Width()/2
		Gui, PrgProperties: Add, Text, xs+%temp% ys+%defColH% HWNDsprHwnd, Product Name
		PrgPropFont(sprHwnd)

		ftemp := 3*defColH
		Gui, PrgProperties: Add, Text, xs+%temp% ys+%ftemp%, % retval

		retval := FileGetInfo(Filename).CompanyName
		ftemp := 5*defColH
		Gui, PrgProperties: Add, Text, xs+%temp% ys+%ftemp% HWNDsprHwnd, Company Name
		PrgPropFont(sprHwnd)

		ftemp := 7*defColH
		Gui, PrgProperties: Add, Text, xs+%temp% ys+%ftemp%, % retval

		retval := FileGetInfo(Filename).ProductVersion
		ftemp := 9*defColH
		Gui, PrgProperties: Add, Text, xs+%temp% ys+%ftemp% HWNDsprHwnd, Product Version
		PrgPropFont(sprHwnd)

		ftemp := 11*defColH
		Gui, PrgProperties: Add, Text, xs+%temp% ys+%ftemp%, % retval

		retval := FileGetInfo(Filename).LegalCopyright
		ftemp := 13*defColH
		Gui, PrgProperties: Add, Text, xs+%temp% ys+%ftemp% HWNDsprHwnd, Legal Copyright
		PrgPropFont(sprHwnd)

		ftemp := 15*defColH
		Gui, PrgProperties: Add, Text, xs+%temp% ys+%ftemp%, % retval
		}
	}

	;CRC

	if (errorText)
	{
		temp := retval? (2*defColW): 0
		Gui, PrgProperties: Add, Text, xs+-%temp% Section, Errors
		Gui, PrgProperties: Add, Text,, % errorText
	}
}
}

Gui, PrgProperties: Font, CLEARTYPE_QUALITY
Gui, PrgProperties: Show, Hide, PrgProperties

WinGetPos,, propY,, propH, % "ahk_id" PrgPropertiesHwnd

	if (y > propH)
	WinMove, % "ahk_id" PrgPropertiesHwnd, , x, % y - propH, w
	else
	WinMove, % "ahk_id" PrgPropertiesHwnd, , x, % propH - y, w

SysGet, temp, MonitorWorkArea, GetPrgLnchMonNum(iDevNumArray, dispMonNamesNo)
if (propY + y > (tempBottom - tempTop))
	WinMove, % "ahk_id" PrgPropertiesHwnd, , , , , tempBottom - tempTop - y


SplashImage, PrgLnchProperties.jpg, Hide,,,LnchSplash
Gui, PrgProperties: Show

}
PrgPropFont(sprHwnd)
{
GuiControl, PrgProperties: Move, %sprHwnd%, % "w" PrgLnchOpt.Width()/4
Gui, PrgProperties: Font, -Wrap Bold, Verdana
GuiControl, PrgProperties: Font, % sprHwnd
Gui, PrgProperties: Font,
}
FileGetInfo(lptstrFilename) ; Lex @ https://autohotkey.com/boards/viewtopic.php?&t=4282
{
	retVal := 0
	;Returns all fields associated with following list
	List := "Comments InternalName ProductName CompanyName LegalCopyright ProductVersion"
		. " FileDescription LegalTrademarks PrivateBuild FileVersion OriginalFilename SpecialBuild"
	retVal := DllCall("Version.dll\GetFileVersionInfoSize", "Str", lptstrFilename, "Ptr", 0)
	if !(retVal)
	return "GetFileVersionInfoSizeFail"
	dwLen := VarSetCapacity( lpData, dwLen + A_PtrSize)
	DllCall("Version.dll\GetFileVersionInfo", "Str", lptstrFilename, "UInt", 0, "UInt", dwLen, "Ptr", &lpData) 
	DllCall("Version.dll\VerQueryValue", "Ptr", &lpData, "Str", "\VarFileInfo\Translation", "PtrP", lplpBuffer, "PtrP", puLen )
	sLangCP := Format("{:04X}{:04X}", NumGet(lplpBuffer+0, "UShort"), NumGet(lplpBuffer+2, "UShort"))
	retVal := {}
	Loop, Parse, % List, %A_Space%
		DllCall("Version.dll\VerQueryValue", "Ptr", &lpData, "Str", "\StringFileInfo\" sLangCp "\" A_LoopField, "PtrP", lplpBuffer, "PtrP", puLen )
		? retVal[A_LoopField] := StrGet(lplpBuffer, puLen) : ""
	return retVal
}
;Laszlo's function CRC32 has three parameters.
;- The first one is the name of a buffer, which can contain binary data.
;- The second parameter is the length of the data in bytes. If omitted or not positive, Strlen(Buffer) is used internally.
;- The 3rd parameter is used for continuing the CRC computation for second or later data sections. If omitted, -1 is used, the standard initial value for CRC32. If an earlier CRC operation is to be continued (which returned C), put here ~C. If a different CRC is needed than the standard CRC-32 (e.g. to resolve collisions), you can use any 32 bit integer for initialization.

CRC32(ByRef Buffer, Bytes=0, Start=-1) {
   Static CRC32, CRC32_Init, CRC32LookupTable
   If (CRC32 = "") {
      MCode(CRC32_Init,"33c06a088bc85af6c101740ad1e981f12083b8edeb02d1e94a75ec8b542404890c82403d0001000072d8c3")
      MCode(CRC32,"558bec33c039450c7627568b4d080fb60c08334d108b55108b751481e1ff000000c1ea0833148e403b450c89551072db5e8b4510f7d05dc3")
      VarSetCapacity(CRC32LookupTable, 256*4)
      DllCall(&CRC32_Init, "uint",&CRC32LookupTable, "cdecl")
   }
   If Bytes <= 0
      Bytes := StrLen(Buffer)
   Return DllCall(&CRC32, "uint",&Buffer, "uint",Bytes, "int",Start, "uint",&CRC32LookupTable, "cdecl uint")
}

MCode(ByRef code, hex)
{ ; allocate memory and write Machine Code there
	VarSetCapacity(code,StrLen(hex)//2)
	Loop % StrLen(hex)//2
	NumPut("0x" . SubStr(hex,2*A_Index-1,2), code, A_Index-1, "Char")
}
