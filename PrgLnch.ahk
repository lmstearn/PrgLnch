;AutoHotkey /Debug C:\Users\New\Desktop\PrgLnch\PrgLnch.ahk
;AutoHotkey /Debug C:\Users\New\Desktop\Desktemp\PrgLnch\PrgLnch.ahk
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
				if (!SubProcFunc)
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
			key := argList["instance"]
			if ((key := Floor(key))) ; 0 is invalid
			{
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
			else
			{
			This.SaveRestoreUserParms(1)
			return
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
				This.parentHWnd := This.SetParentFlag()
				if (This.parentHWnd == "Error")
				{
				;msgbox, 8192, Parent Script, Warning: Parent script is not AHK, or the window handle cannot be obtained!
				This.parentHWnd := 0
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
			;SplitPath,d,name
			;UrlDownloadToFile,%d%,%name%
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

		VarSetCapacity(This.PicInScript, 348 << !!A_IsUnicode)
		This.PicInScript := "iVBORw0KGgoAAAANSUhEUgAAAH0AAAB9CAIAAAAA4vtyAAAACXBIWXMAAA7EAAAOxAGVKw4bAAAAt0lEQVR42u3QAQkAAAgDMLV/59tCELYI6yTFuVHg3TvevePdO96949073r17x7t3vHvHu3e8e8e7d+94945373j3jnfvePeOd+/e8e4d797x7h3v3vHu3TvevePdO96949073r17x7t3vHvHu3e8e8e7d7x7945373j3jnfvePeOd+/e8e4d797x7h3v3vHu3TvevePdO96949073r3j3bt3vHvHu3e8e8e7d7x7945373j3jvenFh1/A/fWM3mhAAAAAElFTkSuQmCC"

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
		if (text != "")
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
					spr := (spr > 0)?((This.vImgTxtSize)? 0: spr)/2: 0
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
		else
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
	temp := 0
	static Title := "PrgLnch Options"
	static DefScrWidth := 1920
	static DefScrHeight := 1080
	static DefScrFreq := 60

	Hwnd()
	{
	DetectHiddenWindows, On
	Gui, PrgLnchOpt: +Hwndtemp
	This.PrgHwnd := temp
	DetectHiddenWindows, Off
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
	scrWidthTest
	{
		set
		{
		this._scrWidthTest := value
		}
		get
		{
			return this._scrWidthTest
		}
	}
	scrHeightTest
	{
		set
		{
		this._scrHeightTest := value
		}
		get
		{
		return this._scrHeightTest
		}
	}
	scrFreqTest
	{
		set
		{
		this._scrFreqTest := value
		}
		get
		{
		return this._scrFreqTest
		}
	}
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
	}

Class PrgLnch
	{
	temp := 0
	static Title := "PrgLnch"
	static Title1 := "Notepad++"
	;static NplusplusClass := "ahk_exe Notepad++.exe"
	;static NplusplusClass := "ahk_class Notepad++"
	static ProcScpt := "ahk_exe PrgLnch.exe"
	static ProcAHK := "ahk_class AutoHotkeyGUI"
	static PrgHwnd := ""

	Hwnd()
	{
	DetectHiddenWindows, On
	Gui, PrgLnch: +Hwndtemp
	This.PrgHwnd := temp
	DetectHiddenWindows, Off
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
	__New()
	{
		ObjInsert(this,"",[])
	}
	__GET(what){
			return this["",what]
	}
	__SET(what,value){
		return this["",what]:=value
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
ChgResOnSwitchHwnd := 0
ChgResPrgOnCloseHwnd := 0
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
PrgChgResPrgOnClose := [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
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
dispMonNames := ["", "", "", "", "", "", "", "", ""]
iDevNumArray := [0, 0, 0, 0, 0, 0, 0, 0, 0]
; Defaults per monitor
scrWidthDefArr := [0, 0, 0, 0, 0, 0, 0, 0, 0]
scrHeightDefArr := [0, 0, 0, 0, 0, 0, 0, 0, 0]
scrFreqDefArr := [0, 0, 0, 0, 0, 0, 0, 0, 0] ; frequencies == vertical refresh rates
; settings per Prg
scrWidthArr := [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
scrHeightArr := [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
scrFreqArr := [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
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

GetDisplayData(, iDevNumArray, dispMonNames, , , , , , -3)

; Can change

PrgLnch.Monitor := GetPrgLnchMonNum(iDevNumArray, primaryMon, 1)


WinMover(, , , , "PrgLnchLoading.jpg")

temp := PrgLnch.Title
fTemp := 0
ffTemp := 0
DetectHiddenWindows, On
; foundpos1, foundpos2 ... window IDs
WinGet, foundpos, List, % temp


if (foundpos > 1 && !A_Args[1]) ;  foundpos is no of window IDs found,.No command line parms! See ComboBugFix
{
	while foundpos%A_Index%
	{
	temp := foundpos%A_Index%
	WinGetClass, strRetVal, % "ahk_id" temp

	if (strRetVal && !InStr(strRetVal, "CabinetWClass"))
	{
	; The following "fails" when any non-PrgLnch ahk script (compiled or not) is run from the PrgLnch folder: Proper way is with mutex. Also fails  on 2 or more classic Notepad windows
	if (InStr(strRetVal, "AutoHotkey"))
	ffTemp++
	if (InStr(strRetVal, "Notepad++"))
	fTemp++

		if (ffTemp > 2)
		{
		MsgBox, 8208, PrgLnch Running!, An instance of PrgLnch is already in memory!
		GoSub PrgLnchButtonQuit_PrgLnch
		}
		else
		{
			if (ffTemp > 2)
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
	SetTimer, RnChmWelcome, 3500
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

	SplashImage, PrgLnchLoading.jpg, A B,,, LnchSplash

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
	iDevNoFunc(txtPrgChoice, selPrgChoice, PrgLnkInf, targMonitorNum, scrWidthArr, scrHeightArr, scrFreqArr)
	SetResDefaults(0, targMonitorNum, scrWidthDefArr, scrHeightDefArr, scrFreqDefArr, 1)
	CheckModesFunc(defPrgStrng, PresetPropHwnd, targMonitorNum, iDevNumArray, ResIndexList, allModes)
	}
	else
	{
	CheckModesFunc(defPrgStrng, PresetPropHwnd, targMonitorNum, iDevNumArray, ResIndexList, allModes)
	CopyToFromResdefaults(1)
	}


GuiControl, PrgLnchOpt:, Monitors, % dispMonNames[targMonitorNum]
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

Gui, PrgLnchOpt: Add, Checkbox, vChgResPrgOnClose gChgResPrgOnCloseChk HWNDChgResPrgOnCloseHwnd, Change Res on Close
GuiControl, PrgLnchOpt: Disable, ChgResPrgOnClose
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
	TogglePrgOptCtrls(txtPrgChoice, ResShortcut, dispMonNames, iDevNum, iDevNumArray, targMonitorNum)
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
	TogglePrgOptCtrls(txtPrgChoice, ResShortcut, dispMonNames, iDevNum, iDevNumArray, targMonitorNum, borderToggle, selPrgChoice, PrgChgResPrgOnClose, PrgChgResOnSwitch, PrgChoicePaths, PrgLnkInf, PrgRnMinMax, PrgRnPriority, PrgBordless, PrgLnchHide, 1)

	GuiControl, PrgLnchOpt: , DefaultPrg, 1
	}




Gui, PrgLnchOpt: Show, Hide
WinMover(PrgLnchOpt.Hwnd(), "d r")   ; "dr" means "down, right"

	if (!FindStoredRes(ResIndexHwnd))
	{
	GuiControl, PrgLnchOpt: ChooseString, ResIndex, % PrgLnchOpt.MonCurrResStrng
	SplashImage, PrgLnchLoading.jpg, A B,,, LnchSplash
	}
	;ChooseString may fail if frequencies differ. Meh!
	if (PrgPID)
	{
	HideShowTestRunCtrls()
	SetTimer, WatchSwitchOut, -%timWatchSwitch%
	}

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
if (A_ISAdmin)
{
strTemp := PrgLnchOpt.Hwnd()
DllCall("ChangeWindowMessageFilterEx", "Ptr", strTemp, "UInt", WM_COPYDATA, "UInt", MSGFLT_ALLOW, "Ptr", 0)
DllCall("ChangeWindowMessageFilterEx", "Ptr", strTemp, "UInt", WM_COPYGLOBALDATA, "UInt", MSGFLT_ALLOW, "Ptr", 0)
DllCall("ChangeWindowMessageFilterEx", "Ptr", strTemp, "UInt", WM_DROPFILES, "UInt", MSGFLT_ALLOW, "Ptr", 0)
}

Gui, PrgLnch: Show,, % PrgLnch.Title

SplashImage, PrgLnchLoading.jpg, Hide,,,LnchSplash

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

	WinMover(, , , , "PrgLaunching.jpg")
	sleep, % (!PrgIntervalLnch)? 2000: (PrgIntervalLnch == -1)? 4000: 6000

	PrgLnchOpt.scrWidth := scrWidthArr[lnchPrgIndex]
	PrgLnchOpt.scrHeight := scrHeightArr[lnchPrgIndex]
	PrgLnchOpt.scrFreq := scrFreqArr[lnchPrgIndex]
	targMonitorNum := PrgMonToRn[lnchPrgIndex]
	}
	else
	{
	lnchPrgIndex := -PrgBatchIni%btchPrgPresetSel%[batchPrgStatus]
	temp := PrgChoicePaths[-lnchPrgIndex]
	PrgLnchOpt.scrWidth := scrWidthArr[-lnchPrgIndex]
	PrgLnchOpt.scrHeight := scrHeightArr[-lnchPrgIndex]
	PrgLnchOpt.scrFreq := scrFreqArr[-lnchPrgIndex]
	targMonitorNum := PrgMonToRn[-lnchPrgIndex]
	}

	lnchStat := 1


	strRetVal := LnchPrgOff(batchPrgStatus, lnchStat, PrgChoiceNames, temp, PrgLnkInf, PrgResolveShortcut, IniFileShortctSep, currBatchno, lnchPrgIndex, PrgCmdLine, iDevNumArray, dispMonNames, PrgMonPID, PrgRnMinMax, PrgRnPriority, PrgBordless, borderToggle, targMonitorNum, PrgPID, PrgListPID%btchPrgPresetSel%, PrgMinMaxVar, PrgStyle, btchPowerNames[btchPrgPresetSel])


	loop % currBatchNo
	{
	strTemp2 := PrgListPID%btchPrgPresetSel%[A_Index]
		if (batchPrgStatus == A_Index)
		{
		SplashImage, PrgLaunching.jpg, Hide,,,LnchSplash
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
		if (PrgChgResPrgOnClose[abs(lnchPrgIndex)] && DefResNoMatchRes())
		{
			if (lnchPrgIndex < 0)
			CopyToFromResdefaults()
		ChangeResolution(dispMonNames, temp)
		sleep, 500
		}
	}


	if (batchActive)
	SetTimer, WatchSwitchOut, %timWatchSwitch%
	else
	{
	CleanupPID(currBatchNo, lastMonitorUsedInBatch, PrgMonToRn, presetNoTest, PrgListPID%btchPrgPresetSel%, PrgStyle, PrgBordless, PrgLnchHide, PrgPID, selPrgChoice, dispMonNames, waitBreak, 1)

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

	RunWait, %strTemp2% %strTemp% %SelIniChoiceName%, , UseErrorLevel:

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
	GuiControl, PrgLnch: Hide, PwrChoice
	GuiControl, PrgLnch: Show, RunBatchPrg
	GuiControl, PrgLnch: Show, % GoConfigHwnd
	GuiControl, PrgLnch: Show, IniChoice
	GuiControl, PrgLnch: Hide, LnchPadConfig
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
namesToDel := ["PrgLnch.ico", "PrgLnchLoading.jpg", "PrgLaunching.jpg", "PrgLnchProperties.jpg", "LnchPadCfg.jpg", "PrgLnch.chm", "PrgLnch.chw", "taskkillPrg.bat", "LnchPadInit.exe"]

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
	case ChgResPrgOnCloseHwnd:
	retVal := RunChm("PrgLnch Config`\PrgLnch Config", "ChgResPrgOnClose")
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
x := 0, y := 0, w := 0, h := 0, hAdj := 0
temp := 0, retVal := 0, notPrgLnchGui := 0
htmlHelp := "C:\Windows\hh.exe ms-its"

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
		notPrgLnchGui := 1
		hAdj := h
		}
	}

if (chmTopic)
run, %htmlHelp%:%A_ScriptDir%\PrgLnch.chm::/%chmTopic%.htm#%Anchor%,, UseErrorLevel
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

		if (!notPrgLnchGui)
		WinMove, A, , %x%, % y - hAdj, %w%, %hAdj%

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
	if (WinActive("A") == PrgLnch.Hwnd() || WinActive("A") == PrgLnchOpt.Hwnd())
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
	if (hwndParent != PrgLnch.Hwnd() && hwndParent != PrgLnchOpt.Hwnd())
	{
	hwndParent := 0
	WinActivate, PrgLnch Options
	WinActivate, PrgLnch
	hwndParent := WinExist("A")
		if (!hwndParent)
		MsgBox, 8192, Task Dialog, Informational: PrgLnch form AWOL:`nNo parent window for dialog.
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
If (strRetVal)
MsgBox, 8192, Missing script, % strRetVal

SplashImage, PrgLnchLoading.jpg, A B,,, LnchSplash
WinGetPos, , , w, h, LnchSplash

WinMove, LnchSplash, , % PrgLnchOpt.X() + (PrgLnchOpt.Width() - w)/2, % PrgLnchOpt.Y() + (PrgLnchOpt.Height() - h)
sleep, 60




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
SplashImage, PrgLnchLoading.jpg, Hide,,,LnchSplash
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

ChgResPrgOnCloseChk:
Gui, PrgLnchOpt: Submit, Nohide
Tooltip
PrgChgResPrgOnClose[selPrgChoice] := ChgResPrgOnClose
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
	TogglePrgOptCtrls(txtPrgChoice, ResShortcut, dispMonNames, iDevNum, iDevNumArray, targMonitorNum, borderToggle, selPrgChoice, PrgChgResPrgOnClose, PrgChgResOnSwitch, PrgChoicePaths, PrgLnkInf, PrgRnMinMax, PrgRnPriority, PrgBordless, PrgLnchHide, 1)
	}
	else
	TogglePrgOptCtrls(txtPrgChoice, ResShortcut, dispMonNames, iDevNum, iDevNumArray, targMonitorNum)

return

iDevNoFunc(txtPrgChoice, selPrgChoice, PrgLnkInf, targMonitorNum, scrWidthArr, scrHeightArr, scrFreqArr)
{
; These for GetDisplayData
Static ENUM_CURRENT_SETTINGS := -1, ENUM_REGISTRY_SETTINGS := -2

	if (txtPrgChoice != "None")
	{
		if ((scrWidthArr[selPrgChoice] && scrHeightArr[selPrgChoice] && scrFreqArr[selPrgChoice]))
		{
		PrgLnchOpt.scrWidth := scrWidthArr[selPrgChoice]
		PrgLnchOpt.scrHeight := scrHeightArr[selPrgChoice]
		PrgLnchOpt.scrFreq := scrFreqArr[selPrgChoice]
		}
		else
		{
		; If by misadventure the values are zero
			if (LNKFlag(PrgLnkInf[selPrgChoice]) > -1) ; don't want the msgbox as ResIndex is already disabled
			MsgBox, 8192, No Resolution Mode, Monitor parameters for the selected or startup Prg do not exist!`n`nDefaults assumed.`nIt's recommended to save the parameters by reselecting the target monitor from the Monitor List, and, if required, changing the resolution mode.
		GetDisplayData(targMonitorNum, , , scrWidth, scrHeight, scrFreq, , , (PrgLnch.regoVar)? ENUM_REGISTRY_SETTINGS: ENUM_CURRENT_SETTINGS, 1)
		CopyToFromResdefaults(1)
		}
	}

}


CheckModes:
; Update allModes
Gui, PrgLnchOpt: Submit, Nohide
CheckModesFunc(defPrgStrng, PresetPropHwnd, targMonitorNum, iDevNumArray, ResIndexList, allModes)
Tooltip
return

CheckModesFunc(defPrgStrng, PresetPropHwnd, targMonitorNum, ByRef iDevNumArray, ByRef ResIndexList, allModes, setPrgLnchOptDefs := 0)
{
static oldTargMonitorNum := 0, ResArray := []
; resArray and all others are one-based now
static monitorOrder := [0, 0, 0, 0, 0, 0, 0, 0, 0]

	if (setPrgLnchOptDefs)
	{
	PrgLnchOpt.scrWidth := ResArray[1, setPrgLnchOptDefs]
	PrgLnchOpt.scrHeight := ResArray[2, setPrgLnchOptDefs]
	PrgLnchOpt.scrFreq := ResArray[3, setPrgLnchOptDefs]
	}
	else
	{
		if (oldTargMonitorNum == targMonitorNum)
		ResIndexList := "|" . GetResInfo(targMonitorNum, ResArray, 1, allModes, monitorOrder)
		else
		{
		ResIndexList := "|" . GetResInfo(targMonitorNum, ResArray, 1, allModes, monitorOrder)

		if (!allModes)
		ResIndexList := "|" . GetResInfo(targMonitorNum, ResArray, 2, allModes)

		oldTargMonitorNum := targMonitorNum

		}


	;Not the g-label ResListBox!
	GuiControl, PrgLnchOpt:, ResIndex, %ResIndexList%



		if (allModes)
		Gui, PrgLnchOpt: Font, Bold CA96915, Verdana
		else
		Gui, PrgLnchOpt: Font
	GuiControl, PrgLnchOpt: Font, ResIndex


	; Now process default res

		if (strTemp := GetResInfo(targMonitorNum, ResArray))
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
				if ((iDevNumArray[monitorOrder[targMonitorNum]] > 9) && (!(MDMF_GetMonStatus(monitorOrder[targMonitorNum]))))
				{
				GuiControlGet, strTemp2, PrgLnchOpt: FocusV

					if (strTemp2 == "iDevNum")
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
						retVal := TaskDialog("Monitors", "Monitor connection issue", "", "A monitor returns a bad status, possibly because of an unsupported setting on the physical monitor itself.`nThe list of resolution modes will now default to those of the primary monitor.`nIt's still possible to change the monitor's resolution from any supported mode from the list, and launch Prgs in the monitor defined in the virtual screen, however.", , "Continue with resolution checks")
							if (retVal < 0)
							IniWrite, 1, % PrgLnch.SelIniChoicePath, General, MonProbMsg
						}
					}

				GuiControl, PrgLnchOpt: Disabled, currRes
				}
				else
				PrgLnchOpt.MonCurrResStrng := strTemp
			}


			if (PresetPropHwnd)
			{
				if ((PrgLnch.Monitor != targMonitorNum) || PrgLnchOpt.Fmode() || PrgLnchOpt.DynamicMode())
				GuiControl, PrgLnchOpt:, currRes, %strTemp%
				else
				GuiControl, PrgLnchOpt:, currRes, % PrgLnchOpt.MonCurrResStrng
			}
			else  ;Update all at Load
			{
				GuiControl, PrgLnchOpt:, currRes, %strTemp%

				if (defPrgStrng == "None")
				CopyToFromResdefaults()
			}


		GuiControl, PrgLnchOpt: ChooseString, ResIndex, % PrgLnchOpt.MonCurrResStrng
		}
		else
		MsgBox, 8192, Monitor %targMonitorNum%, There is a critical error with the dimensions of the target monitor!


	GuiControl, PrgLnchOpt: Show, ResIndex
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
			If (strTemp == A_Loopfield)
			{
			fTemp := A_Index
			Break
			}
		}
		if (fTemp)
		{
		fTemp += 1
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

	Loop, Parse, strTemp, `n
	{
	strTemp2 := ""
	strTemp2 .= PrgLnchOpt.scrWidth . " `, " . PrgLnchOpt.scrHeight . " @ " . PrgLnchOpt.scrFreq . "Hz "

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
		retVal := TaskDialog("Monitors", "Resolution mismatch issue", , "Mismatch detected in desired resolution data for selected monitor! This usually involves differing frequency values appertaining to the same resolution preset.`nExcerpt from <A HREF=""https://support.microsoft.com/en-us/topic/screen-refresh-rate-in-windows-does-not-apply-the-user-selected-settings-on-monitors-tvs-that-report-specific-tv-compatible-timings-0a7a6a38-6c6a-2aec-debc-5183a76b9e1d"">MS Support</a>: `n`n""In Windows 7 and newer versions of Windows, when a user selects 60Hz, the OS stores a value of 59.94Hz. However, 59Hz is shown in the Screen refresh rate in Control Panel, even though the user selected 60Hz."" `n`nThe current resolution mode might have also been set from the ""List all Compatible"" selection. The recommended action is to reselect the required screen resolution from the list.", , "Continue resolution checks")
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
		CopyToFromResdefaults(1)
		scrWidthDefArr[targMonitorNum] := PrgLnchOpt.scrWidthDef
		scrHeightDefArr[targMonitorNum] := PrgLnchOpt.scrHeightDef
		scrFreqDefArr[targMonitorNum] := PrgLnchOpt.scrFreqDef
		GuiControlGet, strTemp, PrgLnchOpt:, ResIndex
		GuiControl, PrgLnchOpt:, currRes, %strTemp%
		}

		; This saves the monitor info for the test Prg in case a batch preset is run concurrently
		if (lnchStat < 0)
		{
		PrgLnchOpt.scrWidthTest := PrgLnchOpt.scrWidth
		PrgLnchOpt.scrWidthTest := PrgLnchOpt.scrHeight
		PrgLnchOpt.scrWidthTest := PrgLnchOpt.scrFreq
		}
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

					if (targMonitorNum == PrgMonToRn[selPrgChoice])
					{
						if ((scrWidthArr[selPrgChoice] && scrHeightArr[selPrgChoice] && scrFreqArr[selPrgChoice]))
						{ 
						PrgLnchOpt.scrWidth := scrWidthArr[selPrgChoice]
						PrgLnchOpt.scrHeight := scrHeightArr[selPrgChoice]
						PrgLnchOpt.scrFreq := scrFreqArr[selPrgChoice]
						}
						else
						{
						iDevNoFunc(txtPrgChoice, selPrgChoice, PrgLnkInf, targMonitorNum, scrWidthArr, scrHeightArr, scrFreqArr)
						SetResDefaults(0, targMonitorNum, scrWidthDefArr, scrHeightDefArr, scrFreqDefArr, 1)
						CheckModesFunc(defPrgStrng, PresetPropHwnd, targMonitorNum, iDevNumArray, ResIndexList, allModes)
						}
					}
					else
					{
						if ((scrWidthArr[selPrgChoice] && scrHeightArr[selPrgChoice] && scrFreqArr[selPrgChoice]))
						{ 
						PrgLnchOpt.scrWidth := scrWidthArr[selPrgChoice]
						PrgLnchOpt.scrHeight := scrHeightArr[selPrgChoice]
						PrgLnchOpt.scrFreq := scrFreqArr[selPrgChoice]
						}

					targMonitorNum := PrgMonToRn[selPrgChoice]
					iDevNoFunc(txtPrgChoice, selPrgChoice, PrgLnkInf, targMonitorNum, scrWidthArr, scrHeightArr, scrFreqArr)
					SetResDefaults(0, targMonitorNum, scrWidthDefArr, scrHeightDefArr, scrFreqDefArr, 1)
					GuiControl, PrgLnchOpt: ChooseString, iDevNum, %targMonitorNum%
					}

					if (!FindStoredRes(ResIndexHwnd))
					GuiControl, PrgLnchOpt: ChooseString, ResIndex, % PrgLnchOpt.MonCurrResStrng

				TogglePrgOptCtrls(txtPrgChoice, ResShortcut, dispMonNames, iDevNum, iDevNumArray, targMonitorNum, borderToggle, selPrgChoice, PrgChgResPrgOnClose, PrgChgResOnSwitch, PrgChoicePaths, PrgLnkInf, PrgRnMinMax, PrgRnPriority, PrgBordless, PrgLnchHide, 1)					


				}
				else
				{
				GuiControl, PrgLnchOpt: Enable, MkShortcut
				GuiControl, PrgLnchOpt:, MkShortcut, Make Shortcut
				GuiControl, PrgLnchOpt: Disable, RnPrgLnch
				PrgURLEnable(PrgUrlTest, UrlPrgIsCompressed, selPrgChoice, PrgChoicePaths, selPrgChoiceTimer, PrgResolveShortcut, PrgLnkInf, PrgUrl, PrgVer, PrgVerNew, UpdturlHwnd, IniFileShortctSep, 1)
				TogglePrgOptCtrls(txtPrgChoice, ResShortcut, dispMonNames, iDevNum, iDevNumArray, targMonitorNum)
				}

			}
			else
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
				TogglePrgOptCtrls(txtPrgChoice, ResShortcut, dispMonNames, iDevNum, iDevNumArray, targMonitorNum)

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
			if (txtPrgChoice == "Prg" . selPrgChoice)
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

iDevNoFunc(txtPrgChoice, selPrgChoice, PrgLnkInf, targMonitorNum, scrWidthArr, scrHeightArr, scrFreqArr)
SetResDefaults(0, targMonitorNum, scrWidthDefArr, scrHeightDefArr, scrFreqDefArr, 1)

CheckModesFunc(defPrgStrng, PresetPropHwnd, targMonitorNum, iDevNumArray, ResIndexList, allModes)
TogglePrgOptCtrls(txtPrgChoice, ResShortcut, dispMonNames, iDevNum, iDevNumArray, targMonitorNum, borderToggle, selPrgChoice, PrgChgResPrgOnClose, PrgChgResOnSwitch, PrgChoicePaths, PrgLnkInf, PrgRnMinMax, PrgRnPriority, PrgBordless, PrgLnchHide, 1)

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
	TogglePrgOptCtrls(txtPrgChoice, ResShortcut, dispMonNames, iDevNum, iDevNumArray, targMonitorNum)


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

	If (Inibox)
	spr := IniBox
	else
	spr = Prg

	Loop % PrgNo
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

	if (WinExist("PrgLnch.ahk") or WinExist("ahk_id" . PrgLnchOpt.Hwnd()) or WinExist("ahk_class" . PrgLnch.Title) or WinExist (PrgLnch.ProcAHK))
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
dispMonNames = ""
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
PrgChgResPrgOnClose = ""
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

scrWidthArr = ""
scrHeightArr = ""
scrFreqArr = ""
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

; Update Prg index
	if (presetNoTest)
	{
		temp := PrgBatchIni%btchPrgPresetSel%[A_Index]
		PrgLnchOpt.scrWidth := scrWidthArr[temp]
		PrgLnchOpt.scrHeight := scrHeightArr[temp]
		PrgLnchOpt.scrFreq := scrFreqArr[temp]
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
		sleep, % (!PrgIntervalLnch)? 2000: (PrgIntervalLnch == -1)? 4000: 6000
		}
		else
		{
		lnchPrgIndex := -temp
		temp := PrgChoicePaths[-lnchPrgIndex]
		}
	}

	strRetVal := LnchPrgOff(A_Index, lnchStat, PrgChoiceNames, (presetNoTest)? temp: strTemp2, PrgLnkInf, PrgResolveShortcut, IniFileShortctSep, (presetNoTest)? currBatchno: 1, lnchPrgIndex, PrgCmdLine, iDevNumArray, dispMonNames, PrgMonPID, PrgRnMinMax, PrgRnPriority, PrgBordless, borderToggle, targMonitorNum, PrgPID, PrgListPID%btchPrgPresetSel%, PrgMinMaxVar, PrgStyle, btchPowerNames[btchPrgPresetSel])

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

				MsgBox, 8192, Prg Launch, % strRetVal
				}
			}
			else
			MsgBox, 8192, Prg Launch, % strRetVal
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
				CleanupPID(currBatchNo, lastMonitorUsedInBatch, PrgMonToRn, presetNoTest, PrgListPID%btchPrgPresetSel%, PrgStyle, PrgBordless, PrgLnchHide, PrgPID, selPrgChoice, dispMonNames, waitBreak)
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
					if (PrgChgResPrgOnClose[abs(lnchPrgIndex)] && (temp := RevertResLastPrgProc(maxBatchPrgs, PrgMonPID)))
					{
						if (DefResNoMatchRes())
						{
						CopyToFromResdefaults()
						ChangeResolution(dispMonNames, temp)
						sleep, 500
						}
					}

					if (currBatchno == A_Index)
					CleanupPID(currBatchNo, lastMonitorUsedInBatch, PrgMonToRn, presetNoTest, PrgListPID%btchPrgPresetSel%, PrgStyle, PrgBordless, PrgLnchHide, PrgPID, selPrgChoice, dispMonNames, waitBreak, 1)
				}
			}
			; Update Master
			PrgPIDMast[lnchPrgIndex] := PrgListPID%btchPrgPresetSel%[A_Index]
		}
	}
