#SingleInstance, force
#NoEnv  ; Performance and compatibility with future AHK releases.
;#Warn, All, OutputDebug ; Enable warnings for a debugger to display to assist with detecting common errors.
;#Warn UseUnsetLocal, OutputDebug  ; Warn when a local variable is used before it's set; send to OutputDebug
#MaxMem 256
#MaxThreads 5
#Persistent
#Include %A_ScriptDir%


AutoTrim, Off ; traditional assignments off
ListLines Off ;A_ListLines default is on: history of lines most recently executed 
SendMode Input  ; Recommended for new scripts due to superior speed & reliability.
FileSetAttrib, -RH, % A_ScriptDir . "`\*.*", 1
SetWinDelay, 100 ; Default
; ListVars for debugging
SetBatchLines, 20ms ; too fast? A_BatchLines is 10ms
SetTitleMatchMode, 2 ;window's title can contain WinTitle anywhere inside it to be a match


OnMessage(0x112, "WM_SYSCOMMAND")
OnMessage(0x0053, "WM_Help")
OnMessage(0x201, "WM_LBUTTONDOWN")







if (!(InStr(PrgLnch.Title . ".ahk", A_ScriptName) || InStr(PrgLnch.Title . ".exe", A_ScriptName)))
{
MsgBox, 8208, Launching PrgLnch, % "PrgLnch cannot be run from a copy like " """" A_ScriptName """" "!"
ExitApp
}


PrgLnchPID := DllCall("GetCurrentProcessId")
Process, priority, %PrgLnchPID%, A
;Issues:

; Virtual screen: https://msdn.microsoft.com/en-us/library/vs/alm/dd145136(v=vs.85).aspx

Class Splashy
{

	spr := 0
	spr1 := 0
	spr2 := 0

	; HTML Colours (RGB- no particular order)
	STATIC HTML := {CYAN: "0X00FFFF", AQUAMARINE : "0X7FFFD4", BLACK: "0X000000", BLUE: "0X0000FF", FUCHSIA: "0XFF00FF", GRAY: "0X808080", AUBURN: "0X2A2AA5"
	 , LIME: "0X00FF00", MAROON: "0X800000", NAVY: "0X000080", OLIVE: "0X808000", PURPLE: "0X800080", INDIGO: "0X4B0082", LAVENDER: "0XE6E6FA", DKSALMON: "0X7A96E9"
	 , SILVER: "0XC0C0C0", TEAL: "0X008080", WHITE: "0XFFFFFF", YELLOW: "0XFFFF00", WHEAT: "0xF5DEB3", ORANGE: "0XFFA500", BEIGE: "0XF5F5DC", CELADON: "0XACE1AF"
	 , CHESTNUT: "0X954535", TAN: "0xD2B48C", CHOCOLATE: "0X7B3F00", TAUPE: "0X483C32", SALMON: "0XFA8072", VIOLET: "0X7F00FF", GRAPE: "0X6F2DA8", STEINGRAU: "0X485555"
	 , PEACH: "0XFFE5B4", CORAL: "0XFF7F50", CRIMSON: "0XDC143C", VERMILION: "0XE34234", CERULEAN: "0X007BA7", TURQUOISE: "0X40E0D0", VIRIDIAN: "0X40826D", RED: "0XFF0000"
	 , PLUM: "0X8E4585", MAGENTA: "0XF653A6", GOLD: "0XFFD700", GOLDENROD: "0XDAA520", GREEN: "0X008000", ONYX: "0X353839", KHAKIGRAU: "0X746643", FELDGRAU: "0X3D5D5D"}

	Static MaxGuis := 1000	; arbitrary limit
	Static parentHWnd := 0
	Static updateFlag := -1
	Static procEnd := 0
	Static pToken := 0
	Static hGDIPLUS := 0

	Static parentClip := 0
	Static downloadedPathNames := []
	Static downloadedUrlNames := []
	Static NewWndObj := {}
	Static vImgType := 0
	Static hWndSaved := []
	Static parent := 0
	Static release := 0
	Static hDCWin := 0
	Static instance := 1
	Static oldInstance := 1
	Static hBitmap := 0
	Static hIcon := 0
	Static vImgTxtSize := 0
	Static vPosX := "c"
	Static vPosY := "c"
	Static vMgnX := 0
	Static vMgnY := 0
	Static vImgX := 0
	Static vImgY := 0
	Static inputVImgW := ""
	Static inputVImgH := ""
	Static vImgW := 0
	Static vImgH := 0
	Static oldVImgW := 0
	Static oldVImgH := 0
	Static actualVImgW := 0
	Static actualVImgH := 0
	Static oldPicInScript := 0
	Static picInScript := 0

	Static ImageName := ""
	Static oldImagePath := ""
	Static imageUrl := ""
	Static oldImageUrl := ""
	Static bkgdColour := ""
	Static transCol := 0
	Static vHide := 0
	Static noHWndActivate := ""
	Static vBorder := 0
	Static voldBorder := 0
	Static vOnTop := 0


	Static mainTextHWnd := []
	Static mainText := ""
	Static mainBkgdColour := ""
	Static mainFontName := ""
	Static mainFontSize := 0
	Static mainFontWeight := 0
	Static mainFontColour := ""
	Static mainFontQuality := 0
	Static mainFontItalic := ""
	Static mainFontStrike := ""
	Static mainFontUnderline := ""
	Static mainMarquee := 0

	Static subTextHWnd := []
	Static subText := ""
	Static subBkgdColour := ""
	Static subFontName := ""
	Static subFontSize := 0
	Static subFontWeight := 0
	Static subFontColour := ""
	Static subFontQuality := 0
	Static subFontItalic := ""
	Static subFontStrike := ""
	Static subFontUnderline := ""
	Static subMarquee := 0

	Class NewWndProc
	{
	Static clbk := []
	Static wndProcOld := 0
	Static WM_PAINT := 0x000F
	Static WM_NCHITTEST := 0x84
	Static WM_ERASEBKGND := 0x0014
	Static WM_CTLCOLORSTATIC := 0x0138
	Static WM_ENTERSIZEMOVE := 0x0231
	Static WM_EXITSIZEMOVE := 0x0232

		__New(instance)
		{
		Static SetWindowLong := A_PtrSize == 8 ? "SetWindowLongPtr" : "SetWindowLong"
		Static wndProcNew := 0

			if (!(wndProcNew := This.clbk[instance].addr)) ; called once only from the caller- this is extra security
			{
			This.clbk[instance] := new This.BoundFuncCallback( ObjBindMethod(This, "WndProc"), 4 )
			wndProcNew := This.clbk[instance].addr
				if (wndProcNew)
				{
					if (!(This.wndProcOld := DllCall(SetWindowLong, "Ptr", Splashy.hWnd(), "Int", GWL_WNDPROC := -4, "Ptr", wndProcNew, "Ptr")))
					msgbox, 8208, WndProc, Bad return!		
				}
				else
				msgbox, 8208, WndProc, No address!
			}
		}

		__Delete(instance)
		{
			This.clbk[instance] := "" ; triggers clbk.__Delete()
		}

		class BoundFuncCallback
		{
		; https://www.autohotkey.com/boards/viewtopic.php?f=76&t=88704&p=390706
			__New(BoundFuncObj, paramCount, options := "")
			{
			This.pInfo := Object( {BoundObj: BoundFuncObj, paramCount: paramCount} )
			This.addr := RegisterCallback(This.__Class . "._Callback", options, paramCount, This.pInfo)
			}
			__Delete()
			{
			ObjRelease(This.pInfo)
			if (DllCall("GlobalFree", "Ptr", This.addr, "Ptr"))
			msgbox, 8208, GlobalFree, Memory could not be released!
			}
			_Callback(Params*)
			{
			Info := Object(A_EventInfo), Args := []
			Loop % Info.paramCount
			Args.Push( NumGet(Params + A_PtrSize*(A_Index - 2)) )
			Return Info.BoundObj.Call(Args*)
			}
		}

		WndProc(hwnd, uMsg, wParam, lParam)
		{
		;Critical 
			Switch uMsg
			{
				case % This.WM_CTLCOLORSTATIC:
				{
				return This.CtlColorStaticProc(wParam, lParam)
				}
				case % This.WM_PAINT:
				{
				This.PaintProc()
				return 0
				}
				case % This.WM_ENTERSIZEMOVE:
				{
				; For WM_Move: revert the parent for the window move
				Splashy.CheckParentStat()
				return 0
				}
				case % This.WM_EXITSIZEMOVE:
				{
				; Revert to Splashy
				Splashy.CheckParentStat(1)
				This.PaintProc()
				return 0
				}
				case % This.WM_NCHITTEST:
				{
				return This.NcHitTestProc(hWnd, uMsg, wParam, lParam)
				}
				Default:
				return DllCall("CallWindowProc", "Ptr", This.wndProcOld, "Ptr", hWnd, "UInt", uMsg, "Ptr", wParam, "Ptr", lParam)
			}
			
		}

		NcHitTestProc(hWnd, uMsg, wParam, lParam)
		{
			Static HTCLIENT := 1, HTCAPTION := 2
			; Makes form movable

			if (Splashy.vMovable)
			{

			lResult := DllCall("DefWindowProc", "Ptr", hWnd, "UInt", uMsg, "UPtr", wParam, "Ptr", lParam)

				if (lResult == HTCLIENT)
				lResult := HTCAPTION
			return % lResult
			}
			else
			return % HTCLIENT
		}

		CtlColorStaticProc(wParam, lParam)
		{
		static DC_BRUSH := 0x12
 
			if (lparam == Splashy.subTextHWnd[Splashy.instance]) ; && This.hDCWin == wParam)
			This.SetColour(wParam, Splashy.subBkgdColour, Splashy.subFontColour)
			else
			{
				if (lParam == Splashy.mainTextHWnd[Splashy.instance])
				This.SetColour(wParam, Splashy.mainBkgdColour, Splashy.mainFontColour)
			}

		return DllCall("Gdi32.dll\GetStockObject", "UInt", DC_BRUSH, "UPtr")
		}

		SetColour(textDC, bkgdColour, fontColour) 
		{
			static NULL_BRUSH := 0x5, TRANSPARENT := 0X1, OPAQUE := 0X2, CLR_INVALID := 0xFFFFFFFF

			DllCall("Gdi32.dll\SetBkMode", "Ptr", textDC, "UInt", (Splashy.transCol)? TRANSPARENT: OPAQUE)
			if (DllCall("Gdi32.dll\SetBkColor", "Ptr", textDC, "UInt", bkgdColour) == CLR_INVALID)
			msgbox, 8208, SetBkColor, Cannot set background colour for text!
			if (DllCall("Gdi32.dll\SetTextColor", "Ptr", textDC, "UInt", fontColour) == CLR_INVALID)
			msgbox, 8208, SetTextColor, Cannot set colour for text!

			if (DllCall("SetDCBrushColor", "Ptr", textDC, "UInt", bkgdColour) == CLR_INVALID)
			msgbox, 8208, SetDCBrushColor, Cannot set colour for brush!
		}


		PaintProc(hWnd := 0)
		{
		spr := 0	
			if (VarSetCapacity(PAINTSTRUCT, A_PtrSize + A_PtrSize + 56, 0)) ; hdc, rcPaint are pointers
			{
					if (!hWnd)
					{
					hWnd := Splashy.hWnd()
						if (!Splashy.procEnd)
						spr := 1
					}
				; DC validated
					if (DllCall("User32.dll\BeginPaint", "Ptr", hWnd, "Ptr", &PAINTSTRUCT, "UPtr"))
					{
						if (!spr)
						{
						static vDoDrawImg := 1 ;set This to 0 and the image won't be redrawn
						static vDoDrawBgd := 1 ;set This to 0 and the background won't be redrawn
						;return ;uncomment This line and the window will be blank

							if (vDoDrawImg)
							Splashy.PaintDC()

							if (vDoDrawBgd)
							Splashy.DrawBackground()
						}
					}
				DllCall("User32.dll\EndPaint", "Ptr", hWnd, "Ptr", &PAINTSTRUCT, "UPtr")
			}
			else
			msgbox, 8208, PAINTSTRUCT, Cannot paint!
		}

		SubClassTextCtl(ctlHWnd, release := 0)
		{
		Static SubProcFunc := 0
			if (release)
			{
			This.subClbk := "" ; triggers subClbk.__Delete()
			SubProcFunc := 0
			}
			else
			{
				if (!ctlHWnd)
				return
				; This only works for one window atm
				if (SubProcFunc)
				return
				else
				{
				This.subClbk := new This.BoundFuncCallback(ObjBindMethod(This, "SubClassTextProc"), 6)
				SubProcFunc := This.subClbk.addr
				}

				if !DllCall("Comctl32.dll\SetWindowSubclass", "Ptr", ctlHWnd, "Ptr", SubProcFunc, "Ptr", ctlHWnd, "Ptr", 0)
				msgbox, 8208, Text Control, SubClassing failed!

			}
		}
		SubClassTextProc(hWnd, uMsg, wParam, lParam, IdSubclass, RefData)
		{
		;THis subclass for marquee code
		; WM_PAINT is required to paint the scrolled text.
		; BeginPaint in WM_PAINT will erase the content already set in the DC of the control.
		;
		;To prevent, temporarily modify AHK's own hbrBackground in its WNDCLASSEX
		; hbrBackground := DllCall(GetStockObject(NULL_BRUSH))
		;
		;Which means we have to create our own class and window for the control anyway,
		; Then use Pens & Brushes & DrawTextEx et al.

		Critical
		static DC_BRUSH := 0x12
		/*



			if (uMsg == This.WM_ERASEBKGND)
			{
			return 1
			}
			if (uMsg == This.WM_PAINT)
			{
			VarSetCapacity(PAINTSTRUCT, A_PtrSize + A_PtrSize + 56, 0)
				if (!(hDC := DllCall("User32.dll\BeginPaint", "Ptr", hWnd, "Ptr", &PAINTSTRUCT, "UPtr")))
				return 0
			spr := This.ToBase(hWnd, 16)
			spr1 := InStr(spr, This.mainTextHWnd[This.instance])
			spr2 := InStr(spr, This.subTextHWnd[This.instance])


				if (spr1 || spr2)
				{

				if (This.mainMarquee && spr1)
				{
				}
				else
					{
						if (This.mainMarquee && spr1)
						{
						}
						else
						{
							if (spr1)
							This.SetColour(This.mainBkgdColour, hDC)
							else
							This.SetColour(This.subBkgdColour, hDC)
						}
					}
				}

			DllCall("User32.dll\EndPaint", "Ptr", hWnd, "Ptr", &PAINTSTRUCT, "UPtr")
			return 0
			}

	;Marquee code in an outside function
				;RECT rectControls := {wd + xCurrentScroll, yCurrentScroll, xNewSize + xCurrentScroll, yNewSize + yCurrentScroll};
				;if (!ScrollDC(hdcWinCl, -xDelta, 0, (CONST RECT*) &rectControls, (CONST RECT*) &rectControls, (HRGN)NULL, (RECT*) &rectControls))
					;ReportErr(L"HORZ_SCROLL: ScrollD Failed!");

	*/

		Return DllCall("Comctl32.dll\DefSubclassProc", "Ptr", hWnd, "UInt", uMsg, "Ptr", wParam, "Ptr", lParam)
		}

	}


	SplashImg(argList*)
	{
	parentOut := ""
	imagePathOut := ""
	imageUrlOut := ""
	bkgdColourOut := ""
	transColOut := ""
	vHideOut := 0
	noHWndActivateOut := ""
	vImgTxtSizeOut := 0
	vMovableOut := 0
	vBorderOut := ""
	vOnTopOut := 0
	vPosXOut := ""
	vPosYOut := ""
	vMgnXOut := 0
	vMgnYOut := 0
	vImgWOut := 0
	vImgHOut := 0
	mainTextOut := ""
	mainBkgdColourOut := ""
	mainFontNameOut := ""
	mainFontSizeOut := 0
	mainFontWeightOut := 0
	mainFontColourOut := -1
	mainFontQualityOut := -1
	mainFontItalicOut := 0
	mainFontStrikeOut := 0
	mainFontUnderlineOut := 0
	subTextOut := ""
	subBkgdColourOut := ""
	subFontNameOut := ""
	subFontSizeOut := 0
	subFontWeightOut := 0
	subFontColourOut := -1
	subFontQualityOut := -1
	subFontItalicOut := 0
	subFontStrikeOut := 0
	subFontUnderlineOut := 0

	This.SaveRestoreUserParms()

	StringCaseSense, Off
	SetWorkingDir %A_ScriptDir%

		if (argList["release"])
		{
			This.Destroy()
			return
		}

		if (argList.HasKey("instance"))
		{
			if (key := argList["instance"])
			{
				if key is not number
				key := 1
			}
			else
			key := 1
			
		key := Floor(key) ; 0 defaults to 1

			if (This.hWndSaved[key])
			{
			This.instance := key

				if (This.instance != This.oldInstance)
				{
				; Ensures current postion is not reset
					This.vPosX := ""
					This.vPosY := ""
				}
			}
			else
			{
				if (key < 0)
				{
				key := -key
					if (This.hWndSaved[key])
					{
					;WinClose, % "ahk_id " This.hWndSaved[This.instance]
					This.hWndSaved[key] := 0
					This.mainTextHWnd[key] := 0
					This.subTextHWnd[key] := 0
					spr := "Splashy" . key
					Gui, %spr%: Destroy
					Splashy.NewWndProc.clbk[key] := ""

					;Now reset This.instance for next call
						if (This.hWndSaved.Length() == 1)
						This.instance := 1
						else
						{
							if (This.hWndSaved.Length() == key)
							This.instance -= 1
							else
							This.instance := This.hWndSaved.MaxIndex()
						}
					This.oldInstance := This.instance
					}
				This.SaveRestoreUserParms(1)
				return
				}
				else
				{
					if (key > This.MaxGuis)
					{
					This.SaveRestoreUserParms(1)
					return
					}
					else
					This.instance := key
				}
			}
		}

		if (This.hWndSaved[This.instance])
		{
			if (argList.HasKey("initSplash"))
			{
				if (argList["initSplash"])
				This.updateFlag := 0
				else
				This.updateFlag := 1
			}
			else
			This.updateFlag := 1
		}
		else
		{
		; init the parent hWnd
			if (!This.parentHWnd)
			{
				if (This.parentHWnd := This.SetParentFlag())
				{
					if (This.parentHWnd == "Error")
					{
					;msgbox, 8192, Parent Script, Warning: Parent script is not AHK, or the window handle cannot be obtained!
					This.parentHWnd := 0
					}
				}
			}
		}


		For key, value in argList
		{

		; An alternative: https://www.autohotkey.com/boards/viewtopic.php?f=6&t=9656
			if (key)
			{
			; Validate values
				Switch key
				{

				Case "parent":
				{
					if (This.updateFlag > 0)
					This.parent := value
					else
					parentOut := value
				}

				Case "imagePath":
				{
					if (This.updateFlag > 0)
					This.imagePath := This.ValidateText(value)
					else
					imagePathOut := value

					if ((InStr(This.imagePath, "*")))
					This.picInScript := 1
					else
					This.picInScript := 0
				}

				Case "imageUrl":
				{
				value := Trim(Value)

					if (This.updateFlag > 0)
					{
					This.imageUrl := This.ValidateText(value)
						if (This.imagePath == A_AhkPath)
						This.imagePath := ""
					}
					else
					imageUrlOut := value
				}
				Case "bkgdColour":
				{
					if (This.updateFlag > 0)
					This.bkgdColour := (value == "")?This.GetDefaultGUIColour():This.ValidateColour(value)
					else
					bkgdColourOut := value
				}
				Case "transCol":
				{
					if (This.transCol)
					{
						if (!value && This.hWndSaved[This.instance])
						{
						WinSet, TransColor, Off, % "ahk_id" . This.hWndSaved[This.instance]
							if (This.subTextHWnd[This.instance])
							WinSet, TransColor, Off, % "ahk_id" . This.subTextHWnd[This.instance]
							if (This.mainTextHWnd[This.instance])
							WinSet, TransColor, Off, % "ahk_id" . This.mainTextHWnd[This.instance]
						}
					}

					if (This.updateFlag > 0)
					This.transCol := value
					else
					transColOut := value
				}
				Case "vHide":
				{
					if (This.updateFlag > 0)
					This.vHide := value
					else
					vHideOut := value
				}
				Case "noHWndActivate":
				{
					if (This.updateFlag > 0)
					This.noHWndActivate := (value)? "NoActivate ": ""
					else
					noHWndActivateOut := value
				}
				Case "vOnTop":
				{
					if (This.updateFlag > 0)
					This.vOnTop := value
					else
					vOnTopOut := value
				}
				Case "vMovable":
				{
					if (This.updateFlag > 0)
					This.vMovable := value
					else
					vMovableOut := value
				}
				Case "vBorder":
				{
					if (InStr(value, "b"))
					spr := "b"
					else
					{
					spr := ""
						if (InStr(value, "w"))
						spr .= "w"
						if (InStr(value, "s"))
						spr .= "s"
						if (InStr(value, "c"))
						spr .= "c"
						if (InStr(value, "d"))
						spr .= "d"
						if (value && !spr)
						spr := "dlgframe"
					}
					if (This.updateFlag > 0)
					This.vBorder := spr
					else
					vBorderOut := spr
				}
				Case "vImgTxtSize":
				{
					if (This.updateFlag > 0)
					This.vImgTxtSize := value
					else
					vImgTxtSizeOut := value
				}
				Case "vPosX":
				{
					if value is number
					{
						if (value)
						spr := Floor(value)
						else
						spr := "zero"
					}
					else
					spr := (Instr(value, "c"))? "c": ""

					if (This.updateFlag > 0)
					This.vPosX := spr
					else
					vPosXOut := spr
				}

				Case "vPosY":
				{
					if value is number
					{
						if (value)
						spr := Floor(value)
						else
						spr := "zero"
					}
					else
					spr := (Instr(value, "c"))? "c": ""

					if (This.updateFlag > 0)
					This.vPosY := spr
					else
					vPosYOut := spr
				}

				Case "vMgnX":
				{
					if (value >= 0)
					{
					spr := Instr(value, "d")? "d": Floor(value)
						if (This.updateFlag > 0)
						This.vMgnX := spr
						else
						vMgnXOut := spr
					}
				}
				Case "vMgnY":
				{
					if (value >= 0)
					{
					spr := Instr(value, "d")? "d": Floor(value)
						if (This.updateFlag > 0)
						This.vMgnY := spr
						else
						vMgnYOut := spr
					}
				}

				Case "vImgW":
				{
				spr := (This.actualVImgW)?This.ProcImgWHVal(value):value

					if (This.updateFlag > 0)
					This.inputVImgW := spr
					else
					vImgWOut := spr
				}

				Case "vImgH":
				{
				spr := (This.actualVImgH)?This.ProcImgWHVal(value, 1):value

					if (This.updateFlag > 0)
					This.inputVImgH := spr
					else
					vImgHOut := spr
				}


				Case "mainText":
				{
					if (This.updateFlag > 0)
					This.mainText := This.ValidateText(value)
					else
					mainTextOut := value
				}
				Case "mainBkgdColour":
				{
					if (This.updateFlag > 0)
					This.mainBkgdColour := (value == "")?This.GetDefaultGUIColour():This.ValidateColour(value, 1)
					else
					mainBkgdColourOut := value
				}
				Case "mainFontName":
				{
					if (This.updateFlag > 0)
					This.mainFontName := (value)?This.ValidateText(value):"Verdana"
					else
					mainFontNameOut := value
				}

				Case "mainFontSize":
				{
				value := abs(value)  ; 200 arbitrary limit
					if (This.updateFlag > 0)
					This.mainFontSize := (0 < value <= 200)?Floor(value):10
					else
					mainFontSizeOut := value
				}
				Case "mainFontWeight":
				{
				value := abs(value)
					if (This.updateFlag > 0)
					This.mainFontWeight := (0 < value <= 1000)?Floor(value):400
					else
					mainFontWeightOut := value
				}
				Case "mainFontColour":
				{
					if (value != -1)
					{
						if (This.updateFlag > 0)
						This.mainFontColour := This.ValidateColour(value, 1)
						else
						mainFontColourOut := value
					}
				}
				Case "mainFontQuality":
				{
				value := abs(value) ; 0 :=  DEFAULT_QUALITY
					if (This.updateFlag > 0)
					This.mainFontQuality := (0 <= value <= 5)?Floor(value):1
					else
					mainFontQualityOut := value
				}
				Case "mainFontItalic":
				{
					if (This.updateFlag > 0)
					This.mainFontItalic := (value)? " Italic": ""
					else
					mainFontItalicOut := value
				}
				Case "mainFontStrike":
				{
					if (This.updateFlag > 0)
					This.mainFontStrike := (value)? " Strike": ""
					else
					mainFontStrikeOut := value
				}
				Case "mainFontUnderline":
				{
					if (This.updateFlag > 0)
					This.mainFontUnderline := (value)? " Underline": ""
					else
					mainFontUnderlineOut := value
				}




				Case "subText":
				{
					if (This.updateFlag > 0)
					This.subText := This.ValidateText(value)
					else
					subTextOut := value
				}
				Case "subBkgdColour":
				{
					if (This.updateFlag > 0)
					This.subBkgdColour := (value == "")?This.GetDefaultGUIColour():This.ValidateColour(value, 1)
					else
					subBkgdColourOut := value
				}

				Case "subFontName":
				{
					if (This.updateFlag > 0)
					This.subFontName := (value)?This.ValidateText(value):"Verdana"
					else
					subFontNameOut := value
				}
				Case "subFontSize":
				{
				value := abs(value)  ; 200 arbitrary limit
					if (This.updateFlag > 0)
					This.subFontSize := (0 < value <= 200)?Floor(value):10
					else
					subFontSizeOut := value
				}
				Case "subFontWeight":
				{
				value := abs(value)
					if (This.updateFlag > 0)
					This.subFontWeight := (0 < value <= 1000)?Floor(value):400
					else
					subFontWeightOut := value
				}
				Case "subFontColour":
				{
					if (value != -1)
					{
						if (This.updateFlag > 0)
						This.subFontColour := This.ValidateColour(value, 1)
						else
						subFontColourOut := value
					}
				}
				Case "subFontQuality":
				{
				value := abs(value)
					if (This.updateFlag > 0)
					This.subFontQuality := (0 <= value <= 5)?Floor(value):1
					else
					subFontQualityOut := value
				}
				Case "subFontItalic":
				{
					if (This.updateFlag > 0)
					This.subFontItalic := (value)? " Italic": ""
					else
					subFontItalicOut := value
				}
				Case "subFontStrike":
				{
					if (This.updateFlag > 0)
					This.subFontStrike := (value)? " Strike": ""
					else
					subFontStrikeOut := value
				}
				Case "subFontUnderline":
				{
					if (This.updateFlag > 0)
					This.subFontUnderline := (value)? " Underline": ""
					else
					subFontUnderlineOut := value
				}


				}
				
			}
		}

	This.SplashImgInit(parentOut, imagePathOut, imageUrlOut
	, bkgdColourOut, transColOut, vHideOut, noHWndActivateOut
	, vOnTopOut, vMovableOut, vBorderOut, vImgTxtSizeOut
	, vPosXOut, vPosYOut, vMgnXOut, vMgnYOut, vImgWOut, vImgHOut
	, mainTextOut, mainBkgdColourOut
	, mainFontNameOut, mainFontSizeOut, mainFontWeightOut, mainFontColourOut
	, mainFontQualityOut, mainFontItalicOut, mainFontStrikeOut, mainFontUnderlineOut
	, subTextOut, subBkgdColourOut
	, subFontNameOut, subFontSizeOut, subFontWeightOut, subFontColourOut
	, subFontQualityOut, subFontItalicOut, subFontStrikeOut, subFontUnderlineOut)
	
	}

	SplashImgInit(parentIn, imagePathIn, imageUrlIn
	, bkgdColourIn, transColIn, vHideIn, noHWndActivateIn
	, vOnTopIn, vMovableIn, vBorderIn, vImgTxtSizeIn
	, vPosXIn, vPosYIn, vMgnXIn, vMgnYIn, vImgWIn, vImgHIn
	, mainTextIn, mainBkgdColourIn
	, mainFontNameIn, mainFontSizeIn, mainFontWeightIn, mainFontColourIn
	, mainFontQualityIn, mainFontItalicIn, mainFontStrikeIn, mainFontUnderlineIn
	, subTextIn, subBkgdColourIn
	, subFontNameIn, subFontSizeIn, subFontWeightIn, subFontColourIn
	, subFontQualityIn, subFontItalicIn, subFontStrikeIn, subFontUnderlineIn)
	/*
	; Future expansion for vertical text:
	, rightText := "", rightFontNameIn := "", rightFontSizeIn := 0, rightFontWeightIn := 0, rightFontColourIn := -1
	, leftText := "", leftFontNameIn := "", leftFontSizeIn := 0, leftFontWeightIn := 0, leftFontColourIn := -1
	; also consider transparency
	*/
	{
	vWinW := 0, vWinH := 0, parentW := 0, parentH := 0, init := 0
	mainTextSize := [0, 0], subTextSize := [0, 0]
	currVPos := {x: "", y: ""}
	static splashyInst := ""
	; Border constants
	Static WS_DLGFRAME := 0x400000, WS_CAPTION := 0xC00000, WS_POPUP := 0x80000000, WS_CHILD := 0x40000000, WS_EX_COMPOSITED := 0X2000000
	Static WS_EX_WINDOWEDGE := 0x100, WS_EX_STATICEDGE := 0x20000, WS_EX_CLIENTEDGE := 0x200, WS_EX_DLGMODALFRAME := 0x1

	; Determines redraw of Splashy window (placeholder)
	diffPicOrDiffDims := 0

	This.procEnd := 0

		if (This.updateFlag <= 0)
		{
		;Set defaults
			if (parentIn != "")
			This.parent := parentIn

			if (imagePathIn == "")
			{
				if (!This.imagePath && imageUrlIn == "")
				This.imagePath := A_AhkPath ; default icon. Ist of 5
			}
			else
			This.imagePath := imagePathIn

			if (imageUrlIn == "")
			{
				if (!This.imageUrl)
				This.imageUrl := "https://www.autohotkey.com/assets/images/features-why.png"
			}
			else
			This.imageUrl := imageUrlIn

			if (bkgdColourIn == "")
			This.bkgdColour := This.GetDefaultGUIColour()
			else
			This.bkgdColour := This.ValidateColour(bkgdColourIn)

		This.transCol := transColIn

		This.vHide := vHideIn

			if (noHWndActivateIn)
			This.noHWndActivate := "NoActivate "
			else
			This.noHWndActivate := ""

		This.vOnTop := vOnTopIn
		This.vMovable := vMovableIn
		This.vBorder := vBorderIn
		This.vImgTxtSize := vImgTxtSizeIn

		This.vPosX := (vPosXIn == "")? This.vPosX: vPosXIn
		This.vPosY := (vPosYIn == "")? This.vPosY: vPosYIn
		This.vMgnX := (vMgnXIn == "")? This.vMgnX: vMgnXIn
		This.vMgnY := (vMgnYIn == "")? This.vMgnY: vMgnYIn

			if (vImgWIn > 0)
			This.inputVImgW := vImgWIn
			else
			{
				if (vImgWin <= -10)
				This.inputVImgW := 0
				else
				This.inputVImgW := vImgWIn
				; a zero default can be Floor(A_ScreenWidth/3)
			}
			if (vImgHIn > 0)
			This.inputVImgH := vImgHIn
			else
			{
				if (vImgHin <= -10)
				This.inputVImgH := 0
				else
				This.inputVImgH := vImgHIn
				; a zero default can be Floor(A_ScreenHeight/3)
			}




			if (mainTextIn == "")
			This.mainText := ""
			else
			This.mainText := This.ValidateText(mainTextIn)

			if (mainBkgdColourIn == "")
			This.mainBkgdColour := This.GetDefaultGUIColour()
			else
			This.mainBkgdColour := This.ValidateColour(mainBkgdColourIn, 1)

			if (mainFontNameIn == "")
			This.mainFontName := "Verdana"
			else
			This.mainFontName := This.ValidateText(mainFontNameIn)

		This.mainFontSize := (0 < mainFontSizeIn < 200)?Floor(mainFontSizeIn):12
		This.mainFontWeight := (0 < mainFontWeightIn < 1000)?Floor(mainFontWeightIn):600


			if (mainFontColourIn == -1)
			{
				if (This.mainFontColour == "")
				This.mainFontColour := This.GetDefaultGUIColour(1)
			}
			else
			This.mainFontColour := This.ValidateColour(mainFontColourIn, 1)

			if (mainFontQualityIn == "")
			This.mainFontQuality := 1
			else
			; NONANTIALIASED_QUALITY for better performance
			; https://stackoverflow.com/questions/8283631/graphics-drawstring-vs-textrenderer-drawtextwhich-can-deliver-better-quality/23230570#23230570
			This.mainFontQuality := (0 <= mainFontQualityIn <= 5)?Floor(mainFontQualityIn):1

		This.mainFontItalic := (mainFontItalicIn)? " Italic": ""

		This.mainFontStrike := (mainFontStrikeIn)? " Strike": ""

		This.mainFontUnderline := (mainFontUnderlineIn)? " Underline": ""



			if (subTextIn =="")
			This.subText := ""
			else
			This.subText :=  This.ValidateText(subTextIn)

			if (subBkgdColourIn == "")
			This.subBkgdColour := This.GetDefaultGUIColour()
			else
			This.subBkgdColour := This.ValidateColour(subBkgdColourIn, 1)


			if (subFontNameIn == "")
			This.subFontName := "Verdana"
			else
			This.subFontName := This.ValidateText(subFontNameIn)

		This.subFontSize := (0 < subFontSizeIn < 200)?Floor(subFontSizeIn):10
		This.subFontWeight := (0 < subFontWeightIn < 1000)?Floor(subFontWeightIn):400

			if (subFontColourIn == -1)
			{
				if (This.subFontColour == "")
				This.subFontColour := This.GetDefaultGUIColour(1)
			}
			else
			This.subFontColour := This.ValidateColour(subFontColourIn, 1)

			if (subFontQualityIn == "")
			This.subFontQuality := 1
			else
			This.subFontQuality := (0 <= subFontQualityIn <= 5)?Floor(subFontQualityIn):1

		This.subFontItalic := (subFontItalicIn)? " Italic": ""

		This.subFontStrike := (subFontStrikeIn)? " Strike": ""

		This.subFontUnderline := (subFontUnderlineIn)? " Underline": ""

			if (This.updateFlag == -1) ; init
			{
			This.updateFlag := 1
			init := 1
			}
		}

		if (diffPicOrDiffDims := This.GetPicWH())
		{
			if (diffPicOrDiffDims) == "error"
			return
			else
			{
				if (This.DisplayToggle() == "error")
				return
			}
		}

	DetectHiddenWindows On
	splashyInst := "Splashy" . (This.instance)

		if (!This.hWndSaved[This.instance])
		{
			if (!This.hGDIPLUS)
			{
				if (This.hGDIPLUS := DllCall("LoadLibrary", "Str", "GdiPlus.dll", "Ptr"))
				{
				VarSetCapacity(SI, (A_PtrSize = 8 ? 24 : 16), 0), Numput(1, SI, 0, "Int")
				DllCall("GdiPlus.dll\GdiplusStartup", "UPtr*", spr, "Ptr", &SI, "Ptr", 0)
				; for return value see status enumeration in  gdiplustypes.h 
				This.pToken := spr
				}
				else
				msgbox, 8208, LoadLibrary, Critical GDIPLUS error!
			}

		;Create Splashy window

		Gui, %splashyInst%: New, +OwnDialogs +ToolWindow -Caption -DPIScale +E%WS_EX_COMPOSITED% ;  WS_POPUP active since default

		This.NewWndObj := new Splashy.NewWndProc(This.instance)
		}

		; Set borders:
		if (This.voldBorder || This.vBorder) ; null or zero
		{
			if (This.instance != This.oldInstance || This.voldBorder != This.vBorder)
			{
			; -0x800000 is not sufficient to remove the standard borders.
			Gui, %splashyInst%: -%WS_CAPTION% -E%WS_EX_WINDOWEDGE% -E%WS_EX_STATICEDGE% -E%WS_EX_CLIENTEDGE% -E%WS_EX_DLGMODALFRAME%
				if (This.vBorder)
				{
					if (This.vBorder == "b")
					Gui, %splashyInst%: +Border
					else
					{
						if (This.vBorder == "dlgframe")
						Gui, %splashyInst%: +WS_DLGFRAME
						else
						{
							Loop, Parse, % This.vBorder
							{
								Switch (A_Loopfield)
								{
									Case "w":
									Gui, %splashyInst%: +E%WS_EX_WINDOWEDGE%
									Case "s":
									Gui, %splashyInst%: +E%WS_EX_STATICEDGE%
									Case "c":
									Gui, %splashyInst%: +E%WS_EX_CLIENTEDGE%
									Case "d":
									Gui, %splashyInst%: +E%WS_EX_DLGMODALFRAME%
								}
							}
						}
					}
				}

			This.voldBorder := This.vBorder
			}
		}

		if (spr := This.parentHWnd)
		{
			if (This.parent)
			{

			; Somehow co-ordinates go wrong if the position is not obtained here
				if (!init)
				currVPos := This.GuiGetPos(This.hWnd(), 1)

			Gui, %splashyInst%: -%WS_POPUP% +%WS_CHILD%
			Gui, %splashyInst%: +parent%spr%

			point := This.GuiGetPos(spr)

			parentW := point.w
			parentH := point.h

				if (This.parentClip)
				Winset, Style, % -This.parentClip , % "ahk_id" This.parentHWnd
			point := ""

			vWinW := This.vImgW
			vWinH := This.vImgH
			}
			else
			{
			Gui, %splashyInst%: -parent%spr%
			Gui, %splashyInst%: +%WS_CHILD% +%WS_POPUP%
			parentW := A_ScreenWidth
			parentH := A_ScreenHeight
				if (This.parentClip)
				Winset, Style, % This.parentClip , % "ahk_id" This.parentHWnd
			}
		}
		else
		{
		parentW := A_ScreenWidth
		parentH := A_ScreenHeight
		}


		if (!This.parent)
		{

			if (This.vMgnX == "d")
			{
			SM_CXEDGE := 45
			sysget, spr, %SM_CXEDGE%
			This.vMgnX := spr
			}

			if (This.vMgnX == "d")
			{
			SM_CYEDGE := 46
			sysget, spr, %SM_CYEDGE%
			This.vMgnY := spr
			}

		This.vImgX := This.vMgnX, This.vImgY := This.vMgnY
		vWinW := This.vImgW + 2 * This.vMgnX
		vWinH := This.vImgH + This.vMgnY
		}

	Gui, %splashyInst%: Color, % This.bkgdColour



		This.vImgY := This.DoText(splashyInst, This.mainTextHWnd[This.instance], This.mainText, currVPos, parentW, parentH, vWinW, vWinH, init)
		vWinH += This.vImgY

		if (spr := This.DoText(splashyInst, This.subTextHWnd[This.instance], This.subText, currVPos, parentW, parentH, vWinW, vWinH, init, 1))
		vWinH += spr + (This.parent?0:This.vMgnY)


	Gui, %splashyInst%: Font

		; now set hWndSaved[This.instance] in hWnd()
		if (This.vHide)
		WinHide % "ahk_id" This.hWnd()
		else
		{
		spr1 := 0
		spr := A_Space

			if (!(This.Parent && (This.mainText || This.subText)))
			{
			currVPos := This.GetPosVal(This.vPosX, This.vPosY, currVPos, parentW, parentH, vWinW, vWinH, (This.parent?This.parentHWnd:0))
			currVPos := This.GetPosProc(splashyInst, currVPos, init)
			}

			if (This.parent)
			Gui, %splashyInst%: Show, % This.noHWndActivate . Format("X{} Y{} W{} H{}", currVPos.x, currVPos.y, vWinW, vWinH)
			else
			{
			; Also consider cloaking (DWMWA_CLOAK)
			Gui, %splashyInst%: Show, % "Hide " . Format(" W{} H{}", vWinW, vWinH)

			;WinGetPos, point.x, point.y,,, % "ahk_id" . This.hWnd(); fail

			; Supposed to prevent form visibility without picture while loading. Want another approach?
			Gui, %splashyInst%: Show, % "Hide " . Format("X{} Y{}", -30000, -30000)
			sleep 20
			;WinMove, % "ahk_id" . This.hWnd(),, % point.x, % point.y ; fails here whether 30000 or 0, as well as SetWindowPos. SetWindowPlacement?

			Gui, %splashyInst%: Show, % This.noHWndActivate . Format("X{} Y{}", currVPos.x, currVPos.y)
			}


		WinSet, AlwaysOnTop, % (This.vOnTop)? 1 : 0, % "ahk_id" . This.hWnd()
			if (This.transCol && !This.vBorder)
			WinSet, TransColor, % This.bkgdColour, % "ahk_id" . This.hWndSaved[This.instance]
		Splashy.NewWndProc.PaintProc(This.hWndSaved[This.instance])
		}

	This.procEnd := 1
	This.oldInstance := This.instance
	SetWorkingDir % This.userWorkingDir
	DetectHiddenWindows Off

	; Sleep -1 is critical, else PaintDC gets out of sync
	Sleep, -1

	}
	;==========================================================================================================
	;==========================================================================================================


	ValidateText(string)
	{
		if (string != "")
		{
			if (StrLen(string) > 20000) ;length?
			string := SubStr(string, 1, 20000)
		}
	return string
	}

	ValidateColour(keyOrVal, toBGR := 0)
	{


		if (This.HTML.HasKey(keyOrVal))
		{
		keyOrVal := This.ToBase(This.HTML[keyOrVal], 16)
		spr1 := StrLen(keyOrVal)
		}
		else
		{
		spr := ""

		spr1 := StrLen(keyOrVal)

		; If "0X" found, remove it. Will be added later. Remove other X's
		
		if (InStr(SubStr(keyOrVal, 1, 2), "0X"))
		keyOrVal := StrReplace(SubStr(keyOrVal, 3, spr1 - 2), "X", "0")
		else
		keyOrVal := StrReplace(SubStr(keyOrVal, 1, spr1), "X", "0")			; filter out numerics 

			if keyOrVal is not xdigit
			{
				; Filter out all but numerics
				loop, Parse, keyOrVal, , %A_Space%%A_Tab% `,
				{
					if A_Loopfield is xdigit
					spr .= A_Loopfield
				}

				if (spr)
				keyOrVal := spr
				else
				keyOrVal := 0
			}

			if (spr1 != 6 && keyOrVal is digit) ;  assume decimal,
			; which may not be desired if they were digits in above loop
			keyOrVal := This.ToBase(keyOrVal, 16)

		spr1 := StrLen(keyOrVal)

			if (spr1 > 8)
			spr1 := 8
			else
			{
				if (spr1 < 3)
				return "0X0"
			}

		}

	; pad zeroes
	spr2 := ""

		loop, % (6 - spr1)
		spr2 := spr2 . "0"

	spr := "0X" . spr2 . keyOrVal


		if (toBGR) ; for the GDI functions (ColorRef)
		spr := This.ReverseColour(spr)
		else
		{
			if (InStr(spr, "0X"))
			spr := SubStr(spr, 3, 6) ; "0X" prefix not required for AHK gui functions
		}

	return spr
	}

	ReverseColour(colour)
	{

		colour := ((colour & 0x0000FF) << 16 ) | (colour & 0x00FF00) | ((colour & 0xFF0000) >> 16)

		if colour is digit
		{
		spr := This.ToBase(colour, 16)
		; possible to return spr here
		; The following just pads the zeroes.
		spr1 := StrLen(spr)

		spr2 := ""

		loop, % (6 - spr1)
		spr2 := spr2 . "0"

		colour := "0X" . spr2 . spr

		}
		return colour
	}

	ToBase(n, b)
	{
	; Hex numbers n must be in quoted "0Xn" format
		Loop
		{
		r := mod(n, b)
		d := floor(n/b)

			if (b == 16)
			r := (r > 9)? chr(0x37 + r): r

		m := r . m
		n := d
			if (n < 1)
			Break
		}
	; returns without "0X"
	Return m
	}

	BinToHex(P, Bytes := 4, Prefix := "")
	{ 
	spr := ""
	Loop % (Bytes)
	   spr .= Format( "{:02X}", *(P + A_Index-1))
	Return ( Prefix . spr )
	}

	GetDefaultGUIColour(font := 0)
	{
		static COLOR_WINDOWTEXT := 8, COLOR_3DFACE := 15 ;(more white than grey these days)

		spr := DllCall("User32.dll\GetSysColor", "Int", (font)? 8: 15, "UInt")
		;BGR +> RGB
		spr := This.ReverseColour(spr)

		return spr
	}

	DownloadFile(URL, fName)
	{
			try
			{
;https://webapps.stackexchange.com/questions/162310/url-image-filtering-url-suffixes-and-wikimedia
			UrlDownloadToFile, %URL%, %fName%
			}
			catch spr
			{
			msgbox, 8208, FileDownload, Error with the bitmap download!`nSpecifically: %spr%
			}		
		FileGetSize, spr , % A_ScriptDir . "`\" . fName
			if spr < 50 ; some very small image
			{
			msgbox, 8208, FileDownload, File size is incorrect!
			return 0
			}
			sleep 50
			return 1


			return fName

	}


	DisplayToggle()
	{
	static vToggle := 1
	spr := 0, spr1 := 0
	; This function uses LoadPicture to populate hBitmap and hIcon
	; and sets the image type for the painting routines accordingly
	; Now that the image dimensions are determined from GetPicWH,
	; adjust the images with the extra possible input from vImgW and vImgW.

	vToggle := !vToggle
	; If the image is the same between calls, this routine is never called, 
	; so vToggle will not update.

	; This.inputVImgW == "" is valid for This.vImgTxtSize
	if (This.inputVImgW == "")
	This.vImgW := (This.vImgW? This.vImgW: This.actualVImgW)
	else
	{
		; In case vImgW is specified in the first call of the image,
		if (This.vImgW)
		This.vImgW := (This.inputVImgW? This.inputVImgW: This.actualVImgW)
		else
		This.vImgW := This.ProcImgWHVal((This.inputVImgW)?This.inputVImgW:This.actualVImgW)
	}

	if (This.inputVImgH == "")
	This.vImgH := (This.vImgH? This.vImgH: This.actualVImgH)
	else
	{
		if (This.vImgH)
		This.vImgH := (This.inputVImgH? This.inputVImgH: This.actualVImgH)
		else
		This.vImgH := This.ProcImgWHVal((This.inputVImgH)?This.inputVImgH:This.actualVImgH, 1)
	}








	spr1 := Format("W{} H{}", spr, spr1)

		if (This.imagePath)
		{
			if (This.hWndSaved[This.instance])
			{
				This.oldImagePath := This.imagePath

				if (This.hBitmap)
				{
					This.DeleteHandles()
					This.oldPicInScript := 0
				}
				else
				{
					if (This.hIcon)
					{
						if (This.picInScript)
						This.oldPicInScript := 1
						else
						This.DeleteHandles()
					}
				}
			}
		SplitPath % This.imagePath,,, spr

			if (spr == "")
			This.vImgType := 0 ; assume image
			else
			This.vImgType := ((spr == "cur")? 2: (spr == "exe" || spr == "ico")? 1: 0)


			if (InStr(This.imagePath, "*"))
			{
			This.vImgType := 1
			return
			}
			else
			{
				if (fileExist(This.imagePath))
				{

				spr := This.imagePath

					if (This.vImgType)
					{
						if (This.imagePath == A_AhkPath)
						{
						This.hIcon := LoadPicture(A_AhkPath, ((vToggle)? "Icon2": "") . spr1, spr)
						return
						}
						else
						{
							if (This.hIcon := LoadPicture(spr, spr1, spr)) ; must use 3rd parm or bitmap handle returned!
							return
						}
					}
					else
					{

						if (This.hBitmap := LoadPicture(spr, spr1))
						return
					}
				}
				else
				{
					if (!fileExist(This.ImageName) && !This.hIcon)
					{
					msgbox, 8208, DisplayToggle, Unknown Error!
					return "error"
					}
				}
			}
		SplitPath % This.imagePath, spr
		This.ImageName := spr
		}
		else
		This.oldImagePath := ""

		; Fail, so download

			if (This.imageUrl && RegExMatch(This.imageUrl, "^(https?://|www\.)[a-zA-Z0-9\-\.]+\.[a-zA-Z]{2,3}(/\S*)?$"))
			{
				if (!(This.ImageName))
				{
				SplitPath % This.imageUrl, spr
				This.ImageName := spr
				}
				;  check if file D/L'd previously
				for key, value in % This.downloadedUrlNames
				{
					if (This.imageUrl == value)
					{
						if (fileExist(key))
						{
							Try
							{
								if (key != This.ImageName)
								FileCopy, %key%, % This.ImageName
							Break
							}
							Catch e
							{
							msgbox, 8208, FileCopy, % key . " could not be copied with error: " . e
							}
						}
					}
				}


				if (!fileExist(This.ImageName))
				{
					if (!(This.DownloadFile(This.imageUrl, This.ImageName)))
					return "error"
				}

				if (This.hBitmap := LoadPicture(This.ImageName, spr1))
				{
				This.oldImageUrl := This.imageUrl
				This.vImgType := 0
				spr := This.ImageName

				This.downloadedPathNames.Push(spr) 
				This.downloadedUrlNames(spr) := This.oldImageUrl
				return
				}
				else
				{
				msgbox, 8208, LoadPicture, Format not recognized!
				FileDelete, % This.ImageName
				return "error"
				}

			}
			else
			spr := 1		

		; "Neverfail" default 
		This.hIcon := LoadPicture(A_AhkPath, ((vToggle)? "Icon2 ": "") . spr1, spr)
		This.vImgType := 1
		
	}

	GetPicWH()
	{
	Static oldParent := This.Parent, vToggle := 1

	vToggle := !vToggle
	/*
	typedef struct tagBITMAP {
	  LONG   bmType;
	  LONG   bmWidth;
	  LONG   bmHeight;
	  LONG   bmWidthBytes;
	  WORD   bmPlanes; // Short
	  WORD   bmBitsPixel; // Short
	  LPVOID bmBits; // FAR ptr to void
	} BITMAP, *PBITMAP, *NPBITMAP, *LPBITMAP; ==> Extra pointer reference
	*/

	if (This.imagePath)
	{
		if (This.hWndSaved[This.instance])
		{
			if (This.oldImagePath == This.imagePath)
			{
			; No need to reload if the parent has not changed
				if (oldParent == This.Parent)
				{
					if (This.inputVImgW && This.inputVImgH)
					{
						if (This.oldVImgW == This.inputVImgW && This.oldVImgH == This.inputVImgH)
						return 0
					}
					else
					{
						if ((This.picInScript && This.oldPicInScript) || (!This.picInScript && !This.oldPicInScript))
						{
							if (This.vImgTxtSize)
							{
								if (This.oldVImgW == This.vImgW)
								{
									; check for height
									if (This.oldVImgH == This.inputVImgH)
									return 0
									else
									This.oldVImgH := This.inputVImgH
								}
								else
								This.oldVImgW := This.vImgW
							}
							else
							{
								if (This.inputVImgW != "") ; else just switched off vImgTxtSize
								{
									if (This.oldVImgW == This.inputVImgW) && (This.oldVImgH == This.inputVImgH)
									return 0
									else
									{
										if (This.oldVImgW != This.inputVImgW && This.oldVImgH == This.inputVImgH)
										{
										This.oldVImgW := This.inputVImgW
										This.oldVImgH := This.inputVImgH
										}
										else
										{
											if (This.oldVImgW != This.inputVImgW)
											This.oldVImgW := This.inputVImgW
											else
											This.oldVImgH := This.inputVImgH
										}
									}
								}
							}
						}
					}
				}
				else
				oldParent := This.Parent
			}
			This.DeleteHandles()
		}

	SplitPath % This.imagePath,,, spr

		if (spr == "")
		This.vImgType := 0 ; assume image
		else
		This.vImgType := ((spr == "cur")? 2: (spr == "exe" || spr == "ico")? 1: 0)


		if (InStr(This.imagePath, "*"))
		{
		This.PicInScript := {}      


			Switch (This.imagePath)
			{
			Case "*Loading":
			{
			VarSetCapacity(This.PicInScript, 26532 << !!A_IsUnicode)
			This.PicInScript := "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"
			This.PicInScript .= "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"
			}
			Case "*Launching":
			{
			VarSetCapacity(This.PicInScript, 39928 << !!A_IsUnicode)
			This.PicInScript := "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"
			This.PicInScript .= "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"
			This.PicInScript .= "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"
			}
			Case "*Properties":
			{
			VarSetCapacity(This.PicInScript, 27696 << !!A_IsUnicode)
			This.PicInScript := "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"
			This.PicInScript .= "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"
			}
			Case "*LnchPadCfg":
			{
			VarSetCapacity(This.PicInScript, 41956 << !!A_IsUnicode)
			This.PicInScript := "iVBORw0KGgoAAAANSUhEUgAAASIAAAElCAMAAAB3ZR88AAADAFBMVEXL5P7S5/+73P7D4P7G4P7U6v/Y6//H4v+32f/Q5v3N5v/c7f+/3fzH4fzA3v7b7Py+3P/J4v/N5PzX6f/V6PzD3f3f7//P4//L4vnX5/fS4/YODk0NDEcGA2YBAzkTD0MJAm71///Q4vEDA1Hb6PO81P4RCQUFA1zj8v/J3/MDAkUXEDwPBxfK2v/5bQoYDjIhBwldIckJCj/D2fTscBzj7PYUDCcCAy9VJNPQcjZsGrT31Rv2uRr34ykxCAbF1P/S1/8WBHX0exPzoB1LK9z67hknGwcIAnvzrCIhCB/yiRnroDBPKsfrfiTzlhr+8QczIalmG8D64hJBMOXGgD3Z3v/3xhj11C7f5OnpjyzfcSz1xiZAFw758Sy/bTn5rQ83FpoXB4Y2Kwjn9P/O4eJHIK/28EBcIbhrHKFNGZ3hxUpQIQ15E6sZHkzyuSxQW4begjb6owyToMTy4kHrvz/t1UHBlj/vyTc+SHXjr0Cpdzbr6uzj2U6isdNDMtPT4c0jK1jgmTqGkrxeaJfSs0XRl0PssDQzO2WAVx3q3MxZGZFnGI2pYDhgKhoaAVPCq0FEOA58FZ63xvu2xuk7L8ZZG6gfD5fu61Th2t5we6HAz+3u5d1kUxZbOxDIyP/XpTvSxkThzb1CNLCxvtszI7nexqcwC4fTjDBSRxSVotl8iKvBwXNtPCTU2rRGFYyOTS6bii1uYh7czv+ouebCiFx+bSUpBWQSFmCVbDPJzpzUr5fJn4YqBXm4d01YH4GyiTWLeyqwtW7Etfzl3f+zqk2QjOzPtX+unzIpIzB/QyakofZNOLpAR4tCDXO/uk56NgzSwv+7zcJANTaZWC2xs/66ovTe5dklLXLj5m3DpWvRz1nLnFp3gbxncK9/Vrm3wpXS0IVdM6G+kHeclUItKoiAeE9iRLGjid6CeN2ptL91RKK0leNwZ9CYdstdVcXJtrBzc4NbWjvKztiWnZmIZcTNtl5LRVBaXG/FYBaacRibmV+lem17V060o6HKvh+tSA5Ln+wvAAB3pUlEQVR42uyZzbKTQBCFicRQEAgOASHZabnQteUT+f7v4Okzc2zGQWO59oMBcsPvl+6eSW714T8vqL5/2/Op4PHItz9G7BXg3/6Jb5jRDnjgGn/L8/nkXYBHeQU+Edvf85ltx/cKt/kQz8dTbNv2Bc1WEa31Uost8dyezuYt46N2a9EenHa0uprz9Y9wl3gQmq2fJs15QCCbM8bVPI5xK39vHD+NEb3/6Xv1GX+7zJd5nu93LNpTO5GqqobXVGISLcBSLUO7TF2L65xOp3YHr7mB/XXPy3kBfX+79Tew3Iz6Vtf1cm6aYbAWhm2bts2O5g2cjDlyN7i6gPEyRi58VXK9jleuAfe7mqKHCbq8BSdg97pOFQihEHK2CXdNBhFA9ZMux255NbiSzg5ketauq0SwKxmwUy993UPQOwh6B2jIfNU1ZtA0zZkfFeZqq+gInBL3+9vIPF9A8vSK627zYYqwMeMcLRXhAjQUckNm5OzgE5SjkBR1UlQ4WokbKh3xdSUsiprQgPO5BjdBRWapFg0UAVNEJlfEWYqAFL12dLUmTdfRFMWzKIo6hVAIZ4gQC8k2zBEagSThon4KkRxXtFVQNHnuVXtCaAbQ8LpU1EdVwl64odDowI3yYUbgoSAJDXYkAPyNpGR0jFEkQzSfKXKWgZOoU65ZyxXRTKZo3SuK+8Uomhw7xPdpoiI4ioHUQ5Ec9aZIaWaKsB9Dj6edMLduaKdIjFdYGrFGe8Fdio6jCDS7vJIau1lb25KK7B6BKSUVgv7PhBA/bYjbTE5BAKnGNSmOF1eUdJ2hL0HtlDRVKkRyFCWxECmITFKZbbBRMkdF7x9WiHTOtk192T7BuJAiNoHd9ImnuuTBUBCAMq2ynouLY5rGojggkDCjj4ATNMfUNTHLwj67Cz/gnmXQaI7GUhH2I/NPZdiGW0YRFPl5qWjDw0pRRu+qKIq70A0xB5izhuWQPueg15ITDa2VM+118i4USAwjLqQo5lizy/HphSJGERzBEigVsV0ED748PrsiEkcnA/AatNQuRpKkSD2bK4IOLqglKgGlIg+gfTFX4gWDqYYokiKyYKIidmVovF6mSBxH0QUxFCeX4Yoohn9KB0PR+8f9JGKJDfCzTzSOTmJ69UWqnVUWjgmY9TEHwqKRoR6twBwxiaFJ8Hq6IjV6nkVFbVasd4owIBRU5CVbSohvsUNkLfJCREXDbuxWVqEecNsdaWxwLCpFF5ooR+alokm9fxiaHCgiVLTzQxRF/oRwtOvuM0les2UEkyyJGVEkReylzVAi68s4xnUyRTKE9TFQxMcRFZsMCfe1opjvhkgVJKWMQ1NExbMqmaHIRkTrqkTTA97BW1fkwI6XI0XNHfNPTScyP6Ho2VpH1kmRHOEuLPNBrmiJ0w7PAT1AhgXCkDkaABZ2qUNFqxTZoL3BMuDgMoUVQ91PRZ5hCojfKWKvhmUeRdSSwknngqLrEwE0ARgiQ8DE0IiKdpEjRTUb3ot7KIZkqNCkNxUI5keFSQ/prKAqkCXTrbGqx5DVIQPPlBzNsdoaWZoJfmV1RR44aa0ooiJEEA1JkeGKegqJE6mTJSkaMkWoFOp5Iv4ukaJAqoyuVORhFnJF+cGdUBhhpqH5WNH4ShGRovEjO3rhlUiKgBnhljvCytKPaGfbtFl6OAbXqRBBHLAnReypWMcPEq1FM8rBp1zlcuMn7OPq5IfIURZBBBtZLbpnctLJWiqagH9qhaIUP24IM6ffKeIxauS8qB8KqrVSVB0qaldbtFYdhdLKUBkSNCRFMUtKRQoiMdr8J0UkKaqcUKXbV7qAGESUA26EYSRFwBSJPofiohk2gChIl1G+iPSjHBpY7dHRSB5N/xpF4r0lGtCQiHu/UhS7mpDu/bxXZD4oKgqSCkbRDRMliL7APTp2rXgl669i/OphW7F2ickjKaM7VqTeTMhPQZ5pd1v8SdGASb+JuiL1ZObn1vdoJsW8LKpF0vRHRdg7k4QkE03wqpx+pnQ6wCXxGPIOn8f8IYouIxQVjt6//8URNeWK1hVnzRQN8iNFN1eU8sxewwcFsVynbTeEnUpUvI8UNZgURceKbJkk0YhJslnkitpCEdnJiUs6IlGR4BlIVHT6iE5fikBghxrLxmIWAL/H7uMD7vhOr78rivgGuTHghMmlarCXhJZ9h1vZj7XklIFMM01TdQQT0Q/yUTW5wBEZXVKyxCZLM36cJlLEgjit7TMpGjCnMi1FAgMb82GyehcQSXpMQhk9bzCjUVVSpMEm/0NgC9MUiCkifNJfFVFBKknuxlqCisokwyzG5AUTxXCpb2til2rp3w55olEOFRGtWUbyHMKTMu8SHisZPwg3l9cmoiiMG3wUrXG0iTYxxUKIoPiI2ESZjUJ3FbKLEIJk5U7E4koIguhCAtWFbqJdBXGhCC4MCAnd60rUhQtx039A0IWCin7nu/fMmXEa/SZ3Gts06fzmvO65192RPCOcGZVIR4WP/Q8i+4MN0QwkZ+9kUHx25teGNMxQakJORIRzAPm8htdZUkuFa62HpiCcKUMFQimpR5kU0EREakliRaapvxCZk6VJaUSC8SgiPvGGlNH1MyKSIZet8iVjRCmgFQV8WHc2Pj9LZzQt5xKiNckTYsGxi8GZiOTfHg+GOaE42O6EDJtztUmItlMGxvKLOpxqlgUBAfm8l9mRUUi0IyCirJtmAVsZoTrCwWm/pTXLaikr8oh8tRJbP+NdByO6ieYmJWL6HyL6oiKa+geijOk/iHT5Vx3tH4gsXAsdDnkeeEaq/EREkHZWtbp2hhOLUHiOk4rltTsUEeHI8EogMnkr4okrKHv+jShR8c5SnKQ4EVEyfqUmHzm1IgABHPO0QBBBQTLzR25NRJzpKyKYkvVlslwKFvmJA9glVyL0muloEBFBO3EkMcUBeURTNCUiIh+HKGPFnynv5GoVSqyI9ziNNLWeL0E4ikWQo6PyaX+b1ZAqMVr5xLIgsnLDug5y0jmC9oFwgqwS4vWatxEQhhJSSHJAUWUE4Z02x/MZAdEc/sKTEUBFUd6REOvBmIjHrEgJRVbkROuJE2K4juazBklpl9l13HDFS9fxYoyIyVYiIAGkiMCHiOSrySyJr42aA7SkWCCKLxKSjQz2jlt9qFXJW5PiX4gowYMHZYgC8SvyCfjAM2EWNSEjse9oiGBFfmG9IEqQYvNTnU45WTSSYtq8LcllJyV8FBEzHwGBDQTHpbyTcXKvVpAnH6rYHYyhX1+C3EbhG8MCFvc5OET+t5PhmoCm1c3MkFQWsSmHqCiIEJgSS+t4qDVxCCKTIcJIVNO7YoAWRGQUR7QzhUg/yQBZCOJSRGV1vNJsrv389ii3ESOPhw+L2ERERXM0ZjRfMSYh8duUWREVa+/7XUWFGXb5rI3NEyWxSctKBmxtflgv0kUiNaCFw9hkdzi7dyfQyNBwJX1IS/cEVJiBNCnldbuLKlcfrIftsHPn6O2rhW06TbUUN+kfaoV/JX2X0SJI0xaPTIF1kOjoso6mNYCrNTbhgNKxSUVE6bzGQE1MAPTlM/T16sMt2DsVQ4RALXOPLFWAZHFcACkiJWNG0H281q61O5eWTl9+8FCDqMmsKPVNHOZojoIl/UOBNyH9YoCmaUdJRPnYZFH7VyqxqtgKssVtQ5TW4S+/hmtrP969unX1IMyM9kMJIrAR7adQ4DhAPlXrOl80ISh2Ryu1Wnvlwqn5k5evmqttiCSmeDMkt8EcLTAjkqFK+Vt+GxHl7N3ZmbGOMQOTIdqUBSBDNDWhRbRQ/vwDzoHLOn0DkDBLcShZEWXhgq1Wqy9qtQDJorQAUkQ84B2V1VEHiF6fqc6fvH19WyZaAcz8RwlELBwDZjSdfqSMyOQBeUQVIrKCkrbEjUwKyZTY/whUeEjJzYiEI5p+7F3oj1fa7fD5UrU0d+DGletThOOL6sLFt59H0BgaDVpFAHIRZut2VyRuiyuo9z6GtVr4bOlI6cCVY/GKKU8JjFQ4Misipvg0Vlgk6CSIaVCKbTAK3M4Q/RR+SbnahozM45whkREdahci0XrHXdZcqQT32ENCXPzPZvd/+TEcrjWbzU6ns7b+68v5nF0T/iKr4KgKQ1EtvLM0XzrwYHqr90TGCCcpoi3p/4UIIxGNONMnFANjqNLpHyO+Sy01VZxgR2lE3ki01Xa4/HkNd37l0tL83Fzp5LUXskTkN9pkC63BWthu1yg448+vD2flEnWqobs1DFEHL4bPlubmn7Ie9FOSYqXVEletFMkoPaUz1001QwzNIYyY3GuMke2Y1UoWIqJ/QppSpUrJnR5Rf4TLaj+/UJ0DogMPzgKRpvnC/v64WTvuBfN4/erK9WOzucSlGKHp+uoobOC9zlRLB25f9z9BgACg3mC0vj4a9FoVIkqLvmuQgkARAU5KZkX7zNcMkdVKMnbIkVQSkTso8zV0TLIu3uwtD8ZhA352An4GRjc3uWKRqf5wBUZERJSkqvkPn+4xh/FERAaqPvi4LNFaQtG1h9N554q5Yn11MG6GUHMd8SwzUdu1iCQiXYMlkJR0PqKvom86RIGblHgRz8yGiPZsZEWUQFBly59ZyUj4KJWQhjb5HWWSEvfDz9rHTbWVO/MvS5+OSfTJK6JpGQGTUHcwbNcaLhTdyumtLdb7o2HYpq92fnyu5NJoNO85RAxugRMxGBUDhFCunUgSwhFIThVEdH7ztu3/8TS/SBPN/w0QbeVwa9Rp1JbfX6gCES5sIb7HQfwsgahzp/ry5curGY3SzsSjpXeEosZio4OwhlCkOSaor44lQjk7RDhbsLkJVygxlJQ8Y4zjLzpNsCKd1EZtJHocERVZcZuzZSYgyrqRJSMi0kaS50NmhXJ/1Gw0wtfMZ3Mnn2YAKNrHUemth3Lvv39v1xyiZ9W7L0u3FuBDTu7uuXgAFnivReBG4Xjjqnc++S7s1EOGq1Yf3M8ZINcJUGKGKCjyvy65pKZKMwIeN/CU9qxWhAiYV0ZQmpBvAoCMJ7RFd3f4/jYQUYdbg+Fyo4FJ1byk/BtPZrOc7XHMtHrD9mKt/fvSnfe8SISsU6WXJQkzmmR9aSKYUBWNlxcXlzUU4Sdi+d14PGu/P1M9cOvY1nyERFZKIkJ+Kw0gVerd1dVut17X8nHjaGR7j9SKzNHyeCNrt8W8bQbiXGEGXUmdr+HkEena25RTufW4CURI08xnVxZmZUcsEWHxt/VYEIVvzpy5sNJepKMtwR1v3N+X2kcGY68jFAmiZxKKruRwTxmfemMjhGyHtHD7EWa4lCDaEa3MOsnNz1W6vRE0WO3WJWdNcDVFpCe80DlaqiPJBQVDVCyjCCnvn92h21ip7N9i27vcG8PPlp8zn5VOPgWfHZBb/in215sutiydeBMCEZ6egjteFkQE4MKBv4l1hKLlc84iTyJaB875UCotOj5Q+FoQ3TdE2xURz5zfsO3UW++EYWc46nVpR8mq2mZrqZXtII7IrEjzPreuzZT7vc+/fn19ev3sHlxpNo1Iy0mMArI6jCh0+QwBxLcPuISYr/SGIaxi5Uy1unSns3h8sbFy6dQcEeUVERXwAI1m45xYpLyTMzJYw5BGxIgWLkvmRE7IbZcba4hmyUk2CHB9LV/pI8IL0bVxv05HSlTWhmzalEKkfGhFcT9DFhpi4v5z6caVp9cfHtvD5jYO5SOESAznQqElV7WMqwIiCSAZ6zRnii2UOX/4ON+Qxus4jhf0B5OI2jidhYMRhzZrP+rOQ5AVDmK/DX20Qmt4ED1qaCoh54Z0u5o5UIp8MrMQOWR0LHzQIlOGDwo5nzRSEOSehNCDHu264M5Dj3p9Pt/f3HLVV3bb7c9vv9/r9/nz/ny+39/6COVWwA+i/j4QBQPYGoieMq1T3SkzzhGKDvL9kSEjHBfoijkRHCOSVFZIJArHx7vd3vYbLbWM9o8LvfiTId9ccoLf2p+DbAYUZ6yokdBjZxC56q6UqUfU9MzgakmbWval9mevXlmcfqV+6Wv9Ywb5bDsTieBnHDlWtGhmoJ1B2S5+xqb8DiJ1SIqUL86ZPTLitxopU1gkG8OVgN2p+YZIVOrpg+1bawkbW9y9a9MDmHishqiuBH9GGKkhYUQmfiFDd3/HZTUg1/kWjxoqfpPWaogcdX2mTuNr2tREJbd6KdzbX/5kgqmkKh5T2eoDTXv4WTEficQKWp89h59p1DxFdNAjiOhs+O1CT6QvopHkuZevvAKW+gVkqk9AFBuKDKkIffkjd50M6BMhYPtHvIGrt+/5L12dbq4iwq911C58AxmIAGsQofrvLjTXzTvW3Z/xMiM/GsJ1QynbJvFDoqLNsajvLNRkTk10O4Qkn+UjQ0n8jDfjHY9W8QDKPZi9JVaxB6KAtTMW6ZOYJYjQRU/V7bZIN+4IRZkIiBJsbOSaqUOJRGpEjnh/f/q1L25cJaHVENU3TWHEwJRQIuJnUjnPW1dBVCtp+VcdzdzOWJGjizyn87QNiGinaZ6+IMlZDloO58UnnKZ8w2UuT7T69jcznPg9y897OfUt1SXMeg1vaoMX+6VLAqK5MTl8WKIvr7nrnN/ZVQ1FWGQaogjHaX1SqGFEhDP9hsUvXIzpic5qL+Ts9ZO0fUVsNHEQF/o40UelY7rgarNqqYqncRgBay6m8dQjarQiUURLh1JrS1gFkbZ/anYDFYOI06Zvx+TyQ0N5Slh97zWho9sVRExmxMASo5zwdseHhyKEdSsgiKbP1SSR43IYUYqNDUTShCtv+ycvdsjpTsnemJwozvdis0sHF/aqInqmERGKl2BhxMZROVE42e2618l38FdrfZyNQJDhxl8NEYVeA6KHDCNMtEfqCQmrTo5SQnWFm/i/7B4ahJQ1NIBr4AXiZ9dNK8ilwzOoVjEkh+e152OCSNyXhL7Q4a7tbDWGgoiNDeQLqKL291/rkKdTpETxT411VxYgpOO0rQyi0z1zroIziMQ98XDbDthd93LUIc3/N1R/mKtoTAFydo5W09npxjUJOQeN8yy+aL7ZvMdZpVGVsp59XGkgjW340daX3m+pX//sSa3eAktesPitNfwsEpu3X0aCk9DqIpH8MTQUwVtDkXfxDZ7lqW1cVSmz/QmzXXeNkexLbY396UWobUaPSTwduX1796SSS3FCTB8SGPrQGWCpXYTF/b8jamqpQ+TDOaSQFMNWLfgtkcgJg3i+GptofPlhhSbZlUxoICO6h+G9gbCtIZKUj1XEJKoRiuRQk7TdvN5Lt30IXjMUEvc8oTwGovDGZTUUUWVhh44MQCk0ux4zRlTrhtQjIuuaayvbtDTsF92ymNqcK5U2ly56miFjhIapm/Wv1s5rbKm56hG1nCKivyNJCMM+9bMWmf5q1R+aUEYQajNN0uef593pgWhs3rIZ1s3fm134mRyG3AaXtvMDA0OleDehKEEoGhiCvD9g2w+oLhn8c+4pAPGIJ8TPeH+a0C/askMRYYca5EUGYERKyA2jekRP1BA5Fy3hCiJZyQ0jv1dE5JU2UpwHE3XUms5E6kZEdbkMl6m/9sKX2xRpEqMoNfnsRpsbJNRsOZgwvSQBiIUJK8xorOZySxuZaCiaDFrx2WRp/aTia6kt83Gn4AeidVFFXTscPWHGCtjx+b3iJqa/xMgNdkAotZTNZinKs5NDoYG8sRiSEAUJkIdENVjkuCtStDgbl1N8BlErTgYhHW16FLhn1707Wof0zD24aNTgY/85nJkqZx6t6mVN1UVOp4LHl5WdkrOtkejlkd/N/FeWvvFm5U4nwr8N29koxoZLxePjygGI0rPBRDITjaaLJ/euLbzY8pg52U+lNiajioWUH9yDFuRtO742jHTfOzmUwYyIpyOVXT04ODhcza7egncsITXsYpsEqVQWO4yIqyK3bzzscgi59eY0G//dig4VkdV9O8fkDPpxb/f3ZppI/z+UkbkIvV41thh5KoCoWam4JEPlZZ8Y3sDdQ6a/Dh9sFKmae0ont7/+/FVPbpUmKaNnLZFIclD5+XIsGgqFopl1e+TKR19/3sJplpS/HQsN6CH7yWfQSq9hbmvaYptLlKUOn9u9e+POykEmnU5n1n+7lWEjokIRTi5RdinZm8hQKdj9nEQnlxyF0HGbQdbXGs0xI1M9Si3py4JIqqJLN5YOh/tfuoDYuPcFHxYG/wlIB44miBRP0+m8vknpICKf7W8TYY3Aw4j89klpuDQ3Pz9H45i28c7NkU8+erApU0LauQkmtqKh8JEQGh8fD00Vb3qf/f77K982g4hCcjsNIg7ZH7BmMaJQZj4IIVNclsvMHLGF7u7ddSxR2CRmQZReF6cauU4owgO3Y7in2DTtIw3Wkgr4/ZyL+mtKbicft1QRweiRx+Hkc9SafelG6lAdbc26Ou1AEEZVezJhEzxVpYilGUT1FXK94Gn1cUblbNsUpSAKxGHz1lH5SBvHmCsaMJCYq1Y/5WA5ExoPHR1BSEa0aPtpTL9wrYUzzYwYfhZCCAYCxoiAECw4n73w119iTKTCLixRAefL99Mgmj3vZ6r6iw4iEaHIRDD1M45Fj0naibmVXOqimSwy6x9bTfHo/BqFD7VGQJ3vGpm4WCnGxsZK890jlL7Kx9zUorgZRPKoCtBjFs/o5QONzXzf4MZkWs52lxYfXrtA4/7C0dFY/wXTWadiFzvoM/9LBNenQuMD+WgVUckKYEXPcsJBtEQo4pC/Oh+wg+u8Q2PWnNPrZ6NwosS0X09OOZ8ugzoU+0qF4yvnyGcm3uOqqAYqV5eZL3p+iVwhM2pLz3sEkfyQFD3SVh04Gg1S34YgwsWvTnhyG6W5uYId+GTaIGpYiiJDX6hH1OSgN5ZUJ5x9+9uaoZx8ht7r6aPzPNbzVj9U+pi1t4M7FAQUTf1vje3hZzOc/mg6nw5zjJen1k1LBBUMoux2JjweiiUs21pLQ4FDDZaNEfX1vST39Ncs6yvepSP0Vz4cCm/x3RqK8DPsUI0vSIfo/QXjHYS41dIweZx+4spFl/SkBpeYoxVQnjZfZyurxltzm5MI2lKw68p1t2/wwd2bAf+ljzrrJsb0HweReBf3p8wMIkYNUc2KCNYHcuKd4oM8NDcmJeReuXwEF9Rq0DKNsbf+2lk73gnuLIcvXw7nZ8uzeXmwPKsfbBdE7ovkJ0znftxK7OGOGBFIpcPKp99SO0SgEr6TUcU7fjmUH7g8PpPEEKnhOlB3xPt8VIyP6NS+6FJEPEmywO2ln3j8wAchWVTxoJIbzFUqK7lBX+uTnZ37B5OEiyQ5f+HhVo9n4pNL7Vem8cratfnmdgYRr5wiQv2ZLr4I+FofoXXwB3wjmsHWpfTw2vCAEL354M5b2pAIBtfG5KmduGXf3bXWZ8KXw5mCZVl7URDJBzE/2qaPuT1iAoA5mr1vgjkCM1jmw2ymXO5RqyTlWLMZgRuORrnjAdHaT9vp+jmdDtlOA1m26n35GqKIwWxI0ViiZvLFhR9zx3M9w6WT443DYrG4uTLY1ul7l9owhAYNdn30Iku2H374+sTE9fo1gzr37zJETs3HYeRuqyKCTx2ip03x8eH2MnubrOYzCx7a7fHjIRFRq4Tb/gi9fJ4ik8e3Ri+Hxbv8ViEtsBKC6DnapszB7/+6HMY4QgNhdaRweodJkP4qaIgLfCu4JZSj940dKm+/ZC9p+afUDnHVbuL3dQ1FrBU9VELVObmP7mRFgQyXE3PqfYeVnO9OZXsSRPnZYNeiu7WVFU0Sm2src+WB28FVj4inmrhzENVGrftD8fHNralweIqcosq6O57UvGD7QdAj3dd4fE87GtQDGFlXITManplMyOuzsJ1Jvk4cAdGEBNWVgykO2hmQTMbhrBYYtIU4iIj3X03yphnkeTA5w9vYmk5Vd56jojR2KGeMZx6WS1rc5AB8tYpIVjT9WZHu1lH5L2SJ6JKT4zuVYiY6MD6eL8df/3OQX1skmMviQW3yuc+uKXG5ziwxcf0PIoL1D5Mz4fAkhi2IQBATLtQPWqcPjZHkY1IxGWHpP78+1ds7JZGCh3xQHkJWukHqZzM1QpD8yorP0dcYgi8iQBChd6x1OOKg1k1rdkoQbRGaYYyfSSjaCpMMUA2y1MhFzvHgZkw1kUL61FFpHt87jgmiv5zJXvrJv21mHBURSx5XPvxwJUvlJJU3egotJQMjqlJpWJbrqv6UQcPF8KDyfXMwhVmsm2YafcJ1Uq4YkRd9pEk0vpeORDSag7D7na0PekeXJVIEXk+OysPz0hkUp5C8g33UESpYQdMx4tMitiN9Ql9ddQZXFTvsvdwrXktTdrpDQxFuj4MWMOqRa80kZe0daLY4wh6J++C+eYIGQUMQwWX0O0qEAd3lUuHk4Natzcq7nmeovbX0BhLZz914CVz9TxmACCINiMhnP830jho/AxF+Fh3QrrS3az4mJXh8Po/0jmkrSf0MLltax382Odo7M2liGG7icpPya342OgUh5AItBIxIW/1YY4Q8MLvMJjQen1dEy192+YXxOX6SElU05eQAenVYEVkyW9RsUU7MH5mwZpM/LrzUd4EsCTSd7VVEDqOtRDmTzhR/+/MLNz2MyubmShaBIKMqzflruGRPrehMD9oE6/1fP2aHJz/Dz9SPCvmoybj4GfaU4Yi44xlsRV7/bmp09ANef85/flZcbv31gCKaIOUPfjM50wud3t7R0ZlMctf2B4JJjEgnify20hpOBJMf9PZqCPMrImiJn+miiOfVVXE9cgBSkoAr3osRkS00moEI6Qki7f7vremEONTipalwFVESux+KZgpdt+/QTaUqjG2uLGVXEAcXYVQbDYhYEtuIqPX5b37iQD/A1F+WpVT4GQIAoe039kRmSVBGkLuRBIyqn533ikt+ACIsALaig92e/VVw9/ZGl5eXJ5OF1wM4q/iZmiCb3lODQnqOyueE2nk2wfmB1rPt15qZzndcVQAy+/qYyBdt/5tYaCeABaJgkCxphEnC5MtE/CSZhxEOPDWVDN6nWsAQ7/6SpViTCZHixubx4eZGJedu+ldEDysiyDSOtv1vfv7gzbc//tLkM5pgW0Zo0+wRe4rej5fTVJvaaOf1mycfv937wdY74odK69PPVBWhg10g+vU9CC3f/3Lnj12r2z+CX0rHyPSxxaDEcfEzx2yxScegAoT7CWp6l4QiEP1N2dnENFZGYXhIQCPRhYMIowQTgjcZqZmmJO2iU1wYGtGFSWMoCrggTRclHQylFLUTkAHURFMSFwiWUEOMSIcIUeJUY4CEAG4wYDICLiCSWbASNIwZ/59zvoug+Hv9uxba2uee8573nO/rlRpQ5XJNSm0+10CeaSAC/CfWgEGEG9Xpv05ZntPcc/pb53jiE3PXrt24al9cx/dvQ0h772d/NUOLn89B5fRhvj58EtGxKlV0ZyON9Qn5zCDSyH/0MTvPXnmC089rbh1b7zLP+g/8eoepZ+k+Tqf9btnHJ4vJ5ypR/osiVJbDjf6yYBld/5QsfZePR+vXJF3tU7ygYCE/iUlRs0taE5EiRSQvgVm4Sp6xvo9aV8ps2yxrum5+8ikr2yB6/VmEn7WyKs/+j2g4UeRYv/EV9XVs1Om0nAQ+I6gmx77ZoUQYPUMDLatrN8eV0GlEfxdFiPXUYkdjY8e8ZeqZm/byMdVKybMBpkKtre9CSoyc/vzgK4k5fi4pyTOhZcKPjhqHlRqQpCWAcMZd7e3te1/3cz11jv0AWaLXlnoGFvKM8nhwaNdEe+yBK0oNoE5iQTys7xdJnn3NuE8Fv3wfVQLR5zWfqQ1hpbbnm6+flaXcGveKILo01upc3//u2ruaCnX7un7NxgnskzTQQO0tMcOgo8M+v6PibxAxKcodJhoT5JkZpjlG8UgDkmec9mN6bjW98tJjUqAVYfnKjRS/PjfIz1GlhNDSZ7q6xgvuqLyeQ4oapTjC0zVcpCNWhOxT2fRQ5fzsXRkk4RsbL16CMnPplRuStp0tnNOOMbIUY3WJQCSqo+VdpWiR1DNyVQW/Z+9VGf0RiF+Y5V6CyAxjacyIIq2vjpf33lqiNX7iWs3KT+xbkvHN658zu4AVKzx7Us/+IyJkG0TdC5FgfXzO73bdb/KMeqVCwDxMPPfn+F/C17YEnhXyjJgjz0DYpxlqSv4ws9vK7k2ysNGYULbB5LHetvmSmZfx2hQCzpGiSH19hz7Pc/MHQYQ0g4h2jHaV+oqadZCG6q0ZY+qanbp9V9u373yFslETX3vpccbdeLdeFkt0pOy4+QMSx9V1dI2InolarP8ofopSKE2mcVQr40UlMrj/8/FXX/wsFET3haYOI15vZPao+fBTYYxjIUgGENXW1k7Tbmj/dmFiMdHYGEkTJlR/+aiz0JKf9BaxAEnSQg3eIk5d1UX3NXz8FVj6GY5RK2t0nDuKFPG8ebEKnp+W5HxWQrQH08AuYqRREHFJmGSDiBKwxLgPYalj88ybek75Qo7F3pa/vEe50xhz3PxwTC2Io63im02u7thVZ9OPz5kdKis/foJiKaI3ilR7/nicBZHI9dlTUYRYb28FvcHUhFalMsmzS3pVITAqdedWDcaFRwwI8kwiR4oRqjUteWZKPvvJuT20JG296Jo+1FZSJIOoxx6V4EeK3DRmoqGt5Gd9ZIZfIs8OUbYIryGjFOGBWqPlOAKr6qGedroP3Oim5qeMRi6/JdNRRKZVhZ/v53QRV7qUCyJ5JgnguVKRQ5UGEO5WtolJELm/f/MdO56+Hyk4jYhDEVWcRkSTv5AJeuPLXHdBRHKhwBEuIaZntkMsYs0tapSdZ2WaZ974tF/ybCKVqA9KyVceIyVnz2lxVP8gETlZcg6zrX2udGBVjvfHHnsUyzI61mgEn/KIsnHOa0hWFYlLnFokrhoRcPHWtxFXbDMhV2WZjZr3lixxYkA+h5oonOeKxKku6TkODkEkl2y4YVsEtb8VRE8zoLjqjF7GfT4niBj35/0PRCy1hqa24r4geaZiLMkFopSdZ+hy52hTZ8dFoy7Iy4X13bg3KBGAas1EgEu+HO3Buq+yezHjJcZUncp7LudVNOTMDIFEgjm9K6JWw1VQCStDijZtORPTcFvRPQWVL04BzcRpedfDDN/PNbxzKLn6maPK0/YtuIyciVWjq3RNvvhJpyBikCWIBHdPb8OSaYwYBJpZ9ssjINJO0dqvLpDFH/OXbJ8wi98guvc0Im0+FrZ8AV/fIJ+Bo8qa6IMLTkeCpA9dvlWTHmu8mMD9SpC53Df6QCSRg2rNJwwts9fR6FrCWx+ftrBEIkUF5BnNBFZFlshE28RONE0LA0XrOdgR28C5vII46crr7xCI9fqfQKaCiMa/3zYdnuE3DaJXjFWDfLT3xc1OaD1V41jRiEyBqP36UkqF2/lZv7j5VscVEHUKoqvWZKm9fcsg0gXpf0B0H74x6QvEli0LIyOd+2xHIx/b5FlEUs45+7xcZ0vHHRf8u8kgeQZQrHUKEetDxMx+LRBdzxJXRvo5rhTn0f6JniFFZSJz/TJyaWpdJs94DxHwg0Nb/HmFcRm3V2qu1mvJdF0RREgR+SnTErrAF4koOlyqLONuxnCeHuq7KBwiTdJqRDpeHu9e6tOiaBAxG2xn91Sn2k8HiNjAaB+6GUgPNkKfQlSok6LtrVggEFxOD/otDLHVspzwJrgQ9GecNgY7B53TIsDXrCpB5B5cjAeDcWHwgJWGB6pkd/nc6FN1zVCTzbFYtIqpw+dNvyolf1ZqMlLUF6znlyzkh08VrE+Y87aHdWuSjYi3cEUn80i9BlvOcEXRvbc2x8BM1zgHNYadnq5x+TEBVecwSftCi6Pr/FQ2Ui/CXfMF1kCWq8aLGjTRsEWXRYoKTx8aRWakdhITQZRprn0y4P3ll+Xl+ZkJ/wQfWxOFlMsEgxAgVo4F2D2xqgwsybPpuNebFFrKA0SaZ97goin5PeN5pQ3bi6bIkFTMlrATnL+CyUgsYxaRomxfUC+JbRwZL4paU+8UUTuImB0cytiO2TaBBiJGcXNNMrSUIYynLfTOodb3Osf6piYtNT/0zWGkvhH73nRNRhSfWS+P018/ZTbojBeVmk3UR/cAtO+N9NeICiumdpIgerK2tjkcTm6tpm/ZYiwplwjK6SCI7HQiV9IRnzdG+XNJnsWhlTYt7MsflNxVGsI/8OnnLYCIFOWVXs+hCfho4YgUaatRw3to9CmiiH0O5CIGyABZRc7UEqD3skLdkNMWJQ0i1Hpz7JIUSObBOgugoG1/NSDDpTqHJm3HjOW+EuLKkMujTnVP/VetrjcqX6XPkynY+htFhg8k/hURYlW5nR1qrjUHlLbSv8S8Prmo5Nli0BtLDVozGe+R4hAI80mfTyNHo0xpma83PHKm9LzJMxNx2L7iO5CiFK2GtBeCV6dSrS3LINJcdSFFci6XBF8lI2QQpUDEG0qHNlKUJ8YxZcZvVeXDDa8eDpC4X2BEzJzKNUzxwuCScysHi5QP0bXJ0LZaCWyR9oSjjraRSl1FpwbefKNAF8lgIlyOb+6gRd9GdETpLK5oe2FjKBZubm4WRM3LMwmfL7Zr8kziZdrCQSuiugdYbXX7F2M+XyatLex8nN+dFrtUplvaSiVrfVruXCCKvldSWoEm2K0GTJF/hihIEaGWSZOrDA1WQRTh9WQ/k0H09iE/Vivr6TGIsiACMxWu90UTURQ0k78UNNRaZ6AUNBGByIQVbefKJMQ3OK/2G0TD1aw6qE0QW3QWuVY8isgwKjyJSAPJcKJMd09lsxuKiVS7Ne3z+UyeWcQLp4ooABVn9CPW1yYyMV8s1eIWKVoWWr+X/Pz886HcVjwQiC9bdHtMNt4oPN+QW7XbC/XinPOx0vGgcFQpIuzsc/SeQsMGwakkiOwoqr6NwfP17Jg0ujJ8an9xqU+TtWnOmEQP7ceSFgEK2g995sUo"
			This.PicInScript .= "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"
			This.PicInScript .= "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"
			}
			Default: ; "*" White graphic for Monitor selection
			{
			VarSetCapacity(This.PicInScript, 348 << !!A_IsUnicode)
			This.PicInScript := "iVBORw0KGgoAAAANSUhEUgAAAH0AAAB9CAIAAAAA4vtyAAAACXBIWXMAAA7EAAAOxAGVKw4bAAAAt0lEQVR42u3QAQkAAAgDMLV/59tCELYI6yTFuVHg3TvevePdO96949073r17x7t3vHvHu3e8e8e7d+94945373j3jnfvePeOd+/e8e4d797x7h3v3vHu3TvevePdO96949073r17x7t3vHvHu3e8e8e7d7x7945373j3jnfvePeOd+/e8e4d797x7h3v3vHu3TvevePdO96949073r3j3bt3vHvHu3e8e8e7d7x7945373j3jvenFh1/A/fWM3mhAAAAAElFTkSuQmCC"
			}

			}


			if ((This.hIcon := This.b64Decode(This.PicInScript))) ; Reqires "HICON:*" for Gui, Add, Picture
			This.vImgType := 1
			else
			{
			; Then try the fallback
			This.imagePath := ""
			This.vImgType := 0
			}
		}
		else
		{
			if (fileExist(This.imagePath))
			{
			spr := This.imagePath

				if (This.vImgType)
				{
					if (This.imagePath == A_AhkPath)
					{
						if (!(This.hIcon := LoadPicture(A_AhkPath, ((vToggle)? "Icon2 ": ""), spr)))
						{
						msgbox, 8208, LoadPicture, Problem loading AHK icon!
						return "error"
						}
					}
					else
					{
						if (!(This.hIcon := LoadPicture(spr, , spr))) ; must use 3rd parm or bitmap handle returned!
						{
						msgbox, 8208, LoadPicture, Problem loading icon!
						return "error"
						}
					}
				}
				else
				{
					if (!(This.hBitmap := LoadPicture(spr)))
					{
					msgbox, 8208, LoadPicture, Problem loading picture!
					return "error"
					}
				}
			}
			else
			This.imagePath := ""
		}
	}
	else
	This.DeleteHandles()

	if (!(This.hBitmap || This.hIcon))
	{
		if (This.ImageName)
		{
		SplitPath % This.imagePath, spr
		This.ImageName := spr
		}

		if (This.imageUrl && RegExMatch(This.imageUrl, "^(https?://|www\.)[a-zA-Z0-9\-\.]+\.[a-zA-Z]{2,3}(/\S*)?$"))
		{
			if (!(This.ImageName))
			{
			SplitPath % This.imageUrl, spr
				if (InStr(spr, ":"))
				{
				msgbox, 8208, Image Url, Name contains a colon, thus not a valid image target!
				return "error"
				}
				else
				This.ImageName := spr
			}
			;  check if file D/L'd previously
			for key, value in % This.downloadedUrlNames
			{
				if (This.imageUrl == value)
				{
					if (fileExist(key))
					{
						Try
						{
							if (key != This.ImageName)
							FileCopy, %key%, % This.ImageName
						Break
						}
						Catch e
						{
						msgbox, 8208, FileCopy, % key . " could not be copied with error: " . e
						return "error"
						}
					}
				}
			}

		; Proceed to download
			if (!fileExist(This.ImageName))
			{
				if (!(This.DownloadFile(This.imageUrl, This.ImageName)))
				return "error"
			}

			if (This.hBitmap := LoadPicture(This.ImageName))
			{
			This.vImgType := 0
			spr := This.ImageName

			This.downloadedPathNames.Push(spr) 
			This.downloadedUrlNames(spr) := This.imageUrl
			}
			else
			{
			msgbox, 8208, LoadPicture, Format of bitmap not recognized!
			FileDelete, % This.ImageName
			return "error"
			}

		}
		else
		spr := 1		


	; "Neverfail" default 
		if (!This.hBitmap)
		{
			if (This.hIcon := LoadPicture(A_AhkPath, ((vToggle)? "Icon2 ": ""), spr))
			This.vImgType := 1
			else
			{
			msgbox, 8208, LoadPicture, Format of icon/cursor not recognized!
			return "error"
			}
		}
	}

	Switch This.vImgType
	{
		case 0:
		{
		bm := []
		spr := (A_PtrSize == 8)? 32: 24
		VarSetCapacity(bm, spr, 0) ;tagBitmap (24: 20) PLUS pointer ref to pBitmap 

			if (!(DllCall("GetObject", "Ptr", This.hBitmap, "uInt", spr, "Ptr", &bm)))
			{
			msgbox, 8208, GetObject hBitmap, Object could not be retrieved!
			VarSetCapacity(bm, 0)
			return "error"
			}

		spr := NumGet(bm, 4, "Int")
		spr1 := NumGet(bm, 8, "Int")
		}
		case 1, 2:
		{
			if (InStr(This.imagePath, "*"))
			{
			; Just get header info
			bm := subStr(This.PicInScript, 1, 100)
			;https://www.autohotkey.com/boards/viewtopic.php?f=6&t=36455&p=168124#p168124

			; CRYPT_STRING_BASE64 := 0x00000001
				if !DllCall("Crypt32.dll\CryptStringToBinary", "Ptr", &bm, "UInt", 0, "UInt", 0x00000001, "Ptr", 0, "UInt*", DecLen, "Ptr", 0, "Ptr", 0)
				return "error"
			VarSetCapacity(spr1, 128), VarSetCapacity(spr1, 0), VarSetCapacity(spr1, DecLen, 0)
				If !DllCall("Crypt32.dll\CryptStringToBinary", "Ptr", &bm, "UInt", 0, "UInt", 0x01, "Ptr", &spr1, "UInt*", DecLen, "Ptr", 0, "Ptr", 0)
				return "error"

			FileAppend , , spr.bin
			tmp := FileOpen("spr.bin", "w")
				if (tmp == 0)
				return "error"
				if (!tmp.RawWrite(&spr1, Declen))
				return "error"
			tmp.Close
			tmp := FileOpen("spr.bin", "r")
			bm := ""
			VarSetCapacity(bm, 24)
				if (!tmp.RawRead(bm, 24))
				return "error"

			VarSetCapacity(spr1, 0)
			tmp.Close
			FileDelete, spr.bin

			spr := This.BinToHex(&bm + 16, 4, "0x")
			spr1 := This.BinToHex(&bm + 20, 4, "0x")

			spr := This.ToBase(spr, 10)
			spr1 := This.ToBase(spr1, 10)
			}
			else
			{
			tmp := (A_PtrSize == 8)? 104: 84, 0
			Ptr := A_PtrSize ? "Ptr" : "UInt"
			; https://www.autohotkey.com/boards/viewtopic.php?t=36733
			; easier way to get icon dimensions is use default SM_CXICON, SM_CYICON

			; 16 NOT 12 because of the 64 bit boundaries- thus there is padding.
			VarSetCapacity(ICONINFO, 16 + 2 * A_PtrSize, 0) ; ICONINFO Structure

				if (DllCall("GetIconInfo", Ptr, This.hIcon, Ptr, &ICONINFO))
				{
					if (ICONINFOhbmMask := NumGet(ICONINFO, 8 + A_PtrSize, Ptr))
					{
					VarSetCapacity(bm, tmp, 0) ; hbmMask dibsection

					DllCall("GetObject", Ptr, ICONINFOhbmMask, "Int", tmp, Ptr, &bm)
					spr := NumGet(bm, 4, "UInt")

						; Check for the hbmColor colour plane
						if (ICONINFOhbmColor := NumGet(ICONINFO, 8 + 2 * A_PtrSize, Ptr))
						spr1 := NumGet(bm, 8, "UInt")
						else ; The following has the effect of reducing the icon size by exactly half- is that wanted?
						spr1 := NumGet(bm, 8, "UInt")/2

					This.deleteObject(ICONINFOhbmMask)

						if (ICONINFOhbmColor)
						This.deleteObject(ICONINFOhbmColor)
					}
					else
					{
					msgbox, 8208, hbmMask, Icon info could not be retrieved!
					VarSetCapacity(bm, 0)
					return "error"
					}

				}
				else
				; The fastest way to convert a hBITMAP to hICON is to add it to a hIML and retrieve it back as a hICON with COMCTL32\ImageList_GetIcon()
				{
				msgbox, 8208, GetIconInfo, Icon info could not be retrieved!
				VarSetCapacity(bm, 0)
				return "error"
				}
				
			VarSetCapacity(ICONINFO, 0)
			}
		VarSetCapacity(bm, 0)
		}
	}

	This.actualVImgW := spr
	This.actualVImgH := spr1
	return 1
	}

	PaintDC()
	{
	;===============
	static IMAGE_BITMAP := 0, SRCCOPY = 0x00CC0020
	hBitmapOld := 0
	;draw bitmap/icon onto GUI & call GetDC every paint

	This.hDCWin := DllCall("user32\GetDC", "Ptr", This.hWndSaved[This.instance], "Ptr")

		Switch This.vImgType
		{
			case 0:
			{
				if (!(hDCCompat := DllCall("gdi32\CreateCompatibleDC", "Ptr", This.hDCWin, "Ptr")))
				msgbox, 8208, Compat DC, DC could not be created!
				if (hBitmapOld := This.SelectObject(hDCCompat, This.hBitmap, "Bitmap"))
				{
					if (This.oldVImgW || This.oldVImgH || (This.actualVImgW != This.vImgW) || (This.actualVImgH != This.vImgH))
					{
						if (!DllCall("gdi32\StretchBlt", "Ptr", This.hDCWin, "Int", This.vImgX, "Int", This.vImgY, "Int", This.vImgW, "Int", This.vImgH, "Ptr", hDCCompat, "Int", 0, "Int", 0, "Int", This.actualVImgW, "Int", This.actualVImgH, "UInt", SRCCOPY))
						msgbox, 8208, PaintDC, BitBlt Failed!
					}
					else
					{
						if (!DllCall("gdi32\BitBlt", "Ptr", This.hDCWin, "Int", This.vImgX, "Int", This.vImgY, "Int", This.vImgW, "Int", This.vImgH, "Ptr", hDCCompat, "Int", 0, "Int", 0, "UInt", SRCCOPY))
						msgbox, 8208, PaintDC, BitBlt Failed!
					}

				This.SelectObject(hDCCompat, hBitmapOld, "Old Bitmap")
				}

				if (!(DllCall("gdi32\DeleteDC", "Ptr", hDCCompat)))
				msgbox, 8208, Compat DC, DC could not be deleted!

			}
			case 1, 2: ;IMAGE_ICON := 1, IMAGE_CURSOR := 1
			{
			DllCall("user32\DrawIconEx", "Ptr", This.hDCWin, "Int", This.vImgX, "Int", This.vImgY, "Ptr", This.hIcon, "Int", This.vImgW, "Int", This.vImgH, "UInt", 0, "Ptr", 0, "UInt", 0x3) ;DI_NORMAL := 0x3
				/*
				; DllCall("gdi32\DestroyIcon", "Ptr", This.hIcon) fails for AHK executable
				; AHK LoadImage does not use LR_SHARED
				; Consider above only if creating or copying an icon- whereas the following is ignored
				if (!(DllCall("gdi32\DeleteObject", "Ptr", This.hIcon)))
				msgbox, 8208, Icon Handle, Handle could not be deleted!
				*/
			}
		}
		This.releaseDC(This.hWndSaved[This.instance], This.hDCWin)
	}

	DrawBackground()
	{
		; for custom see  https://docs.microsoft.com/en-us/windows/win32/gdi/drawing-a-custom-window-background
		DllCall("gdi32\ExcludeClipRect", "Ptr", This.hDCWin, "Int", This.vImgX, "Int", This.vImgY, "Int", This.vImgX+This.vImgW, "Int", This.vImgY+This.vImgH)

		;SelectClipRgn not required
		; one pixel region
		hRgn := []
		hRgn := DllCall("gdi32\CreateRectRgn", "Int", 0, "Int", 0, "Int", 1, "Int", 1, "Ptr")
		; Updates hRgn to define the clipping region in This.hDCWin: turns out to be everything except the margins.
		DllCall("gdi32\GetClipRgn", "Ptr", This.hDCWin, "Ptr", hRgn)
		hBrush := DllCall("user32\GetSysColorBrush", "Int", 15, "Ptr") ;COLOR_BTNFACE := 15
		DllCall("gdi32\FillRgn", "Ptr", This.hDCWin, "Ptr", hRgn, "Ptr", hBrush)
		This.deleteObject(hRgn)
	}	

	ProcImgWHVal(value, height := 0)
	{
	retval := 0
		if (height)
		{
		dim := This.vImgH
		screenDim := A_ScreenHeight
		actualDim := This.actualVImgH
		}
		else
		{
		dim := This.vImgW
		screenDim := A_ScreenWidth
		actualDim := This.actualVImgW
		}

		if value is number
		{
			if (value > 10)
			{
			oldDim := dim
			retval := Floor(value)
			}
			else
			{

				if (value > 0)
				{
				oldDim := dim
				retval := Floor(value * actualDim)
				}
				else
				{
					if (value < 0 && value > -10)
					{
					oldDim := dim
					retval := -Floor(value * screenDim)
					}
					else
					retval := 0
				}
			}
		}

		if (height)
		This.oldVImgH := oldDim
		else
		This.oldVImgW := oldDim

	return retVal
	}


	GetPosProc(splashyInst, currVPos, init)
	{
		if (init)
		{
		; Init only! Position is never preserved, so rely on GuiGetPos
			if (This.vPosX == "c")
			This.vPosX := ""
			if (This.vPosY == "c")
			This.vPosY := ""
		}
		else
		{
		pointGet := This.GuiGetPos(This.hWnd(), 1)

			if (currVPos.x == "")
			{
			; arguably faster than type check
			if (This.vPosX == "" || This.vPosX == "l" || This.vPosX == "c"|| This.vPosX == "zero")
				currVPos.x := pointGet.x
				else
				currVPos.x := This.vPosX
			}

			if (currVPos.y == "")
			{
				if (This.vPosY == "" || This.vPosY == "l" || This.vPosY == "c" || This.vPosY == "zero")
				currVPos.y := pointGet.y
				else
				currVPos.y := This.vPosY
			}

		pointGet := ""
		}
	return currVPos
	}


	GuiGetPos(thisHWnd, hWndPos := 0)
	{
	static HWND_DESKTOP := 0, parentStat := 0

		if (hWndPos)
		{
			if (This.parent)
			parentHWnd := This.parentHWnd
			else
			parentHWnd := HWND_DESKTOP
		}

	VarSetCapacity(rect, 16, 0)

		if (DllCall("GetWindowRect", "Ptr", thisHWnd, "Ptr", &rect))
		{

		x := NumGet(rect, 0, "int")
		y := NumGet(rect, 4, "int")

			if (!hWndPos)
			{
			w := NumGet(rect, 8, "int")
			w := w - x

			h := NumGet(rect, 12, "int")
			h := h - y

			VarSetCapacity(rect, 0)
			return {w: w, h: h}
			}

		VarSetCapacity(point, 8, 0)

		NumPut(x, point, 0, "Int"), NumPut(y, point, 4, "Int")

			if (parentHWnd)
			{
				if (!DllCall("user32\ScreenToClient", "Ptr", parentHWnd, "Ptr", &point, "int"))
				return 0

				;if (!(DllCall("User32.dll\MapWindowPoints", "Ptr", HWND_DESKTOP, "Ptr", parentHWnd, "Ptr", &point, "UInt", 1)))
				;return 0
			}
			else
			{
				if (parentStat != parentHWnd)
				{
				if !DllCall("user32\ClientToScreen", "Ptr", parentStat, "Ptr", &point, "int")
				return 0
				}
			}
			
		x := NumGet(point, 0, "Int"), y := NumGet(point, 4, "Int")

		VarSetCapacity(point, 0)
		}
		else
		return 0

	VarSetCapacity(rect, 0)
	parentStat := parentHWnd

	return {x: x, y: y}
	}


	TransPosVal(vPos, parentDim, winDim)
	{
		if (vPos == "c")
		{
			if (winDim < parentDim)
			vPos := (parentDim - winDim)/2
			else
			vPos := 0
		}
		else
		{
			if (vPos == "zero")
			vPos := 0
			else
			if (vPos == "l")
			vPos := ""
		}
	return vPos
	}

	GetPosVal(vPosX, vPosY, currVPos, parentDimW, parentDimH, winDimW, winDimH, parentHWnd)
	{

	vPosXIn := vPosX
	vPosYIn := vPosY
	vPosX := This.TransPosVal(vPosX, parentDimW, winDimW)
	vPosY := This.TransPosVal(vPosY, parentDimH, winDimH)

		if (vPosX == "")
		{
			if (vPosY == "")
			return {x: currVPos.x, y: currVPos.y}
			else
			vPosXNew := (currVPos.x)?currVPos.x:0
		}
		else
		vPosXNew := vPosX

		if (vPosY == "")
		vPosYNew := (currVPos.y)?currVPos.y:0
		else
		vPosYNew := vPosY
	
		if (parentHWnd)
		{
		VarSetCapacity(point, 8, 0)
		NumPut(vPosXNew, point, 0, "Int")
		NumPut(vPosYNew, point, 4, "Int")

			if !DllCall("user32\ScreenToClient", "Ptr", parentHWnd, "Ptr", &point, "int")
			return 0

			if (vPosXIn == "c")
			{
			parentPoint := This.GuiGetPos(parentHWnd, 1)
			vPosXNew := vPosX + parentPoint.x
			}
			else
			vPosXNew := NumGet(point, 0, "Int")

			if (vPosYIn == "c")
			{
				if (parentPoint.x == "")
				parentPoint := This.GuiGetPos(parentHWnd, 1)
			vPosYNew := vPosY + parentPoint.y
			}
			else
			vPosYNew := NumGet(point, 4, "Int")

		VarSetCapacity(point, 0)

			if (vPosXNew < 0)
			vPosXNew := 0
			else
			{
				if (vPosXNew > parentDimW)
				vPosXNew := parentDimW - winDimW
			}
			if (vPosYNew < 0)
			vPosYNew := 0
			else
			{
				if (vPosYNew > parentDimH)
				vPosYNew := parentDimH - winDimH
			}
		}

	return {x: (vPosX == "")? currVPos.x: vPosXNew, y: (vPosY == "")? currVPos.y : vPosYNew}

	}


	DoText(splashyInst, hWnd, text, ByRef currVPos, parentW, parentH, ByRef currSplashyInstW, currSplashyInstH, init, sub := 0)
	{
	static SS_Center := 0X1, SWP_SHOWWINDOW := 0x0040, mainTextSize := [], subTextSize := []
	static oldSubBkgdColour := 0, oldMainBkgdColour := 0
	init := 0

		if (text == "")
		{
			if (hWnd)
			{
			GuiControl, %splashyInst%: Hide, %hWnd%

				if (sub)
				subTextSize := ""
				else
				mainTextSize := ""
			}

		return 0
		}
		else
		{
		; Note default font styles for main & sub differ
			if (sub)
			Gui, %splashyInst%: Font, % "norm s" . This.subFontSize . " w" . This.subFontWeight . " q" . This.subFontQuality . This.subFontItalic . This.subFontStrike . This.subFontUnderline, % This.subFontName
			else
			Gui, %splashyInst%: Font, % "norm s" . This.mainFontSize . " w" . This.mainFontWeight . " q" . This.mainFontQuality . This.mainFontItalic . This.mainFontStrike . This.mainFontUnderline, % This.mainFontName

			if (hWnd)
			{
			GuiControl, %splashyInst%: Text, %hWnd%, % text
			GuiControl, %splashyInst%: Font, %hWnd%
			}
			else
			{
			init := 1
			Gui, %splashyInst%: Add, Text, % "X0 W" . This.vImgW . " Y" . (sub?currSplashyInstH:This.vMgnY) . " HWND" . "hWnd", % text

				if (sub)
				This.subTextHWnd[This.instance] := hWnd
				else
				This.mainTextHWnd[This.instance] := hWnd
			}


			if (sub)
			subTextSize := This.Text_Dims(text, hWnd)
			else
			mainTextSize := This.Text_Dims(text, hWnd)



			if (This.vImgTxtSize)
			{
				; Not so precise- otherwise very fiddly
				if (sub)
				{
					if (!(This.mainTextHWnd[This.instance] && mainTextSize[1] > subTextSize[1]))
					{
					currSplashyInstW += subTextSize[1] - This.vImgW
					This.vImgW := subTextSize[1]
					This.inputVImgW := ""
					}
				}
				else
				{
					if (!(This.subTextHWnd[This.instance] && subTextSize[1] > mainTextSize[1]))
					{
					currSplashyInstW += mainTextSize[1] - This.vImgW
					This.vImgW := mainTextSize[1]
					This.inputVImgW := ""
					}
				}
			}

			if (This.transCol)
			{
				if (sub)
				{
				oldSubBkgdColour := This.subBkgdColour
				This.subBkgdColour := This.bkgdColour
				}
				else
				{
				oldMainBkgdColour := This.MainBkgdColour
				This.MainBkgdColour := This.bkgdColour
				}
			}
			else
			{
				if (sub && oldSubBkgdColour)
				{
				This.subBkgdColour := oldSubBkgdColour
				oldSubBkgdColour := 0
				}
				else
				{
					if (!sub && oldMainBkgdColour)
					{
					This.MainBkgdColour := oldMainBkgdColour
					oldMainBkgdColour := 0
					}
				}
			}

			if (This.Parent)
			{
			; vMgnx, vMgnY not applicable here
 			This.Setparent(1, (sub?"":hWnd), (sub?hWnd:""))

				if (currVPos.x == "")
				{
				currVPos := This.GetPosVal(This.vPosX, This.vPosY, currVPos, parentW, parentH, currSplashyInstW, currSplashyInstH, This.parentHWnd)

				; Init only! Position is never preserved, so rely on GuiGetPos
					if (init)
					currVPos := This.GetPosProc(splashyInst, currVPos, 1)
				}

;			;Margins not required!
			WinSet, Style, +%SS_Center%, ahk_id %hWnd%

			WinMove ahk_id %hWnd%, , % currVPos.x + This.vMgnX, % currVPos.y + (sub?currSplashyInstH:0), % This.vImgW, % sub?subTextSize[2]:mainTextSize[2]
			;DllCall("SetWindowPos", "UInt", hWnd, "UInt", 0, "Int", This.currVPos.x, "Int", This.currVPos.y, "Int", This.vImgW, "Int", mainTextSize[2], "UInt", 0x0004)

			WinSet, AlwaysOnTop, 1, ahk_id %hWnd%

			WinShow, ahk_id %hWnd%
			}
			else
			{
			; Remove and set the style first- done so the text can be centred within the margins.
			WinSet, Style, -%SS_Center%, ahk_id %hWnd%
			DllCall("SetWindowPos", "Ptr", hWnd, "Ptr", 0, "Int", 0, "Int", 0,"Int", 0,"Int", 0,"UInt", SWP_SHOWWINDOW)

				if (sub)
				{
				This.Setparent(0, , hWnd)
					if (This.subBkgdColour == This.bkgdColour)
					{
					spr := This.vImgW - subTextSize[1] + 2 * This.vMgnX
					spr := (spr > 0)?((This.vImgTxtSize)? 0: spr/2): 0
					}
					else	; colours won't cover all the region after the move
					spr := This.vMgnX

				GuiControl, %splashyInst%: Move, %hWnd%, % "X" . spr . " Y" . currSplashyInstH . " W" . This.vImgW . " H" . subTextSize[2]
				}
				else
				{
				This.Setparent(0, hWnd)

					if (This.mainBkgdColour == This.bkgdColour)
					{
					spr := This.vImgW - mainTextSize[1] + 2 * This.vMgnX
					spr := (spr > 0)?((This.vImgTxtSize)? 0: spr/2): 0
					}
					else
					spr := This.vMgnX

				GuiControl, %splashyInst%: Move, %hWnd%, % "X" . spr . " Y0" . " W" . This.vImgW . " H" . mainTextSize[2]
				}
			GuiControl, %splashyInst%: Show, %hWnd% ; in case of previously hidden
			}

			GuiControl, %splashyInst%: Font, %hWnd%

			

			;ControlSetText, , %mainText%, % "ahk_id" . hWnd
			; This sends more paint messages to parent
			;ControlMove, , % This.vMgnX, % This.vMgnY, This.vImgW , Text_Dims(mainText, hWnd), % "ahk_id" . hWnd


		This.SubClassTextCtl(hWnd)
		return % (sub)?subTextSize[2]:mainTextSize[2]
		}

	}


	CheckParentStat(exiting := 0)
	{
	Static parentChangedSub := 0, parentChangedMain := 0, SWP_SHOWWINDOW := 0x0040, SWP_ASYNCWINDOWPOS := 0x4000

		if (This.parent)
		{
			if (This.mainText != "")
			{
				if (parentChangedMain <= 0)
				{

				This.SetParent(exiting, 0)
				spr := This.mainTextHWnd[This.Instance]
				; All positional changes and paints to the window are not processed during the modal loop
				; Only hope is for a timer.

				; DllCall("SetWindowPos", "Ptr", spr, "Ptr", 2 * This.vMgnX, "Int", 0, "Int", This.vImgw + 2 * This.vMgnX, "Int", 40, "Int", 0, "UInt", SWP_SHOWWINDOW & SWP_ASYNCWINDOWPOS)
				; WinShow, ahk_id . %spr%
					if (exiting)
					{
					WinSet, Style, -%SS_Center%, "ahk_id" . %spr%
					parentChangedMain := 1
					;WinSet, Redraw ,, ahk_id %spr%
					}
					else
					{
					WinSet, Style, +%SS_Center%, "ahk_id" %spr%
					parentChangedMain := -1
					}
				}
			}
			if (This.subText != "")
			{
				if (parentChangedSub <= 0)
				{

				This.SetParent(exiting, , 0)
				spr := This.subTextHWnd[This.Instance]

					if (exiting)
					{
					WinSet, Style, -%SS_Center%, "ahk_id" . %spr%
					parentChangedSub := 1
					;WinSet, Redraw ,, ahk_id %spr%
					}
					else
					{
					WinSet, Style, +%SS_Center%, "ahk_id" %spr%
					parentChangedSub := -1
					}
				}

			}

		}
		else
		{
		parentChangedSub := 0
		parentChangedMain := 0
		}
	}


	SetParent(parentSetStatus, mainHWndIn := "", subHWndIn := "")
	{
	Static lastParentStatusMain := 0, lastParentStatusSub := 0, mainHWnd := 0, subHWnd := 0

		if (mainHWndIn != "")
		{
			if (lastParentStatusMain == parentSetStatus)
			return
		}
		else
		{
			if (subHWndIn != "")
			{
				if (lastParentStatusSub == parentSetStatus)
				return
			}
		}

		if (mainHWndIn)
		hWnd := mainHWnd := mainHWndIn
		else
		{
			if (subHWndIn)
			hWnd := subHWnd := subHWndIn
			else
			{
				if (mainHWndIn == 0)
				hWnd := mainHWnd
				else
				hWnd := subHWnd
			}
		}

		if (parentSetStatus)
		{
			if (DllCall("SetParent", "Ptr", hWnd, "Ptr", This.parentHWnd) != This.hWnd())
			msgbox, 8192, SetParent, Cannot set parent for control!
		}
		else
		{
			if (DllCall("SetParent", "Ptr", hWnd, "Ptr", This.hWnd()) != This.parentHWnd)
			msgbox, 8192, SetParent, Cannot set Splashy as parent for control!
		}

		if (mainHWndIn != "")
		lastParentStatusMain := parentSetStatus
		else
		{
			if (subHWndIn != "")
			lastParentStatusSub := parentSetStatus
		}

	}

	SetParentFlag()
	{
	Static WS_CLIPCHILDREN := 0x02000000
	DetectHiddenWindows, On

	spr := WinExist()
	; AutoHotkeyGui when SplashyTest launches this from a gui thread
	WinGet, WindowList, List , ahk_class AutoHotkeyGUI

	DetectHiddenWindows, Off

		Loop %WindowList%
		{
			if (spr == WindowList%A_Index%)
			{
			; Get clip style
			Winget, spr1, Style, ahk_id %spr%
				if (spr1 & WS_CLIPCHILDREN)
				This.parentClip := WS_CLIPCHILDREN
				else
				This.parentClip := 0
			return spr
			}
		}
	return "Error"
	}

	Text_Dims(Text, hWnd)
	{
	Static WM_GETFONT := 0x0031
	FontSize := [], hDCScreen := 0, outSize := [0, 0]
	;https://www.autohotkey.com/boards/viewtopic.php?f=76&t=9130&p=50713#p50713

	StrReplace(Text, "`r`n", "`r`n", spr1)
	StrReplace(Text, "`n", "`n", spr2)
	spr1 += spr2 + 1

	spr2 := "" ; get longest of multiline
		loop, Parse, Text, `n, `r
		{
		if (StrLen(A_Loopfield)) > StrLen(spr2)
		spr2 := A_Loopfield
		}

	HFONT := DllCall("User32.dll\SendMessage", "Ptr", hWnd, "Int", WM_GETFONT, "Ptr", 0, "Ptr", 0)

	hDCScreen := DllCall("user32\GetDC", "Ptr", 0, "Ptr")

		if (HFONT_OLD := This.SelectObject(hDCScreen, HFONT, "Font"))
		{

		VarSetCapacity(FontSize, 8)
		DllCall("GetTextExtentPoint32", "UPtr", hDCScreen, "Str", spr2, "Int", StrLen(spr2), "UPtr", &FontSize)
		outSize[1] := NumGet(FontSize, 0, "UInt")
		DllCall("GetTextExtentPoint32", "UPtr", hDCScreen, "Str", Text, "Int", StrLen(Text), "UPtr", &FontSize)
		outSize[2] := NumGet(FontSize, 4, "UInt") * spr1

		; clean up

		This.SelectObject(hDCScreen, HFONT_OLD, "Old Font")
		; If not created, DeleteObject NOT required for This HFONT

		This.releaseDC(0, hDCScreen)
		VarSetCapacity(FontSize, 0)
		return outSize
		}
		else
		{
		This.releaseDC(0, hDCScreen)
		return 0
		}
	}

	B64Decode(B64, nBytes := "", W := 0, H := 0)
	{
	Static CRYPT_STRING_BASE64 := 0x00000001
	Bin = {}, BLen := 0, hICON := 0

		if !nBytes
		nBytes := floor(strlen(RTrim(B64, "=")) * 3/4)

	VarSetCapacity( Bin, nBytes, 0 ), BLen := StrLen(B64)
		if DllCall( "Crypt32.dll\CryptStringToBinary", "Ptr", &B64, "UInt", BLen, "UInt", CRYPT_STRING_BASE64
		, "Ptr", &Bin, "UInt*", nBytes, "Int", 0, "Int", 0)

		hICON := DllCall( "CreateIconFromResourceEx", "Ptr", &Bin, "UInt", nBytes, "Int", True
		, "UInt", 0x30000, "Int", W, "Int", H, "UInt", 0, "UPtr")
		; 0X30000: version number of the icon or cursor format for the resource bits pointed to by the pbIconBits 
	Return hICON
	}

	vMovable
	{
		set
		{
		This._vMovable := value
		}
		get
		{
		return This._vMovable
		}
	}

	hWnd()
	{
		if (!(spr := This.hWndSaved[This.instance]))
		{
		spr := "Splashy" . (This.instance)
		Gui, %spr%: +HWNDspr
		This.hWndSaved[This.instance] := spr
		}
	return spr
	}

	SelectObject(hDC, hgdiobj, type)
	{
	static HGDI_ERROR := 0xFFFFFFFF

	hRet := DllCall("Gdi32.dll\SelectObject", "Ptr", hDC, "Ptr", hgdiobj, "Ptr")

		if (!hRet || hRet == HGDI_ERROR)
		{
		msgbox, 8208, GDI Object, % "Selection failed for " type "`nError code is: " . ((hRet == HGDI_ERROR)? "HGDI_ERROR: ": "Unknown: ") . "The errorLevel is " ErrorLevel ": " . A_LastError
		return 0
		}
		else
		return hRet
	}

	deleteObject(hDC, hgdiobj)
	{
		if !DllCall("Gdi32.dll\DeleteObject", "Ptr", hObject)
		msgbox, 8208, GDI Object, % "Deletion failed `nError code is: " . "ErrorLevel " ErrorLevel ": " . A_LastError
	}
		releaseDC(hWnd, hDC)
	{
		if !DllCall("ReleaseDC", "Ptr", hWnd, "UPtr", hDC)
		msgbox, 8208, Device Context, % "Release failed `nError code is: " . "ErrorLevel " ErrorLevel ": " . A_LastError
	}

	SaveRestoreUserParms(Restore := 0)
	{
	Static userWorkingDir := "", userStringCaseSense := "", userDHW := ""

		if (Restore)
		{
			SetWorkingDir %userWorkingDir%
			StringCaseSense, %userStringCaseSense%
			DetectHiddenWindows %userDHW%
		}
		else
		{
			userDHW := A_DetectHiddenWindows
			userWorkingDir := A_WorkingDir
			userStringCaseSense := A_StringCaseSense
		}
	}

	Destroy()
	{
	SetWorkingDir %A_ScriptDir%
		for key, value in % This.downloadedPathNames
		{
			if (FileExist(value))
			FileDelete, % value
		}

	This.SaveRestoreUserParms(1)

	This.DeleteHandles()

	This.SetCapacity(downloadedPathNames, 0)
	This.SetCapacity(downloadedUrlNames, 0)
		for key in This.hWndSaved
		{
		value := "Splashy" . key
		Gui, %value%: Destroy
		Splashy.NewWndProc.clbk[key] := "" ; should invoke __Delete
		This.hWndSaved[key] := 0
		This.mainTextHWnd[key] := 0
		This.subTextHWnd[key] := 0
		}
	This.updateFlag := 0
	This.NewWndObj := ""
	This.SubClassTextCtl(0, 1)

	if (This.pToken)
	DllCall("GdiPlus.dll\GdiplusShutdown", "Ptr", This.pToken)
	if (This.hGDIPLUS)
	DllCall("FreeLibrary", "Ptr", This.hGDIPLUS)

	;This.Delete("", chr(255))
	This.SetCapacity(0)
	This.base := ""
	}

	DeleteHandles()
	{
		if (This.hBitmap)
		{
		; This.vImgType == 0 or IMAGE_BITMAP (0)
			if (DllCall("DeleteObject", "Ptr", This.hBitmap))
			This.hBitmap := 0
			else
			msgbox, 8208, DeleteObject, DeleteObject for hBitmap failed!
		}
		else
		{
			if (This.hIcon)
			{
				if (This.vImgType == 1)  ; IMAGE_ICON
				{
				if (DllCall("DestroyIcon", "Ptr", This.hIcon))
				This.hIcon := 0
				else
				msgbox, 8208, DestroyIcon, DestroyIcon for hIcon failed with error %A_LastError%
				}
				else
				{
					if (This.vImgType == 2)  ; IMAGE_CURSOR
					{
						if (DllCall("DestroyCursor", "Ptr", This.hIcon))
						This.hIcon := 0
						else
						msgbox, 8208, DestroyCursor, DestroyCursor for hIcon failed with error %A_LastError%
					}
				}
			}
		}
	}
	; ##################################################################################
}
;=====================================================================================




;=====================================================================================

Class PrgProperties
	{
	static propsHwnd := 0
	hWnd
	{
		set
		{
		this.propsHwnd := value
		}
		get
		{
			if (!WinExist("ahk_id" . this.propsHwnd))
			this.propsHwnd := 0
		return this.propsHwnd
		}
	}

	}

Class PrgLnchOpt
	{
	static Title := "PrgLnch Options"
	static PrgHwnd := ""
	static DefScrWidth := 1920
	static DefScrHeight := 1080
	static DefScrFreq := 60
	static adapterNames := ["", "", "", "", "", "", "", "", ""]
	static monNames := ["", "", "", "", "", "", "", "", ""]

	Hwnd()
	{
		if (!This.PrgHwnd)
		{
		DetectHiddenWindows, On
		Gui, PrgLnchOpt: +Hwndtemp
		This.PrgHwnd := temp
		DetectHiddenWindows, Off
		}
	return This.PrgHwnd
	}
	X()
	{
	DetectHiddenWindows, On
	WinGetPos, X, , , , % "ahk_id" This.PrgHwnd
	DetectHiddenWindows, Off
	return X
	}
	Y()
	{
	DetectHiddenWindows, On
	WinGetPos, , Y, , , % "ahk_id" This.PrgHwnd
	DetectHiddenWindows, Off
	return Y
	}
	Width()
	{
	DetectHiddenWindows, On
	WinGetPos, , , Width, , % "ahk_id" This.PrgHwnd
	DetectHiddenWindows, Off
	return Width
	}
	Height()
	{
	DetectHiddenWindows, On
	WinGetPos, , , , Height, % "ahk_id" This.PrgHwnd
	DetectHiddenWindows, Off
	return Height
	}
	OrderTargMonitorNum
	{
		set
		{
		this._OrderTargMonitorNum := value
		}
		get
		{
		return this._OrderTargMonitorNum
		}
	}
	MonDefResStrng
	{
		set
		{
		this._MonDefResStrng := value
		}
		get
		{
		return this._MonDefResStrng
		}
	}
	MonCurrResStrng
	{
		set
		{
		this._MonCurrResStrng := value
		}
		get
		{
		return this._MonCurrResStrng
		}
	}
	CurrMonStat
	{
		set
		{
		this._CurrMonStat := value
		}
		get
		{
		return this._CurrMonStat
		}
	}
	dispMonNamesNo
	{
		set
		{
		this._dispMonNamesNo := value
		}
		get
		{
		return this._dispMonNamesNo
		}
	}
	activeDispMonNamesNo
	{
		set
		{
		this._activeDispMonNamesNo := value
		}
		get
		{
		return this._activeDispMonNamesNo
		}
	}
	scrWidth
	{
		set
		{
		this._scrWidth := value
		}
		get
		{
			return this._scrWidth
		}
	}
	scrHeight
	{
		set
		{
		this._scrHeight := value
		}
		get
		{
		return this._scrHeight
		}
	}
	scrFreq
	{
		set
		{
		this._scrFreq := value
		}
		get
		{
		return this._scrFreq
		}
	}
	; scrInterlace, scrDPI handled internally per monitor
	; scrInterlace maybe implemented later
	scrWidthDef
	{
		set
		{
		this._scrWidthDef := value
		}
		get
		{
			if (!(this._scrWidthDef))
			this._scrWidthDef := this.DefScrWidth

			return this._scrWidthDef
		}
	}
	scrHeightDef
	{
		set
		{
		this._scrHeightDef := value
		}
		get
		{
			if (!(this._scrHeightDef))
			this._scrHeightDef := this.DefscrHeight
			
			return this._scrHeightDef
		}
	}
	scrFreqDef
	{
		set
		{
		this._scrFreqDef := value
		}
		get
		{
			if (!(this._scrFreqDef))
			this._scrFreqDef := this.DefscrFreq

		return this._scrFreqDef
		}
	}
	TestMode
	{
		set
		{
		this._TestMode := value
		}
		get
		{
		return this._TestMode
		}
	}
	Fmode
	{
		set
		{
		this._Fmode := value
		}
		get
		{
		return this._Fmode
		}
	}
	DynamicMode
	{
		set
		{
		this._DynamicMode := value
		}
		get
		{
		return this._DynamicMode
		}
	}
	TmpMode
	{
		set
		{
		this._TmpMode := value
		}
		get
		{
		return this._TmpMode
		}
	}
	regovar
	{
		set
		{
		this._regovar := value
		}
		get
		{
		return this._regovar
		}
	}

	SetDispAdapterNamesVal(index, adapterName)
	{
	This.adapterNames.InsertAt(index, adapterName)
	}
	GetDispAdapterNamesVal(index)
	{
	return This.adapterNames[index]
	}
	SetDispMonNamesVal(index, monName)
	{
	This.monNames.InsertAt(index, monName)
	}
	GetDispMonNamesVal(index)
	{
	return This.monNames[index]
	}
}

Class PrgLnch
	{
	static Title := "PrgLnch"
	static PrgHwnd := ""
	static Title1 := "Notepad++"
	;static NplusplusClass := "ahk_exe Notepad++.exe"
	;static NplusplusClass := "ahk_class Notepad++"
	static ProcScpt := "ahk_exe PrgLnch.exe"
	static ProcAHK := "ahk_class AutoHotkeyGUI"


	Hwnd()
	{
		if (!This.PrgHwnd)
		{
		DetectHiddenWindows, On
		Gui, PrgLnch: +Hwndtemp
		This.PrgHwnd := temp
		DetectHiddenWindows, Off
		}
	return This.PrgHwnd
	}
	SelIniChoicePath
	{
		set
		{
		this._SelIniChoicePath := value
		}
		get
		{
		return this._SelIniChoicePath
		}
	}
	Monitor
	{
		set
		{
		this._PrgLnchMonitor := value
		}
		get
		{
		return this._PrgLnchMonitor
		}
	}

	Class()
	{
	(A_IsCompiled)? temp := This.ProcScpt: temp := This.ProcAHK
	;temp := This.NplusplusClass

	;WinGetText, text, ahk_class %temp%
	return temp
	}
	Name()
	{
	SplitPath, A_ScriptFullPath,,,, temp
	return temp
	}
	PID()
	{
	Process, Exist
		If (!ErrorLevel)
		MsgBox, 8208, PrgLnch PID, Cannot retrieve the PID of PrgLnch!
	
	return ErrorLevel
	}
	Activate() ;Activates window with Title - This.Title
	{
	DetectHiddenWindows, On
		if (WinExist(This.Title))
		WinActivate, % "ahk_id" . This.Hwnd()
		;This replaced +LastFound as "WinActivate" would not work for some reason.
		else
		{
			if (WinExist(This.Title1))
			WinActivate
		}
	DetectHiddenWindows, Off
	}
	X()
	{
	DetectHiddenWindows, On
	WinGetPos, X, , , , % "ahk_id" This.PrgHwnd
	DetectHiddenWindows, Off
	return X
	}
	Y()
	{
	DetectHiddenWindows, On
	WinGetPos, , Y, , , % "ahk_id" This.PrgHwnd
	DetectHiddenWindows, Off
	return Y
	}
	Width()
	{
	DetectHiddenWindows, On
	WinGetPos, , , Width, , % "ahk_id" This.PrgHwnd
	DetectHiddenWindows, Off
	return Width
	}
	Height()
	{
	DetectHiddenWindows, On
	WinGetPos, , , , Height, % "ahk_id" This.PrgHwnd
	DetectHiddenWindows, Off
	return Height
	}
	}


(A_PtrSize == 8)? 64bit := 1: 64bit := 0 ; ONLY checks .exe bitness
updateStatus := 1
; Filters
WM_COPYDATA := 0x4A
WM_COPYGLOBALDATA := 0x0049
WM_DROPFILES := 0x233
MSGFLT_ALLOW := 1

;Extended
WS_EX_CONTEXTHELP := 0x00000400
WS_EX_ACCEPTFILES := 0x10
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

; Updown
UDM_SETRANGE := 0X0465

;HWND
PresetHwnd := 0
BtchPrgHwnd := 0
batchPrgStatusHwnd := 0
MovePrgHwnd := 0 ;  for listbox buddy

;combo
PrgChoiceHwnd := 0
IniChoiceHwnd := 0
PwrChoiceHwnd := 0
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
ChgResOnCloseHwnd := 0
ChgResOnSwitchHwnd := 0
PrgMinMaxHwnd := 0
PrgPriorityHwnd := 0
BordlessHwnd := 0
PrgLnchHdHwnd := 0
resolveShortctHwnd := 0

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
PresetPropHwnd := 0
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
btchSelPowerIndex := 0 ; Active power name for batch preset
maxBatchPrgs := 6
batchActive := 0 ; (1) Batch is Active for current Preset (-1) flagged for Not Active (0) Not active (2) Batch active at start
lnchPrgIndex := 0 ; (PrgIndex) Run, (0) Change Res or -(PrgIndex) Cancel
lnchStat := 0 ; (-1) Test Run; (1) Batch Run; (0) BatchPrgStatus Select (not used)
lastMonitorUsedInBatch := 0 ; Revert screen resolution for a Test Run Prg when the last Prg using the same monitor in a Batch has completed
listPrgVar := 0 ; copy of BatchPrgs listbox id
presetNoTest := 2 ; 0: config screen 2: return to or load of batch screen: 1: else e.g. Not click on preset 1: preset clicked
prgSwitchIndex := 0 ; saves index of Prg switched to when active
timWatchSwitch := 1000 ; Constant time interval for checking PrgLnch switch in/out
waitBreak := 0 ; Switch to break the Prg watch
PrgCmdLine := ["", "", "", "", "", "", "", "", "", "", "", ""]
PrgMonToRn := [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
PrgChgResOnClose := [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
PrgChgResOnSwitch := [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
PrgRnMinMax := [-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1] ;In line with the Gui control, indetermined values are "Normal". MinMax in WinGet is 0 for Normal
PrgRnPriority := [-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1]
PrgBordless := [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
PrgLnchHide := [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
PrgResolveShortcut := [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
PrgListIndex := [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
PrgListIndexTmp := [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
PrgBdyBtchTog := [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
PrgBdyBtchTogTmp := [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
PrgPIDMast := [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]

PrgMonPID := {} ; Tracks monitors: 7th entry is for test run Prg
; 0: no slot (after currBatchNo), Monitor No: Prg Active


PresetNames := ["", "", "", "", "", ""]
PresetNamesBak := ["", "", "", "", "", ""]
IniChoiceNames := ["", "", "", "", "", "", "", "", "", "", "", ""]
arrPowerPlanNames := []
btchPowerNames := ["Default", "Default", "Default", "Default", "Default", "Default"]
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
PrgLnkInf := ["", "", "", "", "", "", "", "", "", "", "", ""] ; Can contain either working directory and resolved lnk path for same Prg as well as other meta
PrgVer := [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
PrgUrl := ["", "", "", "", "", "", "", "", "", "", "", ""]
IniFileShortctSep := "?"
strIniChoice := ""
strPrgChoice := "|None|"
defPrgStrng := "None"
ChgShortcutVar := "Change Shortcut"
txtPrgChoice := ""
iniTxtPadChoice := ""
UndoTxt := ""
GoConfigTxt = Prg Config
iniSel := 0
selPrgChoice := 1
selPrgChoiceTimer := 0
ResShortcut := 0
PrgLnch.regoVar := 0


; General temp variables
retVal := 0
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
PrgLnch.SelIniChoicePath := PrgLnchIni
SelIniChoiceName = PrgLnch
selIniNameSprIniSlot := ""
oldSelIniChoiceName := ""
oldSelIniChoicePath := "" ; Previously loaded preset: in many cases the path of oldSelIniChoiceName above

;Monitor array
iDevNumArray := [0, 0, 0, 0, 0, 0, 0, 0, 0]
; Defaults per monitor
scrWidthDefArr := [0, 0, 0, 0, 0, 0, 0, 0, 0]
scrHeightDefArr := [0, 0, 0, 0, 0, 0, 0, 0, 0]
scrFreqDefArr := [0, 0, 0, 0, 0, 0, 0, 0, 0] ; frequencies == vertical refresh rates
; settings per Prg
PrgLnchMon := 0 ; Device PrgLnch is run from
PrgLnchOpt.dispMonNamesNo := 9 ;No more than 9 displays!?
targMonitorNum := 1
primaryMon := 1 ; placeholder
ResIndexList := ""
x := 0
y := 0
w := 0
h := 0


	if (!A_IsUnicode)
	msgbox, 8192 , Task Dialogs, Chinese Characters in ANSI Task Dialogs!


;Done here, else complications with PrgLnch.Monitor
Gui, PrgLnchOpt: New

;Get def. mon list...

GetDisplayData(, iDevNumArray, , , , , , -3)

; Can change

PrgLnch.Monitor := GetPrgLnchMonNum(iDevNumArray, primaryMon, 1)

SplashyProc("*Loading")

temp := PrgLnch.Title
fTemp := 0
ffTemp := 0
DetectHiddenWindows, On
; foundpos1, foundpos2 ... window IDs
WinGet, foundpos, List, % temp


if (foundpos > 1 && !A_Args[1]) ;  foundpos is no of window IDs found,.No command line parms! See ComboBugFix
{
	while (temp := foundpos%A_Index%)
	{

	WinGetClass, strRetVal, % "ahk_id" temp

	if (strRetVal && !InStr(strRetVal, "CabinetWClass"))
	{
	; The following "fails" when any non-PrgLnch ahk script (compiled or not) is run from the PrgLnch folder: Proper way is with mutex. Also fails  on 2 or more classic Notepad windows

	if (InStr(strRetVal, "AutoHotkey"))
	ffTemp++
	if (InStr(strRetVal, "Notepad++"))
	fTemp++

	; An extra value for consideration is the gui in Splashy!
		if (ffTemp > 3)
		{
		MsgBox, 8208, PrgLnch Running!, An instance of PrgLnch is already in memory!
		GoSub PrgLnchButtonQuit_PrgLnch
		}
		else
		{
			if (ffTemp > 3)
			{
			MsgBox, 8224, PrgLnch in Notepad++!, Too many PrgLnch windows open. Is PrgLnch already active?
			GoSub PrgLnchButtonQuit_PrgLnch
			}
		}
	}

	} 
}

DetectHiddenWindows, Off
	if (FileExist(PrgLnchIni))
	{
	IniSpaceCleaner(PrgLnchIni, 1) ;  fix old version
	sleep, 90

	strTemp := ""
	strTemp2 := ""
	temp := 0

	for temp, strRetVal in A_Args  ; For each parameter (or file dropped onto a script):
	{
		if (temp == 1)
		strTemp := strRetVal ; dealt with after Iniproc
		else
		{
			if (temp == 2)
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
			selIniNameSprIniSlot := strRetVal
		}
	}

	IniProcIniFileStart()
}

IniProc()
; No screen parms yet
sleep 90


IniRead, disclaimer, % PrgLnch.SelIniChoicePath, General, Disclaimer


if (!disclaimer || disclaimer == "Error")
{
msgbox, 8196 , Disclaimer, % disclaimtxt
	IfMsgBox, Yes
	{
	IniWrite, 1, % PrgLnch.SelIniChoicePath, General, Disclaimer
	
	FileInstall PrgLnch.ico, PrgLnch.ico
		if FileExist("PrgLnch.ico")
		Menu, Tray, Icon, PrgLnch.ico
	FileInstall PrgLnch.chm, PrgLnch.chm
	sleep, 300
	; init LnchPad here
	IniProcIniFile(0, SelIniChoiceName, IniChoiceNames, PrgNo, strIniChoice)
	oldSelIniChoiceName := selIniChoiceName
	}
	else
	{
	FileDelete % PrgLnch.SelIniChoicePath
	GoSub PrgLnchButtonQuit_PrgLnch
	}
}
else
{
	if (!FileExist("PrgLnch.chm"))
	FileInstall PrgLnch.chm, PrgLnch.chm, 1
sleep, 120
	if (A_Min < 22) ; Do this approx every 3 runs
	IniSpaceCleaner(PrgLnch.SelIniChoicePath)
}


FileInstall PrgLnch.ico, PrgLnch.ico
	if FileExist("PrgLnch.ico")
	Menu, Tray, Icon , PrgLnch.ico



; Restarted PrgLnch (see above): Must happen after initialising PrgPID, PrgListPID.
temp := 0
if (strTemp)
	{
		; restart same ini
		if (PrgLnch.SelIniChoicePath == oldSelIniChoicePath)
		{
			Loop, parse, strTemp, | ; Parse the string based on the pipe symbol.
			{
				if (A_Index == 1)
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
				if (A_Index == 1)
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
	PrgLnkInf[A_Index] := GetPrgLnkVal(strTemp, IniFileShortctSep, 1, PrgResolveShortcut[A_Index])
}



	if (!oldSelIniChoicePath || (PrgLnch.SelIniChoicePath == oldSelIniChoicePath))
	{
		; PrgPIDMast = Potential candidate list for PID
		loop %maxBatchPrgs%
		InitBatchActivePrgs(maxBatchPrgs, PrgBatchIni%A_Index%, PrgPIDMast)

	batchActive := ProcessActivePrgsAtStart(PrgNo, PrgLnkInf, PrgChoicePaths, IniFileShortctSep, PrgPIDMast)

		loop %maxBatchPrgs%
		PidMaster(PrgNo, maxBatchPrgs, A_Index, PrgBatchIni%A_Index%, PrgListPID%A_Index%, PrgPIDMast)
	}
	else
	{
		; PIDs again checked in InitBtchStat later
		; Point of this is to save the _same_ PIDs when switching LnchPad Slots (in case of multiple instances)

		batchActive := ProcessActivePrgsAtStart(PrgNo, PrgLnkInf, PrgChoicePaths, IniFileShortctSep, PrgPIDMast, oldSelIniChoicePath)
	
		loop %maxBatchPrgs%
		PidMaster(PrgNo, maxBatchPrgs, A_Index, PrgBatchIni%A_Index%, PrgListPID%A_Index%, PrgPIDMast)
	}

	if (batchActive)
	batchActive := 2 ; for InitBtchStat at start





IniRead, fTemp, % PrgLnch.SelIniChoicePath, General, ChangeShortcutMsg
	if (fTemp == 1)
	ChgShortcutVar := "Change Shortcut Name"


Gui, PrgLnchOpt: -DPIScale -MaximizeBox -MinimizeBox +OwnDialogs +E%WS_EX_CONTEXTHELP% +E%WS_EX_ACCEPTFILES%

Gui, PrgLnchOpt: Color, FFFFCC
Gui, PrgLnchOpt: Add, ComboBox, vPrgChoice gPrgChoice HWNDPrgChoiceHwnd
Gui, PrgLnchOpt: Add, Button, gMakeShortcut vMkShortcut HWNDMkShortcutHwnd wp, &Just Change Res.
Gui, PrgLnchOpt: Add, Edit, vCmdLinPrm gCmdLinPrmSub HWNDcmdLinHwnd
Gui, PrgLnchOpt: Add, Text, vMonitors gMonitorsSub HWNDMonitorsHwnd wp ; wp is width of previous control
Gui, PrgLnchOpt: Add, DropDownList, AltSubmit viDevNum HWNDDevNumHwnd giDevNo
Gui, PrgLnchOpt: Add, Checkbox, ys vresolveShortct gresolveShortctChk HWNDresolveShortctHwnd wp, Resolve Shortcut
GuiControl, PrgLnchOpt: Enable, resolveShortct
GuiControl, PrgLnchOpt:, resolveShortct, % ResShortcut

Gui, PrgLnchOpt: Add, text,, Res Options:  ; Save this control's position and start a new section.
Gui, PrgLnchOpt: Add, Radio, -Wrap gTestMode vTest HWNDTestHwnd, TestMode
GuiControl, PrgLnchOpt: , Test, % Test
Gui, PrgLnchOpt: Add, Radio, -Wrap gChangeMode vFMode HWNDFModeHwnd, Change at every mode
GuiControl, PrgLnchOpt: , FMode, % FMode
Gui, PrgLnchOpt: Add, Radio, -Wrap gDynamicMode vDynamic HWNDDynamicHwnd, Dynamic (All running Apps)
GuiControl, PrgLnchOpt: , Dynamic, % Dynamic
Gui, PrgLnchOpt: Add, Radio, -Wrap gTmpMode vTmp HWNDTmpHwnd, Temporary (Recommended)
GuiControl, PrgLnchOpt: , Tmp, % Tmp
Gui, PrgLnchOpt: Add, Checkbox, vRego gRegoCheck HWNDRegoHwnd, Pull values from registry

; Save this control's position and start a new section.
Gui, PrgLnchOpt: Add, Text, ys cTeal vcurrRes HWNDcurrResHwnd wp
Gui, PrgLnchOpt: Add, Checkbox, vallModes gCheckModes HWNDallModesHwnd, List all 'compatible'

GuiControl, PrgLnchOpt:, Rego, % PrgLnch.regoVar

GuiControl, PrgLnchOpt:, PrgChoice, %strPrgChoice%


; Choose the appropriate dropdown field
if (defPrgStrng == "None")
	GuiControl, PrgLnchOpt: Choose, PrgChoice, 1
else
{
	GuiControl, PrgLnchOpt:, MkShortcut, Make Shortcut
		loop % PrgNo
		{
		If (PrgChoiceNames[A_Index] == defPrgStrng)
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


	; reject unattached monitors, replace with default
	loop %PrgNo% 
	{
	foundpos := PrgMonToRn[A_Index]
		if (foundpos && (iDevNumArray[foundpos] < 10) && PrgChoiceNames[A_Index])
		PrgMonToRn[A_Index] := PrgLnch.Monitor
	}


	if (PrgMonToRn[selPrgChoice] && (defPrgStrng != "None"))
	{
	targMonitorNum := PrgMonToRn[selPrgChoice]
	StoreFetchPrgRes(1, selPrgChoice, PrgLnkInf, targMonitorNum)
	SetResDefaults(0, targMonitorNum, scrWidthDefArr, scrHeightDefArr, scrFreqDefArr, 1)
	CheckModesFunc(defPrgStrng, PresetPropHwnd, targMonitorNum, iDevNumArray, ResIndexList, allModes)
	}
	else
	{
	CheckModesFunc(defPrgStrng, PresetPropHwnd, targMonitorNum, iDevNumArray, ResIndexList, allModes)
	; save to defaults
	CopyToFromRes(targMonitorNum, 1)
	}


GuiControl, PrgLnchOpt:, Monitors, % PrglnchOpt.GetDispMonNamesVal(targMonitorNum)
;Build monitor list: the results shown in TogglePrgOptCtrls()below

Loop % PrgLnchOpt.dispMonNamesNo
{
	if (iDevNumArray[A_Index] < 10) ;dec masks
	GuiControl, PrgLnchOpt:, iDevNum, % A_Index . " |"
	else
	{
		if (iDevNumArray[A_Index] > 99)
		{
		GuiControl, PrgLnchOpt:, iDevNum, % SubStr(iDevNumArray[A_Index], 3, 1) " |"
			if (!selPrgChoice || defPrgStrng == "None")
			GuiControl, PrgLnchOpt: ChooseString, iDevNum, % SubStr(iDevNumArray[A_Index], 1, 1)
		}
		else
		GuiControl, PrgLnchOpt:, iDevNum, % SubStr(iDevNumArray[A_Index], 2, 1) " |"
	}
}



Gui, PrgLnchOpt: font ;factory  defaults

Gui, PrgLnchOpt: Add, Checkbox, vChgResOnClose gChgResOnCloseChk HWNDChgResOnCloseHwnd, Change Res on Close
GuiControl, PrgLnchOpt: Disable, ChgResOnClose
Gui, PrgLnchOpt: Add, Checkbox, vChgResOnSwitch gChgResOnSwitchChk HWNDChgResOnSwitchHwnd, Change Res on Switch
GuiControl, PrgLnchOpt: Disable, ChgResOnSwitch
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

	if (txtPrgChoice == "None")
	{
	GuiControl, PrgLnchOpt: Enable, RnPrgLnch
	GuiControl, PrgLnchOpt:, RnPrgLnch, Change Res`.
	GuiControl, PrgLnchOpt: Disable, DefaultPrg
	GuiControl, PrgLnchOpt:, MkShortcut, Just Change Res.
	GuiControl, PrgLnchOpt: Disable, Just Change Res.
	TogglePrgOptCtrls(txtPrgChoice, ResShortcut, iDevNum, iDevNumArray, targMonitorNum)
	PrgURLEnable(PrgUrlTest, UrlPrgIsCompressed, selPrgChoice, PrgChoicePaths, selPrgChoiceTimer, PrgResolveShortcut, PrgLnkInf, PrgUrl, PrgVer, PrgVerNew, UpdturlHwnd, IniFileShortctSep, 1)
	}
	else
	{

	GuiControl, PrgLnchOpt:, MkShortcut, % ChgShortcutVar
	CheckPrgPaths(selPrgChoice, IniFileShortctSep, PrgChoicePaths, PrgLnkInf, PrgResolveShortcut, 1)

	PrgCmdLineEnable(selPrgChoice, PrgCmdLine, cmdLinHwnd, PrgResolveShortcut, PrgLnkInf)

	PrgURLEnable(PrgUrlTest, UrlPrgIsCompressed, selPrgChoice, PrgChoicePaths, selPrgChoiceTimer, PrgResolveShortcut, PrgLnkInf, PrgUrl, PrgVer, PrgVerNew, UpdturlHwnd, IniFileShortctSep)
	GuiControl, PrgLnchOpt: ChooseString, iDevNum, %targMonitorNum%
	borderToggle := DcmpExecutable(selPrgChoice, PrgChoicePaths, PrgLnkInf, PrgResolveShortcut, IniFileShortctSep, 1)
	TogglePrgOptCtrls(txtPrgChoice, ResShortcut, iDevNum, iDevNumArray, targMonitorNum, borderToggle, selPrgChoice, PrgChgResOnClose, PrgChgResOnSwitch, PrgChoicePaths, PrgLnkInf, PrgRnMinMax, PrgRnPriority, PrgBordless, PrgLnchHide, 1)

	GuiControl, PrgLnchOpt: , DefaultPrg, 1
	}




Gui, PrgLnchOpt: Show, Hide
WinMover(PrgLnchOpt.Hwnd(), "d r")   ; "dr" means "down, right"

	if (!FindStoredRes(ResIndexHwnd))
	GuiControl, PrgLnchOpt: ChooseString, ResIndex, % PrgLnchOpt.MonCurrResStrng

	;ChooseString may fail if frequencies differ. Meh!
	if (PrgPID)
	{
	HideShowTestRunCtrls()
	SetTimer, WatchSwitchOut, -%timWatchSwitch%
	}

	if (!disclaimer)
	SetTimer, RnChmWelcome, 3200

IniProc(100) ;initialises scrWidth, scrHeight, scrFreq & saves iDevNumArray (Prgmon) in ini





















































































;Frontend form
Gui, PrgLnch: New
Gui, PrgLnch:Default  	;A_DefaultGui is name of default gui
Gui, PrgLnch: -DPIScale -MaximizeBox -MinimizeBox +OwnDialogs +E%WS_EX_CONTEXTHELP%
Gui, PrgLnch: Color, FFFFCC
Gui, PrgLnch: Add, Button, cdefault vPresetProp gPresetProp HWNDPresetPropHwnd, Preset Properties
GuiControlGet, temp, PrgLnch: Pos, %PresetPropHwnd%
GuiControl, PrgLnch: Move, PresetProp, % "w" tempw*1.3

Gui, PrgLnch: Add, Text, vPresetLabel wp, Batch Presets
GuiControl, PrgLnch: Move, PresetLabel, % "w" tempw*1.3

Gui, PrgLnch: Add, Edit, vPresetName gPresetNameSub HWNDPresetNameHwnd
Gui, PrgLnch: Add, ListBox, vBtchPrgPreset gBtchPrgPresetSub HWNDPresetHwnd r6 AltSubmit
Gui, PrgLnch: Add, Checkbox, vDefPreset gDefPresetSub HWNDDefPresetHwnd wp, This Preset at Load

Gui, PrgLnch: Add, Text, ys vbatchListPrg wp, Batch Prgs
;initialise batch
strRetVal := PopBtchListBox(PrgChoiceNames, PrgNo, PrgMonToRn, PrgBdyBtchTog, PrgListIndex, batchPrgNo, 1)
temp := batchPrgNo-1

Gui, PrgLnch: Add, ListBox, vListPrg gListPrgProc HWNDBtchPrgHwnd AltSubmit
Gui, PrgLnch: Add, UpDown, vMovePrg gMovePrgProc HWNDMovePrgHwnd Range%temp%-0 ;MovePrg ZERO based: https://autohotkey.com/boards/viewtopic.php?f=5&t=26703&p=125603#p125603

Gui, PrgLnch: Add, Text, ys wp, Prg Status

temp := PrgLnchOpt.Height()/2

Gui, PrgLnch: Add, ListBox, vbatchPrgStatus gbatchPrgStatusSub HWNDbatchPrgStatusHwnd h%temp% AltSubmit
Gui, PrgLnch: Add, Checkbox, vPrgInterval gPrgIntervalChk HWNDPrgIntervalHwnd Check3 r2 wp, Prg Lnch Interval: (Short-Med-Long)
GuiControl, PrgLnch: Enable, PrgInterval
GuiControl, PrgLnch:, PrgInterval, % PrgIntervalLnch

Gui, PrgLnch: Add, Text, wp, Batch Power Plans

Gui, PrgLnch: Add, DropDownList, wp AltSubmit vPwrChoice gPwrChoiceSel HWNDPwrChoiceHwnd
sleep 30




Gui, PrgLnch: Add, Button, ys cdefault vRunBatchPrg gRunBatchPrgSub HWNDRunBatchPrgHwnd wp, &Run Batch
Gui, PrgLnch: Add, Button, cdefault vGoConfigVar gGoConfig HWNDGoConfigHwnd wp, % "&" GoConfigTxt

Gui, PrgLnch: Add, Text, wp, LnchPad Slot List
Gui, PrgLnch: Add, ComboBox, wp vIniChoice gIniChoiceSel HWNDIniChoiceHwnd
GuiControl, PrgLnch:, IniChoice, %strIniChoice%



if (SelIniChoiceName == "PrgLnch")
{
	; User types at start before selecting from list-
	if (!iniSel)
	iniSel := FindFreeLnchPadSlot(PrgNo, IniChoiceNames)

	if (selIniNameSprIniSlot)
	{
		if (selIniNameSprIniSlot != "PrgLnch")
		iniSel := SubStr(selIniNameSprIniSlot, 4, Strlen(selIniNameSprIniSlot))
	GuiControl, PrgLnch: ChooseString, IniChoice, % "ini" . iniSel
	}
	else
	{
	GuiControl, PrgLnch: Text, IniChoice,
	SetEditCueBanner(IniChoiceHwnd, "LnchPad Slot", 1)
	}
}
else
GuiControl, PrgLnch: ChooseString, IniChoice, %SelIniChoiceName%






Gui, PrgLnch: Add, Button, cdefault vLnchPadConfig gLnchPadConfig HWNDLnchPadConfigHwnd wp, LnchPad Setup
Gui, PrgLnch: Add, Text, wp

Gui, PrgLnch: Add, Button, cdefault HWNDquitHwnd wp, &Quit_PrgLnch

; init conditions
currBatchNo := 0
btchPrgPresetSel := PrgBatchIniStartup
	if (btchPrgPresetSel)
	GuiControl, PrgLnch:, DefPreset, 1


arrPowerPlanNames := DopowerPlan()

DoBatchPower(btchPowerNames, btchSelPowerIndex, arrPowerPlanNames, btchPrgPresetSel)




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

	EnableBatchCtrls(PresetNameHwnd, btchPrgPresetSel, PwrChoiceHwnd, btchSelPowerIndex, PresetNames)

	GuiControl, PrgLnch: Choose, BtchPrgPreset, % btchPrgPresetSel


	sleep 60
	GuiControl, PrgLnch:, batchPrgStatus, % ReorgBatch(batchPrgNo, maxBatchPrgs, btchPrgPresetSel, PrgMonToRn, PrgBatchIni%btchPrgPresetSel%, currBatchNo, PrgListIndex, PrgBdyBtchTog)

	}
	else
	;load "none"
	EnableBatchCtrls(PresetNameHwnd, btchPrgPresetSel, PwrChoiceHwnd, btchSelPowerIndex, PresetNames, 1)



sleep 60
GuiControl, PrgLnch:, ListPrg, % PopBtchListBox(PrgChoiceNames, PrgNo, PrgMonToRn, PrgBdyBtchTog, PrgListIndex, batchPrgNo)
Thread, NoTimers, false




; Just Me: https://autohotkey.com/boards/viewtopic.php?t=1403
SendMessage, % LB_GETITEMHEIGHT, 0, 0, , % "ahk_id " . BtchPrgHwnd
temp := % ErrorLevel
SendMessage, % LB_GETCOUNT, 0, 0, , % "ahk_id " . BtchPrgHwnd
temp :=  (temp * (ErrorLevel + 1)) ; + 8 for the margins

fTemp := PrgLnchOpt.Height()
	if (temp > fTemp)
	temp := fTemp

GuiControl, PrgLnch: Move, ListPrg, h%temp%

temp := temp/2

GuiControl, PrgLnch: Move, MovePrg, y%temp%

temp:= 1/2 * fTemp 
;GuiControl, PrgLnch: Move, BtchPrgPreset, h%temp%


Gui, PrgLnch: Show, Hide

WinMover(PrgLnch.Hwnd(), "d r", PrgLnchOpt.Width() * 61/80, PrgLnchOpt.Height() * 13/10)

sleep, 20
	if (batchActive == 2)
	{
	GoSub InitBtchStat
	batchActive := 1
	}

; Enable message filters for drag'ndrop
if (A_IsAdmin)
{
strTemp := PrgLnchOpt.Hwnd()
DllCall("ChangeWindowMessageFilterEx", "Ptr", strTemp, "UInt", WM_COPYDATA, "UInt", MSGFLT_ALLOW, "Ptr", 0)
DllCall("ChangeWindowMessageFilterEx", "Ptr", strTemp, "UInt", WM_COPYGLOBALDATA, "UInt", MSGFLT_ALLOW, "Ptr", 0)
DllCall("ChangeWindowMessageFilterEx", "Ptr", strTemp, "UInt", WM_DROPFILES, "UInt", MSGFLT_ALLOW, "Ptr", 0)
}

Gui, PrgLnch: Show,, % PrgLnch.Title

SplashyProc("*Release")


Process, priority, %PrgLnchPID%, B

return




;LnchPad invocation
LnchPadConfig:
FileInstall LnchPadCfg.jpg, LnchPadCfg.jpg
CloseChm()
SplashImage, LnchPadCfg.jpg, A B,,, LnchPadCfg
SetTimer, LnchPadSplashTimer, 200

	if (!LnchLnchPad(SelIniChoiceName))
	{
	;Problem with script directory
	IniProcIniFileStart()
	GuiControl, PrgLnch:, IniChoice,
	GuiControl, PrgLnch:, IniChoice, %strIniChoice%
	GuiControl, PrgLnch: Choosestring, IniChoice, % SelIniChoiceName
	GuiControl, PrgLnch: Show, IniChoice
	}

temp := 0
return

LnchPadSplashTimer:
SetTitleMatchMode, 3

	If (WinActive("LnchPad Setup"))
	{
	SetTimer, LnchPadSplashTimer, Delete
	SplashImage, LnchPadCfg.jpg, Hide,,, LnchPadCfg
	}
	else
	{
	temp++
		if (temp > 199)
		{
			; Prompt for Admin
			if (winactive("LnchPad Setup Elevated?") || winactive("PrgLnch Executable Required!"))
			temp := 0
			else
			{
				if (temp == 200)
				{
				MsgBox, 8256, LnchPad Config Delay, There is a problem with the load of LnchPad Config!
				SetTimer, LnchPadSplashTimer, Delete
				SplashImage, LnchPadCfg.jpg, Hide,,, LnchPadCfg
				}
			}
		}
	}
return

PwrChoiceSel:
Gui, PrgLnch: Submit, Nohide
Gui PrgLnch: +OwnDialogs
GuiControlGet, btchSelPowerIndex, PrgLnch:, PwrChoice


temp := 0
	Loop, % arrPowerPlanNames.Length()
	{
		if (A_Index == btchSelPowerIndex)
		{
		btchPowerNames[btchPrgPresetSel] := arrPowerPlanNames[A_Index]
		temp := 1
		Break
		}
	}
	if (!temp)
	btchPowerNames[btchPrgPresetSel] := "Default"

strTemp := join(btchPowerNames)
IniWrite, %strTemp%, % PrgLnch.SelIniChoicePath, Prgs, BatchPowerNames


return

MovePrgProc:

boundListBtchCtl := % MovePrg + 1
Gui, PrgLnch: Submit, Nohide

if (btchPrgPresetSel)
{
if (IsCurrentBatchRunning(currBatchNo, PrgListPID%btchPrgPresetSel%))
return
}

if (listPrgVar)
{
	Loop % batchPrgNo
	{
		if (MovePrg + 1 == A_Index)
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
				if (batchPrgNo == A_Index) ;down: move the rest up
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
				} Until (A_Index == batchPrgNo)
			}
		Break
		}
	}

GuiControl, PrgLnch:, ListPrg, % PopBtchListBox(PrgChoiceNames, PrgNo, PrgMonToRn, PrgBdyBtchTog, PrgListIndex, batchPrgNo)
GuiControl, PrgLnch: Choose, ListPrg, % listPrgVar
GuiControl, PrgLnch: Show, ListPrg

}
return

ListPrgProc:
Gui, PrgLnch: Submit, Nohide
;ToolTip
;Do not use if any active
if (btchPrgPresetSel)
{
if (IsCurrentBatchRunning(currBatchNo, PrgListPID%btchPrgPresetSel%))
return
}

if (!boundListBtchCtl)
{
GuiControl, PrgLnch:, MovePrg, % ListPrg + 1
listPrgVar := 1
boundListBtchCtl := 1
;called once: MovePrg Initialised if no presets loaded!
}

	MouseGetPos,,,,temp,3
	if (temp == BtchPrgHwnd) ;actually clicked the Listbox
	{
	GuiControlGet, listPrgVar, PrgLnch:, listPrg
	fTemp := PrgListIndex[listPrgVar]
	if (PrgBdyBtchTog[listPrgVar] == MonStr(PrgMonToRn, fTemp))
	{
		PrgBdyBtchTog[listPrgVar] := ""
		currBatchNo -= 1
			if (currBatchNo < 0)
			currBatchNo := 0

			if (!currBatchNo)
			EnableBatchCtrls(PresetNameHwnd, btchPrgPresetSel, PwrChoiceHwnd, btchSelPowerIndex, PresetNames, 1)
	}
	else
	{
		if (currBatchNo < maxBatchPrgs)
		{
			if (!currBatchNo)
			EnableBatchCtrls(PresetNameHwnd, btchPrgPresetSel, PwrChoiceHwnd, btchSelPowerIndex, PresetNames)

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
	if (PrgBdyBtchTog[A_Index] == MonStr(PrgMonToRn, temp))
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
	IniWrite, %strTemp%, % PrgLnch.SelIniChoicePath, Prgs, PrgBatchIni%btchPrgPresetSel%
	}
	else
	IniWrite, %A_Space%, % PrgLnch.SelIniChoicePath, Prgs, PrgBatchIni%btchPrgPresetSel%
	 ; Nothing to write!

		;If PrgProperties window is showing, update it
		If (PrgProperties.Hwnd)
		PopPrgProperties(currBatchNo, btchPrgPresetSel, PrgBatchIni%btchPrgPresetSel%, PrgChoiceNames, PrgChoicePaths, PrgLnkInf, PrgResolveShortcut, IniFileShortctSep)

}


return




BtchPrgPresetSub:
Gui, PrgLnch: Submit, Nohide
Gui PrgLnch: +OwnDialogs
SetTimer, WatchSwitchBack, Delete
SetTimer, WatchSwitchOut, Delete
Thread, NoTimers
temp := 0

waitBreak := 1 ; breaks the timer loop

if (btchPrgPresetSel)
GuiControlGet, temp, PrgLnch:, BtchPrgPreset ;sel another preset?
else
GuiControlGet, btchPrgPresetSel, PrgLnch:, BtchPrgPreset



if (btchPrgPresetSel == temp) ; same preset as before
{
	; Batch active?
	if (IsCurrentBatchRunning(currBatchNo, PrgListPID%btchPrgPresetSel%))
	{
	
		; Just returned from Config
		if (presetNoTest == 2)
		{
		presetNoTest := 1

		GuiControl, PrgLnch:, ListPrg, % PopBtchListBox(PrgChoiceNames, PrgNo, PrgMonToRn, PrgBdyBtchTog, PrgListIndex, batchPrgNo, 1)

		; Restore PID
		PidMaster(PrgNo, currBatchNo, btchPrgPresetSel, PrgBatchIni%btchPrgPresetSel%, PrgListPID%btchPrgPresetSel%, PrgPIDMast)

		GuiControl, PrgLnch:, batchPrgStatus, % ReorgBatch(batchPrgNo, maxBatchPrgs, btchPrgPresetSel, PrgMonToRn, PrgBatchIni%btchPrgPresetSel%, currBatchNo, PrgListIndex, PrgBdyBtchTog)


			if (btchPrgPresetSel == PrgBatchIniStartup)
			GuiControl, PrgLnch:, DefPreset, 1
			else
			GuiControl, PrgLnch:, DefPreset, 0


			strRetVal := PopBtchListBox(PrgChoiceNames, PrgNo, PrgMonToRn, PrgBdyBtchTog, PrgListIndex, batchPrgNo)
			sleep 100
			GuiControl, PrgLnch:, ListPrg, % strRetVal
			GuiControl, PrgLnch: Show, ListPrg

			batchActive := 1
			DoBatchPower(btchPowerNames, btchSelPowerIndex, arrPowerPlanNames, btchPrgPresetSel)
			EnableBatchCtrls(PresetNameHwnd, btchPrgPresetSel, PwrChoiceHwnd, btchSelPowerIndex, PresetNames)
			SetTimer, WatchSwitchOut, %timWatchSwitch%

		}
		else
		{
			retVal := TaskDialog("Prg Presets", "Selected Preset contains active Prgs", , "If the active Prg is removed, Prglnch will continue to monitor`nthe (inactive) Prg if it is already included in another batch preset.", "", "Continue and remove the Preset`n(Prgs will not be cancelled)", "Do not remove the Preset")
			if (retVal == 1)
			{

			PrgPropertiesClose()

				loop % currBatchNo
				{
				; Remove PIDs
				temp := PrgListPID%btchPrgPresetSel%[A_Index]
				PrgMonPID.Delete(temp)
				PrgListPID%btchPrgPresetSel%[A_Index] := 0
				PrgBdyBtchTog[A_Index] == ""
				}
			currBatchNo := 0
			;must remove ini entry
			IniWrite, %A_Space%, % PrgLnch.SelIniChoicePath, Prgs, PrgBatchIni%btchPrgPresetSel%
				if (PrgBatchIniStartup == btchPrgPresetSel)
				IniWrite, 0, % PrgLnch.SelIniChoicePath, Prgs, PrgBatchIniStartup

			PresetNames[btchPrgPresetSel] := ""
			btchPrgPresetSel := 0
			SendMessage, LB_SETCURSEL, -1, 0, , ahk_id %PresetHwnd% ; deselects
			GuiControl, PrgLnch:, batchPrgStatus, |
			DoBatchPower(btchPowerNames, btchSelPowerIndex, arrPowerPlanNames, btchPrgPresetSel, 1)
			EnableBatchCtrls(PresetNameHwnd, btchPrgPresetSel, PwrChoiceHwnd, btchSelPowerIndex, PresetNames, 1)
			}
			else
			return

		}
	}
	else
	{
		if (presetNoTest == 2)
		{
		presetNoTest := 1

		GuiControl, PrgLnch:, batchPrgStatus, % ReorgBatch(batchPrgNo, maxBatchPrgs, btchPrgPresetSel, PrgMonToRn, PrgBatchIni%btchPrgPresetSel%, currBatchNo, PrgListIndex, PrgBdyBtchTog)
			if (btchPrgPresetSel == PrgBatchIniStartup)
			GuiControl, PrgLnch:, DefPreset, 1
			else
			GuiControl, PrgLnch:, DefPreset, 0

		strRetVal := PopBtchListBox(PrgChoiceNames, PrgNo, PrgMonToRn, PrgBdyBtchTog, PrgListIndex, batchPrgNo)
		sleep 30
		GuiControl, PrgLnch:, ListPrg, % strRetVal
		DoBatchPower(btchPowerNames, btchSelPowerIndex, arrPowerPlanNames, btchPrgPresetSel)
		EnableBatchCtrls(PresetNameHwnd, btchPrgPresetSel, PwrChoiceHwnd, btchSelPowerIndex, PresetNames)

		GuiControl, PrgLnch: Show, ListPrg

		}
		else
		{

		PrgPropertiesClose()

			loop % currBatchNo
			{
			PrgBdyBtchTog[A_Index] == ""
			}
		currBatchNo := 0
		;must remove ini entry
		IniWrite, %A_Space%, % PrgLnch.SelIniChoicePath, Prgs, PrgBatchIni%btchPrgPresetSel%
			if (PrgBatchIniStartup == btchPrgPresetSel)
			IniWrite, 0, % PrgLnch.SelIniChoicePath, Prgs, PrgBatchIniStartup

		PresetNames[btchPrgPresetSel] := ""
		btchPrgPresetSel := 0
		SendMessage, LB_SETCURSEL, -1, 0, , ahk_id %PresetHwnd% ; deselects
		GuiControl, PrgLnch:, batchPrgStatus, |
		DoBatchPower(btchPowerNames, btchSelPowerIndex, arrPowerPlanNames, btchPrgPresetSel, 1)
		EnableBatchCtrls(PresetNameHwnd, btchPrgPresetSel, PwrChoiceHwnd, btchSelPowerIndex, PresetNames, 1)
		}
	}
}
else
{
	;we have just clicked a new preset after selecting another preset so set read_from_ini flag. Check for an intervening ListPrg msg!

		if (presetNoTest == 2)
		presetNoTest := 1

	foundpos := btchPrgPresetSel ; save old preset
		if (temp)
		btchPrgPresetSel := temp


	PresetNames[btchPrgPresetSel] := PresetNamesBak[btchPrgPresetSel]
	strTemp := ""


	IniReadStart:
	IniRead, temp, % PrgLnch.SelIniChoicePath, Prgs, PrgBatchIni%btchPrgPresetSel%
	sleep, 150
		if (temp == "ERROR")
		{
		retVal := TaskDialog("Ini file", "File not found", , "The active ini file cannot be found. Has it been removed or modified in some way?`nIf it cannot be located, PrgLnch will attempt to recreate the file.`nOn continuation, if the Ini file is a LnchPad Slot, Prglnch will instead be restarted, so the file can be recreated.", "", "Try to read the file again", "Continue without the file")
			if (retVal == 1)
			Goto IniReadStart
			else
			{
				if (SelIniChoiceName == "PrgLnch")
				{
				IniProcIniFileStart()
				IniProc()
				}
				else
				RestartPrgLnch(0, "PrgLnch")
			temp := ""
			}
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


			if (btchPrgPresetSel == PrgBatchIniStartup)
			GuiControl, PrgLnch:, DefPreset, 1
			else
			GuiControl, PrgLnch:, DefPreset, 0


		GuiControl, PrgLnch:, ListPrg, % PopBtchListBox(PrgChoiceNames, PrgNo, PrgMonToRn, PrgBdyBtchTog, PrgListIndex, batchPrgNo)
		GuiControl, PrgLnch: Show, ListPrg

		DoBatchPower(btchPowerNames, btchSelPowerIndex, arrPowerPlanNames, btchPrgPresetSel)



		;If PrgProperties window is showing, update it
			If (PrgProperties.Hwnd)
			PopPrgProperties(currBatchNo, btchPrgPresetSel, PrgBatchIni%btchPrgPresetSel%, PrgChoiceNames, PrgChoicePaths, PrgLnkInf, PrgResolveShortcut, IniFileShortctSep)

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
				if (PrgBdyBtchTog[A_Index] == MonStr(PrgMonToRn, temp))
				{
				currBatchNo += 1
				PrgBatchIni%btchPrgPresetSel%[currBatchNo] := PrgListIndex[A_Index]
				}
			}

			DoBatchPower(btchPowerNames, btchSelPowerIndex, arrPowerPlanNames, btchPrgPresetSel, 1)

			if (currBatchNo)
			{
			temp := ""
				Loop % maxBatchPrgs
				{
					if (A_Index > 1)
					temp := temp . ","
				temp := temp . PrgBatchIni%btchPrgPresetSel%[A_Index]
				}
			IniWrite, %temp%, % PrgLnch.SelIniChoicePath, Prgs, PrgBatchIni%btchPrgPresetSel%
			; copy active Prgs over



				if (btchPrgPresetSel == foundpos)
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
			PrgPropertiesClose()

				if (!batchActive)
				{
				EnableBatchCtrls(PresetNameHwnd, btchPrgPresetSel, PwrChoiceHwnd, btchSelPowerIndex, PresetNames, 1)
				return
				}
			}
		}


	EnableBatchCtrls(PresetNameHwnd, btchPrgPresetSel, PwrChoiceHwnd, btchSelPowerIndex, PresetNames)
	Thread, NoTimers, false

		if (IsCurrentBatchRunning(currBatchNo, PrgListPID%btchPrgPresetSel%))
		{
			batchActive := 1
			SetTimer, WatchSwitchOut, %timWatchSwitch%
		}
		else
		{
			batchActive := 0
			loop % PrgNo
			{
				if (PrgPIDMast[A_Index])
				{
				SetTimer, WatchSwitchOut, %timWatchSwitch%
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

return


DefPresetSub:
Gui, PrgLnch: Submit, Nohide

if (DefPreset)
PrgBatchIniStartup := btchPrgPresetSel
else
PrgBatchIniStartup := 0

IniWrite, %PrgBatchIniStartup%, % PrgLnch.SelIniChoicePath, Prgs, PrgBatchIniStartup
return


batchPrgStatusSub:
Gui, PrgLnch: Submit, Nohide


if (A_GuiEvent == "DoubleClick")
{

	waitBreak := 1
	Thread, NoTimers
	SetTimer, WatchSwitchBack, Delete
	SetTimer, WatchSwitchOut, Delete
	sleep, 200
	strTemp := "|"
		if (!batchPrgStatus)
		return

	; check before launching not cancelling
	temp := PrgListPID%btchPrgPresetSel%[batchPrgStatus]
	if (temp == "NS" || temp == "FAILED" || temp == "TERM" || temp == "ENDED" || !temp)
	{
	strRetVal := ChkExistingProcess(PrgLnkInf, presetNoTest, batchPrgStatus, currBatchNo, PrgBatchIni%btchPrgPresetSel%, PrgChoicePaths, IniFileShortctSep)

		if (strRetVal)
		{
			if (strRetVal == "PrgLnch")
			{
			MsgBox, 8208, PrgLnch Name, Cannot launch this Prg!
			return
			}
			if (strRetVal == "BadPath")
			return

			IniRead, fTemp, % PrgLnch.SelIniChoicePath, General, PrgAlreadyMsg
			if (!fTemp)
			{
			retVal := TaskDialog("Prg Process", "Selected Prg matches an existing process with same name", , "Might be an issue depending on instance requisites.`n" . strRetVal . ".", , "Continue Operation", "Abort Operation")
				if (retVal < 0)
				{
				retVal := -retVal
				IniWrite, %retVal%, % PrgLnch.SelIniChoicePath, General, PrgAlreadyMsg
				}
				if (retVal == 2)
				return
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

	SplashyProc("*Launching")
	sleep, % (!PrgIntervalLnch)? 2000: (PrgIntervalLnch == -1)? 4000: 6000
	targMonitorNum := PrgMonToRn[lnchPrgIndex]

	; save to old
	CopyToFromRes(targMonitorNum, 1, -1)
	StoreFetchPrgRes(1, lnchPrgIndex, PrgLnkInf, targMonitorNum)

	}
	else
	{
	lnchPrgIndex := -PrgBatchIni%btchPrgPresetSel%[batchPrgStatus]
	temp := PrgChoicePaths[-lnchPrgIndex]
	targMonitorNum := PrgMonToRn[-lnchPrgIndex]
	; restore from old
	CopyToFromRes(targMonitorNum, 1, -1)
	}

	lnchStat := 1


	strRetVal := LnchPrgOff(batchPrgStatus, lnchStat, PrgChoiceNames, temp, PrgLnkInf, PrgResolveShortcut, IniFileShortctSep, currBatchno, lnchPrgIndex, PrgCmdLine, iDevNumArray, PrgMonPID, PrgRnMinMax, PrgRnPriority, PrgBordless, borderToggle, targMonitorNum, PrgPID, PrgListPID%btchPrgPresetSel%, PrgMinMaxVar, PrgStyle, btchPowerNames[btchPrgPresetSel])


	loop % currBatchNo
	{
	strTemp2 := PrgListPID%btchPrgPresetSel%[A_Index]
		if (batchPrgStatus == A_Index)
		{
		SplashyProc("*Release")
		HideShowLnchControls(quitHwnd, GoConfigHwnd, 1)

			if (strRetVal) ;Lnch fail
			{
				if (strRetVal == "|")
				strTemp .= "Started" . strRetVal
				else
				{
					if (lnchPrgIndex > 0)
					{
					strTemp .= "Failed" . "|"
					MsgBox, 8208, Prg Launch, % strRetVal

					; restore from old
					CopyToFromRes(targMonitorNum, 0, -1)

						if (DefResNoMatchRes(1) && ChangeResolution(targMonitorNum))
						; restore from defaults on fail
						CopyToFromRes(targMonitorNum)
						else
						sleep, 300
					}
				}
			}
			else
			{
				if (lnchPrgIndex > 0)
				{
					SetResDefaults(lnchStat, targMonitorNum, scrWidthDefArr, scrHeightDefArr, scrFreqDefArr)

						if (PrgLnchHide[lnchPrgIndex])
						Gui, PrgLnch: Show, Hide
						else
						{
						WinMover(PrgLnch.Hwnd(), "d r", PrgLnchOpt.Width() * 61/80, PrgLnchOpt.Height() * 13/10)
						Gui, PrgLnch: Show,, % PrgLnch.Title
						}

					batchActive := 1
					strTemp .= "Active" . "|"
				}
				else ;  ASSUME it's cancelled: (lnchPrgIndex never 0 here)
				strTemp .= "Not Active" . "|"
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
			if (strTemp2)
			{
				if strTemp2 is digit
				strTemp .= "Active" . "|"
				else
				strTemp .= "Not Active" . "|"
			}
			else
			strTemp .= "Not Active" . "|"
		}
	}

GuiControl, PrgLnch:, batchPrgStatus, %strTemp%

;Fix buttons and timer
Thread, NoTimers, false

	if (IsCurrentBatchRunning(currBatchNo, PrgListPID%btchPrgPresetSel%))
	{
	batchActive := 1
	GuiControl, PrgLnch:, RunBatchPrg, &Cancel Batch
	waitBreak := 0
	}
	else
	batchActive := 0

	if (temp := RevertResLastPrgProc(maxBatchPrgs, PrgMonPID, , (lnchPrgIndex > 0)? 1: 0))
	{
		if (PrgChgResOnClose[abs(lnchPrgIndex)] && DefResNoMatchRes(1))
		{
			; restore from defaults when cancelling
			if (lnchPrgIndex < 0)
			CopyToFromRes(targMonitorNum)

		ChangeResolution(temp)
		sleep, 300
		}
	}


	if (batchActive)
	SetTimer, WatchSwitchOut, %timWatchSwitch%
	else
	{
	CleanupPID(currBatchNo, lastMonitorUsedInBatch, PrgMonToRn, presetNoTest, PrgListPID%btchPrgPresetSel%, PrgStyle, PrgBordless, PrgLnchHide, PrgPID, PrgChgResOnClose, selPrgChoice, waitBreak, 1)

		if (PrgPID)
		{
		waitBreak := 0
		SetTimer, WatchSwitchOut, -%timWatchSwitch%
		}
	}
}
return

PresetNameSub:
	if (ffTemp == 1) ; see ffTemp in decl list
	return

GuiControlGet, temp, PrgLnch: FocusV
if (temp == "PresetName")
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
	if (1 == A_Index)
	{
	strTemp .= PresetNames[1]
		if (strTemp)
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
IniWrite, %strTemp%, % PrgLnch.SelIniChoicePath, Prgs, PresetNames
GuiControl, PrgLnch:, BtchPrgPreset, %strRetVal%
GuiControl, PrgLnch: Enable, PresetName
ffTemp := 0
}
return

RunBatchPrgSub:

if (btchPrgPresetSel)
GoSub LnchPrgLnch

return


GoConfig:
Gui PrgLnch: +OwnDialogs

if (GoConfigTxt == "Save LnchPad")
{
ToolTip

GoConfigTxt = Prg Config
GuiControl, PrgLnch:, GoConfigVar, % "&" GoConfigTxt

	if (strLen(iniTxtPadChoice) == 1)
	{
		GuiControl, PrgLnch: Text, IniChoice,
		SetEditCueBanner(IniChoiceHwnd, "Name too short", 1)
		return
	}
	else
	SetEditCueBanner(IniChoiceHwnd, "LnchPad Slot", 1)

	Loop, % prgNo
	{
		if (iniTxtPadChoice == IniChoiceNames[A_Index])
		{
		GuiControl, PrgLnch: Text, IniChoice,
		SetEditCueBanner(IniChoiceHwnd, "Name in Use", 1)
		return
		}
		else
		SetEditCueBanner(IniChoiceHwnd, "LnchPad Slot", 1)
	}


	if (IniChoiceNames[iniSel] && IniChoiceNames[iniSel] != "ini" . iniSel)
	{
	retVal := TaskDialog("LnchPad Slot", """" . IniChoiceNames[iniSel] . """" . " already exists", , "", "", "Continue, overwriting existing data", "Abort operation")
		if (retVal == 2)
		return
	}

oldSelIniChoiceName := SelIniChoiceName
SelIniChoiceName := iniTxtPadChoice
PrgLnch.SelIniChoicePath := A_ScriptDir . "\" . SelIniChoiceName . ".ini"
oldSelIniChoicePath := A_ScriptDir . "\" . oldSelIniChoiceName . ".ini"


ChooseIniChoice(iniSel, selIniChoiceName, PrgNo, IniChoiceNames)

	;Not replacing if doesn't exist!
	if (!FileExist(oldSelIniChoicePath))
	{
	MsgBox, 8208, LnchPad File , % oldSelIniChoiceName " LnchPad file could not be found!`nCannot continue."
	return
	}
	
	if (strRetVal := MoveFileUtil(oldSelIniChoicePath, PrgLnch.SelIniChoicePath, (oldSelIniChoiceName == "PrgLnch")))
	{
	MsgBox, 8256, File Operation, % strRetVal
	iniTxtPadChoice := oldSelIniChoiceName
	GuiControl, PrgLnch: Text, IniChoice, %oldSelIniChoiceName%
	ChooseIniChoice(iniSel, oldSelIniChoiceName, PrgNo, IniChoiceNames)
	return
	}


oldSelIniChoiceName := SelIniChoiceName
oldSelIniChoicePath := PrgLnch.SelIniChoicePath

IniProcIniFile(iniSel, SelIniChoiceName, IniChoiceNames, PrgNo, strIniChoice)

GuiControl, PrgLnch:, IniChoice, %strIniChoice%
ChooseIniChoice(iniSel, selIniChoiceName, PrgNo, IniChoiceNames)
}
else
{

	if (GoConfigTxt == "Del LnchPad")
	{
	ControlSetText,,,ahk_id %IniChoiceHwnd%
	GuiControl, PrgLnch:, IniChoice,
	; iniTxtPadChoice should be null
		if (DelIniPresetProc(iniSel, GoConfigTxt, iniTxtPadChoice, SelIniChoiceName, oldSelIniChoiceName, IniChoiceNames, PrgNo, strIniChoice))
		RestartPrgLnch(0, oldSelIniChoiceName, SelIniChoiceName)
		else
		GuiControl, PrgLnch:, GoConfigVar, % "&" GoConfigTxt
	}
	else
	{

	presetNoTest := 0

	PidMaster(PrgNo, currBatchNo, btchPrgPresetSel, PrgBatchIni%btchPrgPresetSel%, PrgListPID%btchPrgPresetSel%, PrgPIDMast, 1)

	PrgPropertiesClose()

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
	Gui, PrgLnch: Show, Hide
	sleep, 10
	Gui, PrgLnchOpt: Show, NA, % PrgLnchOpt.Title
	sleep 20
	SetTaskBarIcon()
	}
}
return


PrgIntervalChk:
Gui, PrgLnch: Submit, Nohide
PrgIntervalLnch := PrgInterval
	if (PrgIntervalLnch)
	IniWrite, %PrgIntervalLnch%, % PrgLnch.SelIniChoicePath, Prgs, PrgInterval
	else
	IniWrite, %A_Space%, % PrgLnch.SelIniChoicePath, Prgs, PrgInterval
return

PresetProp:
	if (btchPrgPresetSel && currBatchNo)
	PopPrgProperties(currBatchNo, btchPrgPresetSel, PrgBatchIni%btchPrgPresetSel%, PrgChoiceNames, PrgChoicePaths, PrgLnkInf, PrgResolveShortcut, IniFileShortctSep)
return























































;IniChoice section
IniChoiceSel:
Gui, PrgLnch: Submit, Nohide
Gui PrgLnch: +OwnDialogs
Tooltip
SendMessage 0x147, 0, 0, , ahk_id %IniChoiceHwnd%  ; CB_GETCURSEL


If (ErrorLevel == "FAIL")
	{
	Gui, PrgLnch: Submit, Nohide
	MsgBox, 8192, LnchPad Slot List, CB_GETCURSEL Failed
	}
else
	{

	retVal := ErrorLevel << 32 >> 32
		if (retVal < 0) ;Did the user type?
		{
		sleep 90 ;slow down input?
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
				if (iniTxtPadChoice == "")
				{
				GoConfigTxt = Prg Config
				GuiControl, PrgLnch:, GoConfigVar, % "&" GoConfigTxt
				ControlFocus, , ahk_id %GoConfigHwnd%
				return
				}
				else
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
								return
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

				GoConfigTxt := "Save LnchPad"
				CreateToolTip("Click `" . GoConfigTxt . """" . " to save.")
				GuiControl, PrgLnch:, GoConfigVar, % GoConfigTxt
				UndoTxt := iniTxtPadChoice
				}
			}
		}
		else ; Clicked here
		{
		iniSel := retVal + 1
		ControlGetText,iniTxtPadChoice,,ahk_id %IniChoiceHwnd% ; "GuiControlGet, iniTxtPadChoice, PrgLnch:, IniChoice" fails when empty

			if (iniTxtPadChoice)
			{
				if (iniTxtPadChoice == oldSelIniChoiceName)
				return
			}
			; else ; should never get there

		GoConfigTxt = Prg Config
		GuiControl, PrgLnch:, GoConfigVar, % "&" GoConfigTxt

		strRetVal := WorkingDirectory(A_ScriptDir, 1)
		If (strRetVal)
		MsgBox, 8192, Script Directory, % strRetVal "`nCannot load LnchPad file!"
		else
		{
		IniRead, fTemp, %PrgLnchIni%, General, DefPresetSettings

			if (ChkPrgNames(iniTxtPadChoice, PrgNo, "Ini"))
			{
				; ChkPrgNames negates "PrgLnch" so...
				if (oldSelIniChoiceName == "PrgLnch")
				return
				if (!ChkPrgNames(oldSelIniChoiceName, PrgNo, "Ini"))
				{
					if (!fTemp)
					fTemp := TaskDialog("LnchPad Slot", "Initialisation Settings", , "A spare LnchPad slot has just been clicked.`nIt can be initialised with either the current or the default LnchPad.`nThe default contains global settings applied either before the first configuration of an item in the LnchPad Slot list, or after deletion of an item in the list.", , "Use current", "Use default (Recommended)")

				temp := (fTemp > 0)? 0: -fTemp

					if (abs(fTemp) == 1)
					{
					strTemp := PrgLnch.SelIniChoicePath
					SelIniChoiceName .= iniSel
					iniTxtPadChoice := SelIniChoiceName
					PrgLnch.SelIniChoicePath := A_ScriptDir . "\" . SelIniChoiceName . ".ini"


						if (strTemp2 := MoveFileUtil(strTemp, PrgLnch.SelIniChoicePath, 1))
						MsgBox, 8192, File Copy , %strTemp2%
					IniProcIniFile(iniSel, SelIniChoiceName, IniChoiceNames, PrgNo, strIniChoice, temp)
					GuiControl, PrgLnch:, IniChoice, %strIniChoice%
					GuiControl, PrgLnch: ChooseString, IniChoice, % SelIniChoiceName
					}
					else
					{
					SelIniChoiceName = PrgLnch
					; Update all ini files
					UpdateAllIni(PrgNo, iniSel, PrgLnchIni, SelIniChoiceName, IniChoiceNames, temp)
					RestartPrgLnch(0, SelIniChoiceName, iniTxtPadChoice)
					}
				}
			}
			else
			{
				if (FileExist(iniTxtPadChoice . ".ini"))
				{
				UpdateAllIni(PrgNo, iniSel, PrgLnchIni, iniTxtPadChoice, IniChoiceNames, fTemp)
				RestartPrgLnch(0, iniTxtPadChoice)
				}
				else
				{
				DelIniPresetProc(iniSel, GoConfigTxt, iniTxtPadChoice, iniTxtPadChoice, oldSelIniChoiceName, IniChoiceNames, PrgNo, strIniChoice, 1)
				return
				}			
			}
		
		oldSelIniChoiceName := SelIniChoiceName
		}
		}
	}
return


DelIniPresetProc(iniSel, ByRef GoConfigTxt, ByRef iniTxtPadChoice, ByRef SelIniChoiceName, ByRef oldSelIniChoiceName, ByRef IniChoiceNames, PrgNo, ByRef strIniChoice, DelEntryonly := "")
{
ToolTip
retVal := 0
if (DelEntryonly)
retVal := TaskDialog("LnchPad Slot", "Removal", , "", "", "Remove " . """" . SelIniChoiceName . """" . " from the list", "Retain the entry")
else
retVal := TaskDialog("LnchPad Slot", "Deletion", , "", "", "Remove the LnchPad for " . """" . SelIniChoiceName . """", "Keep the LnchPad")

	If (retVal == 1)
	{
	PrgPropertiesClose()

	IniProcIniFile(iniSel, SelIniChoiceName, IniChoiceNames, PrgNo, strIniChoice, , 1)
	oldSelIniChoiceName := SelIniChoiceName
	SelIniChoiceName := "Ini" . iniSel
	GuiControl, PrgLnch:, IniChoice, %strIniChoice%
	GuiControl, PrgLnch: Choosestring, IniChoice, % SelIniChoiceName

		if (DelEntryonly)
		SelIniChoiceName := "PrgLnch"		
		else
		{
		FileDelete, % PrgLnch.SelIniChoicePath
			if (ErrorLevel)
			MsgBox, 8192, File Delete , % PrgLnch.SelIniChoicePath " LnchPad file could not be removed!"
		retVal := 1
		sleep, 30
		}
	
	}
	else
	{
	iniTxtPadChoice := SelIniChoiceName
	GuiControl, PrgLnch: Text, IniChoice, %iniTxtPadChoice%
	}
GoConfigTxt = Prg Config
return retVal
}

UpdateAllIni(PrgNo, iniSel, PrgLnchIni, SelIniChoiceName, IniChoiceNames, DefPresetSettings := 0)
{
spr := "", strTemp := ""
IniChoicePaths := ["", "", "", "", "", "", "", "", "", "", "", ""]

	strTemp := % (SelIniChoiceName == "Ini" . iniSel)? A_Space: SelIniChoiceName
	Loop % PrgNo
	{
		if (IniChoiceNames[A_Index] == "Ini" . A_Index)
		spr .= ","
		else
		{
		spr .= IniChoiceNames[A_Index] . ","
		IniChoicePaths[A_Index] := A_ScriptDir . "\" . IniChoiceNames[A_Index] . ".ini"
		

		if (FileExist(IniChoicePaths[A_Index]))
			IniWrite, %strTemp%, % IniChoicePaths[A_Index], General, SelIniChoiceName
			else
			{
			retVal := TaskDialog("LnchPad Slot File", "LnchPad file " . """" . IniChoiceNames[A_Index] . ".ini " . """" . " not found", , "", "", "Continue updating the others (Recommended)", "Quit updating the LnchPads")
				if (retVal == 2)
				return
			}

			if (Errorlevel)
			{
			retVal := TaskDialog("LnchPad Slot File", "The LnchPad file " . """" . IniChoiceNames[A_Index] . ".ini " . """" . " cannot be updated", , "", "", "Continue updating the others (Recommended)", "Quit updating the LnchPads")
				if (retVal == 2)
				return
			}
		sleep, 10
		}
	}
	
	if (FileExist(PrgLnchIni))
	IniWrite, %strTemp%, %PrgLnchIni%, General, SelIniChoiceName
	else
	{
	MsgBox, 8208, Ini File,The PrgLnch ini file cannot be written to!
	return
	}
	if (Errorlevel)
	MsgBox, 8192, Ini File, % "The following (possibly blank) value could not be written to PrgLnch.ini:`n" strTemp
	
	
	sleep, 10
	; Trim last ","
	spr := SubStr(spr, 1, StrLen(spr) - 1)
	Loop % PrgNo
	{
		if (IniChoicePaths[A_Index] && FileExist(IniChoicePaths[A_Index]))
		{
		IniWrite, %spr%, % IniChoicePaths[A_Index], General, IniChoiceNames
		sleep, 10
		}
	}
	IniWrite, %spr%, %PrgLnchIni%, General, IniChoiceNames
	sleep, 10

	Loop % PrgNo
	{
		if (IniChoicePaths[A_Index] && FileExist(IniChoicePaths[A_Index]))
		{
		if (DefPresetSettings)
		IniWrite, %DefPresetSettings%, % IniChoicePaths[A_Index], General, DefPresetSettings
		sleep, 10
		}
	}
	if (DefPresetSettings)
	IniWrite, %DefPresetSettings%, %PrgLnchIni%, General, DefPresetSettings
	sleep, 10
}


IniProcIniFile(iniSel, ByRef SelIniChoiceName, ByRef IniChoiceNames, PrgNo, ByRef strIniChoice, defPresetSettings := 0,removeIni := 0, forcePrgLnchRead := 0)
{
strTemp := "", spr := "", strRetVal := "", foundPos := 0
PrgLnchPath := A_ScriptDir . "\" . SubStr(A_ScriptName, 1, -3 ) . "ini"
if (iniSel)
{
	if (removeIni)
	{
	strTemp := "Ini" . iniSel
	SelIniChoiceName = PrgLnch
	IniChoiceNames[iniSel] := strTemp
	}
	else
	{
	IniChoiceNames[iniSel] := SelIniChoiceName
	strTemp := SelIniChoiceName
	}

	foundPos := InStr(strIniChoice, "|", false, 1, iniSel)

	spr := SubStr(strIniChoice, 1, foundPos) . strTemp
	;Bar is  to replace, not append  the  gui control string
	foundPos := InStr(strIniChoice, "|", false, foundPos + 1)
	strIniChoice := spr . SubStr(strIniChoice, foundPos)

	UpdateAllIni(PrgNo, iniSel, PrgLnchPath, SelIniChoiceName, IniChoiceNames, defPresetSettings)
}
else ; Read in names
{
PrgLnch.SelIniChoicePath := A_ScriptDir . "\" . SelIniChoiceName . ".ini"

;Update PrgLnch.ini & SelIniChoiceName.ini with IniChoiceNames list
IniRead, strTemp, % PrgLnch.SelIniChoicePath, General, SelIniChoiceName
sleep 30
IniRead, spr, % PrgLnch.SelIniChoicePath, General, IniChoiceNames

If (!strTemp || forcePrgLnchRead)
strTemp = PrgLnch

if (!FileExist(A_ScriptDir . "\" . strTemp . ".ini"))
strRetVal := "Ini file for " . """" . strTemp . """" . " not found!"

if (strTemp == "Error" && spr == "Error")
; *Assume*  old version of PrgLnch
strRetVal .= "Ini file for " . """" . strTemp . """" . "cannot be read!"

if (!strRetVal)
{
	if (spr != "Error")
	{
	; Reset all
		if (strTemp != "PrgLnch" && strTemp != "Error")
		{
		SelIniChoiceName := strTemp
		PrgLnch.SelIniChoicePath := A_ScriptDir . "\" . SelIniChoiceName . ".ini"
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
		SplitPath, % PrgLnch.SelIniChoicePath, , , , SelIniChoiceName


	}
	else
	strRetVal := "LnchPad file for " . """" . strTemp . """" . "is in error- Reverting to PrgLnch.ini."
}

}
return strRetVal
}
WriteIniChoiceNames(IniChoiceNames, PrgNo, ByRef strIniChoice, PrgLnchIni)
{
spr := ""
strIniChoice := "|" ; Global variable

	loop % PrgNo
	{
		if (IniChoiceNames[A_Index] == "Ini" . A_Index)
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
spr := Substr(spr, 1, InStr(spr, ",",, 0) -1)
IniWrite, %spr%, %PrgLnchIni%, General, IniChoiceNames
}

FindFreeLnchPadSlot(PrgNo, IniChoiceNames)
{
	loop, % PrgNo
	{
	if (IniChoiceNames[A_Index] == "Ini" . A_Index)
	return A_Index
	}
return 0
}				

ChooseIniChoice(ByRef iniSel, selIniChoiceName, PrgNo, IniChoiceNames)
{
	if (selIniChoiceName == "PrgLnch")
	{
		if (!iniSel)
		iniSel := FindFreeLnchPadSlot(PrgNo, IniChoiceNames)

		if (iniSel)
		GuiControl, PrgLnch: ChooseString, IniChoice, % "Ini" . iniSel
		else
		MsgBox, 8192, LnchPad Slots, Slots full: Unexpected error.
	}
	else
	GuiControl, PrgLnch: Choosestring, IniChoice, % selIniChoiceName
}
































































;More Frontend functions
LnchLnchPad(SelIniChoiceName)
{
ERROR_FILE_NOT_FOUND := 0x2
ERROR_ACCESS_DENIED := 0x5
ERROR_CANCELLED := 0x4C7
strTemp := ""

PrgPropertiesClose()

Gui, PrgLnch: +Disabled

strRetVal := WorkingDirectory(A_ScriptDir, 1)


	If (strRetVal)
	MsgBox, 8192, Script Directory, % strRetVal "`nCannot load LnchPad file!"
	else
	{
	FileInstall LnchPadInit.exe, LnchPadInit.exe
	Sleep, 750

	strTemp2 := A_ScriptDir . "\LnchPadInit.exe"

		if (!A_IsAdmin)
		{
		retVal := TaskDialog("LnchPad Setup Elevated", "Admin is required for full functionality", , "", "", "Restart LnchPad Setup as Admin", "Try it without Admin")
			if (retVal == 1)
			strTemp2 := "*runAs " . strTemp2
		SplashImage, LnchPadCfg.jpg, A B,,, LnchPadCfg
		}


	strTemp := PrgLnchOpt.scrWidthDef . "," . PrgLnchOpt.scrHeightDef . "," . PrgLnchOpt.scrFreqDef . "," . 0

	RunWait, %strTemp2% %strTemp% %SelIniChoiceName%, , UseErrorLevel

		if (A_LastError)
		{
			Switch, A_LastError
			{
			Case 0x2:
			strTemp := ERROR_FILE_NOT_FOUND
			Case 0x5:
			strTemp := ERROR_ACCESS_DENIED
			Case 0x4C7:
			strTemp := ERROR_CANCELLED
			}
		MsgBox, 8192, Error, % "LnchPadInit will not run. Code: " (strTemp? strTemp: A_LastError)
		strTemp := "Error"
		}
	}
Gui, PrgLnch: -Disabled
DetectHiddenWindows, On

PrgLnch.Activate()

DetectHiddenWindows, Off
return strTemp
}

HideShowLnchControls(quitHwnd, GoConfigHwnd, showCtl := 0)
{
if (showCtl)
	{
	GuiControl, PrgLnch: Show, PresetLabel
	GuiControl, PrgLnch: Show, ListPrg
	GuiControl, PrgLnch: Show, MovePrg
	GuiControl, PrgLnch: Show, PresetName
	GuiControl, PrgLnch: Show, BtchPrgPreset
	GuiControl, PrgLnch: Show, PwrChoice
	GuiControl, PrgLnch: Show, RunBatchPrg
	GuiControl, PrgLnch: Show, % GoConfigHwnd
	GuiControl, PrgLnch: Show, IniChoice
	GuiControl, PrgLnch: Show, LnchPadConfig
	GuiControl, PrgLnch: Show, % quitHwnd
	}
	else
	{
	GuiControl, PrgLnch: Hide, PresetLabel
	GuiControl, PrgLnch: Hide, ListPrg
	GuiControl, PrgLnch: Hide, MovePrg
	GuiControl, PrgLnch: Hide, PresetName
	GuiControl, PrgLnch: Hide, BtchPrgPreset
	GuiControl, PrgLnch: Hide, PwrChoice
	GuiControl, PrgLnch: Hide, RunBatchPrg
	GuiControl, PrgLnch: Hide, % GoConfigHwnd
	GuiControl, PrgLnch: Hide, IniChoice
	GuiControl, PrgLnch: Hide, LnchPadConfig
	GuiControl, PrgLnch: Hide, % quitHwnd
	}
}

IsCurrentBatchRunning(currBatchNo, PrgListPIDbtchPrgPresetSel)
{
strTemp := 0
; return 1 if any running
	if (currBatchNo && PrgListPIDbtchPrgPresetSel)
	{
		Loop % currBatchNo
		{
			strTemp := PrgListPIDbtchPrgPresetSel[A_Index]
			if (strTemp)
			{
				if strTemp is digit
				return 1
			}
		}
	}
return 0
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
			if (temp == PrgListIndex[A_Index])
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
		if (PrgListIndex[A_Index] == PrgBatchInibtchPrgPresetSel[temp])
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
EnableBatchCtrls(PresetNameHwnd, btchPrgPresetSel, PwrChoiceHwnd, btchSelPowerIndex, PresetNames, disableThem := 0)
{
if (disableThem)
	{
	GuiControl, PrgLnch: Disable, RunBatchPrg
	GuiControl, PrgLnch: Disable, DefPreset
	GuiControl, PrgLnch:, DefPreset, 0
	GuiControl, PrgLnch: Disable, PresetName
	GuiControl, PrgLnch: Disable, PresetProp
	Gui, PrgLnch: Font, cA96915
	GuiControl, PrgLnch: Font, PresetLabel
	GuiControl, PrgLnch: Disable, PwrChoice
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
		GuiControl, PrgLnch: Enable, PresetProp
		Gui, PrgLnch: Font, cTeal Bold, Verdana
		GuiControl, PrgLnch:, PresetLabel, Preset Selected
		GuiControl, PrgLnch: Font, PresetLabel
		GuiControl, PrgLnch: Enable, PwrChoice
			if (btchSelPowerIndex > 0)
			{
				if (btchSelPowerIndex)
				GuiControl, PrgLnchOpt: ChooseString, PwrChoice, %btchSelPowerIndex%
				else
				SetEditCueBanner(PwrChoiceHwnd, "Batch Power Plan", 1)
			}

			if (PresetNames[btchPrgPresetSel])
			GuiControl, PrgLnch:, PresetName, % PresetNames[btchPrgPresetSel]
			else
			{
			GuiControl, PrgLnch:, PresetName, 
			sleep, 120
			SetEditCueBanner(PresetNameHwnd, "Preset Name")
			}
		}
		;else: No batch preset- so do little
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
			if (PrgBdyBtchTog[A_Index] == strTemp2)
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
return "*" . PrgMonToRn[selPrgChoice] . "*"
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
				if temp is digit
				PrgPIDMast[temp] := PrgListPIDbtchPrgPresetSel[A_Index]
			}
		}

	 ; sanitize master last
	loop % PrgNo
	{
		temp := PrgPIDMast[A_Index]
		if (temp)
		{
			if (!WinExist("ahk_pid" . temp))
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
			if (!WinExist("ahk_pid" . temp))
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


IniProcIniFileStart()
{
Global
strRetVal := IniProcIniFile(0, SelIniChoiceName, IniChoiceNames, PrgNo, strIniChoice)

	if (strRetVal)
	{
	msgbox, 8192 , LnchPad Ini File, % strRetVal
	oldSelIniChoiceName := selIniChoiceName
	PrgLnch.SelIniChoicePath := PrgLnchIni
	IniProcIniFile(0, SelIniChoiceName, IniChoiceNames, PrgNo, strIniChoice, , , (PrgLnch.SelIniChoicePath == PrgLnchIni))
		Loop, % PrgNo
		{
			if (IniChoiceNames[A_Index] == oldSelIniChoiceName)
			{
			IniChoiceNames[A_Index] := "Ini" . A_Index
			inisel := A_Index
			Break
			}
		}
	WriteIniChoiceNames(IniChoiceNames, PrgNo, strIniChoice, PrgLnchIni)
	IniWrite, %A_Space%, % PrgLnch.SelIniChoicePath, General, SelIniChoiceName
	}


oldSelIniChoiceName := selIniChoiceName
	Loop % PrgNo
	{
		if (IniChoiceNames[A_Index] == SelIniChoiceName)
		{
		iniSel := A_Index
		Break
		}
	}
}


KleenupPrgLnchFiles(RecycleDir := "")
{
namesToDel := ["PrgLnch.ico", "PrgLnch.chm", "PrgLnch.chw", "taskkillPrg.bat", "LnchPadInit.exe"]

temp := ""
KleenupPrgLnchFiles := ""

; Keep files if debugging
if (!A_IsCompiled)
return

For eachNameToDel in namesToDel
{
strTemp := RecycleDir . namesToDel[A_Index]

	if (FileExist(strTemp))
	{
		if (RecycleDir)
		{
		KleenupPrgLnchFiles .= temp . namesToDel[A_Index]
		FileRecycle, % strTemp
			if (!temp)
			temp := ", "
		}
		else
		FileDelete, % namesToDel[A_Index]
	}
}
return KleenupPrgLnchFiles

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
FileMove(Src, Dst, Overwrite := 0)
{
strRetVal := ""
	Try
	{
	FileMove, %Src%, %Dst%, %Overwrite%
	}
	Catch e
	{
	strRetVal := Dst . " could not be moved with error: " . e
	}
return strRetVal
}



MoveFileUtil(Src, Dst, CopySrc := 0)
{
(CopySrc)? Action := "Copy": Action := "Move"

	if (FileExist(Dst))
	{
		retVal := TaskDialog("File Operation", """" . Dst . """" . "`nalready exists", , "", "", "Replace the file", "Do not replace the file")
			if (retVal == 1)
			strRetVal := File%Action%(Src, Dst, 1)
			else
			strRetVal := "Operation cancelled"
	}
	else
	strRetVal := File%Action%(Src, Dst)

return strRetVal


}

WM_HELP(wp_notused, lParam, _msg, _hwnd)
{
Global
retVal := 0


local Size         := NumGet(lParam +  0, "uint")
local ContextType  := NumGet(lParam +  4, "int")
local CtrlId       := Numget(lParam +  8, "int")
local ItemHandle   := Numget(lParam + 12 + 64bit * 4, "ptr")
local ContextId    := NumGet(lParam + 16 + 64bit * 8, "uint")
local MousePosX    := NumGet(lParam + 20 + 64bit * 8, "int")
local MousePosY    := NumGet(lParam + 24 + 64bit * 8, "int")

;This key must be set to 1!
;HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced >> EnableBalloonTips

	switch (ItemHandle)
	{
	case PresetPropHwnd:
	retVal := RunChm("PrgLnch Batch`\PrgLnch Batch", "PresetProperties")
	case PresetNameHwnd:
	retVal := RunChm("PrgLnch Batch`\PrgLnch Batch", "BatchPresetName")
	case PresetHwnd:
	retVal := RunChm("PrgLnch Batch`\PrgLnch Batch", "BatchPresets")
	case DefPresetHwnd:
	retVal := RunChm("PrgLnch Batch`\PrgLnch Batch", "ThisPresetatLoad")
	case BtchPrgHwnd:
	retVal := RunChm("PrgLnch Batch`\PrgLnch Batch", "BatchPrgs")
	case MovePrgHwnd:
	retVal := RunChm("PrgLnch Batch`\PrgLnch Batch", "BatchPrgs")
	case batchPrgStatusHwnd:
	retVal := RunChm("PrgLnch Batch`\PrgLnch Batch", "PrgStatus")
	case PrgIntervalHwnd:
	retVal := RunChm("PrgLnch Batch`\PrgLnch Batch", "PrgLnchInterval")
	case PwrChoiceHwnd:
	retVal := RunChm("PrgLnch Batch`\PrgLnch Batch", "PowerPlans")
	case RunBatchPrgHwnd:
	retVal := RunChm("PrgLnch Batch`\PrgLnch Batch", "RunBatch")
	case GoConfigHwnd:
	retVal := RunChm("PrgLnch Batch`\PrgLnch Batch", "PrgConfig")
	case IniChoiceHwnd:
	retVal := RunChm("PrgLnch Batch`\PrgLnch Batch", "LnchPadSlots")
	case LnchPadConfigHwnd:
	retVal := RunChm("PrgLnch Batch`\PrgLnch Batch", "LnchPadConfig")
	case quitHwnd:
	retVal := RunChm("PrgLnch Batch`\PrgLnch Batch", "QuitPrgLnch")
	case PrgChoiceHwnd:
	retVal := RunChm("PrgLnch Config`\PrgLnch Config", "ShortcutSlots")
	case MkShortcutHwnd:
	retVal := RunChm("PrgLnch Config`\PrgLnch Config", "ModifyShortcut")
	case cmdLinHwnd:
	retVal := RunChm("PrgLnch Config`\PrgLnch Config", "CmdLineExtras")
	case MonitorsHwnd:
	retVal := RunChm("PrgLnch Config`\PrgLnch Config", "MonitorName")
	case DevNumHwnd:
	retVal := RunChm("PrgLnch Config`\PrgLnch Config", "MonitorList")
	case resolveShortctHwnd:
	retVal := RunChm("PrgLnch Config`\PrgLnch Config", "ResolveShortcut")
	case TestHwnd:
	retVal := RunChm("PrgLnch Config`\PrgLnch Config", "TestMode")
	case FModeHwnd:
	retVal := RunChm("PrgLnch Config`\PrgLnch Config", "ChangeAtEveryMode")
	case DynamicHwnd:
	retVal := RunChm("PrgLnch Config`\PrgLnch Config", "Dynamic")
	case TmpHwnd:
	retVal := RunChm("PrgLnch Config`\PrgLnch Config", "Temporary")
	case RegoHwnd:
	retVal := RunChm("PrgLnch Config`\PrgLnch Config", "PullValuesFromRegistry")
	case currResHwnd:
	retVal := RunChm("PrgLnch Config`\PrgLnch Config", "DefaultResolution")
	case allModesHwnd:
	retVal := RunChm("PrgLnch Config`\PrgLnch Config", "ListAllCompatible")
	case ResIndexHwnd:
	retVal := RunChm("PrgLnch Config`\PrgLnch Config", "ResolutionModes")
	case ChgResOnCloseHwnd:
	retVal := RunChm("PrgLnch Config`\PrgLnch Config", "ChgResOnClose")
	case ChgResOnSwitchHwnd:
	retVal := RunChm("PrgLnch Config`\PrgLnch Config", "ChgResOnSwitch")
	case PrgMinMaxHwnd:
	retVal := RunChm("PrgLnch Config`\PrgLnch Config", "MinMax")
	case PrgPriorityHwnd:
	retVal := RunChm("PrgLnch Config`\PrgLnch Config", "Priority")
	case BordlessHwnd:
	retVal := RunChm("PrgLnch Config`\PrgLnch Config", "Borderless")
	case PrgLnchHdHwnd:
	retVal := RunChm("PrgLnch Config`\PrgLnch Config", "HidePrgLnchonRun")
	case DefaultPrgHwnd:
	retVal := RunChm("PrgLnch Config`\PrgLnch Config", "ShowAtStartup")
	case PrgLAAHwnd:
	retVal := RunChm("PrgLnch Config`\PrgLnch Config", "ApplyLAAFlag")
	case RnPrgLnchHwnd:
	retVal := RunChm("PrgLnch Config`\PrgLnch Config", "TestRunPrg")
	case UpdturlHwnd:
	retVal := RunChm("PrgLnch Config`\PrgLnch Config", "UrlName")
	case UpdtPrgLnchHwnd:
	retVal := RunChm("PrgLnch Config`\PrgLnch Config", "UpdatePrg")
	case newVerPrgHwnd:
	retVal := RunChm("PrgLnch Config`\PrgLnch Config", "PrgUpdateStatus")
	case BackToPrgLnchHwnd:
	retVal := RunChm("PrgLnch Config`\PrgLnch Config", "BackToPrglnch")
	default:
	retVal := RunChm()
	}

	if (retVal) ; error
	{
		if (retVal < 0)
		MsgBox, 8192, PrgLnch Help, Could not find the Help file. Has it, or the script been moved?
		else
		MsgBox, 8192, PrgLnch Help, There is a problem with the help file. Code: %retVal%.
	}

}
WM_SYSCOMMAND(wParam)
{
temp := 0
    if (A_Gui && wParam == 0xF060) ; SC_CLOSE Thanks Lex
    {
		WinGet, temp, , A ;or WinGetActive
		if (temp == PrgLnchOpt.Hwnd() || temp == PrgLnch.Hwnd())
		return 0
		; else destroys PrgProperties.Hwnd anyhow
    }
}
RunChm(chmTopic := 0, Anchor := "")
{
static firstRun := 0, htmlHelp := "C:\Windows\hh.exe ms-its"
x := 0, y := 0, w := 0, h := 0, hAdj := 0
temp := 0, retVal := 0, notPrgLnchGui := 0, wndStat := 0


if (!FileExist(A_ScriptDir . "\PrgLnch.chm"))
return -1

retVal := CloseChm()

	strTemp := A_CoordModeMouse
	CoordMode, Mouse, Screen
	WinGetPos, x, y, w, h, A
	CoordMode, Mouse, % strTemp


	if (WinActive("A") == PrgLnchOpt.Hwnd())
	hAdj := 2 * h
	else
	{
		if (WinActive("A") == PrgLnch.Hwnd())
		hAdj := floor(3 * h/2)
		else
		{
			; not the optimal check
			if (WinExist(PrgLnch.ProcAHK))
			{
				if (WinExist("Monitors"))
				wndStat := 1
				else
				{
				if (WinExist("Res. Report"))
				wndStat := 2
				}
			}
			else
			{
			wndStat := -1
			hAdj := h
			}
		}
	}

	if (chmTopic)
	{
		if (chmTopic == "Welcome")
		{
			if (firstRun == 1)
			return
			else
			firstRun := 1
		}
		run, %htmlHelp%:%A_ScriptDir%\PrgLnch.chm::/%chmTopic%.htm#%Anchor%,, UseErrorLevel
	}
	else
	run, %htmlHelp%:%A_ScriptDir%\PrgLnch.chm::/About%A_Space%PrgLnch.htm,, UseErrorLevel

sleep, 120


if (!A_LastError) ; uses last found window
{
temp := 0

	Loop
	{
	Sleep 30
	temp++
		if (temp == 1000)
		{
		retVal := TaskDialog("PrgLnch Help", "Help is slow to launch", , "", "", "Wait for help", "Do not wait for help")
			if (retVal == 1)
			temp := 0
			else
			Break
		}
	} Until (WinActive("PrgLnch_Help"))

WinGetTitle, strtemp , A

	; Too bad if we missed it
	if (strtemp == "PrgLnch_Help")
	{
		if (!retVal) ; no chm closed!
		{
		;if  not maximised
		WinGet, temp, MinMax
		;Tablet mode perhaps? https://autohotkey.com/boards/viewtopic.php?f=6&t=15619
		;We are launching as "normal" but just in case this is overidden by user modifying shortcut properties. (probably not)
			if (!temp)
			{
			WinRestore
			sleep, 60
			}

		SysGet, md, MonitorWorkArea, % PrgLnch.Monitor

		scrWd := mdRight - mdleft
		scrHt := mdBottom - mdTop

		if (wndStat)
		{
			if (wndStat == 1)
			{
			w := 5/4 * Splashy.vImgW
			x := mdRight - (scrWd - w)/2
			hAdj := 2 * Splashy.vImgH
			y := mdTop + (scrHt - hAdj)/2
			}
			else
			{
			w := 3.5 * Splashy.vImgW
			x := mdRight - (scrWd - w)/2
			hAdj := 2.5 * Splashy.vImgH
			y := mdTop + (scrHt - hAdj)/2
			}
		}
		else
		{
			if (y + h > scrHt)
			y := scrHt - h
			else
			{
				if (y - hAdj < 0)
				y += h + hAdj
			}

			;y -= floor(y/10)

			if (x + w > scrWd)
			x := scrWd - w
			else
			{
				if (x < 0)
				x := 0
			}
		y := y - hAdj
		}		

		if (wndStat > -1)
		WinMove, A, , %x%, %y%, %w%, %hAdj%

		}
		; else just use last help co-ords: not covering the case when the gui is moved while the help file is open, and not moved
	}
	else
	{
	retVal := -1
	return retVal
	}
}

return A_LastError 
}

CloseChm()
{
;Close existing
retVal := 0
WinGet, temp, List
	Loop, %temp%
	{
	fTemp := temp%A_Index%
	WinGetTitle, strTemp, % "ahk_id " fTemp

		if (strTemp == "PrgLnch_Help")
		{
		retVal := 1
		WinClose, ahk_id %fTemp%
		}
	}
Sleep 30
return retVal
}

RnChmWelcome:
	if (WinExist(PrgLnch.ProcAHK) && (WinActive("A") == PrgLnch.Hwnd() || WinActive("A") == PrgLnchOpt.Hwnd() || WinExist("Monitors") || WinExist("Res. Report")))
	{
	RunChm("Welcome")
	SetTimer, RnChmWelcome, Delete
	}
return























































; Power:
DopowerPlan(planToChangeTo := "")
{

Static oldSchemeGUID := 0, currSchemeGUID := 0, oldDesc := "", plan := "", arrPowerPlanNames := []
temp := 0, strTemp := "", strTemp2 := " call of PowerReadFriendlyName failed with "


if (!planToChangeTo)
{
	; Restore old scheme on close
	if (oldDesc)
	{

		if (currSchemeGUID != oldSchemeGUID)
		{
		temp := Dllcall("powrprof.dll\PowerSetActiveScheme", "Ptr", 0, "Ptr", oldSchemeGUID, "Uint")
			if (temp)
			MsgBox, 8240, Power Error, % "Error with PowerSetActiveScheme on default plan: " temp
		}
	VarSetCapacity(oldDesc, 0)
	VarSetCapacity(oldSchemeGUID, 0)
	VarSetCapacity(currSchemeGUID, 0)
	arrPowerPlanNames := ""
	return
	}

}



ACCESS_SCHEME := 16 ; For PowerEnumerate
VarSetCapacity(desc, szdesc := 1024)
VarSetCapacity(schemeGUID, szguid := 16)
	if (!oldDesc)
	{
	VarSetCapacity(oldDesc, szdesc)
	VarSetCapacity(oldSchemeGUID, szguid)
	; currSchemeGUID shadows the scheme in current use, thus prevents
	; an extra call of PowerSetActiveScheme on exit when no Batch is run.
	VarSetCapacity(currSchemeGUID, szguid)
	arrPowerPlanNames[1] := "Default"
	}


if (!oldDesc) ; assume oldDesc memset 0
{
	; GetActivePwrScheme the older flavour
	temp := DllCall("powrprof\PowerGetActiveScheme", "Ptr", 0, "Ptr*", oldSchemeGUID, "Uint")
		if (temp)
		strTemp := "Error with GetActivePwrScheme on default plan: " . temp

	temp := Dllcall("powrprof.dll\PowerReadFriendlyName", "Ptr", 0, "Ptr", oldSchemeGUID, "Ptr", 0, "Ptr", 0, "Ptr", 0, "Ptr*", szdesc) ;sdesc :LPDWORD
		if (temp != 0)
		{
		strTemp .= "`nFirst" . strTemp2 . temp . "."
		}
	
	temp := Dllcall("powrprof.dll\PowerReadFriendlyName", "Ptr", 0, "Ptr", oldSchemeGUID, "Ptr", 0, "Ptr", 0, "str", oldDesc, "Ptr*", szdesc) ;use the updated szdesc from first call of fn
		if (temp != 0)
		{
		strTemp .= "`nSecond" . strTemp2 . temp . "."
		}

	currSchemeGUID := oldSchemeGUID

}


Loop
{
	;Consider GetProcAddress for repeated calls
	r := Dllcall("powrprof.dll\PowerEnumerate", "Ptr", 0, "Ptr", 0, "Ptr", 0, "Uint", ACCESS_SCHEME, "Uint", A_Index-1, "Ptr", &schemeGUID, "Uint*", szguid) ;DWORD
		if (r != 0)
		break


	temp := Dllcall("powrprof.dll\PowerReadFriendlyName", "Ptr", 0, "Ptr", &schemeGUID, "Ptr", 0, "Ptr", 0, "Ptr", 0, "Ptr*", szdesc) ;sdesc :LPDWORD
		if (temp != 0)
		{
		strTemp .= "`nThird" . strTemp2 . temp . "."
		}
	
	temp := Dllcall("powrprof.dll\PowerReadFriendlyName", "Ptr", 0, "Ptr", &schemeGUID, "Ptr", 0, "Ptr", 0, "str", desc, "ptr*", szdesc) ;use the updated szdesc from first call of fn
		if (temp != 0)
		{
		strTemp .= "`nFourth" . strTemp2 . temp . "."
		}


	plan .= A_Index-1 " - " desc "`n"

	if (planToChangeTo)
	{
		if (desc == planToChangeTo || planToChangeTo == "Default")
		{
		temp := Dllcall("powrprof.dll\PowerSetActiveScheme", "Ptr", 0, "Ptr", (planToChangeTo == "Default")? oldSchemeGUID: &schemeGUID, "Uint")
			if (temp)
			strTemp .= "`nError with PowerSetActiveScheme on new plan: " . temp
			else
			{
			temp := DllCall("powrprof\PowerGetActiveScheme", "Ptr", 0, "Ptr*", currSchemeGUID, "Uint")
				if (temp)
				strTemp := "Error with GetActivePwrScheme on CHANGED plan: " . temp
			}
		r := 259
		Break
		}
	}
	else ; just enumerate and fill on first call
	arrPowerPlanNames[A_Index + 1] := desc

}

	if (r != 259)  ;ERROR_NO_MORE_ITEMS- (should never get here)
	strTemp .= "`nError in Power Plan Enumeration: " . r



VarSetCapacity(schemeGUID, 0)
VarSetCapacity(desc, 0)

	; If only one entry (Balanced) then it's a Modern Standby or "S0 Low Power Idle" install, not the usual S3 Sleep state!. Other power schemes may not be created.
	if (arrPowerPlanNames.Length() <= 2) ; Final call to function
	{
	VarSetCapacity(oldDesc, 0)
	VarSetCapacity(oldSchemeGUID, 0)
	VarSetCapacity(currSchemeGUID, 0)
	}

	if (strTemp)
	msgbox, 8240, Power Error, % strTemp

	if (planToChangeTo)
	return 0
	else
	return arrPowerPlanNames

}

DoBatchPower(ByRef btchPowerNames, ByRef btchSelPowerIndex, arrPowerPlanNames, btchPrgPresetSel, toPreset := 0)
{
strTemp := "", strRetVal := "|"


if (btchSelPowerIndex)
{
	if (!btchPrgPresetSel)
	return

	if (toPreset)
	{
	; Safest to use defaults
	btchPowerNames[btchPrgPresetSel] = "Default"
	btchSelPowerIndex := 1
	strTemp := join(btchPowerNames)
	IniWrite, %strTemp%, % PrgLnch.SelIniChoicePath, Prgs, BatchPowerNames
	}
	else
	{
	temp := 0
	IniRead, strTemp, % PrgLnch.SelIniChoicePath, Prgs, BatchPowerNames
		Loop, parse, strTemp, CSV
		{
		btchPowerNames[A_Index] := A_Loopfield
		}

		loop, % arrPowerPlanNames.Length()
		{
			if (btchPowerNames[btchPrgPresetSel] == arrPowerPlanNames[A_Index])
			{
			btchSelPowerIndex := A_Index
			temp := 1
			}
		}
		if (!temp)
		NoPowerPlan(btchPowerNames, btchSelPowerIndex, btchPrgPresetSel)
	}
}
else
{
	if (arrPowerPlanNames.Length() > 2)
	{
	
		if (!btchPrgPresetSel)
		{
		;Initial values
		btchSelPowerIndex := 1
		temp := 1
		}

		Loop, % arrPowerPlanNames.Length()
		{
			if (btchPowerNames[btchPrgPresetSel] == arrPowerPlanNames[A_Index])
			{
				if (btchPrgPresetSel)
				btchSelPowerIndex := A_Index
				else
				btchSelPowerIndex := 1
			temp := 1
			}
		strRetVal .= arrPowerPlanNames[A_Index] . "|"
		}

		if (!temp)
		NoPowerPlan(btchPowerNames, btchSelPowerIndex, btchPrgPresetSel)
	strTemp := join(btchPowerNames)
	IniWrite, %strTemp%, % PrgLnch.SelIniChoicePath, Prgs, BatchPowerNames
	GuiControl, PrgLnch:, PwrChoice, %strRetVal%
	}
	else
	btchSelPowerIndex := -2147483647
}
GuiControl, PrgLnch: Choose, PwrChoice, % btchSelPowerIndex
}

NoPowerPlan(ByRef btchPowerNames, ByRef btchSelPowerIndex, btchPrgPresetSel)
{
retVal := TaskDialog("Power Plans", "Power Plan not detected", , "A power plan has been removed or its name has changed, either through Windows Settings or by another program.", "", "Restart PrgLnch to refresh the list", "Use Default Plan instead")
	if (retVal == 1)
	RestartPrgLnch(0)
	else
	{
	btchPowerNames[btchPrgPresetSel] := "Default"
	btchSelPowerIndex := 1
	}
}































; Task dialog
TaskDialog(pageTitle := "Page Title", instructionTitle := "Description of issue", description := "Choose one of the following options:", expandedText := "More Information with a <A HREF=""http://www.some_link.com"">Link</a>", checkText := "Do not show this again", choice1 := "", choice2 := "", choice3 := "", choice4 := "")
{
; This function requires A_Unicode and Vista or later.
Static FooterText := ""
; Error Flags
Static S_OK = 0x0, E_OUTOFMEMORY = 0x8007000E, E_INVALIDARG = 0x80070057, E_FAIL = 0x80004005, E_ACCESSDENIED = 0x80070005

;General Flags
Static flags = 0x1011, TDF_VERIFICATION_FLAG_CHECKED = 0x0100, TDF_CALLBACK_TIMER := 0X0800

; 0x1	:		TDF_ENABLE_HYPERLINKS
; 0X0010:		TDF_USE_COMMAND_LINKS
; 0x1000:		TDF_POSITION_RELATIVE_TO_WINDOW (else the monitor)
; 0x1000000:	TDF_SIZE_TO_CONTENT


	if InStr(pageTitle, "Same Resolution")
	flags |= TDF_VERIFICATION_FLAG_CHECKED
	else
	{
		if InStr(pageTitle, "Downloading Prg")
		{
		FooterText := "Download will abort in: "
		flags |= TDF_CALLBACK_TIMER
		}
	}



CustomButtons := []

hwndParent := WinExist("A")
;	; Do not invoke .Hwnd() unless form is initialised
	if (hwndParent != PrgLnch.PrgHwnd && hwndParent != PrgLnchOpt.PrgHwnd)
	{
	DetectHiddenWindows, On
	if (!(WinExist("ahk_id" . PrgLnch.PrgHwnd) || WinExist("ahk_id" . PrgLnchOpt.PrgHwnd)))
	MsgBox, 8192, Task Dialog, Informational: PrgLnch form AWOL:`nNo parent window for dialog.
	DetectHiddenWindows, Off
	hwndParent := 0
	}

	if (!(TDCallback := RegisterCallback("TDCallback", "Fast")))
	{
		MsgBox, 8208, Task Dialog, Could not Register Callback for the Task dialog.
		return 0
	}

	While (tp := choice%A_Index%)
	CustomButtons.Push(100 + A_Index, tp)


cButtons := CustomButtons.Length()/2
VarSetCapacity(pButtons, 4 * cButtons + A_PtrSize * cButtons, 0)

	loop %cButtons%
	{
	iButtonID := CustomButtons[2 * A_Index -1]
	iButtonText := &(b%A_Index% := CustomButtons[2 * A_Index])
	NumPut(iButtonID,   pButtons, (4 + A_PtrSize) * (A_Index - 1), "Int")
	NumPut(iButtonText, pButtons, (4 + A_PtrSize) * A_Index - A_PtrSize, "Ptr")
	}


; TASKDIALOGCONFIG structure
	if (A_PtrSize == 8) ; X64
	{
	NumPut(VarSetCapacity(TDC, 160, 0), TDC, 0, "UInt") ; cbSize
	NumPut(hwndParent, TDC, 4, "Ptr") ; hwndParent
	;  HINSTANCE
	NumPut(flags, TDC, 20, "Int") ; dwflags
	NumPut(&pageTitle, TDC, 28, "Ptr") ; pszWindowTitle
	NumPut(&instructionTitle, TDC, 44, "Ptr") ; pszMainInstruction
	NumPut(&description, TDC, 52, "Ptr") ; pszContent
	NumPut(cButtons, TDC, 60, "UInt") ; cButtons
	NumPut(&pButtons, TDC, 64, "Ptr") ; pButtons
	NumPut(&checkText, TDC, 92, "Ptr") ; pszVerificationText
	NumPut(&ExpandedText, TDC, 100, "Ptr") ; pszExpandedInformation
	NumPut(&FooterText, TDC, 132, "Ptr") ; pszFooter
	NumPut(TDCallback, TDC, 140, "Ptr") ; pfCallback
	}
	else
	{
	NumPut(VarSetCapacity(TDC, 96, 0), TDC, 0, "UInt") ; cbSize
	NumPut(hwndParent, TDC, 4, Ptr) ; hwndParent
	;  HINSTANCE
	NumPut(flags, TDC, 12, "Int") ; dwflags
	NumPut(&pageTitle, TDC, 20, "UInt") ; pszWindowTitle
	NumPut(&instructionTitle, TDC, 28, "UInt") ; pszMainInstruction
	NumPut(&description, TDC, 32, "UInt") ; pszContent
	NumPut(cButtons, TDC, 36, "UInt") ; cButtons
	NumPut(&pButtons, TDC, 40, "UInt") ; pButtons
	NumPut(&checkText, TDC, 60, "UInt") ; pszVerificationText
	NumPut(&ExpandedText, TDC, 64, "UInt") ; pszExpandedInformation
	NumPut(&FooterText, TDC, 80, "Ptr") ; pszFooter
	NumPut(TDCallback, TDC, 84, "UInt") ; pfCallback
	}

Switch (retVal := DllCall("Comctl32.dll\TaskDialogIndirect", "Ptr", &TDC
	, "Int*", Button := 0
	, "Int*", Radio := 0
	, "Int*", Checked := 0))
	
	{
	Case E_OUTOFMEMORY:
	retVal := "There is insufficient memory to complete the operation."
	Case E_INVALIDARG:
	retVal := "One or more arguments are not valid."
	Case E_FAIL:
	retVal := "The operation failed."
	Case E_ACCESSDENIED:
	retVal := "A general access denied error."
	Default:
		if (retVal)
		{
		retVal := "Com`/shell emitted a system resource error: " . Format("0x{1:x}", retVal)
		}
	; else: S_OK:
	}

	if (retVal)
	{
	msgbox, 8208, Task Dialog, % "The Task Dialog could not display because:`n" . retVal
	return 0
	}

	if (DllCall("Kernel32.dll\GlobalFree", "Ptr", TDCallback))
	MsgBox, 8208, Task Dialog, GlobalFree Failed

Switch (Button)
	{
	Case 101:
	retVal := 1
	Case 102:
	retVal := 2
	Case 103:
	retVal := 3
	Case 104:
	retVal := 4
	Default:
	{
	MsgBox, 8208, Task Dialog, Unexpected return!
	return 0
	}
	}


	if (Checked)
	retVal := -retVal

return retVal
}

TDCallback(hWnd, Notification, wParam, lParam, RefData)
{
Static tdYpos := 0
Static TDE_FOOTER = 0X0002, TDM_UPDATE_ELEMENT_TEXT := 0x400 + 114, TDM_CLICK_BUTTON := 0x400 + 102, timeOut := 10
Static TDN_CREATED := 0, TDN_HYPERLINK_CLICKED := 3, TDN_TIMER := 4, TDN_EXPANDO_BUTTON_CLICKED := 10
    switch (Notification)
	{
		Case TDN_CREATED:
		{
		VarSetCapacity(rect, 16, 0)

			if (DllCall("GetWindowRect", "Ptr", hWnd, "Ptr", &rect))
			tdYpos := NumGet(rect, 4, "int")

		VarSetCapacity(rect, 0)
		}
		Case TDN_HYPERLINK_CLICKED:
		{
		url := StrGet(lParam, "UTF-16") ; <A HREF="URL">Link</A>
		Run %url%
		}
		Case TDN_TIMER:
		{
		;Translate time elapsed to UTF-16
		sElapsed := timeOut - Round(wParam / 1000)
			if (!sElapsed)
			SendMessage, %TDM_CLICK_BUTTON%, 101,,, ahk_id %hwnd%
		sElapsed := "Download will abort in: " sElapsed " seconds"

		;Send a TDM_UPDATE_ELEMENT_TEXT message
		SendMessage, %TDM_UPDATE_ELEMENT_TEXT%, %TDE_FOOTER%, &sElapsed,, ahk_id %hwnd%
		}
		; moves the form so (most of) the expanded text is visible:
		; https://stackoverflow.com/questions/71497916/lower-part-of-expanded-taskdialog-form-goes-offscreen/71497917
		Case TDN_EXPANDO_BUTTON_CLICKED:
		{
			if (WinExist("ahk_id" . PrgLnch.Hwnd()) || WinExist("ahk_id" . PrgLnchOpt.Hwnd()))
			{
				if (wParam)
				tdYposOut := 0
				else
				tdYposOut := tdYpos

			hWndObj := {hWnd:hWnd, tdYpos:tdYposOut}

			MoveTDN(hWndObj)

			hWndObj := ""
			}
		}
		Default:
	}
}
MoveTDN(hWndObj)
{
	Timer := Func("TDNTimer").Bind(A_ThisFunc, hWndObj)

	SetTimer % Timer, -15
	Return
}

TDNTimer(FuncName, hWndObj)
{

	VarSetCapacity(rect, 16, 0)

		if (!DllCall("GetWindowRect", "Ptr", hWndObj.hWnd, "Ptr", &rect))
		return
	tdxpos := NumGet(rect, 0, "int")

		if (hWndObj.tdYpos)
		hWndNewObj := hWndObj
		else
		{
		WinGetPos,,,, h, ahk_class Shell_TrayWnd
			if (h > A_ScreenHeight - 100) ; vert taskbar
			h := 0
		tdYposIn := A_ScreenHeight - h - (NumGet(rect, 12, "int") - NumGet(rect, 4, "int"))
		hWndNewObj := {hWnd:hWndObj.hWnd, tdYpos:tdYposIn}
		VarSetCapacity(rect, 0)
		}

	DllCall("SetWindowPos", "uint", hWndNewObj.hWnd, "uint", hwnd_prev
	, "int", tdxpos, "int", hWndNewObj.tdYpos, "int", 0, "int", 0, "uint", 0)
}


































; Various buttons
BackToPrgLnch:

Tooltip


strRetVal := WorkingDirectory(A_ScriptDir, 1)
	if (strRetVal)
	MsgBox, 8192, Missing script, % strRetVal


SplashyProc("*Loading", 1)

sleep, 30




waitBreak := 1
SetTimer, WatchSwitchOut, Delete
SetTimer, WatchSwitchBack, Delete
sleep, 60
GoSub WatchSwitchOut
SetTimer, WatchSwitchBack, Off

WinActivate, LnchSplash

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

return


InitBtchStat:
PidMaster(PrgNo, currBatchNo, btchPrgPresetSel, PrgBatchIni%btchPrgPresetSel%, PrgListPID%btchPrgPresetSel%, PrgPIDMast)


if (currBatchNo) ; defpreset set
{
	if (IsCurrentBatchRunning(currBatchNo, PrgListPID%btchPrgPresetSel%))
	{
	SetTimer, WatchSwitchOut, %timWatchSwitch%
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
		SetTimer, WatchSwitchOut, %timWatchSwitch%
		Break
		}
	}

}

Gui, PrgLnchOpt: Show, Hide
WinMover(PrgLnch.Hwnd(), "d r", PrgLnchOpt.Width() * 61/80, PrgLnchOpt.Height() * 13/10)
return

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
return


PrgMinMaxChk:
Gui, PrgLnchOpt: Submit, Nohide
Tooltip
GuiControlGet, PrgMinMaxVar, PrgLnchOpt:, PrgMinMax
PrgRnMinMax[selPrgChoice] := PrgMinMaxVar

IniProc(selPrgChoice)

if (PrgPID) ;test only from config
{
	if (PrgMinMaxVar == 1)
	{
	WinMaximize, ahk_pid %PrgPID%
	WinWaitNotActive, % "ahk_id" . This.Hwnd()
	WinActivate, % "ahk_id" . This.Hwnd()
	WinSet, Top,, % "ahk_id" . This.Hwnd()
	Gui, PrgLnchOpt: Show,, % PrgLnchOpt.Title
	}
	else
	{
		if (PrgMinMaxVar == -1)
		WinRestore, ahk_pid %PrgPID%
		else
		WinMinimize, ahk_pid %PrgPID%		
	}
}

return

PrgPriorityChk:
Gui, PrgLnchOpt: Submit, Nohide
Tooltip
PrgRnPriority[selPrgChoice] := PrgPriority
IniProc(selPrgChoice)
if (PrgPID) ;test only from config
{
(!PrgPriority)? temp := "B": (PrgPriority == 1)? temp := "H": temp := "N"
Process, priority, %PrgPID%, % temp
}
return

BordlessChk:
GuiControlGet, temp, PrgLnchOpt: FocusV
	if (!Instr(temp, "Bordless"))
	return
Gui, PrgLnchOpt: Submit, Nohide
Tooltip

	if (PrgPID) ;test only from config
	BordlessProc(targMonitorNum, PrgMinMaxVar, PrgStyle, PrgBordless, selPrgChoice, dx, dy, PrgPID)
	else
	{
	PrgBordless[selPrgChoice] := Bordless
	IniProc(selPrgChoice)
	}

return

PrgLnchHideChk:
Gui, PrgLnchOpt: Submit, Nohide
Tooltip
PrgLnchHide[selPrgChoice] := PrgLnchHd
IniProc(selPrgChoice)
return

resolveShortctChk:
GuiControlGet, temp, PrgLnchOpt: FocusV

if (temp != "resolveShortct")
return
Gui, PrgLnchOpt: Submit, Nohide
Tooltip
;ChkPrgNames better than txtPrgChoice
GuiControlGet, resolveShortct, PrgLnchOpt:, resolveShortct


if (!PrgChoiceNames[selPrgChoice] || ChkPrgNames(PrgChoiceNames[selPrgChoice], PrgNo))
ResShortcut := resolveShortct
else
{
strTemp := PrgChoicePaths[selPrgChoice]
strTemp2 := GetPrgLnkVal(strTemp, IniFileShortctSep, 1 ,resolveShortct)

	if (strTemp2 == "<>")
	{
	MsgBox, 8208, Resolve shortcut, The shortcut is invalid, please replace it.
	GuiControl, PrgLnchOpt:, resolveShortct, % PrgResolveShortcut[selPrgChoice]
	return
	}

PrgLnkInf[selPrgChoice] := strTemp2
PrgResolveShortcut[selPrgChoice] := resolveShortct

	if (PrgResolveShortcut[selPrgChoice])
	{

	;update paths if requ'd
	temp := 0
	strTemp := ExtractPrgPath(selPrgChoice, PrgChoicePaths, 0, PrgLnkInf, 0, IniFileShortctSep, temp)
	PrgChoicePaths[selPrgChoice] := strTemp . IniFileShortctSep . PrgLnkInf[selPrgChoice]

	PrgURLEnable(PrgUrlTest, UrlPrgIsCompressed, selPrgChoice, PrgChoicePaths, selPrgChoiceTimer, PrgResolveShortcut, PrgLnkInf, PrgUrl, PrgVer, PrgVerNew, UpdturlHwnd, IniFileShortctSep)

	GuiControl, PrgLnchOpt: Enable, PrgMinMax
	GuiControl, PrgLnchOpt: Enable, Bordless
	GuiControl, PrgLnchOpt: Enable, PrgLAA
	borderToggle := DcmpExecutable(selPrgChoice, PrgChoicePaths, PrgLnkInf, PrgResolveShortcut, IniFileShortctSep, 1)
	SetTimer, CheckVerPrg, 5000
	}
	else
	{
	SetTimer, CheckVerPrg, Delete
		if (CheckPrgPaths(selPrgChoice, IniFileShortctSep, PrgChoicePaths, PrgLnkInf, PrgResolveShortcut))
		GuiControl, PrgLnchOpt: Disable, resolveShortct
		else
		{
		GuiControl, PrgLnchOpt: Disable, PrgMinMax
		GuiControl, PrgLnchOpt: Disable, Bordless
		GuiControl, PrgLnchOpt: Disable, PrgLAA
		}
		
		PrgURLEnable(PrgUrlTest, UrlPrgIsCompressed, selPrgChoice, PrgChoicePaths, selPrgChoiceTimer, PrgResolveShortcut, PrgLnkInf, PrgUrl, PrgVer, PrgVerNew, UpdturlHwnd, IniFileShortctSep, 1)
	}
PrgCmdLineEnable(selPrgChoice, PrgCmdLine, cmdLinHwnd, PrgResolveShortcut, PrgLnkInf)
}


IniProc(selPrgChoice)

return


PrgLAARn:
Tooltip
DcmpExecutable(selPrgChoice, PrgChoicePaths, PrgLnkInf, PrgResolveShortcut, IniFileShortctSep)
return

UpdturlPrgLnchText:
Tooltip
GuiControlGet, temp, PrgLnchOpt: FocusV
if (temp == "MkShortcut" || temp == "CmdLinPrm")
return
Gui, PrgLnchOpt: Submit, Nohide

	if (temp == "UpdturlPrgLnch")
	{
		if (StrLen(UpdturlPrgLnch) > 2082) ;http://stackoverflow.com/questions/417142/what-is-the-maximum-length-of-a-url-in-different-browsers
		{
		MsgBox, 8192, Prg Url, Too long! ;Probably bombs the script anyway
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
return


CheckDefaultPrg:
Gui, PrgLnchOpt: Submit, Nohide
Tooltip
if (DefaultPrg)
{
defPrgStrng := PrgChoiceNames[selPrgChoice]
IniWrite, %defPrgStrng%, % PrgLnch.SelIniChoicePath, Prgs, StartupPrgName
}
else
{
defPrgStrng := "None"
IniWrite, None, % PrgLnch.SelIniChoicePath, Prgs, StartupPrgName
}
return

RegoCheck:
Gui, PrgLnchOpt: Submit, Nohide
Tooltip
PrgLnch.regoVar := rego
IniProc(selPrgChoice)
return

CmdLinPrmSub:
GuiControlGet, strTemp, PrgLnchOpt: FocusV
	if (strTemp != "CmdLinPrm")
	return

Gui, PrgLnchOpt: Submit, Nohide
Tooltip
sleep 120 ;slow input
GuiControlGet, strTemp, PrgLnchOpt:, CmdLinPrm
if (strTemp)
{

; Double quotes provided for space separated parameters later
	if (!(Instr(PrgChoicePaths[SelPrgChoice], "cmd.exe")))
	{
	strTemp2 := StrReplace(strTemp, Chr(34))
		if (strTemp2 != strTemp)
		{
			if (strTemp2)
			CreateToolTip("Quotes removed")
			else
			SetEditCueBanner(cmdLinHwnd, "Quotes removed")

		strTemp := strTemp2
		GuiControl, PrgLnchOpt:, CmdLinPrm, %strTemp%
		}
	}

	; Should not get in here for ps1, msc, pif in any case
	if (IsRealExecutable(PrgChoicePaths[SelPrgChoice]) < 0)
	{
	strTemp2 := StrReplace(strTemp, Chr(44), Chr(96)Chr(44))
		if (strTemp2 != strTemp)
		{
		; Escape all commas
		strTemp := strTemp2
		GuiControl, PrgLnchOpt:, CmdLinPrm, %strTemp%
		CreateToolTip("Commas escaped")
		}
	}


	if (StrLen(strTemp) > 20000) ;length?
	{
	strTemp := SubStr(strTemp, 1, 20000)
	GuiControl, PrgLnchOpt:, CmdLinPrm, %strTemp%
	CreateToolTip("Long string truncated")
	}
}

PrgCmdLine[selPrgChoice] := strTemp
IniProc(selPrgChoice)
return

















































;Monitor & Res buttons
MonitorsSub:
ToolTip
	if A_OSVersion in WIN_2003,WIN_XP,WIN_2000
	; Above expression : No spaces and doesn't like brackets!
	CreateToolTip("Unable to display VSync for this OS!")
	;Probably bombs the script anyway
	else
	MDMF_GetMonStatus(targMonitorNum, 1) ; only works for Vista+

return

TestMode:
Gui, PrgLnchOpt: Submit, Nohide
Tooltip
IniProc(selPrgChoice)
return
ChangeMode:
Gui, PrgLnchOpt: Submit, Nohide
Tooltip
IniProc(selPrgChoice)
return
DynamicMode:
Gui, PrgLnchOpt: Submit, Nohide
Tooltip
IniProc(selPrgChoice)
return
TmpMode:
Gui, PrgLnchOpt: Submit, Nohide
Tooltip
IniProc(selPrgChoice)
return

ChgResOnCloseChk:
Gui, PrgLnchOpt: Submit, Nohide
Tooltip
PrgChgResOnClose[selPrgChoice] := ChgResOnClose
IniProc(selPrgChoice)
return

ChgResOnSwitchChk:
Gui, PrgLnchOpt: Submit, Nohide
Tooltip
PrgChgResOnSwitch[selPrgChoice] := ChgResOnSwitch
IniProc(selPrgChoice)
return


iDevNo:
Gui PrgLnchOpt: +OwnDialogs
Tooltip

Gui, PrgLnchOpt: Submit, Nohide
GuiControlGet, fTemp, PrgLnchOpt:, iDevNum

	if (fTemp != targMonitorNum)
	{
	targMonitorNum := fTemp
	GuiControl, ,PrgLnchOpt: allModes, 0
	}

;Must reset reslist
CheckModesFunc(defPrgStrng, PresetPropHwnd, targMonitorNum, iDevNumArray, ResIndexList, allModes)
SetResDefaults(0, targMonitorNum, scrWidthDefArr, scrHeightDefArr, scrFreqDefArr, 1)


	if ((txtPrgChoice != "None") && PrgMonToRn[selPrgChoice]) ; save it if a Prg
	{
	; invalid monitor?
		if (iDevNumArray[targMonitorNum] < 10)
		targMonitorNum := PrgLnch.Monitor
	PrgMonToRn[selPrgChoice] := targMonitorNum
	IniProc(selPrgChoice)

		; A warning is provided, but can be confusing if configured as suppressed
		if (!FindStoredRes(ResIndexHwnd))
		GuiControl, PrgLnchOpt: ChooseString, ResIndex, % (iDevNumArray[targMonitorNum] < 10)? PrgLnchOpt.MonDefResStrng: PrgLnchOpt.MonCurrResStrng
	TogglePrgOptCtrls(txtPrgChoice, ResShortcut, iDevNum, iDevNumArray, targMonitorNum, borderToggle, selPrgChoice, PrgChgResOnClose, PrgChgResOnSwitch, PrgChoicePaths, PrgLnkInf, PrgRnMinMax, PrgRnPriority, PrgBordless, PrgLnchHide, 1)
	}
	else
	TogglePrgOptCtrls(txtPrgChoice, ResShortcut, iDevNum, iDevNumArray, targMonitorNum)

return

StoreFetchPrgRes(txtPrgChoice, selPrgChoice, PrgLnkInf, targMonitorNum, Store := 0)
{
Static scrWidthArr := [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], scrHeightArr := [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], scrFreqArr := [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]

	if (Store)
	{
		if (Store < 0)
		{
		scrWidthArr[selPrgChoice] := ""
		scrHeightArr[selPrgChoice] := ""
		scrFreqArr[selPrgChoice] := ""
		}
		else
		{
		scrWidthArr[selPrgChoice] := PrgLnchOpt.scrWidth
		scrHeightArr[selPrgChoice] := PrgLnchOpt.scrHeight
		scrFreqArr[selPrgChoice] := PrgLnchOpt.scrFreq
		}
	}
	else
	{
		if (txtPrgChoice == "None")
		{
		MsgBox, 8192, Function Call, StoreFetchPrgRes called incorrectly!
		return 0
		}
		else
		{
			if ((scrWidthArr[selPrgChoice] && scrHeightArr[selPrgChoice] && scrFreqArr[selPrgChoice]))
			{
			PrgLnchOpt.scrWidth := scrWidthArr[selPrgChoice]
			PrgLnchOpt.scrHeight := scrHeightArr[selPrgChoice]
			PrgLnchOpt.scrFreq := scrFreqArr[selPrgChoice]
			return 1
			}
			else
			{
			; If by misadventure the values are zero
				if (LNKFlag(PrgLnkInf[selPrgChoice]) > -1) ; don't want the msgbox as ResIndex is already disabled
				MsgBox, 8192, No Resolution Mode, Monitor parameters for the selected or startup Prg do not exist!`n`nDefaults assumed.`nIt's recommended to save the parameters by reselecting the target monitor from the Monitor List, and, if required, changing the resolution mode.
			; save to defaults
			CopyToFromRes(targMonitorNum, 1)
			}
		}
	}
return 1
}


CheckModes:
; Update allModes
Gui, PrgLnchOpt: Submit, Nohide
CheckModesFunc(defPrgStrng, PresetPropHwnd, targMonitorNum, iDevNumArray, ResIndexList, allModes)
Tooltip
return

CheckModesFunc(defPrgStrng, PresetPropHwnd, targMonitorNum, ByRef iDevNumArray, ByRef ResIndexList, allModes, setPrgLnchOptDefs := 0)
{
static oldTargMonitorNum := 0
; resArray and all others are one-based now


	if (setPrgLnchOptDefs)
	GetResInfo(targMonitorNum, 1, allModes, iDevNumArray, setPrgLnchOptDefs)
	else
	{
		; use PresetPropHwnd to determine intialisation
		if (!PresetPropHwnd || oldTargMonitorNum != targMonitorNum)
		{
		ResIndexList := "|" . GetResInfo(targMonitorNum, 2, allModes, iDevNumArray)

		; Now process default res

			if (strTemp := GetResInfo(targMonitorNum))
			{
			strTemp := substr(strTemp, 1, StrLen(strTemp) - 1)

				if (PrgLnch.Monitor == targMonitorNum)
				{
				PrgLnchOpt.MonDefResStrng := strTemp
				PrgLnchOpt.MonCurrResStrng := strTemp
				PrgLnchOpt.CurrMonStat := 1 ; Assume the PrgLnch monitor is always ok
				}
				else
				{
					if ((iDevNumArray[targMonitorNum] > 9) && (!(MDMF_GetMonStatus(targMonitorNum))))
					{
					GuiControlGet, strTemp2, PrgLnchOpt: FocusV

						if (!PresetPropHwnd || strTemp2 == "iDevNum")
						{
						IniRead, strTemp2, % PrgLnch.SelIniChoicePath, General, MonProbMsg

							if (strTemp2 = "ERROR")
							{
							; Versioning:  IniSpaceCleaner moves this before ResMode
							IniWrite, %A_Space%, % PrgLnch.SelIniChoicePath, General, PrgCleanOnExit
							strTemp2 := 0
							}
						
							if (!strTemp2)
							{
							retVal := TaskDialog("Monitors", "Monitor connection issue", "", "Monitor " . """" . targMonitorNum . """" . " returns a bad status, possibly due to an unsupported`nsetting or missing feature on the physical monitor itself.`n`nThe Default Resolution value is greyed out as an indication,`nhowever it's possible any number of Resolution Modes from`nthe list will still be supported for the monitor. Otherwise, Prgs`ncan be launched in the monitor defined in the system's Virtual`nScreen, and then moved to a location where they are visible.", , "Continue with resolution checks")
								if (retVal < 0)
								IniWrite, 1, % PrgLnch.SelIniChoicePath, General, MonProbMsg
							}
						}
					GuiControl, PrgLnchOpt: Disabled, currRes
					}
					else
					PrgLnchOpt.MonCurrResStrng := strTemp
				}

				; Check default on monitor change
				if (!allModes)
				ResIndexList := "|" . GetResInfo(targMonitorNum, 3, allModes)

			;Not the g-label ResListBox!
			GuiControl, PrgLnchOpt:, ResIndex, %ResIndexList%

			oldTargMonitorNum := targMonitorNum

				if (allModes)
				Gui, PrgLnchOpt: Font, Bold CA96915, Verdana
				else
				Gui, PrgLnchOpt: Font

			GuiControl, PrgLnchOpt: Font, ResIndex

				if (PresetPropHwnd)
				{
					if ((PrgLnch.Monitor != targMonitorNum) || PrgLnchOpt.Fmode() || PrgLnchOpt.DynamicMode())
					GuiControl, PrgLnchOpt:, currRes, %strTemp%
					else
					GuiControl, PrgLnchOpt:, currRes, % PrgLnchOpt.MonCurrResStrng
				}
				else  ;Update all at PrgLnch Load
				{
					GuiControl, PrgLnchOpt:, currRes, %strTemp%

					; restore from defaults on res change
					if (defPrgStrng == "None")
					CopyToFromRes(targMonitorNum)
				}

			GuiControl, PrgLnchOpt: ChooseString, ResIndex, % PrgLnchOpt.MonCurrResStrng
			GuiControl, PrgLnchOpt: Show, ResIndex
			}
			else
			CreateToolTip("Critical error with dimensions of target monitor " . """" . targMonitorNum . """" . " !")
		}
	}
}




ResListBox:
Tooltip

	if (allModes)
	{
	GuiControlGet, strTemp, PrgLnchOpt:, currRes
	GuiControl, PrgLnchOpt: ChooseString, ResIndex, %strTemp%
	}
	else
	{
	fTemp := 0
	GuiControlGet, strTemp, PrgLnchOpt:, ResIndex
		Loop, Parse, ResIndexList, |
		{
			if (strTemp == A_Loopfield)
			{
			fTemp := A_Index
			Break
			}
		}
		if (fTemp)
		{
		fTemp --
		CheckModesFunc(defPrgStrng, PresetPropHwnd, targMonitorNum, iDevNumArray, ResIndexList, allModes, fTemp)

			if (PrgChoicePaths[selPrgChoice])
			IniProc(selPrgChoice)
		}
		else
		GuiControl, PrgLnchOpt: ChooseString, ResIndex, % PrgLnchOpt.MonCurrResStrng
	}
return

FindStoredRes(ResIndexHwnd)
{
Stat := 0, strTemp2 := "", strTemp := ""

ControlGet, strTemp, List,,, % "ahk_id" ResIndexHwnd

strTemp2 := ""
strTemp2 .= PrgLnchOpt.scrWidth . " `, " . PrgLnchOpt.scrHeight . " @ " . PrgLnchOpt.scrFreq . "Hz "

	Loop, Parse, strTemp, `n
	{
		if (strTemp2 == A_LoopField)
		{
		GuiControl, PrgLnchOpt: ChooseString, ResIndex, % strTemp2
		Stat := 1
		Break
		}
	}

	if (!stat)
	{
		IniRead, strTemp, % PrgLnch.SelIniChoicePath, General, ResClashMsg
		if (!strTemp)
		{
		retVal := TaskDialog("Monitors", "Resolution mismatch issue", "", "Mismatch detected in desired resolution data for selected monitor!`n" . """" . strTemp2 . """" . "`n`nThis resolution is set for the Prg in the Prglnch ini file and may apply to another monitor. Alternatively, differing frequency values appertaining to the same resolution preset is a common side-effect of some hardware. Excerpt from <A HREF=""https://support.microsoft.com/en-us/topic/screen-refresh-rate-in-windows-does-not-apply-the-user-selected-settings-on-monitors-tvs-that-report-specific-tv-compatible-timings-0a7a6a38-6c6a-2aec-debc-5183a76b9e1d"">MS Support</a>: `n`n""In Windows 7 and newer versions of Windows, when a user selects 60Hz, the OS stores a value of 59.94Hz. However, 59Hz is shown in the Screen refresh rate in Control Panel, even though the user selected 60Hz."" `n`nThe current resolution mode might have also been set from the ""List all Compatible"" selection. The recommended action is to reselect the required screen resolution from the list of resolutiuon modes.", , "Continue resolution checks")
			if (retval < 0)
			IniWrite, 1, % PrgLnch.SelIniChoicePath, General, ResClashMsg
		}
	}
return stat
}
SetResDefaults(lnchStat, targMonitorNum, ByRef scrWidthDefArr, ByRef scrHeightDefArr, ByRef scrFreqDefArr, SaveVars := 0)
{
	if (SaveVars)
	{
		if (scrWidthDefArr[targMonitorNum]) ;no need if values have been read already
			{
			PrgLnchOpt.scrWidthDef := scrWidthDefArr[targMonitorNum]
			PrgLnchOpt.scrHeightDef := scrHeightDefArr[targMonitorNum]
			PrgLnchOpt.scrFreqDef := scrFreqDefArr[targMonitorNum]
			}
		else ; on init: The defs in the class are initialised at least
			{
			scrWidthDefArr[targMonitorNum] := PrgLnchOpt.scrWidthDef
			scrHeightDefArr[targMonitorNum] := PrgLnchOpt.scrHeightDef
			scrFreqDefArr[targMonitorNum] := PrgLnchOpt.scrFreqDef
			}
	}
	else
	{
	;Sets new defaults according to resolution changes when changing res
		if (PrgLnchOpt.Fmode() || PrgLnchOpt.DynamicMode())
		{
		CopyToFromRes(targMonitorNum, 1)
		scrWidthDefArr[targMonitorNum] := PrgLnchOpt.scrWidthDef
		scrHeightDefArr[targMonitorNum] := PrgLnchOpt.scrHeightDef
		scrFreqDefArr[targMonitorNum] := PrgLnchOpt.scrFreqDef
		GuiControlGet, strTemp, PrgLnchOpt:, ResIndex
		GuiControl, PrgLnchOpt:, currRes, %strTemp%
		}

		; This saves the monitor info for the test Prg in case a batch preset is run concurrently
		if (lnchStat < 0)
		CopyToFromRes(targMonitorNum, 1, 1)
	}
}







































;Navigational
PrgChoice:
Gui, PrgLnchOpt: Submit, Nohide
Gui PrgLnchOpt: +OwnDialogs
Tooltip
SendMessage 0x147, 0, 0, , ahk_id %PrgChoiceHwnd%  ; CB_GETCURSEL


If (ErrorLevel == "FAIL")
	{
	Gui, PrgLnchOpt: Submit, Nohide
	MsgBox, 8192, Shortcut Slots, CB_GETCURSEL Failed
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
					if (temp == "Make Shortcut")
					CreateToolTip("Click " . """" . temp . """" . " to save.")
					else
					{
					CreateToolTip("Click " . """" . temp . """" . " to save.")
					GuiControl, PrgLnchOpt:, Remove Shortcut, % ChgShortcutVar
					}
				}
				else
				{
				GuiControl, PrgLnchOpt:, MkShortcut, Remove Shortcut
					if (PrgChoicePaths[selPrgChoice]) ;Path already exist?
					CreateToolTip("Click " . """" . "Remove Shortcut" . """" . " or hit Del to confirm.")
					else
					CreateToolTip("Click " . """" . "Remove Shortcut" . """" . " or hit Del to remove unexpected data from reference.")
				}
			}
		}

		}
	else ; Clicked here
		{
		SetTimer, CheckVerPrg, Delete ;vital

		selPrgChoice := retVal
		GuiControlGet, txtPrgChoice, PrgLnchOpt:, PrgChoice ;one of the list items
			if (selPrgChoice)
			{
			GuiControl, PrgLnchOpt:, RnPrgLnch, &Test Run Prg
				if (PrgChoiceNames[selPrgChoice])
				{

				CheckPrgPaths(selPrgChoice, IniFileShortctSep, PrgChoicePaths, PrgLnkInf, PrgResolveShortcut)

				PrgCmdLineEnable(selPrgChoice, PrgCmdLine, cmdLinHwnd, PrgResolveShortcut, PrgLnkInf)
				GuiControl, PrgLnchOpt: Enable, MkShortcut
				GuiControl, PrgLnchOpt:, MkShortcut, % ChgShortcutVar
				GuiControl, PrgLnchOpt: Enable, RnPrgLnch
				PrgURLEnable(PrgUrlTest, UrlPrgIsCompressed, selPrgChoice, PrgChoicePaths, selPrgChoiceTimer, PrgResolveShortcut, PrgLnkInf, PrgUrl, PrgVer, PrgVerNew, UpdturlHwnd, IniFileShortctSep)
				borderToggle := DcmpExecutable(selPrgChoice, PrgChoicePaths, PrgLnkInf, PrgResolveShortcut, IniFileShortctSep, 1)

				GuiControlGet, targMonitorNum, PrgLnchOpt:, iDevNum

					; Update monitor info & res
					if (targMonitorNum != PrgMonToRn[selPrgChoice])
					targMonitorNum := PrgMonToRn[selPrgChoice]

					if (StoreFetchPrgRes(txtPrgChoice, selPrgChoice, PrgLnkInf, targMonitorNum))
					{ 
					SetResDefaults(0, targMonitorNum, scrWidthDefArr, scrHeightDefArr, scrFreqDefArr, 1)
					CheckModesFunc(defPrgStrng, PresetPropHwnd, targMonitorNum, iDevNumArray, ResIndexList, allModes)
					}
					else
					return

				GuiControl, PrgLnchOpt: ChooseString, iDevNum, %targMonitorNum%

					if (!FindStoredRes(ResIndexHwnd))
					GuiControl, PrgLnchOpt: ChooseString, ResIndex, % PrgLnchOpt.MonCurrResStrng

				TogglePrgOptCtrls(txtPrgChoice, ResShortcut, iDevNum, iDevNumArray, targMonitorNum, borderToggle, selPrgChoice, PrgChgResOnClose, PrgChgResOnSwitch, PrgChoicePaths, PrgLnkInf, PrgRnMinMax, PrgRnPriority, PrgBordless, PrgLnchHide, 1)


				}
				else
				{
				GuiControl, PrgLnchOpt: Enable, MkShortcut
				GuiControl, PrgLnchOpt:, MkShortcut, Make Shortcut
				GuiControl, PrgLnchOpt: Disable, RnPrgLnch
				PrgURLEnable(PrgUrlTest, UrlPrgIsCompressed, selPrgChoice, PrgChoicePaths, selPrgChoiceTimer, PrgResolveShortcut, PrgLnkInf, PrgUrl, PrgVer, PrgVerNew, UpdturlHwnd, IniFileShortctSep, 1)
				TogglePrgOptCtrls(txtPrgChoice, ResShortcut, iDevNum, iDevNumArray, targMonitorNum)
				}

			}
			else ; Change res
			{
				selPrgChoice := 1
				GuiControl, PrgLnchOpt:, RnPrgLnch, Change Res`.
				GuiControl, PrgLnchOpt: Disable, DefaultPrg
				GuiControl, PrgLnchOpt:, MkShortcut, Just Change Res.
				GuiControl, PrgLnchOpt: Disable, Just Change Res.
				PrgURLEnable(PrgUrlTest, UrlPrgIsCompressed, selPrgChoice, PrgChoicePaths, selPrgChoiceTimer, PrgResolveShortcut, PrgLnkInf, PrgUrl, PrgVer, PrgVerNew, UpdturlHwnd, IniFileShortctSep, 1)

				GuiControlGet, targMonitorNum, PrgLnchOpt:, iDevNum
					if (iDevNumArray[targMonitorNum] < 10)
					{
					GuiControl, PrgLnchOpt: Enable, RnPrgLnch
					targMonitorNum := PrgLnch.Monitor
					}
					else
					GuiControl, PrgLnchOpt: Enable, RnPrgLnch

				CheckModesFunc(defPrgStrng, PresetPropHwnd, targMonitorNum, iDevNumArray, ResIndexList, allModes)
				TogglePrgOptCtrls(txtPrgChoice, ResShortcut, iDevNum, iDevNumArray, targMonitorNum)

			}

		}
	;Startup Default?

	SetStartupname(defPrgStrng, PrgChoiceNames, selPrgChoice)

	}

return


MakeShortcut:
Gui, PrgLnchOpt: Submit, Nohide
Tooltip
Gui, PrgLnchOpt: +OwnDialogs

GuiControlGet temp, PrgLnchOpt:, MkShortcut

if ((txtPrgChoice == "Prg Removed" || txtPrgChoice == "") && (temp == "Make Shortcut"))
txtPrgChoice := "Prg" . selPrgChoice


if (txtPrgChoice == "")
{

	if (PrgPIDMast[selPrgChoice])
	{
	txtPrgChoice := PrgChoiceNames[selPrgChoice]
	GuiControl, PrgLnchOpt:, MkShortcut, % ChgShortcutVar
	GuiControl, PrgLnchOpt:, PrgChoice, %strPrgChoice%
	GuiControl, PrgLnchOpt: Choose, PrgChoice, % selPrgChoice + 1
	MsgBox, 8192, Active Prg, % "Sorry, a Prg cannot be removed if it is active in Batch!"
	return
	}

;SelPrgChoice is last selected
retVal := TaskDialog("Shortcuts", "Confirm Removal", , "", "", "Remove Shortcut", "Keep Shortcut")
	if (retVal == 1)
	GoSub zeroPrgVars
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
	if (strLen(txtPrgChoice) == 1)
	{
		GuiControl, PrgLnchOpt: Text, PrgChoice,
		txtPrgChoice := "Prg" . selPrgChoice
		SetEditCueBanner(PrgChoiceHwnd, "Prg Name too short", 1)
		return
	}

	if (ChkPrgNames(txtPrgChoice, PrgNo))
	temp := 0
	else
	{
		if (txtPrgChoice == "Prg Removed")
		temp := 0
		else
		{
		if (ChgShortcutVar == "Change Shortcut Name")
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
			retVal := TaskDialog("Shortcuts", "Prg shortcut: How to change", , "Checking the " . """" . " Do not show this again" . """" . " option is to a better effect for experienced users.`nRemoval of the entry (with <DEL> key)`, later`, is always an alternative to modification.", , "Confirm name change (Recommended)", "Assign a new location for Prg", "Do nothing for now")

				if (abs(retVal == 3))
				return

				if (retVal < 0)
				{
				temp := -retVal
				IniWrite, %temp%, % PrgLnch.SelIniChoicePath, General, ChangeShortcutMsg
				}
				else
				temp := retVal
				
				if (temp == 1)
				ChgShortcutVar := "Change Shortcut Name"
				else
				{
				temp := 0
				ChgShortcutVar := "Change Shortcut"
				}

			GuiControl, PrgLnchOpt:, MkShortcut, % ChgShortcutVar

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
				if (txtPrgChoice == PrgChoiceNames[A_Index])
				{
				MsgBox, 8192, Duplicate Name, A Prg exists with this name already. `nPlease use another name.
				return
				}
			}
		}
	SetStartupname(defPrgStrng, PrgChoiceNames, selPrgChoice, txtPrgChoice)
	PrgChoiceNames[selPrgChoice] := txtPrgChoice
	IniProc(selPrgChoice)
	strPrgChoice := ComboBugFix(strPrgChoice, Prgno)
	GuiControl, PrgLnchOpt:, PrgChoice, %strPrgChoice%
	GuiControl, PrgLnchOpt: Choose, PrgChoice, % selPrgChoice + 1
	PrgCmdLineEnable(selPrgChoice, PrgCmdLine, cmdLinHwnd, PrgResolveShortcut, PrgLnkInf)

	}
	else
	{
	;Watch out for TIMERS!
	Thread, NoTimers

		if (resolveShortct)
		FileSelectFile, strTemp, 1, % A_StartMenu "\Programs", Open a file or Shortcut, (*.exe; *.bat; *.com; *.cmd; *.pif; *.ps1; *.msc; *.scr)
		else
		FileSelectFile, strTemp, 33, % A_StartMenu "\Programs", Open a file`, Shortcuts resolved, (*.exe; *.bat; *.com; *.cmd; *.pif; *.ps1; *.msc; *.lnk; *.scr)

	Thread, NoTimers, false

		if (!ErrorLevel)
		{
			if (txtPrgChoice == "" || txtPrgChoice == "Prg" . selPrgChoice)
			SplitPath, strTemp, , , , txtPrgChoice
		GoSub ProcessNewPrg
		}
		;else cancelled out of FSF dialog: PrgChoicePaths is made blank
	}
}
return


ProcessNewPrg:
FileGetAttrib, temp, % strTemp

	;The following does not affect folder shortcuts
	If (InStr(temp, "D"))
	{
			if (!PrgChoicePaths[selPrgChoice])
			txtPrgChoice := "Prg" . selPrgChoice
		MsgBox, 8192, Prg Naming, Unable to use this Prg!
		return
	}


	if (ChkPrgNames(txtPrgChoice, PrgNo))
	{
	; Instead of SplitPath
	temp := SubStr(strTemp, 1, InStr(strTemp, ".") - 1)
	strTemp := SubStr(temp, InStr(temp, "\",, -1) + 1)
		if (InStr(strTemp, "PrgLnch") || InStr(strTemp, "BadPath"))
		{
				if (!PrgChoicePaths[selPrgChoice])
				txtPrgChoice := "Prg" . selPrgChoice
			MsgBox, 8192, Prg Naming, Unable to use this Prg Name!
			return
		}
	PrgChoiceNames[selPrgChoice] := strTemp
	}
	else
	PrgChoiceNames[selPrgChoice] := txtPrgChoice

PrgChoicePaths[selPrgChoice] := strTemp

	;check dup names
	Loop % PrgNo
	{
		if (selPrgChoice != A_Index)
		{
			if (PrgChoiceNames[selPrgChoice] == PrgChoiceNames[A_Index])
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



	if (strRetVal == "*")
	; Not a shortcut: check working  directory & strip the last "\"
	strTemp2 := WorkingDirectory(AssocQueryApp(strTemp))
	else
	{
		if (strRetVal == "|")
		; Directory links cannot be "resolved"
		strTemp2 := WorkingDirectory(strTemp)
		else
		{
		;strRetVal .= IniFileShortctSep, "<>"  or valid target
		; strip the last "\":  gets working directory of lnk, if any
		strTemp2 := WorkingDirectory(strRetVal)
		}
	}

	if (strTemp2)
	{
	MsgBox, 8192, Prg Path, % strTemp2
	txtPrgChoice := "Prg" . selPrgChoice
	GoSub zeroPrgVars
	return
	}
	else
	{
	PrgUrl[selPrgChoice] := ""
	PrgCmdLine[selPrgChoice] := ""

		if (strRetVal == "*")
		{
		strTemp2 := AssocQueryApp(strTemp)
			if (strTemp2)
			{
				if (strTemp == strTemp2)
				strRetVal := GetPrgLnkVal(strTemp, IniFileShortctSep, 1)
			}
			else
			{
			MsgBox, 8192, No Association, The Prg must have an association before it can be used.
			txtPrgChoice := "Prg" . selPrgChoice
			GoSub zeroPrgVars
			return
			}
			; else: Forget associations
		}
		else
		{

			; "<>" case covered with blank strTemp2
			if (strRetVal != IniFileShortctSep && strRetVal != "|")
			{
			;Append resolved path
			strRetVal := GetPrgLnkVal(strTemp, IniFileShortctSep, 1)
			PrgChoicePaths[selPrgChoice] .= IniFileShortctSep . strRetVal
			}
			else
			PrgChoicePaths[selPrgChoice] .= IniFileShortctSep

		}

	PrgLnkInf[selPrgChoice] := strRetVal
	}

txtPrgChoice := PrgChoiceNames[selPrgChoice]
PrgCmdLineEnable(selPrgChoice, PrgCmdLine, cmdLinHwnd, PrgResolveShortcut, PrgLnkInf)

PrgLnchHide[selPrgChoice] := 0

IniProc(selPrgChoice)
strPrgChoice := ComboBugFix(strPrgChoice, Prgno)


GuiControl, PrgLnchOpt:, MkShortcut, % ChgShortcutVar
GuiControl, PrgLnchOpt:, PrgChoice, %strPrgChoice%
GuiControl, PrgLnchOpt: Choose, PrgChoice, % selPrgChoice + 1
GuiControl, PrgLnchOpt: Enable, DefaultPrg
GuiControl, PrgLnchOpt: Enable, RnPrgLnch
GuiControl, PrgLnchOpt:, RnPrgLnch, &Test Run Prg


borderToggle := DcmpExecutable(selPrgChoice, PrgChoicePaths, PrgLnkInf, PrgResolveShortcut, IniFileShortctSep, 1)

StoreFetchPrgRes(1, selPrgChoice, PrgLnkInf, targMonitorNum)
SetResDefaults(0, targMonitorNum, scrWidthDefArr, scrHeightDefArr, scrFreqDefArr, 1)

CheckModesFunc(defPrgStrng, PresetPropHwnd, targMonitorNum, iDevNumArray, ResIndexList, allModes)
TogglePrgOptCtrls(txtPrgChoice, ResShortcut, iDevNum, iDevNumArray, targMonitorNum, borderToggle, selPrgChoice, PrgChgResOnClose, PrgChgResOnSwitch, PrgChoicePaths, PrgLnkInf, PrgRnMinMax, PrgRnPriority, PrgBordless, PrgLnchHide, 1)

GuiControl, PrgLnchOpt: ChooseString, iDevNum, %targMonitorNum%

	if (!FindStoredRes(ResIndexHwnd))
	GuiControl, PrgLnchOpt: ChooseString, ResIndex, % PrgLnchOpt.MonCurrResStrng

PrgURLEnable(PrgUrlTest, UrlPrgIsCompressed, selPrgChoice, PrgChoicePaths, selPrgChoiceTimer, PrgResolveShortcut, PrgLnkInf, PrgUrl, PrgVer, PrgVerNew, UpdturlHwnd, IniFileShortctSep)

	GuiControlGet, temp, PrgLnchOpt:, DefaultPrg
	if (temp) ;if enabled reset string
	{
	defPrgStrng := PrgChoiceNames[selPrgChoice]
	IniWrite, % defPrgStrng, % PrgLnch.SelIniChoicePath, Prgs, StartupPrgName
	}

return


zeroPrgVars:
	SetTimer, CheckVerPrg, Delete ;vital to do first

	;Remove default
	IniRead, defPrgStrng, % PrgLnch.SelIniChoicePath, Prgs, StartupPrgName ;Space just in case None is absent

		if (defPrgStrng == PrgChoiceNames[selPrgChoice])
		{
		defPrgStrng := "None"
		IniWrite, None, % PrgLnch.SelIniChoicePath, Prgs, StartupPrgName
		}
	GuiControl, PrgLnchOpt: , DefaultPrg, 0
	GuiControl, PrgLnchOpt: Disable, DefaultPrg

	strRetVal := WorkingDirectory(A_ScriptDir, 1)
		if (strRetVal)
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
	PrgRnMinMax[selPrgChoice] := -1
	PrgLnkInf[selPrgChoice] := ""
	PrgUrl[selPrgChoice] := ""


	GuiControl, PrgLnchOpt:, PrgChoice, %strPrgChoice%
	GuiControl, PrgLnchOpt: Choose, PrgChoice, % selPrgChoice + 1
	GuiControl, PrgLnchOpt:, MkShortcut, Make Shortcut
	GuiControl, PrgLnchOpt: Disable, RnPrgLnch
	PrgURLEnable(PrgUrlTest, UrlPrgIsCompressed, selPrgChoice, PrgChoicePaths, selPrgChoiceTimer, PrgResolveShortcut, PrgLnkInf, PrgUrl, PrgVer, PrgVerNew, UpdturlHwnd, IniFileShortctSep, 1)
	iDevNum := 1
	GuiControl, PrgLnchOpt:, Choose, iDevNum
	TogglePrgOptCtrls(txtPrgChoice, ResShortcut, iDevNum, iDevNumArray, targMonitorNum)


return

PrgLnchOptGuiDropFiles:
Gui, PrgLnchOpt: Submit, Nohide
strTemp := ""
strTemp2 := ""
temp := 0
; WS_EX_ACCEPTFILES does not allow GUID links e.g. explorer.exe shell:::{4234d49b-0245-4df3-B780-3893943456e1}

	Loop, Parse, A_GuiEvent, `n
	{
		if (strTemp && A_Loopfield)
		{
		strTemp2 := "PrgLnch only accepts one file.`n" . """" . strTemp . """" . ",`nbeing the first file in the list, is assumed the selection.`n"
		break
		}
	strTemp := A_LoopField
	}

		if (txtPrgChoice == "None")
		{
		selPrgChoice := 0 ; selPrgChoice is set to 1
			Loop, % PrgNo
			{
			; First available selPrgChoice slot
			if (!PrgChoicePaths[A_Index])
				{
				selPrgChoice := A_Index
				break
				}
			}

			if (!selPrgChoice) ; Slots are full!
			{
			MsgBox, 8192, Shortcut Slots, All the Shortcut Slots are in use!`n`nFrom the Shortcut Slot list, please select an item`nacceptable for replacement, and retry the operation.
			return
			}

		temp := 1
		}

		if (PrgChoicePaths[selPrgChoice])
		{
			switch (selPrgChoice)
			{
			case 2:
			strTemp2 := "nd"
			case 3:
			strTemp2 := "rd"
			default:
			strTemp2 := "th"
			}

		retVal := TaskDialog("Drag'n Drop Prg Replacement", "Replace the " . selPrgChoice . strTemp2 . " item in the Shortcut Slot list`ncontaining the existing PrgName " . """" . PrgChoiceNames[selPrgChoice] . """" . "`nwith the following Prg replacement file?`n" . """" . strTemp . """" . "", , "", "", "Replace selected Prg and Prg Name", "Replace selected Prg, but keep current Prg Name", "Cancel operation")

			switch (retVal)
			{
			case 1:
			SplitPath, strTemp, , , , txtPrgChoice
			case 3:
			return
			default:
			}
		}
		else
		SplitPath, strTemp, , , , txtPrgChoice
GoSub ProcessNewPrg
return



ChkCmdLineValidFName(ByRef testStr, CmdLine := 0)
{
temp := 0, fTemp := 0
;No commas either
testStr := RegExReplace(testStr, "[\\\/:*?""<>|,]", , temp)
; temp is no of replacements

; whitespaces
if (CmdLine)
testStr := RegExReplace(testStr, "\s+", , (!temp)? temp: fTemp)

return % (temp || fTemp)
}

IsRealExecutable(PrgPth)
{
SplitPath, PrgPth, , , strTemp
	if (strTemp == "exe" ) || (strTemp == "com" ) || (strTemp == "scr" )
	return 1
	else
	{
		if (InStr(strTemp, "bat") || InStr(strTemp, "cmd") || InStr(strTemp, "pif") || InStr(strTemp, "msc") || InStr(strTemp, "ps1"))
		return -1
		else
		return 0
	}
}


ChkPrgNames(testName, PrgNo, IniBox := "", forDeletion := 0)
{
; returns 1 if testName is a spare, bad or default slot name

	if (Inibox)
	spr := IniBox
	else
	spr = Prg

	loop % PrgNo
	{
	if (testName == spr . A_Index)
	return 1
	}

	if (forDeletion)
	return 0

	if (testName == "0" || testName == "Error" || testName == "PrgLnch" || testName == "BadPath")
	return 1
	else
	return 0
}

QuoterizeCommandStringArgs(PrgPaths, inputStr)
{
strTemp := strTemp2 := ""
	; Parms for launched programs should already be quoted, now quote the whole lot
	if (Instr(PrgPaths, "cmd.exe"))
	{
		; note the quoting requirement here: /c "notepad.exe" /w "C:\WINDOWS\win.ini"
		strTemp2 := SubStr(inputStr, Instr(inputStr, chr(34)))
		strTemp := SubStr(inputStr, 1, Instr(inputStr, chr(34)) - 1)

			if (RegExMatch(strTemp, A)[""]+) ; check for 2 doublequotes at start
			strTemp .= strTemp2
			else
			strTemp .= chr(34) . strTemp2 . chr(34)
	}
	else
	{
		if (InStr(inputStr, A_Space))
		{
			Loop, Parse, inputStr, %A_Space%
			{
			strTemp .= A_Space . A_LoopField
			strTemp2 := A_LoopField 
			}
		strTemp := StrReplace(strTemp, strTemp2, chr(34) . strTemp2 . chr(34))
		}
	}

return % (strTemp)? strTemp: inputStr

}


ComboBugFix(strPrgChoice, PrgNo)
{
strTemp := "", strTemp2 := "", foundpos1 := 0, strRetVal:= "", foundpos := InStr(strPrgChoice, "||")
;Addresses weird bug when partially matched names are removed and added to the combobox
; Update: Not required anymore as problem was bad variable/ function parameter
strTemp := StrReplace(strPrgChoice, "|", "|", foundpos1)
	if (foundpos1 != PrgNo + 2)
	{
	MsgBox, 8192, ComboBugFix slots error, PrgLnch has an encountered an unexpected error! Attempting Restart!
	strRetVal := WorkingDirectory(A_ScriptDir, 1)
	If (strRetVal)
	MsgBox, 8192, ComboBugFix slots error, % strRetVal
	if (FileExist("PrgLnch.exe"))
	return RestartPrgLnch(0)
	}


	if (foundpos)
	{
		Loop % PrgNo
		{
			if (InStr(strPrgChoice, "|",,, A_Index + 1) == foundpos)
			{
			strTemp := Substr(strPrgChoice, 1, foundpos) . "Prg" . A_Index

			strTemp2 := Substr(strPrgChoice, foundpos + 1)
			foundpos1 := InStr(strTemp2, "||") ;' yikes already checked! Null terminator removed?
				if (foundpos1)
				strTemp2 := "|Prg" . A_Index + 1 . Substr(strTemp2, foundpos1 + 1)

			return strTemp . strTemp2
			}
		}
	}
	else
	return strPrgChoice
}



PrgCmdLineEnable(selPrgChoice, PrgCmdLine, cmdLinHwnd, PrgResolveShortcut, PrgLnkInf)
{
temp := PrgResolveShortcut[selPrgChoice], strTemp := PrgCmdLine[selPrgChoice], strTemp2 := PrgLnkInf[selPrgChoice]
IsaPrgLnk := LNKFlag(strTemp2)

	Switch, IsaPrgLnk
	{
	Case -1:
	{
		GuiControl, PrgLnchOpt:, CmdLinPrm
		GuiControl, PrgLnchOpt: Disable, CmdLinPrm
		GuiControl, PrgLnchOpt: Disable, resolveShortct
	}
	Case 0:
	{
	GuiControl, PrgLnchOpt: Enable, CmdLinPrm
	GuiControl, PrgLnchOpt:, CmdLinPrm
		if (strTemp)
		GuiControl, PrgLnchOpt:, CmdLinPrm, % strTemp
		else
		SetEditCueBanner(cmdLinHwnd, "Cmd Line Extras")
	GuiControl, PrgLnchOpt: Disable, resolveShortct
	}
	Case 1:
	{
		if (temp)
		{
			if (strTemp)
			GuiControl, PrgLnchOpt:, CmdLinPrm, % strTemp
			else
			SetEditCueBanner(cmdLinHwnd, "Cmd Line Extras")

		GuiControl, PrgLnchOpt: Enable, CmdLinPrm
		}
		else
		{
		GuiControl, PrgLnchOpt:, CmdLinPrm
		GuiControl, PrgLnchOpt: Disable, CmdLinPrm
		}
	GuiControl, PrgLnchOpt: Enable, resolveShortct
	}
	}


GuiControl, PrgLnchOpt:, resolveShortct, % temp
}

LNKFlag(PrgLnkInfArg)
{
	Switch, PrgLnkInfArg
	{
	Case "":
	; Should never get here
	return -1
	Case "|":
	; Directory lnk
	return -1
	Case "<>":
	; invalid lnk/file
	return -1
	Case "?":
	; symbolic lnk
	return -1
	Case "*":
	; no lnk
	return 0
	Default:
	; typical valid lnk
	return 1
	}
}

ExtractPrgPath(selPrgChoice, PrgChoicePaths, PrgPth, PrgLnkInf, PrgResolveShortcut, IniFileShortctSep, ByRef IsaPrgLnk)
{
strTemp := PrgLnkInf[selPrgChoice]
prgPath := (PrgPth)? PrgPth: PrgChoicePaths[selPrgChoice]
IsaPrgLnk := LNKFlag(strTemp)

	Switch, IsaPrgLnk
	{
	Case -1:
	; Can handle ini file errors 
		if (temp := InStr(prgPath, IniFileShortctSep,, 0))
		prgPath := SubStr(prgPath, 1, temp - 1)
	Case 0:
	{
		if (InStr(prgPath, "*",, Strlen(prgPath))) ; don't know reason for this
		PrgPath := Substr(prgPath, 1, Strlen(prgPath) - 1)
	}
	Case 1:
	{
	;not worried about a working directory in PrgLnkInf (InStr(strTemp, "\", false, StrLen(strTemp)))
		if (PrgResolveShortcut[selPrgChoice])
		prgPath := SubStr(prgPath, InStr(prgPath, IniFileShortctSep,,0) + 1)
		else
		prgPath := SubStr(prgPath, 1, InStr(prgPath, IniFileShortctSep,, 0) - 1)
	}
	}


	if (!PrgPath)
	PrgPath := "BadPath"	

return prgPath
}

PrgURLEnable(ByRef PrgUrlTest, ByRef UrlPrgIsCompressed, selPrgChoice, PrgChoicePaths, ByRef selPrgChoiceTimer, PrgResolveShortcut, PrgLnkInf, PrgUrl, ByRef PrgVer, ByRef PrgVerNew, UpdturlHwnd, IniFileShortctSep, UrlDisableGui := 0)
{
currPrgUrl := PrgUrl[selPrgChoice]
PrgverOld := PrgVer[selPrgChoice]
IsaPrgLnk := 0

if (!UrlDisableGui)
{
PrgPth := ExtractPrgPath(selPrgChoice, PrgChoicePaths, 0, PrgLnkInf, PrgResolveShortcut, IniFileShortctSep, IsaPrgLnk)

	if (!FileExist(PrgPth) || InStr(PrgPth, "BadPath", True, 1, 7) || (IsaPrgLnk) || (IsRealExecutable(PrgPth) < 1))
	{
	; Can happen if the file is in sysdir and/or has restricted access
	GuiControl, PrgLnchOpt:, UpdturlPrgLnch
	GuiControl, PrgLnchOpt: Disable, UpdturlPrgLnch
		;paranoia
		if (IsaPrgLnk)
		PrgVer[selPrgChoice] := 0
	PrgURLGui(PrgUrl, PrgUrlTest, SelPrgChoice, 1)
	return
	}
}


GuiControl, PrgLnchOpt: -ReadOnly, UpdturlPrgLnch

	if (currPrgUrl)
	{
	PrgURLGui(PrgUrl, PrgUrlTest, SelPrgChoice, 2)

	; duplication, but just in case something happened
	FileGetVersion, PrgverOld, % PrgPth
		if (ErrorLevel)
		{
		PrgVer[selPrgChoice] := 0
		CreateToolTip("FileGetVersion: currPrgUrl: Problem with retrieving local version info for file:`n" . """" . PrgPth . """" . ".")
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
						CreateToolTip("FileGetVersion: Problem with retrieving local version info from the following Prg:`n" . """" . PrgPth . """" . ".")
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

ChkURLPrgExe(TstUrl)
{
strTemp := 0, temp := 0
;strTemp := SubStr(PrgUrlTest, InStr(PrgUrlTest, ".",, -1) + 1)
SplitPath, TstUrl,,, strTemp
	if (IsRealExecutable(TstUrl) > -1)
	return 0
	else
	{

		if (strTemp == "gz") || (strTemp == "Z") || (strTemp == "bz2") || (strTemp == "lzma") || (strTemp == "xz")
		{
		SplitPath, strTemp,,, temp
		if (temp == "tar")
		return 1
		}
		else
		{
		if (strTemp == "tgz") || (strTemp == "tbz2") || (strTemp == "tlz") || (strTemp == "txz") || (strTemp == "xz") || (strTemp == "7z") || (strTemp == "alz") || (strTemp == "arj") || (strTemp == "cab") || (strTemp == "cfs") ||	(strTemp == "jar") || (strTemp == "lzh") || (strTemp == "lha") || (strTemp == "paq6") || (strTemp == "paq7") || (strTemp == "paq8") || (strTemp == "pea") || (strTemp == "rar") || (strTemp == "paq6") || (strTemp == "sit") || (strTemp == "sitx") || (strTemp == "xar") || (strTemp == "zip") || (strTemp == "zipx") || (strTemp == "zpaq") || (strTemp == "zz")
		return 1
		; There are others: apk arc ba b1 car cpt dar dgc dmg ear ha hki ice kgb partimg pim qda rk sen shk sqx  {uc .uc0 .uc2 .ucn .ur2 .ue2} uha war wim xp3 yz1 zoo
		}
	return -1
	} 

}

; https://autohotkey.com/board/topic/54927-regread-associated-program-for-a-file-extension/
AssocQueryApp(prgPath, ByRef cmdLine := "")
{

SplitPath, prgPath, , , Ext
;exe, com ,scr:  "real" executables
	if (IsRealExecutable(PrgPath))
	strPrg := prgPath
	else
	{
	SetRegView 32
	RegRead, type, % "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\." Ext, Application
		If (ErrorLevel)
		{
			;Default setting
		RegRead, type, % "HKCR\." . Ext
		RegRead, act, % "HKCR\" . type . "\shell"

			If (ErrorLevel)
			act = open
		RegRead, strPrg, % "HKCR\" . type . "\shell\" . act . "\command"
		}
		else
		{ ;Current user has overridden default setting
		RegRead, act, % "HKCU\Software\Classes\Applications\" . type . "\shell"
			If (ErrorLevel)
			act = open
		RegRead, strPrg, % "HKCU\Software\Classes\Applications\" . type . "\shell\" . act . "\command"
		}
		; strip first quote
	foundpos := InStr(strPrg, """")

	strPrg := SubStr(strPrg, foundpos + 1, StrLen(strPrg))
	; strip last quote and all that follows
	foundpos := InStr(strPrg, """")

		if (foundpos)
		strPrg := SubStr(strPrg, 1, foundpos-1)


	strPrg := ParseEnvVars(strPrg)
	; Assume coomand line parms like might be %1 added
		if (temp := Instr(strPrg, " `%1"))
		{
		cmdLine := prgPath
		strPrg := subStr(strPrg, 1, temp - 1)
		}
	}
return strPrg
}

; https://autohotkey.com/boards/viewtopic.php?t=5959
Util_VersionCompare(other, local)
{
	ver_other := StrSplit(other, ".")
	ver_local := StrSplit(local, ".")
	for _index, _num in ver_local
		if ((ver_other[_index]+0) > (_num+0) )
			return 1
		else if ((ver_other[_index]+0) < (_num+0) )
			return 0
	return 0
}

TooltipTimer:
CreateToolTip(tooltipText)
return

CreateToolTip(tooltipText)
{
Static OwnerHwnd := 0

	if (OwnerHwnd)
	{
	MouseGetPos,,, temp

	SetTimer, TooltipTimer, Delete
		if (temp == OwnerHwnd)
		{
		OwnerHwnd := 0
		return
		}
		else
		{
		Tooltip
		ToolTip, %tooltipText%, 0, 0
		OwnerHwnd := 0
		}
	}
	else
	{
	ToolTip
	MouseGetPos,,, OwnerHwnd
	ToolTip, %tooltipText%
	;OwnerHwnd := Format("0x{1:x}", OwnerHwnd)
	
		if ((OwnerHwnd == PrgLnch.Hwnd()) || (OwnerHwnd == PrgLnchOpt.Hwnd()))
		{

		CoordMode, ToolTip, Client
		MouseGetPos,x,y
		SysGet, temp, 31		
		
			if ((OwnerHwnd == PrgLnch.Hwnd()))
			{
			temp := floor(3 * (PrgLnch.Height()-temp)/4)
				if (y > temp)
				ToolTip, %tooltipText%, %x%, %temp%
			}
			else
			{
			temp := floor(2 * (PrgLnchOpt.Height()-temp)/3)
				if (y > temp)
				ToolTip, %tooltipText%, %x%, %temp%
			}		
		
		
		;lastTooltipText := tooltipText
		SetTimer, TooltipTimer, 120
		}
		else
		{
		ToolTip, %tooltipText%, 0, 0
		OwnerHwnd := 0
		}
	}
}

RepositionGuiToMouse(IsOptions := 0)
{
; This repositions the top left of the GUI to mouse cursor

;Close properties
PrgPropertiesClose()
id := "ahk_id"

	if (IsOptions)
	{
	id .= PrgLnchOpt.Hwnd()
	w := PrgLnchOpt.Width()
	h := PrgLnchOpt.Height()
	}
	else
	{
	id .= PrgLnch.Hwnd()
	w := PrgLnch.Width()
	h := PrgLnch.Height()
	}



strTemp := A_CoordModeMouse
CoordMode, Mouse, Screen
MouseGetPos, x, y
CoordMode, Mouse, % strTemp

	if (WinExist("PrgLnch.ahk") or WinExist("ahk_id" . PrgLnchOpt.Hwnd()) or WinExist("ahk_class" . PrgLnch.Title) or WinExist(PrgLnch.ProcAHK))
	{
		if (WinExist(%id%))
		{
		WinShow	%id%
		w := A_ScreenWidth - w
		h := A_ScreenHeight - h
			
			if ((x > w) && (y > h))
			WinMove, %id%,, %w%, %h%
			else
			{
				if (x > w)
				WinMove, %id%,, %w%, %y%
				else
				{
					if (y > h)
					WinMove, %id%,, %x%, %h%
					else
					WinMove, %id%,, %x%, %y%		
				}
			}

		}
		else
		{
		retVal := TaskDialog("Reposition Gui To Mouse", "Problem with locating a Prglnch form", , "Not a critical issue, but a sign that something`nin Windows isn't working for PrgLnch right now", "", "Quit Prglnch", "Do not quit PrgLnch")
			if (retVal == 1)
			GoSub PrgLnchButtonQuit_PrgLnch
		}
	}
}

#IfWinActive, Prg Properties (Version 2.x) ahk_class AutoHotkeyGUI

^!p::
RepositionGuiToMouse()
return

Esc::
PrgPropertiesClose()

return
#IfWinActive

#If WinActive(PrgLnchOpt.Title) and WinActive("ahk_class AutoHotkeyGUI")

Esc::
goSub BackToPrgLnch
return

^!p::
RepositionGuiToMouse(1)
return


^z::

GuiControlGet, strTemp, PrgLnchOpt: FocusV

	if (strTemp == "CmdLinPrm")
	{
	Tooltip
	ControlGetText, temp,,ahk_id %cmdLinHwnd%
		if (temp)
		{
		UndoTxt := temp
		GuiControl, PrgLnchOpt:, CmdLinPrm,
		}
		else
		{
		GuiControl, PrgLnchOpt:, CmdLinPrm, % UndoTxt
		UndoTxt := ""
		}
	}
	else
	{
		if (strTemp == "UpdturlPrgLnch")
		{
		ControlGetText, temp,,ahk_id %UpdturlHwnd%
			if (temp)
			{
			ToolTip
			UndoTxt := temp
			GuiControl, PrgLnchOpt:, UpdturlPrgLnch,
			}
			else
			{
			GuiControl, PrgLnchOpt:, UpdturlPrgLnch, % UndoTxt
			UndoTxt := ""
			}
		}
		else
		{
			if (strTemp == "PrgChoice")
			{
			ToolTip
			ControlGetText, temp,,ahk_id %PrgChoiceHwnd%
				if (temp)
				{
				UndoTxt := temp
				GuiControl, PrgLnchOpt: Text, PrgChoice,
				}
				else
				{
				GuiControl, PrgLnchOpt: Text, PrgChoice, % UndoTxt
				UndoTxt := ""
				}
			}
		}
	}
return

Del::

GuiControlGet, strTemp, PrgLnchOpt: FocusV
GuiControlGet, temp, PrgLnchOpt:, MkShortcut
	if (strTemp == "PrgChoice")
	{
		if (InStr(temp, "Change Shortcut"))
		{
		UndoTxt := txtPrgChoice
		txtPrgChoice := ""
		ControlSetText,,,ahk_id %PrgChoiceHwnd%
		GuiControl, PrgLnchOpt:, MkShortcut, Remove Shortcut
			if (PrgChoicePaths[selPrgChoice])
			CreateToolTip("Click " . """" . "Remove Shortcut" . """" . " or hit Del to confirm.")
			else
			CreateToolTip("Click " . """" . "Remove Shortcut" . """" . " or hit Del to remove unexpected data from reference.")
			return
		}
		else
		{
			if (temp == "Remove Shortcut")
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
		if (strTemp == "UpdturlPrgLnch")
		{
			ToolTip
			GuiControlGet UndoTxt, PrgLnchOpt:, UpdturlPrgLnch
			GuiControl, PrgLnchOpt:, UpdturlPrgLnch
			GuiControl, PrgLnchOpt: Disable, UpdtPrgLnch
			GuiControl, PrgLnchOpt:, newVerPrg
			PrgUrl[selPrgChoice] := ""
			IniProc(selPrgChoice)
		}
		else
		{
			if (strTemp == "CmdLinPrm")
			{
				ToolTip
				GuiControlGet UndoTxt, PrgLnchOpt:, CmdLinPrm
				GuiControl, PrgLnchOpt:, CmdLinPrm
				UndoTxt := PrgCmdLine[selPrgChoice]
				PrgCmdLine[selPrgChoice] := ""
				IniProc(selPrgChoice)
			}
			else
			{
			if (temp == "Remove Shortcut")
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
return
#IfWinActive



#IfWinActive, PrgLnch ahk_class AutoHotkeyGUI

PrgLnchButtonQuit_PrgLnch:
PrgLnchGuiEscape:
;PrgLnchGuiClose: ; not mandatory
Gui PrgLnch: +OwnDialogs
critical

	if (GoConfigTxt == "Del LnchPad" || GoConfigTxt == "Save LnchPad")
	{
	tooltip
	GoConfigTxt = Prg Config
	GuiControl, PrgLnch:, GoConfigVar, % "&" GoConfigTxt
	return
	}


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
				strRetVal := ExtractPrgPath(A_Index, 0, strRetVal, PrgLnkInf, 0, IniFileShortctSep, IsaPrgLnk)

				if (strRetVal := GetProcFromPath(strRetVal, Instr(strRetVal, IniFileShortctSep)))
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
				strRetVal := ExtractPrgPath(selPrgChoice, PrgChoicePaths, 0, PrgLnkInf, 0, IniFileShortctSep, IsaPrgLnk)

					if (strRetVal := GetProcFromPath(strRetVal))
					(strTemp2)? strTemp2 := "`[Test Run`]: """ . strRetVal . """`n" . strTemp2: strTemp2 := "`[Test Run`]: """ . strRetVal . """"
				}
			}
	}

	if (strTemp2)
	{
		if ((Instr(strTemp2, "`n")) || (Instr(strTemp2, ",")))
		{
		temp := "Prgs are"
		strTemp := "them"
		}
		else
		{
		temp := "A Prg is"
		strTemp := "it"
		}

		if (!PrgTermExit)
		{
			PrgTermExit := TaskDialog("Active on Quit", temp . " still running!`n" . strTemp2, , "If the active Prgs in a Batch Preset are not cancelled before Prglnch Quit, they'll`nbe automatically re-assigned to the (selected) Preset if active on PrgLnch rerun.`nAs a general rule, whenever the " . """" . " Do not show this again" . """" . " option is checked,`nthis dialog can only be restored by manually editing the LnchPad Slot ini file.`nThis tends to happen more when the " . """" . "Close" . """" . " option is clicked.", , "Close " . strTemp, "Do not close " . strTemp . " (Recommended)")
				if (PrgTermExit < 0)
				{
				PrgTermExit := -PrgTermExit
				IniWrite, %PrgTermExit%, % PrgLnch.SelIniChoicePath, Prgs, PrgTermExit
				}
		}

	}

}

if (PrgTermExit == 1)
{ ;cancel Prgs

	loop % PrgNo
		{
		temp := PrgPIDMast[A_Index]
		if (temp)
		{
		WinClose, ahk_pid%temp%
		sleep, 100
		}

		if (temp)
		KillPrg(temp)
		}
	if (PrgPID)
	{
	WinClose, ahk_pid%PrgPID%
	sleep, 100
		if (PrgPID)
		KillPrg(PrgPID)
	}
}

SetTimer, NewThreadforDownload, Delete ;Cleanup
CloseChm()
PrgPropertiesClose()

strTemp := ""
strTemp2 := ""
loop % PrgNo
{
	if (PrgChoicePaths[A_Index])
	{
	; strIniChoice used as temp!
	strIniChoice := ExtractPrgPath(A_Index, 0, PrgChoicePaths[A_Index], PrgLnkInf, PrgResolveShortcut, IniFileShortctSep, temp)

		if (strIniChoice && temp > -1) ; Don't care about invalid links etc- (but we do really!)
		{
			if (temp) ;IsaPrgLnk
			strIniChoice := PrgLnkInf[A_Index]
			

		strRetVal := WorkingDirectory(strIniChoice, 1)

			If (strRetVal)
			strTemp2 .= "`n" . strRetVal
			else
			{
				if (!InStr(strIniChoice, A_ScriptDir))
				{
					if (!temp)
					{
					SplitPath, strIniChoice, , strIniChoice
					strIniChoice .= "\"
					}
				fTemp := KleenupPrgLnchFiles(strIniChoice) ; An old (fixed?) bug where these ended up in wrong directory
					if (fTemp)
					strTemp .= "`nFile(s): """ . fTemp . """ found in """ . strIniChoice . """ marked for the Recycle Bin."
				}
			}
		}
	}
}

strRetVal := WorkingDirectory(A_ScriptDir, 1)

	if (strRetVal)
	MsgBox, 8192, PrgLnch Remnants, % "*Critical Error with the directory containing PrgLnch executable!*`n" . strRetVal
	else
	{
	KleenupPrgLnchFiles() ; PrgLnch files removed from PrgLnch Directory only
		if FileExist(PrgLnch.SelIniChoicePath)
		{
			if Instr(strTemp2, "`n")
			{
				if (Instr(strTemp2, "`n", , 2))
				strTemp2 := "The following directories could not be scanned" . strTemp2
				else
				strTemp2 := "The following directory could not be scanned" . strTemp2
			}
			if (strTemp)
			strTemp := "`nAlso`," . strTemp

		IniRead, fTemp, % PrgLnch.SelIniChoicePath, General, PrgCleanOnExit
			; Versioning:  IniSpaceCleaner moves this before ResMode
			if (fTemp = "ERROR")
			{
			IniWrite, %A_Space%, % PrgLnch.SelIniChoicePath, General, PrgCleanOnExit
			fTemp := 0
			}

			if (!fTemp && (strTemp2 || strTemp))
			{
			retVal := TaskDialog("PrgLnch Remnants", strTemp2 .  strTemp, "", ((strTemp2)? "The typical reason for the scan error is Prg removal`\relocation,`nor that the PrgLnch ini file originates from another device.`n": "") . ((strTemp)? "The file recycle notification is a problem with PrgLnch.": ""), , "Continue")
				if (retVal < 1)
				IniWrite, 1, % PrgLnch.SelIniChoicePath, General, PrgCleanOnExit
			}
		}
	}

; Gui, Progrezz: Destroy ; automatic, as with PrgLnchOpt: PrgLnch


arrPowerPlanNames = ""
btchPowerName = ""
iDevNumArray = ""
IniChoiceNames = ""
PresetNames = ""
PresetNamesBak = ""

Loop %maxBatchPrgs%
{
PrgBatchIni%A_Index% = ""
PrgListPID%A_Index% = ""
}

PrgBdyBtchTog = ""
PrgBdyBtchTogTmp = ""
PrgBordless = ""
PrgChgResOnClose = ""
PrgChgResOnSwitch = ""
PrgChoiceNames = ""
PrgChoicePaths = ""
PrgCmdLine = ""
PrgListIndex = ""
PrgListIndexTmp = ""
PrgLnchHide = ""
PrgLnkInf = ""
PrgMonToRn = ""
PrgPIDMast = ""
PrgResolveShortcut = ""
PrgRnMinMax = ""
PrgRnPriority = ""
PrgUrl = ""
PrgVer = ""

scrWidthDefArr = ""
scrHeightDefArr = ""
scrFreqDefArr = ""

DopowerPlan()

OnMessage(0x112, "WM_SYSCOMMAND", 0)
OnMessage(0x0053, "WM_Help", 0)
OnMessage(0x201, "WM_LBUTTONDOWN", 0)
ExitApp




^!p::
; This repositions the top left of the GUI to mouse cursor
RepositionGuiToMouse()
return

^z::

GuiControlGet, strTemp, PrgLnch: FocusV
	if (strTemp == "PresetName")
	{
	Tooltip
	ControlGetText, temp,,ahk_id %PresetNameHwnd%
		if (temp)
		{
		UndoTxt := temp
		GuiControl, PrgLnch: Text, PresetName,
		}
		else
		{
		GuiControl, PrgLnch: Text, PresetName, % UndoTxt
		UndoTxt := ""
		}
	}
	else
	{
		if (strTemp == "IniChoice")
		{
		Tooltip
		ControlGetText, temp,,ahk_id %IniChoiceHwnd%
			if (temp)
			{
				if (temp != "ini" . iniSel)
				{
				UndoTxt := temp
				GuiControl, PrgLnch: Text, IniChoice,
				GoConfigTxt = Prg Config
				GuiControl, PrgLnch:, GoConfigVar, % "&" GoConfigTxt
				}
			}
			else
			{
				if (UndoTxt != "")
				{
				GoConfigTxt := "Save LnchPad"
				CreateToolTip("Click `" . GoConfigTxt . """" . " to save.")
				GuiControl, PrgLnch:, GoConfigVar, % GoConfigTxt
				GuiControl, PrgLnch: Text, IniChoice, % UndoTxt
				UndoTxt := ""
				}
			}
		}
	}
return

Del::
GuiControlGet, strTemp, PrgLnch: FocusV

	if (strTemp == "PresetName")
	{
		if (ffTemp == 1)
		return
	GuiControlGet, UndoTxt,, %PresetNameHwnd%
	GuiControl, PrgLnch:, PresetName,
	;PresetNameSub automatically invoked
	}
	else
	{
		if (strTemp == "IniChoice")
		{
			if (GoConfigTxt == "Del LnchPad")
			{
				if (DelIniPresetProc(iniSel, GoConfigTxt, iniTxtPadChoice, SelIniChoiceName, oldSelIniChoiceName, IniChoiceNames, PrgNo, strIniChoice))
				RestartPrgLnch(0, oldSelIniChoiceName, SelIniChoiceName)
				else
				GuiControl, PrgLnch:, GoConfigVar, % "&" GoConfigTxt
			}
			else
			{
			ControlGetText, UndoTxt,,ahk_id %IniChoiceHwnd%
			ControlSetText,,,ahk_id %IniChoiceHwnd%
				if (UndoTxt && (SelIniChoiceName == "PrgLnch") && (UndoTxt != "PrgLnch"))
				{
				Tooltip
				GoConfigTxt = Prg Config
				GuiControl, PrgLnch:, GoConfigVar, % GoConfigTxt
				}
				else
				{
					if (!(ChkPrgNames(SelIniChoiceName, PrgNo, "Ini", 1) || SelIniChoiceName == "PrgLnch"))
					{
					GoConfigTxt = Del LnchPad
					CreateToolTip("Click `" . GoConfigTxt . """" . " or hit Del to confirm.")
					GuiControl, PrgLnch:, GoConfigVar, % GoConfigTxt
					}
				}
			}
		}
	}
return
#IfWinActive

SetStartupname(ByRef defPrgStrng, PrgChoiceNames, selPrgChoice, newName := 0)
{
	if (newName)
	{
		if (PrgChoiceNames[selPrgChoice] == defPrgStrng)
		{
		IniWrite, % newName, % PrgLnch.SelIniChoicePath, Prgs, StartupPrgName
		defPrgStrng := newName
		}
	}
	else
	{
	IniRead, defPrgStrng, % PrgLnch.SelIniChoicePath, Prgs, StartupPrgName, %A_Space%
	GuiControlGet temp, PrgLnchOpt:, MkShortcut
		if (temp == "Just Change Res.") ; Otherwise don't care if typed over "None"
		{
		GuiControl, PrgLnchOpt: , DefaultPrg, 0
		GuiControl, PrgLnchOpt: Disable, DefaultPrg
		}
		else
		{
			if (PrgChoiceNames[selPrgChoice] == defPrgStrng) ;Default here
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
	if (Msg == WM_HELPMSG)
	WM_HELP(0, lParam, WM_HELPMSG, hWnd)
	else
	{
    MouseGetPos, , , , mControl ; mX relative to FORM
	; Bizarro results with OutputVarControl so get class instead
	WinGetClass, class, ahk_id %hWnd%
		if (class="tooltips_class32")
		ToolTip
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
if ((presetNoTest && strTemp == "&Run Batch") || (!presetNoTest && temp == "&Test Run Prg"))
{
	lnchPrgIndex := selPrgChoice ; changes in next loop
	strRetVal := ChkExistingProcess(PrgLnkInf, presetNoTest, selPrgChoice, currBatchNo, PrgBatchIni%btchPrgPresetSel%, PrgChoicePaths, IniFileShortctSep, 1)

	if (strRetVal)
	{
		if (strRetVal == "PrgLnch")
		{
		MsgBox, 8192, PrgLnch Name, Cannot launch this Prg!
		return
		}

		if (strRetVal == "BadPath")
		return

		IniRead, fTemp, % PrgLnch.SelIniChoicePath, General, PrgAlreadyMsg
		if (!fTemp)
		{
		retVal := TaskDialog("Prg Processes", "A Prg set to be launched is already active", , "The name of one or more Prgs scheduled for start is matching the name at least one active process. This is acceptable when Prg can run in more than one instance, otherwise it won't launch on continuation.", , "Continue launching", "Abort the launch")
			if (retVal < 0)
			{
			retVal := -retVal
			IniWrite, %retVal%, % PrgLnch.SelIniChoicePath, General, PrgAlreadyMsg
			}
			if (retVal == 2)
			return
		}

	}

	if (!presetNoTest && temp == "&Test Run Prg")
	{
	lnchStat := -1
	targMonitorNum := PrgMonToRn[lnchPrgIndex]
	}
	else
	lnchStat := 1

}
else
{
	if (!(presetNoTest) && temp == "Change Res`.")
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
	; save to old
	CopyToFromRes(targMonitorNum, 1, -1)

;	 Update Prg index

	if (presetNoTest)
	{
	temp := PrgBatchIni%btchPrgPresetSel%[A_Index]
	targMonitorNum := PrgMonToRn[temp]
	StoreFetchPrgRes(1, temp, PrgLnkInf, targMonitorNum)

		if (lnchPrgIndex > 0)
		{
		;Init all to batch
		PrgListPID%btchPrgPresetSel%[A_Index] := "NS"
		;Hide the quit and config buttons!
		HideShowLnchControls(quitHwnd, GoConfigHwnd)

		lnchPrgIndex := temp

		temp := PrgChoicePaths[lnchPrgIndex]
		SplashyProc("*Launching")
		sleep, % (!PrgIntervalLnch)? 2000: (PrgIntervalLnch == -1)? 4000: 6000
		}
		else
		{
		lnchPrgIndex := -temp
		temp := PrgChoicePaths[-lnchPrgIndex]
		}
	}

	strRetVal := LnchPrgOff(A_Index, lnchStat, PrgChoiceNames, (presetNoTest)? temp: strTemp2, PrgLnkInf, PrgResolveShortcut, IniFileShortctSep, (presetNoTest)? currBatchno: 1, lnchPrgIndex, PrgCmdLine, iDevNumArray, PrgMonPID, PrgRnMinMax, PrgRnPriority, PrgBordless, borderToggle, targMonitorNum, PrgPID, PrgListPID%btchPrgPresetSel%, PrgMinMaxVar, PrgStyle, btchPowerNames[btchPrgPresetSel])

	if (strRetVal)
	{  ;Lnch failed for current Prg

		if (strRetVal == "|")
		strTemp .= "Started" . strRetVal
		else
		{
			if (lnchPrgIndex)
			{
				if (lnchPrgIndex > 0)
				{
					if (lnchStat == 1)
					strTemp .= "Failed" . "|"
				}

			MsgBox, 8192, Prg Launch, % strRetVal

			; restore from old
			CopyToFromRes(targMonitorNum, 0, -1)
				if (DefResNoMatchRes(1) && ChangeResolution(targMonitorNum))
				; restore from defaults when fail
				CopyToFromRes(targMonitorNum)
				else
				sleep, 300
			}
			else
			MsgBox, 8192, Change Resolution, % strRetVal
		}
	}
	else
	{
	SetResDefaults(lnchStat, targMonitorNum, scrWidthDefArr, scrHeightDefArr, scrFreqDefArr)
		if (lnchStat < 0) ;test run
		{
			if (lnchPrgIndex > 0)
			{
				if (PrgLnchHide[selPrgChoice])
				Gui, PrgLnchOpt: Show, Hide
				else
				{
				WinMover(PrgLnchOpt.Hwnd(), "d r")
				HideShowTestRunCtrls()
				Gui, PrgLnchOpt: Show,, % PrgLnchOpt.Title
				}
			}
			else
			{
				if (lnchPrgIndex)
				;just cancelled- but not from a hidden form!
				CleanupPID(currBatchNo, lastMonitorUsedInBatch, PrgMonToRn, presetNoTest, PrgListPID%btchPrgPresetSel%, PrgStyle, PrgBordless, PrgLnchHide, PrgPID, PrgChgResOnClose, selPrgChoice, waitBreak)
				; else Change res
			}
		}
		else
		{
			if (lnchPrgIndex > 0)
			{
				if (PrgLnchHide[lnchPrgIndex])
				Gui, PrgLnch: Show, Hide
				else
				WinMover(PrgLnch.Hwnd(), "d r", PrgLnchOpt.Width() * 61/80, PrgLnchOpt.Height() * 13/10)
			strTemp .= "Active" . "|"
			}
			else
			{
			; Cancelling the lot!
				strTemp .= "Not Active" . "|"
				if (lnchPrgIndex < 0)
				{
					if (PrgChgResOnClose[abs(lnchPrgIndex)] && (temp := RevertResLastPrgProc(maxBatchPrgs, PrgMonPID)))
					{
						if (DefResNoMatchRes(1))
						{
						; restore from defaults
						CopyToFromRes(targMonitorNum)
						ChangeResolution(temp)
						sleep, 300
						}
					}

					if (currBatchno == A_Index)
					CleanupPID(currBatchNo, lastMonitorUsedInBatch, PrgMonToRn, presetNoTest, PrgListPID%btchPrgPresetSel%, PrgStyle, PrgBordless, PrgLnchHide, PrgPID, PrgChgResOnClose, selPrgChoice, waitBreak, 1)
				}
			}
			; Update Master
			PrgPIDMast[lnchPrgIndex] := PrgListPID%btchPrgPresetSel%[A_Index]
		}
	}
SplashyProc("*Release")
}

sleep 300

;Start Timer & update status list & fix buttons
Thread, NoTimers, false


	; This is because of the case where the only Prg in a Batch Preset is also a test run!
	if (IsCurrentBatchRunning(currBatchNo, PrgListPID%btchPrgPresetSel%))
	batchActive := 1
	else
	batchActive := 0



	if (lnchStat < 0)
	{
		if (PrgPID)
		{
		waitBreak := 0
		SetTimer, WatchSwitchOut, -%timWatchSwitch%
		}
		else ;in case something else running
		{

			loop % PrgNo
			{
				if (PrgPIDMast[A_Index])
				{
				waitBreak := 0
				SetTimer, WatchSwitchOut, %timWatchSwitch%
				break
				}
			}

			if (lnchPrgIndex && !batchActive)
			{
			CleanupPID(currBatchNo, lastMonitorUsedInBatch, PrgMonToRn, presetNoTest, PrgListPID%btchPrgPresetSel%, PrgStyle, PrgBordless, PrgLnchHide, PrgPID, PrgChgResOnClose, selPrgChoice, waitBreak)
			return
			}
		}
	}
	else
	{

	GuiControl, PrgLnch:, batchPrgStatus, %strTemp%

	HideShowLnchControls(quitHwnd, GoConfigHwnd, 1)

	temp := 0

		if (batchActive)
		{
		GuiControl, PrgLnch:, RunBatchPrg, &Cancel Batch
		waitBreak := 0
		SetTimer, WatchSwitchOut, %timWatchSwitch%
		}
		else
		{
			if (PrgPID)
			{
			waitBreak := 0
			SetTimer, WatchSwitchOut, %timWatchSwitch%
			}
		GuiControl, PrgLnch:, RunBatchPrg, &Run Batch
		}

	; Update PrgMonBak
	if (lnchStat == 1 && lnchPrgIndex > 0)
	RevertResLastPrgProc(maxBatchPrgs, PrgMonPID, , 1)
	}


return


LnchPrgOff(prgIndex, lnchStat, PrgNames, PrgPaths, PrgLnkInf, PrgResolveShortcut, IniFileShortctSep, currBatchno, lnchPrgIndex, PrgCmdLine, iDevNumArray, ByRef PrgMonPID, PrgRnMinMax, PrgRnPriority, PrgBordless, borderToggle, ByRef targMonitorNum, ByRef PrgPID, ByRef PrgListPID, ByRef PrgMinMaxVar, ByRef PrgStyle, btchPowerName)
{
PrgLnchMon := 0, primaryMon := 0, disableRedirect := 0, PrgPIDtmp := 0, PrgPrty := "N", IsaPrgLnk := 0, PrgLnkInflnchPrgIndex := PrgLnkInf[lnchPrgIndex]
temp := 0, fTemp := 0, strRetVal := "", wkDir := "", PrgPathsAssocCommandLine := ""

Static ERROR_FILE_NOT_FOUND := 0x2, ERROR_ACCESS_DENIED := 0x5, ERROR_CANCELLED := 0x4C7


PrgLnchMon := GetPrgLnchMonNum(iDevNumArray, primaryMon)

if (PrgLnch.Monitor != PrgLnchMon)
{
	IniRead, fTemp, % PrgLnch.SelIniChoicePath, General, LnchPrgMonWarn
	if (!fTemp)
	{
	retVal := TaskDialog("PrgLnch Position", "PrgLnch was moved to another monitor", , "PrgLnch was moved to monitor #" . PrgLnchMon . " either by mouse or another process. All PrgLnch generated messages will be directed there.", , "Continue the launch")
		if (retVal < 0)
		IniWrite, 1, % PrgLnch.SelIniChoicePath, General, LnchPrgMonWarn

		if (lnchStat > 0)
		MovePrgToMonitor(PrgLnchMon, 0, 0, 0, 0, 0, 0, 0, 0, Splashy.hWndSaved[1])
	}
PrgLnch.Monitor := PrgLnchMon
}


if (lnchPrgIndex > 0) ;Running
{
	;Fix priority
	temp := (PrgRnPriority[lnchPrgIndex])
	(!temp)? PrgPrty := "B": (temp == 1)? PrgPrty := "H": PrgPrty := "N"
	PrgPaths := ExtractPrgPath(lnchPrgIndex, 0, PrgPaths, PrgLnkInf, PrgResolveShortcut, IniFileShortctSep, IsaPrgLnk)

	if ((IsaPrgLnk > -1) && ((strRetVal := PrgPaths) != AssocQueryApp(PrgPaths))) ; must be an association
	{
		if (IsaPrgLnk)
		{
			;Treat as regular association
			If (PrgResolveShortcut[lnchPrgIndex])
			IsaPrgLnk := 0

			if (!IsaPrgLnk)
			{
			; "Easiest" way to use working dir for associations
			SplitPath, PrgPaths,, wkDir
			PrgPaths := AssocQueryApp(PrgPaths)
			}

		}
		else
		{
		SplitPath, PrgPaths,, wkDir
		PrgPaths := AssocQueryApp(PrgPaths, strRetVal)

			if (PrgPaths)
			{
				if (strRetVal)
				{
				PrgPathsAssocCommandLine := PrgPaths . A_Space . """" . strRetVal . """"
				strRetVal := ""
				}
			}
			else
			return "Association Removed.`nThe Prg must have an association before it can be used."
		
		}
	}

	if (!FileExist(PrgPaths))
	{
	; https://www.autohotkey.com/boards/viewtopic.php?f=76&t=31269
		if (A_Is64bitOS && A_PtrSize == 4)
		{
			if (!(disableRedirect := DllCall("Wow64DisableWow64FsRedirection", "Ptr*", oldRedirectionValue)))
			return % PrgLnch.SelIniChoicePath . " does not exist and there is a redirection error!"
		}
	sleep 20
	}

	if (FileExist(PrgPaths))
	;If Notepad, copy Notepad exe to  %A_ScriptDir% and it will not run! (Windows 10 1607)
	{

		if (!IsaPrgLnk)
		{
		; In most cases wkDir is null, so set the working directory as the Prg location
		strRetVal := WorkingDirectory(PrgPaths, 1)
			If (strRetVal)
			{
				if (disableRedirect)
				DllCall("Wow64RevertWow64FsRedirection", "Ptr", oldRedirectionValue)
			return strRetVal
			}
		}

		;Special case for scr
		if (IsaPrgLnk && PrgResolveShortcut[lnchPrgIndex] && Instr(PrgPaths, ".scr", , Strlen(PrgPaths) - 4), Strlen(PrgPaths))
		PrgPaths := "*Config " . PrgPaths

	

		if (((IsaPrgLnk && PrgResolveShortcut[lnchPrgIndex]) || !IsaPrgLnk) && PrgCmdLine[lnchPrgIndex])
		PrgPaths := PrgPaths . A_Space . QuoterizeCommandStringArgs(PrgPaths, PrgCmdLine[lnchPrgIndex])

		if (PrgPathsAssocCommandLine)
		PrgPaths := PrgPathsAssocCommandLine



	;WinHide ahk_class Shell_TrayWnd ;Necessary?
		if (!Instr(PrgLnkInflnchPrgIndex, "|") && !Instr(PrgLnkInflnchPrgIndex, IniFileShortctSep))
		{
			; Problems with showing the PrgLnch gui?
			if (targMonitorNum == PrgLnchMon)
			{

				if (PrgLnchOpt.scrWidth + 180 < PrgLnchOpt.scrWidthDef) ; 180 pixels might be enough?
				{
				IniRead, fTemp, % PrgLnch.SelIniChoicePath, General, LoseGuiChangeResWrn
					if (!fTemp)
					{
					retVal := TaskDialog("Switching to lower resolution", "Shortcut key for PrgLnch Positioning", " Click " . """" . "See details" . """" . " on <CTRL-Alt-P> before continuing", "In the rare case of the PrgLnch GUI relocating off screen`nafter switching to a lower screen resolution, the keyboard`nshortcut, <CTRL-Alt-P> returns PrgLnch to focus", , "Continue launch (Recommended)", "Cancel launch")
						if (retVal < 0)
						{
						retVal := -retVal
						IniWrite, %retVal%, % PrgLnch.SelIniChoicePath, General, LoseGuiChangeResWrn
						}

						if (retVal == 2)
						{
							if (disableRedirect)
							DllCall("Wow64RevertWow64FsRedirection", "Ptr", oldRedirectionValue)
						return "Cancelled!"
						}

					; reposition Splashy
					SplashyProc("*Launching")
					}
				}
			}

			;*************************************************
			; Monitor Checks

			if (DefResNoMatchRes())
			{
				if (strRetVal := ChangeResolution(targMonitorNum))
				{
				retVal := TaskDialog("Screen Resolution", "Resolution change failed", , "Res. change reported an error when launching " . PrgNames[lnchPrgIndex] . ".`nPrg's saved resolution data is: " . PrgLnchOpt.scrWidth . " width, " . PrgLnchOpt.scrHeight . " height, at " . PrgLnchOpt.scrFreq . " Hz.`nReason for failure: `n" . """" . strRetVal . "." . """" . "`nUpon continuation of the launch, the Prg should (but is not guaranteed) to become visible in the primary (or default) monitor at its current resolution.", "", "Continue launching " . PrgNames[lnchPrgIndex], "Cancel launch")
					if (retVal == 1)
					{
					SplashyProc("*Launching")
					Sleep 100
					}
					else
					{
						if (disableRedirect)
						DllCall("Wow64RevertWow64FsRedirection", "Ptr", oldRedirectionValue)
					return "Cancelled!"
					}
				}
				else
				Sleep 300
			}
		}


		if (Instr(PrgPaths, "DOSBox.exe"))
		{
			if (!(InitDOSBoxGameDir(PrgPaths)))
			{
				if (disableRedirect) ; doubt it for DOSBox- just to be sure
				DllCall("Wow64RevertWow64FsRedirection", "Ptr", oldRedirectionValue)
			return "No Game selected!"
			}
		}


	;try
	;{
	Run, %PrgPaths%, % (IsaPrgLnk)? PrgLnkInflnchPrgIndex: wkDir, % "UseErrorLevel" ((IsaPrgLnk == -1)? "": (PrgRnMinMax[lnchPrgIndex])? ((PrgRnMinMax[lnchPrgIndex] > 0)? "Max": ""): "Min"), PrgPIDtmp

	;}
	;catch temp
	;{

		if (A_LastError)
		{
		sleep, 30
			if (A_LastError == ERROR_FILE_NOT_FOUND || A_LastError == ERROR_ACCESS_DENIED || A_LastError == ERROR_CANCELLED)
			{
				if (A_IsAdmin)
				{
				outStr := PrgNames[lnchPrgIndex] . " cannot launch with error " . A_LastError . ".`nIs it a system file, or does it have special permissions?"
					if (disableRedirect)
					DllCall("Wow64RevertWow64FsRedirection", "Ptr", oldRedirectionValue)
				return outStr
				}
				else
				retVal := TaskDialog("Prg Launch", "Prg Launch failed: Retry elevated?", , PrgNames[lnchPrgIndex] . " cannot launch with error " A_LastError ".`nIs it a system file, or does it have special permissions?`nPrgLnch might be able to launch it with Admin privileges.", "", "Attempt to restart PrgLnch as Admin", "Do not restart PrgLnch")

				;Try elevation?
				if (disableRedirect)
				DllCall("Wow64RevertWow64FsRedirection", "Ptr", oldRedirectionValue)

				if (retVal == 1)
				return RestartPrgLnch(1)
				else
				return "Prg could not be run with the current credentials."
			}
			else
			{
				;Add to PID list
				PrgPIDtmp := "TERM"
				FixPrgPIDStatus(currBatchno, prgIndex, lnchStat, PrgPIDtmp, PrgPID, PrgListPID)
				;WinShow ahk_class Shell_TrayWnd
				outStr := PrgNames[lnchPrgIndex] . " could not launch with error " . A_LastError
					if (disableRedirect)
					DllCall("Wow64RevertWow64FsRedirection", "Ptr", oldRedirectionValue)
				return outStr
			}
		}


		if (Instr(PrgPaths, "DOSBox.exe"))
		InitDOSBoxGameDir(PrgPaths, 1)

	Process, Priority, PrgPIDtmp, % PrgPrty
	;Add to PID list

	Sleep 200
	FixPrgPIDStatus(currBatchno, prgIndex, lnchStat, PrgPIDtmp, PrgPID, PrgListPID)
	Sleep 150

		if (lnchStat == 1)
		PrgMonPID[PrgPIDtmp] := targMonitorNum

	if (outStr := MovePrgToMonitor(targMonitorNum, PrgPIDtmp, PrgMinMaxVar, PrgStyle, PrgBordless, disableRedirect, oldRedirectionValue, PrgNames, lnchPrgIndex))
	return outStr
	;WinShow ahk_class Shell_TrayWnd

	; Set power here rather than at the beginning
		if (currBatchno == 1 & lnchStat == 1)
		{
			if (btchPowerName)
			DopowerPlan(btchPowerName)
		}

		if (disableRedirect)
		DllCall("Wow64RevertWow64FsRedirection", "Ptr", oldRedirectionValue)
	; Path links etc cannot be cancelled as they do not return a PID:
		if (InStr(PrgLnkInflnchPrgIndex, "|", false))
		return "|"

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
		if (disableRedirect)
		DllCall("Wow64RevertWow64FsRedirection", "Ptr", oldRedirectionValue)
	return outStr
	}

;WinWaitClose What about suspended task?


}
else
{

	if (lnchPrgIndex == 0) ;Just Change Res
	{
		GuiControlGet, targMonitorNum, PrgLnchOpt:, iDevNum

		if ((targMonitorNum != PrgLnchMon) || temp := DefResNoMatchRes())
		{
			if (!temp)
			return "Cancelled!"

			if (strRetVal := ChangeResolution(targMonitorNum))
			return % "Requested resolution change did not work. Reason: `n" strRetVal
			else
			WinMover(PrgLnchOpt.Hwnd(), "d r")

		}
		
	}
	else ;Cancel Prg: Either this or Waitclose
	{
		;Get batch no
		if (lnchStat == -1)
		{
		PrgPIDtmp := PrgPID
		PrgPID := 0
		}
		else
		{
		sleep, 120
		PrgPIDtmp := PrgListPID[prgIndex]
		PrgMonPID.Delete(PrgPIDtmp)
		PrgListPID[prgIndex] := 0

		;do not set PrgPID to 0 as it may be running in the frontend.
		}

		if (PrgPIDtmp)
		{
			if PrgPIDtmp is digit
			{
			PrgPaths := ExtractPrgPath(-lnchPrgIndex, 0, PrgPaths, PrgLnkInf, PrgResolveShortcut, IniFileShortctSep, IsaPrgLnk)
			temp := GetProcFromPath(PrgPaths)
			Process, Exist, %PrgPIDtmp%
				if (ErrorLevel)
				{
				;gets here if exists
				Process, Priority, %PrgPIDtmp%, H
				;set script priority high
				Process, Priority, , H
				WinClose, ahk_pid %PrgPIDtmp%
				sleep 220
				;Try again
				Process, Exist, %PrgPIDtmp%
					if (ErrorLevel)
					{
						if (PrgPIDtmp)
						{

						WinClose, ahk_pid %PrgPIDtmp%
						sleep, 220
						}

					sleep 30

						if (PrgPIDtmp)
						{
						retVal := TaskDialog("Closing Prg", "Closing " . """" . temp . """" . "failed", , "A common explanation is that resources like program libraries or files have not been released by Prg, else Prg has no way out of a loop cycle.`nWhen all attempts by PrgLnch to close " . """" . temp . """" . " have failed, it will`nno longer be monitored by Prglnch until PrgLnch is next restarted.", "", "Attempt force termination", "Do not force terminate")
							if (retVal == 1)
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
				IniRead, fTemp, % PrgLnch.SelIniChoicePath, General, ClosePrgWarn
					if (!fTemp)
					{
					retVal := TaskDialog("Closing Prg", """" . temp . """" . " has already terminated", , "PrgLnch was to have closed the Prg, but it has been terminated either by an external process/input or an internal instruction.", , "Continue")
						if (retVal < 0)
						IniWrite, 1, % PrgLnch.SelIniChoicePath, General, ClosePrgWarn
					PrgPIDtmp := ""
					}

				}
			}
		}
		;  else we assume it was invalid or cancelled via the timer

		PrgStyle := 0
		dx := 0
		dy:= 0

	}
}

return 0
}

MovePrgToMonitor(targMonitorNum, PrgPIDtmp, ByRef PrgMinMaxVar, ByRef PrgStyle, PrgBordless, disableRedirect, oldRedirectionValue, PrgNames, lnchPrgIndex, targHWnd := 0)
{
ms := 0, md := 0, msw := 0, mdw := 0, msh := 0, mdh := 0, mdRight := 0, mdLeft := 0, mdBottom := 0, mdTop := 0, msRight := 0, msLeft := 0, msBottom := 0, msTop := 0
DetectHiddenWindows, On

	if (targHWnd)
	WinGetPos, x, y, w, h, % "ahk_id" targHWnd
	else
	{
	WinGet, temp, MinMax, ahk_pid%PrgPIDtmp%

		if (temp)
		WinRestore, ahk_pid%PrgPIDtmp%


	WinGetPos, x, y, w, h, % "ahk_pid" PrgPIDtmp
	}

	if (w || h)
	fTemp := -1
	else
	fTemp := 0

SysGet, md, MonitorWorkArea, % targMonitorNum

	if (!((mdLeft - mdRight) && (mdTop - mdBottom)))
	{
	outStr := "Incorrect destination co-ordinates.`nIf the monitor has just been configured, a reboot may resolve the issue."
		if (disableRedirect)
		DllCall("Wow64RevertWow64FsRedirection", "Ptr", oldRedirectionValue)
	return outStr
	}
; Consider the (default) window co-ords in another monitor from a previous run here
; don't bother moving if the window is already located in the destination monitor
	if (fTemp && !(x >= mdLeft && x <= mdRight && y >= mdTop && y <= mdBottom))
	{
		loop % PrgLnchOpt.dispMonNamesNo
		{
			; no need to check source monitor if same as dest monitor
			; in which case this would never be reached
			if (targMonitorNum != A_Index)
			{
			SysGet, ms, MonitorWorkArea, % A_Index
				if (x >= msLeft && x <= msRight && y >= msTop && y <= msBottom)
				Break
			}
		}

	mdw := mdRight - mdLeft, mdh := mdBottom - mdTop
	msw := msRight - msLeft, msh := msBottom - msTop

	; Calculate new size for new monitor.
	dx := mdLeft + (x-msLeft)*(mdw/msw)
	dy := mdTop + (y-msTop)*(mdh/msh)

		; not for the Splashy monitor guis
		if (!targHWnd && wp_IsResizable())
		{
		w := Round(w*(mdw/msw))
		h := Round(h*(mdh/msh))
		}


	; Move window, using resolution difference to scale co-ordinates.

		try
		{
		fTemp := 1
		WinMove, % (targHWnd)? "ahk_id" . targHWnd: "ahk_pid" . PrgPIDtmp, , %dx%, %dy%, %w%, %h%
		}
		catch
		{
		sleep, 20
		WinGetPos, x, y, w, h, % (targHWnd)? "ahk_id" . targHWnd: "ahk_pid" . PrgPIDtmp
			if (w || h)
			{
				if (x == dx && y == dy)
				{
				MsgBox, 8192, Moving Prg, % " Move Window failed for " (targHWnd)? targHWnd: PrgNames[lnchPrgIndex]
				fTemp := 0
				}
			}
		}

		if (!targHWnd)
		{
			if (w || h)
			{
			dx := Round(dx + w/2)
			dy := Round(dy + h/2)
				if (fTemp)
				DllCall("SetCursorPos", "UInt", dx, "UInt", dy)
				else
				fTemp := 1
			}
		}
	}

; If fTemp == 0, anything goes !!??


	; Restore min/max
	if (temp == 1)
	WinMaximize, % (targHWnd)? "ahk_id" . targHWnd: "ahk_pid" . PrgPIDtmp
	else
	{
		if (temp == -1)
		WinMinimize, % (targHWnd)? "ahk_id" . targHWnd: "ahk_pid" . PrgPIDtmp
	}

	if (fTemp && borderToggle)
	{
	dx := mdLeft
	dy := mdTop
	BordlessProc(targMonitorNum, PrgMinMaxVar, PrgStyle, PrgBordless, lnchPrgIndex, PrgPIDtmp, 1, dx, dy) ; query
	}
	;Then we can Move window
	;WinGetPos,,, W, H, A
	;WinMove, A ,, mswLeft + (mswRight - mswLeft) // 2 - W // 2, mswTop + (mswBottom - mswTop) // 2 - H // 2

DetectHiddenWindows, Off
return 0
}


InitDOSBoxGameDir(PrgPaths, InitDOSBoxGame := 0)
{
Static mountedDrive := "", DOSBoxVer := "", gameDir := ""
if (InitDOSBoxGame)
	{
	SetTitleMatchMode, 2
		if (gameDir != "*")
		{
		; First dismount current drive
		fTemp := A_KeyDelay
		SetKeyDelay, 15

		sleep 20
		WinWaitActive, %DOSBoxVer%

		SendEvent, MOUNT -u %mountedDrive%
		sleep 20
		SendEvent, {Enter}
		sleep 20
		WinWaitActive, %DOSBoxVer%

		strTemp := "mount C " . """" . gameDir . """"

		WinWaitActive, %DOSBoxVer%
		SendEvent, %strTemp%

		sleep 200
		Send {Enter}
		sleep 20

		; Diskcaching reset
		WinWaitActive, %DOSBoxVer%
		Send !{F4}
		Send {Enter}
		}
	sleep 20
	WinWaitActive, %DOSBoxVer%
	; No support for CDRom
	Send, % mountedDrive . ":"
	Send {Enter}
	sleep 20
	Send dir /w /p
	Send {Enter}
	SetKeyDelay, %fTemp%
	}
	else ;InitDOSBoxGame 1
	{
	PrgPathNoCmdLine := Substr(PrgPaths, 1, Instr(PrgPaths, "DOSBox.exe") + 10)
	gameDir := ""
	; first check entry in conf- "supposed to "take care" of micro versioning

	FileGetVersion, DOSBoxVer, % PrgPathNoCmdLine

		if (ErrorLevel)
		return

	temp := Instr(DOSBoxVer, ".0", , strLen(DOSBoxVer) - 1)
		if (temp)
		DOSBoxVer := Substr(DOSBoxVer, 1, temp - 1)
	;now replace second period with hyphen
	temp := (Instr(DOSBoxVer, ".", , 1, 2))

	DOSBoxVer := Substr(DOSBoxVer, 1, temp - 1) . "-" . Substr(DOSBoxVer, temp + 1)
	confFile := "DOSBox-" . DOSBoxVer . ".conf"
	DOSBoxVer := "DOSBox " . DOSBoxVer
	EnvGet, wkDir, LOCALAPPDATA
	wkDir .= "\DOSBox\"

	FileRead, strTemp, % wkDir . confFile
	; after [autoexec] if line does not begin with #
	strTemp := Substr(strTemp, Instr(strTemp, "[autoexec]") + 10, Strlen(strTemp))

	strTemp2 := ""
		Loop, Parse, strTemp, `r`n
		{
			if ((A_Loopfield != "") && !Instr(A_Loopfield, "#", , 1, 1))
			{
				if ((Instr(A_Loopfield, "Mount", , 1, 1) == 1))
				{
					Loop, Parse, A_Loopfield, %A_Space%
					{
						if (A_Loopfield == "Mount")
						Continue
						else
						{
						mountedDrive := A_Loopfield
						Break			
						}
					}
				}
			strTemp2 .= A_Loopfield . "`n"
			}
		}

		if (strTemp2)
		{
		retVal := TaskDialog("DOSBox Configuration File", "The following entries are found in the [autoexec] section of the conf. file:`n`n" . strTemp2, , "", "", "Run DOSBox with those", "Select a different game")
			if (retVal == 1)
			gameDir := "*"
		}

		if (!gameDir)
		{
		FileSelectFolder, gameDir, % "*" . A_Desktop, 4, Select Folder containing the DOS game
			if (ErrorLevel)
			return
		}
	}
return gameDir
}

FixPrgPIDStatus(currBatchno, prgIndex, lnchStat, PrgPIDtmp, ByRef PrgPID, ByRef PrgListPID)
{
fTemp := 0
if (lnchStat == -1)
	{
		if (PrgPIDtmp == "TERM")
		PrgPID := 0
		else
		PrgPID := PrgPIDtmp

	}
	else
	{
		if (lnchStat == 1)
		{
			loop % currBatchno
			{
			fTemp := PrgListPID[A_Index]
				if fTemp is digit
				{
				Process, Exist, % fTemp
					if (!ErrorLevel)
					PrgListPID[A_Index] := "ENDED"
				}
				else
				{
					if (fTemp != "TERM")
					{
					PrgListPID[A_Index] := PrgPIDtmp
					Break
					}
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
SetTitleMatchMode, 3

if (WinActive(PrgLnch.Title) || WinActive(PrgLnchOpt.Title))
{
		if ((prgSwitchIndex)? PrgChgResOnSwitch[prgSwitchIndex]: PrgChgResOnSwitch[selPrgChoice])
		{
		; restore from defaults
		CopyToFromRes(targMonitorNum)
		targMonitorNum := (lnchStat < 0)? PrgMonToRn[selPrgChoice]: PrgMonToRn[prgSwitchIndex]
			if (DefResNoMatchRes(1) && PrgLnch.Monitor == targMonitorNum)
			{
			ChangeResolution(targMonitorNum)
			sleep, 300
			}
		}
	SetTimer, WatchSwitchBack, Off
	SetTimer, WatchSwitchOut, -%timWatchSwitch%
}
else
SetTimer, WatchSwitchBack, -%timWatchSwitch%
return

WatchSwitchOut:

Thread, Priority, -536870911 ; https://autohotkey.com/boards/viewtopic.php?f=13&t=29911


	if (presetNoTest) ; in the Prglnch screen
	{
		timerBtch := 0
		lastMonitorUsedInBatch := 0
		if (batchActive)
		{
		timerTemp := "|"
			loop % currBatchno
			{
			timerfTemp := PrgListPID%btchPrgPresetSel%[A_Index]

				switch (timerfTemp)
				{
					case "TERM":
					{
					timerTemp .= "Failed" . "|"
					PrgListPID%btchPrgPresetSel%[A_Index] := "Failed"
					}
					case "ENDED":
					timerTemp .= "Not Active" . "|"
					case "FAILED":
					timerTemp .= "Failed" . "|"
					case "NS":
					timerTemp .= "Not Started" . "|"
					default:
					{
						if (timerfTemp)
						{
						Process, Exist, % timerfTemp
						timerBtch := PrgBatchIni%btchPrgPresetSel%[A_Index]
							if (ErrorLevel)
							{
							timerTemp .= "Active" . "|"
							lastMonitorUsedInBatch := PrgMontoRn[timerBtch]
							}
							else
							{
							PrgListPID%btchPrgPresetSel%[A_Index] := "ENDED"
							timerTemp .= "Not Active" . "|"
								if (timerfTemp && PrgChgResOnClose[timerBtch])
								{
								; got PID just closed by user && update for each prg in batch
									if (PrgMonPID.delete(timerfTemp))
									{
										if (temp := RevertResLastPrgProc(maxBatchPrgs, PrgMonPID, timerfTemp) && DefResNoMatchRes(1))
										{
										; restore from defaults
										CopyToFromRes(targMonitorNum)
										ChangeResolution(temp)
										sleep, 300
										WinMover(PrgLnch.Hwnd(), "d r", PrgLnchOpt.Width() * 61/80, PrgLnchOpt.Height() * 13/10)
										}

									}
									else
									MsgBox, 8192, PID Check, % "PID for " . PrgChoiceNames[timerBtch] . " never existed!"
								}
							}
						}
						else
						timerTemp .= "Not Active" . "|"
					}
				}
			}

		GuiControl, PrgLnch:, batchPrgStatus, %timerTemp%
			if (!lastMonitorUsedInBatch)
			{
			batchActive := 0
			CleanupPID(currBatchNo, lastMonitorUsedInBatch, PrgMonToRn, presetNoTest, PrgListPID%btchPrgPresetSel%, PrgStyle, PrgBordless, PrgLnchHide, PrgPID, PrgChgResOnClose, selPrgChoice, waitBreak, 1)
				if (!PrgPID)
				return
			}
		}
		else
		{
			if (PrgPID)
			{
			Process, Exist, %PrgPID%
				if (!ErrorLevel)
				{
 				PrgPID := 0
				CleanupPID(currBatchNo, lastMonitorUsedInBatch, PrgMonToRn, presetNoTest, PrgListPID%btchPrgPresetSel%, PrgStyle, PrgBordless, PrgLnchHide, PrgPID, PrgChgResOnClose, selPrgChoice, waitBreak)
				return
				}
			}
		}
	}
	else ;In Config screen
	{
		if (PrgPID)
		{
		Process, Exist, %PrgPID%
			if (!ErrorLevel)
			{
			PrgPID := 0
			CleanupPID(currBatchNo, lastMonitorUsedInBatch, PrgMonToRn, presetNoTest, PrgListPID%btchPrgPresetSel%, PrgStyle, PrgBordless, PrgLnchHide, PrgPID, PrgChgResOnClose, selPrgChoice, waitBreak)
				if (!batchActive)
				return
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
				if (!(timerfTemp := PrgListPID%btchPrgPresetSel%[A_Index]))
				Continue
					if timerfTemp is digit
					{
					Process, Exist, % timerfTemp
						if (ErrorLevel)
						{
						timerBtch := PrgBatchIni%btchPrgPresetSel%[A_Index]
						lastMonitorUsedInBatch := PrgMontoRn[timerBtch]
						}
						else
						{
						; Do not modify PrgBatchIni%btchPrgPresetSel%[A_Index] until return to Batch Screen
							if (PrgChgResOnClose[timerBtch])
							{
								if PrgMonPID.delete(timerfTemp)
								{
									if (temp := RevertResLastPrgProc(maxBatchPrgs, PrgMonPID, timerfTemp))
									{
										if (DefResNoMatchRes(1))
										{
										; restore from defaults
										CopyToFromRes(targMonitorNum)
										ChangeResolution(temp)
										sleep, 300
										WinMover(PrgLnchOpt.Hwnd(), "d r", PrgLnchOpt.Width() * 61/80, PrgLnchOpt.Height() * 13/10)
										}
									}
								}
								else
								MsgBox, 8192, PID Check, % "PID for " . PrgChoiceNames[timerBtch] . " never existed!"
							}
						}
					}
				}

				if(!timerBtch)
				{
				batchActive := 0
				CleanupPID(currBatchNo, lastMonitorUsedInBatch, PrgMonToRn, presetNoTest, PrgListPID%btchPrgPresetSel%, PrgStyle, PrgBordless, PrgLnchHide, PrgPID, PrgChgResOnClose, selPrgChoice, waitBreak, 1)
				return
				}
			}
		}
	}



SetTitleMatchMode, 3
If (WinWaiter(presetNoTest, PrgLnch.Title, PrgLnchOpt.Title, waitBreak))
{
	; check the PID of app. If it matches a Prg, use the index to retrieve the resolution

	timerfTemp := FindMatchingPID(lnchStat, currBatchNo, PrgListPID%btchPrgPresetSel%, PrgPID)

	if (timerfTemp)
	{
	(lnchStat < 0)? prgSwitchIndex := 0: prgSwitchIndex := PrgBatchIni%btchPrgPresetSel%[timerfTemp]

		if ((prgSwitchIndex)? PrgChgResOnSwitch[prgSwitchIndex]: PrgChgResOnSwitch[selPrgChoice])
		{
		StoreFetchPrgRes(1, (lnchStat < 0)? selPrgChoice: prgSwitchIndex, PrgLnkInf, targMonitorNum)
		targMonitorNum := (lnchStat < 0)? PrgMonToRn[selPrgChoice]: PrgMonToRn[prgSwitchIndex]
			if (DefResNoMatchRes(1) && (PrgLnch.Monitor == targMonitorNum))
			{
			ChangeResolution(targMonitorNum)
			sleep, 300
			}
		}
	}
	SetTimer, WatchSwitchOut, Off
	SetTimer, WatchSwitchBack, -%timWatchSwitch%

}
else
SetTimer, WatchSwitchOut, -%timWatchSwitch%

return

WinWaiter(presetNoTest, PrgLnchText := "", PrgLnchOptText := "", waitBreak := 0, timeOut:= 0)
{
; https://autohotkey.com/boards/viewtopic.php?f=5&t=29822
t1 := 0
winText := (presetNoTest)? PrgLnchText: PrgLnchOptText

	(timeOut) && t1 := A_TickCount
	; if timout is 0, t1 is not initialised

	Loop
	{
	Sleep 20

	} Until (!WinActive(winText) && state := "inactive")

	|| (waitBreak && state := "break")

	|| (t1 && A_TickCount-t1 >= timeOut && state := "timeout") ; t1 nothing
	return state
}

RevertResLastPrgProc(maxBatchPrgs, PrgMonPID, btchPIDUserClose := 0, Init := 0)
{
Static PrgMonPIDBak := {}
; PrgMonPID has PID keys for ALL batch presets with active Prgs.
; This function only handles one Prg at a time:
; If two Prgs happen to terminate simultaneously,
; the second Prg either gets processed in the calling
; loop, or waits for the next timer call.

retVal := 0

	if (Init)
	{
		; Deep copy
		for PID, monitor in PrgMonPID
		PrgMonPIDBak[PID] := PrgMonPID[PID]
	}
	else
	{
		if (PrgMonPIDBak.Count() != PrgMonPID.Count())
		{
			if (btchPIDUserClose)
			{
			retVal := PrgMonPIDBak[btchPIDUserClose]

				if (retVal && (retVal != PrgMonPID[btchPIDUserClose]))
				{
				PrgMonPIDBak.Delete(PID)
				btchPIDUserClose := 0
				}
			}
			else
			{
				; From the Lnch button where we are assured Thread, Notimers
				; makes only the cancelled prg the one that is handled here.
				for PID, monitor in PrgMonPIDBak
				{
				retVal := PrgMonPIDBak[PID]
					if (retVal && (retVal != PrgMonPID[PID]))
					{
					PrgMonPIDBak.Delete(PID)
					break
					}
				}
				; retVal == 0: an impossibility
			}
		}
	}
return retVal
}

CleanupPID(currBatchNo, lastMonitorUsedInBatch, PrgMonToRn, presetNoTest, ByRef PrgListPIDbtchPrgPresetSel, ByRef PrgStyle, PrgBordless, PrgLnchHide, ByRef PrgPID, PrgChgResOnClose, selPrgChoice, waitBreak, batchWasActive := 0)
{
testPrgTerm := 0, temp := 0, strRetVal := "", PrgStyle := 0, dx := 0, dy:= 0
; The outcome of this utility depends on whether user is in Batch or Config screen which mixes things up a bit.


	if (strRetVal := WorkingDirectory(A_ScriptDir, 1))
	MsgBox, 8192, Cleanup PID, % strRetVal
if (presetNoTest) ; Batch screen
{
	if (PrgPID)
	{
	SplashImage, Hide, A B,,,LnchSplash

		if (PrgMonToRn[selPrgChoice] == lastMonitorUsedInBatch)
		{
		PrgAlreadyLaunched(lastMonitorUsedInBatch)
		WinMover(PrgLnch.Hwnd(), "d r", PrgLnchOpt.Width() * 61/80, PrgLnchOpt.Height() * 13/10)
		}

	}

	if (batchWasActive)
	{
		Loop % currBatchNo
		{
		temp := PrgListPIDbtchPrgPresetSel[A_Index]
			if (temp)
			{
				if temp is digit
				MsgBox, 8192, PrgLnch PID Error, PID now cleared!
			PrgListPIDbtchPrgPresetSel[A_Index] := 0
			}
		}

	GuiControl, PrgLnch:, RunBatchPrg, &Run Batch

		if (PrgLnchHide[selPrgChoice])
		Gui, PrgLnch: Show,, % PrgLnch.Title

	DopowerPlan("Default")

	SetTimer, WatchSwitchBack, Delete
	SetTimer, WatchSwitchOut, Delete
	}
	else
	testPrgTerm := 1
}
else ;Config screen
{
	if (batchWasActive) ;Then the Batch has completed
	{
		Loop % currBatchNo
		{
		temp := PrgListPIDbtchPrgPresetSel[A_Index]
			if (temp)
			{
				if temp is digit
				MsgBox, 8192, PID Error, A PID wasn't cleared!
			}
		}

		if (PrgPID)
		{
			if (PrgMonToRn[selPrgChoice] == lastMonitorUsedInBatch)
			PrgAlreadyLaunched(lastMonitorUsedInBatch)
		}
	}
	else
	testPrgTerm := 1


	if (testPrgTerm)
	{
	HideShowTestRunCtrls(1)
	GuiControl, PrgLnchOpt:, Bordless, % PrgBordless[selPrgChoice]

		;  used to be extra condition: (PrgMonToRn[selPrgChoice] == PrgLnch.Monitor)
		if (PrgChgResOnClose[selPrgChoice] && DefResNoMatchRes(1))
		{
		; restore from old
		CopyToFromRes(targMonitorNum, 0, -1)
		ChangeResolution(PrgLnch.Monitor)
		sleep, 300
		}

		if (!presetNoTest)
		{
		SetTimer, WatchSwitchBack, Delete
		SetTimer, WatchSwitchOut, Delete
		}
	}


; No problem if a batch preset completes at exactly the same time.
WinMover(PrgLnchOpt.Hwnd(), "d r")

	if (PrgLnchHide[selPrgChoice])
	Gui, PrgLnchOpt: Show,, % PrgLnchOpt.Title

}

	if (!waitBreak && presetNoTest == 1)
	{
	SysGet, md, MonitorWorkArea, % PrgLnch.Monitor
	dx := Round(mdleft + (mdRight- mdleft)/2)
	dy := Round(mdTop + (mdBottom - mdTop)/2)
	DllCall("SetCursorPos", "UInt", dx, "UInt", dy)
	}

}

PrgAlreadyLaunched(targMonitorNum)
{
retVal := 0
IniRead, retVal, % PrgLnch.SelIniChoicePath, General, PrgAlreadyLaunchedMsg
sleep, 120


	if (!retVal)
	{
	retVal := TaskDialog("Screen Resolution for Test Run Prg", "Batch has completed and, in the same monitor,`na Prg has been launched with a click on Test Run", , "The monitor resolution set for the Test Prg might not be the same as the current resolution.`nTest Prgs are generally recommended to run in Temporary mode so the default resolution is automatically restored on quitting PrgLnch`nDo you wish to change the resolution of the monitor the Test Prg was launched from?", , "Change resolution", "Do not change resolution")
		if (retVal < 0)
		{
		retVal := -retVal
		IniWrite, %retVal%, % PrgLnch.SelIniChoicePath, General, PrgAlreadyLaunchedMsg
		}
	}

	if (retVal == 1)
	{
	CopyToFromRes(targMonitorNum, 0, 1)

		if (DefResNoMatchRes(1))
		{
		ChangeResolution(targMonitorNum)
		sleep, 300
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
SetTaskBarIcon()
{
;https://autohotkey.com/board/topic/122770-how-to-change-the-icon-on-a-taskbar-button/
WM_SETICON:=0x80
IMAGE_ICON := 1, LR_LOADFROMFILE := 0x10, LR_DEFAULTSIZE := 0x40
IconFile := A_ScriptDir . "\PrgLnch.ico"
hIcon := DllCall("LoadImage", "uint", 0, "str", IconFile, "uint", IMAGE_ICON, "int", 0, "int", 0, "uint", LR_LOADFROMFILE | LR_DEFAULTSIZE)

	if (!hIcon && A_IsCompiled)
	{
	MsgBox, 8192, Icon File, Icon file missing or invalid!
	return
	}
;hIcon := Format("0x{:x}", hIcon + 0) : ; hIcon does not want hex formatting for ahk_id...
SendMessage, %WM_SETICON%, 0, %hIcon%,, % "ahk_id " . PrgLnchOpt.Hwnd()
}

CheckPrgPaths(selPrgChoice, IniFileShortctSep, ByRef PrgChoicePaths, ByRef PrgLnkInf, ByRef PrgResolveShortcut, atInit := 0)
{
strRetVal := "", strTemp := PrgChoicePaths[selPrgChoice], strTemp2 := PrgLnkInf[selPrgChoice], IsaPrgLnk := 0, lnkPrg := 0



	if (strTemp2 == "*")
	strRetVal := WorkingDirectory(strTemp)
	else
	{
	lnkPrg := ExtractPrgPath(selPrgChoice, PrgChoicePaths, 0, PrgLnkInf, 0, IniFileShortctSep, IsaPrgLnk)

		Switch, strTemp2
		{
		Case "|":
		{
			if ((!atInit) && strRetVal := WorkingDirectory(lnkPrg))
			strRetVal :=  "Invalid directory link: " . strRetVal
		}
		Case "<>":
		{
			if ((!atInit) && strRetVal := WorkingDirectory(lnkPrg))
			strRetVal :=  "Invalid shortcut: " . strRetVal
		}
		Case "?":
		; symbolic lnk
		Default:
		{
	; The ini may be corrupted when IniFileShortctSep is removed
			If (!FileExist(lnkPrg))
			{
				if (InStr(strTemp2, "\", false, StrLen(strTemp2)) || !WorkingDirectory(ExtractPrgPath(selPrgChoice, PrgChoicePaths, 0, PrgLnkInf, 1, IniFileShortctSep, IsaPrgLnk)))
				{
				retVal := TaskDialog("Link to Prg", "The following link is found to be invalid:`n" . lnkPrg, , "The link is reported by PrgLnch as invalid.`nThe target of the link can still be determined, so PrgLnch can use that`nfor the shortcut, instead. Otherwise, choose the option of " . """" . "Do nothing" . """" . "`nif there is a possibility the lnk file can be manually recovered, later.", "", "Attempt to use the link's target", "Do nothing")
					if (retVal == 1)
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
				strRetVal := % strTemp2 "`nwas supposed to have a backslash terminator!"
			}
		}
		}
	}

if (strRetVal)
CreateToolTip("Checking Prg Paths:`n" . strRetVal)


return strRetVal
}
FindMatchingPID(lnchStat, currBatchNo, PrgListPIDbtchPrgPresetSel, PrgPID)
{
	temp := 0

	WinGet, temp, PID, A

	if (lnchStat < 0)
	{
		if (temp == PrgPID)
		return -1
	}
	else
	{
		loop % currBatchNo
		{
			if (temp == PrgListPIDbtchPrgPresetSel[A_Index])
			return A_Index
		}
	}
return 0
}

KillPrg(poorPID)
{
strTemp := "" , strRetVal := ""
Process, Close, %poorPID%
strRetVal := ErrorLevel
sleep, 200

	if (!strRetVal)
	{
		; When in program files, and running without elevation,
		; full paths are required for file processing in any case.
		if (strRetVal := WorkingDirectory(A_ScriptDir, 1))
		MsgBox, 8192, Cancel Prg, % strRetVal

		if (FileExist(A_ScriptDir  . "taskkillPrg.bat"))
		{
		FileDelete, % A_ScriptDir  . "\taskkillPrg.bat"
		sleep, 200
		}

	strTemp := A_ScriptDir "\taskkillPrg.bat"
	FileAppend,
	(
	taskkill /pid %poorPID% /f /t
	Exit
	), %strTemp%

	sleep, 200
	Run, *RunAs "%strTemp%",, Hide UseErrorLevel
	sleep, 200
	FileDelete, % A_ScriptDir  . "\taskkillPrg.bat"
	}
}

GetProcFromPath(strTemp, lnkInfo := 0)
{
if (lnkInfo)
{
strRetVal := SubStr(strTemp, InStr(strTemp, "\",, -1) + 1)
strRetVal := SubStr(strRetVal, 1, StrLen(strRetVal) -3) . "exe" ; assume exe
}
else
strRetVal := SubStr(strTemp, InStr(strTemp, "\",, -1) + 1)

	if (!strRetVal)
	MsgBox, 8192, Prg Directory,Invalid path with %strTemp%!`nUnable to continue process check.

return strRetVal
}

ChkExistingProcess(PrgLnkInf, presetNoTest, selPrgChoice, currBatchNo, PrgBatchIni, PrgChoicePaths, IniFileShortctSep, btchRun := 0, multiInst := 0)
{
strComputer := ".", dupList := "", temp := 0, strTemp := "", strTemp2 := "", IsaPrgLnk := 0
wbemFlagForwardOnly := 0x20, wbemFlagReturnImmediately := 0x10
static Flags := wbemFlagForwardOnly & wbemFlagReturnImmediately


if (presetNoTest && btchRun)
{
loop % currBatchNo
	{
	temp := PrgBatchIni[A_Index]
	strTemp := ExtractPrgPath(temp, PrgChoicePaths, 0, PrgLnkInf, 0, IniFileShortctSep, IsaPrgLnk)

	temp := InStr(PrgChoicePaths, ".lnk", false, strLen(PrgChoicePaths) - 4)
	if (InStr(strTemp, "PrgLnch.exe") || InStr(strTemp, "BadPath"))
	return "PrgLnch"
    if (!(strTemp := GetProcFromPath(strTemp, temp)))
	return "BadPath"
	strTemp2 := ""
	; Does not work for lnk files. "Select *" means full paths and names and commandlines!
	; ExecutablePath maybe null if insufficent permission
		for process in ComObjGet("winmgmts:{impersonationLevel=impersonate}!\\" . strComputer . "\root\cimv2").ExecQuery("Select Name from Win32_Process where ExecutablePath is not null",,Flags)
		{
			if (strTemp == process.Name) ; process.ExecutablePath was also possible (Select Name, ExecutablePath from Win32_Process)
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

	strTemp := ExtractPrgPath(temp, PrgChoicePaths, 0, PrgLnkInf, 0, IniFileShortctSep, IsaPrgLnk)

	if (InStr(strTemp, "PrgLnch.exe") || InStr(strTemp, "BadPath"))
	return "PrgLnch"

    if (!(strTemp := GetProcFromPath(strTemp, strTemp2)))
	return "BadPath"
	strTemp2 := ""
	for process in ComObjGet("winmgmts:{impersonationLevel=impersonate}!\\" . strComputer . "\root\cimv2").ExecQuery("Select Name from Win32_Process where ExecutablePath is not null,,Flags")
	{
		if (strTemp == process.Name)
		{
		duplist .= strTemp2 . strTemp
			if (multiInst)
			strTemp2 := "|" 
			else
			Break
		}
	}
}

return duplist
}

InitBatchActivePrgs(maxBatchPrgs, PrgBatchIniA_Index, ByRef PrgListPID)
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

ProcessActivePrgsAtStart(PrgNo, PrgLnkInf, PrgChoicePaths, IniFileShortctSep, ByRef PrgPIDMast, oldSelIniChoicePath := "")
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

; No "WarnAlreadyRunning" as this is default when switching LnchPads
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
					if (strTemp == strTemp2 && !PrgPIDMastTmp[A_Index])
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
return retVal
}
else
{

	IniRead, WarnAlreadyRunning, % PrgLnch.SelIniChoicePath, General, WarnAlreadyRunning
		if (WarnAlreadyRunning == 2)
		return retVal

	Loop % PrgNo
	{
		if (PrgChoicePaths[A_Index] && PrgPIDMast[A_Index])
		{
			if (strRetVal := ChkExistingProcess(PrgLnkInf, 0, A_Index, 0, 0, PrgChoicePaths, IniFileShortctSep, 0, 1))
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
	strRetVal := % (multipleInstance)? "`nIf multiple instances of Prg were detected during the process of automatically`nupdating the Batch list, PrgLnch will choose just one of the available instances.`nThat choice is likely to be the instance most recently launched,`nbut there is no guarantee.`n": ""
	retVal := TaskDialog("Running Prgs", "The Prgs in the list below have already started:`n" . strTemp, , "Some processes may not be retrieved if PrgLnch`nis not currently run as Admin`, if it ever was before.`n" . strRetVal . "`nAs mentioned in the Help file`, non-default Power Plans do not activate for`nresumed Batch Presets`, manually re-select them from the list to make it so.", , "Update Prg Batch Status (Recommended)", "Do not update Prg Batch Status")
		if (retVal < 0)
		{
		retVal := -retVal
		IniWrite, %retVal%, % PrgLnch.SelIniChoicePath, General, WarnAlreadyRunning
		}
		if (retVal == 2)
		return 0
	}
}


Loop % PrgNo
{
foundpos := 0
	if (ProcNames[A_Index])
	{
	Process, Exist, % ProcNames[A_Index]

	foundpos := ErrorLevel

		; PrgPIDMast[]A_Index] 1 if batch as initialised by InitBatchActivePrgs
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



return retVal
}

GetPrgLnchMonNum(iDevNumArray, ByRef primaryMon, fromMouse := 0)
{
iDevNumb := 0, monitorHandle := 0,  MONITOR_DEFAULTTONULL := 0, strTemp := ""

VarSetCapacity(monitorInfo, 40)
NumPut(40, monitorInfo)


hWnd := PrgLnchOpt.Hwnd()

	If (!hWnd)
	{
	MsgBox, 8192, PrgLnch Handle, % "Cannot get handle of Script/Executable! Error: " A_LastError
	VarSetCapacity(monitorInfo, 0)
	return -1
	}
	;winHandle := WinExist("A") ; LastWindow: The PrgLnch Window if clicked on

	loop % PrgLnchOpt.dispMonNamesNo
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
			if ((msLeft == mtLeft) and (msTop == mtTop)
				and (msRight == mtRight) and (msBottom == mtBottom))
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
		MsgBox, 8192, Monitor Error, %strTemp% mouse cursor!
		else
		MsgBox, 8192, Monitor Error, %strTemp% target window!
	return 1 ;hopefully this monitor is the one!
	}

}
GetPrgLnkVal(strTemp, IniFileShortctSep, ProcessLnk := 0, resolveNow := 0)
{
;Gets either working directory or resolved/unresolved shortcut path
strRetVal := "", strTemp2 := "", IsALnk := InStr(strTemp, IniFileShortctSep), initLnk := (InStr(strTemp, ".lnk", False, StrLen(strTemp) - 4))
	; ATM PrgLnch does not modify the fields of the Wscript shortcut component in any way.
	;http://superuser.com/questions/392061/how-to-make-a-shortcut-from-cmd

	; PrgLnkInf will contain:
	; First pass (ProcessLnk 0)
	; Working directory of a valid lnk
	; <>	invalid lnk (error or non-existent)
	; * Regular prg (Hard link) IsaPrgLnk 0
	;  | directory link (IsaPrgLnk -1)
	; IniFileShortctSep : Lnk for which FileGetShortcut suceeds but returns a blank working directory
	; IniFileShortctSep also applies ro symbolic lnks, (IsaPrgLnk -2) for now
	; Second Pass (ProcessLnk 1)
	; Valid working directory of Prg when IsaPrgLnk 0
	; Resolved Target of hard linked shortcut
	; <>	invalid lnk (error or non-existent)
	; * invalid working directory (inaccessible: rare)
	;  | directory link (IsaPrgLnk -1)
	; IniFileShortctSep:  symbolic lnks, (IsaPrgLnk -2) for now

	; Second Pass
	if (ProcessLnk)
	{

		if (IsALnk)
		strTemp2 := SubStr(strTemp, 1, IsALnk - 1)
		else
		strTemp2 := strTemp

		if (resolveNow) ; never gets here if symbolic or dir lnk, or initLnk
		{
		FileGetShortcut, %strTemp2%, strRetVal

			if (ErrorLevel)
			{
				if (IsALnk)
				strRetVal := "<>"
				else
				strRetVal := "*" ; (Add new Prg) IsALnk is not set yet
			}
			else
			{
			strTemp2 := SubStr(strTemp, IsALnk + 1)
				if (strTemp2 != strRetVal)
				;CreateToolTip("Shortcut target`n" . """" . strRetVal . """" . "`nhas been updated")
				MsgBox, 8192, Updating Shortcut, % "Shortcut target`n" strRetVal "`nhas been updated"
			;FileGetShortcut may not error if not lnk
			}
		}
		else
		{
		FileGetShortcut, %strTemp2%, , strRetVal
			if (strRetVal) ; PrgLnkInf receives the working dir of resolved lnk: Review the terminating backslash!
			strRetVal := ParseEnvVars(strRetVal) . "\"
			else ; else; Regular Prgs get here. Note use of Errorlevel for the symbolic or dir lnks
			{
				if (ErrorLevel)
				{
					if (IsALnk || initLnk)
					strRetVal := "<>"
					else
					strRetVal := "*"
				}
				else
				{
				FileGetShortcut, %strTemp2%, strRetVal
					if (strRetVal)
					strRetVal := "|" ; Directory: This may want ParseEnvVars
					else ; Problematic : All symbolic lnks go here
					strRetVal := IniFileShortctSep
				}

			}
		}
	}
	else
	{
	; First pass: Read in New
	; get workdir: This blanks all if not lnk file  (or a shortcut  to an "special" target tlke recycle bin, so expect return of ""
			;if (IsALnk == strLen(strTemp)) ; Not relevant with new shortcut
			;strTemp := SubStr(strTemp, 1, IsALnk - 1)

	FileGetShortcut, %strTemp%, , strRetVal
		if (ErrorLevel)
		{
			; IsaLnk is used on open of a new file through the dialog. In that case, "*" is always returned. This happens with associations as werll
			if (IsALnk)
			strRetVal := "<>"
			else
			strRetVal := "*"
		}
		else
		{
			if (strRetVal)
			{
			strRetVal := ParseEnvVars(strRetVal)
			strRetVal .= "\"
			}
			else ; lnk might be a directory shortcut/symbolic lnk
			{
			FileGetShortcut, %strTemp%, strRetVal

				if (strRetVal)
				strRetVal := "|"
				else ; Problematic : All symbolic lnks go here
				strRetVal := IniFileShortctSep
			}
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
		if (strTemp2 && !InStr(strTemp2, "\") == 1)
		strTemp2 := "\" . strTemp2

	EnvGet, userProfile, USERPROFILE
	strTemp := userProfile . strTemp2
	}
	else
	{
	;absolutely refuse to parse HOMEDRIVE and HOMEPATH separately: Homepath = \Users\{username}
	strTemp2 := StrReplace(strTemp, "`%HOMEDRIVE`%`%HOMEPATH`%", , foundPos)
		if (foundPos)
		{
			if (strTemp2 && !InStr(strTemp2, "\") == 1)
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

			if (strTemp2 && !InStr(strTemp2, "\") == 1)
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

			if (strTemp2 && !InStr(strTemp2, "\") == 1)
			strTemp2 := "\" . strTemp2

		EnvGet, homeShare, HOMESHARE
		strTemp := homeShare . strTemp2
	
		}
		else
		{
		strTemp2 := StrReplace(strTemp, "`%SYSTEMROOT`%", , foundPos)
			if foundpos
			{
				if (strTemp2 && !InStr(strTemp2, "\") == 1)
				strTemp2 := "\" . strTemp2
			EnvGet, systemroot, SYSTEMROOT
			strTemp := systemroot . strTemp2
			}
		}
		}
		}

	}

return strTemp
}

WorkingDirectory(strTemp, SetNow := 0)
{
retVal := 0


	;if (strTemp != A_ScriptDir && !InStr(strTemp, "\", false,  StrLen(strTemp)))
	if (InStr(strTemp, "\", false,  StrLen(strTemp)))
	strTemp2 := SubStr(strTemp, 1, InStr(strTemp, "\", false, 0) -1)
	else
	{
	FileGetAttrib, strTemp2, %strTemp%
		if (InStr(strTemp2, "D"))
		strTemp2 := strTemp
		else
		SplitPath strTemp, , strTemp2
	}

SetWorkingDir %strTemp2%
retVal := ErrorLevel


	if (!SetNow) ; just testing: never called with A_ScriptDir
	{
	sleep 50
		if (retval)
		{
		SetWorkingDir %A_ScriptDir% ; Caution: Working Dir can be altered by other processes
		retVal := ErrorLevel
		}
	}
	; 0 success
	if (retVal)
	return "An error of " retVal " occurred while reading the path for:`n""" strTemp2 . """"
	else
	return ""
}
/*
===============================================================================
Function:   wp_IsResizable
    Determine if we should attempt to resize the last found window.
returns:
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

BordlessProc(targMonitorNum, ByRef PrgMinMaxVar, ByRef PrgStyle, PrgBordless, selPrgChoice, PrgPID, queryOnly := 0, dxVal := 0, dyVal:= 0)
{
Static PrgPos := [0, 0, 0, 0], monitorPID := targMonitorNum, dx := 0, dy := 0
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
		return 1
		else
		GuiControl, PrgLnchOpt: Disable, Bordless
	return 0
	}



	if (PrgStyleTmp) ;check flags not Borderless
	{
		if (dxVal)
		dx := dxVal
		if (dyVal)
		dy := dyVal
	
	; Store existing style
	WinGet, IsMaxed, MinMax, ahk_pid%PrgPID%
	; Get/store whether the window is maximized
		if (PrgMinMaxVar := IsMaxed == 1 ? true : false)
		WinRestore, ahk_pid%PrgPID%
	;move window to max perims
	WinGetPos, x, y, w, h, ahk_pid%PrgPID%

	PrgPos[1] := x, PrgPos[2] := y, PrgPos[3] := w, PrgPos[4] := h
	; Remove borders
	winSet, Style, % -PrgStyleTmp, ahk_pid%PrgPID%
	sleep 30
	WinMove, ahk_pid%PrgPID%, , %dx%, %dy%, % PrgLnchOpt.scrWidth, % PrgLnchOpt.scrHeight
	}
	else
	{
	; If borderless, reapply borders
	WinSet, Style, % "+" PrgStyle, ahk_pid%PrgPID%
	WinGetPos, x, y, w, h, ahk_pid%PrgPID%
		if (!PrgPos[3] || monitorPID != targMonitorNum)
		PrgPos[1] := x, PrgPos[2] := y, PrgPos[3] := w, PrgPos[4] := h
	WinMove, ahk_pid%PrgPID%,, % PrgPos[1], % PrgPos[2], % PrgPos[3], % PrgPos[4]
	; return to original position & maximize if required
		if (PrgMinMaxVar)
		WinMaximize, ahk_pid%PrgPID%
	monitorPID := targMonitorNum
	}
return 0
}








































































































;Monitor routines
GetDisplayData(targMonitorNum := 1, ByRef iDevNumArray := 0, ByRef scrWidth := 0, ByRef scrHeight := 0, ByRef scrFreq := 0, ByRef scrInterlace := 0, ByRef scrDPI := 0, iMode := -2, iChange := 0)
{
Static OffsetDWORD := 4

; devFlags
Static DISPLAY_DEVICE_ATTACHED_TO_DESKTOP := 0x00000001, DISPLAY_DEVICE_PRIMARY_DEVICE:= 0x00000004, DISPLAY_DEVICE_MIRRORING_DRIVER := 0x00000008, DISPLAY_DEVICE_VGA_COMPATIBLE := 0x00000010

	if (iMode == -3) ; program load
	{
	iDevNumb := 0, ftemp := 0, temp := 0, devFlags := 0, devKey := 0
	; devKey:	Path to the device's registry key relative to HKEY_LOCAL_MACHINE. (not required)
	iLocDevNumArray := [0, 0, 0, 0, 0, 0, 0, 0, 0]

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



		loop % PrgLnchOpt.dispMonNamesNo
		{

		cbDISPDEV := OffsetDWORD + OffsetDWORD + offsetWORDStr + 3 * OffsetLongStr
		VarSetCapacity(DISPLAY_DEVICE, cbDISPDEV, 0)
		NumPut(cbDISPDEV, DISPLAY_DEVICE, 0) ; initialising cb (byte counts) or size member

			if (!DllCall("EnumDisplayDevices" . (A_IsUnicode? "W": "A"), "PTR", 0, "UInt", iDevNumb, "PTR", &DISPLAY_DEVICE, "UInt", 0))
			{
			PrgLnchOpt.dispMonNamesNo := iDevNumb
			break
			}



		devFlags := NumGet(DISPLAY_DEVICE, OffsetDWORD + offsetWORDStr + OffsetLongStr, "UInt")
		devKey := StrGet(&DISPLAY_DEVICE + OffsetDWORD + OffsetDWORD + offsetWORDStr + OffsetLongStr + OffsetLongStr, OffsetLongStr)

		if (devFlags & DISPLAY_DEVICE_MIRRORING_DRIVER)
		temp += 1
		else
		{

		iDevNumb := iDevNumb + 1

			;How do we differentiate between ....
			if (devFlags & DISPLAY_DEVICE_PRIMARY_DEVICE)
			{
				if (devFlags & DISPLAY_DEVICE_ATTACHED_TO_DESKTOP)
				iLocDevNumArray[iDevNumb] := iDevNumb + 110
				else
				{
				iLocDevNumArray[iDevNumb] := iDevNumb + 100 ; Impossible
				MsgBox, 8208, Monitors, The primary monitor is not attached to the desktop somehow!
				}
			}
			else
			{
				if (devFlags & DISPLAY_DEVICE_ATTACHED_TO_DESKTOP)
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
					MsgBox, 8192, Monitors, A configurational change in the monitor setup is detected.`nThis may affect how some Prgs run.
					ftemp := 1
					}
				}
			}
			else
			iDevNumArray[iDevNumb] := iLocDevNumArray[iDevNumb]

			monName := StrGet(&DISPLAY_DEVICE + OffsetDWORD, offsetWORDStr)

			PrglnchOpt.SetDispMonNamesVal(iDevNumb, monName)
			; adapter name	
			PrglnchOpt.SetDispAdapterNamesVal(StrGet(&DISPLAY_DEVICE + OffsetDWORD + offsetWORDStr, offsetWORDStr))

			if (!monName)
			{
			; happens on XP
			PrgLnchOpt.dispMonNamesNo := iDevNumb
			MsgBox, 8192, Monitors, " GetDisplay breaks at: dispMonNamesNo: " PrgLnchOpt.dispMonNamesNo
			break
			}

		}
		VarSetCapacity(DISPLAY_DEVICE, 0)
		}
	
	PrgLnchOpt.dispMonNamesNo -= temp



	fTemp := 0
		loop % PrgLnchOpt.dispMonNamesNo
		{
			if (iDevNumArray[A_Index] > 9)
			fTemp += 1
			else
			Continue
		}

	PrgLnchOpt.activeDispMonNamesNo := fTemp

	}
	else ; iMode is either an enumeration counter {0 ... PrgLnchOpt.dispMonNamesNo} or -1 or -2
	{

	retVal := 0
		;devMode Struct contains dmDeviceName[CCHDEVICENAME] and dmFormName[CCHFORMNAME]
		; where the CCH indexes == 32, (names get truncated when > 32 chars). This explains OffsetdevMode
		;devMode also has 5 words, 5 short, 17 Dwords, 2 longs (POINTL:="x,y")... 5 * 2 + 5 * 2 + 16 * 4  + 2 * 4 = 92 structure has TWO Unions
		if (A_IsUnicode)
		{
		OffsetdevMode := 2 * 32
		offsetWORDStr := 64
		}
		else
		{
		OffsetdevMode := 0
		offsetWORDStr := 32
		}
		;(A_PtrSize == 8)? 64bit := 1 : 64bit := 0 ; not required for DM

	cbdevMode := 92 + 32 + 32 + OffsetdevMode
	VarSetCapacity(Device_Mode, cbdevMode, 0)
	NumPut(cbdevMode, Device_Mode, OffsetDWORD + offsetWORDStr, Ushort) ; initialise cbsize member

	; Point of iChange is when initialising primary monitor, a different target monitor must not be confused with primary monitor.
	; The fn actually has a 4th flags parm- EDS_RAWMODE might be worth another look.

	if (iChange) ; DISPLAY_DEVICE.DeviceName
	retVal := DllCall("EnumDisplaySettingsEx" . (A_IsUnicode? "W": "A"), "PTR", PrglnchOpt.GetDispMonNamesVal(targMonitorNum), "UInt", iMode, "PTR", &Device_Mode, "UInt", 0)
	else ; PrgLnch display device (0 will do for the fn)
	retVal := DllCall("EnumDisplaySettingsEx" . (A_IsUnicode? "W": "A"), "PTR", 0, "UInt", iMode, "PTR", &Device_Mode, "UInt", 0)

	;NumGet(Device_Mode, 64bit*32 + 4 +OffsetdevMode/2,UShort) ;dmSize, (before the 2nd Tchar)
	;NumGet(Device_Mode, 64bit*32 + 6 +OffsetdevMode/2,UShort) ;dmDriverExtra
	;NumGet(Device_Mode, 64bit*32 + 8 + OffsetdevMode/2,UInt) ; dmFields, see below: location of extra monitors
	;scrdmPostionX:=NumGet(Device_Mode, 64bit*32 + 12 +OffsetdevMode/2,UInt) ;Union POINTL
	;scrdmPostionY:=NumGet(Device_Mode, 64bit*32 + 12 +OffsetdevMode/2,UInt) ;

	;The following settings are applicable to other monitors
	scrDPI := NumGet(Device_Mode, 104 + OffsetdevMode,"UInt") ; colour depth (pel is pixel) or A_ScreenDPI
	scrWidth := NumGet(Device_Mode, 108 + OffsetdevMode,"UInt") ; dmPelsWidth or A_ScreenWidth
	scrHeight := NumGet(Device_Mode, 112 + OffsetdevMode,"UInt") ; dmPelsHeight or A_ScreenHeight
	scrInterlace := NumGet(Device_Mode, 116 + OffsetdevMode,"UInt") ; DM_GRAYSCALE, DM_INTERLACED (non interlaced if not specified)
	scrFreq := NumGet(Device_Mode, 120 + OffsetdevMode,"UInt") ; Do not change 
	;https://support.microsoft.com/en-au/kb/2006076
		if (PrgLnchOpt.scrFreq == 59)
		PrgLnchOpt.scrFreq := PrgLnchOpt.scrFreq + 1

	;Do not touch 148 dmPanningWidth or 152 dmPanningHeight

	VarSetCapacity(Device_Mode, 0)
	}
	return retVal
}


ChangeResolution(targMonitorNum := 1)
{
Device_Mode := 0, monName := 0, devFlags := 0, CDSopt := 0, strRetVal := "", DM_Position := 0, mdLeft := 0, mdTop := 0, cbSize := 0, OffsetWORD := 0, OffsetDWORD := 4
;Change display flags
Static CDS_TEST = 0x00000002, CDS_RESET = 0x40000000, CDS_UPDATEREGISTRY = 0x00000001, CDS_FULLSCREEN = 0x00000004
 ; These for GetDisplayData
Static ENUM_CURRENT_SETTINGS := -1, ENUM_REGISTRY_SETTINGS := -2

	if (PrgLnchOpt.TestMode)
	CDSopt := CDS_TEST
	if (PrgLnchOpt.Fmode)
	CDSopt := CDS_RESET
	if (PrgLnchOpt.DynamicMode)
	CDSopt := CDS_UPDATEREGISTRY
	if (PrgLnchOpt.TmpMode)
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
	VarSetCapacity(Device_Mode, cbSize, 0)
	NumPut(cbSize, Device_Mode, OffsetDWORD + 32, "Ushort")
	}

	GetDisplayData(targMonitorNum, , , , , scrInterlace, scrDPI ,(PrgLnch.regoVar)? ENUM_REGISTRY_SETTINGS: ENUM_CURRENT_SETTINGS, 1)


	;The following values should never change, but just in case!
	;OffsetWORD of dmPosition = 44
	;OffsetWORD of dmDisplayOrientation = 52
	;OffsetWORD of dmDisplayFixedOutput = 56

	NumPut(scrDPI, Device_Mode, 104 + OffsetWORD, "UInt")
	NumPut(scrInterlace, Device_Mode, 116 + OffsetWORD, "UInt")
	NumPut(PrgLnchOpt.scrWidth, Device_Mode, 108 + OffsetWORD, "UInt") ; A_ScreenWidth
	NumPut(PrgLnchOpt.scrHeight, Device_Mode, 112 + OffsetWORD, "UInt") ; A_ScreenHeight
	NumPut(PrgLnchOpt.scrFreq, Device_Mode, 120 + OffsetWORD, "UInt") ;


	NumPut(0, Device_Mode, 38 + OffsetWORD/2, "Ushort") ;dmDriverExtra



	if (targMonitorNum == PrgLnch.Monitor)
	devFlags := 0x00080000 | 0x00100000
	else
	{
	devFlags := 0x00000020		; DM_POSITION
				| 0x00080000	; DM_PELSWIDTH
				| 0x00100000	; DM_PELSHEIGHT
	;dmFields, a POINTL:="x,y" structure is a union of structs
	VarSetCapacity(DM_Position, 8, 0)
	Numput(mdLeft + 1, DM_Position, 0, "UInt")
	Numput(mdTop + 1, DM_Position, 4, "UInt")

	Numput(&DM_Position, Device_Mode, 44 + OffsetWORD/2)
	}

	NumPut(devFlags, Device_Mode, 40 + OffsetWORD/2, "UInt")
	;OffsetWORD of dmDisplayOrientation = 52
	;OffsetWORD of dmDisplayFixedOutput = 56


	monName := PrglnchOpt.GetDispMonNamesVal(targMonitorNum)

	;Ref SetDisplayConfig. The usual approach is to call with CD_TEST and if no error use CDS_UPDATEREGISTRY | CDS_NORESET. With 2 monitors, again call ChangeDisplaySettingsExto change settings.
	retVal := DllCall("ChangeDisplaySettingsEx", "Ptr", &monName, "Ptr", &Device_Mode, "Ptr", 0, "UInt", CDSopt, "Ptr", 0)
	Sleep 100

	VarSetCapacity(DM_Position, 0)
	VarSetCapacity(Device_Mode, 0)
	;ChangeDisplaySettingsEx for all monitors (need EnumDisplayDevices)
	; for position of monitor (Primary at 0,0)


	switch (retVal)
	{
		case DISP_CHANGE_BADDUALVIEW: ;-6
		strRetVal := "Change Settings Failed: (Windows XP & later):`nThe settings change was unsuccessful because system is DualView capable."
		case DISP_CHANGE_BADPARAM: ;-5
		strRetVal := "Change Settings Failed: An invalid parameter was passed in.`nThis can include an invalid flag or combination of flags."
		case DISP_CHANGE_BADFLAGS: ;-4
		strRetVal := "An invalid set of flags was passed in."
		case DISP_CHANGE_NOTUPDATED: ;-3
		strRetVal := "(Windows NT/2000/XP: Unable to write settings to the registry."
		case DISP_CHANGE_BADMODE: ;-2
		strRetVal := "The graphics mode is not supported.`nThis can be caused by an out of range resolution value."
		case DISP_CHANGE_FAILED: ;-1
		strRetVal := "The display driver failed the specified graphics mode."
		case DISP_CHANGE_RESTART: ;1
		strRetVal := "Computer must be restarted in order for the graphics mode to work."
		Default: ; retVal = 0: Success!
		{
			if (CDSopt == CDS_TEST)
			traytip, Resolution Test, "Resolution Test Succeeded!"
		}
	}


return strRetVal
}

FindResMatch(iModeCt, ResArray)
{
i := 0
While (PrgLnchOpt.scrWidthDef == ResArray[1, iModeCt - i])
{
	if (PrgLnchOpt.scrHeightDef == ResArray[2, iModeCt - i] && (Abs(PrgLnchOpt.scrFreqDef - ResArray[3, iModeCt - i]) < 1))
	return 1
i++
}
return 0
}


MonitorSelectProc(ByRef resultResolutionMons, canonicalMonitorListIn)
{
WS_EX_CONTEXTHELP := 0x00000400
	static acceptDlg := 0, trackMonNames := [], monitors := [], canonicalMonitorListOut := []

	;https://autohotkey.com/board/topic/72109-ahk-fonts/
	; gui variables in function must be global
	Global guiMonitorSelect1, guiMonitorSelect2, guiMonitorSelect3, guiMonitorSelect4, guiMonitorSelect5, guiMonitorSelect6, guiMonitorSelect7, guiMonitorSelect8, guiMonitorSelect9, outputText

	;monitor names
	wmi := ComObjGet("winmgmts:{impersonationLevel=impersonate}!\\" A_ComputerName "\root\wmi")

		for monitor in wmi.ExecQuery("Select * from WmiMonitorID") ;extract names
		{	
		fname := ""
			for char in monitor.UserFriendlyName
			fname .= chr(char)
		monitors.push(fname)
		}


	if (PrgLnchOpt.activeDispMonNamesNo == 1)
	{
	resultResolutionMons[1] := 1
	canonicalMonitorListOut[1] := monitors[1]
	return canonicalMonitorListOut
	}
	
	
	if (!acceptDlg)
	{
	height := A_ScreenHeight/18

		loop % PrgLnchOpt.activeDispMonNamesNo
		trackMonNames[A_Index] := A_Index

	gui, MonitorSelectDlg: -MaximizeBox -MinimizeBox HWNDhWndMonitorSelectDlg +E%WS_EX_CONTEXTHELP% 
	Gui, MonitorSelectDlg: Font, cTeal Bold, s10

	gui, MonitorSelectDlg: add, text, % "w" . 3 * height . " h" . height/2, Verify Device Numbers
	GuiControl, MonitorSelectDlg: +Center, Verify Device Numbers

	gui, MonitorSelectDlg: Font

	Gui, MonitorSelectDlg: Font, cA96915, s10
	gui, MonitorSelectDlg: add, text, % "w" . 3 * height . " h" . height/2, Click buttons to correct 
	GuiControl, MonitorSelectDlg: +Center, Click buttons to correct
	gui, MonitorSelectDlg: Font

	Gui, MonitorSelectDlg: Font, cTeal
	Gui, MonitorSelectDlg: Add, GroupBox, % "Section W" . 3 * height . " H" . height * PrgLnchOpt.activeDispMonNamesNo + height/2, Monitor List


		; PrgLnch monitor dimensions used for other monitors.
		loop % PrgLnchOpt.activeDispMonNamesNo
		{
		canonicalMonitorListOut[A_Index] := canonicalMonitorListIn[A_Index]
		gui, MonitorSelectDlg: add, button, % "xs+" . height/2 . " ys+" . (A_Index - 1) * height + height/2 . " W" . 2 * height . " H" . height/2 . " gGuiMonitorSelect" . " vguiMonitorSelect" . A_Index, % "Monitor" . resultResolutionMons[A_Index]
		SplashyProc("*", A_Index, resultResolutionMons[A_Index], monitors[resultResolutionMons[A_Index]])
		resultResolutionMons[A_Index] := A_Index
		MovePrgToMonitor(A_Index, 0, 0, 0, 0, 0, 0, 0, 0, Splashy.hWndSaved[A_Index + 1])
		}

	gui, MonitorSelectDlg: add, button, % "Section xp w" . 2 * height . " ys" . height * (PrgLnchOpt.activeDispMonNamesNo + 1) . " gGuiMonitorSelectDlgAccept", Accept

	gui, MonitorSelectDlg: show, % "x" . A_ScreenWidth/4, Monitors

	WinWaitClose, ahk_id %hWndMonitorSelectDlg%
	}

		if (acceptDlg)
		return canonicalMonitorListOut
		else
		return 0


	MonitorSelectDlgGuiClose:
	acceptDlg := 0
	gui, MonitorSelectDlg: Destroy
		loop % PrgLnchOpt.activeDispMonNamesNo
		SplashyProc("*", -A_Index)
	return 0


	GuiMonitorSelectDlgAccept:
	acceptDlg := 1

		loop % PrgLnchOpt.activeDispMonNamesNo
		{
		canonicalMonitorListOut[trackMonNames[A_Index]] := monitors[A_Index]
		resultResolutionMons[A_Index] := trackMonNames[A_Index]
		SplashyProc("*", -A_Index)
		}

	gui, MonitorSelectDlg: Destroy
	return canonicalMonitorListOut


	GuiMonitorSelect:
	gui, MonitorSelectDlg: submit, nohide
	fTemp := subStr(A_GuiControl, 0)

		if (trackMonNames[fTemp] < PrgLnchOpt.activeDispMonNamesNo)
		trackMonNames[fTemp] += 1
		else
		trackMonNames[fTemp] := 1

	SplashyProc("*", fTemp, trackMonNames[fTemp], monitors[trackMonNames[fTemp]])
	MovePrgToMonitor(fTemp, 0, 0, 0, 0, 0, 0, 0, 0, Splashy.hWndSaved[fTemp + 1])

		loop % PrgLnchOpt.activeDispMonNamesNo
		{
		fTemp := A_Index
			loop % PrgLnchOpt.activeDispMonNamesNo
			{
				if (A_Index > fTemp)
				{
					if (trackMonNames[fTemp] == trackMonNames[A_Index])
					{
					GuiControl, MonitorSelectDlg: Disabled, Accept
					return
					}
				}
			}
		}
	GuiControl, MonitorSelectDlg: Enabled, Accept
	return

}


CheckResolutions(targMonitorNum, ByRef monitorOrder, allModes, ByRef ResArrayWMI)
{

Static ResArrayStored := [[], [], []]

; List of names followed by their order.
canonicalMonitorList := [0, 0, 0, 0, 0, 0, 0, 0, 0]



; The following has in all versions of windows to date been the same stock listing
; for every monitor! Thus storing this value for *each* monitor has little relevance.
numResolutionmodes := [0, 0, 0, 0, 0, 0, 0, 0, 0]
static modes := ["", "", "", "", "", "", "", "", ""]
static stockModes := ["", "", "", "", "", "", "", "", ""]
static initResArrayStored := 0, initMonitors := 0

numWMIResolutionmodes := [0, 0, 0, 0, 0, 0, 0, 0, 0]
numResolutionmodesTaken := [0, 0, 0, 0, 0, 0, 0, 0, 0]
resStrng := ["", "", "", "", "", "", "", "", ""]
fTemp := 0, retVal := 0


	if (!initResArrayStored)
	{
	resArrayInit := []
	fTemp := 1 ; arbitrary number
	ResArrayInit[1, fTemp] := 0
	ResArrayInit[2, fTemp] := 0
	ResArrayInit[3, fTemp] := 0

		Loop, % PrgLnchOpt.activeDispMonNamesNo
		ResArrayStored[A_Index] := ResArrayInit

	;First populate res tables with stock resolutions:

		loop % PrgLnchOpt.activeDispMonNamesNo
		{
		; do stock resolutions ever vary per monitor?
		iModeCt := 0, iModeVal := 0
		scrWidthLast := 0, scrHeightLast := 0, scrFreqLast := 0
		dispMon := A_Index

		stockModes[dispMon] := ""

			while GetDisplayData(dispMon, , scrWidth, scrHeight, scrFreq, scrInterlace, scrDPI, iModeVal, (PrgLnch.Monitor != dispMon))
			{

				if (scrWidthLast == scrWidth)
				{
					;many iModeCts here are equivalent for the above params. scrFreq & scrHeight may vary for a subset of those
					if (scrHeightLast != scrHeight || scrFreqLast != scrFreq)
					{
					iModeCt += 1
					ResArrayStored[dispMon, 1, iModeCt] := scrWidth
					ResArrayStored[dispMon, 2, iModeCt] := scrHeight
					ResArrayStored[dispMon, 3, iModeCt] := scrFreq

					scrHeightLast := scrHeight
					scrFreqLast := scrFreq
					scrDPILast := scrDPI
					scrInterlaceLast := scrInterlace
					stockModes[dispMon] .= scrWidth . " `, " . scrHeight . " @ " . scrFreq "Hz |"
					}
				}
				else
				{
					if (scrHeightLast != scrHeight || scrFreqLast != scrFreq && !scrWidthLast)
					{
					iModeCt += 1
					ResArrayStored[dispMon, 1, iModeCt] := scrWidth
					ResArrayStored[dispMon, 2, iModeCt] := scrHeight
					ResArrayStored[dispMon, 3, iModeCt] := scrFreq

					scrWidthLast := scrWidth
					scrHeightLast := scrHeight
					scrFreqLast := scrFreq
					scrDPILast := scrDPI
					scrInterlaceLast := scrInterlace
					stockModes[dispMon] .= scrWidth . " `, " . scrHeight . " @ " . scrFreq "Hz |"
					}
				}
			iModeVal++
			}
		numResolutionmodes[A_Index] := iModeVal
		sleep 300
		}

	; Going through the motions, we already know the outcome ...
	; iterate through all monitors and compare number of resolution each has
	
	Enabled := ComObjError(1)
	dispMon := 0
	wmi := ComObjGet("winmgmts:{impersonationLevel=impersonate}!\\" A_ComputerName "\root\wmi")
		for monitor in wmi.ExecQuery("SELECT NumOfMonitorSourceModes, MonitorSourceModes FROM WmiMonitorListedSupportedSourceModes WHERE Active=TRUE",,wbemFlagForwardOnly := 32)
		{
		dispMon += 1
		numWMIResolutionmodes[dispMon] := monitor.NumOfMonitorSourceModes
		}

	;As these are active monitors, they *should* be equivalent
	dispMon := Max(dispMon, PrgLnchOpt.activeDispMonNamesNo)

		if (dispMon != PrgLnchOpt.activeDispMonNamesNo)
		msgbox, 8192, Active Monitors, Warning: Windows reports a discrepancy regarding the number of active monitors.


	fTemp := 0
		loop %dispMon%
		{
		currMon := A_Index
			loop %dispMon%
			{
				if ((numResolutionmodes[currMon] == numWMIResolutionmodes[A_Index]) && !numResolutionmodesTaken[A_Index])
				{
				numResolutionmodesTaken[A_Index] := 1
				fTemp++
				monitorOrder[fTemp] := currMon
				Break
				}
			}
		}

		; Fill the rest of the array with the monitors having the non matching res modes
		loop %dispMon%
		{
		currMon := A_Index
			if (currMon > fTemp)
			{
				loop %dispMon%
				{
					if (!numResolutionmodesTaken[A_Index])
					{
					monitorOrder[currMon] := A_Index
					numResolutionmodesTaken[A_Index] := 1
					Break
					}
				}
			}
		}

	IniRead, fTemp, % PrgLnch.SelIniChoicePath, General, MonitorNames

		if (fTemp == "ERROR")
		{
		; Versioning:  IniSpaceCleaner moves this before ResMode
		IniWrite, %A_Space%, % PrgLnch.SelIniChoicePath, General, MonitorNames
		; MonitorOrder is also stored in ini file
		IniWrite, %A_Space%, % PrgLnch.SelIniChoicePath, General, MonitorOrder
		fTemp := 0
		}

		if (fTemp && InStr(fTemp, ","))
		{
			Loop, Parse, fTemp, CSV
			canonicalMonitorList[A_Index] := A_Loopfield

			IniRead, fTemp, % PrgLnch.SelIniChoicePath, General, MonitorOrder

			if (fTemp)
			{
			Loop, Parse, fTemp, CSV
			monitorOrder[A_Index] := A_Loopfield
			}
			else
			{
				While (!(canonicalMonitorList := MonitorSelectProc(monitorOrder, canonicalMonitorList)))
				{
				retVal := TaskDialog("Monitor names", "No monitor names obtained", , "", "", "Continue with unreliable monitor info", "Retry (Recommended)")
					if (retVal == 1)
					{
					; populate with unknowns
						loop % PrgLnchOpt.dispMonNamesNo
						canonicalMonitorList[A_Index] := "Unknown" . A_Index
					break
					}
				}
			initMonitors := 1
			}
		}
		else
		{
			if (PrgLnchOpt.activeDispMonNamesNo > 1)
			SetTimer, RnChmWelcome, 3200

			While (!(canonicalMonitorList := MonitorSelectProc(monitorOrder, canonicalMonitorList)))
			{
			retVal := TaskDialog("Monitor names", "No monitor names obtained", , "", "", "Continue with unreliable monitor info", "Retry (Recommended)")
				if (retVal == 1)
				{
				; populate with unknowns
					loop % PrgLnchOpt.dispMonNamesNo
					canonicalMonitorList[A_Index] := "Unknown" . A_Index
				break
				}
			}

			if (!retVal)
			{
			fTemp := ""

				loop % PrgLnchOpt.activeDispMonNamesNo
				fTemp .= A_Space . canonicalMonitorList[A_Index] . ","

			fTemp := SubStr(fTemp, 1, StrLen(fTemp) - 1)

			IniWrite, % Trim(fTemp), % PrgLnch.SelIniChoicePath, General, MonitorNames

			fTemp := ""

				loop % PrgLnchOpt.activeDispMonNamesNo
				fTemp .= monitorOrder[A_Index] . ","

			fTemp := SubStr(fTemp, 1, StrLen(fTemp) - 1)
			IniWrite, %fTemp%, % PrgLnch.SelIniChoicePath, General, MonitorOrder

			initMonitors := 1
			}
		}


	; Obtain resolution set for current monitor.

	ResArrayTracked := []
		; Clone useless for MD arrays
		loop % PrgLnchOpt.activeDispMonNamesNo
		{
		dispMon := A_Index
			loop % ResArrayStored[A_Index, 1].Length()
			{
			ResArrayTracked[dispMon, 1, A_Index] := ResArrayStored[dispMon, 1, A_Index]
			ResArrayTracked[dispMon, 2, A_Index] := ResArrayStored[dispMon, 2, A_Index]
			ResArrayTracked[dispMon, 3, A_Index] := ResArrayStored[dispMon, 3, A_Index]
			}
		}

	; Populate ResArrayWMI (initially unordered)
	Enabled := ComObjError(1)
	dispMon := 0
	wmi := ComObjGet("winmgmts:{impersonationLevel=impersonate}!\\" A_ComputerName "\root\wmi")
		for monitor in wmi.ExecQuery("SELECT NumOfMonitorSourceModes, MonitorSourceModes FROM WmiMonitorListedSupportedSourceModes WHERE Active=TRUE",,wbemFlagForwardOnly := 32)
		{
		; https://superuser.com/questions/1683790/devmode-videomodedescriptor-screen-refresh-rate-data
		; repeated width, height, freq sets may have interlace toggle.
		; NumOfMonitorSourceModes is *supported* modes
		ResArrayTmp := ""
		ResArrayTmp := []
		dispMon++
		numWMIResolutionmodes[dispMon] := monitor.NumOfMonitorSourceModes

			Loop, % monitor.NumOfMonitorSourceModes
			{
			sourceIndex := A_Index - 1
			ResArrayTmp[1, A_Index] := monitor.MonitorSourceModes[sourceIndex].HorizontalActivePixels
			ResArrayTmp[2, A_Index] := monitor.MonitorSourceModes[sourceIndex].VerticalActivePixels
			ResArrayTmp[3, A_Index] := Round((monitor.MonitorSourceModes[sourceIndex].VerticalRefreshRateNumerator)/(monitor.MonitorSourceModes[sourceIndex].VerticalRefreshRateDenominator))
			}

		ResArrayTmp := SortSourceModes(dispMon, numWMIResolutionmodes, ResArrayTmp)


			Loop, % numWMIResolutionmodes[dispMon]
			{
			scrWidth := ResArrayTmp[1, A_Index]
			ResArrayWMI[dispMon, 1, A_Index] := scrWidth
			scrHeight := ResArrayTmp[2, A_Index]
			ResArrayWMI[dispMon, 2, A_Index] := scrHeight
			scrFreq := ResArrayTmp[3, A_Index]
			ResArrayWMI[dispMon, 3, A_Index] := scrFreq
			modes[dispMon] .= scrWidth . " `, " . scrHeight . " @ " . scrFreq "Hz |"
			iModeCt := 0


			; Now check the all WMI resolutions are in the stock:

			resArrayInit := ""
			resArrayInit := []
				loop % numResolutionmodes[dispMon]
				{
				if (scrWidth == ResArrayTracked[dispMon, 1, A_Index])
				resArrayInit.Push(A_Index)
				}
				iModeCt := 0
				for each in resArrayInit
				{
				fTemp := resArrayInit[A_Index]
				scrWidthTest := ResArrayTracked[dispMon, 1, fTemp]
				scrHeightTest := ResArrayTracked[dispMon, 2, fTemp]
					if (scrHeight == scrHeightTest)
					{
					scrFreqTest := ResArrayTracked[dispMon, 3, fTemp]
					; reduce search payload
						if (scrFreq == scrFreqTest)
						{
							for each, array in ResArrayTracked[dispMon]
							array.RemoveAt(fTemp)
						iModeCt := 1
						}
					}
				}
			if (!imodeCt)
			resStrng[dispMon] .= scrWidth . " `, " . scrHeight . " @ " . scrFreq "Hz`n"
			}
		}

		if (initMonitors)
		{
		DisplayNonStockRes(canonicalMonitorList, resStrng)
		initMonitors := 0
		}

	initResArrayStored := 1
	}

	if (allModes)
	{
		if (stockModes[monitorOrder[targMonitorNum]])
		return stockModes[monitorOrder[targMonitorNum]]
	}
	else
	{
		if (modes[monitorOrder[targMonitorNum]])
		return modes[monitorOrder[targMonitorNum]]
	}
return
}


DisplayNonStockRes(canonicalMonitorList, ResList)
{

	height := A_ScreenHeight/5
	WS_EX_CONTEXTHELP := 0x00000400

	gui, NonStockResDlg: -MaximizeBox -MinimizeBox +E%WS_EX_CONTEXTHELP% HWNDhWndNonStockResDlg
	Gui, NonStockResDlg: Font, cTeal Bold, s10
	gui, NonStockResDlg: add, text, w%height%, Missing Stock Resolutions
	Gui, NonStockResDlg: Font

	Gui, NonStockResDlg: Font, cA96915, s10

	Strng := ""
		for each in canonicalMonitorList
		{
			loop StrLen(canonicalMonitorList[A_Index])
			Strng .= "-"
		Strng .= "`n" . canonicalMonitorList[A_Index] . "`n"
			loop StrLen(canonicalMonitorList[A_Index])
			Strng .= "-"

			Strng .= "`n" . ResList[A_Index] 
		}
	gui, NonStockResDlg: add, text, w%height%, %Strng%


	gui, NonStockResDlg: Font
	Gui, NonStockResDlg: Font, cTeal


	gui, NonStockResDlg: add, button, gNonStockResDlgClipSave w%height%, Save to Clipboard
	gui, NonStockResDlg: add, button, gNonStockResDlgAccept w%height%, Accept

	gui, NonStockResDlg: show, % "x" . height, Res. Report 

	if (PrgLnchOpt.activeDispMonNamesNo == 1)
	SetTimer, RnChmWelcome, 3500

	WinWaitClose, ahk_id %hWndNonStockResDlg%


	return

	NonStockResDlgClipSave:
	Clipboard := Strng
	return

	NonStockResDlgAccept:
	NonStockResDlgGuiClose:
	gui, NonStockResDlg: Destroy
	return 0
}


SortSourceModes(dispMonIn, numWMIResolutionmodes, ResArray)
{
Static dispMon := dispMonIn
ResNewArray := []
; Sorts the unordered WMI res modes and returns them in ResNewArray

	if (dispMon != dispMonIn)
	{
	;reset stuff
	dispMon := dispMonIn
	numWMIResolutionmodesSaved := numWMIResolutionmodes[dispMon]
	numWMIResolutionmodesTmp := numWMIResolutionmodesSaved
	}

	While (numWMIResolutionmodesTmp)
	{
	temp := Min(ResArray[1]*)
	fTemp := 0
	tempHeight := ""
	tempHeight := []
	tempFreq := ""
	tempFreq := []
	strHeight := ""
	strFreq := ""

	resOffset := numWMIResolutionmodesSaved - numWMIResolutionmodesTmp

		Loop, % numWMIResolutionmodesTmp
		{
			if (ResArray[1, A_Index] == temp)
			{
			fTemp++
			ResNewArray[1, resOffset + fTemp] := temp
			tempHeight.Push(A_Index)
			}
		}

		for fTemp in tempHeight
		{
			Loop, % numWMIResolutionmodesTmp
			{
				if (A_Index == tempHeight[fTemp])
				{
				strHeight .= ResArray[2, A_Index] . "`,"
				tempFreq.Push(A_Index)
				}
			}
		}

	strHeightOld := strHeight
	Sort strHeight, N D, 

	;Order of frequencies follows ordered Height
		for fTemp in tempFreq
		{
			Loop, Parse, strHeight, CSV
			{
			temp := 0
			newLoopfield := A_Loopfield
				Loop, Parse, strHeightOld, CSV
				{
					if (A_Loopfield && A_Loopfield == newLoopfield)
					{
					strFreq .= ResArray[3, tempFreq[fTemp]] . "`,"
					strHeightOld := SubStr(strHeightOld, 1, InStr(strHeightOld, A_Loopfield) - 1) . SubStr(strHeightOld, InStr(strHeightOld, A_Loopfield) + StrLen(A_Loopfield))
					temp := 1
					break
					}
				}
			ResNewArray[2, resOffset + fTemp] := A_Loopfield
				if (temp)
				break
			}
		}

	temp := 0
	fTemp := 0
		Loop, Parse, strFreq, CSV
		{
			if (A_Loopfield)
			{
			; Remove processed entries and adjust counter
				if (fTemp)
				{
					if (tempHeight[A_Index] > fTemp)
					fTemp := tempHeight[A_Index]
					else
					fTemp := tempHeight[A_Index] - 1
				}
				else
				fTemp := tempHeight[A_Index]

				if (!(ResArray[1].RemoveAt(fTemp) && ResArray[2].RemoveAt(fTemp) && ResArray[3].RemoveAt(fTemp)))
				MsgBox, 8192, SortSourceModes, Unexpected error!

			ResNewArray[3, resOffset + A_Index] := A_Loopfield
			numWMIResolutionmodesTmp--
			}
		}
	}
Return ResNewArray
}




GetResInfo(targMonitorNum, getCurrentRes := 0, allModes := 0, ByRef iDevNumArray := 0, setPrgLnchOptDefs := 0)
{
; From Checkmodes, 1: click ResList, 2: get all, 0: get default, 3: check default

static monitorMsg := 0, ENUM_CURRENT_SETTINGS := -1, ENUM_REGISTRY_SETTINGS := -2
static checkDefMissing := [0, 0, 0, 0, 0, 0, 0, 0, 0]
Static ResArrayIn := [[], [], []], monitorOrder := [0, 0, 0, 0, 0, 0, 0, 0, 0]

ResList := "", Strng := ""

fTemp := 0, iModeCt := 0, iModeval := 0
scrWidth := 0, scrHeight := 0, scrDPI := 0, scrInterlace := 0, scrFreq := 0
scrWidthLast := 0, scrHeightLast := 0, scrDPILast := 0, scrInterlaceLast := 0, scrFreqLast := 0

	switch (getCurrentRes)
	{
	
		case 1: ; click selection in list
		{
		PrgLnchOpt.scrWidth := ResArrayIn[PrgLnchOpt.OrderTargMonitorNum, 1, setPrgLnchOptDefs]
		PrgLnchOpt.scrHeight := ResArrayIn[PrgLnchOpt.OrderTargMonitorNum, 2, setPrgLnchOptDefs]
		PrgLnchOpt.scrFreq := ResArrayIn[PrgLnchOpt.OrderTargMonitorNum, 3, setPrgLnchOptDefs]
		}
		case 2:  ; 3: populate list
		ResList := CheckResolutions(targMonitorNum, monitorOrder, allModes, ResArrayIn)
		case 3: ; check default (when switching monitors)
		{
		iModeCt := 1

		ResArray := ResArrayIn[PrgLnchOpt.OrderTargMonitorNum]
		
		ResTmpArray := []

			loop, 3
			ResTmpArray[A_Index, 0] := 0

			while (scrWidth := ResArray[1, iModeCt])
			{
				scrHeight := ResArray[2, iModeCt]
				scrFreq := ResArray[3, iModeCt]

				;For "Incompatible" resolution detection: check if the current settings are missing from the list and replace it .
				if (!checkDefMissing[targMonitorNum] && PrgLnchOpt.scrWidthDef && (scrWidth > PrgLnchOpt.scrWidthDef))
				{
					if ((!FindResMatch(iModeCt + 1, ResArray)) || (scrWidthLast != PrgLnchOpt.scrWidthDef))
					{
					ResTmpArray[1].Push(PrgLnchOpt.scrWidthDef)
					ResTmpArray[2].Push(PrgLnchOpt.scrHeightDef)
					ResTmpArray[3].Push(PrgLnchOpt.scrFreqDef)
					Strng := PrgLnchOpt.scrWidthDef . " `, " . PrgLnchOpt.scrHeightDef . " @ " . PrgLnchOpt.scrFreqDef . "Hz |"
					ResList .= Strng

					IniRead, fTemp, % PrgLnch.SelIniChoicePath, General, CheckDefMissingMsg

						if (fTemp = "ERROR")
						{
						; Versioning:  IniSpaceCleaner moves this before ResMode
						IniWrite, %A_Space%, % PrgLnch.SelIniChoicePath, General, CheckDefMissingMsg
						fTemp := 0
						}

						if (!fTemp)
						{
						;note-msgbox isn't modal if called from function
						retVal := TaskDialog("Monitor Selection", "Unsupported Default Resolution", "", "The current desktop resolution of " PrgLnchOpt.scrWidthDef " X " PrgLnchOpt.scrHeightDef " does not belong to the list of resolution modes the firmware of selected monitor " . targMonitorNum . " has flagged as operable. If the OEM wddm driver asserts`nthe resolution mode is actually compatible, the mode will appear in the Windows Setting's list of resolution, there is no issue other than PrgLnch using an older technology from that of the driver. Else, the options of an out-dated or imported PrgLnch ini file, driver inconsistency or error in multi-monitor setup cannot be discounted.`n`nThe mode has been inserted to the PrgLnch Resolution Mode list, however changes to this, or any other resolution mode in this PrgLnch instance may not work properly.`n`nTo use PrgLnch, it's recommended the current desktop resolution be permanently changed to one which is more " . """" . "compatible" . """" . " with the driver.`nTo do so, from PrgLnch Options, select " . """" . "None" . """" . " in Shortcut slots, and choose " . """" . "Dynamic" . """" . " in the Res Options, and then select an alternative resolution mode from the list. Be sure`nto return the selection in Res Options to " . """" . "Temporary" . """" . ", if that is the preference.`n`nChecking " . """" . "Do not show this again" . """" . " also suppresses this warning for other monitors.", , "Continue with the resolution checks")

							if (retVal < 0)
							{
							IniWrite, 1, % PrgLnch.SelIniChoicePath, General, CheckDefMissingMsg

								for fTemp in checkDefMissing
								checkDefMissing[A_Index] := 1
							}
						}
					}
				checkDefMissing[targMonitorNum] := 1
				}

				if (scrWidthLast == scrWidth)
				{
					;many iModeCts here are equivalent for the above params. scrFreq & scrHeight may vary for a subset of those
					if ((allModes && (scrHeightLast == scrHeight || scrFreqLast == scrFreq)) || (scrHeightLast != scrHeight || scrFreqLast != scrFreq))
					{
					scrHeightLast := scrHeight
					scrFreqLast := scrFreq
					Strng := scrWidth . " `, " . scrHeight . " @ " . scrFreq "Hz |"
					ResList .= Strng
					ResTmpArray[1].Push(scrWidth)
					ResTmpArray[2].Push(scrHeight)
					ResTmpArray[3].Push(scrFreq)
					iModeVal++
					}
				}
				else
				{
					if (!allModes || allModes && (scrHeightLast == scrHeight && scrFreqLast == scrFreq))
					{
					scrWidthLast := scrWidth
					scrHeightLast := scrHeight
					scrFreqLast := scrFreq
					Strng := scrWidth . " `, " . scrHeight . " @ " . scrFreq "Hz |"
					ResList .= Strng
					ResTmpArray[1].Push(scrWidth)
					ResTmpArray[2].Push(scrHeight)
					ResTmpArray[3].Push(scrFreq)
					}
				}
			iModeCt++
			}
		ResArrayIn[PrgLnchOpt.OrderTargMonitorNum] := ResTmpArray
		ResTmpArray := ""
		ResArray := ""
		}
		Default: ; Get default res
		{
		;imodeVal == 0 caches the data for EnumSettings
			if (!GetDisplayData(targMonitorNum, , , , , , , iModeval, (PrgLnch.Monitor != targMonitorNum)))
			MsgBox, 8192, Display Data, Display data could not be cached!
			if (!GetDisplayData(targMonitorNum, , scrWidth, scrHeight, scrFreq, scrInterlace, scrDPI, (PrgLnch.regoVar)? ENUM_REGISTRY_SETTINGS: ENUM_CURRENT_SETTINGS, (PrgLnch.Monitor != targMonitorNum)))
			MsgBox, 8192, Display Data, % "PrgLnch could not retrieve information on " ((PrgLnch.Monitor == targMonitorNum)? "the monitor from which it was launched!": "monitor " targMonitorNum)
		; Compare & check defaults (hope frequencies tally)
		SysGet, mt, Monitor, %targMonitorNum%

			if (mtRight - mtLeft)
			{
				if (mtRight - mtLeft != scrWidth)
				fTemp := 1
				else
				{
					if (mtBottom - mtTop != scrHeight)
					fTemp := 1
				}

				if (monitorMsg && fTemp)
				{
				monitorMsg := 1
				MsgBox, 8192, Monitor Setup, The default screen resolution for the current monitor is not correct,`nand its default refresh rate (frequency Hz) may not be reliable.`nCould be an issue with the initial monitor setup,`nor that the monitor was not available on Windows Bootup`n`n(A once per session notification that may apply to any other physical monitor attached to the desktop).
				}

			PrgLnchOpt.scrWidthDef := mtRight - mtLeft
			PrgLnchOpt.scrHeightDef := mtBottom - mtTop
			PrgLnchOpt.scrFreqDef := scrFreq
			ResList := PrgLnchOpt.scrWidthDef . " `, " . PrgLnchOpt.scrHeightDef . " @ " . PrgLnchOpt.scrFreqDef . "Hz |"

			PrgLnchOpt.OrderTargMonitorNum := MonitorOrder[targMonitorNum]
			}
			; else error reported in caller
		}
	}
return ResList
}

CopyToFromRes(targMonitorNum, copyTo := 0, Test := 0)
{
; These for GetDisplayData
Static ENUM_CURRENT_SETTINGS := -1, ENUM_REGISTRY_SETTINGS := -2

static scrWidthTest := 0, scrHeightTest := 0, scrFreqTest := 0
static scrWidthOld := [0, 0, 0, 0, 0, 0, 0, 0, 0], scrHeightOld := [0, 0, 0, 0, 0, 0, 0, 0, 0], scrFreqOld := [0, 0, 0, 0, 0, 0, 0, 0, 0]
scrWidth := 0, scrHeight := 0, scrFreq := 0
	if (copyTo)
	{
	; v2 allows property deref
		if (Test > 0)
		{
		; Save res that is set for the test Prg
		scrWidthTest := PrgLnchOpt.scrWidth
		scrHeightTest := PrgLnchOpt.scrHeight
		scrFreqTest := PrgLnchOpt.scrFreq
		}
		else
		{
		GetDisplayData(targMonitorNum, , scrWidth, scrHeight, scrFreq, , , (PrgLnch.regoVar)? ENUM_REGISTRY_SETTINGS: ENUM_CURRENT_SETTINGS, 1)
			if (Test)
			{
			scrWidthOld[targMonitorNum] := scrWidth
			scrHeightOld[targMonitorNum] := scrHeight
			scrFreqOld[targMonitorNum] := scrFreq
			}
			else
			{
			PrgLnchOpt.scrWidthDef := scrWidth
			PrgLnchOpt.scrHeightDef := scrHeight
			PrgLnchOpt.scrFreqDef := scrFreq
			}
		}
	}
	else
	{
		if (Test < 0)
		{
		PrgLnchOpt.scrWidth := scrWidthOld[targMonitorNum]
		PrgLnchOpt.scrHeight := scrHeightOld[targMonitorNum]
		PrgLnchOpt.scrFreq := scrFreqOld[targMonitorNum]
		}
		else
		{
			if (Test)
			{
			PrgLnchOpt.scrWidth := scrWidthTest
			PrgLnchOpt.scrHeight := scrHeightTest
			PrgLnchOpt.scrFreq := scrFreqTest
			}
			else
			{
			PrgLnchOpt.scrWidth := PrgLnchOpt.scrWidthDef
			PrgLnchOpt.scrHeight := PrgLnchOpt.scrHeightDef
			PrgLnchOpt.scrFreq := PrgLnchOpt.scrFreqDef
			}
		}
	}
}

DefResNoMatchRes(noPrompt := 0)
{
defResMsg := 0

	if (PrgLnchOpt.scrWidth == PrgLnchOpt.scrWidthDef && PrgLnchOpt.scrHeight == PrgLnchOpt.scrHeightDef)
	{

		if (PrgLnchOpt.Fmode()) ;always change: Condition removed: (PrgLnchOpt.DynamicMode()
		return 1

	IniRead, defResMsg, % PrgLnch.SelIniChoicePath, General, DefResMsg

		if (noPrompt || defResMsg)
		{
			if (DefResMsg == 1)
			return 1
			else
			return 0
		}
		else
		{
		defResMsg := TaskDialog("Same Resolution", "Informational: The resolution on the Prg's target`nmonitor is identical to its current resolution", , "When the target resolution is the same as the existing resolution, the firmware`nin most monitors performs a rescan each time the change resolution function`nis called, a consideration fortunately handled in most video driver software.`nChoose the recommended action, unless trouble-shooting the monitor.`n`nScreen resolution always changes automatically when " . """" . "Change at every mode" . """" . "`nin " . """" . "Res Options" . """" . " is selected`, irrespective of the following choices.", , "Change resolution", "Do not change resolution (Recommended)", "Decide later")
			if (defResMsg < 0)
			{
			defResMsg := -defResMsg
				if (defResMsg != 3)
				IniWrite, %defResMsg%, % PrgLnch.SelIniChoicePath, General, DefResMsg
			}
			if (defResMsg == 1)
			return 1
			else
			return 0
		}
	}
	else
	return 1
}


MDMF_GetMonStatus(targMonitorNum, getTooltip := 0)
{

Monitors := {Count: 0, targetMonitorNum: 0}
Monitors.targetMonitorNum := targMonitorNum
retVal := 0

PrgLnchOpt.CurrMonStat := getTooltip


; GlobalFree (below) spits a 0xc0000374 when EnumProc is static!
;If (Monitors.MaxIndex() = "") ; enumerate
EnumProc := RegisterCallback("MonitorEnumProc", "", 4)



; enumerates monitors in the same order as sysget.
	if (!(DllCall("User32.dll\EnumDisplayMonitors", "ptr", 0, "ptr", 0, "ptr", EnumProc, "ptr", &Monitors)))
	{
		;if (DllCall("GlobalFree", "Ptr", EnumProc, "Ptr"))
		;MsgBox, 8195, Memory Clean up, GlobalFree Failed
	retval := PrgLnchOpt.CurrMonStat
	return retVal
	}
}

MonitorEnumProc(hMonitor, hdcMonitor, lprcMonitor, MonitorsObj)
{
64bit := 0 , Physical_Monitor := 0, monitorDesc := "", retVal := 0, temp := 0, fTemp := 0, physHand := 0, outStr := "", Monitors := Object(MonitorsObj)
Monitors.Count++
MonitorsObj := Monitors

if (Monitors.Count == Monitors.targetMonitorNum)
{
/*
        public enum MC_DISPLAY_TECHNOLOGY_TYPE
        {
            MC_SHADOW_MASK_CATHODE_RAY_TUBE,

            MC_APERTURE_GRILL_CATHODE_RAY_TUBE,

            MC_THIN_FILM_TRANSISTOR,

            MC_LIQUID_CRYSTAL_ON_SILICON,

            MC_PLASMA,

            MC_ORGANIC_LIGHT_EMITTING_DIODE,

            MC_ELECTROLUMINESCENT,

            MC_MICROELECTROMECHANICAL,

            MC_FIELD_EMISSION_DEVICE,
        }

*/

; Get Physical Monitor(s) from handle

	if (!DllCall("dxva2\GetNumberOfPhysicalMonitorsFromHMONITOR", "Ptr", hMonitor, "uint*", numberOfPhysicalMonitors))
	{
		if (PrgLnchOpt.CurrMonStat)
		CreateToolTip("GetNumberOfPhysicalMonitorsFromHMONITOR failed with code: " . """" . A_LastError . """")
	PrgLnchOpt.CurrMonStat := 0
	return False
	}
	sizeOfmonitorHandleAndDesc := (A_IsUnicode ? 2 : 1) * 128 + (A_PtrSize == 8)? 8 : 4
	VarSetCapacity(monitorHandleandDesc, sizeOfmonitorHandleandDesc, 0)
	VarSetCapacity(physicalMonitorArray, numberOfPhysicalMonitors * sizeOfmonitorHandleandDesc, 0)

	; Get Physical Monitor from handle
	

	OffsetDWORD := 4, OffsetUchar := 1

	;NumPut(Physical_Monitor, Device_Mode, OffsetDWORD + offsetWORDStr, Ushort) ; initialise cbsize member
	if (DllCall("dxva2\GetPhysicalMonitorsFromHMONITOR", "Ptr", hMonitor, "uint", numberOfPhysicalMonitors, "Ptr", &physicalMonitorArray))
	{
		Loop %numberOfPhysicalMonitors%
		{
			if (numberOfPhysicalMonitors > 1)
			outStr .= "`n"

			physHand := NumGet(physicalMonitorArray[A_Index - 1], (A_Index - 1) * sizeOfmonitorHandleAndDesc)
			; 0 value Physical Monitor Handles are valid and common!!!
			VarSetCapacity(MC_TIMING_REPORT, OffsetUchar + OffsetDWORD + OffsetDWORD)
			retVal := DllCall("dxva2\GetTimingReport", "Ptr", physHand, "Ptr", &MC_TIMING_REPORT)
			sleep 30
				if (retVal)
				{
				; Get Monitor description
				temp := &physicalMonitorArray[A_Index - 1] + sizeOfmonitorHandleAndDesc

				temp := StrGet(temp, sizeOfmonitorHandleAndDesc)

				;Horizontal scan HZ
				fTemp := NumGet(MC_TIMING_REPORT, 0, "Int")
				outStr .= "Monitor Description: " . temp . "`nHorizontal Frequency: " . fTemp/100 . " KHz"
				}
				else
				{
					switch (A_LastError)
					{
					case 31:
					strRetVal := "ERROR_GEN_FAILURE"
					case -1071241847:
					{
					strRetVal := "ERROR_GRAPHICS_DDCCI_INVALID_MESSAGE_COMMAND"
					retVal := 1 ; monitor still good to go???
					}
					case -1071241856:
					{
					strRetVal := "ERROR_GRAPHICS_I2C_NOT_SUPPORTED"
					retVal := 1 ; monitor still good to go
					}
					case -1071241854:
					{
					strRetVal := "ERROR_GRAPHICS_I2C_ERROR_TRANSMITTING_DATA"
					retVal := 1 ; monitor still good to go
					}
					case -1071241853:
					{
					strRetVal := "ERROR_GRAPHICS_I2C_ERROR_RECEIVING_DATA"
					retVal := 1 ; monitor still good to go
					}
					case -1071241852:
					{
					strRetVal := "ERROR_GRAPHICS_DDCCI_VCP_NOT_SUPPORTED"
					retVal := 1 ; monitor still good to go
					}
					case -1071241844:
					strRetVal := "ERROR_GRAPHICS_INVALID_PHYSICAL_MONITOR_HANDLE"
					Default:
					{
					}
					}
				outStr .= "GetTimingReport failed with code: " . ((strRetVal)? strRetVal: A_LastError) . " ."
				}

			if (!DllCall("dxva2\DestroyPhysicalMonitor", "ptr", physHand))
			{
			
				if (A_LastError == -1071241844)
				strRetVal := "ERROR_GRAPHICS_INVALID_PHYSICAL_MONITOR_HANDLE"
				else
				{
					if (A_LastError == -1071241852)
					strRetVal := "ERROR_GRAPHICS_DDCCI_VCP_NOT_SUPPORTED"
				}
			outStr .= "DestroyPhysicalMonitor failed with code: " . ((strRetVal)? strRetVal: A_LastError) . " ."
			}

			VarSetCapacity(MC_TIMING_REPORT, 0)
		}
		if (PrgLnchOpt.CurrMonStat)
		CreateToolTip(outStr)

	}
	else
	{
		if (PrgLnchOpt.CurrMonStat)
		CreateToolTip("GetPhysicalMonitorsFromHMONITOR failed with code: " . """" . A_LastError . """")
	}
	PrgLnchOpt.CurrMonStat := retVal
	VarSetCapacity(Physical_Monitor, 0)
return False ;No more iterations required
}
else
return True
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
	return
}
else ;interrupted download but wish to continue
{
	if (temp="&Save URL")
	{

		;;verify URL
		PrgUrlTest := Trim(PrgUrlTest)							
		If (!RegExMatch(PrgUrlTest, "^(https?://|www\.)[a-zA-Z0-9\-\.]+\.[a-zA-Z]{2,3}(/\S*)?$"))
		{
			retVal := TaskDialog("URL String", "The URL doesn't appear valid", , "", "", "Try the URL", "Cancel")
			if (retVal == 2)
			return
		}
		UrlPrgIsCompressed := ChkURLPrgExe(PrgUrlTest)
		if (UrlPrgIsCompressed < 0)
		{
			retVal := TaskDialog("Executable URL", "The URL does not appear to contain an extension which indicates a compressed or executable file", , "", "", "Try the URL", "Cancel")
			if (retVal == 2)
			return
		}

		GuiControl, PrgLnchOpt:, UpdtPrgLnch, % "&Update Prg"
		PrgUrl[selPrgChoice] := PrgUrlTest

		IniWrite, %PrgUrlTest%, % PrgLnch.SelIniChoicePath, Prg%selPrgChoice%, PrgUrl
	}
	else
	{
		if (!updateStatus)
		{
		retVal := TaskDialog("Downloading Prg", "Cancel the download?", , "", "", "Cancel", "Continue downloading")
			if (retVal == 1) ; i.e. Assume "Cancel" if timeout
			{
			updateStatus := -1
			return
			}
		; Otherwise, continue:
		}
	}
}
return


NewThreadforDownload: ;Timer!
	HideShowCtrls(1)
	GuiControl, PrgLnchOpt: , UpdtPrgLnch, &Cancel (Esc)

	;In most cases only the file names in the url will want encoding-else only spaces in folders or user names
	;https://github.com/ahkscript/libcrypt.ahk/blob/master/src/URI.ahk
	;https://tools.ietf.org/html/rfc3986
	;We don't know if the URL works, but write it to ini anyway
	IniProc(selPrgChoice)

	strTemp := ExtractPrgPath(selPrgChoice, PrgChoicePaths, 0, PrgLnkInf, 0, IniFileShortctSep, temp)
	if (InStr(PrgUrl[selPrgChoice], "%"))
	DownloadFile(LC_UrlDecode(PrgUrl[selPrgChoice]), strTemp, updateStatus)
	else
	DownloadFile(LC_UrlEncode(PrgUrl[selPrgChoice]), strTemp, updateStatus)


		if (updateStatus < 0)
		{
			if (updateStatus == -1)
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
			MsgBox, 8192, Downloading, % "Problem with retrieving local version info for file " strTemp
			}
			else
			{
			PrgVer[selPrgChoice] := PrgVerNew
			IniWrite, %PrgVerNew%, % PrgLnch.SelIniChoicePath, Prg%selPrgChoice%, PrgVer
			}

		IniRead, fTemp, % PrgLnch.SelIniChoicePath, General, PrgLaunchAfterDL

			if (!fTemp)
			{
			retVal := TaskDialog("Prg Downloaded", "Launch the Prg?", , "Launch the downloaded Prg to test it. After selecting" . """" .  "Launch" . """" . ",`nPrgLnch Options won't be available until the launched Prg is closed.", , "Launch", "Do not launch")
				if (retVal < 0)
				{
				retVal := -retVal
				IniWrite, %retVal%, % PrgLnch.SelIniChoicePath, General, PrgLaunchAfterDL
				}
				if (retVal == 1)
				{
				Runwait, % strTemp, , UseErrorLevel ; might be a self extracting package
					if (ErrorLevel)
					MsgBox, 8192, Prg launch, The file could not be launched with error %ErrorLevel%
				}
			}
		strTemp2 := ExtractPrgPath(selPrgChoice, PrgChoicePaths, 0, PrgLnkInf, 0, IniFileShortctSep, temp)
		if (strTemp != strTemp2)
		{
		SplitPath, strTemp2,, strTemp2
		SplitPath, strTemp,, strTemp
			if (strTemp2 == strTemp)
			{
				retVal := TaskDialog("Prg Directories", "The Prg just updated is assigned to this directory:`n" . """" . strTemp . """" . "`nThe original Prg still exists in this directory:`n" . """" . strTemp2 . """", , "", "", "Delete the original", "Keep the original for archiving")
				if (retVal == 1)
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
			IniWrite, %strTemp%, % PrgLnch.SelIniChoicePath, Prg%selPrgChoice%, PrgPath
			}
			else
			MsgBox, 8192, Prg Directories, % "The Prg just updated is assigned to this directory:`n" . """" . strTemp . """" . "`nThe original Prg still exists in this directory:`n" . """" . strTemp2 . """" . "`nGiven the new location the Prg was downloaded to is preferred,`nconsider for housekeeping, manual removal of the original directory."
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
return



;http://www.codeproject.com/Article.aspx?tag=198374993737746150&_z=11114232
DownloadFile(UrlToFile, ByRef SaveFileAs, ByRef updateStatus)
{
	X :=0, Y:=0, temp:=0, strTemp := "", retVal := 0, PercentDone := 0, badFile := "text`/html", timedOut := False, prgWid := PrgLnchOpt.Width()/3, prgHght := PrgLnchOpt.Height()/2
	global progressVar, progressText
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
			return
			}

			SplitPath, temp, , strTemp
			SplitPath, temp, temp
			ChkCmdLineValidFName(temp)
			if Instr(strTemp, A_WinDir)
			{
			IniRead, retVal, % PrgLnch.SelIniChoicePath, General, WinRtDirWrn
				if (!retVal)
				{
				retVal := TaskDialog("Windows Directory", "Windows area used for a file download", , "Directories and subdirectories there contain protected system files,`nso downloading anything like those will not work as intended,`nand downloading anything else there is not recommended.", , "Continue the download", "Abort the download")
					if (retVal < 0)
					{
					retVal := -retVal
					IniWrite, retVal , % PrgLnch.SelIniChoicePath, General, WinRtDirWrn
					}

					if (retVal == 2)
					{
					updateStatus := -2
					return
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
		MsgBox, 8192, Download Error,Wrong file header, or file not found!
		updateStatus := -2
		WebRequest := ""
		return
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



			if (!FinalSize || timedOut)
			MsgBox, 8192, Downloading Prg, Timed out

			if (!progressVar)
			Gui, Progrezz: New, +OwnDialogs


		SysGet, X, 45 ;Progress bar border B1 corresponds with SM_CXEDGE?
		SysGet, Y, 4 ;Height of a caption area?

		X := PrgLnchOpt.X() - prgWid - (2 * X)
		Y := PrgLnchOpt.Y() + PrgLnchOpt.Height() - prgHght - (2 * Y)

			if (X < 0) ;form was moved to the left
			X := PrgLnchOpt.X() + PrgLnchOpt.Width()


			if (!progressVar)
			{
			Gui, Progrezz: Hide
			prgHght := prgHght/2
			Gui, Progrezz: Add, Progress, R2 W%prgWid% H%prgHght% vprogressVar cGreen Border
			Gui, Progrezz: Add, Text, Center W%prgWid% H%prgHght% vprogressText cRed, Downloading...
			prgHght := 2 * prgHght
			Gui, Progrezz: Show, X%X% Y%Y% W%prgWid% H%prgHght%, Downloading...
			}

		SetTimer, __UpdateProgressBar, 200

		}
		catch temp
		{
		msgbox, 8208, Downloading Prg, Problem with the URL!`nSpecifically: %temp%
		Gui, Progrezz: Hide
		updateStatus := -3
		SetTimer, __UpdateProgressBar, Delete
		WebRequest := ""
		return
		}

	GuiControl, PrgLnchOpt: , UpdtPrgLnch, &Cancel (Esc)
	;Download the file
		try
		{
		UrlDownloadToFile, %UrlToFile%, %SaveFileAs%
		}
		catch temp
		{
		msgbox, 8208, Downloading Prg, Error with the download!`nSpecifically: %temp%
		PercentDone := 100
		updateStatus := -1
		Gui, Progrezz: Hide
		SetTimer, __UpdateProgressBar, Delete
		GuiControl, PrgLnchOpt: Hide, UpdtPrgLnch
		GuiControl, PrgLnchOpt: , UpdtPrgLnch, &Update Prg
		WebRequest := ""
		return
		}
	;Remove the timer and the progressbar because the download has finished
	GuiControl, PrgLnchOpt: Hide, UpdtPrgLnch
	GuiControl, PrgLnchOpt: , UpdtPrgLnch, &Update Prg
	PercentDone := 100
	Gui, Progrezz: Hide
	SetTimer, __UpdateProgressBar, Delete
	WebRequest := ""
	return



	;TIMER HERE:	The label that updates the progressbar
	__UpdateProgressBar:
	if (updateStatus == -1)
	{
	PercentDone := 100
	}
	else
	{
	;Get the current filesize and tick
	CurrentSize := FileOpen(SaveFileAs, "r").Length ;FileGetSize wouldn't return reliable results
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

	GuiControl, Progrezz:, progressVar, %PercentDone%
	GuiControl, Progrezz:, progressText, Downloading %SaveFileAs% (%PercentDone%`%) at (%Speed%) speed

	return
}


; Modified by GeekDude from http://goo.gl/0a0iJq
LC_UrlEncode(Url)
{ ; keep ":/;?@,&=+$#."
	return LC_UriEncode(Url, "[0-9a-zA-Z:/;?@,&=+$#.]")
}
LC_UriEncode(Uri, RE="[0-9A-Za-z]")
{
	VarSetCapacity(Var, StrPut(Uri, "UTF-8"), 0), StrPut(Uri, &Var, "UTF-8")

	While Code := NumGet(Var, A_Index - 1, "UChar")

	Res .= (Chr:=Chr(Code)) ~= RE ? Chr : Format("%{:02X}", Code)
	VarSetCapacity(Var, 0)
	return, Res
}
LC_UrlDecode(url)
{
	return LC_UriDecode(url)
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
	return, Uri
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
	;version is never going to exceed 1000 bytes, so returns junk if version.txt not found

		if (!PrgVerNew || StrLen(PrgVerNew)>1000)
		{
		PrgVerNew := 0
		MsgBox, 4112, Prg Version, % "version.txt not at " verLoctmp
		return 1
		}
	}
	Catch err ;http://stackoverflow.com/questions/32616959/winhttprequest-timeouts
	{
		For eachKey, Line in StrSplit(err.Message, "`n", "`r")
		{
		Results := InStr(Line, "Description:") ? StrReplace(Line, "Description:") : ""
		Results := Trim(Results)
		if (Results <> "")
		Break
		}
	
	IniRead, strTemp, % PrgLnch.SelIniChoicePath, General, PrgVersionError
		if (!strTemp)
		{
		retVal := TaskDialog("Prg Url", "Problem with Prg version info", "","""" . Results . """" . " and " . """" . "version.txt" . """" . " not found at `n" . """" . verLoctmp . """" . "`nIf no URL displayed, it's a timing issue or a temporary error", , "Continue")
			if (retVal < 0)
			IniWrite, %retVal%, % PrgLnch.SelIniChoicePath, General, PrgVersionError
		}

	return 1
	}

	return 0
}

PrgURLGui(ByRef PrgUrl, ByRef PrgUrlTest, SelPrgChoice, NoSaveURL := 0)
{
	GuiControl, PrgLnchOpt:, newVerPrg
	PrgUrlTest := ""
	if (NoSaveURL)
	{
	ToolTip
	GuiControl, PrgLnchOpt:, UpdtPrgLnch, % "&Update Prg"
		if (NoSaveURL == 1)
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
	CreateToolTip("Type to modify, Del to remove, or click " . """" . "Save URL" . """" . " to save URL.")
	GuiControl, PrgLnchOpt: Enable, UpdtPrgLnch
	GuiControlGet, PrgUrlTest, PrgLnchOpt:, UpdturlPrgLnch
	}
}

































;Misc functions
SetEditCueBanner(HWND, Cue, IsCombo := 0)
{
; requires AHL_L: JustMe
Static EM_SETCUEBANNER := (0x1500 + 1)
Static CB_SETCUEBANNER := (0x1700 + 3)
if (IsCombo)
return DllCall("User32.dll\SendMessageW", "Ptr", HWND, "Uint", CB_SETCUEBANNER, "Ptr", True, "WStr", Cue)
else
return DllCall("User32.dll\SendMessageW", "Ptr", HWND, "Uint", EM_SETCUEBANNER, "Ptr", True, "WStr", Cue)
}

MakeLong(LoWord, HiWord) ; courtesy Chris
{
return (HiWord << 16) | (LoWord & 0xffff)
}

DcmpExecutable(selPrgChoice, PrgChoicePaths, PrgLnkInf, PrgResolveShortcut, IniFileShortctSep, checkSubSys := 0)
{
sizeOfOptionalHeader := 0, e_lfanew := 0, e_magic := 0, ntHeaders32 := 0, temp := 0, IsaPrgLnk := 0

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

if (!(exeStr := ExtractPrgPath(selPrgChoice, PrgChoicePaths, 0, PrgLnkInf, PrgResolveShortcut, IniFileShortctSep, IsaPrgLnk)))
return

	if (!fileExist(exeStr) || InStr(exeStr, "BadPath", True, 1, 7) || (!PrgResolveShortcut[selPrgChoice] && (IsaPrgLnk == 1)) || (IsaPrgLnk == -1) || (IsRealExecutable(exeStr) == -1))
	return
	else
	exeStr := AssocQueryApp(exeStr)

exeStrOld := exeStr
SplitPath, exeStrOld, exeStrName

;FileOpen returns an object
exeStr := FileOpen(exeStr, "rw" "-rwd")


if (IsObject(exeStr))
{

; Verify EXE signature or "MZ"
e_magic := SeekProc(exeStr, 0, "ushort", 0)

if (e_magic == IMAGE_DOS_SIGNATURE)
	{
	; Next is the stub "This program cannot be run in DOS mode." This takes us up to offset PE_HEADER_OFFSET
	; Get offset to pointer of IMAGE_NT_HEADERS struct: This is okay for either 32 or 64bit builds
	e_lfanew := SeekProc(exeStr, PE_HEADER_OFFSET_ADDRESS, "int", 0)
	; Verify NT header:
	ntHeaders32 := SeekProc(exeStr, e_lfanew, "uint", 0)

		if (ntHeaders32 == IMAGE_NT_HEADERS32)
		{
			if (checkSubSys)
			{
			; sizeOfOptionalHeader is in IMAGE_FILE_HEADER
			sizeOfOptionalHeader := SeekProc(exeStr, e_lfanew + 20, "ushort", "check")
			OptHeaderMagicNo := SeekProc(exeStr, e_lfanew + IMAGE_FILE_HEADER_SIZE, "Ushort", "check")
			
				if (OptHeaderMagicNo == 0x10b)
				optHeader_Magic := "PE32"
				else
				{
					if (OptHeaderMagicNo == 0x20B)
					optHeader_Magic := "PE32+"
					else
					optHeader_Magic := "ROMIMAGE"
				}
			temp := SeekProc(exeStr, e_lfanew + IMAGE_FILE_HEADER_SIZE + 68, "ushort", "check")

				if (temp == IMAGE_SUBSYSTEM_WINDOWS_GUI || temp == IMAGE_SUBSYSTEM_WINDOWS_CUI)
				temp := 1
				else
				temp := 0
			exeStr.Close()
			return temp
			}

			else
			{
			; LAA offset is e_lfanew + 0x12 or 18		
			lAA := SeekProc(exeStr, e_lfanew + CHARACTERISTICS_OFFSET + 4, "ushort", "check")

			GuiControlGet, labPrgLAA, PrgLnchOpt:, PrgLAA

				if (labPrgLAA == "Remove LAA Flag")
				{
				;Toggle flag off
				lAA := lAA & ~IMAGE_FILE_LARGE_ADDRESS_AWARE

				if (SeekProc(exeStr, e_lfanew + CHARACTERISTICS_OFFSET + 4, "ushort", lAA))
					{
					MsgBox, 8192, LAA FLAG, LAA Flag Removed
					GuiControl, PrgLnchOpt:, PrgLAA, Apply LAA Flag
					}
				else
					MsgBox, 8192, LAA FLAG, % "Unable to remove LAA Flag. Is " exeStrName " opened in an editor?"
				}
				else
				{

				;lAA := lAA | IMAGE_FILE_LARGE_ADDRESS_AWARE

				if (lAA & IMAGE_FILE_LARGE_ADDRESS_AWARE)
				MsgBox, 8192, LAA FLAG, %  exeStrName " already has the LAA patch!"
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
					MsgBox, 8192, LAA FLAG, LAA Flag Written
					GuiControl, PrgLnchOpt:, PrgLAA, Remove LAA Flag
					}
				else
					MsgBox, 8192, LAA FLAG, % "Unable to write LAA Flag. Is " exeStrName " opened in an editor?"
				}
				else
				MsgBox, 8192, LAA FLAG, %  exeStrName "`n`nUnexpected data in Characteristics field. LAA flag cannot not be written!"
				}
				}

			}
		}
		else
		{
		MsgBox, 8192, LAA FLAG, %  exeStrName "`n`nBad exe file: no NT Headers"
		}

	}
	else
	{
		if (e_magic == IMAGE_DOS_SIGNATURE_BIG_ENDIAN)
		MsgBox, 8192, LAA FLAG, %  exeStrName "`n`nNo can do! This executable runs on a Big_Endian system!"
		else
		{
		MsgBox, 8192, LAA FLAG, %  exeStrName "`n`nBad exe file: no DOS sig."
		;creates empty file if non-existent: Already checked above!
		exeStr.Close()
		FileGetSize temp, %exeStrName%
		sleep 20
			if (!temp && FileExist(exeStrName))
			FileDelete, %exeStrName%
		return 0
		}
	}
	exeStr.Close()
}
else
{
	if (!checkSubSys || (checkSubSys && !Instr(exeStrOld, A_WinDir) && !Instr(PrgChoicePaths[selPrgChoice], A_WinDir)))
	{
	IniRead, fTemp, % PrgLnch.SelIniChoicePath, General, DcmpExecutableWrn
		if (fTemp = "ERROR")
		{
		; Versioning:  IniSpaceCleaner moves this before ResMode
		IniWrite, %A_Space%, % PrgLnch.SelIniChoicePath, General, DcmpExecutableWrn
		fTemp := 0
		}

		if (!fTemp)
		{
			if (A_IsAdmin)
			retVal := TaskDialog("Decompile Executable", "Problem opening the Prg file", ,"While seeking information from the file headers, the Prg`n" . """" . exeStrName . """" . "`ncould not be accessed with error " . A_LastError . ".`nIs it opened by another process, or is it located in a protected location?`nEven though it is possible for the Prg to be launched and monitored,`nthere may be other situations where PrgLnch is unable to use the Prg.", , "Continue")
			else
			retVal := TaskDialog("Decompile Executable", "Problem opening the Prg file", ,"While seeking information from the file headers, the Prg`n" . """" . exeStrName . """" . "`ncould not be accessed with error " . A_LastError . ".`nIs it opened by another process, or does it have special permissions?`nEven though it is possible for the Prg to be launched and monitored,`nthere may be other issues if PrgLnch is not run as elevated Admin.", "Do not show again (No restart as Admin)", "Do not restart PrgLnch", "Restart PrgLnch as Admin")

			if (retVal < 0)
			{
			IniWrite, 1, % PrgLnch.SelIniChoicePath, General, DcmpExecutableWrn
			retVal := -retVal
			}

			if (retVal == 2)
			RestartPrgLnch(1)
		}
	}
	else
	return 1 ;Optimistically
}
return 0
}
; SeekProc: Seek to absolute offset and read a number of the specified type.
SeekProc(stream, offset, type, action)
{
retVal := 0
stream.Seek(offset)
VarSetCapacity(v,8)

if (action == "check")
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
	MsgBox, 8192, SeekProc, % " Read failed"
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

SplashyProc(type, action := 0, mainText := "", subText := "")
{
Static SplashRef := Splashy.SplashImg
static loadW := 0, loadH := 0, propW := 0, propH := 0
vImgW := 0
vImgH := 0
vPosX := "C"
vPosY := "C"
instance := 0



	switch type
	{
		case "*Release":
		{
		if (action)
		%SplashRef%(Splashy, {InitSplash: 1}*)
		else
		%SplashRef%(Splashy, {release: 1}*)
		return
		}
		case "*Loading":
		{
			if (action)
			{
			vPosX := floor(PrgLnchOpt.X() + (PrgLnchOpt.Width() - loadW)/2)
			vPosY := floor(PrgLnchOpt.Y() + (PrgLnchOpt.Height() - loadH))
			}
		}
		case "*Launching":
		{
		; onTop?: too many issues
		}
		case "*LnchPadCfg":
		{
		}
		case "*Properties":
		{
			if (!propW)
			{
			%SplashRef%(Splashy, {imagePath: "*Properties", vHide : 1}*)
			propW := Splashy.vImgW
			propH := Splashy.vImgH
			}
		vPosX := PrgLnch.X() + (PrgLnch.Width() - propW)/2
		vPosY := Abs(PrgLnch.Y() - propH)
		}
		default:
		{
		instance := (action > 0)? action + 1: action - 1
			if (instance < 0)
			{
			%SplashRef%(Splashy, {imagePath: "*", instance: -instance, mainText: "", subText: "", mainFontSize: 10, subFontSize: 10, vOnTop: 0, vImgW : vImgW, vImgH : vImgH}*)
			%SplashRef%(Splashy, {imagePath: "*", instance: instance}*)
			return
			}
			else
			%SplashRef%(Splashy, {imagePath: "*", vHide : 1, instance: instance, mainText: mainText, subText: subText, mainFontSize: 100, subFontSize: 30, vOnTop: 1}*)

		vImgW := A_ScreenWidth/4
		vImgH := A_ScreenHeight/3	
		}
	}

%SplashRef%(Splashy, {imagePath: type, vHide : 0, instance: instance, vPosX : vPosX, vPosY : vPosY, vImgW : vImgW, vImgH : vImgH}*)

	if (!loadW)
	{
	loadW := Splashy.vImgW
	loadH := Splashy.vImgH
	}
}

WinMover(Hwnd := 0, position := "hc vc", Width := 0, Height := 0, wdRatio := 1, htRatio := 1)
{
 x := 0, y := 0, ix:= 0, iy := 0, w := 0, h:= 0

; wdRatio, htRatio not used


	SysGet, mt, MonitorWorkArea, % PrgLnch.Monitor
	oldDHW := A_DetectHiddenWindows
	DetectHiddenWindows, On

	strTemp := A_CoordModeMouse
	CoordMode, Mouse, Screen

	if (Width && Hwnd)
	WinMove, ahk_id %Hwnd%,,,, %Width%, %Height%
	;by Learning one
	; position: l=left, hc=horizontal center, r=right, u=up, vc= vertical center, d=down, b=bottom (same as down)

	WinGetPos,ix,iy,w,h, ahk_id %Hwnd%

	position := StrReplace(position, "b", "d") ;b=bottom (same as down)
	x := InStr(position,"l")? mtLeft: InStr(position,"hc")? (mtLeft + (mtRight-mtLeft-w)/2): InStr(position,"r") ? mtRight - w: ix
	y := InStr(position,"u")? mtTop: InStr(position,"vc")? (mtTop + (mtBottom-mtTop-h)/2): InStr(position,"d") ? mtBottom - h: iy


	WinMove, ahk_id %Hwnd%,, wdRatio * x, htRatio * y

	CoordMode, Mouse, % strTemp
	DetectHiddenWindows, %oldDHW%

}

; Enables controls as per prg/monitor specs.
TogglePrgOptCtrls(txtPrgChoice, ResShortcut, iDevNum, iDevNumArray, targMonitorNum, borderToggle := 0, selPrgChoice := 0, PrgChgResOnClose := 0, PrgChgResOnSwitch := 0, PrgChoicePaths := 0, PrgLnkInf := 0, PrgRnMinMax := -1, PrgRnPriority := -1, PrgBordless := 0, PrgLnchHide := 0, CtrlsOn := 0)
{

ctlEnable := (LNKFlag(PrgLnkInf[selPrgChoice]) == -1)? "Disable": "Enable"

GuiControl, PrgLnchOpt:, Monitors, % PrglnchOpt.GetDispMonNamesVal(targMonitorNum)
			
	; adapter name
	;PrglnchOpt.GetDispAdapterNamesVa(targMonitorNum)

	if (iDevNumArray[targMonitorNum] < 10) ;dec masks
	{
	CtrlsOn := 0
	GuiControl, PrgLnchOpt: Disable, RnPrgLnch
	GuiControl, PrgLnchOpt: Disable, currRes
	Gui, PrgLnchOpt: Font, cGrey Bold, Verdana
	}
	else
	{
	GuiControl, PrgLnchOpt: Enable, RnPrgLnch
		if (MDMF_GetMonStatus(targMonitorNum))
		GuiControl, PrgLnchOpt: Enable, currRes
		else
		GuiControl, PrgLnchOpt: Disabled, currRes


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


if (CtrlsOn)
{
	if (InStr(PrgChoicePaths[selPrgChoice], ".lnk", false, strLen(PrgChoicePaths[selPrgChoice]) - 5))
	{
	GuiControl, PrgLnchOpt:, ChgResOnClose, 0
	GuiControl, PrgLnchOpt: Disable, ChgResOnClose
	GuiControl, PrgLnchOpt:, ChgResOnSwitch, 0
	GuiControl, PrgLnchOpt: Disable, ChgResOnSwitch
	GuiControl, PrgLnchOpt: Disable, ResIndex
	GuiControl, PrgLnchOpt: Disable, allModes
	}
	else
	{
	GuiControl, PrgLnchOpt: Enable, ChgResOnClose
	GuiControl, PrgLnchOpt: Enable, ChgResOnSwitch
	GuiControl, PrgLnchOpt:, ChgResOnClose, % PrgChgResOnClose[selPrgChoice]
	GuiControl, PrgLnchOpt:, ChgResOnSwitch, % PrgChgResOnSwitch[selPrgChoice]
	GuiControl, PrgLnchOpt: Enable, ResIndex
	GuiControl, PrgLnchOpt: Enable, allModes
	}

	GuiControl, PrgLnchOpt:, PrgMinMax, % PrgRnMinMax[selPrgChoice]
	GuiControl, PrgLnchOpt: Enable, PrgPriority
	GuiControl, PrgLnchOpt:, PrgPriority, % PrgRnPriority[selPrgChoice]
	GuiControl, PrgLnchOpt: Text, Bordless, Ext. Borderless
		if (borderToggle)
		{
		GuiControl, PrgLnchOpt: Enable, Bordless
		GuiControl, PrgLnchOpt:, Bordless, % PrgBordless[selPrgChoice]
		}
		else
		{
		GuiControl, PrgLnchOpt:, Bordless, 0
		GuiControl, PrgLnchOpt: Disable, Bordless
		}
		
	GuiControl, PrgLnchOpt: Enable, PrgLnchHd
	GuiControl, PrgLnchOpt:, PrgLnchHd, % PrgLnchHide[selPrgChoice]

	GuiControl, PrgLnchOpt: %ctlEnable%, PrgLAA
	GuiControl, PrgLnchOpt: %ctlEnable%, PrgMinMax ; MinMax disabled for all dir/invalid/symbolic links

}
else
{
		; Case of "just in case"
		if (txtPrgChoice != "None")
		GuiControl, PrgLnchOpt: Disable, RnPrgLnch

		if (iDevNumArray[targMonitorNum] < 10) ;dec masks
		{
		GuiControl, PrgLnchOpt: Disable, ResIndex
		GuiControl, PrgLnchOpt: Disable, allModes
		}
		else
		{
		GuiControl, PrgLnchOpt: Enable, ResIndex
		GuiControl, PrgLnchOpt: Enable, allModes
		}
	
	GuiControl, PrgLnchOpt: Disable, CmdLinPrm
	GuiControl, PrgLnchOpt:, CmdLinPrm
	GuiControl, PrgLnchOpt:, ChgResOnClose, 0
	GuiControl, PrgLnchOpt: Disable, ChgResOnClose
	GuiControl, PrgLnchOpt:, ChgResOnSwitch, 0
	GuiControl, PrgLnchOpt: Disable, ChgResOnSwitch
	GuiControl, PrgLnchOpt:, PrgMinMax, -1
	GuiControl, PrgLnchOpt: Disable, PrgMinMax
	GuiControl, PrgLnchOpt:, PrgPriority, -1
	GuiControl, PrgLnchOpt: Disable, PrgPriority
	GuiControl, PrgLnchOpt:, Bordless, 0
	GuiControl, PrgLnchOpt: Disable, Bordless
	GuiControl, PrgLnchOpt:, PrgLnchHd, 0
	GuiControl, PrgLnchOpt: Disable, PrgLnchHd
		if (txtPrgChoice == "None")
		GuiControl, PrgLnchOpt: Disable, resolveShortct
		else
		GuiControl, PrgLnchOpt: Enable, resolveShortct
	GuiControl, PrgLnchOpt:, resolveShortct, % ResShortcut
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
GuiControl, PrgLnchOpt: Hide, Allmodes
GuiControl, PrgLnchOpt: Hide, ResIndex
GuiControl, PrgLnchOpt: Hide, RnPrgLnch
GuiControl, PrgLnchOpt: Hide, CmdLinPrm
GuiControl, PrgLnchOpt: Hide, UpdturlPrgLnch
GuiControl, PrgLnchOpt: Hide, Quit_PrgLnch
GuiControl, PrgLnchOpt: Hide, PrgMinMax
GuiControl, PrgLnchOpt: Hide, PrgLnchHd
GuiControl, PrgLnchOpt: Hide, Bordless
GuiControl, PrgLnchOpt: Hide, PrgPriority
GuiControl, PrgLnchOpt: Hide, ChgResOnClose
GuiControl, PrgLnchOpt: Hide, ChgResOnSwitch
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
GuiControl, PrgLnchOpt: Show, Allmodes
GuiControl, PrgLnchOpt: Show, ResIndex
GuiControl, PrgLnchOpt: Show, RnPrgLnch
GuiControl, PrgLnchOpt: Show, CmdLinPrm
GuiControl, PrgLnchOpt: Show, UpdturlPrgLnch
GuiControl, PrgLnchOpt: Show, Quit_PrgLnch
GuiControl, PrgLnchOpt: Show, PrgMinMax
GuiControl, PrgLnchOpt: Show, PrgLnchHd
GuiControl, PrgLnchOpt: Show, Bordless
GuiControl, PrgLnchOpt: show, PrgPriority
GuiControl, PrgLnchOpt: show, ChgResOnClose
GuiControl, PrgLnchOpt: show, ChgResOnSwitch
GuiControl, PrgLnchOpt: Show, resolveShortct
GuiControl, PrgLnchOpt: Show, PrgLAA

}

}



IniProc(selPrgChoice := 0, removeRec := 0)
{

Local iDevNumArrayIn := [0, 0, 0, 0, 0, 0, 0, 0, 0], foundPosOld := 0, recCount := -1, sectCount := 0, c := 0, p := 0, s := 0, k := 0, spr := "", reWriteIni := 0, FileExistSelIniChoicePath := FileExist(PrgLnch.SelIniChoicePath)

; Local implies  or assumes global function

IniProcStart:


	if (!FileExistSelIniChoicePath)
	{
	IniWrite, % (reWriteini)? 1: 0, % PrgLnch.SelIniChoicePath, General, Disclaimer
	IniWrite, %A_Space%, % PrgLnch.SelIniChoicePath, General, DefResMsg
	IniWrite, %A_Space%, % PrgLnch.SelIniChoicePath, General, PrgAlreadyMsg
	IniWrite, %A_Space%, % PrgLnch.SelIniChoicePath, General, ClosePrgWarn
	IniWrite, %A_Space%, % PrgLnch.SelIniChoicePath, General, ResClashMsg
	IniWrite, %A_Space%, % PrgLnch.SelIniChoicePath, General, WinRtDirWrn
	IniWrite, %A_Space%, % PrgLnch.SelIniChoicePath, General, LnchPrgMonWarn
	IniWrite, %A_Space%, % PrgLnch.SelIniChoicePath, General, LoseGuiChangeResWrn
	IniWrite, %A_Space%, % PrgLnch.SelIniChoicePath, General, PrgAlreadyLaunchedMsg
	IniWrite, %A_Space%, % PrgLnch.SelIniChoicePath, General, ChangeShortcutMsg
	IniWrite, %A_Space%, % PrgLnch.SelIniChoicePath, General, PrgLaunchAfterDL
	IniWrite, %A_Space%, % PrgLnch.SelIniChoicePath, General, PrgCleanOnExit
	IniWrite, %A_Space%, % PrgLnch.SelIniChoicePath, General, CheckDefMissingMsg
	IniWrite, %A_Space%, % PrgLnch.SelIniChoicePath, General, DcmpExecutableWrn
	IniWrite, %A_Space%, % PrgLnch.SelIniChoicePath, General, MonProbMsg
	IniWrite, %A_Space%, % PrgLnch.SelIniChoicePath, General, MonitorNames
	IniWrite, %A_Space%, % PrgLnch.SelIniChoicePath, General, MonitorOrder

	; % PrgLnch.SelIniChoicePath as long as the current directory isn't changed while this loads

	spr := "0,0,0,1"
	IniWrite, %spr%, % PrgLnch.SelIniChoicePath, General, ResMode
	IniWrite, %A_Space%, % PrgLnch.SelIniChoicePath, General, UseReg
	IniWrite, %A_Space%, % PrgLnch.SelIniChoicePath, General, ResShortcut
 	IniWrite, %A_Space%, % PrgLnch.SelIniChoicePath, General, WarnAlreadyRunning
	IniWrite, %A_Space%, % PrgLnch.SelIniChoicePath, General, OnlyOneMonitor
	IniWrite, %A_Space%, % PrgLnch.SelIniChoicePath, General, DefPresetSettings
	IniWrite, %A_Space%, % PrgLnch.SelIniChoicePath, General, PrgVersionError


	IniWrite, %SelIniChoiceName%, %PrgLnchIni%, General, SelIniChoiceName

	WriteIniChoiceNames(IniChoiceNames, PrgNo, strIniChoice, PrgLnchIni)

	IniWrite, % (defPrgStrng)? defPrgStrng: None, % PrgLnch.SelIniChoicePath, Prgs, StartupPrgName


	IniWrite, %A_Space%, % PrgLnch.SelIniChoicePath, Prgs, PrgMon

	IniWrite, % (PrgBatchIniStartup)? PrgBatchIniStartup: A_Space, % PrgLnch.SelIniChoicePath, Prgs, PrgBatchIniStartup
	IniWrite, % (PrgTermExit)? PrgTermExit: A_Space, % PrgLnch.SelIniChoicePath, Prgs, PrgTermExit
	IniWrite, % (PrgIntervalLnch)? PrgIntervalLnch: A_Space, % PrgLnch.SelIniChoicePath, Prgs, PrgInterval

	spr := join(PresetNames)
	spr := (spr)? spr: %A_Space%
	
	IniWrite, %spr%, % PrgLnch.SelIniChoicePath, Prgs, PresetNames

		Loop % maxBatchPrgs
		{
			spr := join(PrgBatchIni%A_Index%)
			spr := (spr)? spr: %A_Space%
			IniWrite, %spr%, % PrgLnch.SelIniChoicePath, Prgs, PrgBatchIni%A_Index%
		}


		spr := join(btchPowerNames)
		spr := (spr)? spr: %A_Space%
		IniWrite, %spr%, % PrgLnch.SelIniChoicePath, Prgs, BatchPowerNames




		loop % PrgNo
		{
		;PrgChoiceNames.push([0])

		if (!reWriteini)
		strPrgChoice .= "Prg" . A_Index . "|"

		IniWrite, % (PrgChoiceNames[A_Index])? PrgChoiceNames[A_Index]: A_Space, % PrgLnch.SelIniChoicePath, Prg%A_Index%, PrgName
		;for  each PrgChoicePaths[%A_Index%]
		if (reWriteini)
		{
			if (spr := PrgChoicePaths[A_Index])
			{
				if (InStr(spr, ".lnk", False, StrLen(spr) - 4) && (!InStr(spr, IniFileShortctSep)))
					{
					;Append resolved path
					strRetVal := GetPrgLnkVal(spr, IniFileShortctSep)
						if (LNKFlag(strRetVal) > 0)
						PrgChoicePaths[A_Index] .= IniFileShortctSep . strRetVal
					}
			}
		}
		IniWrite, % (PrgChoicePaths[A_Index])? PrgChoicePaths[A_Index]: A_Space, % PrgLnch.SelIniChoicePath, Prg%A_Index%, PrgPath

		IniWrite, % (PrgCmdLine[A_Index])? PrgCmdLine[A_Index]: A_Space, % PrgLnch.SelIniChoicePath, Prg%A_Index%, PrgCmdLine
		IniWrite, %A_Space%, % PrgLnch.SelIniChoicePath, Prg%A_Index%, PrgRes
		IniWrite, % (PrgUrl[A_Index])? PrgUrl[A_Index]: A_Space, % PrgLnch.SelIniChoicePath, Prg%A_Index%, PrgUrl
		IniWrite, % (PrgVer[A_Index])? PrgVer[A_Index]: A_Space, % PrgLnch.SelIniChoicePath, Prg%A_Index%, PrgVer
		if (reWriteini)
		{
		/*
		; This is the ver 1.X order (forget it)
		PrgLnchHide[A_Index] := PrgMonToRn[A_Index]
		PrgMonToRn[A_Index] := (PrgChgResOnSwitch[A_Index])? PrgChgResOnSwitch[A_Index]: 1
		PrgChgResOnSwitch[A_Index] := PrgBordless[A_Index]
		PrgBordless[A_Index] := PrgRnMinMax[A_Index]
		PrgRnMinMax[A_Index] := -1
		*/
		PrgChgResOnClose[A_Index] := PrgChgResOnSwitch[A_Index]
		PrgChgResOnSwitch[A_Index] := PrgBordless[A_Index]
		PrgBordless[A_Index] := PrgRnMinMax[A_Index]
		PrgRnMinMax[A_Index] := -1


		spr := PrgMonToRn[A_Index] . "," . PrgChgResOnClose[A_Index] . "," . PrgChgResOnSwitch[A_Index] . ",-1," . PrgRnPriority[A_Index] . "," . PrgBordless[A_Index] . "," . PrgLnchHide[A_Index] . ",0"

		IniWrite, % spr, % PrgLnch.SelIniChoicePath, Prg%A_Index%, PrgMisc

		StoreFetchPrgRes(1, A_Index, PrgLnkInf, targMonitorNum)

		spr := % PrgLnchOpt.scrWidth . "," . PrgLnchOpt.scrHeight . "," . PrgLnchOpt.scrFreq . "," 0

		IniWrite, %spr%, % PrgLnch.SelIniChoicePath, Prg%A_Index%, PrgRes


		IniProcIniFile(0, SelIniChoiceName, IniChoiceNames, PrgNo, strIniChoice)
		}
		else
		IniWrite, %A_Space%, % PrgLnch.SelIniChoicePath, Prg%A_Index%, PrgMisc

		}
	reWriteIni := 0
	}
	; Ini file exists
	; **********************************************************************************************************************************************
	else
	{

	FileRead, s, % PrgLnch.SelIniChoicePath

		if (ErrorLevel)
		{
		MsgBox, 8208, Ini File, Critical error reading file! `nSpecifically: %A_LastError% `nLoading defaults...
		FileExistSelIniChoicePath := 0
		goto IniProcStart
		}
	
	Loop, Parse, s, `n`r, %A_Space%%A_Tab%
	{

	c := SubStr(A_LoopField, 1, 1)
	if (c == "[")
		{
			sectCount := 0
			k := SubStr(A_LoopField, 1)
			spr := SubStr(k, 2, 3)
				if (spr == "Prg")
				recCount := recCount + 1
				else	;Process  General section
				Continue ;Just in case any new sub nodes
		}
		else 
		{
			if (c == ";" || c == "*/") ;comments
			Continue
			if (c == "/*")
			{
			MsgBox, 8192, Ini file read, % "Can't handle " c " if not eof!"
			return -1
			}


			if (p := InStr(A_LoopField, "="))
			{
			k := SubStr(A_LoopField, p + 1)
			sectCount := sectCount + 1
				if (recCount < 0) ;General section
				{
					switch (sectCount)
					{
						case 18: ; ResMode
						{
							if (selPrgChoice)
							{
							PrgLnchOpt.TestMode := Test
							PrgLnchOpt.Fmode := Fmode
							PrgLnchOpt.DynamicMode := Dynamic
							PrgLnchOpt.TmpMode := Tmp
							spr := Test ? Test : Fmode? Fmode: Dynamic? Dynamic: Tmp
								if (Test == 1)
								spr := spr . ",0,0,0"
								else
								{
									if (FMode == 1)
									spr := "0," . spr . ",0,0"
									else
									{
										if (Dynamic == 1)
										spr := "0,0," . spr . ",0"
										else
										spr := "0,0,0," . spr
									}
								}
							IniWrite, %spr%, % PrgLnch.SelIniChoicePath, General, ResMode
							}
							else
							{
								if (k)
								{
									if (InStr(k, ","))
									{
									PrgLnchOpt.TestMode := Test := SubStr(k, 1, 1)
									PrgLnchOpt.Fmode := FMode := SubStr(k, 3, 1)
									PrgLnchOpt.DynamicMode := Dynamic := SubStr(k, 5, 1)
									PrgLnchOpt.TmpMode := Tmp := SubStr(k, 7)
									}
									else
									MsgBox, 8208, Ini File, Error reading Resmode in file! `nTry restarting PrgLnch.
								}
							}
					
						}
						case 19: ; UseReg
						{
							if (selPrgChoice)
							IniWrite, % PrgLnch.regoVar, % PrgLnch.SelIniChoicePath, General, UseReg
							else
							{
							;spr := SubStr(A_LoopField, 2, -1)
							;if (spr == "UseReg")
							;{
								if (k)
								PrgLnch.regoVar := k
							;}
							;else
							}
						}
						case 20: ; ResShortcut
						{
							if (selPrgChoice)
							IniWrite, %ResShortcut%, % PrgLnch.SelIniChoicePath, General, ResShortcut
							else
							{
								if (k)
								ResShortcut := k
							}
						}
						default:
						Continue
						; section 21- ...26+ : read "on the fly"
					}
				}
				else
				{
				if (recCount == 0) ;Prgs section
				{
					switch (sectCount)
					{
					case 1:
					{
					;strPrgChoice := % "|None|" ;why was this in?
						if (!selPrgChoice)
						{
							if (k)
							IniRead, defPrgStrng , % PrgLnch.SelIniChoicePath, Prgs, StartupPrgName, %A_Space% ;Space just in case None is absent
						}

					}
					case 2:
					{
						if (selPrgChoice)
						{
							if (selPrgChoice == 100) ;write record at init
							{
							spr := ""
							temp := PrgLnchOpt.dispMonNamesNo
								loop % temp - 1
								spr .= iDevNumArray[A_Index] . ","

							spr .= iDevNumArray[temp]

							IniWrite, %spr%, % PrgLnch.SelIniChoicePath, Prgs, PrgMon
							}

						}
						else  ;reading entire file
						{
							temp := 0
							if (k)
							{
								Loop, parse, k, CSV , %A_Space%%A_Tab%
								{
								iDevNumArrayIn[A_Index] := A_Loopfield
								temp++
								}

								if (iDevNumArrayIn[1])
								{
									if (temp == PrgLnchOpt.dispMonNamesNo)
									{
										loop % temp
										{
											if (iDevNumArray[A_Index] != iDevNumArrayIn[A_Index])
											{
											retVal := TaskDialog("Monitor configuration", "Informational: The current monitor config`ndiffers to the one read from the ini file", , "This usually occurs after monitors have been added or removed`,`nor the existing PrgLnch ini file has been generated on another device.`nThis is only an issue if the existing ini file is not to be overwritten.", "", "Continue to write the new configuration", "Quit Prglnch")
												if (retVal == 1)
												Break
												else
												{
												KleenupPrgLnchFiles()
												ExitApp
												}
											}
										}
									}
									else
									{
									retVal := TaskDialog("Monitor configuration", "Informational: The current monitor config`ndiffers to the one read from the ini file", , "This usually occurs after monitors have been added or removed`,`nor the existing PrgLnch ini file has been generated on another device.`nThis is only an issue if the existing ini file is not to be overwritten.", "", "Continue to write the new configuration", "Quit Prglnch")
										if (retVal == 2)
										{
										KleenupPrgLnchFiles()
										ExitApp
										}
									}
								}
								else ;  cannot handle old ini files
								{
									if (k < 111) ; 111 is case when driver is uninstalled and only one monitor!
									{
									sectCount -= 1
									reWriteIni := 1
									Continue
									}
									else
									{
									IniRead, foundpos, % PrgLnch.SelIniChoicePath, General, OnlyOneMonitor
										if (!foundpos)
										{
										retVal := TaskDialog("Monitor configuration", "Reading Config: Only one logical monitor", , "Prglnch.ini reports at most one logical monitor attached!`nAssumed cause is driver removal, else corrupted ini file.`nInformational only- if driver has just been updated.", , "Continue loading Prglnch")
											if (retVal < 0)
											IniWrite, 1, % PrgLnch.SelIniChoicePath, General, OnlyOneMonitor
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
					case 3:
					{
						if (!inputOnceOnly)
						{
							if (k)
							PrgBatchIniStartup := k
						}
					}
					case 4:
					{
						if (!inputOnceOnly)
						{
							if (k)
							PrgTermExit := k
						}
					}
					case 5:
					{
						if (!inputOnceOnly)
						{
							if (k)
							PrgIntervalLnch := k
						}
					}
					case 6:
					{
						if (!inputOnceOnly)
						{
							Loop, parse, k, CSV , %A_Space%%A_Tab%
							{
							PresetNames[A_Index] := A_Loopfield
							}
						}
					}
					default:
					{
						if (sectCount < 13)
						{
							if (!inputOnceOnly)
							{
								if (k)
								{
								temp := sectCount - 6
									Loop, parse, k, CSV, %A_Space%%A_Tab%
									{
									PrgBatchIni%temp%[A_Index] := A_Loopfield
									}
								}
							}
						}
						else
						{
							if (!inputOnceOnly)
							{
								Loop, parse, k, CSV , %A_Space%%A_Tab%
								{
									if (A_Loopfield)
									btchPowerNames[A_Index] := A_Loopfield
								}
							inputOnceOnly := 1
							}
						
						}
					}
					}
				}
				else ; Prg Slots
				{
					switch (sectCount)
					{
					case 1:
					{
						if (selPrgChoice)
						{
							if (selPrgChoice == recCount) ;write record at selPrgChoice
							{
							spr := ""
								if (removeRec)
								{
								spr .= "Prg" . recCount
								IniWrite, %A_Space%, % PrgLnch.SelIniChoicePath, %spr%, PrgName
								}
								else
								{
								spr .= PrgChoiceNames[recCount]
								IniWrite, %spr%, % PrgLnch.SelIniChoicePath, Prg%recCount%, PrgName
								}
							foundPos := InStr(strPrgChoice, "|", false, 1, recCount + 1)
							spr := SubStr(strPrgChoice, 1, foundPos) . spr ;Bar is  to replace, not append  the  gui control string
							foundPos := InStr(strPrgChoice, "|", false, foundPos + 1)
							strPrgChoice := spr . SubStr(strPrgChoice, foundPos)
							}
						}
						else ;reading entire file
						{
						if (k)
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
					case 2:
					{
						if (selPrgChoice)
						{
							if (selPrgChoice == recCount) ;write record at selPrgChoice
							{
								if (removeRec)
								IniWrite, %A_Space%, % PrgLnch.SelIniChoicePath, Prg%recCount%, PrgPath
								else
								{
								spr := PrgChoicePaths[recCount]
								IniWrite, %spr%, % PrgLnch.SelIniChoicePath, Prg%recCount%, PrgPath
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
					case 3:
					{
						if (selPrgChoice)
						{
							if (selPrgChoice == recCount)
							{
								if (removeRec)
								IniWrite, %A_Space%, % PrgLnch.SelIniChoicePath, Prg%recCount%, PrgCmdLine
								else
								{
									if (PrgCmdLine[selPrgChoice])
									IniWrite, % PrgCmdLine[selPrgChoice], % PrgLnch.SelIniChoicePath, Prg%recCount%, PrgCmdLine
									else
									IniWrite, %A_Space%, % PrgLnch.SelIniChoicePath, Prg%recCount%, PrgCmdLine
								}
							}
						}
						else
						{
							if (k)
							PrgCmdLine[reccount] := k
						}
					}
					case 4:
					{
						if (selPrgChoice)
						{
							if (selPrgChoice == recCount) ;write record at selPrgChoice
							{
								if (removeRec)
								{
								StoreFetchPrgRes(1, A_Index, PrgLnkInf, targMonitorNum, -1)
								IniWrite, %A_Space%, % PrgLnch.SelIniChoicePath, Prg%recCount%, PrgRes
								}
								else
								{
									if (PrgChoiceNames[recCount])
									{
									spr := PrgLnchOpt.scrWidth . "," . PrgLnchOpt.scrHeight . "," . PrgLnchOpt.scrFreq . "," . 0
									;extra 0 for interlace which might implement later
									IniWrite, %spr%, % PrgLnch.SelIniChoicePath, Prg%recCount%, PrgRes
									StoreFetchPrgRes(1, selPrgChoice, PrgLnkInf, targMonitorNum, 1)
									}
								}
							}
						}
						else  ;reading entire file
						{
							if (k)
							{ ; could have parsed (sigh)
								foundPos := InStr(k, ",", 1)
								PrgLnchOpt.scrWidth := SubStr(k, 1, foundPos - 1)
								spr := InStr(k, ",",,,2)
								PrgLnchOpt.scrHeight := SubStr(k, foundPos + 1, spr - foundPos - 1)
								foundPos := InStr(k, ",",,,3)
								PrgLnchOpt.scrFreq := SubStr(k, spr + 1 , foundPos - spr - 1)
								StoreFetchPrgRes(1, recCount, PrgLnkInf, targMonitorNum, 1)
							}
						}
					}
					case 5:
					{
						if (selPrgChoice)
						{
							if (selPrgChoice == recCount) ;write record at selPrgChoice
							{
								if (removeRec)
								IniWrite, %A_Space%, % PrgLnch.SelIniChoicePath, Prg%recCount%, PrgUrl
								else
								{
									if (PrgChoiceNames[recCount])
									IniWrite, % PrgUrl[recCount], % PrgLnch.SelIniChoicePath, Prg%recCount%, PrgUrl
								}
							}
						}
						else  ;reading entire file
						{
							if (k)
							PrgUrl[recCount] := k
						}
					}
					case 6:
					{
						if (selPrgChoice)
						{
							if (selPrgChoice == recCount) ;write record at selPrgChoice
							{
								if (removeRec)
								IniWrite, %A_Space%, % PrgLnch.SelIniChoicePath, Prg%recCount%, PrgVer
								else
								{
								if (PrgChoiceNames[recCount])
								IniWrite, % PrgVer[recCount], % PrgLnch.SelIniChoicePath, Prg%recCount%, PrgVer
								}
							}
						}
						else  ;reading entire file
						{
							if (k)
							PrgVer[recCount] := k
						}
					}
					case 7:
					;Various Prg settings
					{
						if (selPrgChoice)
						{
							if (selPrgChoice == recCount) ;write record at selPrgChoice
							{
								if (removeRec)
								IniWrite, %A_Space%, % PrgLnch.SelIniChoicePath, Prg%recCount%, PrgMisc
								else
								{
									if (PrgChoiceNames[recCount])
									{
									spr := PrgMonToRn[selPrgChoice]
									spr .= "," . PrgChgResOnClose[selPrgChoice]
									spr .= "," . PrgChgResOnSwitch[selPrgChoice]
									spr .= "," . PrgRnMinMax[selPrgChoice]
									spr .= "," . PrgRnPriority[selPrgChoice]
									spr .= "," . PrgBordless[selPrgChoice]
									spr .= "," . PrgLnchHide[selPrgChoice]
									spr .= "," . PrgResolveShortcut[selPrgChoice]
									IniWrite, %spr%, % PrgLnch.SelIniChoicePath, Prg%recCount%, PrgMisc
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
								switch (A_Index)
								{
								case 1:
								PrgMonToRn[recCount] := A_LoopField
								case 2:
								PrgChgResOnClose[recCount] := A_LoopField
								case 3:
								PrgChgResOnSwitch[recCount] := A_LoopField
								case 4:
								PrgRnMinMax[recCount] := A_LoopField
								case 5:
								PrgRnPriority[recCount] := A_LoopField
								case 6:
								PrgBordless[recCount] := A_LoopField
								case 7:
								PrgLnchHide[recCount] := A_LoopField
								case 8:
								PrgResolveShortcut[recCount] := A_LoopField
								}
							}
						}
					}
					}
					default: ; unexpected extras ignored
					}
				}

				}
			}
			else
			{
				if (A_LoopField) ; No equals character!
				{
				reWriteIni := DeleteIniFile("", 1)
					if (reWriteIni)
					{
						if (reWriteIni == 1)
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
			if (DeleteIniFile("", 2))
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

DeleteIniFile(iniFile, wrnPrompt := 0)
{
spr := 0
reWriteIni := 1
	if (wrnPrompt == 1)
	{
	retVal := TaskDialog("Ini file", "A PrgLnch ini file appears corrupted", , "", "", "Attempt reset to currently stored values (Recommended)", "Clear settings to their initial state", "Continue with errors")
		switch (retVal)
		{
		case 1:
		reWriteIni := 2
		case 2:
		reWriteIni := 1
		case 3:
		return reWriteIni
		}
	}
	else 
	{
		if (wrnPrompt == 2)
		{
		MsgBox, 8192, Ini File, Ini file will be converted to version 2.x.`nMost settings will be preserved.
		}
	}

	if (!iniFile)
	iniFile := PrgLnch.SelIniChoicePath

	Try
	{
	FileDelete %iniFile%
	sleep, 100
	}
	catch spr
	{
	reWriteIni := 0
	MsgBox, 8208, Ini File Delete, Critical error deleting file! `nSpecifically: %spr%
	}
return reWriteIni
}
IniSpaceCleaner(IniFile, oldVerChg := 0)
{
; https://autohotkey.com/boards/viewtopic.php?f=13&t=26556&p=124630#p124630
spr := "", strRetVal := "", temp := ""
Thread, NoTimers
try
{
	FileRead, strRetVal, %IniFile%
	if (oldVerChg)
	{
		if (InStr(strRetVal, "NavShortcut"))
		strRetVal := StrReplace(strRetVal, "NavShortcut", "ResShortcut")


		if (InStr(strRetVal, "LoseGuiChangeResWrn"))
		{
		temp := InStr(strRetVal, "`n[Prgs]")
		temp := SubStr(strRetVal, 1, temp - 1)
		temp := SubStr(temp, InStr(temp, "`n", 0, 0))
		; includes trailing "`n"
			if (InStr(temp, "MonitorNames"))
			{
				;first remove current MonitorNames
				strRetVal := StrReplace(strRetVal, temp, "")

				fTemp := InStr(strRetVal, "ResMode=") - 1
				temp .= "MonitorOrder= `n"
					if (!InStr(strRetVal, "MonProbMsg="))
					temp := "`nMonProbMsg=" . temp
					if (!InStr(strRetVal, "DcmpExecutableWrn="))
					temp := "`nDcmpExecutableWrn=" . temp
					if (!InStr(strRetVal, "CheckDefMissingMsg="))
					temp := "`nCheckDefMissingMsg=" . temp
					if (!InStr(strRetVal, "PrgCleanOnExit="))
					temp := "`nPrgCleanOnExit=" . temp

				fTemp := SubStr(strRetVal, 1, fTemp)

				fTemp := InStr(fTemp, "`n", 0, 0)
				; factor in the extra carriage return

				strRetVal := SubStr(strRetVal, 1, fTemp - 2) . temp . SubStr(strRetVal, fTemp + 1)
			}
			else
			{
				if (InStr(temp, ","))
				{
				temp := InStr(strRetVal, "`n[Prgs]")
				temp := SubStr(strRetVal, 1, temp - 1)
				; includes trailing "`n"
					if (!InStr(temp, "MonitorNames"))
					{
					temp := "MonitorNames= `nMonitorOrder= `n"
						if (!InStr(strRetVal, "MonProbMsg="))
						temp := "MonProbMsg= `n" . temp
						if (!InStr(strRetVal, "DcmpExecutableWrn="))
						temp := "DcmpExecutableWrn= `n" . temp
						if (!InStr(strRetVal, "CheckDefMissingMsg="))
						temp := "CheckDefMissingMsg= `n" . temp
						if (!InStr(strRetVal, "PrgCleanOnExit="))
						temp := "PrgCleanOnExit= `n" . temp
					temp := "`n" . temp
					fTemp := InStr(strRetVal, "ResMode=") - 1
					fTemp := SubStr(strRetVal, 1, fTemp)

					fTemp := InStr(fTemp, "`n", 0, 0)
					; factor in the extra carriage return

					strRetVal := SubStr(strRetVal, 1, fTemp - 2) . temp . SubStr(strRetVal, fTemp + 1)
					}
				}
				else
				{
				MsgBox, 8208, Ini File, Unknown problem with Resmode in the ini file!`nTry manually editing it, or delete it and start afresh.
				return
				}
			}
		}
		else ; Hope this is never reached!
		strRetVal := StrReplace(strRetVal, "ResMode=", "LoseGuiChangeResWrn= `nPrgAlreadyLaunchedMsg= `nChangeShortcutMsg= `nPrgLaunchAfterDL= `nPrgCleanOnExit= `nCheckDefMissingMsg= `nDcmpExecutableWrn= `nMonProbMsg= `nMonitorNames= `nResMode=")
	}
	else
	strRetVal := RegExReplace(strRetVal, "m) +$", " ") ;m multilineselect; " +" one or more spaces; $ only at EOL
	; Names & pathnames with more than one space are tested and not affected.

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
PopPrgProperties(currBatchNo, btchPrgPresetSel, PrgBatchInibtchPrgPresetSel, PrgChoiceNames, PrgChoicePaths, PrgLnkInf, PrgResolveShortcut, IniFileShortctSep)
{
IsaPrgLnk := 0, strTemp := "", fTemp := 0, temp := 0, foundpos := 0, batchPos := 0, pathCol := 0, pathColH := 0, pathColHOld := 0, defCol := 0, defColW := 0, defColH := 0, propY := 0, propW := 0, propH := 0, truncFileName := "", errorText := "", strRetVal := "", fileName := ""
static tabName := 0
x := PrgLnchOpt.X(), y := PrgLnch.Y(), w:= PrgLnchOpt.Width(), h := PrgLnch.Height()


	if (strRetVal := WorkingDirectory(A_ScriptDir, 1))
	MsgBox, 8192, PrgProperties, % strRetVal

SplashyProc("*Properties")


Gui, PrgProperties: Destroy

sleep, 120

Gui, PrgProperties: New,, Prg_Properties
Gui, PrgProperties: -MaximizeBox -MinimizeBox +OwnDialogs +HwndPrgPropertiesHwnd
; PrgProperties.Hwnd in this thread isn't valid while the form is hidden unofrtunately
PrgProperties.Hwnd := PrgPropertiesHwnd
Gui, PrgProperties: Color, FFFFCC


CLEARTYPE_QUALITY := 5

loop % currBatchNo
{
	batchPos := PrgBatchInibtchPrgPresetSel[A_Index]
	fileName := ExtractPrgPath(batchPos, PrgChoicePaths, 0, PrgLnkInf, PrgResolveShortcut, IniFileShortctSep, IsaPrgLnk)
	strTemp := PrgChoiceNames[batchPos]

	if (FileExist(fileName))
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
Gui, PrgProperties: Add, Tab3, vtabName -Theme -wrap AltSubmit, % strRetVal
;GuiControl, PrgProperties:, Move, tabName, w%w%

loop % currBatchNo
{
Gui, PrgProperties: Tab, %A_Index%


batchPos := PrgBatchInibtchPrgPresetSel[A_Index]
fileName := ExtractPrgPath(batchPos, PrgChoicePaths, 0, PrgLnkInf, PrgResolveShortcut, IniFileShortctSep, IsaPrgLnk)

if (FileExist(fileName))
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

		FileGetAttrib, strRetVal, % fileName
		if (A_LastError)
		{
		errorText .= "Problem with file size.`n"
		temp := 0
		}
		else
		{
		strTemp := ""
			loop, parse, strRetVal
			{
			Switch A_Loopfield
			{
			case "R":
			strTemp .= "Readonly"
			case "A":
			strTemp .= "Archive"
			case "S":
			strTemp .= "System"
			case "H":
			strTemp .= "Hidden"
			case "N":
			strTemp .= "Normal"
			case "D":
			strTemp .= "Directory"
			case "O":
			strTemp .= "Offline"
			case "C":
			strTemp .= "Compressed"
			case "T":
			strTemp .= "Temporary"
			}
			}
		}
	GuiControl, PrgProperties:, %sprHwnd%, `"%strTemp%`" attributes and %foundpos% kB filesize for the following Prg...
	GuiControl, PrgProperties: Move, %sprHwnd%, % "w" w/2


	temp := w
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



	temp := w/2 - defColW, fTemp := 16*defColH
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
		if (strRetVal == "GetFileVersionInfoSizeFail")
		errorText .= "Unable to retrieve extended information from the file.`n"
		else
		{

		temp := w/2 - defColW, fTemp := 16*defColH
		Gui, PrgProperties: Add, GroupBox, ys w%temp% h%fTemp%

		temp := w/2
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
		; `n req'd else text is clipped e.g. if (SubStr(errorText, StrLen(errorText) - 2) == "`n") errorText := SubStr(errorText, 1, StrLen(errorText) - 2)
		Gui, PrgProperties: Add, Text, w%w% xs+-%temp% HWNDsprHwnd, % errorText
		Gui, PrgProperties: Font, -Wrap q2 Italic cRed, Impact
		GuiControl, PrgProperties: Font, % sprHwnd
		Gui, PrgProperties: Font,
		}
}
}

Gui, PrgProperties: Font, CLEARTYPE_QUALITY
Gui, PrgProperties: Show, Hide


SysGet, mt, MonitorWorkArea, PrgLnch.Monitor

DetectHiddenWindows, On
WinGetPos,, propY,, propH, % "ahk_id" PrgPropertiesHwnd

	if (mtBottom - y > mtBottom - propH)
	WinMove, % "ahk_id" PrgPropertiesHwnd, , %x%, % propH - y, %w%
	else
	WinMove, % "ahk_id" PrgPropertiesHwnd, , %x%, % y - propH, %w%



	;For low screen res 
	if (propH + h > (mtBottom - mtTop))
	WinMove, % "ahk_id" PrgPropertiesHwnd, , , %mtBottom%, , % mtBottom - mtTop

DetectHiddenWindows, Off

SplashyProc("*Release")
Gui, PrgProperties: Show, , Prg Properties (Version 2.x)

}

PrgPropertiesClose()
{
	If (PrgProperties.Hwnd)
	{
	Gui, PrgProperties: Destroy
	PrgProperties.Hwnd := 0
	}
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
   If (CRC32 == "")
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
	return retVal 
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
Local temp := 0, strTemp := PrgPID . ",", strTemp2 := "", full_command_line := ""

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
full_command_line := DllCall("GetCommandLine", "str") ; no Parms: "str" is Cdecl returnType

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
	return strTemp2
	else
	{
	MsgBox, 8192, ReLaunch, % strTemp2
	return 1
	}
}