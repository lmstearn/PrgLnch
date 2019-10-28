;AutoHotkey /Debug C:\Users\New\Desktop\PrgLnch\PrgLnch.ahk
;AutoHotkey /Debug C:\Users\New\Desktop\Desktemp\PrgLnch\PrgLnch.ahk
#SingleInstance, force
#NoEnv  ; Performance and compatibility with future AHK releases.
;#Warn, All , MsgBox ; Enable warnings to assist with detecting common errors.
ListLines Off ;A_ListLines is on
SendMode Input  ; Recommended for new scripts due to superior speed & reliability.
#MaxMem 256
FileSetAttrib, -RH, % A_ScriptDir . "`\*.*", 1
AutoTrim, Off
SetTitleMatchMode, 2
#MaxThreads 5
#Persistent
#Warn UseUnsetLocal, OutputDebug  ; Warn when a local variable is used before it's set; send to OutputDebug
SetWinDelay, 100 ; Default
; ListVars for debugging
;A_BatchLines is 10ms
SetBatchLines, 3ms
;https://autohotkey.com/boards/viewtopic.php?p=114554#p114554
OnMessage(0x112, "WM_SYSCOMMAND")
OnMessage(0x0053, "WM_Help")
OnMessage(0x201, "WM_LBUTTONDOWN")

#Include %A_ScriptDir%


;Issues:

