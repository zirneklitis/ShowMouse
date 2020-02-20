; Display ripple effect on mouse clicks
author=Zirneklitis
applicationname=ShowMouse
version=0.9 (2020.02.20 - 20:20)
license=CC-BY-SA

; Based on script by 
; mright
; https://autohotkey.com/boards/viewtopic.php?f=6&t=8963&p=176651#p176651
; https://www.autohotkey.com/boards/viewtopic.php?f=6&t=8963
; Drugwash 18 Oct 2017, 03:53
; Drugwash added the ability to modify the idle timer and the pen width besides reverse animation switch.



Gosub,TRAYMENU


#NoEnv
#SingleInstance Force
#KeyHistory 0
ListLines Off
SetBatchLines, -1
SetKeyDelay, -1, -1
SetMouseDelay, -1
SetWinDelay, -1
SetControlDelay, -1
CoordMode Mouse, Screen
Setup()

~LButton::ShowRipple(LeftClickRippleColor,,0)
~MButton::ShowRipple(MiddleClickRippleColor,,0)
~WheelUp::ShowRipple(MouseMiddleRippleColor,,0)
~WheelDown::ShowRipple(MouseMiddleRippleColor,, 1)
~RButton::ShowRipple(RightClickRippleColor,, 1)

Setup()
{
    Global
    RippleWinSize := 200
    RippleStep := 15
    RippleMinSize := 10
    RippleMaxSize := RippleWinSize - 20
    RippleAlphaMax := 0xFF
    RippleAlphaStep := RippleAlphaMax / ((RippleMaxSize - RippleMinSize) / RippleStep)
    RippleVisible := False
    LeftClickRippleColor := 0xaa0000
	MiddleClickRippleColor := 0xcccc00
    RightClickRippleColor := 0x0000ff
    MouseMiddleRippleColor := 0x008000
    MouseIdleTimer := 5000
    PenWidth := 6
    Rev := 0
    
    DllCall("LoadLibrary", Str, "gdiplus.dll")
    VarSetCapacity(buf, 16, 0)
    NumPut(1, buf)
    DllCall("gdiplus\GdiplusStartup", UIntP, pToken, UInt, &buf, UInt, 0)
    
    Gui Ripple: -Caption +LastFound +AlwaysOnTop +ToolWindow +Owner +E0x80000
    Gui Ripple: Show, NA, RippleWin
    hRippleWin := WinExist("RippleWin")
    hRippleDC := DllCall("GetDC", UInt, 0)
    VarSetCapacity(buf, 40, 0)
    NumPut(40, buf, 0)
    NumPut(RippleWinSize, buf, 4)
    NumPut(RippleWinSize, buf, 8)
    NumPut(1, buf, 12, "ushort")
    NumPut(32, buf, 14, "ushort")
    NumPut(0, buf, 16)
    hRippleBmp := DllCall("CreateDIBSection", UInt, hRippleDC, UInt, &buf, UInt, 0, UIntP, ppvBits, UInt, 0, UInt, 0)
    DllCall("ReleaseDC", UInt, 0, UInt, hRippleDC)
    hRippleDC := DllCall("CreateCompatibleDC", UInt, 0)
    DllCall("SelectObject", UInt, hRippleDC, UInt, hRippleBmp)
    DllCall("gdiplus\GdipCreateFromHDC", UInt, hRippleDC, UIntP, pRippleGraphics)
    DllCall("gdiplus\GdipSetSmoothingMode", UInt, pRippleGraphics, Int, 4)
    
    MouseGetPos _lastX, _lastY
    Return

}