SplashImage, PrgLaunching.jpg, Hide,,,LnchSplash
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
			CleanupPID(currBatchNo, lastMonitorUsedInBatch, PrgMonToRn, presetNoTest, PrgListPID%btchPrgPresetSel%, PrgStyle, PrgBordless, PrgLnchHide, PrgPID, selPrgChoice, dispMonNames, waitBreak)
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


LnchPrgOff(prgIndex, lnchStat, PrgNames, PrgPaths, PrgLnkInf, PrgResolveShortcut, IniFileShortctSep, currBatchno, lnchPrgIndex, PrgCmdLine, iDevNumArray, dispMonNames, ByRef PrgMonPID, PrgRnMinMax, PrgRnPriority, PrgBordless, borderToggle, ByRef targMonitorNum, ByRef PrgPID, ByRef PrgListPID, ByRef PrgMinMaxVar, ByRef PrgStyle, btchPowerName)
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

	WinMover(, , , , "PrgLaunching.jpg")
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
		if (!(disableRedirect := DllCall("Wow64DisableWow64FsRedirection", "Ptr*", oldRedirectionValue)))
		return % PrgLnch.SelIniChoicePath . " does not exist and there is a redirection error!"
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

					WinMover(, , , , "PrgLaunching.jpg")
					}
				}
			}

			;*************************************************
			; Monitor Checks

			if (DefResNoMatchRes())
			{
			strRetVal := ChangeResolution(dispMonNames, targMonitorNum)
				if (strRetVal)
				{
				retVal := TaskDialog("Screen Resolution", "Resolution change failed", , "Res. change reported an error when launching " . PrgNames[lnchPrgIndex] . ".`nPrg's saved resolution data is: " . PrgLnchOpt.scrWidth . " width, " . PrgLnchOpt.scrHeight . " height, at " . PrgLnchOpt.scrFreq . " Hz.`nReason for failure: `n" . """" . strRetVal . "." . """" . "`nUpon continuation of the launch, the Prg should (but is not guaranteed) to become visible in the primary (or default) monitor at its current resolution.", "", "Continue launching " . PrgNames[lnchPrgIndex], "Cancel launch")
					if (retVal == 1)
					{
					WinMover(, , , , "PrgLaunching.jpg")
					Sleep 200
					}
					else
					{
						if (disableRedirect)
						DllCall("Wow64RevertWow64FsRedirection", "Ptr", oldRedirectionValue)
					return "Cancelled!"
					}
				}
				else
				Sleep 600
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
		sleep, 120
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
					if (DefResNoMatchRes())
					{
						if (!ChangeResolution(dispMonNames, targMonitorNum))
						{
						sleep, 500
						CopyToFromResdefaults()
						}
					}
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
		tmp := 1

		if ((targMonitorNum != PrgLnchMon) || tmp := DefResNoMatchRes())
		{
			if (!tmp)
			return "Failed!"
			if (tmp < 0)
			return "Cancelled!"

			strRetVal := ChangeResolution(dispMonNames, targMonitorNum)

			if (strRetVal)
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

		if (wp_IsResizable())
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
		CopyToFromResdefaults()
		targMonitorNum := (lnchStat < 0)? PrgMonToRn[selPrgChoice]: PrgMonToRn[prgSwitchIndex]
			if (PrgLnch.Monitor == targMonitorNum)
			{
			ChangeResolution(dispMonNames, targMonitorNum)
			sleep, 500
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
								if (timerfTemp && PrgChgResPrgOnClose[timerBtch])
								{
								; got PID just closed by user && update for each prg in batch
									if (PrgMonPID.delete(timerfTemp))
									{
										if (temp := RevertResLastPrgProc(maxBatchPrgs, PrgMonPID, timerfTemp) && DefResNoMatchRes())
										{
										CopyToFromResdefaults()
										ChangeResolution(dispMonNames, temp)
										sleep, 500
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
			CleanupPID(currBatchNo, lastMonitorUsedInBatch, PrgMonToRn, presetNoTest, PrgListPID%btchPrgPresetSel%, PrgStyle, PrgBordless, PrgLnchHide, PrgPID, selPrgChoice, dispMonNames, waitBreak, 1)
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
				CleanupPID(currBatchNo, lastMonitorUsedInBatch, PrgMonToRn, presetNoTest, PrgListPID%btchPrgPresetSel%, PrgStyle, PrgBordless, PrgLnchHide, PrgPID, selPrgChoice, dispMonNames, waitBreak)
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
			CleanupPID(currBatchNo, lastMonitorUsedInBatch, PrgMonToRn, presetNoTest, PrgListPID%btchPrgPresetSel%, PrgStyle, PrgBordless, PrgLnchHide, PrgPID, selPrgChoice, dispMonNames, waitBreak)
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
							if (PrgChgResPrgOnClose[timerBtch])
							{
								if PrgMonPID.delete(timerfTemp)
								{
									if (temp := RevertResLastPrgProc(maxBatchPrgs, PrgMonPID, timerfTemp))
									{
										if (DefResNoMatchRes())
										{
										CopyToFromResdefaults()
										ChangeResolution(dispMonNames, temp)
										sleep, 500
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
				CleanupPID(currBatchNo, lastMonitorUsedInBatch, PrgMonToRn, presetNoTest, PrgListPID%btchPrgPresetSel%, PrgStyle, PrgBordless, PrgLnchHide, PrgPID, selPrgChoice, dispMonNames, waitBreak, 1)
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
		PrgLnchOpt.scrWidth := (lnchStat < 0)? scrWidthArr[selPrgChoice]: scrWidthArr[prgSwitchIndex]
		PrgLnchOpt.scrHeight := (lnchStat < 0)? scrHeightArr[selPrgChoice]: scrHeightArr[prgSwitchIndex]
		PrgLnchOpt.scrFreq := (lnchStat < 0)? scrFreqArr[selPrgChoice]: scrFreqArr[prgSwitchIndex]
		targMonitorNum := (lnchStat < 0)? PrgMonToRn[selPrgChoice]: PrgMonToRn[prgSwitchIndex]
			if (DefResNoMatchRes() && (PrgLnch.Monitor == targMonitorNum))
			{
			ChangeResolution(dispMonNames, targMonitorNum)
			sleep, 500
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

CleanupPID(currBatchNo, lastMonitorUsedInBatch, PrgMonToRn, presetNoTest, ByRef PrgListPIDbtchPrgPresetSel, ByRef PrgStyle, PrgBordless, PrgLnchHide, ByRef PrgPID, selPrgChoice, dispMonNames, waitBreak, batchWasActive := 0)
{
temp := 0, strRetVal := "", PrgStyle := 0, dx := 0, dy:= 0


	if (strRetVal := WorkingDirectory(A_ScriptDir, 1))
	MsgBox, 8192, Cleanup PID, % strRetVal
if (presetNoTest) ; Batch screen
{
	if (PrgPID)
	{
	SplashImage, Hide, A B,,,LnchSplash

		if (PrgMonToRn[selPrgChoice] == lastMonitorUsedInBatch)
		{
		PrgAlreadyLaunched(lastMonitorUsedInBatch, dispMonNames)
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
			PrgAlreadyLaunched(lastMonitorUsedInBatch, dispMonNames)
		}
	}
	else
	{
	HideShowTestRunCtrls(1)
	GuiControl, PrgLnchOpt:, Bordless, % PrgBordless[selPrgChoice]
		if (DefResNoMatchRes() && (PrgMonToRn[selPrgChoice] == PrgLnch.Monitor))
		{
		ChangeResolution(dispMonNames, PrgLnch.Monitor)
		sleep, 500
		}
	SetTimer, WatchSwitchBack, Delete
	SetTimer, WatchSwitchOut, Delete
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

PrgAlreadyLaunched(targMonitorNum, dispMonNames)
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
	PrgLnchOpt.scrWidth := PrgLnchOpt.scrWidthTest
	PrgLnchOpt.scrWidth := PrgLnchOpt.scrHeightTest
	PrgLnchOpt.scrWidth := PrgLnchOpt.scrFreqTest
		if (DefResNoMatchRes())
		{
		ChangeResolution(dispMonNames, targMonitorNum)
		sleep, 500
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
LR_LOADFROMFILE:=0x10
IconFile := A_ScriptDir . "\PrgLnch.ico"
hIcon := DllCall("LoadImage", "uint", 0, "str", IconFile, "uint", 1, "int", 0, "int", 0, "uint", LR_LOADFROMFILE)

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
		for process in ComObjGet("winmgmts:{impersonationLevel=impersonate}!\\" . strComputer . "\root\cimv2").ExecQuery("Select Name from Win32_Process")
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
	for process in ComObjGet("winmgmts:{impersonationLevel=impersonate}!\\" . strComputer . "\root\cimv2").ExecQuery("Select Name from Win32_Process")
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
	retVal := TaskDialog("Running Prgs", "The Prgs in the list below have already started:`n" . strTemp, , "", , "Update Prg Batch Status (Recommended)", "Do not update Prg Batch Status")
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
GetDisplayData(targMonitorNum := 1, ByRef iDevNumArray := 0, ByRef dispMonNames := 0, ByRef scrWidth := 0, ByRef scrHeight := 0, ByRef scrFreq := 0, ByRef scrInterlace := 0, ByRef scrDPI := 0, iMode := -2, iChange := 0)
{
Static OffsetDWORD := 4

; devFlags
Static DISPLAY_DEVICE_ATTACHED_TO_DESKTOP := 0x00000001, DISPLAY_DEVICE_PRIMARY_DEVICE:= 0x00000004, DISPLAY_DEVICE_MIRRORING_DRIVER := 0x00000008, DISPLAY_DEVICE_VGA_COMPATIBLE := 0x00000010

	if (iMode == -3) ; program load
	{
	iDevNumb := 0, ftemp := 0, temp := 0, devFlags := 0, devKey := 0
	; devKey:	Path to the device's registry key relative to HKEY_LOCAL_MACHINE. (not required)
	iLocDevNumArray := [0, 0, 0, 0, 0, 0, 0, 0, 0]

	static dispMonNamesSaved := {}
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

			dispMonNames[iDevNumb] := StrGet(&DISPLAY_DEVICE + OffsetDWORD, offsetWORDStr)

			if (!dispMonNames[iDevNumb])
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
	dispMonNamesSaved := dispMonNames

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
	retVal := DllCall("EnumDisplaySettingsEx" . (A_IsUnicode? "W": "A"), "PTR", dispMonNamesSaved[targMonitorNum], "UInt", iMode, "PTR", &Device_Mode, "UInt", 0)
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


ChangeResolution(dispMonNames, targMonitorNum := 1)
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

	GetDisplayData(targMonitorNum, , , , , , scrInterlace, scrDPI ,(PrgLnch.regoVar)? ENUM_REGISTRY_SETTINGS: ENUM_CURRENT_SETTINGS, 1)


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


	monName := dispMonNames[targMonitorNum]

	;Ref SetDisplayConfig. The usual approach is to call with CD_TEST and if no error use CDS_UPDATEREGISTRY | CDS_NORESET. With 2 monitors, again call ChangeDisplaySettingsExto change settings.
	retVal := DllCall("ChangeDisplaySettingsEx", "Ptr", &monName, "Ptr", &Device_Mode, "Ptr", 0, "UInt", CDSopt, "Ptr", 0)
	Sleep 100

	VarSetCapacity(DM_Position, 0)
	VarSetCapacity(Device_Mode, 0)
	;ChangeDisplaySettingsEx for all monitors (need EnumDisplayDevices)

	; for position of monitor (Primary at 0,0)

	;retVal = 0: Success
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
		Default: ; Success!
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
	if (PrgLnchOpt.scrHeightDef == ResArray[2, iModeCt - i] && PrgLnchOpt.scrFreqDef == ResArray[3, iModeCt - i])
	return 1
i++
}
return 0
}


MonitorSelectProc(ByRef resultResolutionMons, canonicalMonitorListIn)
{
WS_EX_CONTEXTHELP := 0x00000400
	static acceptDlg := 0, trackMonNames := [], monitors := [], canonicalMonitorListOut := []


	Static SplashRef := Splashy.SplashImg
	;https://autohotkey.com/board/topic/72109-ahk-fonts/
	; gui variables in function must be global
	Global guiMonitorSelect1, guiMonitorSelect2, guiMonitorSelect3, guiMonitorSelect4, guiMonitorSelect5, guiMonitorSelect6, guiMonitorSelect7, guiMonitorSelect8, guiMonitorSelect9, outputText

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

	;monitor names
	wmi := ComObjGet("winmgmts:{impersonationLevel=impersonate}!\\" A_ComputerName "\root\wmi")

		for monitor in wmi.ExecQuery("Select * from WmiMonitorID") ;extract names
		{	
		fname := ""
			for char in monitor.UserFriendlyName
			fname .= chr(char)
		monitors.push(fname)
		}

		; PrgLnch monitor dimensions used for other monitors.
		loop % PrgLnchOpt.activeDispMonNamesNo
		{
		canonicalMonitorListOut[A_Index] := canonicalMonitorListIn[A_Index]
		gui, MonitorSelectDlg: add, button, % "xs+" . height/2 . " ys+" . (A_Index - 1) * height + height/2 . " W" . 2 * height . " H" . height/2 . " gGuiMonitorSelect" . " vguiMonitorSelect" . A_Index, % "Monitor" . resultResolutionMons[A_Index]
		%SplashRef%(Splashy, {imagePath: "*", instance: A_Index, mainText: resultResolutionMons[A_Index], subText: monitors[resultResolutionMons[A_Index]], mainFontSize: 100, subFontSize: 30, vPosX : "C", vPosY : "C", vImgW: A_ScreenWidth/4, vImgH: A_ScreenHeight/3, vOnTop: 1}*)
		resultResolutionMons[A_Index] := A_Index
		MovePrgToMonitor(A_Index, 0, 0, 0, 0, 0, 0, 0, 0, Splashy.hWndSaved[A_Index])
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
	%SplashRef%(Splashy, {release: 1}*)
	return 0


	GuiMonitorSelectDlgAccept:
	acceptDlg := 1

	%SplashRef%(Splashy, {release: 1}*)
		loop % PrgLnchOpt.activeDispMonNamesNo
		{
		canonicalMonitorListOut[trackMonNames[A_Index]] := monitors[A_Index]
		resultResolutionMons[A_Index] := trackMonNames[A_Index]
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
	%SplashRef%(Splashy, {instance: fTemp, mainText: trackMonNames[fTemp], subText: monitors[trackMonNames[fTemp]]}*)	

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

			while GetDisplayData(dispMon, , , scrWidth, scrHeight, scrFreq, scrInterlace, scrDPI, iModeVal, (PrgLnch.Monitor != dispMon))
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

MsgBox, 8208, Monitor Resolutions, Critical error with selected Monitor %targMonitorNum%.
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




GetResInfo(targMonitorNum, ByRef ResArray, getCurrentRes := 0, allModes := 0, ByRef monitorOrder := 0, ByRef iDevNumArray := 0)
{
; From Checkmodes, getCurrentRes is 0: get all, 1: get default, 2: check default

static ENUM_CURRENT_SETTINGS := -1, ENUM_REGISTRY_SETTINGS := -2
static monitorMsg := 0, defResArray := [], iniDefResArray := []
Static ResArrayIn := [[], [], []]
ResList := "", Strng := ""

fTemp := 0, iModeCt := 0, checkDefMissing := 0, iModeval := 0
scrWidth := 0, scrHeight := 0, scrDPI := 0, scrInterlace := 0, scrFreq := 0
scrWidthLast := 0, scrHeightLast := 0, scrDPILast := 0, scrInterlaceLast := 0, scrFreqLast := 0


	switch (getCurrentRes)
	{
		case 1:  ; 0: populate list
		{
		ResList := CheckResolutions(targMonitorNum, monitorOrder, allModes, ResArrayIn)
		ResArray := ResArrayIn[monitorOrder[targMonitorNum]]
		}
		case 2:
		{
		iModeCt := 1

			while (scrWidth := ResArray[1, iModeCt])
			{
				scrHeight := ResArray[2, iModeCt]
				scrFreq := ResArray[3, iModeCt]

				;For "Incompatible" resolution detection: check if the current settings are missing from the list and replace it .
				if (!checkDefMissing && PrgLnchOpt.scrWidthDef && (scrWidth > PrgLnchOpt.scrWidthDef))
				{
					if ((!FindResMatch(iModeCt, ResArray)) || (scrWidthLast != PrgLnchOpt.scrWidthDef))
					{
					ResArray[1].InsertAt(iModeCt, PrgLnchOpt.scrWidthDef)
					ResArray[2].InsertAt(iModeCt, PrgLnchOpt.scrHeightDef)
					ResArray[3].InsertAt(iModeCt, PrgLnchOpt.scrFreqDef)
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
						retVal := TaskDialog("Unsupported Default Resolution", "Switching Monitors", "", "The current desktop resolution of " PrgLnchOpt.scrWidthDef " X " PrgLnchOpt.scrHeightDef " does not belong to the list of resolution modes the firmware of the selected monitor has flagged as operable. If the OEM wddm driver asserts the resolution mode is actually compatible, the mode will appear in the Windows Setting's list of resolution, there is no issue other than PrgLnch using an older technology from that of the driver. Else, the options of an out-dated or imported PrgLnch ini file, driver inconsistency or error in multi-monitor setup cannot be discounted.`n`nThe mode has been inserted to the PrgLnch Resolution Mode list, however changes to this, or any other resolution mode in this PrgLnch instance may not work properly.`n`nTo use PrgLnch, it's recommended the current desktop resolution be permanently changed to one which is more " . """" . "compatible" . """" . " with the driver.`nTo do so, from PrgLnch Options, select " . """" . "None" . """" . " in Shortcut slots, and choose " . """" . "Dynamic" . """" . " in the Res Options, and then select an alternative resolution mode from the list. Be sure`nto return the selection in Res Options to " . """" . "Temporary" . """" . ", if that is the preference.", , "Continue with the resolution checks")
							if (retVal < 0)
							IniWrite, 1, % PrgLnch.SelIniChoicePath, General, CheckDefMissingMsg
						}
					}
				checkDefMissing := 1
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
					}
				}
			iModeCt += 1
			}
		}
		Default: ; check default (when switching monitors)
		{
		;imodeVal == 0 caches the data for EnumSettings
			if (!GetDisplayData(targMonitorNum, , , , , , , , iModeval, (PrgLnch.Monitor != targMonitorNum)))
			MsgBox, 8192, Display Data, Display data could not be cached!
			if (!GetDisplayData(targMonitorNum, , , scrWidth, scrHeight, scrFreq, scrInterlace, scrDPI, (PrgLnch.regoVar)? ENUM_REGISTRY_SETTINGS: ENUM_CURRENT_SETTINGS, (PrgLnch.Monitor != targMonitorNum)))
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
			}
			else
			MsgBox, 8208, Monitor Dimensions, Critical error in monitor dimensions!
		}
	}
return ResList
}

CopyToFromResdefaults(copyTo := 0)
{
	if (copyTo)
	{
	PrgLnchOpt.scrWidthDef := PrgLnchOpt.scrWidth
	PrgLnchOpt.scrHeightDef := PrgLnchOpt.scrHeight
	PrgLnchOpt.scrFreqDef := PrgLnchOpt.scrFreq
	}
	else
	{
	PrgLnchOpt.scrWidth := PrgLnchOpt.scrWidthDef
	PrgLnchOpt.scrHeight := PrgLnchOpt.scrHeightDef
	PrgLnchOpt.scrFreq := PrgLnchOpt.scrFreqDef
}
}

DefResNoMatchRes()
{
defResmsg := 0

	if (PrgLnchOpt.scrWidth == PrgLnchOpt.scrWidthDef && PrgLnchOpt.scrHeight == PrgLnchOpt.scrHeightDef)
	{

	if (!(PrgLnchOpt.Fmode())) ;always change: Condition removed: !(PrgLnchOpt.DynamicMode()
	return 1

	IniRead, defResmsg, % PrgLnch.SelIniChoicePath, General, DefResmsg
		if (defResmsg)
		{
			if (defResmsg == 1)
			return 0
			else
			return 1
		}
		else
		{
		defResmsg := TaskDialog("Same Resolution", "Informational: The resolution on the Prg's target`nmonitor is identical to its current resolution", , "When the target resolution is the same as the existing resolution, the firmware`nin most monitors performs a rescan each time the change resolution function`nis called, a consideration fortunately handled in most video driver software.`nChoose the recommended action, unless trouble-shooting the monitor.`n`nScreen resolution always changes automatically when " . """" . "Change at every mode" . """" . "`nin " . """" . "Res Options" . """" . " is selected`, irrespective of the following choices.", , "Change resolution", "Do not change resolution (Recommended)", "Decide later")
			if (defResmsg < 0)
			{
			defResmsg := -defResmsg
				if (defResmsg != 3)
				IniWrite, %defResmsg%, % PrgLnch.SelIniChoicePath, General, defResmsg
			}
			if (defResmsg == 1)
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


WinMover(Hwnd := 0, position := "hc vc", Width := 0, Height := 0, splashInit := 0 ,wdRatio := 1, htRatio := 1)
{
x:= 0, y := 0, w := 0, h:= 0

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
				if (splashInit == "PrgLnchLoading.jpg")
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
	x := InStr(position,"l")? mtLeft: InStr(position,"hc")? (mtLeft + (mtRight-mtLeft-w)/2): InStr(position,"r") ? mtRight - w: ix
	y := InStr(position,"u")? mtTop: InStr(position,"vc")? (mtTop + (mtBottom-mtTop-h)/2): InStr(position,"d") ? mtBottom - h: iy


	if (splashInit)
	WinMove, LnchSplash,, wdRatio * x, htRatio * y
	else
	WinMove, ahk_id %Hwnd%,, wdRatio * x, htRatio * y

	CoordMode, Mouse, % strTemp
	DetectHiddenWindows, %oldDHW%


}

; Enables controls as per prg/monitor specs.
TogglePrgOptCtrls(txtPrgChoice, ResShortcut, dispMonNames, iDevNum, iDevNumArray, targMonitorNum, borderToggle := 0, selPrgChoice := 0, PrgChgResPrgOnClose := 0, PrgChgResOnSwitch := 0, PrgChoicePaths := 0, PrgLnkInf := 0, PrgRnMinMax := -1, PrgRnPriority := -1, PrgBordless := 0, PrgLnchHide := 0, CtrlsOn := 0)
{

ctlEnable := (LNKFlag(PrgLnkInf[selPrgChoice]) == -1)? "Disable": "Enable"

GuiControl, PrgLnchOpt:, Monitors, % dispMonNames[targMonitorNum]


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
	GuiControl, PrgLnchOpt:, ChgResPrgOnClose, 0
	GuiControl, PrgLnchOpt:, ChgResOnSwitch, 0
	GuiControl, PrgLnchOpt: Disable, ChgResOnSwitch
	GuiControl, PrgLnchOpt: Disable, ResIndex
	GuiControl, PrgLnchOpt: Disable, allModes
	}
	else
	{
	GuiControl, PrgLnchOpt: Enable, ChgResPrgOnClose
	GuiControl, PrgLnchOpt: Enable, ChgResOnSwitch
	GuiControl, PrgLnchOpt:, ChgResPrgOnClose, % PrgChgResPrgOnClose[selPrgChoice]
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
	GuiControl, PrgLnchOpt:, ChgResPrgOnClose, 0
	GuiControl, PrgLnchOpt: Disable, ChgResPrgOnClose
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
GuiControl, PrgLnchOpt: Hide, ChgResPrgOnClose
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
GuiControl, PrgLnchOpt: show, ChgResPrgOnClose
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
	IniWrite, %A_Space%, % PrgLnch.SelIniChoicePath, General, DefResmsg
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
		PrgChgResPrgOnClose[A_Index] := PrgChgResOnSwitch[A_Index]
		PrgChgResOnSwitch[A_Index] := PrgBordless[A_Index]
		PrgBordless[A_Index] := PrgRnMinMax[A_Index]
		PrgRnMinMax[A_Index] := -1


		spr := PrgMonToRn[A_Index] . "," . PrgChgResPrgOnClose[A_Index] . "," . PrgChgResOnSwitch[A_Index] . ",-1," . PrgRnPriority[A_Index] . "," . PrgBordless[A_Index] . "," . PrgLnchHide[A_Index] . ",0"

		IniWrite, % spr, % PrgLnch.SelIniChoicePath, Prg%A_Index%, PrgMisc

		spr := % scrWidthArr[A_Index] . "," . scrHeightArr[A_Index] . "," . scrFreqArr[A_Index] . "," 0

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
								scrWidthArr[selPrgChoice] := ""
								scrHeightArr[selPrgChoice] := ""
								scrFreqArr[selPrgChoice] := ""

								IniWrite, %A_Space%, % PrgLnch.SelIniChoicePath, Prg%recCount%, PrgRes
								}
								else
								{
									if (PrgChoiceNames[recCount])
									{
									spr := PrgLnchOpt.scrWidth . "," . PrgLnchOpt.scrHeight . "," . PrgLnchOpt.scrFreq . "," . 0
									;extra 0 for interlace which might implement later
									IniWrite, %spr%, % PrgLnch.SelIniChoicePath, Prg%recCount%, PrgRes
									scrWidthArr[selPrgChoice] := PrgLnchOpt.scrWidth
									scrHeightArr[selPrgChoice] := PrgLnchOpt.scrHeight
									scrFreqArr[selPrgChoice] := PrgLnchOpt.scrFreq
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
								scrWidthArr[recCount] := PrgLnchOpt.scrWidth
								scrHeightArr[recCount] := PrgLnchOpt.scrHeight
								scrFreqArr[recCount] := PrgLnchOpt.scrFreq
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
									spr .= "," . PrgChgResPrgOnClose[selPrgChoice]
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
								PrgChgResPrgOnClose[recCount] := A_LoopField
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

SplashImage, PrgLnchProperties.jpg, Hide,,,LnchSplash
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