; Virtual screen: https://msdn.microsoft.com/en-us/library/vs/alm/dd145136(v=vs.85).aspx

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
	static PrgLnchMonitor := 0

	Hwnd()
	{
	Gui, PrgLnch: +Hwndtemp
	This.PrgHwnd := temp
	Return This.PrgHwnd
	}
	Monitor()
	{
	PrgLnchMonitor := value
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
	If (!ErrorLevel)
	MsgBox, 8192, , Cannot retrieve the PID of PrgLnch!
	
	Return ErrorLevel
	}
	Activate() ;Activates window with Title - This.Title
	{
		IfWinExist, This.Title
		WinActivate
		else
		{
		IfWinExist, This.Title1
		WinActivate
		}
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





(A_PtrSize = 8)? 64bit := 1 : 64bit := 0 ; ONLY checks .exe bitness
updateStatus := 1
;Change display flags
CDS_TEST := 0x00000002
CDS_RESET := 0x40000000
CDS_UPDATEREGISTRY := 0x00000001
CDS_FULLSCREEN := 0x00000004
WS_EX_CONTEXTHELP := 0x00000400
;listBox
LB_GETITEMHEIGHT := 0x01A1
LB_GETCOUNT := 0x018B
;LB_GETCURSEL := 0x0188
LB_SETCURSEL := 0x0186

DISP_CHANGE_BADDUALVIEW := -6
DISP_CHANGE_BADPARAM := -5
DISP_CHANGE_BADFLAGS := -4
DISP_CHANGE_NOTUPDATED := -3
DISP_CHANGE_BADMODE := -2
DISP_CHANGE_FAILED := -1
DISP_CHANGE_RESTART := 1


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
DefaultPrgHwnd := 0
RegoHwnd := 0
allModesHwnd := 0
ChgResonSwitchHwnd := 0
PrgMinMaxHwnd := 0
PrgPriorityHwnd := 0
BordlessHwnd := 0
PrgLnchHdHwnd := 0
resolveShortctHwnd := 0
PrgPropsHwnd := 0

;Radio
TestHwnd := 0
FModeHwnd := 0
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

PrgTermExit := 0
PrgVerNew := 0
PrgNo := 12
PrgPID := 0 ; PID for test run Prgs
PrgStyle := 0 ;Storage for styles
PrgMinMaxVar := 0 ; -1 Min, 0 in Between, 1 Max
PrgIntervalLnch := -1
PrgUrlTest := "" ;temp URL to be verified in "Save URL"
borderToggle := 0 ; Borderless styles applied or no
UrlPrgIsCompressed := 0
batchPrgNo := 0 ;actually no of Prgs configured
currBatchNo := 0 ;no of Prgs in selected preset limited by maxBatchPrgs
boundListBtchCtl := 0 ; PrgList sel or Updown toggle
btchPrgPresetSel := 0 ;What preset is currently selected- 0 for none
PrgBatchIniStartup := 0 ;Batch Preset read from Startup
maxBatchPrgs := 6
batchActive := 0 ; (1) Batch is Active for current Preset (-1) flagged for Not Active (0) Not active (2) Batch active at start
lnchPrgIndex := 0 ; (PrgIndex) Run, (0) Change Res or -(PrgIndex) Cancel
lnchStat := 0 ; (-1) Test Run; (1) Batch Run; (0) BatchPrgStatus Select
lastMonitorUsedInBatch := 0
listPrgVar := 0 ; copy of BatchPrgs listbox id
presetNoTest := 2 ; 0: config screen 2: return to or load of batch screen: 1: else e.g. Not click on preset 1: preset clicked
prgSwitchIndex := 0 ; saves index of Prg switched to when active
waitBreak := 0 ; Switch to break the Prg watch
PrgPos := [0, 0, 0, 0]
PrgCmdLine := ["", "", "", "", "", "", "", "", "", "", "", ""]
PrgMonToRn := [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
PrgChgResonSwitch := [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
PrgRnMinMax := [-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1] ;indetermined values are "normal"
PrgRnPriority := [-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1]
PrgBordless := [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
PrgLnchHide := [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
PrgResolveShortcut := [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
PrgListIndex := [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
PrgListIndexTmp := [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
PrgBdyBtchTog := [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
PrgBdyBtchTogTmp := [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
PresetNames := ["", "", "", "", "", ""]
PresetNamesBak := ["", "", "", "", "", ""]
IniChoiceNames := ["", "", "", "", "", "", "", "", "", "", "", ""]
PrgPIDMast := [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
Loop %maxBatchPrgs%
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
PrgChoiceNames := ["", "", "", "", "", "", "", "", "", "", "", ""]
PrgChoicePaths := ["", "", "", "", "", "", "", "", "", "", "", ""]
PrgLnkInf := ["", "", "", "", "", "", "", "", "", "", "", ""]
PrgVer := [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
PrgUrl := ["", "", "", "", "", "", "", "", "", "", "", ""]
IniFileShortctSep := "?"
strIniChoice := ""
strPrgChoice := "|None|"
defPrgStrng := "None"
ChgShortcutVar := "Change Shortcut"
txtPrgChoice := ""
iniTxtPadChoice := ""
GoConfigTxt = Prg Config
iniSel := 0
selPrgChoice := 1
selPrgChoiceTimer := 0
txtCmd := 0
RegoVar := 0
navShortcut := 0



; General temp variables
;retVal above
strRetval := ""
verTemp := 0
timerfTemp := 0
timerTemp := 0
timerBtch := 0
foundPos := 0
temp := 0
fTemp := 0
ffTemp := 0 ; tmp for Makelong- also speed check for PresetName
strTemp := ""
strTemp2 := ""
;Prevents unecessary extra reads when this counter exceeds 4
inputOnceOnly := 0
PrgLnchIni := A_ScriptDir . "\" . SubStr(A_ScriptName, 1, -3 ) . "ini"
SelIniChoicePath := PrgLnchIni
SelIniChoiceName = PrgLnch
oldSelIniChoiceName := ""
oldSelIniChoicePath := "" ; Previously loaded preset: in many cases the path of oldSelIniChoiceName above
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
primaryMon := 1
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

;Done here, else complications with PrgLnch.Monitor
Gui, PrgLnchOpt: New

;Get def. mon list...
GetDisplayData( , , dispMonNamesNo, iDevNumArray, dispMonNames, scrDPI, scrWidth, scrHeight, scrInterlace, scrFreq, -3)

PrgLnch.Monitor := GetPrgLnchMonNum(iDevNumArray, dispMonNamesNo, primaryMon, 1)

WinMover(, , , , "PrgLnchLoading.jpg")

temp := PrgLnch.Title
DetectHiddenWindows, On
WinGet, foundpos, List, % temp

if (foundpos > 1 && !A_Args[1]) ; No command line parms! See ComboBugFix
{
	while foundpos%A_Index%
	{
	temp := foundpos%A_Index%
	WinGetClass, strRetVal, % "ahk_id" temp
	; This "fails" when any non-PrgLnch ahk script is run from the PrgLnch folder
		if (InStr(strRetVal, PrgLnch.Class()) || InStr(PrgLnch.Class(), strRetVal))
		fTemp += 1

	if (fTemp > 2)
	{
	MsgBox, 8192, PrgLnch Running!, An instance of PrgLnch is already in memory!
	GoSub PrgLnchButtonQuit_PrgLnch
	}

	} 
}

	if (FileExist(PrgLnchIni))
	{
	IniSpaceCleaner(PrgLnchIni, 1) ;  fix old version
	sleep, 90

	strTemp := ""
	strTemp2 := ""
	temp := 0

	for temp, strRetVal in A_Args  ; For each parameter (or file dropped onto a script):
	{
		if (temp = 1)
		strTemp := strRetVal ; dealt with after Iniproc
		else
		{
			if (temp = 2)
			{
				if (InStr(strRetVal, "|"))
				{
				SelIniChoiceName := SubStr(strRetVal, InStr(strRetVal, "|",,0) + 1)
				oldSelIniChoiceName := SubStr(strRetVal, 1, InStr(strRetVal, "|",,0) - 1)
					if (oldSelIniChoiceName != "PrgLnch")
					oldSelIniChoicePath := A_ScriptDir . "\" . oldSelIniChoiceName . ".ini"
				}
				else
				{
				SelIniChoiceName := strRetVal
					if (strRetVal != "PrgLnch")
					Break
				}
			}
			else
			strTemp2 := strRetVal ;Warning: Temp variable used long way down
		}
	}





	strRetVal := IniProcIniFile(0, SelIniChoicePath, SelIniChoiceName, IniChoiceNames, PrgNo, strIniChoice)
		if (strRetVal)
		{
		msgbox, 8192 , Ini File, % strRetVal
		SelIniChoicePath := PrgLnchIni
		IniWrite, %A_Space%, %SelIniChoicePath%, General, SelIniChoiceName
		IniWrite, %IniChoiceNames%, %SelIniChoicePath%, General, IniChoiceNames
		IniProcIniFile(0, SelIniChoicePath, SelIniChoiceName, IniChoiceNames, PrgNo, strIniChoice)
		; If file missing go to Disclaimer
		}
	oldSelIniChoiceName := selIniChoiceName
		Loop % PrgNo
		{
			if (IniChoiceNames[A_Index] = SelIniChoiceName)
			{
			iniSel := A_Index
			Break
			}
		}
	}

IniProc()
; No screen parms yet
sleep 90



IniRead, disclaimer, %SelIniChoicePath%, General, Disclaimer


if (!disclaimer || disclaimer = "Error")
{
msgbox, 8196 , Disclaimer, % disclaimtxt
	IfMsgBox, Yes
	{
	IniWrite, 1, %SelIniChoicePath%, General, Disclaimer
	FileInstall PrgLnch.chm, PrgLnch.chm
	sleep, 300
	SetTimer, RnChmWelcome, 3500
	; init Lnch Pad here
	IniProcIniFile(0, SelIniChoicePath, SelIniChoiceName, IniChoiceNames, PrgNo, strIniChoice)
	oldSelIniChoiceName := selIniChoiceName
	}
	else
	{
	FileDelete %SelIniChoicePath%
	GoSub PrgLnchButtonQuit_PrgLnch
	}
}
else
{
	if (!FileExist("PrgLnch.chm"))
	FileInstall PrgLnch.chm, PrgLnch.chm
sleep, 120
	if (A_Min < 22) ; Do this approx every 3 runs
	IniSpaceCleaner(SelIniChoicePath)
}




; Restarted PrgLnch (see above): Must happen after initialising PrgPID, PrgListPID.
temp := 0
if (strTemp)
	{
		; restart same ini
		if (SelIniChoicePath = oldSelIniChoicePath)
		{
		Loop, parse, strTemp, | ; Parse the string based on the pipe symbol.
		{
			if (A_Index = 1)
			{
				if (A_Loopfield)
				PrgPid := A_Loopfield
			}
			else
			{
			foundpos := A_Index - 1
				Loop, parse, A_Loopfield, `,
				{
					if (A_Loopfield)
					{
					temp += 1
					PrgListPID%foundpos%[A_Index] := A_Loopfield
					}
				}
			PidMaster(PrgNo, temp, foundpos, PrgBatchIni%foundpos%, PrgListPID%foundpos%, PrgPIDMast, 1)
			}
		}
		}
		else
		{

			Loop, parse, strTemp, `,
			{
				if (A_Index = 1)
				{
					if (A_Loopfield)
					PrgPid := A_Loopfield
				}
				else
				{
					if (A_Loopfield)
					{
					temp += 1
					PrgPIDMast[A_Index - 1] := A_Loopfield
					}
				}
			}
		}

	}





; Init the lnk info list
loop % PrgNo
{
	strTemp := PrgChoicePaths[A_Index]
	if (strTemp)
	{
		if (InStr(strTemp, IniFileShortctSep))
		;resolved link is stored after "?" in ini
		PrgLnkInf[A_Index] := GetPrgLnkVal(strTemp, IniFileShortctSep, 1, PrgResolveShortcut[A_Index])
		else
		{
		strRetVal := GetPrgLnkVal(strTemp, IniFileShortctSep)
			if (InStr(strRetVal, "|"))
			strRetVal .= "*"

		PrgLnkInf[A_Index] := strRetVal
		}
	}
}



	if (!oldSelIniChoicePath || (SelIniChoicePath = oldSelIniChoicePath))
	{
		; PrgPIDMast = Potential candidate list for PID
		loop %maxBatchPrgs%
		ChkBatchActivePrgs(maxBatchPrgs, PrgBatchIni%A_Index%, PrgPIDMast)

	batchActive := ProcessActivePrgsAtStart(SelIniChoicePath, PrgNo, PrgLnkInf, PrgChoicePaths, IniFileShortctSep, PrgPIDMast)

		loop %maxBatchPrgs%
		PidMaster(PrgNo, maxBatchPrgs, foundpos, PrgBatchIni%A_Index%, PrgListPID%A_Index%, PrgPIDMast)
	}
	else
	{
		; PIDs again checked in InitBtchStat later
		; Point of this is to save the _same_ PIDs when switching Lnch Pad Slots (in case of multiple instances)

		batchActive := ProcessActivePrgsAtStart(SelIniChoicePath, PrgNo, PrgLnkInf, PrgChoicePaths, IniFileShortctSep, PrgPIDMast, oldSelIniChoicePath)
	
		loop %maxBatchPrgs%
		PidMaster(PrgNo, maxBatchPrgs, foundpos, PrgBatchIni%A_Index%, PrgListPID%A_Index%, PrgPIDMast)
	}



	if (batchActive)
	batchActive := 2 ; for InitBtchStat at start






IniRead, fTemp, %SelIniChoicePath%, General, ChangeShortcutMsg
if (fTemp)
ChgShortcutVar := "Change Shortcut Name"

Gui, PrgLnchOpt: -MaximizeBox -MinimizeBox +OwnDialogs +E%WS_EX_CONTEXTHELP%

Gui, PrgLnchOpt: Color, FFFFCC
Gui, PrgLnchOpt: Add, ComboBox, vPrgChoice gPrgChoice HWNDPrgChoiceHwnd
Gui, PrgLnchOpt: Add, Button, gMakeShortcut vMkShortcut HWNDMkShortcutHwnd wp, &Just Change Res.
Gui, PrgLnchOpt: Add, Edit, vCmdLinPrm gCmdLinPrmSub HWNDcmdLinHwnd
Gui, PrgLnchOpt: Add, Text, vMonitors gMonitorsSub HWNDMonitorsHwnd wp ; wp is width of previous control
Gui, PrgLnchOpt: Add, DropDownList, AltSubmit viDevNum HWNDDevNumHwnd giDevNo
Gui, PrgLnchOpt: Add, Checkbox, ys vresolveShortct gresolveShortctChk HWNDresolveShortctHwnd wp, Shortcut Nav. (Dlg)
GuiControl, PrgLnchOpt: Enable, resolveShortct
GuiControl, PrgLnchOpt: , resolveShortct, % navShortcut

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

GuiControl, PrgLnchOpt:, Rego, % RegoVar


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


loop %PrgNo% 
{
foundpos := PrgMonToRn[A_Index]
if (foundpos && (iDevNumArray[foundpos] < 10) && PrgChoiceNames[A_Index])
PrgMonToRn[A_Index] := PrgLnch.Monitor
}


if (PrgMonToRn[selPrgChoice] && defPrgStrng != "None")
{
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

Loop % dispMonNamesNo
{
	if (iDevNumArray[A_Index] < 10) ;dec masks
	GuiControl, PrgLnchOpt:, iDevNum, % SubStr(iDevNumArray[A_Index], 1, 1) " |"
	else
	{
		if (iDevNumArray[A_Index] > 99)
		{
		GuiControl, PrgLnchOpt:, iDevNum, % SubStr(iDevNumArray[A_Index], 3, 1) " |"
			if (!selPrgChoice || defPrgStrng = "None")
			GuiControl, PrgLnchOpt: ChooseString, iDevNum, % SubStr(iDevNumArray[A_Index], 1, 1)
		}
		else
		GuiControl, PrgLnchOpt:, iDevNum, % SubStr(iDevNumArray[A_Index], 2, 1) " |"
	}
}



GoSub FixMonColours
Gui, PrgLnchOpt: font ;factory  defaults

Gui, PrgLnchOpt: Add, Checkbox, vChgResonSwitch gChgResonSwitchChk HWNDChgResonSwitchHwnd, Change Res on Switch
GuiControl, PrgLnchOpt: Disable, ChgResonSwitch
Gui, PrgLnchOpt: Add, Checkbox, ys vPrgMinMax gPrgMinMaxChk HWNDPrgMinMaxHwnd Check3 wp, Window (Min-Norm-Max)
GuiControl, PrgLnchOpt: Enable, PrgMinMax
GuiControl, PrgLnchOpt:, PrgMinMax, -1
Gui, PrgLnchOpt: Add, Checkbox, vPrgPriority gPrgPriorityChk HWNDPrgPriorityHwnd Check3 wp, Prg Priority (BN-N-H)
;check3 enables 3 values in checkbox
GuiControl, PrgLnchOpt: Enable, PrgPriority
GuiControl, PrgLnchOpt:, PrgPriority, -1
Gui, PrgLnchOpt: Add, Checkbox, vBordless gBordlessChk HWNDBordlessHwnd wp, Ext. Borderless
GuiControl, PrgLnchOpt: Disable, Bordless
Gui, PrgLnchOpt: Add, Checkbox, vPrgLnchHd gPrgLnchHideChk HWNDPrgLnchHdHwnd, Hide PrgLnch On Run
GuiControl, PrgLnchOpt: Disable, PrgLnchHd
Gui, PrgLnchOpt: Add, Checkbox, vDefaultPrg gCheckDefaultPrg HWNDDefaultPrgHwnd, Show at Startup ;Tip: g-labels can be used for more than one control
Gui, PrgLnchOpt: Add, Button, vPrgLAA gPrgLAARn HWNDPrgLAAHwnd wp, Apply LAA Flag



Gui, PrgLnchOpt: Add, Button, ys vRnPrgLnch gLnchPrgLnch HWNDRnPrgLnchHwnd wp, &Test Run Prg  ; ym topmost, xm puts it at the bottom left corner.
Gui, PrgLnchOpt: Add, Button, vUpdtPrgLnch gUpdtPrg HWNDUpdtPrgLnchHwnd wp, &Update Prg
Gui, PrgLnchOpt: Add, Edit, vUpdturlPrgLnch gUpdturlPrgLnchText HWNDUpdturlHwnd wp
Gui, PrgLnchOpt: Add, Text, vnewVerPrg HWNDnewVerPrgHwnd wp
Gui, PrgLnchOpt: Add, Button, cdefault gBackToPrgLnch HWNDBackToPrgLnchHwnd wp, &Back to PrgLnch ;cdefault colour

GuiControlGet, txtPrgChoice, PrgLnchOpt:, PrgChoice



if (ChkPrgNames(txtPrgChoice, PrgNo)) ;shouldn't happen on load
{
	txtPrgChoice := "None"
	GuiControl, PrgLnchOpt: Text, PrgChoice, None
	GuiControl, PrgLnchOpt: Choose, PrgChoice, 1
}

if (txtPrgChoice = "None")
	{
	GuiControl, PrgLnchOpt: Enable, RnPrgLnch
	GuiControl, PrgLnchOpt:, RnPrgLnch, Change Res`.
	GuiControl, PrgLnchOpt: Disable, DefaultPrg
	GuiControl, PrgLnchOpt:, MkShortcut, Just Change Res.
	GuiControl, PrgLnchOpt: Disable, Just Change Res.
	TogglePrgOptCtrls(txtPrgChoice, navShortcut)
	PrgURLEnable(PrgUrlTest, UrlPrgIsCompressed, selPrgChoice, PrgChoicePaths, selPrgChoiceTimer, PrgLnkInf, PrgUrl, PrgVer, PrgVerNew, UpdturlHwnd, IniFileShortctSep, 1)
	}
else
	{

	GuiControl, PrgLnchOpt:, MkShortcut, % ChgShortcutVar
	CheckPrgPaths(selPrgChoice, IniFileShortctSep, PrgChoicePaths, PrgLnkInf, PrgResolveShortcut)

	PrgCmdLineEnable(selPrgChoice, PrgCmdLine, cmdLinHwnd, PrgResolveShortcut, !InStr(PrgLnkInf[selPrgChoice], "*"), InStr(PrgLnkInf[selPrgChoice], "|"))

	PrgURLEnable(PrgUrlTest, UrlPrgIsCompressed, selPrgChoice, PrgChoicePaths, selPrgChoiceTimer, PrgLnkInf, PrgUrl, PrgVer, PrgVerNew, UpdturlHwnd, IniFileShortctSep)
	GuiControl, PrgLnchOpt: ChooseString, iDevNum, %targMonitorNum%
	borderToggle := DcmpExecutable(selPrgChoice, PrgChoicePaths, PrgLnkInf, IniFileShortctSep, 1)
	TogglePrgOptCtrls(txtPrgChoice, navShortcut, borderToggle, selPrgChoice, PrgChgResonSwitch, PrgRnMinMax, PrgRnPriority, PrgBordless, PrgLnchHide, 1, InStr(PrgLnkInf[selPrgChoice], "\", false, StrLen(PrgLnkInf[selPrgChoice])) || InStr(PrgLnkInf[selPrgChoice], "|"))
	GuiControl, PrgLnchOpt: , DefaultPrg, 1
	}





Gui, PrgLnchOpt: Show, Hide, PrgLnchOpt
WinMover(PrgLnchOpt.Hwnd(), "d r")   ; "dr" means "down, right"

if (!FindStoredRes(SelIniChoicePath, scrWidth, scrHeight, scrFreq))
GuiControl, PrgLnchOpt: ChooseString, ResIndex, %currRes%
;ChooseString may fail if frequencies differ. Meh!
if (PrgPID)
{
HideShowTestRunCtrls()
SetTimer, WatchSwitchOut, -1000
}

IniProc(100) ;initialises scrWidth, scrHeight, scrFreq & Prgmon in ini










































































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
strRetVal := PopBtchListBox(PrgChoiceNames, PrgNo, PrgMonToRn, PrgBdyBtchTog, PrgListIndex, batchPrgNo, 1)
temp := batchPrgNo-1

Gui, PrgLnch: Add, ListBox, vListPrg gListPrgProc HWNDBtchPrgHwnd AltSubmit
Gui, PrgLnch: Add, UpDown, vMovePrg gMovePrgProc HWNDMovePrgHwnd Range%temp%-0 ;MovePrg ZERO based: https://autohotkey.com/boards/viewtopic.php?f=5&t=26703&p=125603#p125603

Gui, PrgLnch: Add, Text, ys vstatic wp, Prg Status
Gui, PrgLnch: Add, ListBox, vbatchPrgStatus gbatchPrgStatusSub HWNDbatchPrgStatusHwnd AltSubmit
Gui, PrgLnch: Add, Checkbox, vPrgInterval gPrgIntervalChk HWNDPrgIntervalHwnd Check3 wp, Prg Lnch Interval: (Short-Med-Long)
GuiControl, PrgLnch: Enable, PrgInterval
GuiControl, PrgLnch:, PrgInterval, % PrgIntervalLnch
sleep 20

Gui, PrgLnch: Add, Checkbox, ys vDefPreset gDefPresetSub HWNDDefPresetHwnd, This Preset at Load

sleep 20

Gui, PrgLnch: Add, Button, cdefault vRunBatchPrg gRunBatchPrgSub HWNDRunBatchPrgHwnd wp, &Run Batch
Gui, PrgLnch: Add, Button, cdefault vGoConfigVar gGoConfig HWNDGoConfigHwnd wp, % "&" GoConfigTxt

Gui, PrgLnch: Add, ComboBox, vIniChoice gIniChoiceSel HWNDIniChoiceHwnd
GuiControl, PrgLnch:, IniChoice, %strIniChoice%


if (SelIniChoiceName = "PrgLnch")
{
	if (strTemp2)
	GuiControl, PrgLnch: Choose, IniChoice, %strTemp2%
	else
	{
	GuiControl, PrgLnch: Text, IniChoice,
	SetEditCueBanner(IniChoiceHwnd, "Lnch Pad Slot", 1)
	}
}
else
GuiControl, PrgLnch: Choose, IniChoice, %SelIniChoiceName%


Gui, PrgLnch: Add, Button, cdefault HWNDquitHwnd wp, &Quit_PrgLnch

; init conditions
currBatchNo := 0
btchPrgPresetSel := PrgBatchIniStartup
	if (btchPrgPresetSel)
	GuiControl, PrgLnch:, DefPreset, 1


FrontendInit:
sleep 100
Thread, NoTimers

strRetVal := "|"


loop %maxBatchPrgs% ;Preset limit is also Prgs_in_preset limit! 
{
	if (PresetNames[A_Index])
	{
	PresetNamesBak[A_Index] := PresetNames[A_Index]
	strRetVal := strRetVal . PresetNames[A_Index] . "|"
	}
	else
	strRetVal := strRetVal . "Preset" . A_Index . "|"
}
GuiControl, PrgLnch:, BtchPrgPreset, %strRetVal%

if (btchPrgPresetSel && PrgBatchIni%btchPrgPresetSel%[1])
{

EnableBatchCtrls(PresetNameHwnd, btchPrgPresetSel, PresetNames)

GuiControl, PrgLnch: Choose, BtchPrgPreset, % btchPrgPresetSel


sleep 60
GuiControl, PrgLnch:, batchPrgStatus, % ReorgBatch(batchPrgNo, maxBatchPrgs, btchPrgPresetSel, PrgMonToRn, PrgBatchIni%btchPrgPresetSel%, currBatchNo, PrgListIndex, PrgBdyBtchTog)

}
else
{
;load "none"
EnableBatchCtrls(PresetNameHwnd, btchPrgPresetSel, PresetNames, 1)
}


sleep 60
GuiControl, PrgLnch:, ListPrg, % PopBtchListBox(PrgChoiceNames, PrgNo, PrgMonToRn, PrgBdyBtchTog, PrgListIndex, batchPrgNo)
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
temp := .8 * temp
GuiControl, PrgLnch: Move, batchPrgStatus, h%temp%

GuiControlGet, batchPrgStatus, PrgLnch: Pos ;current selection

GuiControl, PrgLnch: Move, PrgInterval, % "y" 1.2 * batchPrgStatusY + batchPrgStatusH


Gui, PrgLnch: Show, Hide, PrgLnch
WinMover(PrgLnch.Hwnd(), "d r", PrgLnchOpt.Width() * 3/4, PrgLnchOpt.Height())

sleep, 20
	if (batchActive = 2)
	{
	GoSub InitBtchStat
	batchActive := 1
	}


Gui, PrgLnch: Show



;"WS_EX_CONTEXTHELP"
SplashImage, PrgLnchLoading.jpg, Hide,,,LnchSplash

Return


^!p::
strTemp := A_CoordModeMouse
CoordMode, Mouse, Screen
MouseGetPos, x, y
CoordMode, Mouse, % strTemp

if (WinExist("PrgLnch.ahk") or WinExist("ahk_class" . PrgLnch) or WinExist ("ahk_class AutoHotkeyGUI"))
{
WinActivate


IfWinExist, PrgLnch
{
WinMove, , PrgLnch, x, y
WinMove, , PrgLnch Options, x, y
}
else
{
IfWinExist, PrgLnch Options
{
WinMove, , PrgLnch Options, x, y
WinMove, , PrgLnch, x, y
}
else
{
MsgBox, 8196, , Problem with Finding the PrgLnch Window! Quit PrgLnch?
IfMsgBox, Yes
GoSub PrgLnchButtonQuit_PrgLnch

}

}

}
Return


MovePrgProc:

boundListBtchCtl := % MovePrg + 1
Gui, PrgLnch: Submit, Nohide

if (btchPrgPresetSel)
{
if (IsCurrentBatchRunning(currBatchNo, PrgListPID%btchPrgPresetSel%))
Return
}

if (listPrgVar)
{
	Loop % batchPrgNo
	{
		if (MovePrg + 1 = A_Index)
		{

			if (listPrgVar != MovePrg + 1)
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
								if (!temp)
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
								if (!temp)
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
				if (batchPrgNo = A_Index) ;down: move the rest up
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
								if (!PrgBdyBtchTog[batchPrgNo])
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
								if (!PrgBdyBtchTog[1])
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

if (!boundListBtchCtl)
{
GuiControl, PrgLnch:, MovePrg, % ListPrg + 1
listPrgVar := 1
boundListBtchCtl := 1
;called once: MovePrg Initialised if no presets loaded!
}

	MouseGetPos,,,,temp,3
	if (temp = BtchPrgHwnd) ;actually clicked the Listbox
	{
	GuiControlGet, listPrgVar, PrgLnch:, listPrg
	fTemp := PrgListIndex[listPrgVar]
	if (PrgBdyBtchTog[listPrgVar] = MonStr(PrgMonToRn, fTemp))
	{
		PrgBdyBtchTog[listPrgVar] := ""
		currBatchNo -= 1
			if (currBatchNo < 0)
			currBatchNo := 0

			if (!currBatchNo)
			EnableBatchCtrls(PresetNameHwnd, btchPrgPresetSel, PresetNames, 1)
	}
	else
	{
		if (currBatchNo < maxBatchPrgs)
		{
			if (!currBatchNo)
			EnableBatchCtrls(PresetNameHwnd, btchPrgPresetSel, PresetNames)

			if (!PrgBdyBtchTog[listPrgVar])
			currBatchNo += 1
		fTemp := PrgListIndex[listPrgVar]
		PrgBdyBtchTog[listPrgVar] := MonStr(PrgMonToRn, fTemp)
		}
		else
		{
		PrgBdyBtchTog[listPrgVar] := "" ; In case set to "MonStr(PrgMonToRn, PrgListIndex[A_Index]) " in the updown
		;ToolTip , "Batch Prg Limit Reached."
		}
	}


	GuiControl, PrgLnch:, ListPrg, % PopBtchListBox(PrgChoiceNames, PrgNo, PrgMonToRn, PrgBdyBtchTog, PrgListIndex, batchPrgNo)
	GuiControl, PrgLnch: Choose, ListPrg, % listPrgVar
	GuiControl, PrgLnch: Show, ListPrg
	}
;commit preset to file each click
if (btchPrgPresetSel)
{
;For some  reason, variables and arrays do not update without the sleep!
sleep, 120
	strTemp := "|"
	Loop % currBatchNo
	{
	strTemp .= "Unknown" . "|"
	}
	GuiControl, PrgLnch:, batchPrgStatus, %strTemp%

	Loop % maxBatchPrgs
	{
	PrgBatchIni%btchPrgPresetSel%[A_Index] := 0
	}

	fTemp := 0
	Loop % batchPrgNo
	{
	temp := PrgListIndex[A_Index]
	if (PrgBdyBtchTog[A_Index] = MonStr(PrgMonToRn, temp))
	{
	fTemp += 1
	PrgBatchIni%btchPrgPresetSel%[fTemp] := temp
	}
	}
	if (fTemp)
	{
	; Write if preset selected
	strTemp := ""
		Loop % maxBatchPrgs
		{
		if (A_Index > 1)
		strTemp := strTemp . ","
		strTemp2 := PrgBatchIni%btchPrgPresetSel%[A_Index]
		strTemp := strTemp . strTemp2
		}
	IniWrite, %strTemp%, %SelIniChoicePath%, Prgs, PrgBatchIni%btchPrgPresetSel%
	}
	else
	IniWrite, %A_Space%, %SelIniChoicePath%, Prgs, PrgBatchIni%btchPrgPresetSel%
	 ; Nothing to write!

	;If PrgProperties window is showing, update it
	DetectHiddenWindows, Off
	Gui, PrgProperties: +LastFoundExist
	IfWinExist
	{
	DetectHiddenWindows, On
	PopPrgProperties(PrgPropsHwnd, currBatchNo, btchPrgPresetSel, PrgBatchIni%btchPrgPresetSel%, PrgChoiceNames, PrgChoicePaths, PrgLnkInf, IniFileShortctSep, PrgLnchOpt.X(), PrgLnchOpt.Y(), PrgLnchOpt.Width(), PrgLnchOpt.Height())
	}
}


Return




BtchPrgPresetSub:
Gui, PrgLnch: Submit, Nohide
Gui PrgLnch: +OwnDialogs
SetTimer, WatchSwitchBack, Delete
SetTimer, WatchSwitchOut, Delete
Thread, NoTimers
temp := 0
DetectHiddenWindows, Off

waitBreak := 1 ; breaks the timer loop

if (btchPrgPresetSel)
GuiControlGet, temp, PrgLnch:, BtchPrgPreset ;sel another preset?
else
GuiControlGet, btchPrgPresetSel, PrgLnch:, BtchPrgPreset



if (btchPrgPresetSel = temp)
{
	; Batch active?
	if (IsCurrentBatchRunning(currBatchNo, PrgListPID%btchPrgPresetSel%))
	{
	
		; Just returned from Config
		if (presetNoTest = 2)
		{
		presetNoTest := 1

		GuiControl, PrgLnch:, ListPrg, % PopBtchListBox(PrgChoiceNames, PrgNo, PrgMonToRn, PrgBdyBtchTog, PrgListIndex, batchPrgNo, 1)

		; Restore PID
		PidMaster(PrgNo, currBatchNo, btchPrgPresetSel, PrgBatchIni%btchPrgPresetSel%, PrgListPID%btchPrgPresetSel%, PrgPIDMast)

		GuiControl, PrgLnch:, batchPrgStatus, % ReorgBatch(batchPrgNo, maxBatchPrgs, btchPrgPresetSel, PrgMonToRn, PrgBatchIni%btchPrgPresetSel%, currBatchNo, PrgListIndex, PrgBdyBtchTog)


			if (btchPrgPresetSel = PrgBatchIniStartup)
			GuiControl, PrgLnch:, DefPreset, 1
			else
			GuiControl, PrgLnch:, DefPreset, 0


			strRetVal := PopBtchListBox(PrgChoiceNames, PrgNo, PrgMonToRn, PrgBdyBtchTog, PrgListIndex, batchPrgNo)
			sleep 100
			GuiControl, PrgLnch:, ListPrg, % strRetVal
			GuiControl, PrgLnch: Show, ListPrg

			batchActive := 1
			EnableBatchCtrls(PresetNameHwnd, btchPrgPresetSel, PresetNames)
			SetTimer, WatchSwitchOut, 1000

		}
		else
		{
		MsgBox, 8196, Active Preset, This Preset contains active Prgs!`n`nReply:`nYes: Continue and remove the Preset `nNo: Do not remove the Preset. `n
			IfMsgBox, No
			{
			DetectHiddenWindows, On
			Return
			}
			else
			{

			Gui, PrgProperties: +LastFoundExist
			IfWinExist
			Gui, PrgProperties: Destroy


			loop % currBatchNo
			{
			PrgListPID%btchPrgPresetSel%[A_Index] := 0
			PrgBdyBtchTog[A_Index] = ""
			}
			currBatchNo := 0
			;must remove ini entry
			IniWrite, %A_Space%, %SelIniChoicePath%, Prgs, PrgBatchIni%btchPrgPresetSel%
				if (PrgBatchIniStartup = btchPrgPresetSel)
				IniWrite, 0, %SelIniChoicePath%, Prgs, PrgBatchIniStartup

			PresetNames[btchPrgPresetSel] := ""
			btchPrgPresetSel := 0
			SendMessage, LB_SETCURSEL, -1, 0, , ahk_id %PresetHwnd% ; deselects
			GuiControl, PrgLnch:, batchPrgStatus, |
			EnableBatchCtrls(PresetNameHwnd, btchPrgPresetSel, PresetNames, 1)
			}

		}
	}
	else
	{
		if (presetNoTest = 2)
		{
		presetNoTest := 1

		GuiControl, PrgLnch:, batchPrgStatus, % ReorgBatch(batchPrgNo, maxBatchPrgs, btchPrgPresetSel, PrgMonToRn, PrgBatchIni%btchPrgPresetSel%, currBatchNo, PrgListIndex, PrgBdyBtchTog)
			if (btchPrgPresetSel = PrgBatchIniStartup)
			GuiControl, PrgLnch:, DefPreset, 1
			else
			GuiControl, PrgLnch:, DefPreset, 0

		strRetVal := PopBtchListBox(PrgChoiceNames, PrgNo, PrgMonToRn, PrgBdyBtchTog, PrgListIndex, batchPrgNo)
		sleep 30
		GuiControl, PrgLnch:, ListPrg, % strRetVal
		EnableBatchCtrls(PresetNameHwnd, btchPrgPresetSel, PresetNames)

		;GuiControl, PrgLnch:, ListPrg, % PopBtchListBox(PrgChoiceNames, PrgNo, PrgMonToRn, PrgBdyBtchTog, PrgListIndex, batchPrgNo)
		GuiControl, PrgLnch: Show, ListPrg

		}
		else
		{

		Gui, PrgProperties: +LastFoundExist
		IfWinExist
		Gui, PrgProperties: Destroy


		loop % currBatchNo
		{
		PrgBdyBtchTog[A_Index] = ""
		}
		currBatchNo := 0
		;must remove ini entry
		IniWrite, %A_Space%, %SelIniChoicePath%, Prgs, PrgBatchIni%btchPrgPresetSel%
			if (PrgBatchIniStartup = btchPrgPresetSel)
			IniWrite, 0, %SelIniChoicePath%, Prgs, PrgBatchIniStartup

		PresetNames[btchPrgPresetSel] := ""
		btchPrgPresetSel := 0
		SendMessage, LB_SETCURSEL, -1, 0, , ahk_id %PresetHwnd% ; deselects
		GuiControl, PrgLnch:, batchPrgStatus, |
		EnableBatchCtrls(PresetNameHwnd, btchPrgPresetSel, PresetNames, 1)
		}
	}
}
else
{
	;we have just clicked a new preset after selecting another preset so set read_from_ini flag. Check for an intervening ListPrg msg!

	if (presetNoTest = 2)
	presetNoTest := 1


	foundpos := btchPrgPresetSel ; save old preset
	if (temp)
	btchPrgPresetSel := temp


	PresetNames[btchPrgPresetSel] := PresetNamesBak[btchPrgPresetSel]
	strTemp := ""


	IniReadStart:
	IniRead, temp, %SelIniChoicePath%, Prgs, PrgBatchIni%btchPrgPresetSel%
	sleep, 150
	if (temp = "ERROR")
	{
		MsgBox, 8196, , Problem reading the Ini file! Try again?
		IfMsgBox, Yes
		Goto IniReadStart
	}
	; No key and defaults to "ERROR"
	if (temp)
	{
		currBatchNo := 0
		loop, parse, temp, CSV
		{
			if (A_LoopField)
			{
			currBatchNo += 1
			strTemp := A_LoopField
			PrgBatchIni%btchPrgPresetSel%[A_Index] := strTemp
			}
			else
			PrgBatchIni%btchPrgPresetSel%[A_Index] := 0
		}
	}
	if (strTemp)
	{
	; just load new preset in:- first reset entire list as at load


	GuiControl, PrgLnch:, ListPrg, % PopBtchListBox(PrgChoiceNames, PrgNo, PrgMonToRn, PrgBdyBtchTog, PrgListIndex, batchPrgNo, 1)

	; Restore PID
	PidMaster(PrgNo, currBatchNo, btchPrgPresetSel, PrgBatchIni%btchPrgPresetSel%, PrgListPID%btchPrgPresetSel%, PrgPIDMast)

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
		PopPrgProperties(PrgPropsHwnd, currBatchNo, btchPrgPresetSel, PrgBatchIni%btchPrgPresetSel%, PrgChoiceNames, PrgChoicePaths, PrgLnkInf, IniFileShortctSep, PrgLnchOpt.X(), PrgLnchOpt.Y(), PrgLnchOpt.Width(), PrgLnchOpt.Height())
		}

	}
	else ;nothing in ini to restore, so write to it!
	{
		;sanitize
			Loop % maxBatchPrgs
			PrgBatchIni%btchPrgPresetSel%[A_Index] := 0


		currBatchNo := 0

			Loop % batchPrgNo
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
		IniWrite, %temp%, %SelIniChoicePath%, Prgs, PrgBatchIni%btchPrgPresetSel%
		; copy active Prgs over

			
			if (btchPrgPresetSel = foundpos)
			{
			;Reselecting a just removed preset, so re-populate PID array with a slected Prg that is active in another preset
			PidMaster(PrgNo, currBatchNo, btchPrgPresetSel, PrgBatchIni%btchPrgPresetSel%, PrgListPID%btchPrgPresetSel%, PrgPIDMast)
			GuiControl, PrgLnch:, batchPrgStatus, % ReorgBatch(batchPrgNo, maxBatchPrgs, btchPrgPresetSel, PrgMonToRn, PrgBatchIni%btchPrgPresetSel%, currBatchNo, PrgListIndex, PrgBdyBtchTog)
			}
			else
			{
				loop % currBatchNo
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
			if (!batchActive)
			{
			EnableBatchCtrls(PresetNameHwnd, btchPrgPresetSel, PresetNames, 1)
			Return
			}
		}
	}



EnableBatchCtrls(PresetNameHwnd, btchPrgPresetSel, PresetNames)
Thread, NoTimers, false

if (IsCurrentBatchRunning(currBatchNo, PrgListPID%btchPrgPresetSel%))
{
	batchActive := 1
	SetTimer, WatchSwitchOut, 1000
}
else
{
	batchActive := 0
	loop % PrgNo
	{
		if (PrgPIDMast[A_Index])
		{
		SetTimer, WatchSwitchOut, 1000
		Break
		}
	}
}

if (batchActive)
GuiControl, PrgLnch:, RunBatchPrg, &Cancel Batch
else
{
	strRetVal := "|"
	loop % currBatchNo
	{
	strRetVal := strRetVal . "Not Active" . "|"
	}
GuiControl, PrgLnch:, batchPrgStatus, % strRetVal
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

IniWrite, %PrgBatchIniStartup%, %SelIniChoicePath%, Prgs, PrgBatchIniStartup
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
	strTemp := "|"
		if (!batchPrgStatus)
		Return

	; check before launching not cancelling
	temp := PrgListPID%btchPrgPresetSel%[batchPrgStatus]
	if (temp = "NS" || temp = "FAILED" || temp = "TERM" || temp = "ENDED" || !temp)
	{

	strRetVal := ChkExistingProcess(PrgLnkInf, presetNoTest, batchPrgStatus, currBatchNo, PrgBatchIni%btchPrgPresetSel%, PrgChoicePaths, IniFileShortctSep)

		if (strRetVal)
		{
			if (strRetVal == "PrgLnch")
			{
			MsgBox, 8192, , Cannot launch this Prg!
			Return
			}
			if (strRetVal == "BadPath")
			Return

			IniRead, fTemp, %SelIniChoicePath%, General, PrgAlreadyMsg
			if (!fTemp)
			{
			MsgBox, 8195, , Selected Prg matches a process already running with `nthe same name. Might be an issue depending on instance requisites.`n`"%strRetVal%`"`n`nReply:`nYes: Continue (Warn like this next time) `nNo: Continue (This will not show again) `nCancel: Do nothing: `n
				IfMsgBox, Yes
				fTemp := 0 ; dummy condition
				else
				{
					IfMsgBox, No
					IniWrite, 1, %SelIniChoicePath%, General, PrgAlreadyMsg
					else
					return
				}
			}
		}


	if (!temp) ; fresh start
	{
	; Initialise all to batch
		loop % currBatchNo
		{
		if (!PrgListPID%btchPrgPresetSel%[A_Index])
		PrgListPID%btchPrgPresetSel%[A_Index] := "NS"
		}
	}

	;Hide the quit and config buttons!
	HideShowLnchControls(quitHwnd, GoConfigHwnd)
	lnchPrgIndex := PrgBatchIni%btchPrgPresetSel%[batchPrgStatus]
	temp := PrgChoicePaths[lnchPrgIndex]

	WinMover(, , , , "PrgLaunching.jpg")
	sleep, % (!PrgIntervalLnch)? 2000: (PrgIntervalLnch = -1)? 4000: 6000

	scrWidth := scrWidthArr[lnchPrgIndex]
	scrHeight := scrHeightArr[lnchPrgIndex]
	scrFreq := scrFreqArr[lnchPrgIndex]
	targMonitorNum := PrgMonToRn[lnchPrgIndex]
	}
	else
	{
	lnchPrgIndex := -PrgBatchIni%btchPrgPresetSel%[batchPrgStatus]
	temp := PrgChoicePaths[-lnchPrgIndex]
	scrWidth := scrWidthArr[-lnchPrgIndex]
	scrHeight := scrHeightArr[-lnchPrgIndex]
	scrFreq := scrFreqArr[-lnchPrgIndex]
	targMonitorNum := PrgMonToRn[-lnchPrgIndex]
	}

	lnchStat := 0


	strRetVal := LnchPrgOff(SelIniChoicePath, batchPrgStatus, lnchStat, PrgChoiceNames, temp, PrgLnkInf, IniFileShortctSep, currBatchno, lnchPrgIndex, PrgCmdLine, iDevNumArray, dispMonNamesNo, PrgRnMinMax, PrgRnPriority, PrgBordless, borderToggle, scrWidth, scrHeight, scrFreq, scrWidthDef, scrHeightDef, scrFreqDef, targMonitorNum, PrgPID, PrgListPID%btchPrgPresetSel%, PrgPos, PrgMinMaxVar, PrgStyle, x, y, w, h, dx, dy, Fmode)


	loop % currBatchNo
	{
	strTemp2 := PrgListPID%btchPrgPresetSel%[A_Index]
		if (batchPrgStatus = A_Index)
		{
		SplashImage, PrgLaunching.jpg, Hide,,,LnchSplash
		HideShowLnchControls(quitHwnd, GoConfigHwnd, 1)

			if (strRetVal) ;Lnch fail
			{
				if (strRetVal = "|*")
				strTemp .= "Started" . "|"
				else
				{
					if (lnchPrgIndex > 0)
					{
					strTemp .= "Failed" . "|"
					MsgBox, 8192, , % strRetVal
					}
				}
			}
			else
			{
				if (lnchPrgIndex > 0)
				{
					Gui, PrgLnch: Show, Hide, PrgLnch
						if (!PrgLnchHide[lnchPrgIndex])
						{
						WinMover(PrgLnch.Hwnd(), "d r", PrgLnchOpt.Width() * 3/4, PrgLnchOpt.Height())
						Gui, PrgLnch: Show
						}
					batchActive := 1
					strTemp .= "Active" . "|"
					SetResDefaults(targMonitorNum, currRes, Dynamic, FMode, scrWidth, scrHeight, scrFreq, scrWidthDef, scrHeightDef, scrFreqDef, scrWidthDefArr, scrHeightDefArr, scrFreqDefArr)
				}
				else
				{
				; ASSUME it's cancelled
					if (currBatchno = A_Index)
					CleanupPID(SelIniChoicePath, currBatchNo, PrgLnch.Monitor, lastMonitorUsedInBatch, PrgMonToRn, PrgNo, PrgPIDMast, presetNoTest, PrgListPID%btchPrgPresetSel%, PrgStyle, dx, dy, PrgBordless, PrgLnchHide, PrgPID, selPrgChoice, Fmode, dispMonNamesNo, scrWidth, scrHeight, scrWidthDef, scrHeightDef, scrFreqDef, waitBreak, 1)

					if (lnchPrgIndex < 0)
					strTemp .= "Not Active" . "|"
				}
			}
			; Update Master
			if (lnchPrgIndex > 0)
			{
				if (strRetVal)
				PrgPIDMast[lnchPrgIndex] := 0
				else
				PrgPIDMast[lnchPrgIndex] := strTemp2
			}
			else
			PrgPIDMast[-lnchPrgIndex] := strTemp2
		}
		else
		{
			if (strTemp2 = "NS" || strTemp2 = "FAILED" || strTemp2 = "TERM" || strTemp2 = "ENDED" || !strTemp2)
			strTemp .= "Not Active" . "|"
			else
			strTemp .= "Active" . "|"
		}
	}

GuiControl, PrgLnch:, batchPrgStatus, %strTemp%

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
	SetTimer, WatchSwitchOut, 1000
	}
	else
	{
		if (PrgPID)
		{
		waitBreak := 0
		SetTimer, WatchSwitchOut, -1000
		}
	GuiControl, PrgLnch:, RunBatchPrg, &Run Batch
	}
}
Return

PresetNameSub:
	if (ffTemp = 1)
	Return

GuiControlGet, temp, PrgLnch: FocusV
if (temp = "PresetName")
{
ffTemp := 1
Gui, PrgLnch: Submit, Nohide

GuiControlGet, strTemp, PrgLnch:, PresetName

sleep, 30


strTemp := StrReplace(strTemp, "`,")
strTemp := StrReplace(strTemp, "|", "1")


;fTemp:=RegExReplace(fTemp, "[\W_]+") ; Bit heavy

	if (strTemp)
	{
		if (StrLen(strTemp) > 3000) ;length: 6 X 3000 < 20000 being a reasonable limit
		{
		strTemp := SubStr(PresetName, 1, 3000)
		GuiControl, PrgLnch:, PresetName, %strTemp%
		}
	PresetNames[btchPrgPresetSel] := strTemp
	}
	else
	PresetNames[btchPrgPresetSel] := ""


sleep, 30
PresetNamesBak[btchPrgPresetSel] := PresetNames[btchPrgPresetSel]
strTemp := ""
Loop % maxbatchPrgs
{
	if (1 = A_Index)
	{
	strTemp .= PresetNames[1]
	strRetVal := strTemp
		if (temp)
		strRetVal := "|" . strTemp . "|"
		else
		strRetVal := "|Preset1|"
	}
	else
	{
	strTemp .= "," . PresetNames[A_Index]
		if 	(PresetNames[A_Index])
		strRetVal := strRetVal . PresetNames[A_Index] . "|"
		else
		strRetVal := strRetVal . "Preset" . A_Index . "|"
	}
}
IniWrite, %strTemp%, %SelIniChoicePath%, Prgs, PresetNames
GuiControl, PrgLnch:, BtchPrgPreset, %strRetVal%
GuiControl, PrgLnch: Enable, PresetName
ffTemp := 0
}
Return

RunBatchPrgSub:

if (btchPrgPresetSel)
GoSub LnchPrgLnch

Return


GoConfig:
Gui PrgLnch: +OwnDialogs

if (GoConfigTxt = "Save Lnch Pad")
{
ToolTip

GoConfigTxt = Prg Config
GuiControl, PrgLnch:, GoConfigVar, % "&" GoConfigTxt

if (strLen(iniTxtPadChoice) = 1)
{
	GuiControl, PrgLnch: Text, IniChoice,
	SetEditCueBanner(IniChoiceHwnd, "Name too short", 1)
	Return
}
else
SetEditCueBanner(IniChoiceHwnd, "Lnch Pad Slot", 1)

Loop, % prgNo
{
	if (iniTxtPadChoice = IniChoiceNames[A_Index])
	{
	GuiControl, PrgLnch: Text, IniChoice,
	SetEditCueBanner(IniChoiceHwnd, "Name in Use", 1)
	Return
	}
	else
	SetEditCueBanner(IniChoiceHwnd, "Lnch Pad Slot", 1)
}

if (IniChoiceNames[iniSel] && IniChoiceNames[iniSel] != "ini" . iniSel)
{
MsgBox, 8196, , % """" IniChoiceNames[iniSel] """" " is a Lnch Pad slot already, so replacing it will remove its data.`n`nYes: Overwrite the existing Lnch Pad with the one just configured.`nNo: Cancel the operation."
	IfMsgBox, No
	Return
}

	if (SelIniChoiceName = "ini" . iniSel)
	oldSelIniChoiceName = PrgLnch
	else
	oldSelIniChoiceName := SelIniChoiceName
SelIniChoiceName := iniTxtPadChoice
SelIniChoicePath := A_ScriptDir . "\" . SelIniChoiceName . ".ini"
oldSelIniChoicePath := A_ScriptDir . "\" . oldSelIniChoiceName . ".ini"

;Not replacing if exists!
if (!FileExist(oldSelIniChoicePath))
{
MsgBox, 8192, Lnch Pad File , % oldSelIniChoiceName " Lnch Pad file could not be found!`nCannot continue."
Return
}

	if (oldSelIniChoiceName = "PrgLnch")
	FileCopy %oldSelIniChoicePath%, %SelIniChoicePath%
	else
	FileMove %oldSelIniChoicePath%, %SelIniChoicePath%
	if (ErrorLevel)
	{
	MsgBox, 8192, File Move , % SelIniChoiceName " Lnch Pad could not be created!"
	iniTxtPadChoice = oldSelIniChoiceName
	GuiControl, PrgLnch: Text, IniChoice, %oldSelIniChoiceName%
	GuiControl, PrgLnch: Choose, IniChoice, % oldSelIniChoiceName
	Return
	}
	; Type at start
	if (!iniSel)
	iniSel := 1
IniProcIniFile(iniSel, SelIniChoicePath, SelIniChoiceName, IniChoiceNames, PrgNo, strIniChoice)
oldSelIniChoiceName := selIniChoiceName
GuiControl, PrgLnch:, IniChoice, %strIniChoice%
GuiControl, PrgLnch: Choose, IniChoice, % SelIniChoiceName
}
else
{

	if (GoConfigTxt = "Del Lnch Pad")
	{
	ControlSetText,,,ahk_id %IniChoiceHwnd%
	GuiControl, PrgLnch:, IniChoice,
	; iniTxtPadChoice should be null
		if (DelIniPresetProc(iniSel, GoConfigTxt, iniTxtPadChoice, SelIniChoicePath, SelIniChoiceName, oldSelIniChoiceName, IniChoiceNames, PrgNo, strIniChoice, 1))
		RestartPrgLnch(0, oldSelIniChoiceName, SelIniChoiceName)
		else
		GuiControl, PrgLnch:, GoConfigVar, % "&" GoConfigTxt
	}
	else
	{

	presetNoTest := 0

	PidMaster(PrgNo, currBatchNo, btchPrgPresetSel, PrgBatchIni%btchPrgPresetSel%, PrgListPID%btchPrgPresetSel%, PrgPIDMast, 1)
		IfWinExist, % "ahk_id" PrgPropsHwnd
		{
		Gui, PrgProperties: Destroy
		PrgPropsHwnd := 0
		}

		if (PrgPID)
		{
		Process, Exist, % PrgPID
			if (!ErrorLevel)
			{
			PrgPID := 0
			HideShowTestRunCtrls(1)
			}
		}
	WinMover(PrgLnchOpt.Hwnd(), "d r")
	Gui, PrgLnch: Show, Hide, PrgLnch
	sleep, 10
	Gui, PrgLnchOpt: Show, NA, PrgLnch Options

	}
}
Return


PrgIntervalChk:
Gui, PrgLnch: Submit, Nohide
PrgIntervalLnch := PrgInterval
if (PrgIntervalLnch)
IniWrite, %PrgIntervalLnch%, %SelIniChoicePath%, Prgs, PrgInterval
else
IniWrite, %A_Space%, %SelIniChoicePath%, Prgs, PrgInterval
Return

PresetLabelSub:
if (btchPrgPresetSel && currBatchNo)
PopPrgProperties(PrgPropsHwnd, currBatchNo, btchPrgPresetSel, PrgBatchIni%btchPrgPresetSel%, PrgChoiceNames, PrgChoicePaths, PrgLnkInf, IniFileShortctSep, PrgLnchOpt.X(), PrgLnchOpt.Y(), PrgLnchOpt.Width(), PrgLnchOpt.Height())
Return



















;IniChoice section
IniChoiceSel:
Gui, PrgLnch: Submit, Nohide
Gui PrgLnch: +OwnDialogs
Tooltip
SendMessage 0x147, 0, 0, , ahk_id %IniChoiceHwnd%  ; CB_GETCURSEL


If (ErrorLevel = "FAIL")
	{
	Gui, PrgLnch: Submit, Nohide
	MsgBox, 8192, , CB_GETCURSEL Failed
	}
else
	{

	retVal := ErrorLevel << 32 >> 32
		if (retVal < 0) ;Did the user type?
		{
		sleep 120 ;slow down input?
		GuiControlGet, iniTxtPadChoice, PrgLnch:, IniChoice

		;Pre-validation

			if (StrLen(iniTxtPadChoice) > 20000) ;length?
			{
			iniTxtPadChoice := SubStr(iniTxtPadChoice, 1, 20000)
			GuiControl, PrgLnch: Text, IniChoice, %iniTxtPadChoice%
			}

		; This isn't good...
		iniTxtPadChoice := StrReplace(iniTxtPadChoice, "|", "1")
		iniTxtPadChoice := StrReplace(iniTxtPadChoice, "`,")

			if (ChkPrgNames(iniTxtPadChoice, PrgNo, "Ini"))
			{
			;"0" happens rarely on "timing glitch??"
			GuiControl, PrgLnch: Text, IniChoice,
			SetEditCueBanner(IniChoiceHwnd, "Name Reserved", 1)
			GoConfigTxt = Prg Config
			GuiControl, PrgLnch:, GoConfigVar, % "&" GoConfigTxt
			ControlFocus, , ahk_id %GoConfigHwnd%
			}
			else
			{
				if (iniTxtPadChoice)
				{
					if (strLen(iniTxtPadChoice) > 1)
					{
						if (ChkCmdLineValidFName(iniTxtPadChoice, 1))
						{
							if (!iniTxtPadChoice)
							{
								GuiControl, PrgLnch: Text, IniChoice,
								SetEditCueBanner(IniChoiceHwnd, "Alphanumeric Name", 1)
								GoConfigTxt = Prg Config
								GuiControl, PrgLnch:, GoConfigVar, % "&" GoConfigTxt
								ControlFocus, , ahk_id %GoConfigHwnd%
								Return
							}

						}

					strTemp := RegExReplace(iniTxtPadChoice, "\w", "", temp)
						if (!temp)
						{
						GuiControl, PrgLnch: Text, IniChoice,
						SetEditCueBanner(IniChoiceHwnd, "Alphanumeric Name", 1)
						GoConfigTxt = Prg Config
						GuiControl, PrgLnch:, GoConfigVar, % "&" GoConfigTxt
						ControlFocus, , ahk_id %GoConfigHwnd%
						return
						}
					}

				GoConfigTxt := "Save Lnch Pad"
				ToolTip, "Click `"Save Lnch Pad`" to save."
				GuiControl, PrgLnch:, GoConfigVar, % GoConfigTxt
				}
				else
				{
				GoSub PrepDelIni
				}
			}
		}
		else
		{
		
		ControlGetText,iniTxtPadChoice,,ahk_id %IniChoiceHwnd% ; "GuiControlGet, iniTxtPadChoice, PrgLnch:, IniChoice" fails when empty

			if (iniTxtPadChoice)
			{
				if (iniTxtPadChoice = oldSelIniChoiceName)
				Return
			}
			else ; Del key hit
			{
			GoSub PrepDelIni
			Return
			}

		 ; Clicked here
		iniSel := retVal + 1
		GoConfigTxt = Prg Config
		GuiControl, PrgLnch:, GoConfigVar, % "&" GoConfigTxt

		strRetVal := WorkingDirectory(A_ScriptDir, 1)
		If (strRetVal)
		MsgBox, 8192, Script Directory, % strRetVal "`nCannot load Lnch Pad file!"
		else
		{
		
		IniRead, fTemp, %PrgLnchIni%, General, DefPresetSettings
		if (ChkPrgNames(iniTxtPadChoice, PrgNo, "Ini"))
		{
			; ChkPrgNames negates "PrgLnch" so...
			if (oldSelIniChoiceName = "PrgLnch")
			Return
			if (!ChkPrgNames(oldSelIniChoiceName, PrgNo, "Ini") && fTemp = "")
			{
			temp := 0
			MsgBox, 8195, Current or default settings, A spare Lnch Pad slot has just been clicked.`nIt can be initialised with either the current or the default Lnch Pad.`n`nReply:`nYes: Use current (Warn like this next time)`nNo: Do not use current (Recommended: This will not show again)`nCancel: Do not use current (Warn like this next time):`n
				IfMsgBox, Yes
				{
				strTemp := SelIniChoicePath
				SelIniChoiceName .= iniSel
				iniTxtPadChoice := SelIniChoiceName
				SelIniChoicePath := A_ScriptDir . "\" . SelIniChoiceName . ".ini"

				FileCopy %strTemp%, %SelIniChoicePath%

					if (ErrorLevel)
					MsgBox, 8192, File Copy , % SelIniChoiceName " Lnch Pad could not be created!"
				IniProcIniFile(iniSel, SelIniChoicePath, SelIniChoiceName, IniChoiceNames, PrgNo, strIniChoice)
				GuiControl, PrgLnch:, IniChoice, %strIniChoice%
				GuiControl, PrgLnch: Choose, IniChoice, % SelIniChoiceName
				}
				else
				{
					IfMsgBox, No
					temp := 1

				SelIniChoiceName = PrgLnch
				; Update all ini files
				UpdateAllIni(PrgNo, iniSel, SelIniChoicePath, PrgLnchIni, SelIniChoiceName, IniChoiceNames, temp)
				RestartPrgLnch(0, SelIniChoiceName, iniTxtPadChoice)
				}
			}
		}
		else
		{
		UpdateAllIni(PrgNo, iniSel, SelIniChoicePath, PrgLnchIni, iniTxtPadChoice, IniChoiceNames, fTemp)
		RestartPrgLnch(0, iniTxtPadChoice)
		}
		
		oldSelIniChoiceName := SelIniChoiceName
		}
		}
	}
Return

PrepDelIni:
ControlSetText,,,ahk_id %IniChoiceHwnd%
	if (GoConfigTxt = "Del Lnch Pad")
	{
		if (DelIniPresetProc(iniSel, GoConfigTxt, iniTxtPadChoice, SelIniChoicePath, SelIniChoiceName, oldSelIniChoiceName, IniChoiceNames, PrgNo, strIniChoice, 1))
		RestartPrgLnch(0, oldSelIniChoiceName, SelIniChoiceName)
		else
		GuiControl, PrgLnch:, GoConfigVar, % "&" GoConfigTxt
	}
	else
	{
		if ((SelIniChoiceName != "PrgLnch") && !ChkPrgNames(SelIniChoiceName, PrgNo, "Ini", 1))
		{
		GoConfigTxt = Del Lnch Pad
		ToolTip, "Click `"Del Lnch Pad`" or hit Del to confirm."
		GuiControl, PrgLnch:, GoConfigVar, % GoConfigTxt
		}
	}
Return



DelIniPresetProc(iniSel, ByRef GoConfigTxt, ByRef iniTxtPadChoice, ByRef SelIniChoicePath, ByRef SelIniChoiceName, ByRef oldSelIniChoiceName, ByRef IniChoiceNames, PrgNo, ByRef strIniChoice, 1)
{
ToolTip
retVal := 0
MsgBox, 8193, Del Lnch Pad, Really delete the Lnch Pad?`nThis will also remove the file.
	IfMsgBox, Ok
	{
		IfWinExist, % "ahk_id" PrgPropsHwnd
		{
		Gui, PrgProperties: Destroy
		PrgPropsHwnd := 0
		}
	IniProcIniFile(iniSel, SelIniChoicePath, SelIniChoiceName, IniChoiceNames, PrgNo, strIniChoice, 1)
	oldSelIniChoiceName := SelIniChoiceName
	SelIniChoiceName := "Ini" . iniSel
	GuiControl, PrgLnch:, IniChoice, %strIniChoice%
	GuiControl, PrgLnch: Choose, IniChoice, % SelIniChoiceName

	FileDelete, %SelIniChoicePath%
		if (ErrorLevel)
		MsgBox, 8192, File Delete , % SelIniChoicePath " Lnch Pad file could not be removed!"
	retVal := 1
	sleep, 30
	}
	else
	{
	iniTxtPadChoice := SelIniChoiceName
	GuiControl, PrgLnch: Text, IniChoice, %iniTxtPadChoice%
	}
GoConfigTxt = Prg Config
Return retVal
}

UpdateAllIni(PrgNo, iniSel, SelIniChoicePath, PrgLnchIni, SelIniChoiceName, IniChoiceNames, DefPresetSettings := 0) ; won't allow A_Space
{
spr := "", strTemp := "", fTemp := 0
IniChoicePaths := ["", "", "", "", "", "", "", "", "", "", "", ""]

	strTemp := % (SelIniChoiceName = "Ini" . iniSel)? A_Space: SelIniChoiceName
	Loop % PrgNo
	{
		if (IniChoiceNames[A_Index] = "Ini" . A_Index || IniChoiceNames[A_Index] = "PrgLnch")
		spr .= ","
		else
		{
		spr .= IniChoiceNames[A_Index] . ","
		IniChoicePaths[A_Index] := A_ScriptDir . "\" . IniChoiceNames[A_Index] . ".ini"
		IniWrite, %strTemp%, % IniChoicePaths[A_Index], General, SelIniChoiceName
			if (Errorlevel)
			{
			MsgBox, 8196, , % "The following Lnch Pad file could not be written to:`n" IniChoiceNames[A_Index] "`n`nReply:`nYes: Continue updating the others (Recommended) `nNo: Quit updating the Lnch Pads. `n"
				IfMsgBox, No
				Return
			}
		sleep, 20
		}
	}
	
	IniWrite, %strTemp%, %PrgLnchIni%, General, SelIniChoiceName
		if (Errorlevel)
		MsgBox, 8192, , % "The following (possibly blank) value could not be written to PrgLnch.ini:`n" strTemp
	sleep, 20
	; Trim last ","
	spr := SubStr(spr, 1, StrLen(spr) - 1)
	Loop % PrgNo
	{
		if (IniChoicePaths[A_Index])
		{
		IniWrite, %spr%, % IniChoicePaths[A_Index], General, IniChoiceNames
		sleep, 20
		}
	}
	IniWrite, %spr%, %PrgLnchIni%, General, IniChoiceNames
	sleep, 20

	Loop % PrgNo
	{
		if (IniChoicePaths[A_Index])
		{
		IniWrite, % (DefPresetSettings)? 1: A_Space, % IniChoicePaths[A_Index], General, DefPresetSettings
		sleep, 20
		}
	}
	IniWrite, % (DefPresetSettings)? 1: A_Space, %PrgLnchIni%, General, DefPresetSettings

}


IniProcIniFile(iniSel, ByRef SelIniChoicePath, ByRef SelIniChoiceName, ByRef IniChoiceNames, PrgNo, ByRef strIniChoice, removeIni := 0)
{
strTemp := "", spr := "", foundPos := 0
PrgLnchPath := A_ScriptDir . "\" . SubStr(A_ScriptName, 1, -3 ) . "ini"
if (iniSel)
{
	if (removeIni)
	{
	strTemp := "Ini" . iniSel
	SelIniChoiceName = PrgLnch
	IniChoiceNames[iniSel] := SelIniChoiceName
	}
	else
	{
	IniChoiceNames[iniSel] := SelIniChoiceName
	strTemp := SelIniChoiceName
	}

	UpdateAllIni(PrgNo, iniSel, SelIniChoicePath, PrgLnchPath, SelIniChoiceName, IniChoiceNames)
	foundPos := InStr(strIniChoice, "|", false, 1, iniSel)
	spr := SubStr(strIniChoice, 1, foundPos) . strTemp ;Bar is  to replace, not append  the  gui control string
	foundPos := InStr(strIniChoice, "|", false, foundPos + 1)
	strIniChoice := spr . SubStr(strIniChoice, foundPos)

}
else ; Read in names
{
SelIniChoicePath := A_ScriptDir . "\" . SelIniChoiceName . ".ini"

;Update PrgLnch.ini & SelIniChoiceName.ini with IniChoiceNames list
IniRead, strTemp, %SelIniChoicePath%, General, SelIniChoiceName
IniRead, spr, %SelIniChoicePath%, General, IniChoiceNames


if (strTemp = "Error" && spr = "Error")
; *Assume*  old version of PrgLnch
Return 0
Else
{
	if (spr != "Error" || SelIniChoicePath != "Error")
	{
	; Reset all
	if (strTemp != "PrgLnch")
	{
	SelIniChoiceName := strTemp
	SelIniChoicePath := A_ScriptDir . "\" . SelIniChoiceName . ".ini"
	}


	strIniChoice := "|"
		Loop, Parse, spr, CSV, %A_Space%%A_Tab%
		{
			if (A_LoopField)
			{
			foundPos := 1
			IniChoiceNames[A_Index] := A_LoopField
			;SplitPath, A_LoopField, , , , strTemp
			strIniChoice .= A_LoopField . "|"
			}
			else
			{
			IniChoiceNames[A_Index] := "Ini" . A_Index
			strIniChoice .= IniChoiceNames[A_Index] . "|"
			}
		}

	if (!foundPos)
	SplitPath, SelIniChoicePath, , , , SelIniChoiceName
	}
	else
	Return "Lnch Pad file is in error- Reverting to PrgLnch.ini."
}

}
Return 0
}
































;More Frontend functions
HideShowLnchControls(quitHwnd, GoConfigHwnd, showCtl := 0)
{
if (showCtl)
	{
	GuiControl, PrgLnch: Show, PresetLabel
	GuiControl, PrgLnch: Show, ListPrg
	GuiControl, PrgLnch: Show, MovePrg
	GuiControl, PrgLnch: Show, PresetName
	GuiControl, PrgLnch: Show, BtchPrgPreset
	GuiControl, PrgLnch: Show, RunBatchPrg
	GuiControl, PrgLnch: Show, % GoConfigHwnd
	GuiControl, PrgLnch: Show, IniChoice
	GuiControl, PrgLnch: Show, % quitHwnd
	}
	else
	{
	GuiControl, PrgLnch: Hide, PresetLabel
	GuiControl, PrgLnch: Hide, ListPrg
	GuiControl, PrgLnch: Hide, MovePrg
	GuiControl, PrgLnch: Hide, PresetName
	GuiControl, PrgLnch: Hide, BtchPrgPreset
	GuiControl, PrgLnch: Hide, RunBatchPrg
	GuiControl, PrgLnch: Hide, % GoConfigHwnd
	GuiControl, PrgLnch: Hide, IniChoice
	GuiControl, PrgLnch: Hide, % quitHwnd
	}
}

IsCurrentBatchRunning(currBatchNo, PrgListPIDbtchPrgPresetSel)
{
strTemp := 0
; return 1 if any running
	Loop % currBatchNo
	{
		strTemp := PrgListPIDbtchPrgPresetSel[A_Index]
		if !(strTemp = "NS" || strTemp = "FAILED" || strTemp = "TERM" || strTemp = "ENDED" || !strTemp)
		return 1
	}
Return 0
}
ReorgBatch(batchPrgNo, maxBatchPrgs, btchPrgPresetSel, PrgMonToRn, PrgBatchInibtchPrgPresetSel, ByRef currBatchNo, ByRef PrgListIndex, ByRef PrgBdyBtchTog)
{
;confirm new items and merge, swapping entries
temp := 0, fTemp := 0, foundpos := 0, strRetVal := "|"
currBatchNo := 0

	loop % maxBatchPrgs
	{
		temp := PrgBatchInibtchPrgPresetSel[A_Index]
		if (temp)
		{
		loop % batchPrgNo
		{
			if (temp = PrgListIndex[A_Index])
			{
			currBatchNo += 1
			fTemp := PrgListIndex[A_Index]
			PrgBdyBtchTog[A_Index] := MonStr(PrgMonToRn, fTemp)
			break
			}
		}
	}
	}


Loop % currBatchNo
{
	temp := A_Index

	Loop % BatchPrgno
	{
		if (PrgListIndex[A_Index] = PrgBatchInibtchPrgPresetSel[temp])
		{
		foundpos := A_Index
		Break
		}
	}

	if (foundpos > A_Index)
	{
	temp := PrgListIndex[foundpos]
	PrgListIndex[foundpos] := PrgListIndex[A_Index]
	PrgListIndex[A_Index] := temp
	temp := PrgBdyBtchTog[foundpos]
	PrgBdyBtchTog[foundpos] := PrgBdyBtchTog[A_Index]
	PrgBdyBtchTog[A_Index] := temp
	}

	;init Status List
	strRetVal := strRetVal . "Unknown" . "|"

}
return strRetVal
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
strRetVal := "", strTemp2 := "", strTemp := "|" ;vital, or listBox won't refresh


if (AtLoad)
{
	batchPrgNo := 0
	Loop % PrgNo
	{
	strTemp2 := PrgChoiceNames[A_Index]
	if (strTemp2)
		{
		batchPrgNo += 1
		; Following requ'd to init Listbox!??
		strTemp := strTemp . strTemp2 . "|"

		PrgListIndex[batchPrgNo] := A_Index
		PrgBdyBtchTog[batchPrgNo] := "" ;sanitize as well!
		}
	}

	if (!batchPrgNo)
	strTemp := strTemp . "No Prgs Configured |"
}
else
{
	Loop % batchPrgNo
		{
		strRetVal := PrgListIndex[A_Index]
		strTemp2 := MonStr(PrgMonToRn, strRetVal)
			if (PrgBdyBtchTog[A_Index] = strTemp2)
			strTemp := strTemp . strTemp2 . A_Space . PrgChoiceNames[strRetVal] . "|"
			else
			strTemp := strTemp . PrgChoiceNames[strRetVal] . "|"
		}
}
return strTemp
}
MonStr(PrgMonToRn, selPrgChoice)
; Rather than worry about multi-select listboxes, we have this to show selection ... - and monitor number!
{
Return "*" . PrgMonToRn[selPrgChoice] . "*"
}

MsgOnceTerminate(SelIniChoicePath, strTemp, ByRef PrgTermExit)
{
retVal := 0

	if ((Instr(strTemp, "`n")) || (Instr(strTemp, ",")))
	{
	strTemp2 := "Prgs are"
	strTemp3 := "them"
	}
	else
	{
	strTemp2 := "A Prg is"
	strTemp3 := "it"
	}


if (!PrgTermExit)
	{
	MsgBox, 8195, Active on Quit, %strTemp2% still running!`n%strTemp%`nDo you wish to close %strTemp3%?`n`nReply:`nYes: Close: (Brings up another dialog)`nNo: Do not close: (Recommended: This will not show again)`nCancel: Do not close: (This will show again): `n
	IfMsgBox, No
	{
	PrgTermExit := 1
	IniWrite, %PrgTermExit%, %SelIniChoicePath%, Prgs, PrgTermExit
	}
	else
	{
		IfMsgBox, Yes
		{
		MsgBox, 8195, Terminate on Quit, Automatically terminate Prgs when quitting?`n`nYes: Terminate (Not recommended: This will not show again) `nNo: Terminate (The `"Active on Quit`" prompt will show again)`nCancel: Do nothing (The `"Active on Quit`" prompt will show again)`n
			IfMsgBox, Cancel
			RetVal := 1
			else
			{
			PrgTermExit := 2
				IfMsgBox, Yes
				IniWrite, %PrgTermExit%, %SelIniChoicePath%, Prgs, PrgTermExit
			}
		}
	}
	}
Return retVal
}

PidMaster(PrgNo, currBatchNo, btchPrgPresetSel, PrgBatchInibtchPrgPresetSel, ByRef PrgListPIDbtchPrgPresetSel, ByRef PrgPIDMast, ToPidMast := 0)
{
	temp := 0
	if (ToPidMast)
	{
		;Backup current last selected
		loop % currBatchNo
		{
		temp := PrgBatchInibtchPrgPresetSel[A_Index]
			if (temp)
			{
				if !(temp = "NS" || temp = "FAILED" || temp = "TERM" || temp = "ENDED" || !temp)
				PrgPIDMast[temp] := PrgListPIDbtchPrgPresetSel[A_Index]
			}
		}

	 ; sanitize master last
	loop % PrgNo
	{
		temp := PrgPIDMast[A_Index]
		if (temp)
		{
			ifWinNotExist, ahk_pid%temp%
			PrgPIDMast[A_Index] := 0
		}
	}


	}
	else
	{
	; This section is called after ProcessActivePrgsAtStart so all PrgPIDMast values are either 0 or PID (not 1)
	; sanitize master first
	loop % PrgNo
	{
		temp := PrgPIDMast[A_Index]
		if (temp)
		{
			ifWinNotExist, ahk_pid%temp%
			PrgPIDMast[A_Index] := 0
		}
	}

	loop % currBatchNo
	{
	temp := PrgBatchInibtchPrgPresetSel[A_Index]
		if (temp)
		{
			if (PrgPIDMast[temp])
			PrgListPIDbtchPrgPresetSel[A_Index] := PrgPIDMast[temp]
		}
	}
	}
}



PrgLnchButtonQuit_PrgLnch:
PrgLnchGuiEscape:
;PrgLnchGuiClose: ; not mandatory
Gui PrgLnch: +OwnDialogs
critical

if (PrgTermExit <> 2)
{
	if (presetNoTest) ; Quit Button clicked
	{
	strTemp2 := ""
	temp := ""
	loop % PrgNo
	{
		foundpos := PrgPIDMast[A_Index]
		if (foundpos)
		{
			Process, Exist, % foundpos
			if (ErrorLevel)
			{
				
				if (!(strRetVal := PrgChoicePaths[A_Index]))
				Continue

				if (strRetVal := GetProcFromPath(strRetVal))
				{
				if (temp)
				strTemp2 .= temp . """" . strRetVal . """"
				else
				{
				temp := ", "
				strTemp2 := "`[Batched`]: """ . strRetVal . """"
				}
			}
			}
		}
	}
	}

	if (PrgPID)
	{
		Process, Exist, %PrgPID%
		if (ErrorLevel)
			{
				if (PrgChoicePaths[selPrgChoice])
				{
				strRetVal := PrgChoicePaths[selPrgChoice]
					if (strRetVal := GetProcFromPath(strRetVal))
					(strTemp2)? strTemp2 := "`[Test Run`]: """ . strRetVal . """`n" . strTemp2: strTemp2 := "`[Test Run`]: """ . strRetVal . """"
				}
			}
	}

	if (strTemp2)
	{
		if (MsgOnceTerminate(SelIniChoicePath, strTemp2, PrgTermExit))
		Return
	}

}


if (PrgTermExit = 2)
{ ;cancel Prgs

	loop % PrgNo
		{
		temp := PrgPIDMast[A_Index]
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

SetTimer, NewThreadforDownload, Delete ;Cleanup



strTemp2 := ""
strTemp3 := ""
loop % PrgNo
{
	strTemp := PrgChoicePaths[A_Index]
	if (strTemp)
	{
		if (!InStr(PrgLnkInf[A_Index], "*"))
		strTemp := PrgLnkInf[A_Index]

	strRetVal := WorkingDirectory(strTemp, 1)
		If (strRetVal)
		strTemp2 .= "`n" . strRetVal
		else
		{
			if (InStr(!strTemp, A_ScriptDir))
			{
			fTemp := KleenupPrgLnchFiles(1) ; An old (fixed?) bug where these ended up in wrong directory
				if (fTemp)
				{
				SplitPath, strTemp, , strTemp
				strTemp3 .= "`nFile(s): """ . fTemp . """ found in """ . strTemp . """ marked for the Recycle Bin."
				}
			}
		}
	}
}

strRetVal := WorkingDirectory(A_ScriptDir, 1)

	If (strRetVal)
	strTemp2 .= "`n" . strRetVal
	else
	KleenupPrgLnchFiles()

	if (strTemp3)
	MsgBox, 8192, PrgLnch Remnants, % (strTemp2)? ("Clean up failed for the following!`n" strTemp2 "`n`nAlso, " strTemp3): strTemp3
	else
	{
		if (strTemp2)
		MsgBox, 8192, PrgLnch Remnants, % "Clean up failed for the following!`n" strTemp2
	}

ExitApp

KleenupPrgLnchFiles(RecycleNow := 0)
{
namesToDel := ["PrgLnchLoading.jpg", "PrgLaunching.jpg", "PrgLnchProperties.jpg", "PrgLnch.chm", "PrgLnch.chw", "taskkillPrg.bat"]

temp := ""
KleenupPrgLnchFiles := ""

; Keep files if debugging
if (!A_IsCompiled)
Return

For eachNameToDel in namesToDel
{
	ifexist, % namesToDel[A_Index]
	{
		if (RecycleNow)
		{
		KleenupPrgLnchFiles .= temp . namesToDel[A_Index]
		FileRecycle, % namesToDel[A_Index]
			if (!temp)
			temp := ", "
		}
		else
		FileDelete, % namesToDel[A_Index]
	}
}
return KleenupPrgLnchFiles

}
WM_HELP(wp_notused, lParam, _msg, _hwnd)
{
local retVal := 0 ;using local this is now a global function


local Size         := NumGet(lParam +  0, "uint")
local ContextType  := NumGet(lParam +  4, "int")
local CtrlId       := Numget(lParam +  8, "int")
local ItemHandle   := Numget(lParam + 12 + 64bit * 4, "ptr")
local ContextId    := NumGet(lParam + 16 + 64bit * 8, "uint")
local MousePosX    := NumGet(lParam + 20 + 64bit * 8, "int")
local MousePosY    := NumGet(lParam + 24 + 64bit * 8, "int")

;This key must be set to 1!
;HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced >> EnableBalloonTips

if (ItemHandle = PresetLabelHwnd)
{
	if (btchPrgPresetSel && currBatchNo)
	PopPrgProperties(PrgPropsHwnd, currBatchNo, btchPrgPresetSel, PrgBatchIni%btchPrgPresetSel%, PrgChoiceNames, PrgChoicePaths, PrgLnkInf, IniFileShortctSep, PrgLnchOpt.X(), PrgLnchOpt.Y(), PrgLnchOpt.Width(), PrgLnchOpt.Height())
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
if (ItemHandle = IniChoiceHwnd)
retVal := RunChm("PrgLnch Batch`\PrgLnch Batch", "LnchPadSlots")
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
if (ItemHandle = PrgPriorityHwnd)
retVal := RunChm("PrgLnch Config`\PrgLnch Config", "Priority")
else
if (ItemHandle = PrgMinMaxHwnd)
retVal := RunChm("PrgLnch Config`\PrgLnch Config", "MinMax")
else
if (ItemHandle = BordlessHwnd)
retVal := RunChm("PrgLnch Config`\PrgLnch Config", "Borderless")
else
if (ItemHandle = PrgLnchHdHwnd)
retVal := RunChm("PrgLnch Config`\PrgLnch Config", "HidePrgLnchonRun")
else
if (ItemHandle = resolveShortctHwnd)
retVal := RunChm("PrgLnch Config`\PrgLnch Config", "ResolveShortcut")
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
	if (retVal < 0)
	MsgBox, 8192, , Could not find the Help file. Has it, or the script been moved?
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

if (!FileExist(A_ScriptDir . "\PrgLnch.chm"))
return -1

WinGetPos, x, y, w, , A

if (chmTopic)
run, %htmlHelp%:%A_ScriptDir%\PrgLnch.chm::/%chmTopic%.htm#%Anchor%,, UseErrorLevel
else
run, %htmlHelp%:%A_ScriptDir%\PrgLnch.chm::/About%A_Space%PrgLnch.htm,, UseErrorLevel
sleep, 120


if (!A_LastError) ; uses last found window
{
if (WinExist("PrgLnch_Help"))
	{
	;if  not maximised
	WinGet, temp, MinMax
	;Tablet mode perhaps? https://autohotkey.com/boards/viewtopic.php?f=6&t=15619
	;We are launching as "normal" but just in case this is overidden by user modifying shortcut properties. (probably not)
	if (!temp)
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
DopowerPlan(planToChangeTo := "")
{

Static oldSchemeGUID, oldDesc, arrPowerPlanNames := []
tmp := 0

if (planToChangeTo)
{
	if (!oldDesc)
	defPowerPlanNames := ["Balanced", "Power saver", "High performance"]

	loop, 3
	{
	if (planToChangeTo = defPowerPlanNames[A_Index])
	tmp := 1
	} 
/*
; If a default plan is only to be set
	if (!tmp)
	{
	Msgbox % planToChangeTo " is not a default power plan!"
	Return
	}
*/
}
else
{
	if (oldDesc)
	{
	tmp := Dllcall("powrprof.dll\PowerSetActiveScheme", "Ptr", 0, "Ptr", oldSchemeGUID, "Uint")
		if (tmp)
		Msgbox % "PowerSetActiveScheme error: " tmp

	VarSetCapacity(oldDesc, 0)
	VarSetCapacity(oldSchemeGUID, 0)
	arrPowerPlanNames := ""
	Return
	}

}



ACCESS_SCHEME := 16 ; For PowerEnumerate
VarSetCapacity(desc, szdesc := 1024)
VarSetCapacity(schemeGUID, szguid := 16)
	if (!oldDesc)
	{
	VarSetCapacity(oldDesc, szdesc)
	VarSetCapacity(oldSchemeGUID, szguid)
	}


if (!oldDesc)
{
	; GetActivePwrScheme the older flavour
	if (DllCall("powrprof\PowerGetActiveScheme", "Ptr", 0, "Ptr*", oldSchemeGUID, "Uint"))
	Msgbox GetActivePwrScheme fail error!
	tmp := Dllcall("powrprof.dll\PowerReadFriendlyName", "Ptr", 0, "Ptr", oldSchemeGUID, "Ptr", 0, "Ptr", 0, "Ptr", 0, "Ptr*", szdesc) ;sdesc :LPDWORD
	if (tmp != 0)
	{
	Msgbox % "First call of PowerReadFriendlyName failed with " tmp "."
	}
	
	tmp := Dllcall("powrprof.dll\PowerReadFriendlyName", "Ptr", 0, "Ptr", oldSchemeGUID, "Ptr", 0, "Ptr", 0, "str", oldDesc, "Ptr*", szdesc) ;use the updated szdesc from first call of fn
	if (tmp != 0)
	{
	Msgbox % "Second call of PowerReadFriendlyName failed with " tmp "."
	}

}


Loop
{
	r := Dllcall("powrprof.dll\PowerEnumerate", "Ptr", 0, "Ptr", 0, "Ptr", 0, "Uint", ACCESS_SCHEME, "Uint", A_Index-1, "Ptr", &schemeGUID, "Uint*", szguid) ;DWORD
		if (r != 0)
		break

	tmp := Dllcall("powrprof.dll\PowerReadFriendlyName", "Ptr", 0, "Ptr", &schemeGUID, "Ptr", 0, "Ptr", 0, "Ptr", 0, "Ptr*", szdesc) ;sdesc :LPDWORD
	if (tmp != 0)
	{
	Msgbox % "Third call of PowerReadFriendlyName failed with " tmp "."
	}
	
	tmp := Dllcall("powrprof.dll\PowerReadFriendlyName", "Ptr", 0, "Ptr", &schemeGUID, "Ptr", 0, "Ptr", 0, "str", desc, "ptr*", szdesc) ;use the updated szdesc from first call of fn
	if (tmp != 0)
	{
	Msgbox % "Fourth call of PowerReadFriendlyName failed with " tmp "."
	}



	plan .= A_Index-1 " - " desc "`n"
	if (planToChangeTo)
	{
		if (desc = planToChangeTo)
		{
		tmp := Dllcall("powrprof.dll\PowerSetActiveScheme", "Ptr", 0, "Ptr", &schemeGUID, "Uint")
			if (tmp)
			Msgbox % "PowerSetActiveScheme error: " tmp
		r := 259
		Break
		}
	}
	else ; just enumerate and fill on first call
	arrPowerPlanNames[A_Index] := desc

}

	if (r != 259)  ;ERROR_NO_MORE_ITEMS- (should never get here)
	Msgbox % "PowerEnumerate error: " r




Msgbox Available power schemes:`n%plan%`nCurrent GUID: %oldSchemeGUID%




VarSetCapacity(schemeGUID, 0)
VarSetCapacity(desc, 0)

	; If only one entry (Balanced) then it's a Modern Standby or "S0 Low Power Idle" install, not the usual S3 Sleep state!. Other power schemes may not be created.
	if (arrPowerPlanNames.Length() = 1) ; Final call to function
	{
	VarSetCapacity(oldDesc, szdesc)
	VarSetCapacity(oldSchemeGUID, szguid)
	}


if (planToChangeTo)
return
else
return arrPowerPlanNames

}






































BackToPrgLnch:
SetTimer, WatchSwitchOut, Off
SetTimer, WatchSwitchBack, Off

Tooltip

UDM_SETRANGE := 0X0465

strRetVal := WorkingDirectory(A_ScriptDir, 1)
If (strRetVal)
MsgBox, 8192, Missing script, % strRetVal

SplashImage, PrgLnchLoading.jpg, A B,,, LnchSplash
WinGetPos, , , w, h, LnchSplash

WinMove, LnchSplash, , % PrgLnchOpt.X() + (PrgLnchOpt.Width() - w)/2, % PrgLnchOpt.Y() + (PrgLnchOpt.Height() - h)
sleep, 120
GuiControl, PrgLnch:, batchPrgStatus, % ReorgBatch(batchPrgNo, maxBatchPrgs, btchPrgPresetSel, PrgMonToRn, PrgBatchIni%btchPrgPresetSel%, currBatchNo, PrgListIndex, PrgBdyBtchTog)

sleep 60

GuiControl, PrgLnch:, ListPrg, % PopBtchListBox(PrgChoiceNames, PrgNo, PrgMonToRn, PrgBdyBtchTog, PrgListIndex, batchPrgNo, 1)
;fix the updown
temp := batchPrgNo-1
fTemp := 0
ffTemp := MakeLong(fTemp, temp)
SendMessage, %UDM_SETRANGE%, , %ffTemp%, , ahk_id %MovePrgHwnd%
ffTemp := 0


Gosub FrontendInit
presetNoTest := 2
GoSub InitBtchStat
Return


InitBtchStat:
PidMaster(PrgNo, currBatchNo, btchPrgPresetSel, PrgBatchIni%btchPrgPresetSel%, PrgListPID%btchPrgPresetSel%, PrgPIDMast)


if (currBatchNo) ; defpreset set
{
	if (IsCurrentBatchRunning(currBatchNo, PrgListPID%btchPrgPresetSel%))
	{
	SetTimer, WatchSwitchOut, 1000
	GuiControl, PrgLnch:, RunBatchPrg, &Cancel Batch
	}
	else
	{
		strRetVal := "|"
			loop % currBatchNo
			{
			strRetVal := strRetVal . "Not Active" . "|"
			}
		GuiControl, PrgLnch:, batchPrgStatus, % strRetVal
		GuiControl, PrgLnch:, RunBatchPrg, &Run Batch
	}
}
else
{
	loop % PrgNo
	{
		if (PrgPIDMast[A_Index])
		{
		SetTimer, WatchSwitchOut, 1000
		Break
		}
	}

}

Gui, PrgLnchOpt: Show, Hide, PrgLnchOpt
WinMover(PrgLnch.Hwnd(), "d r", PrgLnchOpt.Width() * 3/4, PrgLnchOpt.Height())
SplashImage, PrgLnchLoading.jpg, Hide,,,LnchSplash
Return


CheckVerPrg:
if (selPrgChoiceTimer != selPrgChoice)
; have clicked on!
SetTimer, CheckVerPrg, Delete
else 
{
verTemp := PrgVer[selPrgChoice]
	if (verTemp)
	{
		if (Util_VersionCompare(PrgVerNew, verTemp))
		GuiControl, PrgLnchOpt:, newVerPrg, % "  Update Available"
		else
		GuiControl, PrgLnchOpt:, newVerPrg, % "  Prg is up to date"

	IniProc(selPrgChoice)
	}
	else
	GuiControl, PrgLnchOpt:, newVerPrg, % "  No Version of Prg!"

	SetTimer, CheckVerPrg, Delete
}
Return

MonitorsSub:
Tooltip
	if A_OSVersion in WIN_2003,WIN_XP,WIN_2000
	; Above expression : No spaces and doesn't like brackets!
	ToolTip, % "Unable to display VSync for this OS!"
	;Probably bombs the script anyway
	else
	MDMF_GetMonHandle(targMonitorNum) ; only works for Vista+
Return

TestMode:
Gui, PrgLnchOpt: Submit, Nohide
Tooltip
IniProc(selPrgChoice)
Return
ChangeMode:
Gui, PrgLnchOpt: Submit, Nohide
Tooltip
IniProc(selPrgChoice)
Return
DynamicMode:
Gui, PrgLnchOpt: Submit, Nohide
Tooltip
IniProc(selPrgChoice)
Return
TmpMode:
Gui, PrgLnchOpt: Submit, Nohide
Tooltip
IniProc(selPrgChoice)
Return

ChgResonSwitchChk:
Gui, PrgLnchOpt: Submit, Nohide
Tooltip
PrgChgResonSwitch[selPrgChoice] := ChgResonSwitch
IniProc(selPrgChoice)
Return

PrgMinMaxChk:
Gui, PrgLnchOpt: Submit, Nohide
Tooltip
GuiControlGet, PrgMinMaxVar, PrgLnchOpt:, PrgMinMax
PrgRnMinMax[selPrgChoice] := PrgMinMaxVar

IniProc(selPrgChoice)

if (PrgPID) ;test only from config
{
	if (PrgMinMaxVar = 1)
	WinMaximize, ahk_pid %PrgPID%
	else
	{
		if (PrgMinMaxVar = -1)
		WinRestore, ahk_pid %PrgPID%
		else
		WinMinimize, ahk_pid %PrgPID%		
	}
}

Return

PrgPriorityChk:
Gui, PrgLnchOpt: Submit, Nohide
Tooltip
PrgRnPriority[selPrgChoice] := PrgPriority
IniProc(selPrgChoice)
if (PrgPID) ;test only from config
{
(!PrgPriority)? temp := "B": (PrgPriority = 1)? temp := "H": temp := "N"
Process, priority, %PrgPID%, % temp
}
Return

BordlessChk:
GuiControlGet, temp, PrgLnchOpt: FocusV
	if (!Instr(temp, "Bordless"))
	Return
Gui, PrgLnchOpt: Submit, Nohide
Tooltip

	if (PrgPID) ;test only from config
	BordlessProc(PrgPos, PrgMinMaxVar, PrgStyle, PrgBordless, selPrgChoice, dx, dy, scrWidth, scrHeight, PrgPID)
	else
	{
	PrgBordless[selPrgChoice] := Bordless
	IniProc(selPrgChoice)
	}

Return

PrgLnchHideChk:
Gui, PrgLnchOpt: Submit, Nohide
Tooltip
PrgLnchHide[selPrgChoice] := PrgLnchHd
IniProc(selPrgChoice)
Return

resolveShortctChk:
GuiControlGet, temp, PrgLnchOpt: FocusV

if (temp != "resolveShortct")
Return
Gui, PrgLnchOpt: Submit, Nohide
Tooltip
;ChkPrgNames better than txtPrgChoice

if (!PrgChoiceNames[selPrgChoice] || ChkPrgNames(PrgChoiceNames[selPrgChoice], PrgNo))
navShortcut := resolveShortct
else
{
PrgResolveShortcut[selPrgChoice] := resolveShortct
strTemp := PrgChoicePaths[selPrgChoice]
	if (resolveShortct)
	{
	PrgLnkInf[selPrgChoice] := GetPrgLnkVal(strTemp, IniFileShortctSep, 1 , 1)

	;update paths if requ'd
	strTemp := PrgChoicePaths[selPrgChoice]
	strTemp := SubStr(strTemp, 1, InStr(strTemp, IniFileShortctSep,,0) - 1)
	PrgChoicePaths[selPrgChoice] := strTemp . IniFileShortctSep . PrgLnkInf[selPrgChoice]

	PrgURLEnable(PrgUrlTest, UrlPrgIsCompressed, selPrgChoice, PrgChoicePaths, selPrgChoiceTimer, PrgLnkInf, PrgUrl, PrgVer, PrgVerNew, UpdturlHwnd, IniFileShortctSep)

	GuiControl, PrgLnchOpt: Enable, PrgMinMax
	GuiControl, PrgLnchOpt: Enable, PrgLAA
	SetTimer, CheckVerPrg, 5000
	}
	else
	{
	SetTimer, CheckVerPrg, Delete
		PrgLnkInf[selPrgChoice] := GetPrgLnkVal(strTemp, IniFileShortctSep, 1)
		if (CheckPrgPaths(selPrgChoice, IniFileShortctSep, PrgChoicePaths, PrgLnkInf, PrgResolveShortcut))
		{
		PrgResolveShortcut[selPrgChoice] := 0
		GuiControl, PrgLnchOpt: Disable, resolveShortct
		}
		else
		{
		GuiControl, PrgLnchOpt: Disable, PrgMinMax
		GuiControl, PrgLnchOpt: Disable, PrgLAA
		}
		PrgURLEnable(PrgUrlTest, UrlPrgIsCompressed, selPrgChoice, PrgChoicePaths, selPrgChoiceTimer, PrgLnkInf, PrgUrl, PrgVer, PrgVerNew, UpdturlHwnd, IniFileShortctSep, 1)
	}
PrgCmdLineEnable(selPrgChoice, PrgCmdLine, cmdLinHwnd, PrgResolveShortcut, 1)
}


IniProc(selPrgChoice)

Return


PrgLAARn:
Tooltip
DcmpExecutable(selPrgChoice, PrgChoicePaths, PrgLnkInf, IniFileShortctSep)
Return

UpdturlPrgLnchText:
Tooltip
GuiControlGet, temp, PrgLnchOpt: FocusV
if (temp = "MkShortcut" || temp = "CmdLinPrm")
Return
Gui, PrgLnchOpt: Submit, Nohide

	if (temp = "UpdturlPrgLnch")
	{
		if (StrLen(UpdturlPrgLnch) > 2082) ;http://stackoverflow.com/questions/417142/what-is-the-maximum-length-of-a-url-in-different-browsers
		{
		MsgBox, 8192, , Too long! ;Probably bombs the script anyway
		UpdturlPrgLnch := ""
		}

		if (UpdturlPrgLnch)
		{
			if (PrgUrlTest)
			{
			PrgUrlTest := UpdturlPrgLnch
			Tooltip
			}
			else
			PrgURLGui(PrgUrl, PrgUrlTest, SelPrgChoice)

		}
		else
		{
			PrgURLGui(PrgUrl, PrgUrlTest, SelPrgChoice, 1)
			IniProc(selPrgChoice)
		}
	}
Return


CheckDefaultPrg:
Gui, PrgLnchOpt: Submit, Nohide
Tooltip
if (DefaultPrg)
{
defPrgStrng := PrgChoiceNames[selPrgChoice]
IniWrite, %defPrgStrng%, %SelIniChoicePath%, Prgs, StartupPrgName
}
else
{
defPrgStrng := "None"
IniWrite, None, %SelIniChoicePath%, Prgs, StartupPrgName
}
Return

RegoCheck:
Gui, PrgLnchOpt: Submit, Nohide
Tooltip
IniProc(selPrgChoice)
Return

CmdLinPrmSub:
GuiControlGet, strTemp, PrgLnchOpt: FocusV
	if (strTemp != "CmdLinPrm")
	Return

Gui, PrgLnchOpt: Submit, Nohide
Tooltip
sleep 120 ;slow input
GuiControlGet, strTemp, PrgLnchOpt:, CmdLinPrm
if (strTemp)
{
	if (StrLen(strTemp) > 20000) ;length?
	{
	strTemp := SubStr(txtPrgChoice, 1, 20000)
	GuiControl, PrgLnchOpt:, CmdLinPrm, %strTemp%
	}
}

PrgCmdLine[selPrgChoice] := strTemp
IniProc(selPrgChoice)
Return


PrgURLGui(ByRef PrgUrl, ByRef PrgUrlTest, SelPrgChoice, NoSaveURL := 0)
{
	GuiControl, PrgLnchOpt:, newVerPrg
	PrgUrlTest := ""
	if (NoSaveURL)
	{
	ToolTip
	GuiControl, PrgLnchOpt:, UpdtPrgLnch, % "&Update Prg"
		if (NoSaveURL = 1)
		{
		GuiControl, PrgLnchOpt: Disable, UpdtPrgLnch
		PrgUrl[selPrgChoice] := ""
		}
		else
		{
		GuiControl, PrgLnchOpt: Enable, UpdtPrgLnch
		GuiControl, PrgLnchOpt: Enable, UpdturlPrgLnch
		GuiControl, PrgLnchOpt:, UpdturlPrgLnch, % PrgUrl[selPrgChoice]
		}

	}
	else
	{
	GuiControl, PrgLnchOpt:, UpdtPrgLnch, % "&Save URL"
	ToolTip, % "Type to modify, Del to remove, or click ""Save URL"" to save URL."
	GuiControl, PrgLnchOpt: Enable, UpdtPrgLnch
	GuiControlGet, PrgUrlTest, PrgLnchOpt:, UpdturlPrgLnch
	}
}

SetEditCueBanner(HWND, Cue, IsCombo := 0)
{
; requires AHL_L: JustMe
Static EM_SETCUEBANNER := (0x1500 + 1)
Static CB_SETCUEBANNER := (0x1700 + 3)
if (IsCombo)
Return DllCall("User32.dll\SendMessageW", "Ptr", HWND, "Uint", CB_SETCUEBANNER, "Ptr", True, "WStr", Cue)
else
Return DllCall("User32.dll\SendMessageW", "Ptr", HWND, "Uint", EM_SETCUEBANNER, "Ptr", True, "WStr", Cue)
}
MakeLong(LoWord, HiWord) ; courtesy Chris
{
return (HiWord << 16) | (LoWord & 0xffff)
}






















;Monitor functions
iDevNo:
Gui, PrgLnchOpt: Submit, Nohide
Gui PrgLnchOpt: +OwnDialogs
Tooltip
GuiControlGet, fTemp, PrgLnchOpt:, iDevNum
GuiControlGet, strTemp, PrgLnchOpt: FocusV

if (strTemp = "iDevNum")
{
	if (fTemp != targMonitorNum)
	{
	targMonitorNum := fTemp
	GuiControl, ,PrgLnchOpt: allModes, 0
	}

	;Must reset reslist
	GoSub CheckModes
	SetResDefaults(targMonitorNum, currRes, Dynamic, FMode, scrWidth, scrHeight, scrFreq, scrWidthDef, scrHeightDef, scrFreqDef, scrWidthDefArr, scrHeightDefArr, scrFreqDefArr, 1)

	if (PrgMonToRn[selPrgChoice]) ; save it if a Prg
	{
		; invalid monitor?
			if (iDevNumArray[targMonitorNum] < 10)
			targMonitorNum := PrgLnch.Monitor
		PrgMonToRn[selPrgChoice] := targMonitorNum
		IniProc(selPrgChoice)
		if (!FindStoredRes(SelIniChoicePath, scrWidth, scrHeight, scrFreq))
		GuiControl, PrgLnchOpt: ChooseString, ResIndex, %currRes%

	}
	else
	{
	if (txtPrgChoice = "None" && iDevNumArray[targMonitorNum] > 9)
	GuiControl, PrgLnchOpt: Enable, RnPrgLnch
	}
	GoSub FixMonColours
}
else
{
	
	if (txtPrgChoice != "None")
	{
		if ((scrWidthArr[selPrgChoice] && scrHeightArr[selPrgChoice] && scrFreqArr[selPrgChoice]))
		{
		scrWidth := scrWidthArr[selPrgChoice]
		scrHeight := scrHeightArr[selPrgChoice]
		scrFreq := scrFreqArr[selPrgChoice]
		}
		else
		{
		; If by misadventurer the values are zero
		MsgBox, 8192, No Resolution Mode, Monitor parameters for the selected or startup Prg do not exist!`n`nDefaults assumed.`nIt's recommended to save the parameters by reselecting the target monitor from the Monitor List, and, if required, changing the resolution mode.
		GetDisplayData(PrgLnch.Monitor, targMonitorNum, dispMonNamesNo, , , , scrWidth, scrHeight, , scrFreq , -1, 1)
		scrWidthDef := scrWidth
		scrHeightDef := scrHeight
		scrFreqDef := scrFreq
		}
	}

	SetResDefaults(fTemp, currRes, Dynamic, FMode, scrWidth, scrHeight, scrFreq, scrWidthDef, scrHeightDef, scrFreqDef, scrWidthDefArr, scrHeightDefArr, scrFreqDefArr, 1)
	;Must reset reslist
	GoSub CheckModes
}

Return


FixMonColours:
	GuiControl, PrgLnchOpt:, Monitors, % dispMonNames[targMonitorNum]

	if (iDevNumArray[targMonitorNum] < 10) ;dec masks
	{
	GuiControl, PrgLnchOpt: Disable, RnPrgLnch
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

		if (iDevNumArray[targMonitorNum] > 99)
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

	ResIndexList := GetResList(PrgLnch.Monitor, targMonitorNum, dispMonNamesNo, iDevNumArray, dispMonNames, ResArray, scrWidthDef, scrHeightDef, scrFreqDef, allModes, -1)

	if (!PresetLabelHwnd)  ;Update all at Load
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
ResIndexList := % "|" . GetResList(PrgLnch.Monitor, targMonitorNum, dispMonNamesNo, iDevNumArray, dispMonNames, ResArray, scrWidthDef, scrHeightDef, scrFreqDef, allModes)

;Not the g-label ResListBox!
GuiControl, PrgLnchOpt:, ResIndex, %ResIndexList%
GuiControlGet currRes, PrgLnchOpt:, currRes ; Why?
GuiControl, PrgLnchOpt: ChooseString, ResIndex, %currRes%
GuiControl, PrgLnchOpt: Show, ResIndex
Return




ResListBox:
Tooltip


if (Allmodes)
GuiControl, PrgLnchOpt: ChooseString, ResIndex, %currRes%
else
{
fTemp := 0
GuiControlGet, strTemp, PrgLnchOpt:, ResIndex
	Loop, Parse, ResIndexList, |
	{
		If (strTemp = A_Loopfield)
		{
		fTemp := A_Index
		Break
		}
	}
	if (fTemp)
	{
	scrWidth := ResArray[fTemp - 1, 1]
	scrHeight := ResArray[fTemp - 1, 2]
	scrFreq := ResArray[fTemp - 1, 3]

		if (PrgChoicePaths[selPrgChoice])
		IniProc(selPrgChoice)
	}
	else
	GuiControl, PrgLnchOpt: ChooseString, ResIndex, %currRes%
}




Return

FindStoredRes(SelIniChoicePath, scrWidth, scrHeight, scrFreq)
{
	Stat := 0, strTemp2 := "", strTemp := ""

	ControlGet, strTemp, List,, ListBox1, % "ahk_id" PrgLnchOpt.Hwnd()
	Loop, Parse, strTemp, `n
	{
	strTemp2 := ""
	strTemp2 .= scrWidth . " `, " . scrHeight . " @ " . scrFreq . "Hz "
	if (strTemp2 = A_LoopField)
	{
	GuiControl, PrgLnchOpt: ChooseString, ResIndex, % strTemp2
	Stat := 1
	Break
	}
	}
if (!stat)
{
	IniRead, strTemp, %SelIniChoicePath%, General, ResClashMsg
	if (!strTemp)
	{
	MsgBox, 8196, , % "Mismatch detected in desired resolution data for this monitor! This usually involves differing frequency values appertaining to the same resolution preset.`nExcerpt from MSDN: `n`n""In Windows 7 and newer versions of Windows, when a user selects 60Hz, the OS stores a value of 59.94Hz. However, 59Hz is shown in the Screen refresh rate in Control Panel, even though the user selected 60Hz."" `n`nThe current resolution mode might have also been set from the ""List all Compatible"" selection. The recommended action is to reselect the required screen resolution from the list.`n`n`nYes: Continue (Warn like this next time) `nNo: Continue (This will not show again) `n"
		IfMsgBox, Yes
		strTemp := "" ; dummy condition
		else
		IniWrite, 1, %SelIniChoicePath%, General, ResClashMsg
	}
}
Return stat
}
SetResDefaults(targMonitorNum, currRes, Dynamic, FMode, ByRef scrWidth, ByRef scrHeight, ByRef scrFreq, ByRef scrWidthDef, ByRef scrHeightDef, ByRef scrFreqDef, ByRef scrWidthDefArr, ByRef scrHeightDefArr, ByRef scrFreqDefArr, SaveVars := 0)
{
	if (SaveVars)
	{
		if (scrWidthDefArr[targMonitorNum]) ;no need if  values have been read already
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































;Navigational
PrgChoice:
Gui, PrgLnchOpt: Submit, Nohide
Gui PrgLnchOpt: +OwnDialogs
Tooltip
SendMessage 0x147, 0, 0, , ahk_id %PrgChoiceHwnd%  ; CB_GETCURSEL


If (ErrorLevel = "FAIL")
	{
	Gui, PrgLnchOpt: Submit, Nohide
	MsgBox, 8192, , CB_GETCURSEL Failed
	}
else
	{

	retVal := ErrorLevel << 32 >> 32
	if (retVal < 0) ;Did the user type?
		{
		sleep 120 ;slow down input?
		GuiControlGet, txtPrgChoice, PrgLnchOpt:, PrgChoice

		;Pre-validation

		if (txtPrgChoice != "None")
		{
		loop %maxbatchPrgs%
			{

			temp := "*" . A_Index . "* "  ; Required for Batch selection
			if (InStr(txtPrgChoice, temp))
			txtPrgChoice := StrReplace(txtPrgChoice, temp, "*" . A_Index . "*")
			}

			; Not good
			txtPrgChoice := StrReplace(txtPrgChoice, "|", "1")
			; As a matter of interest, we need not be concerned with a literal `n or `r in the text file, as the reads are char by char: (char(10) & char (13)).

			if (strLen(txtPrgChoice) > 1)
			{
			strTemp := RegExReplace(txtPrgChoice, "\w", "", temp)
				if (!temp)
				{
				GuiControl, PrgLnchOpt: Text, PrgChoice,
				txtPrgChoice := "Prg" . selPrgChoice
				SetEditCueBanner(PrgChoiceHwnd, "Alphanumeric Name", 1)
				ControlFocus, , ahk_id %MkShortcutHwnd%
				return
				}
			}
		}

		if (StrLen(txtPrgChoice) > 20000) ;length?
		{
		txtPrgChoice := SubStr(txtPrgChoice, 1, 20000)
		GuiControl, PrgLnchOpt: Text, PrgChoice, %txtPrgChoice%
		}
		GuiControlGet temp, PrgLnchOpt:, MkShortcut

		if (temp != "Just Change Res.") ; Otherwise don't care if typed over "None"
		{
			if (ChkPrgNames(txtPrgChoice, PrgNo))
			{
			;"0" happens rarely on "timing glitch??"
			GuiControl, PrgLnchOpt: Text, PrgChoice,
			txtPrgChoice := "Prg" . selPrgChoice
			SetEditCueBanner(PrgChoiceHwnd, "Prg Name Reserved", 1)
			ControlFocus, , ahk_id %MkShortcutHwnd%
			}
			else
			{
				if (txtPrgChoice)
				{
					if (temp="Make Shortcut")
					ToolTip, "Click `"Make Shortcut`" to save."
					else
					{
					ToolTip, "Click `"Change Shortcut`" to save."
					GuiControl, PrgLnchOpt:, Remove Shortcut, % ChgShortcutVar
					}
				}
				else
				{
				GuiControl, PrgLnchOpt:, MkShortcut, Remove Shortcut
					if (PrgChoicePaths[selPrgChoice]) ;Path already exist?
					ToolTip, "Click `"Remove Shortcut`" or hit Del to confirm."
					else
					ToolTip, "Click `"Remove Shortcut`" or hit Del to remove unexpected data from reference."
				}
			}
		}

		}
	else ; Clicked here
		{
		SetTimer, CheckVerPrg, Delete ;vital

		selPrgChoice := retVal
		GuiControlGet, txtPrgChoice, PrgLnchOpt:, PrgChoice ;one of the list items
		if (retVal)
			{
			GuiControl, PrgLnchOpt:, RnPrgLnch, &Test Run Prg
				if (PrgChoiceNames[selPrgChoice])
				{
				CheckPrgPaths(selPrgChoice, IniFileShortctSep, PrgChoicePaths, PrgLnkInf, PrgResolveShortcut)


				PrgCmdLineEnable(selPrgChoice, PrgCmdLine, cmdLinHwnd, PrgResolveShortcut, !InStr(PrgLnkInf[selPrgChoice], "*"), InStr(PrgLnkInf[selPrgChoice], "|"))
				GuiControl, PrgLnchOpt: Enable, MkShortcut
				GuiControl, PrgLnchOpt:, MkShortcut, % ChgShortcutVar
				GuiControl, PrgLnchOpt: Enable, RnPrgLnch
				PrgURLEnable(PrgUrlTest, UrlPrgIsCompressed, selPrgChoice, PrgChoicePaths, selPrgChoiceTimer, PrgLnkInf, PrgUrl, PrgVer, PrgVerNew, UpdturlHwnd, IniFileShortctSep)
				borderToggle := DcmpExecutable(selPrgChoice, PrgChoicePaths, PrgLnkInf, IniFileShortctSep, 1)
				TogglePrgOptCtrls(txtPrgChoice, navShortcut, borderToggle, selPrgChoice, PrgChgResonSwitch, PrgRnMinMax, PrgRnPriority, PrgBordless, PrgLnchHide, 1, InStr(PrgLnkInf[selPrgChoice], "\", false, StrLen(PrgLnkInf[selPrgChoice])) || InStr(PrgLnkInf[selPrgChoice], "|"))

				GuiControlGet, targMonitorNum, PrgLnchOpt:, iDevNum

				if (targMonitorNum = PrgMonToRn[selPrgChoice])
					{
						if ((scrWidthArr[selPrgChoice] && scrHeightArr[selPrgChoice] && scrFreqArr[selPrgChoice]))
						{ 
						scrWidth := scrWidthArr[selPrgChoice]
						scrHeight := scrHeightArr[selPrgChoice]
						scrFreq := scrFreqArr[selPrgChoice]
						}
						else
						GoSub IDevNo
					}
					else
					{
						if ((scrWidthArr[selPrgChoice] && scrHeightArr[selPrgChoice] && scrFreqArr[selPrgChoice]))
						{ 
						scrWidth := scrWidthArr[selPrgChoice]
						scrHeight := scrHeightArr[selPrgChoice]
						scrFreq := scrFreqArr[selPrgChoice]
						}

					targMonitorNum := PrgMonToRn[selPrgChoice]
					GoSub iDevNo
					GoSub FixMonColours
					GuiControl, PrgLnchOpt: ChooseString, iDevNum, %targMonitorNum%
					}

					if (!FindStoredRes(SelIniChoicePath, scrWidth, scrHeight, scrFreq))
					GuiControl, PrgLnchOpt: ChooseString, ResIndex, %currRes%


				}
				else
				{
				GuiControl, PrgLnchOpt: Text, resolveShortct, Shortcut Nav. (Dlg)
				GuiControl, PrgLnchOpt: Enable, MkShortcut
				GuiControl, PrgLnchOpt:, MkShortcut, Make Shortcut
				GuiControl, PrgLnchOpt: Disable, RnPrgLnch
				PrgURLEnable(PrgUrlTest, UrlPrgIsCompressed, selPrgChoice, PrgChoicePaths, selPrgChoiceTimer, PrgLnkInf, PrgUrl, PrgVer, PrgVerNew, UpdturlHwnd, IniFileShortctSep, 1)
				TogglePrgOptCtrls(txtPrgChoice, navShortcut)
				}

			}
		else
			{
				selPrgChoice := 1
				GuiControl, PrgLnchOpt:, RnPrgLnch, Change Res`.
				GuiControl, PrgLnchOpt: Disable, DefaultPrg
				GuiControl, PrgLnchOpt:, MkShortcut, Just Change Res.
				GuiControl, PrgLnchOpt: Disable, Just Change Res.
				GuiControl, PrgLnchOpt: Text, resolveShortct, Shortcut Nav. (Dlg)
				PrgURLEnable(PrgUrlTest, UrlPrgIsCompressed, selPrgChoice, PrgChoicePaths, selPrgChoiceTimer, PrgLnkInf, PrgUrl, PrgVer, PrgVerNew, UpdturlHwnd, IniFileShortctSep, 1)
				TogglePrgOptCtrls(txtPrgChoice, navShortcut)

				GuiControlGet, targMonitorNum, PrgLnchOpt:, iDevNum
				if (iDevNumArray[targMonitorNum] < 10)
				{
				GuiControl, PrgLnchOpt: Enable, RnPrgLnch
				targMonitorNum := PrgLnch.Monitor
				}
				else
				GuiControl, PrgLnchOpt: Enable, RnPrgLnch
				GoSub CheckModes
				GuiControl, PrgLnchOpt: ChooseString, iDevNum, %targMonitorNum%
				GoSub FixMonColours

			}

		}
	;Startup Default?

	SetStartupname(SelIniChoicePath, defPrgStrng, PrgChoiceNames, selPrgChoice)

	}

Return


MakeShortcut:
Gui, PrgLnchOpt: Submit, Nohide
Tooltip
Gui, PrgLnchOpt: +OwnDialogs

GuiControlGet temp, PrgLnchOpt:, MkShortcut

if ((txtPrgChoice = "Prg Removed" || txtPrgChoice = "") && (temp = "Make Shortcut"))
txtPrgChoice := "Prg" . selPrgChoice


if (txtPrgChoice = "")
{

	if (PrgPIDMast[selPrgChoice])
	{
	txtPrgChoice := PrgChoiceNames[selPrgChoice]
	GuiControl, PrgLnchOpt:, MkShortcut, % ChgShortcutVar
	GuiControl, PrgLnchOpt:, PrgChoice, %strPrgChoice%
	GuiControl, PrgLnchOpt: Choose, PrgChoice, % selPrgChoice + 1
	MsgBox, 8192, , % "Sorry, a Prg cannot be removed if it is active in Batch!"
	Return
	}

	;SelPrgChoice is last selected
	MsgBox, 8193, , Remove Shortcut?
	IfMsgBox, Ok
	{
	SetTimer, CheckVerPrg, Delete ;vital to do first

	;Remove default
	IniRead, defPrgStrng, %SelIniChoicePath%, Prgs, StartupPrgName ;Space just in case None is absent

	if (defPrgStrng = PrgChoiceNames[selPrgChoice])
	{
	defPrgStrng := "None"
	IniWrite, None, %SelIniChoicePath%, Prgs, StartupPrgName
	}
	GuiControl, PrgLnchOpt: , DefaultPrg, 0
	GuiControl, PrgLnchOpt: Disable, DefaultPrg

	strRetVal := WorkingDirectory(A_ScriptDir, 1)
	If (strRetVal)
	MsgBox, 8192, Prg Path, % strRetVal

	IniProc(selPrgChoice, 1)
	strPrgChoice := ComboBugFix(strPrgChoice, Prgno)
	PrgChoiceNames[selPrgChoice] := ""
	PrgChoicePaths[selPrgChoice] := ""
	PrgResolveShortcut[selPrgChoice] := 0
	PrgCmdLine[selPrgChoice] := ""
	PrgMonToRn[selPrgChoice] := 0
	PrgRnPriority[selPrgChoice] := -1
	PrgBordless[selPrgChoice] := 0
	PrgLnchHide[selPrgChoice] := 0
	PrgRnMinMax[selPrgChoice] := 0
	PrgLnkInf[selPrgChoice] := ""
	PrgUrl[selPrgChoice] := ""

	GuiControl, PrgLnchOpt:, PrgChoice, %strPrgChoice%
	GuiControl, PrgLnchOpt: Choose, PrgChoice, % selPrgChoice + 1
	GuiControl, PrgLnchOpt:, MkShortcut, Make Shortcut
	GuiControl, PrgLnchOpt: Disable, RnPrgLnch
	PrgURLEnable(PrgUrlTest, UrlPrgIsCompressed, selPrgChoice, PrgChoicePaths, selPrgChoiceTimer, PrgLnkInf, PrgUrl, PrgVer, PrgVerNew, UpdturlHwnd, IniFileShortctSep, 1)
	TogglePrgOptCtrls(txtPrgChoice, navShortcut)
	iDevNum := 1
	GuiControl, PrgLnchOpt:, Choose, iDevNum
	GoSub FixMonColours
	}
	else
	{
	txtPrgChoice := PrgChoiceNames[selPrgChoice]
	GuiControl, PrgLnchOpt:, MkShortcut, % ChgShortcutVar
	GuiControl, PrgLnchOpt:, PrgChoice, %strPrgChoice%
	GuiControl, PrgLnchOpt: Choose, PrgChoice, % selPrgChoice + 1
	}

}
else
{
	if (strLen(txtPrgChoice) = 1)
	{
		GuiControl, PrgLnchOpt: Text, PrgChoice,
		txtPrgChoice := "Prg" . selPrgChoice
		SetEditCueBanner(PrgChoiceHwnd, "Prg Name too short", 1)
		Return
	}

	if (ChkPrgNames(txtPrgChoice, PrgNo))
	temp := 0
	else
	{
		if (txtPrgChoice = "Prg Removed")
		temp := 0
		else
		{
		if (ChgShortcutVar = "Change Shortcut Name")
		{
			if (PrgChoicePaths[selPrgChoice])
			temp := 1
			else
			temp := 0
		}
		else ; "Change Shortcut"
		{
			if (PrgChoicePaths[selPrgChoice])
			{
			MsgBox, 8195, Name or Path?, Confirm name change of the Prg (if any) or select a new path?`nIf "No," the entry can be later removed with <DEL>.`n`nReply:`nYes: Confirm Prg name change (Warn like this next time) `nNo: Confirm Prg name change (Recommended: This will not show again)`nCancel: Select a new path (Warn like this next time)`n
				IfMsgBox, Cancel
				temp := 0
				else
				{
				temp := 1
					IfMsgBox, No
					{
					IniWrite, 1, %SelIniChoicePath%, General, ChangeShortcutMsg
					ChgShortcutVar := "Change Shortcut Name"
					GuiControl, PrgLnchOpt:, MkShortcut, % ChgShortcutVar
					}
				}
			}
			else
			temp := 0
		}
	}
	}

	if (temp)
	{
	loop % PrgNo
	{
		if (A_Index != selPrgChoice)
		{
			if (txtPrgChoice = PrgChoiceNames[A_Index])
			{
			MsgBox, 8192, Duplicate Name, A Prg exists with this name already. Please use another.
			Return
			}
		}
	}
	SetStartupname(SelIniChoicePath, defPrgStrng, PrgChoiceNames, selPrgChoice, txtPrgChoice)
	PrgChoiceNames[selPrgChoice] := txtPrgChoice
	IniProc(selPrgChoice)
	strPrgChoice := ComboBugFix(strPrgChoice, Prgno)
	GuiControl, PrgLnchOpt:, PrgChoice, %strPrgChoice%
	GuiControl, PrgLnchOpt: Choose, PrgChoice, % selPrgChoice + 1
	PrgCmdLineEnable(selPrgChoice, PrgCmdLine, cmdLinHwnd, PrgResolveShortcut, !InStr(PrgLnkInf[selPrgChoice], "*"), InStr(PrgLnkInf[selPrgChoice], "|"))

	}
	else
	{
	;Watch out for TIMERS!
	Thread, NoTimers
	if (resolveShortct)
	FileSelectFile, strTemp, 1, % A_StartMenu "\Programs", Open a file`, Shortcuts resolved, (*.exe; *.bat; *.com; *.cmd; *.pif; *.ps1; *.msc; *.lnk; *.scr)
	else
	FileSelectFile, strTemp, 32, % A_StartMenu "\Programs", Open a file or Shortcut, (*.exe; *.bat; *.com; *.cmd; *.pif; *.ps1; *.msc; *.lnk; *.scr)
	Thread, NoTimers, false
	if (!ErrorLevel)
		{
		FileGetAttrib, temp, % strTemp
		;The following does not affect folder shortcuts
		If (InStr(temp, "D"))
		{
			PrgChoicePaths[selPrgChoice] := ""
			txtPrgChoice := "Prg" . selPrgChoice
			MsgBox, 8192, , Unable to use this Prg!
			Return
		}

		PrgChoicePaths[selPrgChoice] := strTemp
		if (ChkPrgNames(txtPrgChoice, PrgNo))
		{
		temp := SubStr(strTemp, 1, InStr(strTemp, ".") - 1)
		strTemp := SubStr(temp, InStr(temp, "\",, -1) + 1)
			if (InStr(strTemp, "PrgLnch") || InStr(strTemp, "BadPath"))
			{
				PrgChoicePaths[selPrgChoice] := ""
				txtPrgChoice := "Prg" . selPrgChoice
				MsgBox, 8192, Prg Name, Unable to use this Prg!
				Return
			}
		PrgChoiceNames[selPrgChoice] := strTemp
		}
		else
		PrgChoiceNames[selPrgChoice] := txtPrgChoice


		;check dup names
		Loop % PrgNo
		{
		if (selPrgChoice != A_Index)
		{
		if (PrgChoiceNames[selPrgChoice] = PrgChoiceNames[A_Index])
		PrgChoiceNames[selPrgChoice] := PrgChoiceNames[selPrgChoice] . selPrgChoice
		}
		}

		;valid monitor?
		GuiControlGet, targMonitorNum, PrgLnchOpt:, iDevNum
		if (iDevNumArray[targMonitorNum] < 10)
		targMonitorNum := PrgLnch.Monitor
		PrgMonToRn[selPrgChoice] := targMonitorNum



		strTemp := PrgChoicePaths[selPrgChoice]
		strRetVal := GetPrgLnkVal(strTemp, IniFileShortctSep)
			if (InStr(strRetVal, "*"))
			;Invalid working  directory- now strip the last "\"
			strTemp2 := WorkingDirectory(strTemp)
			else
			{
				if (InStr(strRetVal, "|"))
				{
				; Directory links cannot be "resolved"
				strTemp2 := WorkingDirectory(strTemp)
				strRetVal .= "*"
				}
				else
				{
				PrgResolveShortcut[selPrgChoice] := 0
				; strip the last "\":  gets working directory of lnk, if any
				strTemp2 := WorkingDirectory(strRetVal)
				}
			}

			if (strTemp2)
			{
			MsgBox, 8192, Prg Path, % strTemp2
			txtPrgChoice := "Prg" . selPrgChoice
			PrgLnkInf[selPrgChoice] := ""
			PrgChoicePaths[selPrgChoice] := ""
			PrgChoiceNames[selPrgChoice] := ""
			Return
			}
			else
			{
			PrgLnkInf[selPrgChoice] := strRetVal
			GuiControl, PrgLnchOpt: Text, resolveShortct, Resolve shortcut
				if (!InStr(strRetVal, "*"))
				{
				;Append resolved path
				strRetVal := GetPrgLnkVal(strTemp, IniFileShortctSep, 1, 1)
				PrgChoicePaths[selPrgChoice] .= IniFileShortctSep . strRetVal
				}
			}

		txtPrgChoice := PrgChoiceNames[selPrgChoice]
		PrgCmdLineEnable(selPrgChoice, PrgCmdLine, cmdLinHwnd, PrgResolveShortcut, !InStr(strRetVal, "*"), InStr(strRetVal, "|"))



		PrgLnchHide[selPrgChoice] := 0
		IniProc(selPrgChoice)
		strPrgChoice := ComboBugFix(strPrgChoice, Prgno)



		GuiControl, PrgLnchOpt:, MkShortcut, % ChgShortcutVar
		GuiControl, PrgLnchOpt:, PrgChoice, %strPrgChoice%
		GuiControl, PrgLnchOpt: Choose, PrgChoice, % selPrgChoice + 1
		GuiControl, PrgLnchOpt: Enable, DefaultPrg
		GuiControl, PrgLnchOpt: Enable, RnPrgLnch


		borderToggle := DcmpExecutable(selPrgChoice, PrgChoicePaths, PrgLnkInf, IniFileShortctSep, 1)

		TogglePrgOptCtrls(txtPrgChoice, navShortcut, borderToggle, selPrgChoice, PrgChgResonSwitch, PrgRnMinMax, PrgRnPriority, PrgBordless, PrgLnchHide, 1, InStr(PrgLnkInf[selPrgChoice], "\", false, StrLen(PrgLnkInf[selPrgChoice])) || InStr(PrgLnkInf[selPrgChoice], "|"))

		GoSub iDevNo
		GoSub FixMonColours

		GuiControl, PrgLnchOpt: ChooseString, iDevNum, %targMonitorNum%

		if (!FindStoredRes(SelIniChoicePath, scrWidth, scrHeight, scrFreq))
		GuiControl, PrgLnchOpt: ChooseString, ResIndex, %currRes%

		PrgURLEnable(PrgUrlTest, UrlPrgIsCompressed, selPrgChoice, PrgChoicePaths, selPrgChoiceTimer, PrgLnkInf, PrgUrl, PrgVer, PrgVerNew, UpdturlHwnd, IniFileShortctSep)

		GuiControlGet, temp, PrgLnchOpt:, DefaultPrg
		if (temp) ;if enabled reset string
			{
			defPrgStrng := PrgChoiceNames[selPrgChoice]
			IniWrite, % defPrgStrng, %SelIniChoicePath%, Prgs, StartupPrgName
			}
		}
	;else PrgChoicePaths is made blank
	}
}
Return

ChkCmdLineValidFName(ByRef testStr, CmdLine := 0)
{
temp := 0, fTemp := 0
;No commas either
testStr := RegExReplace(testStr, "[\\\/:*?""<>|,]", , temp)
; temp is no of replacements

; whitespaces
if (CmdLine)
testStr := RegExReplace(testStr, "\s+", , (!temp)? temp: fTemp)

Return % (temp || fTemp)
}


ChkPrgNames(testName, PrgNo, IniBox := "", forDeletion := 0)
{
; Returns 1 if testName is a spare, bad or default slot name


	If (Inibox)
	spr := IniBox
	else
	spr = Prg

	Loop % PrgNo
	{
	if (testName = spr . A_Index)
	return 1
	}

	if (forDeletion)
	return 0

	if (testName = "0" || testName = "Error" || testName = "PrgLnch" || testName = "BadPath")
	return 1
	else
	return 0
}
ComboBugFix(strPrgChoice, PrgNo)
{
strTemp := "", strTemp2 := "", foundpos1 := 0, strRetVal:= "", foundpos := InStr(strPrgChoice, "||")
;Addresses weird bug when partially matched names are removed and added to the combobox
; Update: Not required anymore as problem was bad variable/ function parameter
strTemp := StrReplace(strPrgChoice, "|", "|", foundpos1)
	if (foundpos1 != PrgNo + 2)
	{
	MsgBox, 8192, , PrgLnch has an encountered an unexpected error! Attempting Restart!
	strRetVal := WorkingDirectory(A_ScriptDir, 1)
	If (strRetVal)
	MsgBox, 8192, ComboBugFix, % strRetVal
	if (FileExist("PrgLnch.exe"))
	Return RestartPrgLnch(0)
	}


	if (foundpos)
	{
		Loop % PrgNo
		{
		if (InStr(strPrgChoice, "|",,, A_Index + 1) = foundpos)
		{
		strTemp := Substr(strPrgChoice, 1, foundpos) . "Prg" . A_Index

		strTemp2 := Substr(strPrgChoice, foundpos + 1)
		foundpos1 := InStr(strTemp2, "||") ;' yikes already checked! Null terminator removed?
		if (foundpos1)
		strTemp2 := "|Prg" . A_Index + 1 . Substr(strTemp2, foundpos1 + 1)

		Return strTemp . strTemp2
		}
		}
	}
	else
	return strPrgChoice
}
PrgCmdLineEnable(selPrgChoice, PrgCmdLine, cmdLinHwnd, PrgResolveShortcut, noLnk := 0, dirShortCut := 0)
{

temp := PrgResolveShortcut[selPrgChoice]
strTemp := PrgCmdLine[selPrgChoice]


if (noLnk || dirShortCut) ;only if not a lnk file with separator. dirShortCut does not have separator, so is conditional -i.e. (!noLnk && dirShortCut) is impossible
{
	if (temp)
	{
	GuiControl, PrgLnchOpt: Enable, CmdLinPrm
	GuiControl, PrgLnchOpt:, CmdLinPrm
		if (strTemp)
		GuiControl, PrgLnchOpt:, CmdLinPrm, % strTemp
		else
		SetEditCueBanner(cmdLinHwnd, "Cmd Line Extras")
	}
	else
	{
		if (dirShortCut)
		{
		GuiControl, PrgLnchOpt:, CmdLinPrm
		GuiControl, PrgLnchOpt: Disable, CmdLinPrm
		}
		else
		{
		GuiControl, PrgLnchOpt: Enable, CmdLinPrm
		GuiControl, PrgLnchOpt:, CmdLinPrm
			if (strTemp)
			GuiControl, PrgLnchOpt:, CmdLinPrm, % strTemp
			else
			SetEditCueBanner(cmdLinHwnd, "Cmd Line Extras")
		}
	}

	if (dirShortCut)
	{
	GuiControl, PrgLnchOpt:, resolveShortct, 0
	GuiControl, PrgLnchOpt: Disable, resolveShortct
	}
	else
	{
	GuiControl, PrgLnchOpt: Enable, resolveShortct
	GuiControl, PrgLnchOpt:, resolveShortct, % temp
	}
}
else
{
GuiControl, PrgLnchOpt:, CmdLinPrm

	if (strTemp)
	GuiControl, PrgLnchOpt:, CmdLinPrm, % strTemp
	else
	SetEditCueBanner(cmdLinHwnd, "Cmd Line Extras")

GuiControl, PrgLnchOpt: Enable, CmdLinPrm
GuiControl, PrgLnchOpt: Disable, resolveShortct
}
GuiControl, PrgLnchOpt: Text, resolveShortct, Resolve Shortcut
}

ExtractPrgPath(selPrgChoice, PrgChoicePaths, PrgPth, PrgLnkInf, ByRef IsaPrgLnk, IniFileShortctSep)
{
IsaPrgLnk := 0
prgPath := (PrgPth)? PrgPth: PrgChoicePaths[selPrgChoice]

if (InStr(PrgLnkInf[selPrgChoice], "*")) ; Lnk has invalid working directory OR regular Prg
{
	;case where prgPath is a directory link
	if (InStr(prgPath, IniFileShortctSep,, 0))
	{
	IsaPrgLnk := 1
	PrgPath := Substr(prgPath, 1, InStr(prgPath, IniFileShortctSep,, 0) -1)
	}
}
else
{
	if (InStr(prgPath, IniFileShortctSep,, 0))
	{
		; shortcut not resolved
		if (InStr(PrgLnkInf[selPrgChoice], "\", false, StrLen(PrgLnkInf[selPrgChoice])))
		{
		prgPath := SubStr(prgPath, 1, InStr(prgPath, IniFileShortctSep,, 0) -1)
		IsaPrgLnk := 1
		}
		else ;shortcut resolved
		prgPath := PrgLnkInf[selPrgChoice]
	}

}
Return %prgPath%
}

PrgURLEnable(ByRef PrgUrlTest, ByRef UrlPrgIsCompressed, selPrgChoice, PrgChoicePaths, ByRef selPrgChoiceTimer, PrgLnkInf, PrgUrl, ByRef PrgVer, ByRef PrgVerNew, UpdturlHwnd, IniFileShortctSep, UrlDisableGui := 0)
{
currPrgUrl := PrgUrl[selPrgChoice]
PrgverOld := PrgVer[selPrgChoice]
IsaPrgLnk := 0
if (!UrlDisableGui)
{
PrgPth := ExtractPrgPath(selPrgChoice, PrgChoicePaths, 0, PrgLnkInf, IsaPrgLnk, IniFileShortctSep)
	if (!FileExist(PrgPth))
	{
	GuiControl, PrgLnchOpt: Disable, UpdturlPrgLnch
	Return
	}
}


GuiControl, PrgLnchOpt: -ReadOnly, UpdturlPrgLnch

	if (currPrgUrl)
	{
		if (IsaPrgLnk)
		; Should never get here!
		MsgBox, 8192, , % "The Prg " PrgPth "`nshould not be a "".lnk"" file!"
		else
		{
			PrgURLGui(PrgUrl, PrgUrlTest, SelPrgChoice, 2)

			; duplication, but just in case something happened
			FileGetVersion, PrgverOld, % PrgPth
			if (ErrorLevel)
			{
			PrgVer[selPrgChoice] := 0
			MsgBox, 8192, , % "Problem with retrieving local version info for file " PrgPth
			}
			else
			PrgVer[selPrgChoice] := PrgverOld


			UrlPrgIsCompressed := ChkURLPrgExe(currPrgUrl) ; Checks for type

			selPrgChoiceTimer := selPrgChoice
				if (GetPrgVersion(currPrgUrl, PrgVerNew))
				GuiControl, PrgLnchOpt:, newVerPrg, Info unavailable
				else
				{
				GuiControl, PrgLnchOpt:, newVerPrg, % "  Checking Update..." ; … ellipsis wait for Unicode build
				SetTimer, CheckVerPrg, 5000
				}
		}
	}
	else
	{
	GuiControl, PrgLnchOpt:, UpdturlPrgLnch
	PrgURLGui(PrgUrl, PrgUrlTest, SelPrgChoice, 1)
	PrgVerNew := 0
		If (UrlDisableGui)
		{
		GuiControl, PrgLnchOpt: Disable, UpdturlPrgLnch
		PrgVer[selPrgChoice] := 0
		}
		else
		{
			if (IsaPrgLnk)
			{
			GuiControl, PrgLnchOpt: Disable, UpdturlPrgLnch
			PrgVer[selPrgChoice] := 0
			}
			else
			{ 
				; set ver
				if (PrgverOld)
				{
				GuiControl, PrgLnchOpt: Enable, UpdturlPrgLnch
				SetEditCueBanner(UpdturlHwnd, "Url Progenitor of Prg")				
				}
				else
				{
				FileGetVersion, PrgverOld, % PrgPth
					if (ErrorLevel)
					{
					PrgPth := AssocQueryApp(PrgPth)
						If (PrgPth)
						{
						FileGetVersion, PrgverOld, % PrgPth
							if (ErrorLevel)
							{
							MsgBox, 8192, , % "Problem with retrieving version info from the following Prg:`n" PrgPth "."
							PrgVer[selPrgChoice] := 0
							GuiControl, PrgLnchOpt: Disable, UpdturlPrgLnch
							}
							else
							{
							;Replaced Get Focus & Send, ^a & Tooltip
							PrgVer[selPrgChoice] := PrgverOld
							GuiControl, PrgLnchOpt: Enable, UpdturlPrgLnch
							SetEditCueBanner(UpdturlHwnd, "Url Progenitor of Prg")
							}
						}
						else
						{
						; assume directory shortcut
						PrgVer[selPrgChoice] := 0
						GuiControl, PrgLnchOpt: Disable, UpdturlPrgLnch
						}
					}
					else
					{
					GuiControl, PrgLnchOpt: Enable, UpdturlPrgLnch
					SetEditCueBanner(UpdturlHwnd, "Url Progenitor of Prg") ;Replaced Get Focus & Send, ^a & Tooltip
					PrgVer[selPrgChoice] := PrgverOld
					}
				}
			}
		}

	}
}

ChkURLPrgExe(TstUrl)
{
strTemp := 0, temp := 0
;strTemp := SubStr(PrgUrlTest, InStr(PrgUrlTest, ".",, -1) + 1)
SplitPath, TstUrl,,, strTemp
if (strTemp = "exe" ) || (strTemp = "bat" ) || (strTemp = "com" ) || (strTemp = "cmd" ) || (strTemp = "pif" ) || (strTemp = "msc" ) || (strTemp = "scr" )
Return 0
else
{

	if (strTemp = "gz") || (strTemp = "Z") || (strTemp = "bz2") || (strTemp = "lzma") || (strTemp = "xz")
	{
	SplitPath, strTemp,,, temp
	if (temp = "tar")
	Return 1
	}
	else
	{
	if (strTemp = "tgz") || (strTemp = "tbz2") || (strTemp = "tlz") || (strTemp = "txz") || (strTemp = "xz") || (strTemp = "7z") || (strTemp = "alz") || (strTemp = "arj") || (strTemp = "cab") || (strTemp = "cfs") ||	(strTemp = "jar") || (strTemp = "lzh") || (strTemp = "lha") || (strTemp = "paq6") || (strTemp = "paq7") || (strTemp = "paq8") || (strTemp = "pea") || (strTemp = "rar") || (strTemp = "paq6") || (strTemp = "sit") || (strTemp = "sitx") || (strTemp = "xar") || (strTemp = "zip") || (strTemp = "zipx") || (strTemp = "zpaq") || (strTemp = "zz")
	Return 1
	; There are others: apk arc ba b1 car cpt dar dgc dmg ear ha hki ice kgb partimg pim qda rk sen shk sqx  {uc .uc0 .uc2 .ucn .ur2 .ue2} uha war wim xp3 yz1 zoo
	}
Return -1
} 

}

; https://autohotkey.com/board/topic/54927-regread-associated-program-for-a-file-extension/
AssocQueryApp(prgPath)
{
SplitPath, prgPath, , , Ext

if (InStr(Ext, "exe") || InStr(Ext, "com") || InStr(Ext, "scr")) ; "real" executables
	strPrg := prgPath
else
{
	RegRead, type, HKCU, Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.%Ext%, Application
		If (ErrorLevel)
		{
			;Default setting
		RegRead, type, HKCR, .%Ext%
		RegRead, act , HKCR, %type%\shell
			If (ErrorLevel)
			act = open
		RegRead, strPrg , HKCR, %type%\shell\%act%\command
		}
		else
		{ ;Current user has overridden default setting
		RegRead, act, HKCU, Software\Classes\Applications\%type%\shell
			If (ErrorLevel)
			act = open
		RegRead, strPrg, HKCU, Software\Classes\Applications\%type%\shell\%act%\command
		}
		; strip first quote
	foundpos := InStr(strPrg, """")

	strPrg := SubStr(strPrg, foundpos + 1, StrLen(strPrg))
	; strip last quote and all that follows
	foundpos := InStr(strPrg, """")

	if (foundpos)
	strPrg := SubStr(strPrg, 1, foundpos-1)
}
return strPrg
}

; https://autohotkey.com/boards/viewtopic.php?t=5959
Util_VersionCompare(other,local)
{
	ver_other:=StrSplit(other,".")
	ver_local:=StrSplit(local,".")
	for _index, _num in ver_local
		if ( (ver_other[_index]+0) > (_num+0) )
			return 1
		else if ( (ver_other[_index]+0) < (_num+0) )
			return 0
	return 0
}


#IfWinActive, PrgLnch Options ahk_class AutoHotkeyGUI
{
Del::

GuiControlGet, strTemp, PrgLnchOpt: FocusV
GuiControlGet, temp, PrgLnchOpt:, MkShortcut
	if (strTemp = "PrgChoice")
	{
		if (InStr(temp, "Change Shortcut"))
		{
		txtPrgChoice := ""
		ControlSetText,,,ahk_id %PrgChoiceHwnd%
		GuiControl, PrgLnchOpt:, MkShortcut, Remove Shortcut
			if (PrgChoicePaths[selPrgChoice])
			ToolTip, "Click `"Remove Shortcut`" or hit Del to confirm."
			else
			ToolTip, "Click `"Remove Shortcut`" or hit Del to remove unexpected data from reference."
			Return
		}
		else
		{
			if (temp = "Remove Shortcut")
			{
				if (ChkPrgNames(txtPrgChoice, PrgNo))
				strPrgChoice := ComboBugFix(strPrgChoice, PrgNo)
				else
				{
				txtPrgChoice := ""
				Gosub, MakeShortcut
				}
			}
		}
	}
	else
	{
		if (strTemp="UpdturlPrgLnch")
		{
			ToolTip
			GuiControl, PrgLnchOpt:, UpdturlPrgLnch
			GuiControl, PrgLnchOpt: Disable, UpdtPrgLnch
			GuiControl, PrgLnchOpt:, newVerPrg
			PrgUrl[selPrgChoice] := ""
			IniProc(selPrgChoice)
		}
		else
		{
			if (strTemp="CmdLinPrm")
			{
				ToolTip
				GuiControl, PrgLnchOpt:, CmdLinPrm
				PrgCmdLine[selPrgChoice] := ""
				IniProc(selPrgChoice)
			}
			else
			{
			if (temp = "Remove Shortcut")
			{
				if (ChkPrgNames(txtPrgChoice, PrgNo))
				strPrgChoice := ComboBugFix(strPrgChoice, Prgno)
				else
				{
				txtPrgChoice := ""
				Gosub, MakeShortcut
				}
			}
			else
			Tooltip
			}
		} 
	}
Return
}



#IfWinActive, PrgLnch ahk_class AutoHotkeyGUI
{
Del::
GuiControlGet, strTemp, PrgLnch: FocusV
	if (strTemp = "PresetName")
	{
		if (ffTemp = 1)
		Return
	GuiControl, PrgLnch:, PresetName,
	;PresetNameSub automatically invoked
	}
	else
	{
		if (strTemp = "IniChoice")
		GoSub PrepDelIni
	}
Return
}

SetStartupname(SelIniChoicePath, ByRef defPrgStrng, PrgChoiceNames, selPrgChoice, newName := 0)
{
	if (newName)
	{
		if (PrgChoiceNames[selPrgChoice] = defPrgStrng)
		{
		IniWrite, % newName, %SelIniChoicePath%, Prgs, StartupPrgName
		defPrgStrng := newName
		}
	}
	else
	{
	IniRead, defPrgStrng, %SelIniChoicePath%, Prgs, StartupPrgName, %A_Space%
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
}


;https://autohotkey.com/boards/viewtopic.php?f=5&t=17712&p=196504#p196504
WM_LBUTTONDOWN(wParam, lParam, Msg, hWnd)
{
WM_HELPMSG := 0x0053
	if (Msg = WM_HELPMSG)
	WM_HELP(0, lParam, WM_HELPMSG, hWnd)
	else
	{
    MouseGetPos, , , mWin, mControl ; mX relative to FORM
	; Bizarro results with OutputVarControl so get class instead
	WinGetClass, class, ahk_id %mWin%
		if (class="tooltips_class32")
		ToolTip
		else
		GuiControlGet, tmp, Name, % mControl
	}
}



























;Batch Launch
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
sleep, 60

; set lnchPrgIndex, lnchStat 
GuiControlGet temp, PrgLnchOpt:, RnPrgLnch
GuiControlGet strTemp, PrgLnch:, RunBatchPrg
if ((presetNoTest && strTemp = "&Run Batch") || (!presetNoTest && temp = "&Test Run Prg"))
{
	lnchPrgIndex := selPrgChoice ; changes shortly
	strRetVal := ChkExistingProcess(PrgLnkInf, presetNoTest, selPrgChoice, currBatchNo, PrgBatchIni%btchPrgPresetSel%, PrgChoicePaths, IniFileShortctSep, 1)


	if (strRetVal)
	{
		if (strRetVal == "PrgLnch")
		{
		MsgBox, 8192, , Cannot launch this Prg!
		Return
		}
		if (strRetVal == "BadPath")
		Return

		IniRead, fTemp, %SelIniChoicePath%, General, PrgAlreadyMsg
		if (!fTemp)
		{
		MsgBox, 8195, , One or more Prgs scheduled for start matches a process running with `nthe same name. Might be an issue depending on instance requisites.`n`"%strRetVal%`"`n`nReply:`nYes: Continue (Warn like this next time) `nNo: Continue (This will not show again) `nCancel: Do nothing: `n
			IfMsgBox, Yes
			fTemp := 0 ; dummy condition
			else
			{
				IfMsgBox, No
				IniWrite, 1, %SelIniChoicePath%, General, PrgAlreadyMsg
				else
				return
			}
		}

	}

	if (!presetNoTest && temp = "&Test Run Prg")
	{
	lnchStat := -1
	targMonitorNum := PrgMonToRn[lnchPrgIndex]
	}
	else
	lnchStat := 1

}
else
{
	if (!(presetNoTest) && temp = "Change Res`.")
	{
	lnchPrgIndex := 0
	lnchStat := -1
	GuiControlGet, targMonitorNum, PrgLnchOpt:, iDevNum
	}
	else ; cancel
	{
		if (presetNoTest)
		{
		lnchStat := 1
		lnchPrgIndex := -1 ; lnchPrgIndex again set in loop
		}
		else
		{
		lnchPrgIndex := -selPrgChoice
		lnchStat := -1
		}

	}
}

;init status list vars
strTemp2 := PrgChoicePaths[selPrgChoice]
strTemp := "|" ;Building PrgStatus list


loop % ((presetNoTest)? currBatchno: 1)
{

; Update Prg index
	if (presetNoTest)
	{
		temp := PrgBatchIni%btchPrgPresetSel%[A_Index]
		scrWidth := scrWidthArr[temp]
		scrHeight := scrHeightArr[temp]
		scrFreq := scrFreqArr[temp]
		targMonitorNum := PrgMonToRn[temp]

		if (lnchPrgIndex > 0)
		{
		;Init all to batch
		PrgListPID%btchPrgPresetSel%[A_Index] := "NS"
		;Hide the quit and config buttons!
		HideShowLnchControls(quitHwnd, GoConfigHwnd)

		lnchPrgIndex := temp

		temp := PrgChoicePaths[lnchPrgIndex]
		WinMover(, , , , "PrgLaunching.jpg")
		sleep, % (!PrgIntervalLnch)? 2000: (PrgIntervalLnch = -1)? 4000: 6000
		}
		else
		{
		lnchPrgIndex := -temp
		temp := PrgChoicePaths[-lnchPrgIndex]
		}
	}

	strRetVal := LnchPrgOff(SelIniChoicePath, A_Index, lnchStat, PrgChoiceNames, (presetNoTest)? temp: strTemp2, PrgLnkInf, IniFileShortctSep, (presetNoTest)? currBatchno: 1, lnchPrgIndex, PrgCmdLine, iDevNumArray, dispMonNamesNo, PrgRnMinMax, PrgRnPriority, PrgBordless, borderToggle, scrWidth, scrHeight, scrFreq, scrWidthDef, scrHeightDef, scrFreqDef, targMonitorNum, PrgPID, PrgListPID%btchPrgPresetSel%, PrgPos, PrgMinMaxVar, PrgStyle, x, y, w, h, dx, dy, Fmode)

	if (strRetVal)
	{  ;Lnch failed for current Prg

	if (strRetVal = "|*")
	strTemp .= "Started" . "|"
	else
	{
		if (lnchPrgIndex)
		{
			if (lnchPrgIndex > 0)
			{
				if (lnchStat = 1)
				strTemp .= "Failed" . "|"

			MsgBox, 8192, , % strRetVal
			}
		}
		else
		MsgBox, 8192, , % strRetVal
	}
	}
	else
	{
	SetResDefaults(targMonitorNum, currRes, Dynamic, FMode, scrWidth, scrHeight, scrFreq, scrWidthDef, scrHeightDef, scrFreqDef, scrWidthDefArr, scrHeightDefArr, scrFreqDefArr)
		if (lnchStat < 0) ;test run
		{
			if (lnchPrgIndex > 0)
			{
				if (PrgLnchHide[selPrgChoice])
				Gui, PrgLnchOpt: Show, Hide, PrgLnchOpt
				else
				{
				WinMover(PrgLnchOpt.Hwnd(), "d r")
				HideShowTestRunCtrls()
				Gui, PrgLnchOpt: Show
				}
			}
			else ;just cancelled- but not from a hidden form!
			CleanupPID(SelIniChoicePath, currBatchNo, PrgLnch.Monitor, lastMonitorUsedInBatch, PrgMonToRn, PrgNo, PrgPIDMast, presetNoTest, PrgListPID%btchPrgPresetSel%, PrgStyle, dx, dy, PrgBordless, PrgLnchHide, PrgPID, selPrgChoice, Fmode, dispMonNamesNo, scrWidth, scrHeight, scrWidthDef, scrHeightDef, scrFreqDef, waitBreak)
		}
		else
		{
			if (lnchPrgIndex > 0)
			{
				if (PrgLnchHide[lnchPrgIndex])
				Gui, PrgLnch: Show, Hide, PrgLnch
				else
				WinMover(PrgLnch.Hwnd(), "d r", PrgLnchOpt.Width() * 3/4, PrgLnchOpt.Height())
			batchActive := 1
			strTemp .= "Active" . "|"
			}
			else
			{
			; Cancelling the lot!
			if (lnchPrgIndex < 0)
			strTemp .= "Not Active" . "|"
			if (currBatchno = A_Index)
			CleanupPID(SelIniChoicePath, currBatchNo, PrgLnch.Monitor, lastMonitorUsedInBatch, PrgMonToRn, PrgNo, PrgPIDMast, presetNoTest, PrgListPID%btchPrgPresetSel%, PrgStyle, dx, dy, PrgBordless, PrgLnchHide, PrgPID, selPrgChoice, Fmode, dispMonNamesNo, scrWidth, scrHeight, scrWidthDef, scrHeightDef, scrFreqDef, waitBreak, 1)
			}
			; Update Master
			PrgPIDMast[lnchPrgIndex] := PrgListPID%btchPrgPresetSel%[A_Index]
		}
	}
SplashImage, PrgLaunching.jpg, Hide,,,LnchSplash
}


;Start Timer & update status list & fix buttons
Thread, NoTimers, false


if (lnchStat < 0)
	{
		if (PrgPID)
		{
		waitBreak := 0
		SetTimer, WatchSwitchOut, -1000
		}
		else ;in case something else running
		{
			loop % PrgNo
			{
				if (PrgPIDMast[A_Index])
				{
				waitBreak := 0
				SetTimer, WatchSwitchOut, 1000
				Break
				}
			}
		}
	}
	else
	{

	GuiControl, PrgLnch:, batchPrgStatus, %strTemp%

	HideShowLnchControls(quitHwnd, GoConfigHwnd, 1)

	temp := 0

	if (IsCurrentBatchRunning(currBatchNo, PrgListPID%btchPrgPresetSel%))
	; not testing for batchActive as a Batch Prg might have been cancelled, but others in the preset are still active
		{
		GuiControl, PrgLnch:, RunBatchPrg, &Cancel Batch
		waitBreak := 0
		SetTimer, WatchSwitchOut, 1000
		}
		else
		{
			if (PrgPID)
			{
			waitBreak := 0
			SetTimer, WatchSwitchOut, 1000
			}
		GuiControl, PrgLnch:, RunBatchPrg, &Run Batch
		}
	}
Return

LnchPrgOff(SelIniChoicePath, prgIndex, lnchStat, PrgNames, PrgPaths, PrgLnkInf, IniFileShortctSep, currBatchno, lnchPrgIndex, PrgCmdLine, iDevNumArray, dispMonNamesNo, PrgRnMinMax, PrgRnPriority, PrgBordless, borderToggle, ByRef scrWidth, ByRef scrHeight, ByRef scrFreq, ByRef scrWidthDef, ByRef scrHeightDef, ByRef scrFreqDef, ByRef targMonitorNum, ByRef PrgPID, ByRef PrgListPID, ByRef PrgPos, ByRef PrgMinMaxVar, ByRef PrgStyle, ByRef x, ByRef y, ByRef w, ByRef h, ByRef dx, ByRef dy, Fmode)
{


strRetVal := "", PrgLnchMon := 0, primaryMon := 0, temp := 0, fTemp := 0, ms := 0, md := 0, msw := 0, mdw := 0, msh := 0, mdh := 0, PrgPIDtmp := 0, PrgPrty := "N", IsaPrgLnk := 0, mdRight := 0, mdLeft := 0, mdBottom := 0, mdTop := 0, msRight := 0, msLeft := 0, msBottom := 0, msTop := 0
ERROR_FILE_NOT_FOUND := 0x2
ERROR_ACCESS_DENIED := 0x5
ERROR_CANCELLED := 0x4C7



PrgLnchMon := GetPrgLnchMonNum(iDevNumArray, dispMonNamesNo, primaryMon)
if (PrgLnch.Monitor != PrgLnchMon)
{
	IniRead, fTemp, %SelIniChoicePath%, General, LnchPrgMonWarn
	if (!fTemp)
	{
	MsgBox, 8196, PrgLnch Moved, PrgLnch has been moved to another monitor %PrgLnchMon%.`nAll messages will be directed there.`n`nReply:`nYes: Continue (Warn like this next time)`nNo: Continue (This will not show again) `n
	IfMsgBox, No
	IniWrite, 1, %SelIniChoicePath%, General, LnchPrgMonWarn
	}
PrgLnch.Monitor := PrgLnchMon
}


if (DefResNoMatchRes(SelIniChoicePath, Fmode, scrWidth, scrHeight, scrWidthDef, scrHeightDef) < 0)
Return "Cancelled by User!"


if (lnchPrgIndex > 0) ;Running
{
	;Fix priority
	temp := (PrgRnPriority[lnchPrgIndex])
	(!temp)? PrgPrty := "B": (temp = 1)? PrgPrty := "H": PrgPrty := "N"

	PrgPaths := ExtractPrgPath(lnchPrgIndex, 0, PrgPaths, PrgLnkInf, IsaPrgLnk, IniFileShortctSep)

	IfExist, % PrgPaths
	;If Notepad, copy Notepad exe to  %A_ScriptDir% and it will not run! (Windows 10 1607)
	{
	strRetVal := WorkingDirectory(PrgPaths, 1)
	If (strRetVal)
	Return % strRetVal

	If (!IsaPrgLnk && PrgCmdLine[lnchPrgIndex])
	PrgPaths := PrgPaths . A_Space . "" . PrgCmdLine[lnchPrgIndex] . ""


	if (targMonitorNum = PrgLnchMon)
	{

	;WinHide ahk_class Shell_TrayWnd ;Necessary?

	if (scrWidth < scrWidthDef)
		{
		IniRead, fTemp, %SelIniChoicePath%, General, LoseGuiChangeResWrn
			if (!fTemp)
			{
			MsgBox, 8195, , In the unlikely situation of the PrgLnch Gui relocating `noff the screen after switching to lower resolutions, `nuse <CTRL-Alt-P> to return the Gui to focus.`n`nReply:`nYes: Continue (Warn like this next time)`nNo: Continue (This will not show again) `nCancel: Do nothing: `n
			IfMsgBox, No
			IniWrite, 1, %SelIniChoicePath%, General, LoseGuiChangeResWrn
			else
			{
				IfMsgBox, Cancel
				Return "Cancelled by user!"
			}
			}
		}
	if (DefResNoMatchRes(SelIniChoicePath, Fmode, scrWidth, scrHeight, scrWidthDef, scrHeightDef))
		{

		strRetVal := ChangeResolution(scrWidth, scrHeight, scrFreq, targMonitorNum)
		if (strRetVal)
		{
		MsgBox, 8196, , % "Requested resolution change did not work. Reason: `n" strRetVal "`n`nReply:`nYes: Continue, and launch " PrgNames[lnchPrgIndex] ".`nNo: Do not launch the Prg: `n"
		IfMsgBox, No
		Return "Cancelled by user!"
		}
		else
		Sleep 1200
		}

;try
;{
		Run, % PrgPaths, % (IsaPrgLnk)? PrgLnkInf[lnchPrgIndex]: "", % "UseErrorLevel" ((IsaPrgLnk)? "": (PrgRnMinMax[lnchPrgIndex])? ((PrgRnMinMax[lnchPrgIndex] > 0)? "Max": ""): "Min"), PrgPIDtmp

;}
;catch temp
;{

	if (A_LastError)
	{
	sleep, 120
		if (A_LastError = ERROR_FILE_NOT_FOUND || A_LastError = ERROR_ACCESS_DENIED || A_LastError = ERROR_CANCELLED)
		{
			if (A_IsAdmin)
			{
			outStr := PrgNames[lnchPrgIndex] . " cannot launch with error " . A_LastError . ".`nIs it a system file, or does it have special permissions?"
			Return outStr
			}
			else
			msgbox, 8196 ,Run Elevated?, % PrgNames[lnchPrgIndex] " cannot launch with error " A_LastError ".`nIs it a system file, or does it have special permissions?`nIt might be possible for PrgLnch to run it as Admin:`n`nYes: Attempt to restart PrgLnch as Admin.`nNo: Do not restart PrgLnch.`n"

			IfMsgBox, Yes
			Return RestartPrgLnch(1)
			else
			Return "Prg could not be run with the current credentials."
		;Try elevation
		}
		else
		{
			;Add to PID list
			PrgPIDtmp := "TERM"
			FixPrgPIDStatus(currBatchno, prgIndex, lnchStat, PrgPIDtmp, PrgPID, PrgListPID)
				;WinShow ahk_class Shell_TrayWnd
				if (DefResNoMatchRes(SelIniChoicePath, Fmode, scrWidth, scrHeight, scrWidthDef, scrHeightDef))
				{
					if (!ChangeResolution(scrWidthDef, scrHeightDef, scrFreqDef, targMonitorNum))
					{
					sleep, 1000
					scrWidth := scrWidthDef
					scrHeight := scrHeightDef
					scrFreq := scrFreqDef
					}
				}
			outStr := PrgNames[lnchPrgIndex] . " could not launch with error " . A_LastError
			return outStr
		}
	}

	Process, Priority, PrgPIDtmp, % PrgPrty
	;Add to PID list

	FixPrgPIDStatus(currBatchno, prgIndex, lnchStat, PrgPIDtmp, PrgPID, PrgListPID)
	Sleep 500


	WinGetPos, x, y, w, h, % "ahk_pid" PrgPIDtmp
	fTemp := 0
	; Possible the default window co-ords are in another monitor from a previous run here
	loop % dispMonNamesNo
	{
	SysGet, ms, MonitorWorkArea, % A_Index
		if (x >= msLeft && x <= msRight && y >= msTop && y <= msBottom)
		{
			;we know targMonitorNum = PrgLnchMon
			if (PrgLnchMon != A_Index)
			{
				SysGet, md, MonitorWorkArea, % PrgLnchMon
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
				try
				{
				fTemp := 1
				WinMove, ahk_pid%PrgPIDtmp%, , dx, dy, w, h
				}
				catch
				{
				sleep, 20
				WinGetPos, x, y, , , % "ahk_pid" PrgPIDtmp
					if (x = dx && y = dy)
					{
					MsgBox, 8192, , % " Move Window failed for " PrgNames[lnchPrgIndex]
					fTemp := 0
					}
				}

				dx := Round(dx + w/2)
				dy := Round(dy + h/2)
				fTemp := 1
					if (fTemp)
					DllCall("SetCursorPos", UInt, dx, UInt, dy)
					else
					fTemp := 1
			}
			Break
		}
	}

	; Prevents cursor from reverting to primary if PrgLnch not primary
	if (!fTemp && PrgLnchMon != primaryMon)
	{
	dx := Round(x + w/2)
	dy := Round(y + y/2)
	DllCall("SetCursorPos", UInt, dx, UInt, dy)
	}
		if (borderToggle)
		BordlessProc(PrgPos, PrgMinMaxVar, PrgStyle, PrgBordless, lnchPrgIndex, 0, 0, scrWidth, scrHeight, PrgPIDtmp, 1) ; query


	;WinShow ahk_class Shell_TrayWnd
	}
	else ; monitor other than current
	{


			if (DefResNoMatchRes(SelIniChoicePath, Fmode, scrWidth, scrHeight, scrWidthDef, scrHeightDef))
			{
			strRetVal := ChangeResolution(scrWidth, scrHeight, scrFreq, targMonitorNum)
			if (strRetVal)
			{
			MsgBox, 8196, , % "Requested resolution change did not work. Reason: `n " strRetVal "`n`nReply:`nYes: Continue, and launch " PrgNames[lnchPrgIndex] ".`nNo: Do not launch the Prg: `n"
			IfMsgBox, No
			Return "Cancelled by user!"
			}
			else
			Sleep 1200
			}
;try
;{

Run, % PrgPaths, % (IsaPrgLnk)? PrgLnkInf[lnchPrgIndex]: "", % "UseErrorLevel" ((IsaPrgLnk)? "": (PrgRnMinMax[lnchPrgIndex])? ((PrgRnMinMax[lnchPrgIndex] > 0)? "Max": ""): "Min"), PrgPIDtmp

;}
;catch temp
;{
	if (A_LastError)
	{
	sleep, 120
		if (A_LastError = ERROR_FILE_NOT_FOUND || A_LastError = ERROR_ACCESS_DENIED || A_LastError = ERROR_CANCELLED)
		{
			if (A_IsAdmin)
			{
			outStr := PrgNames[lnchPrgIndex] . " cannot launch with error " . A_LastError . ".`nIs it a system file, or does it have special permissions?"
			Return outStr 
			}
			else
			msgbox, 8196 ,Run Elevated?, % PrgNames[lnchPrgIndex] " cannot launch with error " A_LastError ".`nIs it a system file, or does it have special permissions?`nIt might be possible for PrgLnch to run it as Admin:`n`nYes: Attempt to restart PrgLnch as Admin.`nNo: Do not restart PrgLnch.`n"

			IfMsgBox, Yes
			Return RestartPrgLnch(1)
			else
			Return "Prg could not be run with the current credentials."
		;Try elevation
		}
		else
		{
			;Add to PID list
			PrgPIDtmp := "TERM"
			FixPrgPIDStatus(currBatchno, prgIndex, lnchStat, PrgPIDtmp, PrgPID, PrgListPID)
				;WinShow ahk_class Shell_TrayWnd
				if (DefResNoMatchRes(SelIniChoicePath, Fmode, scrWidth, scrHeight, scrWidthDef, scrHeightDef))
				{
					if (!ChangeResolution(scrWidthDef, scrHeightDef, scrFreqDef, targMonitorNum))
					{
					sleep, 1000
					scrWidth := scrWidthDef
					scrHeight := scrHeightDef
					scrFreq := scrFreqDef
					}
				}
			outStr := PrgNames[lnchPrgIndex] . " could not launch with error " . A_LastError
			return outStr
		}
	}


		Process, Priority, PrgPIDtmp, % PrgPrty


		FixPrgPIDStatus(currBatchno, prgIndex, lnchStat, PrgPIDtmp, PrgPID, PrgListPID)
		Sleep 500

		WinGet, temp, MinMax, ahk_pid%PrgPIDtmp%
		if (temp)
		WinRestore, ahk_pid%PrgPIDtmp%

		WinGetPos, x, y, w, h, % "ahk_pid" PrgPIDtmp

		;change res, launch Prg, move window of Prg 
		; Get source and destination work areas (excludes taskbar-reserved space.)

		SysGet, md, MonitorWorkArea, % targMonitorNum

			if (!(mdLeft - mdRight) && (mdTop - mdBottom))
			{
			outStr := "Incorrect destination co-ordinates.`nIf the monitor has just been configured, a reboot may resolve the issue."
			return outStr
			}

		; Possible the default window co-ords are in the other monitor from a previous run here
			if !(x >= mdLeft && x <= mdRight && y >= mdTop && y <= mdBottom)
			{
			SysGet, ms, MonitorWorkArea, % PrgLnchMon
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

				try
				{
				WinMove, ahk_pid%PrgPIDtmp%, , dx, dy, w, h
				}
				catch
				{
				sleep, 20
				WinGetPos, x, y, , , % "ahk_pid" PrgPIDtmp
					if (x = dx && y = dy)
					MsgBox, 8192, , % " Move Window failed for " PrgNames[lnchPrgIndex]
				}
				dx := Round(dx + w/2)
				dy := Round(dy + h/2)
				DllCall("SetCursorPos", UInt, dx, UInt, dy)
			}


		; Restore min/max
		(temp = 1)? (WinMaximize, ahk_pid %PrgPIDtmp%): ((temp = -1)? (WinMinimize, ahk_pid %PrgPIDtmp%): )

		if (borderToggle)
		{
		dx := mdLeft
		dy := mdTop
		BordlessProc(PrgPos, PrgMinMaxVar, PrgStyle, PrgBordless, lnchPrgIndex, dx, dy, scrWidth, scrHeight, PrgPIDtmp, 1) ; query
		}
		;Then we can Move window
		;WinGetPos,,, W, H, A
		;WinMove, A ,, mswLeft + (mswRight - mswLeft) // 2 - W // 2, mswTop + (mswBottom - mswTop) // 2 - H // 2

	}

	; Path links etc cannot be cancelled as they do not return a PID:
	if (InStr(PrgLnkInf[lnchPrgIndex], "|*", false))
	Return "|*"

	;pillarboxing see https://msdn.microsoft.com/en-us/library/windows/desktop/bb530115(v=vs.85).aspx
	;showhide taskbar
	;WinHide ahk_class Shell_TrayWnd
	;WinShow ahk_class Shell_TrayWnd
	}
else
	{
		PrgPIDtmp := "TERM"
		FixPrgPIDStatus(currBatchno, prgIndex, lnchStat, PrgPIDtmp, PrgPID, PrgListPID)
		outStr := "Unable to determine the location of `n" . PrgPaths
		return outStr
	}

;WinWaitClose What about suspended task?


}
else
{

	if (lnchPrgIndex = 0) ;Just Change Res
	{
		GuiControlGet, targMonitorNum, PrgLnchOpt:, iDevNum


		if (DefResNoMatchRes(SelIniChoicePath, Fmode, scrWidth, scrHeight, scrWidthDef, scrHeightDef))
		{
			strRetVal := ChangeResolution(scrWidth, scrHeight, scrFreq, targMonitorNum)

			if (strRetVal)
			Return % "Requested resolution change did not work. Reason: `n" strRetVal
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
			if (ErrorLevel)
			{
				if (PrgPIDtmp)
				{

				WinClose, ahk_pid %PrgPIDtmp%
				sleep, 200
				}

				if (PrgPIDtmp)
				{
				MsgBox, 8193, , There was a problem closing a Prg. If it is still open, `nthe Prg will no longer be monitored by PrgLnch. `nClick OK to confirm its force termination.`n`"%temp%`"
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
			IniRead, fTemp, %SelIniChoicePath%, General, ClosePrgWarn
			if (!fTemp)
			{
				MsgBox, 8196, , An attempt was made to close a Prg `nwhich has already terminated by itself.`n`"%temp%`"`n`nReply:`nYes: Continue (Warn like this next time)`nNo: Continue (This will not show again) `n
				IfMsgBox, Yes
				PrgPIDtmp := ""
				else
				IniWrite, 1, %SelIniChoicePath%, General, ClosePrgWarn
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
fTemp := 0
if (lnchStat = -1)
	{
		if (PrgPIDtmp = "TERM")
		PrgPID := 0
		else
		PrgPID := PrgPIDtmp

	}
	else
	{
		if (lnchStat = 1)
		{
		loop % currBatchno
		{
		fTemp := PrgListPID[A_Index]
		if (fTemp = "NS" || fTemp = "FAILED" || fTemp = "TERM" || fTemp = "ENDED")
		{
			if (fTemp != "TERM")
			{
			PrgListPID[A_Index] := PrgPIDtmp
			Break
			}
		}
		else
		{
		Process, Exist, % fTemp
		if (!ErrorLevel)
		PrgListPID[A_Index] := "ENDED"
		}

		}
		}
		else
		PrgListPID[prgIndex] := PrgPIDtmp
	}
}


WatchSwitchBack:

Thread, Priority, -536870911
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
			if (PrgLnch.Monitor = targMonitorNum)
			{
			ChangeResolution(scrWidthDef, scrHeightDef, scrFreqDef, PrgLnch.Monitor)
			sleep, 1000
			}
		}
	SetTimer, WatchSwitchBack, Off
	SetTimer, WatchSwitchOut, -1000
}
Return

WatchSwitchOut:

Thread, Priority, -536870911 ; https://autohotkey.com/boards/viewtopic.php?f=13&t=29911

	if (presetNoTest) ; in the Prglnch screen
	{
		timerBtch := 0
		if (batchActive)
		{
		timerTemp := "|"
			loop % currBatchno
			{
			timerfTemp := PrgListPID%btchPrgPresetSel%[A_Index]
				if (timerfTemp = "TERM")
				{
				timerTemp .= "Failed" . "|"
				PrgListPID%btchPrgPresetSel%[A_Index] := "Failed"
				}
				else
				{
				if (timerfTemp = "FAILED")
				timerTemp .= "Failed" . "|"
				else
				{
				if (timerfTemp = "NS")
				timerTemp .= "Not Started" . "|"
				else
				{
				if (timerfTemp)
					{
					Process, Exist, % timerfTemp
						if(ErrorLevel)
						{
						timerTemp .= "Active" . "|"
						timerBtch := PrgBatchIni%btchPrgPresetSel%[A_Index]
						lastMonitorUsedInBatch := PrgMontoRn[timerBtch]
						}
						else
						{
						PrgListPID%btchPrgPresetSel%[A_Index] := "ENDED"
						timerTemp .= "Not Active" . "|"
						}
					}
					else
					timerTemp .= "Not Active" . "|"
				}
				}
				}
			}
			GuiControl, PrgLnch:, batchPrgStatus, %timerTemp%
				if (!timerBtch)
				{
				batchActive := 0
				CleanupPID(SelIniChoicePath, currBatchNo, PrgLnch.Monitor, lastMonitorUsedInBatch, PrgMonToRn, PrgNo, PrgPIDMast, presetNoTest, PrgListPID%btchPrgPresetSel%, PrgStyle, dx, dy, PrgBordless, PrgLnchHide, PrgPID, selPrgChoice, Fmode, dispMonNamesNo, scrWidth, scrHeight, scrWidthDef, scrHeightDef, scrFreqDef, waitBreak, 1)
				if (!PrgPID)
				Return
				}
		}
		else
		{
			Process, Exist, %PrgPID%
			if(!ErrorLevel)
			{
			PrgPID := 0
			CleanupPID(SelIniChoicePath, currBatchNo, PrgLnch.Monitor, lastMonitorUsedInBatch, PrgMonToRn, PrgNo, PrgPIDMast, presetNoTest, PrgListPID%btchPrgPresetSel%, PrgStyle, dx, dy, PrgBordless, PrgLnchHide, PrgPID, selPrgChoice, Fmode, dispMonNamesNo, scrWidth, scrHeight, scrWidthDef, scrHeightDef, scrFreqDef, waitBreak)
			Return
			}
		}
	}
	else ;In Config screen
	{
		if (PrgPID)
		{
			Process, Exist, %PrgPID%
			if(!ErrorLevel)
			{
			PrgPID := 0
			CleanupPID(SelIniChoicePath, currBatchNo, PrgLnch.Monitor, lastMonitorUsedInBatch, PrgMonToRn, PrgNo, PrgPIDMast, presetNoTest, PrgListPID%btchPrgPresetSel%, PrgStyle, dx, dy, PrgBordless, PrgLnchHide, PrgPID, selPrgChoice, Fmode, dispMonNamesNo, scrWidth, scrHeight, scrWidthDef, scrHeightDef, scrFreqDef, waitBreak)
				if (!batchActive)
				Return
			}
		}
		else
		{ 
			if (batchActive)
			{
			;get lastMonitorUsedInBatch
			timerBtch := 0
				loop % currBatchNo
				{
				timerfTemp := PrgListPID%btchPrgPresetSel%[A_Index]
				Process, Exist, % timerfTemp
					if(ErrorLevel)
					{
					timerBtch := PrgBatchIni%btchPrgPresetSel%[A_Index] ;
					lastMonitorUsedInBatch := PrgMontoRn[timerBtch]
					}
				}

				if(!timerBtch)
				{
				batchActive := 0
				CleanupPID(SelIniChoicePath, currBatchNo, PrgLnch.Monitor, lastMonitorUsedInBatch, PrgMonToRn, PrgNo, PrgPIDMast, presetNoTest, PrgListPID%btchPrgPresetSel%, PrgStyle, dx, dy, PrgBordless, PrgLnchHide, PrgPID, selPrgChoice, Fmode, dispMonNamesNo, scrWidth, scrHeight, scrWidthDef, scrHeightDef, scrFreqDef, waitBreak, 1)
				Return
				}
			}
			else
			Return
		}
	}

If (WinWaiter(PrgLnch))
{
	; check the PID of app. If it matches a Prg, use the index to retrieve the resolution

	timerfTemp := FindMatchingPID(lnchStat, currBatchNo, PrgListPID%btchPrgPresetSel%, PrgPID)

	if (timerfTemp)
	{
	(lnchStat < 0)? prgSwitchIndex := 0: prgSwitchIndex := PrgBatchIni%btchPrgPresetSel%[timerfTemp]
		if ((prgSwitchIndex)? PrgChgResonSwitch[prgSwitchIndex]: PrgChgResonSwitch[selPrgChoice])
		{
		scrWidth := (lnchStat < 0)? scrWidthArr[selPrgChoice]: scrWidthArr[prgSwitchIndex]
		scrHeight := (lnchStat < 0)? scrHeightArr[selPrgChoice]: scrHeightArr[prgSwitchIndex]
		scrFreq := (lnchStat < 0)? scrFreqArr[selPrgChoice]: scrFreqArr[prgSwitchIndex]
		targMonitorNum := (lnchStat < 0)? PrgMonToRn[selPrgChoice]: PrgMonToRn[prgSwitchIndex]
		if (DefResNoMatchRes(SelIniChoicePath, Fmode, scrWidth, scrHeight, scrWidthDef, scrHeightDef) && (PrgLnch.Monitor = targMonitorNum))
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

CleanupPID(SelIniChoicePath, currBatchNo, PrgLnchMon, lastMonitorUsedInBatch, PrgMonToRn, PrgNo, PrgPIDMast, presetNoTest, ByRef PrgListPIDbtchPrgPresetSel, ByRef PrgStyle, ByRef dx, ByRef dy, PrgBordless, PrgLnchHide, ByRef PrgPID, selPrgChoice, Fmode, dispMonNamesNo, scrWidth, scrHeight, scrWidthDef, scrHeightDef, scrFreqDef, waitBreak, batchWasActive := 0)
{
temp := 0, strRetVal := "", PrgStyle := 0, dx := 0, dy:= 0

strRetVal := WorkingDirectory(A_ScriptDir, 1)
If (strRetVal)
MsgBox, 8192, Cleanup PID, % strRetVal
if (presetNoTest)
{
	if (PrgPID)
	{
		if (PrgMonToRn[selPrgChoice] != PrgLnchMon)
		{
		SplashImage, Hide, A B,,,LnchSplash
		;must zero array
			Loop % currBatchNo
			{
			PrgListPIDbtchPrgPresetSel[A_Index] := 0
			}
			if (PrgLnchMon = lastMonitorUsedInBatch)
			PrgAlreadyLaunched(SelIniChoicePath, PrgLnchMon, Fmode, scrWidth, scrHeight, scrWidthDef, scrHeightDef, scrFreqDef)
		}
	}
	else
	{
	if (batchWasActive)
		{
		if (DefResNoMatchRes(SelIniChoicePath, Fmode, scrWidth, scrHeight, scrWidthDef, scrHeightDef) && (PrgLnchMon = lastMonitorUsedInBatch))
			{
			ChangeResolution(scrWidthDef, scrHeightDef, scrFreqDef, PrgLnchMon)
			sleep, 1000
			}
		}
		; else the Prg Test run complete

	WinMover(PrgLnch.Hwnd(), "d r", PrgLnchOpt.Width() * 3/4, PrgLnchOpt.Height())
		if (PrgLnchHide[selPrgChoice])
		Gui, PrgLnch: Show

	GuiControl, PrgLnch:, RunBatchPrg, &Run Batch
	SetTimer, WatchSwitchBack, Delete
	SetTimer, WatchSwitchOut, Delete
	}
}
else
{
	if (batchWasActive) ;Then the Batch has completed
	{
		if (!(PrgMonToRn[selPrgChoice] = PrgLnchMon) && (PrgLnchMon = lastMonitorUsedInBatch))
		PrgAlreadyLaunched(SelIniChoicePath, PrgLnchMon, Fmode, scrWidth, scrHeight, scrWidthDef, scrHeightDef, scrFreqDef)

		;must zero array
		Loop % currBatchNo
		{
		PrgListPIDbtchPrgPresetSel[A_Index] := 0
		}
	}
	else
	{
	HideShowTestRunCtrls(1)
	GuiControl, PrgLnchOpt:, Bordless, % PrgBordless[selPrgChoice]
		if (DefResNoMatchRes(SelIniChoicePath, Fmode, scrWidth, scrHeight, scrWidthDef, scrHeightDef) && (PrgMonToRn[selPrgChoice] = PrgLnchMon))
		{
		ChangeResolution(scrWidthDef, scrHeightDef, scrFreqDef, PrgLnchMon)
		sleep, 1000
		}
	SetTimer, WatchSwitchBack, Delete
	SetTimer, WatchSwitchOut, Delete
	}
	; No problem if a batch preset completes at exactly the same time.
WinMover(PrgLnchOpt.Hwnd(), "d r")
	if (PrgLnchHide[selPrgChoice])
	Gui, PrgLnchOpt: Show
}

	if (!waitBreak && presetNoTest < 2)
	{
	SysGet, md, MonitorWorkArea, % PrgLnchMon
	dx := Round(mdleft + (mdRight- mdleft)/2)
	dy := Round(mdTop + (mdBottom - mdTop)/2)
	DllCall("SetCursorPos", UInt, dx, UInt, dy)
	}



}
PrgAlreadyLaunched(SelIniChoicePath, PrgLnchMon, Fmode, scrWidth, scrHeight, scrWidthDef, scrHeightDef, scrFreqDef)
{
temp := 0
IniRead, temp, %SelIniChoicePath%, General, PrgAlreadyLaunchedMsg
sleep, 120

	if (temp)
	{
		if (temp = 1)
		{
			if (DefResNoMatchRes(SelIniChoicePath, Fmode, scrWidth, scrHeight, scrWidthDef, scrHeightDef))
			{
			ChangeResolution(scrWidthDef, scrHeightDef, scrFreqDef, PrgLnchMon)
			sleep, 1000
			}
		}
	}
	else
	{
		MsgBox, 8195, , Batch has completed but a Prg has been launched via Test Run.`nIt's possible Batch Prgs used other monitors other than the default.`nDo you wish to change the resolution of the monitor `nPrgLnch was run from back to its default resolution now?`n`nReply:`nYes: Change resolution (Warn like this next time) `nNo: Change resolution (This will not show again) `nCancel: Do not change resolution (This will not show again)`n
		IfMsgBox, Cancel
		IniWrite, 2, %SelIniChoicePath%, General, PrgAlreadyLaunchedMsg
		else
		{
				if (DefResNoMatchRes(SelIniChoicePath, Fmode, scrWidth, scrHeight, scrWidthDef, scrHeightDef))
				{
				ChangeResolution(scrWidthDef, scrHeightDef, scrFreqDef, PrgLnchMon)
				sleep, 1000
				}
			IfMsgBox, No
			IniWrite, 1, %SelIniChoicePath%, General, PrgAlreadyLaunchedMsg

		}
	}

}











































;More General file & process routines
join(strArray)
{
s := ""
	for i,v in strArray
	s .= "," . v
return substr(s, 2)
}
CheckPrgPaths(selPrgChoice, IniFileShortctSep, ByRef PrgChoicePaths, ByRef PrgLnkInf, ByRef PrgResolveShortcut)
{
Local strRetVal := "", strTemp := PrgChoicePaths[selPrgChoice], strTemp2 := PrgLnkInf[selPrgChoice]
;gets, tests working directory of possible lnk, if any
	if (InStr(strTemp2, "*"))
	{
	strRetVal := WorkingDirectory(strTemp)
		if (!strRetVal && InStr(strTemp, ".lnk", False, StrLen(strTemp) - 4))
		{
			if ("*" = GetPrgLnkVal(strTemp, IniFileShortctSep))
			MsgBox, 8192, , The link %strTemp% is invalid!
			;else it''s a directory lnk
		}
	}
	else
	{
	; The ini may be corrupted when IniFileShortctSep is removed
	(InStr(strTemp, IniFileShortctSep))? lnkPrg := Substr(strTemp, 1, InStr(strTemp, IniFileShortctSep) - 1): lnkPrg := strTemp

		If (!FileExist(lnkPrg))
		{
			if (InStr(strTemp2, "\", false, StrLen(strTemp2)))
			{
			MsgBox, 8196, , The link %lnkPrg% is invalid.`nGiven that its target still exists, the Prg can still be used.`n`nReply:`nYes: Attempt to use the target`nNo: Do nothing, in case the lnk file can be recovered.`n
				IfMsgBox, Yes
				{
				strTemp := SubStr(strTemp, InStr(strTemp, IniFileShortctSep,,0) + 1)
				PrgChoicePaths[selPrgChoice] := strTemp
				PrgResolveShortcut[selPrgChoice] := 0
				PrgLnkInf[selPrgChoice] := "*"
				IniProc(selPrgChoice)
				strRetVal := WorkingDirectory(strTemp)
				}
				else
				strRetVal := ""
			}
			else
			strRetVal := % strTemp "`nwas supposed to have a backslash terminator!"
		}
	}
if (strRetVal)
MsgBox, 8192, Checking Prg Paths, % strRetVal

Return strRetVal
}
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
		loop % currBatchNo
		{
			if (temp = PrgListPIDbtchPrgPresetSel[A_Index])
			Return A_Index
		}
	}
Return 0
}

KillPrg(poorPID)
{
strTemp := "" , strRetVal := ""
Process, Close, ahk_pid %poorPID%
sleep, 200

if (poorPID)
	{
	strRetVal := WorkingDirectory(A_ScriptDir, 1)
	If (strRetVal)
	MsgBox, 8192, Cancel Prg, % strRetVal
	if (FileExist("taskkillPrg.bat"))
		{
		FileDelete, taskkillPrg.bat
		sleep, 200
		}
	strTemp := "taskkill /pid "
	strTemp .= poorPID . " /f /t"
	FileAppend, %strTemp%, taskkillPrg.bat
	sleep, 200
	Run, taskkillPrg.bat,, Hide UseErrorLevel
	sleep, 200
	FileDelete, taskkillPrg.bat
	}
}

GetProcFromPath(strTemp, lnkInfo := 0)
{
if (lnkInfo)
{
strRetVal := SubStr(strTemp, InStr(strTemp, "\",, -1) + 1)
strRetVal := SubStr(strRetVal, 1, StrLen(strRetVal)-3) . "exe" ; assume exe
}
else
strRetVal := SubStr(strTemp, InStr(strTemp, "\",, -1) + 1)

	if (!strRetVal)
	MsgBox, 8192, ,Invalid path with %strTemp%!`nUnable to continue process check.

Return strRetVal
}

ChkExistingProcess(PrgLnkInf, presetNoTest, selPrgChoice, currBatchNo, PrgBatchIni, PrgChoicePaths, IniFileShortctSep, btchRun := 0, multiInst := 0)
{
strComputer := ".", dupList := "", temp := 0, strTemp := "", strTemp2 := "", IsaPrgLnk := 0

if (presetNoTest && btchRun)
{
loop % currBatchNo
	{
	temp := PrgBatchIni[A_Index]
	strTemp := ExtractPrgPath(temp, PrgChoicePaths, 0, PrgLnkInf, IsaPrgLnk, IniFileShortctSep)
	temp := InStr(PrgPaths, ".lnk", false, strLen(PrgPaths) - 4)
	if (InStr(strTemp, "PrgLnch.exe") || InStr(strTemp, "BadPath"))
	Return "PrgLnch"
    if !(strTemp := GetProcFromPath(strTemp, temp))
	Return "BadPath"
	strTemp2 := ""
	; Does not work for lnk files. "Select *" means full paths and names and commandlines!
		for process in ComObjGet("winmgmts:{impersonationLevel=impersonate}!\\" . strComputer . "\root\cimv2").ExecQuery("Select Name from Win32_Process")
		{
			if (strTemp = process.Name) ; process.ExecutablePath was also possible (Select Name, ExecutablePath from Win32_Process)
			{
			if (duplist)
			strTemp2 := ", "

			duplist .= strTemp2 . strTemp
			Break
			}
		}
	}
}
else
{
	if (presetNoTest)
	{
	; selPrgChoice is batchPrgstatus
	temp := PrgBatchIni[selPrgChoice]
	strTemp2 := PrgLnkInf[temp]
	}
	else
	{
	temp := selPrgChoice
	strTemp2 := PrgLnkInf[temp]
	}

	strTemp := ExtractPrgPath(temp, PrgChoicePaths, 0, PrgLnkInf, IsaPrgLnk, IniFileShortctSep)
	;ExtractPrgPath(selPrgChoice, PrgChoicePaths, PrgPth, PrgLnkInf, ByRef IsaPrgLnk, IniFileShortctSep)
;if InStr(strTemp, "Notepad")

	if (InStr(strTemp, "PrgLnch.exe") || InStr(strTemp, "BadPath"))
	Return "PrgLnch"
    if !(strTemp := GetProcFromPath(strTemp, strTemp2))
	Return "BadPath"
	strTemp2 := ""
	for process in ComObjGet("winmgmts:{impersonationLevel=impersonate}!\\" . strComputer . "\root\cimv2").ExecQuery("Select Name from Win32_Process")
	{
		if (strTemp = process.Name)
		{
		duplist .= strTemp2 . strTemp
			if (multiInst)
			strTemp2 := "|" 
			else
			Break
		}
	}
}

Return duplist
}

ChkBatchActivePrgs(maxBatchPrgs, PrgBatchIniA_Index, ByRef PrgListPID)
{
	loop % maxBatchPrgs
	{
	fTemp := PrgBatchIniA_Index[A_Index]

		if (fTemp)
		PrgListPID[fTemp] := "A" ; Potential candidate for PID
		else
		Break
	}
}

ProcessActivePrgsAtStart(SelIniChoicePath, PrgNo, PrgLnkInf, PrgChoicePaths, IniFileShortctSep, ByRef PrgPIDMast, oldSelIniChoicePath := "")
{
ProcNames := ["", "", "", "", "", "", "", "", "", "", "", ""]
PrgPIDMastTmp := [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
strTemp := ""
strTemp2 := ""
multipleInstance := 0
foundpos := 0
retVal := 0




if (oldSelIniChoicePath)
{

; No "WarnAlreadyRunning" as this is default when switching Lnch Pads
	Loop % PrgNo
	{
		strTemp2 := PrgChoicePaths[A_Index]
		temp := A_Index
			if (strTemp2)
			{
				loop % PrgNo
				{
				IniRead, strTemp, %oldSelIniChoicePath%, Prg%A_Index%, PrgPath
					if (PrgPIDMast[A_Index] && strTemp)
					{
					if (strTemp = strTemp2 && !PrgPIDMastTmp[A_Index])
					PrgPIDMastTmp[temp] := PrgPIDMast[A_Index]
					}
				}
			}
	}
	Loop % PrgNo
	{
	PrgPIDMast[A_Index] := PrgPIDMastTmp[A_Index]
	}
; Not using ChkExistingProcess so not absolutely water-tight
retVal := 1
Return retVal
}
else
{

	IniRead, WarnAlreadyRunning, %SelIniChoicePath%, General, WarnAlreadyRunning
		if (WarnAlreadyRunning = 2)
		Return retVal

	Loop % PrgNo
	{
		if (PrgChoicePaths[A_Index] && PrgPIDMast[A_Index])
		{
		strRetVal := ChkExistingProcess(PrgLnkInf, 0, A_Index, 0, 0, PrgChoicePaths, IniFileShortctSep, 0, 1)

			if (strRetVal)
			{
			MultInstPrg := 0
			foundpos := 1
				if (Instr(strRetVal, "|"))
				{
					Loop, Parse, strRetVal, |
					{
					foundpos += 1
					multipleInstanceExist := 1
					MultInstPrg := 1
					}
				}

			ProcNames[A_Index] := (MultInstPrg)? (SubStr(strRetVal, 1, Instr(strRetVal, "|") - 1)): strRetVal

			strTemp .= ((A_Index > 9)? "`nPrg ": "`nPrg  ") . A_Index . ": " . ((foundpos > 1)? (foundpos - 1 . " instances of "): ("One instance of ")) . ProcNames[A_Index] . "."
			}
		}
	}

	if (!WarnAlreadyRunning && foundpos)
	{
	strRetVal := % (multipleInstance)? "`nNote, if Yes, PrgLnch will only choose one of the instances.": ""
	MsgBox, 8195, Running Prgs, % "The Prgs in the list below have already started!`n" strTemp "`n`nReply:`nYes: Update Prg Batch Status (Recommended: This will not show again)`nNo: Do not update Prg Batch Status (This will show again)`nCancel: Do not update Prg Batch Status (This will not show again)`n" strRetVal
		ifMsgBox, Yes
		IniWrite, 1, %SelIniChoicePath%, General, WarnAlreadyRunning
		Else
		{
		IfMsgBox, Cancel
		IniWrite, 2, %SelIniChoicePath%, General, WarnAlreadyRunning

		Return retVal
		}
	}
}


Loop % PrgNo
{
foundpos := 0
	if (ProcNames[A_Index])
	{
	Process, Exist, % ProcNames[A_Index]

	foundpos := ErrorLevel

		; PrgPIDMast[]A_Index] 1 if batch as initialised by ChkBatchActivePrgs
		if (foundpos && PrgPIDMast[A_Index])
		{
		PrgPIDMast[A_Index] := foundpos
		retVal := 1
		}
		else
		PrgPIDMast[A_Index] := 0
	}
	else
	PrgPIDMast[A_Index] := 0
}



Return retVal
}

GetPrgLnchMonNum(iDevNumArray, dispMonNamesNo, ByRef primaryMon, fromMouse := 0)
{
	iDevNumb := 0, monitorHandle := 0,  MONITOR_DEFAULTTONULL := 0, strTemp := ""
	VarSetCapacity(monitorInfo, 40)
	NumPut(40, monitorInfo)


	hWnd := PrgLnchOpt.Hwnd()
	If (!hWnd)
	{
	MsgBox, 8192, , % "Cannot get handle of Script! Error: " A_LastError
	VarSetCapacity(monitorInfo, 0)
	Return -1
	}
	;winHandle := WinExist("A") ; LastWindow: The PrgLnch Window if clicked on

	loop %dispMonNamesNo%
	{
		if (iDevNumArray[A_Index] > 9)
		{
		iDevNumb += 1
			if (iDevNumArray[A_Index] > 99)
			primaryMon := SubStr(iDevNumArray[A_Index], 1, 1)
		}
	}

	if (fromMouse)
	{
	strTemp := A_CoordModeMouse
	CoordMode, Mouse, Screen
	MouseGetPos, x, y
	CoordMode, Mouse, % strTemp
	}
	else
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

		; GetMonitorIndexFromWindow(windowHandle)

		Loop %iDevNumb%
		{
			SysGet, mt, Monitor, %A_Index%

			; Compare location to determine the monitor index.
			if (fromMouse)
			{
				if (x >= mtLeft && x <= mtRight && y <= mtBottom && y >= mtTop)
				{

				msI := A_Index
				break
				}
			}
			else
			{
				if ((msLeft = mtLeft) and (msTop = mtTop)
					and (msRight = mtRight) and (msBottom = mtBottom))
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
strTemp := "Cannot retrieve Monitor info from the"
	if (fromMouse)
	MsgBox, 8192, , %strTemp% mouse cursor!
	else
	MsgBox, 8192, , %strTemp% target window!
return 1 ;hopefully this monitor is the one!
}

}
GetPrgLnkVal(strTemp, IniFileShortctSep, ProcessLnk := 0, resolveNow := 0)
{
;Gets either working directory or resolved shortcut path
strRetVal := "", strTemp2 := ""
	; ATM PrgLnch does not modify the fields of the Wscript shortcut component in anyway.
	;http://superuser.com/questions/392061/how-to-make-a-shortcut-from-cmd


	if (ProcessLnk)
	{
		if (InStr(strTemp, IniFileShortctSep))
		strTemp2 := SubStr(strTemp, 1, InStr(strTemp, IniFileShortctSep,,0) - 1)
		else
		strTemp2 := strTemp

		if (resolveNow)
		{
		FileGetShortcut, % strTemp2, strRetVal
		strTemp2 := SubStr(strTemp, InStr(strTemp, IniFileShortctSep,,0) + 1)
		if (strTemp2 != strRetVal && !strTemp2)
		MsgBox, 8192, , % "Shortcut target`n" strRetVal "`nhas been updated"
		}
		else
		{
		FileGetShortcut, % strTemp2, , strRetVal
		strRetVal .= "\"
		}
	}
	else
	{
	strTemp:= ParseEnvVars(strTemp)
	; get workdir: This blanks all if not lnk file so expect return of "*"
	FileGetShortcut, % strTemp, , strRetVal
		if (strRetVal)
		{
		strRetVal := ParseEnvVars(strRetVal)
		strRetVal .= "\"
		}
		else ; lnk might be a directory shortcut
		{
		FileGetShortcut, % strTemp, strRetVal
			if (strRetVal)
			{	
				if (InStr(strTemp, IniFileShortctSep))
				strTemp := SubStr(strTemp, 1, InStr(strTemp, IniFileShortctSep,,0) - 1)

			strRetVal := "|"
			}
			else
			strRetVal := "*"
			; dummy character- definitely not a valid path
		}

	}

	return strRetVal
}

ParseEnvVars(strTemp)
{
; Bunch of them at https://docs.microsoft.com/en-us/windows/deployment/usmt/usmt-recognized-environment-variables
	;CSIDL_PROFILE ;A typical path is C:\Users\Username
	strTemp2 := StrReplace(strTemp, "`%USERPROFILE`%", , foundPos)
	if (foundPos)
	{
		if (strTemp2 && !InStr(strTemp2, "\") = 1)
		strTemp2 := "\" . strTemp2

	EnvGet, userProfile, USERPROFILE
	strTemp := userProfile . strTemp2
	}
	else
	{
	;absolutely refuse to parse HOMEDRIVE and HOMEPATH separately
	strTemp2 := StrReplace(strTemp, "`%HOMEDRIVE`%`%HOMEPATH`%", , foundPos)
		if (foundPos)
		{
			if (strTemp2 && !InStr(strTemp2, "\") = 1)
			strTemp2 := "\" . strTemp2

		EnvGet, homeDrive, HOMEDRIVE
		EnvGet, homePath, HOMEPATH
		strTemp := homeDrive . homePath . strTemp2
		}
		else
		{
		; Win2000 Unc Path: 
		;Win2000: %HOMESHARE%: \\ServerName\ShareName\Folder1\Folder2\HomeFolder
		; %HOMEDRIVE% - Z:, mapped to \\ServerName\ShareName\Folder1\Folder2\HomeFolder
		; %HOMEPATH%   - \
		
		; Nt4:Unc Path:  (Think these are used for later OS)
		;HOMESHARE% - \\ServerName\ShareName
		;%HOMEDRIVE% - Z:, mapped to \\ServerName\ShareName
		; %HOMEPATH%   - \Folder1\Folder2\HomeFolder
		
		strTemp2 := StrReplace(strTemp, "`%HOMESHARE`%`%HOMEPATH`%", , foundPos)
		if (foundPos)
		{

			if (strTemp2 && !InStr(strTemp2, "\") = 1)
			strTemp2 := "\" . strTemp2

		EnvGet, homeShare, HOMESHARE
		EnvGet, homePath, HOMEPATH

		strTemp := homeShare . homePath . strTemp2
		}
		else
		{
		strTemp2 := StrReplace(strTemp, "`%HOMESHARE`%", , foundPos)
		if (foundPos)
		{

			if (strTemp2 && !InStr(strTemp2, "\") = 1)
			strTemp2 := "\" . strTemp2

		EnvGet, homeShare, HOMESHARE
		strTemp := homeShare . strTemp2
	
		}
		}
		}

	}
Return strTemp
}

WorkingDirectory(strTemp, SetNow := 0)
{
retVal := 0


	;if (strTemp != A_ScriptDir && !InStr(strTemp, "\", false,  StrLen(strTemp)))
	if (InStr(strTemp, "\", false,  StrLen(strTemp)))
	{
	retVal := InStr(strTemp, "\", false, -1)
	strTemp2 := SubStr(strTemp, 1, retVal)
	}
	else
	SplitPath strTemp, , strTemp2


SetWorkingDir %strTemp2%
retVal := ErrorLevel

	if (!SetNow) ; just testing: never called with A_ScriptDir
	{
	sleep 50
		if (retval)
		SetWorkingDir %A_ScriptDir% ; Caution: Working Dir can be altered by other processes
	}
; 0 success
if (retVal)
Return "An error of " retVal " occurred while reading the path for:`n""" strTemp . """"
else
Return ""
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
WS_SIZEBOX := 0x00040000
WinGetClass, Class
	if (Class in Chrome_XPFrame,MozillaUIWindowClass,IEFrame,OpWindow)
	return true
	WinGet, CurrStyle, Style
	return (CurrStyle & WS_SIZEBOX)
}
BordlessProc(ByRef PrgPos, ByRef PrgMinMaxVar, ByRef PrgStyle, PrgBordless, selPrgChoice, dx, dy, scrWidth, scrHeight, PrgPID, queryOnly := 0)
{
WS_BORDER := 0x00800000 ;Window has a thin-line border.
WS_CAPTION := 0x00C00000 ; Window has a title bar (includes the WS_BORDER style: i.e. anding Hex C = 1100 8 = 1000 ): 
WS_THICKFRAME := 0x00040000 ; Window has a sizing border. aka WS_SIZEBOX

; Extended Borders
WS_EX_WINDOWEDGE := 0x00000100 ; Window has a border with a raised edge.
WS_EX_CLIENTEDGE := 0x00000200 ; Window has a border with a sunken edge
WS_EX_STATICEDGE := 0x00020000 ; Window has a 3D border style for use with items that do not accept user input.
WS_EX_DLGMODALFRAME := 0x00000001 ; Window has a double border

; https://autohotkey.com/boards/viewtopic.php?p=123166#p123166
S:=0, PrgStyleTmp := 0, x:= 0, y:= 0, w := 0, h := 0
WinGet, S, Style, ahk_pid%PrgPID%


	if (PrgStyle)
	PrgStyleTmp := S & PrgStyle
	else
	{
	WindowStyle := WS_CAPTION
		if (S & WindowStyle)
		{
			if (S & WS_THICKFRAME)
			WindowStyle := WS_CAPTION|WS_THICKFRAME
		}
		else
		{
		WindowStyle := WS_BORDER
			if (S & WindowStyle)
			{
				if (S & WS_THICKFRAME)
				WindowStyle := WindowStyle|WS_THICKFRAME
			}
			else
			{
				if (S & WS_THICKFRAME)
				WindowStyle := WindowStyle|WS_THICKFRAME
				else
				WindowStyle := 0
			}
		}
	PrgStyle := S & WindowStyle
	PrgStyleTmp := PrgStyle

	if (PrgBordless[selPrgChoice])
	{
	; Extended Borders
	
	WindowStyle := WS_EX_WINDOWEDGE
		if (S & WindowStyle)
		{
		WindowStyle := WindowStyle | WS_EX_STATICEDGE
			if (S & WindowStyle)
			{
				if (S & WS_EX_DLGMODALFRAME)
				WindowStyle := WindowStyle | WS_EX_DLGMODALFRAME
			}
			else
			{
			WindowStyle := WS_EX_WINDOWEDGE
				if (S & WS_EX_DLGMODALFRAME)
				WindowStyle := WindowStyle | WS_EX_DLGMODALFRAME
			}

		}
		else
		{
		WindowStyle := WS_EX_CLIENTEDGE

			if (S & WindowStyle)
			{
			WindowStyle := WindowStyle | WS_EX_STATICEDGE
				if (S & WindowStyle)
				{
					if (S & WS_EX_DLGMODALFRAME)
					WindowStyle := WindowStyle | WS_EX_DLGMODALFRAME
				}
				else
				{
				WindowStyle := WS_EX_CLIENTEDGE
					if (S & WS_EX_DLGMODALFRAME)
					WindowStyle := WindowStyle | WS_EX_DLGMODALFRAME
				}
			}
			else
			{
			WindowStyle := WS_EX_STATICEDGE
				if (S & WindowStyle)
				{
					if (S & WS_EX_DLGMODALFRAME)
					WindowStyle := WindowStyle | WS_EX_DLGMODALFRAME
				}
				else
				{
					if (S & WS_EX_DLGMODALFRAME)
					WindowStyle := WS_EX_DLGMODALFRAME
					else
					WindowStyle := 0
				}
			
			}

		}

	PrgStyle := PrgStyle | (S & WindowStyle)
	PrgStyleTmp := PrgStyle
	}
	}



	if (queryOnly)
	{
	;Initialises PrgStyle
	GuiControl, PrgLnchOpt:, Bordless, 0
	GuiControl, PrgLnchOpt: Text, Bordless, Apply Borderless
		if (PrgStyleTmp)
		Return 1
		else
		GuiControl, PrgLnchOpt: Disable, Bordless
	Return 0
	}



	if (PrgStyleTmp) ;check flags not Borderless
	{
	; Store existing style
	WinGet, IsMaxed, MinMax, ahk_pid%PrgPID%
	; Get/store whether the window is maximized
		if (PrgMinMaxVar := IsMaxed = 1 ? true : false)
		WinRestore, ahk_pid%PrgPID%
	;move window to max perims
	WinGetPos, x, y, w, h, ahk_pid%PrgPID%

	PrgPos[1] := x, PrgPos[2] := y, PrgPos[3] := w, PrgPos[4] := h
	; Remove borders
	winSet, Style, % -PrgStyleTmp, ahk_pid%PrgPID%
	sleep 30
	WinMove, ahk_pid%PrgPID%, , dx, dy, scrWidth, scrHeight
	}
	else
	{
	; If borderless, reapply borders
	WinSet, Style, % "+" PrgStyle, ahk_pid%PrgPID%
	WinGetPos, x, y, w, h, ahk_pid%PrgPID%
		if (!PrgPos[3])
		PrgPos[1] := x, PrgPos[2] := y, PrgPos[3] := w, PrgPos[4] := h
	WinMove, ahk_pid%PrgPID%,, PrgPos[1], PrgPos[2], PrgPos[3], PrgPos[4]
	; Return to original position & maximize if required
		if (PrgMinMaxVar)
		WinMaximize, ahk_pid%PrgPID%
	}
Return 0
}






































;Monitor routines
GetDisplayData(PrgLnchMon := 1, targMonitorNum := 1, ByRef dispMonNamesNo := 0, ByRef iDevNumArray := 0, ByRef dispMonNames := 0, ByRef scrDPI := 0, ByRef scrWidth := 0, ByRef scrHeight := 0, ByRef scrInterlace := 0, ByRef scrFreq := 0, iMode := -2, iChange := 0)
{
Device_Mode := 0, iDevNumb = 0, ftemp := 0, temp := 0, retVal := 0, devFlags := 0, devKey := 0, OffsetDWORD := 4
iLocDevNumArray := [0, 0, 0, 0, 0, 0, 0, 0, 0]

	if (iMode = -3)
	{


			if (A_IsUnicode)
			{
			offsetWORDStr := 64
			OffsetLongStr := 256
			; Note Union in Devmode structure is either/or printer stuff screen stuff

			}
			else
			{
			offsetWORDStr := 32
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

		cbDISPDEV := OffsetDWORD + OffsetDWORD + offsetWORDStr + 3 * OffsetLongStr
		VarSetCapacity(DISPLAY_DEVICE, cbDISPDEV, 0)
		NumPut(cbDISPDEV, DISPLAY_DEVICE, 0) ; initialising cb (byte counts) or size member

		if (!DllCall("EnumDisplayDevices", PTR,0, UInt,iDevNumb, PTR,&DISPLAY_DEVICE, UInt,0))
		{
		dispMonNamesNo := iDevNumb
		break
		}



		devFlags := NumGet(DISPLAY_DEVICE, OffsetDWORD + offsetWORDStr + OffsetLongStr, UInt)
		devKey := StrGet(&DISPLAY_DEVICE + OffsetDWORD + OffsetDWORD + offsetWORDStr + OffsetLongStr + OffsetLongStr, OffsetLongStr)

		If (devFlags & DISPLAY_DEVICE_MIRRORING_DRIVER)
		temp += 1
		else
		{

		iDevNumb := iDevNumb + 1

			;How do we differentiate between ....
			If (devFlags & DISPLAY_DEVICE_PRIMARY_DEVICE)
				{
					If (devFlags & DISPLAY_DEVICE_ATTACHED_TO_DESKTOP)
					iLocDevNumArray[iDevNumb] := iDevNumb + 110
					else
					iLocDevNumArray[iDevNumb] := iDevNumb + 100 ; Impossible
				}
			else
				{
					If (devFlags & DISPLAY_DEVICE_ATTACHED_TO_DESKTOP)
					iLocDevNumArray[iDevNumb] := iDevNumb + 10
					else
					iLocDevNumArray[iDevNumb] := iDevNumb
				}

			if (iDevNumArray[iDevNumb])
			{
			if (iDevNumArray[iDevNumb] != iLocDevNumArray[iDevNumb])
			{
				if (!ftemp)
				{
				MsgBox, 8192, , A configurational change in the monitor setup is detected.`nThis may affect how some Prgs run.
				ftemp := 1
				}
			}
			}
			else
			iDevNumArray[iDevNumb] := iLocDevNumArray[iDevNumb]

			dispMonNames[iDevNumb] := StrGet(&DISPLAY_DEVICE + OffsetDWORD, offsetWORDStr)

			if (!dispMonNames[iDevNumb])
			{
			; happens on XP
			dispMonNamesNo := iDevNumb
			MsgBox, 8192, , " GetDisplay breaks at: dispMonNamesNo: " dispMonNamesNo
			break
			}

		}
		VarSetCapacity(DISPLAY_DEVICE, 0)
		}
	dispMonNamesNo := dispMonNamesNo - temp

	}
	else
	{


		;dmDeviceName ; 5 words, 5 short, 17 Dwords, 2 longs (POINTL:="x,y")... 5 * 2 + 5 * 2 + 16 * 4  + 2 * 4 = 92 structure has TWO Unions
		if (A_IsUnicode)
		{
		OffsetdevMode := 2 * 32
		offsetWORDStr := 64
		}
		else
		{
		OffsetdevMode := 32
		offsetWORDStr := 32
		}
		;(A_PtrSize = 8)? 64bit := 1 : 64bit := 0 ; not required for DM

	cbdevMode := 92 + 32 + 32 + OffsetdevMode
	VarSetCapacity(Device_Mode, cbdevMode, 0)
	NumPut(cbdevMode, Device_Mode, OffsetDWORD + offsetWORDStr, Ushort) ; initialise cbsize member

	if (iChange)
	retVal := DllCall("EnumDisplaySettings", PTR,dispMonNames[targMonitorNum], UInt,iMode, PTR,&Device_Mode)
	else ;current display device
	retVal := DllCall("EnumDisplaySettings", PTR,dispMonNames[PrgLnchMon], UInt,iMode, PTR,&Device_Mode)


	;NumGet(Device_Mode, 64bit*32 + 4 +OffsetdevMode/2,UShort) ;dmSize, (before the 2nd Tchar)
	;NumGet(Device_Mode, 64bit*32 + 6 +OffsetdevMode/2,UShort) ;dmDriverExtra
	;NumGet(Device_Mode, 64bit*32 + 8 + OffsetdevMode/2,UInt) ; dmFields, see below: location of extra monitors
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


	VarSetCapacity(Device_Mode, 0)
	}
	Return retVal
}


ChangeResolution(scrWidth := 1920, scrHeight := 1080, scrFreq := 60, targMonitorNum := 1)
{
	local Device_Mode := 0, monName := 0, devFlags := 0, CDSopt := 0, scrInterlace := 0, scrDPI := 32, strRetVal := "", DM_Position := 0, mdLeft := 0, mdTop := 0, cbSize := 0, OffsetWORD := 0, OffsetDWORD := 4

	GuiControlGet Test, PrgLnchOpt:, Test
		If (Test)
		CDSopt := CDS_TEST
	GuiControlGet FMode, PrgLnchOpt:, FMode
		If (FMode)
		CDSopt := CDS_RESET
	GuiControlGet Tmp, PrgLnchOpt:, Tmp
		If (Dynamic)
		CDSopt := CDS_UPDATEREGISTRY
	GuiControlGet Dynamic, PrgLnchOpt:, Dynamic
		If (Tmp)
		CDSopt := CDS_FULLSCREEN

		if (A_IsUnicode)
		{
		cbSize := 220 ;  2 + 2 + 64
		OffsetWORD := 64
		VarSetCapacity(Device_Mode, cbSize, 0)
		NumPut(cbSize, Device_Mode, OffsetDWORD + 64, "Ushort")
		}
		else
		{
		cbSize := 156 ;  2 + 2 + 32
		OffsetWORD := 0
		VarSetCapacity(Device_Mode,cbSize,0)
		NumPut(cbSize, Device_Mode, OffsetDWORD + 32, "Ushort")
		}

		if (RegoVar)
		{
		ENUM_REGISTRY_SETTINGS := -2
		GetDisplayData(PrgLnch.Monitor, targMonitorNum, dispMonNamesNo, , , scrDPI, , , scrInterlace, , ENUM_REGISTRY_SETTINGS, 1)
		}
		else
		{
		GetDisplayData(PrgLnch.Monitor, targMonitorNum, dispMonNamesNo, , , scrDPI, , , scrInterlace, , -1, 1)
		}




	;The following values should never change, but just in case!
	;OffsetWORD of dmPosition = 44
	;OffsetWORD of dmDisplayOrientation = 52
	;OffsetWORD of dmDisplayFixedOutput = 56

	NumPut(scrDPI,Device_Mode,104+OffsetWORD, "UInt")
	NumPut(scrInterlace,Device_Mode,116+OffsetWORD, "UInt")
	NumPut(scrWidth,Device_Mode,108+OffsetWORD, "UInt") ; A_ScreenWidth
	NumPut(scrHeight,Device_Mode,112+OffsetWORD, "UInt") ; A_ScreenHeight
	NumPut(scrFreq,Device_Mode,120+OffsetWORD, "UInt") ;



	NumPut(0, Device_Mode,38+OffsetWORD/2, "Ushort") ;dmDriverExtra



	if (targMonitorNum != PrgLnch.Monitor)
	{
	devFlags := 0x00000020		; DM_POSITION
				| 0x00080000	; DM_PELSWIDTH
				| 0x00100000	; DM_PELSHEIGHT
	;dmFields, a POINTL:="x,y" structure is a union of structs
	VarSetCapacity(DM_Position,8,0)
	Numput(mdLeft + 1,DM_Position, 0, "UInt")
	Numput(mdTop + 1,DM_Position, 4, "UInt")
	Numput(&DM_Position,Device_Mode,44+OffsetWORD/2)
	}
	else
	{
	devFlags := 0x00080000 | 0x00100000
	}
	NumPut(devFlags, Device_Mode,40+OffsetWORD/2, "UInt")
	;OffsetWORD of dmDisplayOrientation = 52
	;OffsetWORD of dmDisplayFixedOutput = 56


	monName := dispMonNames[targMonitorNum]

	;Ref SetDisplayConfig. The usual approach is to call with CD_TEST and if no error use CDS_UPDATEREGISTRY | CDS_NORESET. With 2 monitors, again call ChangeDisplaySettingsExto change settings.
	retVal := DllCall("ChangeDisplaySettingsEx", "Ptr", &monName, "Ptr", &Device_Mode, "Ptr", 0, "UInt", CDSopt, "Ptr", 0)
	Sleep 100

	VarSetCapacity(DM_Position, 0)
	VarSetCapacity(Device_Mode, 0)
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
		strRetVal := "Change Settings Failed: (Windows XP & later) The settings change was unsuccessful because system is DualView capable."
		else
		{
			if (retVal = DISP_CHANGE_BADPARAM) ;-5
			strRetVal := "Change Settings Failed: An invalid parameter was passed in. This can include an invalid flag or combination of flags."
			else
			{
			if (retVal = DISP_CHANGE_BADFLAGS) ;-4
			strRetVal := "An invalid set of flags was passed in."
			else
			{
			if (retVal = DISP_CHANGE_NOTUPDATED) ;-3
			strRetVal := "(Windows NT/2000/XP: Unable to write settings to the registry."
			else
			{
			if (retVal = DISP_CHANGE_BADMODE) ;-2
			strRetVal := "The graphics mode is not supported. This can be caused by an out of range resolution value."
			else
			{
			if (retVal = DISP_CHANGE_FAILED) ;-1
			strRetVal := "The display driver failed the specified graphics mode."
			else
			if (retVal = DISP_CHANGE_RESTART) ;1
			strRetVal := "The computer must be restarted in order for the graphics mode to work."
			}
			}
			}
			}

		}
	}

Return strRetVal
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
			;many iModes here are equivalent for the above params. scrFreq & scrHeight may vary for a subset of those
			if  (allModes && !(scrHeightlast = scrHeight))
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
				scrHeightlast := scrHeight
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

DefResNoMatchRes(SelIniChoicePath, Fmode, scrWidth, scrHeight, scrWidthDef, scrHeightDef)
{
defResmsg := 0

if (scrWidth=scrWidthDef && scrHeight=scrHeightDef)
{
if (Fmode) ;always change
Return 1

IniRead, defResmsg, %SelIniChoicePath%, General, DefResmsg
	if (defResmsg)
	{
		if (defResmsg = 1)
		Return 0
		else
		Return 1
	}
	else
	{
	MsgBox, 8195, Resolution Change, The resolution on the target monitor is the same as the current resolution. `n(It will automatically change when "Change at every mode" in "Res Options" is selected, irrespective of the following choice):`n`nReply:`nYes: Change resolution (This will not show again)`nNo: Do not change resolution: (Recommended: This will not show again) `n `nCancel: Do nothing: `n
	;note msgbox isn't modal if called from function
		IfMsgBox, No
		{
		IniWrite, 1, %SelIniChoicePath%, General, defResmsg
		Return 0
		}
		else
		{
			ifMsgBox, Yes
			{
			IniWrite, 2, %SelIniChoicePath%, General, defResmsg
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


MDMF_GetMonHandle(targMonitorNum)
{
Static Monitors := 0
Monitors := {Count: 0, targetMonitorNum: 0}
Monitors.targetMonitorNum := targMonitorNum


;If (Monitors.MaxIndex() = "") ; enumerate
Static EnumProc := RegisterCallback("MonitorEnumProc", "", 4)

; enumerates monitors in the same order as sysget.
If (!DllCall("User32.dll\EnumDisplayMonitors", "ptr", 0, "ptr", 0, "ptr", EnumProc, "ptr", &Monitors))
Return False
}

MonitorEnumProc(hMonitor, hdcMonitor, lprcMonitor, MonitorsObj)
{
64bit := 0 , Physical_Monitor := 0, temp := 0, fTemp := 0, physHand := 0, outStr := "", Monitors := Object(MonitorsObj)
Monitors.Count++
MonitorsObj := Monitors

if (Monitors.Count = Monitors.targetMonitorNum)
{

; Get Physical Monitor(s) from handle


	if (!DllCall("dxva2\GetNumberOfPhysicalMonitorsFromHMONITOR", "Ptr", hMonitor, "uint*", nMon))
	{
	ToolTip, % "GetNumberOfPhysicalMonitorsFromHMONITOR failed with code: " A_LastError " .", 0, 0
	return False
	}

	; Get Physical Monitor from handle
	(A_PtrSize = 8)? 64bit := 2 : 64bit := 1
	OffsetDWORD := 4, OffsetUchar := 1
	Physical_Monitor_size_single:= 64bit * OffsetDWORD + (A_IsUnicode ? 2 : 1)*128
	VarSetCapacity(Physical_Monitor, nMon*Physical_Monitor_size_single, 0)
	if (DllCall("dxva2\GetPhysicalMonitorsFromHMONITOR", "Ptr", hMonitor, "uint", nMon, "Ptr", &Physical_Monitor))
	{
		Loop %nMon%
		{
			if (nMon > 1)
			outStr .= "`n"

			physHand := NumGet(Physical_Monitor, (A_Index-1)*Physical_Monitor_size_single)
			; 0 value Physical Monitor Handles are valid and common!!!
			VarSetCapacity(MC_TIMING_REPORT, OffsetUchar + OffsetDWORD + OffsetDWORD)
			retVal := DllCall("dxva2\GetTimingReport", "Ptr", physHand, "Ptr", &MC_TIMING_REPORT)
			sleep 100
			if (retVal)
			{
			; Get Monitor description
			temp := &Physical_Monitor + 64bit * OffsetDWORD + (A_Index-1)*(Physical_Monitor_size_single + 64bit * OffsetDWORD)
			temp := StrGet(temp, Physical_Monitor_size_single)

			;Horizontal scan HZ
			fTemp := NumGet(MC_TIMING_REPORT, 0, "Int")
			outStr .= "Monitor Description: " . temp . "`nHorizontal Frequency: " . fTemp/100 . " KHz"
			}
			else
			{
			if (A_LastError = -1071241854)
			strRetVal := "ERROR_GRAPHICS_I2C_ERROR_TRANSMITTING_DATA"
			else
			retVal := A_LastError
			outStr .= "GetTimingReport failed with code: " retVal " ."
			}

			if (!DllCall("dxva2\DestroyPhysicalMonitor", "ptr", physHand))
			{
			if (A_LastError = -1071241844)
			strRetVal := "ERROR_GRAPHICS_INVALID_PHYSICAL_MONITOR_HANDLE"
			else
			if (A_LastError = -1071241852)
			strRetVal := "ERROR_GRAPHICS_DDCCI_VCP_NOT_SUPPORTED"
			else
			retVal := A_LastError
			outStr .= "DestroyPhysicalMonitor failed with code: " retVal " ."
			}

			VarSetCapacity(MC_TIMING_REPORT, 0)
		}
		ToolTip, % outStr, 0, 0
	}
	else
	{
	ToolTip, % "GetPhysicalMonitorsFromHMONITOR failed with code: " A_LastError " .", 0, 0
	}

	VarSetCapacity(Physical_Monitor, 0)
return False ;No more iterations required
}
else
Return True
}
































































; Downloading
UpdtPrg:
GuiEscape:
Gui, PrgLnchOpt: +OwnDialogs
Gui, PrgLnchOpt: Submit, Nohide
GuiControlGet, temp, PrgLnchOpt: FocusV

;If !(A_IsCritical)
;Critical

if (temp != "UpdtPrgLnch")
GoSub PrgLnchButtonQuit_PrgLnch


Tooltip
GuiControlGet temp, PrgLnchOpt:, % A_GuiControl


if (temp="&Update Prg")
{
	SetTimer, NewThreadforDownload, 200
	Return
}
else ;interrupted download but wish to continue
{
	if (temp="&Save URL")
	{

		;;verify URL
									
		If (!RegExMatch(PrgUrlTest, "^(https?://|www\.)[a-zA-Z0-9\-\.]+\.[a-zA-Z]{2,3}(/\S*)?$"))
		{
			MsgBox, 8193, , The URL doesn't appear valid. Use it?
			IfMsgBox, Cancel
			Return
		}
		UrlPrgIsCompressed := ChkURLPrgExe(PrgUrlTest)
		if (UrlPrgIsCompressed < 0)
		{
			MsgBox, 8193, , The URL doesn't appear to have an extension for a compressed or executable file.`nUse it?
			IfMsgBox, Cancel
			Return
		}

		GuiControl, PrgLnchOpt:, UpdtPrgLnch, % "&Update Prg"
		PrgUrl[selPrgChoice] := PrgUrlTest

		IniWrite, %PrgUrlTest%, %SelIniChoicePath%, Prg%selPrgChoice%, PrgUrl
	}
	else
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
}
Return


NewThreadforDownload: ;Timer!
	HideShowCtrls(1)
	GuiControl, PrgLnchOpt: , UpdtPrgLnch, &Cancel (Esc)

	;In most cases only the file names in the url will want encoding-else only spaces in folders or user names
	;https://github.com/ahkscript/libcrypt.ahk/blob/master/src/URI.ahk
	;https://tools.ietf.org/html/rfc3986
	;We don't know if the URL works, but write it to ini anyway
	IniProc(selPrgChoice)


	strTemp := ExtractPrgPath(selPrgChoice, PrgChoicePaths, 0, PrgLnkInf, IsaPrgLnk, IniFileShortctSep)
	if (InStr(PrgUrl[selPrgChoice], "%"))
	DownloadFile(SelIniChoicePath, LC_UrlDecode(PrgUrl[selPrgChoice]), strTemp, updateStatus)
	else
	DownloadFile(SelIniChoicePath, LC_UrlEncode(PrgUrl[selPrgChoice]), strTemp, updateStatus)


		if (updateStatus < 0)
		{
			if (updateStatus = -1)
			{
			Sleep, 100 ;Do events
			FileDelete, % strTemp
			If (ErrorLevel) ;Try once more
				{
				Sleep, 100
					Try
					{
					FileDelete, % strTemp
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

		if (!UrlPrgIsCompressed)
		{
		FileGetVersion, PrgverNew, % strTemp
			if (ErrorLevel)
			{
			PrgVer[selPrgChoice] := 0
			MsgBox, 8192, , % "Problem with retrieving local version info for file " strTemp
			}
			else
			{
			PrgVer[selPrgChoice] := PrgVerNew
			IniWrite, %PrgVerNew%, %SelIniChoicePath%, Prg%selPrgChoice%, PrgVer
			}

		IniRead, fTemp, %SelIniChoicePath%, General, PrgLaunchAfterDL

			if (!fTemp)
			{
			MsgBox, 8195, , Launch the newly downloaded Prg to test it? `nIf replying 'Yes', PrgLnch Options won't be available until the launched Prg is closed.`n`nReply:`nYes: Launch (Warn like this next time)`nNo: Do not launch (Warn like this next time) `nCancel: Do not launch (This will not show again): `n
				IfMsgBox, Yes
				{
				Runwait, % strTemp, , UseErrorLevel ; might be a self extracting package
					if (ErrorLevel)
					MsgBox, 8192, , The file could not be launched with error %ErrorLevel%
				}
				else
				{
					IfMsgBox, Cancel
					IniWrite, 1, %SelIniChoicePath%, General, PrgLaunchAfterDL
				}
			}
		strTemp2 := ExtractPrgPath(selPrgChoice, PrgChoicePaths, 0, PrgLnkInf, IsaPrgLnk, IniFileShortctSep)
		if (strTemp != strTemp2)
		{
		SplitPath, strTemp2,, strTemp2
		SplitPath, strTemp,, strTemp
			if (strTemp2 = strTemp)
			{
				MsgBox, 8193, , % "The updated Prg is allocated this path name:`n" strTemp "`nThe original Prg still exists with this path name.`n" strTemp2 "`nOK: Delete the original`nCancel: Keep the original as a backup copy."
				IfMsgBox, Ok
				{
					Try
					{
					FileDelete % PrgChoicePaths[selPrgChoice]
					}
					catch retVal
					{
					MsgBox, 8208, Ini File Delete, Error deleting (broken) file! `nSpecifically: %retVal%
					}
				}
			PrgChoicePaths[selPrgChoice] := strTemp
			IniWrite, %strTemp%, %SelIniChoicePath%, Prg%selPrgChoice%, PrgPath
			}
			else
			MsgBox, 8208, , % "The updated Prg is allocated this folder:`n" strTemp "`nThe original Prg is allocated this folder.`n" strTemp2 "`nGiven the location used for the download of Prg is preferred, for the purposes of housekeeping, consider the manual removal of the old location."
		}
		; else Prg is overwritten
		}
		}
	;Critical, Off
	HideShowCtrls()
	GuiControl, PrgLnchOpt: , UpdtPrgLnch, &Update Prg
	GuiControl, PrgLnchOpt: Show, UpdtPrgLnch
	updateStatus := 1
	SetTimer, NewThreadforDownload, Off
	Sleep, 60 ;Do events
Return



;http://www.codeproject.com/Article.aspx?tag=198374993737746150&_z=11114232
DownloadFile(SelIniChoicePath, UrlToFile, ByRef SaveFileAs, ByRef updateStatus)
{
	X :=0, Y:=0, temp:=0, strTemp := "", fTemp := 0, badFile := "text`/html", timedOut := False, prgWid := PrgLnchOpt.Width()/3, prgHght := PrgLnchOpt.Height()/2
	;Check if the file already exists + overwrite

	If (updateStatus > 0)
		{
		Gui, PrgLnchOpt: +OwnDialogs
		FileSelectFile, temp, S 19, % SaveFileAs, % "Save as " SaveFileAs
			Gui, PrgLnchOpt: -OwnDialogs
			if (temp)
			updateStatus := 0
			else
			{
			updateStatus := -2
			Return
			}

			SplitPath, temp, , strTemp
			SplitPath, temp, temp
			ChkCmdLineValidFName(temp)
			if Instr(strTemp, A_WinDir)
			{
			IniRead, fTemp, %SelIniChoicePath%, General, WinRtDirWrn
				if (!fTemp)
				{
				MsgBox, 8195, Windows Directory, The file to be downloaded is to be copied to the Windows area.`nDirectories and subdirectories there contain protected system files,`nso downloading anything like those will not work,`nand downloading anything else there is not recommended.`n`nReply:`nYes: Continue (Warn like this next time)`nNo: Abort the download (Warn like this next time) `nCancel: Abort the download. (This will not show again)`n
					IfMsgBox, Yes
					fTemp := 0
					else
					{
						IfMsgBox, Cancel
						IniWrite, 1 , %SelIniChoicePath%, General, WinRtDirWrn
					updateStatus := -2
					Return
					}
				}
			}
			SaveFileAs := strTemp . "\" . temp

		}
	WebRequest := ComObjCreate("WinHttp.WinHttpRequest.5.1")
	WebRequest.Open( "GET", UrlToFile), WebRequest.Send()
    ;Bad file-  also check types :http://www.iana.org/assignments/media-types/media-types.xhtml
	temp := % WebRequest.GetAllResponseHeaders()
		if (Instr(temp, badFile))
		{
		MsgBox, 8192, ,Wrong file header, or file not found!
		updateStatus := -2
		WebRequest := ""
		Return
		}

	;Check if the user wants a progressbar
	;Initialize the WinHttpRequest Object
	;WebRequest := ComObjCreate("WinHttp.WinHttpRequest.5.1")
	;Download the headers

	WebRequest.Open("HEAD", UrlToFile, true)


	WebRequest.Send()
	WebRequest.WaitForResponse()
	;Store the header which holds the file size in a variable:
		try
		{
		FinalSize := WebRequest.GetResponseHeader("Content-Length")
		;Create the progressbar and the timer
		GuiControl, PrgLnchOpt: , UpdtPrgLnch, Preparing...
		Sleep, 2200 ;timeout: 2 seconds (should not time out)
		ComObjError(False)
		WinHttpReq.Status
			If (A_LastError) ;if WinHttpReq.Status was not set (no response received yet)
			timedOut := True
		ComObjError(True)



		If (!FinalSize || timedOut)
		MsgBox, 8192, , Timed out

		Progress, Hide ,, Downloading...
		WinGet, Hwnd, ID,,, Downloading...
		SysGet, X, 45 ;Progress bar border B1 corresponds with SM_CXEDGE?
		SysGet, Y, 4 ;Height of a caption area?

		X := PrgLnchOpt.X() - prgWid - (2 * X)
		Y := PrgLnchOpt.Y() + PrgLnchOpt.Height() - prgHght - (2 * Y)

			if (X < 0) ;form was moved to the left
			X := PrgLnchOpt.X() + PrgLnchOpt.Width()
		Progress, X%X% Y%Y% W%prgWid% H%prgHght% M,, Downloading..., %UrlToFile%
		Progress Show


		SetTimer, __UpdateProgressBar, 200

		}
		catch temp
		{
		msgbox, 8208, FileDownload, Problem with the URL!`nSpecifically: %temp%
		Progress, Off
		updateStatus := -3
		SetTimer, __UpdateProgressBar, Delete
		WebRequest := ""
		Return
		}

	GuiControl, PrgLnchOpt: , UpdtPrgLnch, &Cancel (Esc)
	;Download the file
		try
		{
		UrlDownloadToFile, %UrlToFile%, %SaveFileAs%
		}
		catch temp
		{
		msgbox, 8208, FileDownload, Error with the download!`nSpecifically: %temp%
		PercentDone := 100
		updateStatus := -1
		Progress, Off
		SetTimer, __UpdateProgressBar, Delete
		GuiControl, PrgLnchOpt: Hide, UpdtPrgLnch
		GuiControl, PrgLnchOpt: , UpdtPrgLnch, &Update Prg
		WebRequest := ""
		Return
		}
	;Remove the timer and the progressbar because the download has finished
	GuiControl, PrgLnchOpt: Hide, UpdtPrgLnch
	GuiControl, PrgLnchOpt: , UpdtPrgLnch, &Update Prg
	Progress, Off
	SetTimer, __UpdateProgressBar, Delete
	WebRequest := ""
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
	VarSetCapacity(Var, 0)
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
		VarSetCapacity(Var, 0)
	}
	Return, Uri
}
GetPrgVersion(currPrgUrl, ByRef PrgVerNew := 0)
{

err := 0
; Example: Make an asynchronous HTTP request.
req := ComObjCreate("WinHttp.WinHttpRequest.5.1")
; Open a request with async enabled.

strTemp := InStr(currPrgUrl, "/", false, -1)
verLoc := SubStr(currPrgUrl, 1, strTemp)
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
	PrgVerNew := req.ResponseText
	;version is never going to exceed 1000 bytes, so Returns junk if version.txt not found

	if (!PrgVerNew || StrLen(PrgVerNew)>1000)
	{
	PrgVerNew := 0
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
	DoVersionErrorMessage(Results, verLoctmp)

	Return 1
	}

	Return 0
}

DoVersionErrorMessage(Results, verLoctmp)
{
Local strTemp2 := ""

	IniRead, strTemp2, %SelIniChoicePath%, General, PrgVersionError
	if (!strTemp2)
	{
	MsgBox, 8196, , % "Prg Url Version, " Results " and version.txt not found at `n" verLoctmp "`nIf no URL displayed, it's a timing issue or a temporary error.`n`nYes: Continue (Warn like this next time) `nNo: Continue (This will not show again) `n"
		IfMsgBox, No
		IniWrite, 1, %SelIniChoicePath%, General, PrgVersionError
	}
}

DcmpExecutable(selPrgChoice, PrgChoicePaths, PrgLnkInf, IniFileShortctSep, checkSubSys := 0)
{
sizeOfOptionalHeader := 0, e_lfanew := 0, e_magic := 0, ntHeaders32 := 0, temp := 0

IMAGE_DOS_SIGNATURE_BIG_ENDIAN := 0x4D5A
IMAGE_DOS_SIGNATURE := 0x5A4D ; first 2 bytes 23117
IMAGE_NT_HEADERS32 := 0x4550 ;17744: Not interested in IMAGE_NT_HEADERS64 (aka IMAGE_FILE_HEADER)
PE_HEADER_OFFSET_ADDRESS := 0X3C ; 60
IMAGE_FILE_HEADER_SIZE := 0X18 ;24
CHARACTERISTICS_OFFSET := 0X12 ;18 
IMAGE_SUBSYSTEM_WINDOWS_GUI := 0x0002
IMAGE_SUBSYSTEM_WINDOWS_CUI := 0x0003

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

exeStr := ExtractPrgPath(selPrgChoice, PrgChoicePaths, 0, PrgLnkInf, temp, IniFileShortctSep)

	if (!fileExist(exeStr) || InStr(exeStr, ".lnk", false, strLen(exeStr) - 4))
	Return
	else
	exeStr := AssocQueryApp(exeStr)

exeStrOld := exeStr
SplitPath, exeStrOld, exeStrOld


exeStr := FileOpen(exeStr , "rw" "-rwd")


if (IsObject(exeStr))
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
			if (checkSubSys)
			{
			; sizeOfOptionalHeader is in IMAGE_FILE_HEADER
			sizeOfOptionalHeader := SeekProc(exeStr, e_lfanew + 20, "ushort", "check")
			OptHeaderMagicNo := SeekProc(exeStr, e_lfanew + IMAGE_FILE_HEADER_SIZE, "Ushort", "check")
			
				if (OptHeaderMagicNo = 0x10b)
				optHeader_Magic := "PE32"
				else
				{
					if (OptHeaderMagicNo = 0x20B)
					optHeader_Magic := "PE32+"
					else
					optHeader_Magic := "ROMIMAGE"
				}
			temp := SeekProc(exeStr, e_lfanew + IMAGE_FILE_HEADER_SIZE + 68, "ushort", "check")

				if (temp = IMAGE_SUBSYSTEM_WINDOWS_GUI || temp = IMAGE_SUBSYSTEM_WINDOWS_CUI)
				temp := 1
				else
				temp := 0
			exeStr.Close()
			Return temp
			}

			else
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
					MsgBox, 8192, , % "Unable to remove LAA Flag. Is " exeStrOld " opened in an editor?"
				}
				else
				{

				;lAA := lAA | IMAGE_FILE_LARGE_ADDRESS_AWARE

				if (lAA & IMAGE_FILE_LARGE_ADDRESS_AWARE)
				MsgBox, 8192, , %  exeStrOld " already has the LAA patch!"
				else
				{
				; check at least one of the flags exist
				if (lAA & IMAGE_FILE_RELOCS_STRIPPED || lAA & IMAGE_FILE_EXECUTABLE_IMAGE || lAA & IMAGE_FILE_LINE_NUMS_STRIPPED || lAA & IMAGE_FILE_LOCAL_SYMS_STRIPPED || lAA & IMAGE_FILE_AGGRESIVE_WS_TRIM || lAA & IMAGE_FILE_16BIT_MACHINE || lAA & IMAGE_FILE_BYTES_REVERSED_LO || lAA & MAGE_FILE_32BIT_MACHINE || lAA & IMAGE_FILE_DEBUG_STRIPPED || lAA & IMAGE_FILE_REMOVABLE_RUN_FROM_SWAP || lAA & IMAGE_FILE_NET_RUN_FROM_SWAP || lAA & IMAGE_FILE_SYSTEM || lAA & IMAGE_FILE_DLL || lAA & IMAGE_FILE_UP_SYSTEM_ONLY || lAA & IMAGE_FILE_BYTES_REVERSED_HI)
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
					MsgBox, 8192, , % "Unable to write LAA Flag. Is " exeStrOld " opened in an editor?"
				}
				else
				MsgBox, 8192, , %  "Unexpected data in Characteristics field. LAA flag cannot not be written!"
				}
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
		if (e_magic = IMAGE_DOS_SIGNATURE_BIG_ENDIAN)
		MsgBox, 8192, , %  "No can do! This executable runs on a Big_Endian system!"
		else
		{
		MsgBox, 8192, , %  "Bad exe file: no DOS sig."
		;creates empty file if non-existent: Already checked above!
		exeStr.Close()
		FileGetSize temp, %exeStr%
		if (!temp)
		FileDelete, %exeStr%
		Return 0
		}
	}
	exeStr.Close()
}
else
{
	if (!checkSubSys || (checkSubSys && !Instr(PrgChoicePaths[selPrgChoice], A_WinDir)))
	{
		if (A_IsAdmin)
		msgbox, 8196 ,File Open, % exeStrOld " could not be accessed with error " A_LastError "."
		else
		{
		msgbox, 8196 ,File Open, % exeStrOld " could not be accessed with error " A_LastError ".`nIs it opened by another process, or does it have special permissions?`nIt might be possible for PrgLnch to open it as Admin:`n`nYes: Attempt to restart PrgLnch as Admin.`nNo: Do not restart PrgLnch.`n"
			IfMsgBox, Yes
			RestartPrgLnch(1)
		}
	}
	else
	Return 1 ;Optimistically
}
Return 0
}
; SeekProc: Seek to absolute offset and read a number of the specified type.
SeekProc(stream, offset, type, action)
{
retVal := 0
stream.Seek(offset)
VarSetCapacity(v,8)

if (action = "check")
{
	retVal := stream.ReadShort()
	VarSetCapacity(v, 0)
	return retVal
}
else
{
	/*
	; We could possibly swap Big_Endian in a new pass:
	SwapEndian(ByRef Var, Bytes)
	{
	VarSetCapacity(BE, 8, 0)
	loop % Bytes
	{
		NumPut(NumGet(Var, Bytes-A_Index, "Uint"), BE, A_Index-1, "Uint")
	}
	return NumGet(BE, "Uint")
	}
	*/
	if (action)
	{
	bytesToProcess := NumPut(action,v,0,type) - &v ;Numput returns the address to the "right" of  item just written
	retVal := stream.RawWrite(v, bytesToProcess)
	VarSetCapacity(v, 0)
	return retVal 
	}

	else
	{


	bytesToProcess := NumPut(0,v,0,type) - &v ;Numput returns the address to the "right" of  item just written
	bytesRead := stream.RawRead(v, bytesToProcess)
	;if !(DllCall("ReadFile", "uint", stream, "uint", &v, "uint", bytesToProcess, "uint*", bytesRead, "uint", 0) && bytesRead == bytesToProcess)
	if (v)
	{
	MsgBox, 8192, , % " Read failed"
	VarSetCapacity(v, 0)
	return 0
	}
	else
	{
	retVal := NumGet(v, 0, type)
	VarSetCapacity(v, 0)
	return retVal 

	}
	}
}
}


WinMover(Hwnd := 0, position := "hc vc", Width := 0, Height := 0, splashInit := 0 ,wdRatio := 1, htRatio := 1)
{
	x:= 0, y := 0, w := 0, h:= 0

; wdRatio, htRatio not used

	if (Width && Hwnd)
	WinMove, ahk_id %Hwnd%,,,, Width, Height
	;by Learning one
	; position: l=left, hc=horizontal center, r=right, u=up, vc= vertical center, d=down, b=bottom (same as down)

	SysGet, Mon, MonitorWorkArea, % PrgLnch.Monitor
	oldDHW := A_DetectHiddenWindows
	DetectHiddenWindows, On

	strTemp := A_CoordModeMouse
	CoordMode, Mouse, Screen

	if (splashInit)
	{
;Ensures a consistent starting directory.
	strRetVal := WorkingDirectory(A_ScriptDir, 1)
		if (strRetVal)
		MsgBox, 8192, WinMover, % strRetVal
		else
		{
			If (!FileExist(splashInit))
			{
				if (splashInit = "PrgLnchLoading.jpg")
				FileInstall PrgLnchLoading.jpg, PrgLnchLoading.jpg
				else
				FileInstall PrgLaunching.jpg, PrgLaunching.jpg
			sleep, 200
			}
		SplashImage, %splashInit%, A B,,,LnchSplash
		WinGetPos,ix,iy,w,h, LnchSplash
		}
	}
	else
	WinGetPos,ix,iy,w,h, ahk_id %Hwnd%

	position := StrReplace(position, "b", "d") ;b=bottom (same as down)
	x := InStr(position,"l")? MonLeft: InStr(position,"hc")? (MonLeft + (MonRight-MonLeft-w)/2): InStr(position,"r") ? MonRight - w: ix
	y := InStr(position,"u")? MonTop: InStr(position,"vc")? (MonTop + (MonBottom-MonTop-h)/2): InStr(position,"d") ? MonBottom - h: iy


	if (splashInit)
	WinMove, LnchSplash,, wdRatio * x, htRatio * y
	else
	WinMove, ahk_id %Hwnd%,, wdRatio * x, htRatio * y
	CoordMode, Mouse, % strTemp
	DetectHiddenWindows, %oldDHW%


}

TogglePrgOptCtrls(txtPrgChoice, navShortcut, borderToggle := 0, selPrgChoice := 0, PrgChgResonSwitch := 0, PrgRnMinMax := 0, PrgRnPriority := 0, PrgBordless := 0, PrgLnchHide := 0, CtrlsOn := 0, lnkDisable := 0)
{
if (CtrlsOn)
{
	GuiControl, PrgLnchOpt: Enable, ChgResonSwitch
	GuiControl, PrgLnchOpt:, ChgResonSwitch, % PrgChgResonSwitch[selPrgChoice]
	GuiControl, PrgLnchOpt:, PrgMinMax, % PrgRnMinMax[selPrgChoice]
	GuiControl, PrgLnchOpt: Enable, PrgPriority
	GuiControl, PrgLnchOpt:, PrgPriority, % PrgRnPriority[selPrgChoice]
	GuiControl, PrgLnchOpt: Text, Bordless, Ext. Borderless
		if (borderToggle)
		{
		GuiControl, PrgLnchOpt: Enable, Bordless
		GuiControl, PrgLnchOpt:, Bordless, % PrgBordless[selPrgChoice]
		}
	GuiControl, PrgLnchOpt: Enable, PrgLnchHd
	GuiControl, PrgLnchOpt:, PrgLnchHd, % PrgLnchHide[selPrgChoice]
		if (lnkDisable)
		{
		GuiControl, PrgLnchOpt: Disable, PrgLAA
		GuiControl, PrgLnchOpt: Disable, PrgMinMax
		}
		else
		{
		GuiControl, PrgLnchOpt: Enable, PrgLAA
		GuiControl, PrgLnchOpt: Enable, PrgMinMax
		}
}
else
{
	GuiControl, PrgLnchOpt: Disable, CmdLinPrm
	GuiControl, PrgLnchOpt:, CmdLinPrm
	GuiControl, PrgLnchOpt:, ChgResonSwitch, 0
	GuiControl, PrgLnchOpt: Disable, ChgResonSwitch
	GuiControl, PrgLnchOpt:, PrgMinMax, -1
	GuiControl, PrgLnchOpt: Disable, PrgMinMax
	GuiControl, PrgLnchOpt:, PrgPriority, -1
	GuiControl, PrgLnchOpt: Disable, PrgPriority
	GuiControl, PrgLnchOpt:, Bordless, 0
	GuiControl, PrgLnchOpt: Disable, Bordless
	GuiControl, PrgLnchOpt:, PrgLnchHd, 0
	GuiControl, PrgLnchOpt: Disable, PrgLnchHd
	GuiControl, PrgLnchOpt:, resolveShortct, 0
		if (txtPrgChoice = "None")
		GuiControl, PrgLnchOpt: Disable, resolveShortct
		else
		GuiControl, PrgLnchOpt: Enable, resolveShortct
	GuiControl, PrgLnchOpt: , resolveShortct, % navShortcut
	GuiControl, PrgLnchOpt: Text, resolveShortct, Shortcut Nav. (Dlg)
	GuiControl, PrgLnchOpt: Disable, PrgLAA
}
}

HideShowTestRunCtrls(showCtrl := 0)
{
if (showCtrl)
{
	GuiControl, PrgLnchOpt: Show, MkShortcut
	GuiControl, PrgLnchOpt: Show, Allmodes
	GuiControl, PrgLnchOpt: Show, ResIndex
	GuiControl, PrgLnchOpt: Show, iDevNum
	GuiControl, PrgLnchOpt: Show, PrgChoice
	GuiControl, PrgLnchOpt: Show, UpdtPrgLnch
	GuiControl, PrgLnchOpt: Show, UpdturlPrgLnch
	GuiControl, PrgLnchOpt: Text, Bordless, Ext. Borderless
	GuiControl, PrgLnchOpt: Show, PrgLnchHd
	GuiControl, PrgLnchOpt: Show, resolveShortct
	GuiControl, PrgLnchOpt: Show, PrgLAA 

	GuiControl, PrgLnchOpt:, RnPrgLnch, &Test Run Prg
	GuiControl, PrgLnchOpt: -ReadOnly, CmdLinPrm
}
else
{
	GuiControl, PrgLnchOpt: Hide, PrgChoice
	GuiControl, PrgLnchOpt: Hide, MkShortcut
	GuiControl, PrgLnchOpt: Hide, Allmodes
	GuiControl, PrgLnchOpt: Hide, iDevNum
	GuiControl, PrgLnchOpt: Hide, ResIndex
	GuiControl, PrgLnchOpt: Hide, PrgLnchHd
	GuiControl, PrgLnchOpt: Hide, resolveShortct
	GuiControl, PrgLnchOpt: Hide, PrgLAA
	GuiControl, PrgLnchOpt: Hide, UpdtPrgLnch
	GuiControl, PrgLnchOpt: Hide, UpdturlPrgLnch
	GuiControl, PrgLnchOpt:, RnPrgLnch, &Cancel Prg
	GuiControl, PrgLnchOpt: +ReadOnly, CmdLinPrm
}

}
HideShowCtrls(ByRef showCtrl := 0)
{
if (showCtrl)
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
GuiControl, PrgLnchOpt: Hide, PrgMinMax
GuiControl, PrgLnchOpt: Hide, PrgLnchHd
GuiControl, PrgLnchOpt: Hide, Bordless
GuiControl, PrgLnchOpt: Hide, PrgPriority
GuiControl, PrgLnchOpt: Hide, ChgResonSwitch
GuiControl, PrgLnchOpt: Hide, resolveShortct
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
GuiControl, PrgLnchOpt: Show, PrgMinMax
GuiControl, PrgLnchOpt: Show, PrgLnchHd
GuiControl, PrgLnchOpt: Show, Bordless
GuiControl, PrgLnchOpt: show, PrgPriority
GuiControl, PrgLnchOpt: show, ChgResonSwitch
GuiControl, PrgLnchOpt: Show, resolveShortct
GuiControl, PrgLnchOpt: Show, PrgLAA

}

}



IniProc(selPrgChoice := 0, removeRec := 0)
{

Local foundPosOld := 0, recCount := -1, sectCount := 0, c := 0, p := 0, s := 0, k := 0, spr := "", reWriteIni := 0, FileExistSelIniChoicePath:= FileExist(SelIniChoicePath)
; Local implies  or assumes global function

IniProcStart:


if (!FileExistSelIniChoicePath)
	{
	IniWrite, % (reWriteini)? 1: 0, %SelIniChoicePath%, General, Disclaimer
	IniWrite, %A_Space%, %SelIniChoicePath%, General, DefResmsg
	IniWrite, %A_Space%, %SelIniChoicePath%, General, PrgAlreadyMsg
	IniWrite, %A_Space%, %SelIniChoicePath%, General, ClosePrgWarn
	IniWrite, %A_Space%, %SelIniChoicePath%, General, ResClashMsg
	IniWrite, %A_Space%, %SelIniChoicePath%, General, WinRtDirWrn
	IniWrite, %A_Space%, %SelIniChoicePath%, General, LnchPrgMonWarn
	IniWrite, %A_Space%, %SelIniChoicePath%, General, LoseGuiChangeResWrn
	IniWrite, %A_Space%, %SelIniChoicePath%, General, PrgAlreadyLaunchedMsg
	IniWrite, %A_Space%, %SelIniChoicePath%, General, ChangeShortcutMsg
	IniWrite, %A_Space%, %SelIniChoicePath%, General, PrgLaunchAfterDL

	; %SelIniChoicePath% as long as the current directory isn't changed while this loads

	spr := "0,0,0,1"
	IniWrite, %spr%, %SelIniChoicePath%, General, ResMode
	IniWrite, %A_Space%, %SelIniChoicePath%, General, UseReg
	IniWrite, %A_Space%, %SelIniChoicePath%, General, NavShortcut
 	IniWrite, %A_Space%, %SelIniChoicePath%, General, WarnAlreadyRunning
	IniWrite, %A_Space%, %SelIniChoicePath%, General, OnlyOneMonitor
	IniWrite, %A_Space%, %SelIniChoicePath%, General, DefPresetSettings
	IniWrite, %A_Space%, %SelIniChoicePath%, General, PrgVersionError

	IniWrite, %SelIniChoiceName%, %PrgLnchIni%, General, SelIniChoiceName
	
	spr := ""
	strIniChoice := "" ; Global variable
		if (reWriteini)
		{
			loop % PrgNo
			{
			if (IniChoiceNames[A_Index] = "Ini" . A_Index)
			{
			spr .= ","
			strIniChoice .= "Ini" . A_Index . "|"
			}
			else
			{
			spr .= IniChoiceNames[A_Index] . ","
			strIniChoice .= IniChoiceNames[A_Index] . "|"
			}
			}
		}
		else
		{
			loop % PrgNo
			{
			spr .= ","
			strIniChoice .= "Ini" . A_Index . "|"
			}
		}

	spr := Substr(spr, 1, InStr(spr, ",",, 0) -1)
	IniWrite, %spr%, %PrgLnchIni%, General, IniChoiceNames


	IniWrite, % (defPrgStrng)? defPrgStrng: None, %SelIniChoicePath%, Prgs, StartupPrgName


	IniWrite, %A_Space%, %SelIniChoicePath%, Prgs, PrgMon

	IniWrite, % (PrgBatchIniStartup)? PrgBatchIniStartup: A_Space, %SelIniChoicePath%, Prgs, PrgBatchIniStartup
	IniWrite, % (PrgTermExit)? PrgTermExit: A_Space, %SelIniChoicePath%, Prgs, PrgTermExit
	IniWrite, % (PrgIntervalLnch)? PrgIntervalLnch: A_Space, %SelIniChoicePath%, Prgs, PrgInterval

	spr := join(PresetNames)
	spr := (spr)? spr: %A_Space%
	
	IniWrite, %spr%, %SelIniChoicePath%, Prgs, PresetNames

		Loop % maxBatchPrgs
		{
			spr := join(PrgBatchIni%A_Index%)
			spr := (spr)? spr: %A_Space%
			IniWrite, %spr%, %SelIniChoicePath%, Prgs, PrgBatchIni%A_Index%
		}

		loop % PrgNo
		{
		;PrgChoiceNames.push([0])

		if (!reWriteini)
		strPrgChoice .= "Prg" . A_Index . "|"

		IniWrite, % (PrgChoiceNames[A_Index])? PrgChoiceNames[A_Index]: A_Space, %SelIniChoicePath%, Prg%A_Index%, PrgName
		;for  each PrgChoicePaths[%A_Index%]
		if (reWriteini)
		{
		spr := PrgChoicePaths[A_Index]
		if (spr)
		{
			if (InStr(spr, ".lnk", False, StrLen(spr) - 4))
				{
				;Append resolved path
				strRetVal := GetPrgLnkVal(spr, IniFileShortctSep)
				if (!InStr(strRetVal, "*") || InStr(strRetVal, "|"))
				PrgChoicePaths[A_Index] .= IniFileShortctSep . strRetVal
				}
		}
		}
		IniWrite, % (PrgChoicePaths[A_Index])? PrgChoicePaths[A_Index]: A_Space, %SelIniChoicePath%, Prg%A_Index%, PrgPath

		IniWrite, % (PrgCmdLine[A_Index])? PrgCmdLine[A_Index]: A_Space, %SelIniChoicePath%, Prg%A_Index%, PrgCmdLine
		IniWrite, %A_Space%, %SelIniChoicePath%, Prg%A_Index%, PrgRes
		IniWrite, % (PrgUrl[A_Index])? PrgUrl[A_Index]: A_Space, %SelIniChoicePath%, Prg%A_Index%, PrgUrl
		IniWrite, % (PrgVer[A_Index])? PrgVer[A_Index]: A_Space, %SelIniChoicePath%, Prg%A_Index%, PrgVer
		if (reWriteini)
		{
		; This is the ver 1.X order
		PrgLnchHide[A_Index]:= PrgMonToRn[A_Index]
		PrgMonToRn[A_Index] := (PrgChgResonSwitch[A_Index])? PrgChgResonSwitch[A_Index]: 1
		PrgChgResonSwitch[A_Index] := PrgBordless[A_Index]
		PrgBordless[A_Index] := PrgRnMinMax[A_Index]
		PrgRnMinMax[A_Index] := -1

		spr := PrgMonToRn[A_Index] . "," . PrgChgResonSwitch[A_Index] . ",-1," . PrgRnPriority[A_Index] . "," . PrgBordless[A_Index] . "," . PrgLnchHide[A_Index] . ",0"

		IniWrite, % spr, %SelIniChoicePath%, Prg%A_Index%, PrgMisc

		spr := % scrWidthArr[A_Index] . "," . scrHeightArr[A_Index] . "," . scrFreqArr[A_Index] . "," 0

		IniWrite, %spr%, %SelIniChoicePath%, Prg%A_Index%, PrgRes


		IniProcIniFile(0, SelIniChoicePath, SelIniChoiceName, IniChoiceNames, PrgNo, strIniChoice)
		}
		else
		IniWrite, %A_Space%, %SelIniChoicePath%, Prg%A_Index%, PrgMisc

		}
	reWriteIni := 0
	}
	else
	{

	FileRead, s, %SelIniChoicePath%

	Loop, Parse, s, `n`r, %A_Space%%A_Tab%
	{

	c := SubStr(A_LoopField, 1, 1)
	if (c="[")
		{
			sectCount := 0
			k := SubStr(A_LoopField, 1)
			spr := SubStr(k, 2, 3)
				if (spr = "Prg")
				recCount := recCount + 1
				else	;Process  General section
				Continue ;Just in case any new sub nodes
		}
		else 
		{
			if (c=";" || c="*/") ;comments
			Continue
			if (c="/*")
			{
				MsgBox, 8192, , % "Can't handle " c " if not eof!"
				Return -1
			}


			p := InStr(A_LoopField, "=")

			if (p)
			{
			k := SubStr(A_LoopField, p + 1)
			sectCount := sectCount + 1
				if (recCount < 0) ;General section
				{
					if (sectCount < 12)
					{
					Continue ;don't care about the "Don't show me first" || (sectCount = 3)
					}
					else
					{

						if (sectCount = 12)
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
										spr := "0,0,0," . spr
									}
								}
							IniWrite, %spr%, %SelIniChoicePath%, General, ResMode
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
						if (sectCount = 13)
						{
							if (selPrgChoice)
							IniWrite, %RegoVar%, %SelIniChoicePath%, General, UseReg
							else
							{
							;spr := SubStr(A_LoopField, 2, -1)
							;if (spr = "UseReg")
							;{
								if (k)
								RegoVar := k
							;}
							;else
							}
						}
						else
						{
						if (sectCount = 14)
						{
							if (selPrgChoice)
							IniWrite, %navShortcut%, %SelIniChoicePath%, General, NavShortcut
							else
							{
								if (k)
								navShortcut := k
							}
						}
						; section 15+ : WarnAlreadyRunning: don't show me this again
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
							IniRead, defPrgStrng , %SelIniChoicePath%, Prgs, StartupPrgName, %A_Space% ;Space just in case None is absent
						}

					}
					else
					{
						if (sectCount = 2)
						{
							if (selPrgChoice)
							{
								if (selPrgChoice = 100) ;write record at init
								{
								spr := ""
									loop % dispMonNamesNo - 1
									{
									spr .= iDevNumArray[A_Index] . ","
									}
								spr .= iDevNumArray[dispMonNamesNo]

								IniWrite, %spr%, %SelIniChoicePath%, Prgs, PrgMon
								}

							}
							else  ;reading entire file
							{
								if (k)
								{
								foundPos := 0
									loop % dispMonNamesNo
									{
									foundPosOld := foundPos + 1
									foundPos := InStr(k, ",", , , A_Index)
										if (!foundPos)
										Break
									iDevNumArray[A_Index] := SubStr(k, foundPosOld, foundPos - foundPosOld)
									}
									if (!iDevNumArray[1]) ;  cannot handle old ini files
									{
										if (k < 111) ; 111 is case when driver is uninstalled and only one monitor!
										{
										sectCount -= 1
										reWriteIni := 1
										Continue
										}
										else
										{
										IniRead, foundpos, %SelIniChoicePath%, General, OnlyOneMonitor
											if (!foundpos)
											{
											MsgBox, 8196, , % "One Monitor, No more than one logical monitor!`nMost likely cause is driver removal.`nInformational only- if driver has just been updated.`n`n`nYes: Continue (Warn like this next time) `nNo: Continue (This will not show again) `n"
												IfMsgBox, No
												IniWrite, 1, %SelIniChoicePath%, General, OnlyOneMonitor
											}
										}
									}
								}
								else
								{
								sectCount -= 1
								reWriteIni := 1
								Continue
								}
							}
						}
						else ;Only reading the following sections- writing at control labels
						{
						if (sectCount = 3)
						{
							if (!inputOnceOnly)
							{
								if (k)
								PrgBatchIniStartup := k
							}
						}
						else
						{
						if (sectCount = 4)
						{
							if (!inputOnceOnly)
							{
								if (k)
								PrgTermExit := k
							}
						}
						else
						{
						if (sectCount = 5)
						{
							if (!inputOnceOnly)
							{
								if (k)
								PrgIntervalLnch := k
							}
						}
						else
						{
						if (sectCount = 6)
						{
							if (!inputOnceOnly)
							{
							temp := sectCount - 6
								Loop, parse, k, CSV , %A_Space%%A_Tab%
								{
								PresetNames[A_Index] := A_Loopfield
								}
							}
						}
						else
						{
						if (!inputOnceOnly)
						{
						if (sectCount > 6)
						{
							if (k)
							{
							temp := sectCount - 6
								Loop, parse, k, CSV, %A_Space%%A_Tab%
								{
								PrgBatchIni%temp%[A_Index] := A_Loopfield
								}
							}
							if (sectCount = 6 + maxBatchPrgs)
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
								IniWrite, %A_Space%, %SelIniChoicePath%, %spr%, PrgName
								}
								else
								{
								spr .= PrgChoiceNames[recCount]
								IniWrite, %spr%, %SelIniChoicePath%, Prg%recCount%, PrgName
								}
							foundPos := InStr(strPrgChoice, "|", false, 1, recCount + 1)
							spr := SubStr(strPrgChoice, 1, foundPos) . spr ;Bar is  to replace, not append  the  gui control string
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
									IniWrite, %A_Space%, %SelIniChoicePath%, Prg%recCount%, PrgPath
									else
									{
									spr := PrgChoicePaths[recCount]
									IniWrite, %spr%, %SelIniChoicePath%, Prg%recCount%, PrgPath
									}
								}
							}
							else  ;reading entire file
							{
								if (k)
								PrgChoicePaths[recCount] := k
								else
								{
									if (PrgChoiceNames[recCount])
									MsgBox, 8192, Path to Prg, % "Error: " PrgChoiceNames[recCount] " has no paths!"
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
									if (removeRec)
									IniWrite, %A_Space%, %SelIniChoicePath%, Prg%recCount%, PrgCmdLine
									else
									{
										if (PrgCmdLine[selPrgChoice])
										IniWrite, % PrgCmdLine[selPrgChoice], %SelIniChoicePath%, Prg%recCount%, PrgCmdLine
										else
										IniWrite, %A_Space%, %SelIniChoicePath%, Prg%recCount%, PrgCmdLine
									}
								}
							}
							else
							{
								if (k)
								PrgCmdLine[reccount] := k
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

									IniWrite, %A_Space%, %SelIniChoicePath%, Prg%recCount%, PrgRes
									}
									else
									{
										if (PrgChoiceNames[recCount])
										{
										spr := % scrWidth . "," . scrHeight . "," . scrFreq . "," 0
										;extra 0 for interlace which might implement later
										IniWrite, %spr%, %SelIniChoicePath%, Prg%recCount%, PrgRes
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
								{ ; could have parsed (sigh)
									foundPos := InStr(k, ",", 1)
									scrWidth := SubStr(k, 1, foundPos - 1)
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
						else
						{
						if (sectCount = 5)
						{
							if (selPrgChoice)
							{
								if (selPrgChoice = recCount) ;write record at selPrgChoice
								{
									if (removeRec)
									IniWrite, %A_Space%, %SelIniChoicePath%, Prg%recCount%, PrgUrl
									else
									{
										if (PrgChoiceNames[recCount])
										IniWrite, % PrgUrl[recCount], %SelIniChoicePath%, Prg%recCount%, PrgUrl
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
									IniWrite, %A_Space%, %SelIniChoicePath%, Prg%recCount%, PrgVer
									else
									{
									if (PrgChoiceNames[recCount])
									IniWrite, % PrgVer[recCount], %SelIniChoicePath%, Prg%recCount%, PrgVer
									}
								}
							}
							else  ;reading entire file
							{
								if (k)
								PrgVer[recCount] := k
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
									IniWrite, %A_Space%, %SelIniChoicePath%, Prg%recCount%, PrgMisc
									else
									{
										if (PrgChoiceNames[recCount])
										{
										spr := PrgMonToRn[selPrgChoice]
										spr .= "," . PrgChgResonSwitch[selPrgChoice]
										spr .= "," . PrgRnMinMax[selPrgChoice]
										spr .= "," . PrgRnPriority[selPrgChoice]
										spr .= "," . PrgBordless[selPrgChoice]
										spr .= "," . PrgLnchHide[selPrgChoice]
										spr .= "," . PrgResolveShortcut[selPrgChoice]
										IniWrite, %spr%, %SelIniChoicePath%, Prg%recCount%, PrgMisc
										}
									}
								}
							}
							else  ;reading entire file
							{
							if (k)
							{
								Loop, Parse, k, CSV, %A_Space%%A_Tab%
								{
									if (1 = A_Index)
									PrgMonToRn[recCount] := A_LoopField
									else
									{
									if (2 = A_Index)
									PrgChgResonSwitch[recCount] := A_LoopField
									else
									{
									if (3 = A_Index)
									PrgRnMinMax[recCount] := A_LoopField
									else
									{
									if (4 = A_Index)
									PrgRnPriority[recCount] := A_LoopField
									else
									{
									if (5 = A_Index)
									PrgBordless[recCount] := A_LoopField
									else
									{
									if (6 = A_Index)
									PrgLnchHide[recCount] := A_LoopField
									else
									{
									if (7 = A_Index)
									PrgResolveShortcut[recCount] := A_LoopField
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
			}
			else
			{
				if (A_LoopField) ; No equals character!
				{
				reWriteIni := DeleteIniFile(SelIniChoicePath, 2)
					if (reWriteIni)
					{
							if (reWriteIni = 1)
							reWriteIni := 0
						FileExistSelIniChoicePath := ""
						strPrgChoice := "|None|"
						defPrgStrng := "None"
						PrgBatchIniStartup := ""
						goto IniProcStart
					}
					else
					{
					KleenupPrgLnchFiles()
					ExitApp
					}
				}
			}

		}
	}
		if (reWriteIni)
		{
		if (DeleteIniFile(SelIniChoicePath, 2))
		{
		FileExistSelIniChoicePath := ""
		goto IniProcStart
		}
		else
		{
		KleenupPrgLnchFiles()
		ExitApp
		}
		}


	}
}
DeleteIniFile(SelIniChoicePath, wrnPrompt := 0)
{
spr := 0
reWriteIni := 1
if (wrnPrompt = 1)
{
MsgBox, 8195, , Ini file appears to be corrupted.`nThe recommended course of action is to reset it.`n`nYes: Attempt reset to currently stored values. (Recommended) `nNo: Clear settings to their initial state. `nCancel: Continue with errors: `n
	IfMsgBox, Yes
	reWriteIni := 2
	else
	{
		IfMsgBox, No
		reWriteIni := 1
		else
		return reWriteIni
	}
}
else 
{
if (wrnPrompt = 2)
{
MsgBox, 8192, , Ini file will be converted to version 2.x.`nMost settings will be preserved.
}
}

	Try
	{
	FileDelete %SelIniChoicePath%
	sleep, 100
	}
	catch spr
	{
	reWriteIni := 0
	MsgBox, 8208, Ini File Delete, Critical error deleting file! `nSpecifically: %spr%
	}
	Return reWriteIni
}
IniSpaceCleaner(IniFile, oldVerChg := 0)
{
; https://autohotkey.com/boards/viewtopic.php?f=13&t=26556&p=124630#p124630
retVal := "", temp := ""
Thread, NoTimers
try
{
	FileRead, strRetVal, %IniFile%
	if (oldVerChg)
	{
		if (InStr(strRetVal, "LoseGuiChangeResWrn"))
		Return
		else
		strRetVal := StrReplace(strRetVal, "ResMode=", "LoseGuiChangeResWrn= `nPrgAlreadyLaunchedMsg= `nChangeShortcutMsg= `nResMode= ")
	}
	else
	strRetVal := RegExReplace(strRetVal, "m) +$", " ") ;m multilineselect; " +" one or more spaces; $ only at EOL
	; Names & pathnames with more than one space are tested a not affected.

	DeleteIniFile(IniFile)
	FileAppend, %strRetVal%, %IniFile%
	sleep, 100
}
catch temp
{
if (temp)
MsgBox, 8208, IniSpaceCleaner, Error with Ini file! `nSpecifically: %temp%
}
Thread, NoTimers, false
}























;Properties routines
PopPrgProperties(ByRef PrgPropertiesHwnd, currBatchNo, btchPrgPresetSel, PrgBatchInibtchPrgPresetSel, PrgChoiceNames, PrgChoicePaths, PrgLnkInf, IniFileShortctSep, x, y, w, h)
{
IsaPrgLnk := 0, strTemp := 0, fTemp := 0, temp := 0, foundpos := 0, batchPos := 0, pathCol := 0, pathColH := 0, pathColHOld := 0, defCol := 0, defColW := 0, defColH := 0, propX := 0, propY := 0, propW := 0, propH := 0, truncFileName := "", errorText := "", strRetVal := "", fileName := ""
static tabName := 0



strRetVal := WorkingDirectory(A_ScriptDir, 1)
	if (strRetVal)
	MsgBox, 8192, PrgProperties, % strRetVal
	else
	{
		If (!FileExist("PrgLnchProperties.jpg"))
		FileInstall PrgLnchProperties.jpg, PrgLnchProperties.jpg

	sleep, 200
	SplashImage, PrgLnchProperties.jpg, A B,,,LnchSplash
	WinGetPos,, propY, propW, propH, LnchSplash

		if (y > propY)
		WinMove, LnchSplash, , % x + (w - propW)/2, % y - propY
		else
		WinMove, LnchSplash, , % x + (w - propW)/2, % propY - Y

	}




Gui, PrgProperties: Destroy

sleep, 120

Gui, PrgProperties: New,, Prg_Properties
Gui, PrgProperties: -MaximizeBox -MinimizeBox +OwnDialogs +HwndPrgPropertiesHwnd
Gui, PrgProperties: Color, FFFFCC


CLEARTYPE_QUALITY := 5

loop % currBatchNo
{
	batchPos := PrgBatchInibtchPrgPresetSel[A_Index]
	fileName := ExtractPrgPath(batchPos, PrgChoicePaths, 0, PrgLnkInf, IsaPrgLnk, IniFileShortctSep)
	strTemp := PrgChoiceNames[batchPos]

	IfExist, % fileName
	{
		if (StrLen(strTemp) > 12)
		{
		strTemp := SubStr(strTemp, 1, 12) . "..."
		}
	strRetVal .= "|" . strTemp
	}
	else
	strRetVal .= "|" . "No File!"
}

strRetVal := SubStr(strRetVal, 2)
;remove first pipe
Gui, PrgProperties: Add, Tab3, w%w% vtabName -Theme -wrap AltSubmit, % strRetVal


loop % currBatchNo
{
Gui, PrgProperties: Tab, %A_Index%


batchPos := PrgBatchInibtchPrgPresetSel[A_Index]
fileName := ExtractPrgPath(batchPos, PrgChoicePaths, 0, PrgLnkInf, IsaPrgLnk, IniFileShortctSep)

IfExist, % fileName
{

	errorText := ""

		Gui, PrgProperties: Add, Text, HWNDsprHwnd, Path

		if (!defColW)
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
		temp := substr(temp, StrLen(temp)/2, StrLen(temp))
		GuiControl, PrgProperties:, %pathHwnd%, % temp
		GuiControl, PrgProperties: Move, %pathHwnd%, % "h" pathColH/2
		GuiControlGet, pathCol, PrgProperties: Pos, % pathHwnd
		}
		pathColH := 5*pathColH/4
		GuiControl, PrgProperties: Move, %pathHwnd%, % "h" pathColH
		GuiControl, PrgProperties: , %pathHwnd%, % substr(temp, 1, 3) . "..." . temp
		}



	temp := 2*defColW, fTemp := 16*defColH
	pathColHOld := pathColHOld - pathColH
	Gui, PrgProperties: Add, GroupBox, Section y+-%pathColHOld% w%temp% h%fTemp%


		FileRead temp, % fileName
		if (temp)
		{
			sleep, 120
			temp := CRC32(temp,foundpos)

			if (temp)
				{
				Gui, PrgProperties: Add, Text, xs ys+%defColH% HWNDsprHwnd, CRC
				PrgPropFont(sprHwnd)

				fTemp := 3*defColH
				Gui, PrgProperties: Add, Text, xs ys+%fTemp%, % temp
				}
			else
				errorText .= "Problem with CRC.`n"
		}
		else
		errorText .= "Problem with file read for CRC.`n"

	FileGetTime, strTemp, % fileName, C
		if (ErrorLevel)
		errorText .= "Problem with file creation time.`n"
		else
		{
			fTemp := 5*defColH
			Gui, PrgProperties: Add, Text, xs ys+%fTemp% HWNDsprHwnd, Creation Date
			PrgPropFont(sprHwnd)

			FormatTime, strTemp, % strTemp, ShortDate
			fTemp := 7*defColH
			Gui, PrgProperties: Add, Text, xs ys+%fTemp%, % strTemp
		}


	FileGetTime, strTemp, % fileName
		if (ErrorLevel)
		errorText .= "Problem with file modification time.`n"
		else
		{
			fTemp := 9*defColH
			Gui, PrgProperties: Add, Text, xs ys+%fTemp% HWNDsprHwnd, Modification Date
			PrgPropFont(sprHwnd)

			FormatTime, strTemp, % strTemp, ShortDate
			fTemp := 11*defColH
			Gui, PrgProperties: Add, Text, xs ys+%fTemp%, % strTemp
		}

	if (!IsaPrgLnk)
	{
		FileGetVersion, foundpos, % fileName
			if (ErrorLevel)
			fileName := AssocQueryApp(fileName)

		; Try again if association
		FileGetVersion, foundpos, % fileName
			if (ErrorLevel)
			errorText .= "Problem with file version.`n"
			else
			{
			fTemp := 13*defColH
			Gui, PrgProperties: Add, Text, xs ys+%fTemp% HWNDsprHwnd, File Version Number
			PrgPropFont(sprHwnd)

			fTemp := 15*defColH
			Gui, PrgProperties: Add, Text, xs ys+%fTemp%, % foundpos
			}


		strRetVal := FileGetInfo(Filename).ProductName
		if (strRetVal = "GetFileVersionInfoSizeFail")
		errorText .= "Unable to retrieve extended information from the file.`n"
		else
		{

		temp := PrgLnchOpt.Width()/2
		Gui, PrgProperties: Add, Text, xs+%temp% ys+%defColH% HWNDsprHwnd, Product Name
		PrgPropFont(sprHwnd)

		fTemp := 3*defColH
		Gui, PrgProperties: Add, Text, xs+%temp% ys+%fTemp%, % strRetVal

		strRetVal := FileGetInfo(Filename).CompanyName
		fTemp := 5*defColH
		Gui, PrgProperties: Add, Text, xs+%temp% ys+%fTemp% HWNDsprHwnd, Company Name
		PrgPropFont(sprHwnd)

		fTemp := 7*defColH
		Gui, PrgProperties: Add, Text, xs+%temp% ys+%fTemp%, % strRetVal

		strRetVal := FileGetInfo(Filename).ProductVersion
		fTemp := 9*defColH
		Gui, PrgProperties: Add, Text, xs+%temp% ys+%fTemp% HWNDsprHwnd, Product Version
		PrgPropFont(sprHwnd)

		fTemp := 11*defColH
		Gui, PrgProperties: Add, Text, xs+%temp% ys+%fTemp%, % strRetVal

		strRetVal := FileGetInfo(Filename).LegalCopyright
		fTemp := 13*defColH
		Gui, PrgProperties: Add, Text, xs+%temp% ys+%fTemp% HWNDsprHwnd, Legal Copyright
		PrgPropFont(sprHwnd)

		fTemp := 15*defColH
		Gui, PrgProperties: Add, Text, xs+%temp% ys+%fTemp%, % strRetVal
		}
	}

	;CRC

	if (errorText)
	{
		temp := strRetVal? (2*defColW): 0
		Gui, PrgProperties: Add, Text, xs+-%temp% Section, Errors
		Gui, PrgProperties: Add, Text,, % errorText
	}
}
}

Gui, PrgProperties: Font, CLEARTYPE_QUALITY
Gui, PrgProperties: Show, Hide, PrgProperties


SysGet, temp, MonitorWorkArea, PrgLnch.Monitor
WinGetPos,, propY,, propH, % "ahk_id" PrgPropertiesHwnd
	if (tempBottom - y > tempBottom - propH)
	WinMove, % "ahk_id" PrgPropertiesHwnd, , x, % propH - y, w
	else
	WinMove, % "ahk_id" PrgPropertiesHwnd, , x, % y - propH, w



;For low screen res 
if (propH + h > (tempBottom - tempTop))
	WinMove, % "ahk_id" PrgPropertiesHwnd, , , tempBottom, , % tempBottom - tempTop


SplashImage, PrgLnchProperties.jpg, Hide,,,LnchSplash
Gui, PrgProperties: Show, , Prg Properties (Version 2.x)

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
	List := "Comments InternalName ProductName CompanyName LegalCopyright ProductVersion"
		. " FileDescription LegalTrademarks PrivateBuild FileVersion OriginalFilename SpecialBuild"
	dwLen := DllCall("Version.dll\GetFileVersionInfoSize", "Str", lptstrFilename, "Ptr", 0)
	dwLen := VarSetCapacity(lpData, dwLen + A_PtrSize)
	DllCall("Version.dll\GetFileVersionInfo", "Str", lptstrFilename, "UInt", 0, "UInt", dwLen, "Ptr", &lpData) 
	DllCall("Version.dll\VerQueryValue", "Ptr", &lpData, "Str", "\VarFileInfo\Translation", "PtrP", lplpBuffer, "PtrP", puLen )
	sLangCP := Format("{:04X}{:04X}", NumGet(lplpBuffer+0, "UShort"), NumGet(lplpBuffer+2, "UShort"))
	i := {}
	Loop, Parse, % List, %A_Space%
	DllCall("Version.dll\VerQueryValue", "Ptr", &lpData, "Str", "\StringFileInfo\" sLangCp "\" A_LoopField, "PtrP", lplpBuffer, "PtrP", puLen )
		? i[A_LoopField] := StrGet(lplpBuffer, puLen) : ""
	VarSetCapacity(lpData, 0)
	return i
}
;Laszlo's function CRC32 has three parameters.
;- The first one is the name of a buffer, which can contain binary data.
;- The second parameter is the length of the data in bytes. If omitted or not positive, Strlen(Buffer) is used internally.
;- The 3rd parameter is used for continuing the CRC computation for second or later data sections. If omitted, -1 is used, the standard initial value for CRC32. If an earlier CRC operation is to be continued (which returned C), put here ~C. If a different CRC is needed than the standard CRC-32 (e.g. to resolve collisions), you can use any 32 bit integer for initialization.

CRC32(ByRef Buffer, Bytes=0, Start=-1) {
   Static CRC32, CRC32_Init, CRC32LookupTable
   retVal := 0
   If (CRC32 = "")
	{
		MCode(CRC32_Init,"33c06a088bc85af6c101740ad1e981f12083b8edeb02d1e94a75ec8b542404890c82403d0001000072d8c3")
		MCode(CRC32,"558bec33c039450c7627568b4d080fb60c08334d108b55108b751481e1ff000000c1ea0833148e403b450c89551072db5e8b4510f7d05dc3")
		VarSetCapacity(CRC32LookupTable, 256*4)
		DllCall(&CRC32_Init, "uint",&CRC32LookupTable, "cdecl")
	}
	If (Bytes <= 0)
	Bytes := StrLen(Buffer)

	retVal := DllCall(&CRC32, "uint",&Buffer, "uint",Bytes, "int",Start, "uint",&CRC32LookupTable, "cdecl uint")
	VarSetCapacity(CRC32_Init, 0)
	VarSetCapacity(CRC32, 0)
	VarSetCapacity(CRC32LookupTable, 0)
	Return retVal 
}

MCode(ByRef code, hex)
{
	; allocate memory and write Machine Code there
	VarSetCapacity(code,StrLen(hex)//2)
	Loop % StrLen(hex)//2
	NumPut("0x" . SubStr(hex,2*A_Index-1,2), code, A_Index-1, "Char")
}
RestartPrgLnch(AsAdmin := 0, chgPreset := "", SprIniSlot := "")
{
Global
Thread, NoTimers
Local temp := 0, strTemp := PrgPID . ",", strTemp2 := ""

if (chgPreset)
{

; Get Pidmaster values and current Preset name & separate "|" with target Preset
	loop % PrgNo
	{
	strTemp .= PrgPIDMast[A_Index] . "`,"
	}

strTemp := SubStr(strTemp, 1, strLen(strTemp) - 1)
chgPreset := oldSelIniChoiceName . "|" . chgPreset

	if (SprIniSlot)
	strTemp := % ((A_IsCompiled)? """": """ """) . strTemp . """ """ . chgPreset . """ """ . SprIniSlot . """"
	else
	strTemp := % ((A_IsCompiled)? """": """ """) . strTemp . """ """ . chgPreset . """"

}
else
{

	loop % maxBatchPrgs
	{
	temp := A_Index
		loop % maxBatchPrgs
		{
		strTemp .= PrgListPID%temp%[A_Index] . "`,"
		}
	strTemp := SubStr(strTemp, 1, strLen(strTemp) - 1)
	strTemp .= "|"
	}

chgPreset := SelIniChoiceName . "|" . SelIniChoiceName
strTemp := % ((A_IsCompiled)? """": """ """) . strTemp . """ """ . chgPreset . """"
}

strTemp2 := (AsAdmin)? "*RunAs ": ""
full_command_line := DllCall("GetCommandLine", "str") ; no Parms: "str" is Cdecl ReturnType

	; Is this condition absolutely necessary here?
	if (!RegExMatch(full_command_line, " /restart(?!\S)") || chgPreset)
	{

		try
		{
		if (A_IsCompiled)
		strTemp2 .= """" . A_ScriptFullPath . """" . " /restart " . strTemp
		else
		strTemp2 .= """" . A_AhkPath . """" . " /restart " . """" . A_ScriptFullPath . strTemp
		; restart may not work if LOAD phase of script is not completed- test it!!!

		Run, %strTemp2%, %A_ScriptDir%
		}
		catch fTemp
		{
		MsgBox, 8192, ReLaunch, % "PrgLnch could not restart with error " fTemp "."
		KleenupPrgLnchFiles()
		}
	SetTimer, NewThreadforDownload, Delete ;Cleanup
	Thread, NoTimers, false
	ExitApp
	}
	strTemp2 := % "PrgLnch could not relaunch, as it has already restarted with this command line:`n" full_command_line
	Thread, NoTimers, false
	if (AsAdmin)
	Return %strTemp2%
	else
	{
	MsgBox, 8192, ReLaunch, % strTemp2
	Return 1
	}
}
