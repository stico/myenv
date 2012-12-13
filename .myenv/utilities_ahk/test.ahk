^+d::Temp1()
^+f::Temp2()


Temp1() {
    msgbox temp1
}

Temp2() {
    msgbox "+="
    msgbox "\+="
    msgbox "\+\="
    msgbox "\\+\\="
}


;------------------------------------------------------------------------------
; Below is test utilities for test
;------------------------------------------------------------------------------
SetWinDelay,2
SetTitleMatchMode 2		; This match mode could make the winTitle match any part of the real title. But for safety useage, exactly match is better

CoordMode,Mouse
return

^!q::ReloadThisTest()

ReloadThisTest() 
{
    If true
    {
        Run C:\Users\ezhuouy\Documents\DCB\Configuration\AutoHotKey\A_Test_Area.ahk
    } else {
        SendInput ^!o
    }
}