ShowRipple(_color, _interval:=10, _rs:=0)
{
    Global
    if (RippleVisible)
    	Return
    RippleColor := _color
    RippleDiameter := _rs ? RippleMaxSize : RippleMinSize
    RippleAlpha := RippleAlphaMax
    RippleVisible := True
    Rev := _rs

    MouseGetPos _pointerX, _pointerY
    SetTimer RippleTimer, % _interval
    Return

RippleTimer:
    DllCall("gdiplus\GdipGraphicsClear", UInt, pRippleGraphics, Int, 0)
    RippleDiameter := Rev ? RippleDiameter - RippleStep : RippleDiameter + RippleStep
    if (Rev && (RippleDiameter > RippleMinSize)) OR (!Rev && (RippleDiameter < RippleMaxSize)) {
        DllCall("gdiplus\GdipCreatePen1", Int, ((RippleAlpha -= RippleAlphaStep) << 24) | RippleColor, float, PenWidth, Int, 2, UIntP, pRipplePen)
        DllCall("gdiplus\GdipDrawEllipse", UInt, pRippleGraphics, UInt, pRipplePen, float, 1, float, 1, float, RippleDiameter - 1, float, RippleDiameter - 1)
        DllCall("gdiplus\GdipDeletePen", UInt, pRipplePen)
    }
    else {
        RippleVisible := False
        SetTimer RippleTimer, Off
    }

    VarSetCapacity(buf, 8)
    NumPut(_pointerX - RippleDiameter // 2, buf, 0)
    NumPut(_pointerY - RippleDiameter // 2, buf, 4)
    DllCall("UpdateLayeredWindow", UInt, hRippleWin, UInt, 0, UInt, &buf, Int64p, (RippleDiameter + 5) | (RippleDiameter + 5) << 32, UInt, hRippleDC, Int64p, 0, UInt, 0, UIntP, 0x1FF0000, UInt, 2)
    Return
}



TRAYMENU:
Menu,Tray,NoStandard
Menu,Tray,Add,%applicationname%,ABOUT
Menu,Tray,Add,
Menu,Tray,Add,E&xit,EXIT
Menu,Tray,Default,%applicationname%
Menu,Tray,Tip,%applicationname%
Return


EXIT:
GuiClose:
ExitApp


ABOUT:
Gui,99:Destroy
Gui,99:Margin,20,20
Gui,99:Add,Picture,xm Icon1,%applicationname%.exe
Gui,99:Font,Bold
Gui,99:Add,Text,x+10 yp+10,%applicationname% - %version%
Gui,99:Add,Text,y+5,Author; %author%
Gui,99:Font
Gui,99:Add,Text,y+15,License: %license%
Gui,99:Add,Text,y+10,This script can show a little ripple effects when
Gui,99:Add,Text,y+5,you click the mouse left, middle or right button
Gui,99:Add,Text,y+0,or scroll the mouse wheel.

Gui,99:Add,Picture,xm y+20 Icon3,%applicationname%.exe
Gui,99:Font,Bold
Gui,99:Add,Text,x+10 yp+10,ACKNOWLEDGMENTS
Gui,99:Font
Gui,99:Add,Text,y+10,	Based on skripts published by mright and Drugwash
Gui,99:Font,CBlue Underline
Gui,99:Add,Text,y+5 GACKNOWLEDGMENT1,https://www.autohotkey.com/boards
Gui,99:Font
Gui,99:Add,Text,y+10,Some ideas where taken from Skrommel's One Hour Software
Gui,99:Font,CBlue Underline
Gui,99:Add,Text,y+5 GACKNOWLEDGMENT2,http://www.dcmembers.com/skrommel/
Gui,99:Font

Gui,99:Add,Picture,xm y+20 Icon4,%applicationname%.exe
Gui,99:Font,Bold
Gui,99:Add,Text,x+10 yp+10,AutoHotkey
Gui,99:Font
Gui,99:Add,Text,y+10,This tool was made using the powerful
Gui,99:Font,CBlue Underline
Gui,99:Add,Text,y+5 GAUTOHOTKEY,https://www.autohotkey.com/
Gui,99:Font

Gui,99:Show,,%applicationname% About
hCurs:=DllCall("LoadCursor","UInt",NULL,"Int",32649,"UInt") ;IDC_HAND
Return

ACKNOWLEDGMENT1:
    Run,https://www.autohotkey.com/boards/viewtopic.php?f=6&t=8963
Return

ACKNOWLEDGMENT2:
  Run,http://www.dcmembers.com/skrommel/download/showoff/
Return

AUTOHOTKEY:
  Run,http://www.autohotkey.com/
Return

99GuiClose:
  Gui,99:Destroy
  OnMessage(0x200,"")
  DllCall("DestroyCursor","Uint",hCur)
Return