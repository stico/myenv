;-------------------------------------------------------------------------------
; NOTES
;-------------------------------------------------------------------------------
; 1. Why put every "{" in a newline? because some stupid statement need this (like "IfWinActive"), or will cause the script can not start
; 2. If path and file is needed as a "path and file", do't use "" embrace it. Only do this when it could be seem as a string (search C:\\ to see examples) 

;-------------------------------------------------------------------------------
; TODO
;-------------------------------------------------------------------------------
; Todo1 There are lots of path, put them into variable? (but some path are not seem as variable, seem item 2 in knowledge above.)
; Todo2 MButton -> scroll where is pointed
; Todo3 why the OnExit not work?


SetWinDelay,2
SetTitleMatchMode 2		; This match mode could make the winTitle match any part of the real title. But for safety useage, exactly match is better

CoordMode,Mouse
return

Capslock::Ctrl
;+Capslock::Capslock	; seems will actually cause "ctrl"

^!q::		ShowHide_TextWindow("Documents\DCB\Google Drive\NOTE\A_A_NOTE_Record.txt", false, false, false, "")
^!z::		ShowHide_TextWindow("Documents\DCB\Google Drive\NOTE\A_A_NOTE_Schedule.txt", false, false, false, "")
^!c::		ShowHide_TextWindow("Documents\DCB\Record\Z\A_A_NOTE_Copy.txt", true, false, true, "")
^!a::		ShowHide_TextWindow("Documents\DCB\Collection\allFile_All.txt", false, true, false, ": set isfname+=:")

^!p::		ShowHide_TextWindow("dev\a_workspaces\A_Project.lst", true, false, false, ": set isfname+=:")

;^!d::		ShowHide_Window("E:\program\A_Text_GoldenDict_1.0.1_Official\GoldenDict.exe", "GoldenDict")	; ahk can not activate GoldenDict, set the key in itself
^!x::		ShowHide_Window("E:\program\A_System_ConEmuPack_X\ConEmu.exe", "ahk_class VirtualConsoleClass")
^!e::		ShowHide_Window("C:\Users\ouyangzhu\AppData\Local\Google\Chrome\Application\chrome.exe", "Google Chrome")
^!s::		ShowHide_Window("E:\program\A_Network_SecureCRT_6.2.2\SecureCRT.EXE", "SecureCRT")
^!b::		ShowHide_Window("E:\program\A_Network_Chrome_X_PA-Basic\GoogleChromePortable.exe", "ahk_class Chrome_WidgetWin_1")
^!o::		ShowHide_Window("C:\Users\ouyangzhu\AppData\Roaming\Microsoft\Internet Explorer\Quick Launch\User Pinned\StartMenu\Microsoft Outlook 2010.lnk", "Microsoft Outlook")

^+c::		AppendTo_TempCopiedRepository()

^!+c::		EditTempCopyText()
^!+x::		EditTempCutText()

!x::		Window_CloseCurrent()
!z::		Window_MaxmizeRestore()
!c::		Window_Minimize()
RButton::	Window_Drag()
^RButton::	Window_Resize()

; to prevent catch cmd send by itself, use $ prefix for cmd
$^+TAB::	Filter_C_S_Tab_Excel_Console_Eclipse()
$^+w::		Filter_C_S_w_Chrome()
$^+q::		Filter_C_S_q_Eclipse()
$^+e::		Filter_C_S_e_Eclipse()
$^d::		Filter_C_d_Cmd_Console_Outlook()
$^TAB::		Filter_C_Tab_Excel_Console_Eclipse()
$+Insert::	Filter_S_Insert()
$f1::		Filter_F1_Vim()
$f3::		Filter_F3_FreeCommander()
$f4::		Filter_F4_Eclipse()
$ESC::		Filter_Esc_Excel()
$LButton::	Filter_Mouse_Right_Click_ConEmu()

^`::		QuickOpen_Vim()
f12::		BackupFile_Freecommander()
#b::		ScreenSave_Black()	
#TAB::		Goto_Taskbar()

^!+q::		tmpCmd()

tmpCmd()
{
	InitGlobalVar()
	msgbox %MY_PRO%
}
InitGlobalVar()
{
	global
	EnvGet, envVar_PATH, PATH
	msgbox %envVar_PATH%
}

;Following keys are deprecated, but the logic in them may useful
;^ESC::		RunTaskCenter()	
;$!Enter::	Filter_A_Enter()
;$^!s::		Filter_CtrlAlt_s_Vim()
;^!d::		ShowHide_Window("\A_A_Script-Basic\starDict-Repeatable.bat", "StarDict")	; deprecated by GoldenDict (set in that app itself)
;^!x::		ShowHide_Window("E:\program\A_System_ConEmuPack_X\ConEmu.exe", "G_Console_")
;^+x::		temp_startEclipse35()
;^!b::		ShowHide_Window_Chrome()		; specially for chrome, works (2012-10-25). seems ShowHide_Window() also works
;$^!d::		Filter_CtrlAlt_d()			; removed as this keys now is use for show/hide dictionary
;$^+g::		Filter_C_S_g_Eclipse()		; remvoed as found it is the clipX hacked the hot key
;^!d::		ShowDesktop()				; removed as #d works either
;^!e::		ShowExplorer()				; removed as #e works either
;#x::		MinimizeCurrentWindow()			; removed as seldom use
;$^!o::		CheckoutFileWithoutComments()		; ClearCase use
;$^!+o::	CheckoutFileWithComments()		; ClearCase use
;$^!i::		CheckinFileWithoutComments()		; ClearCase use
;$^!+i::	CheckinFileWithComments()		; ClearCase use
;$^!t::		ShowElementVersionTree()		; ClearCase use
;^!+x::		Window_CloseCurrent_NoSave()		; too danger and not seldom used


Filter_A_Enter()
{
	; seems can not filter YY chat window
	;IfWinActive, ahk_class QWidget
	;IfWinActive 909011
	;{
	;	msgbox aaa
	;}
}

Filter_S_Insert() {
	IfWinActive cmd.exe
	{
		sendInput {ALT DOWN}{Space}{ALT UP}{e}{p}
		;SendInput {RButton}
	} else IfWinActive DOS
	{
		sendInput {ALT DOWN}{Space}{ALT UP}{e}{p}
		;SendInput {RButton}
	; don't use "" for the window name, otherwise is will no effect
	} else IfWinActive Command Prompt
	{
		sendInput {ALT DOWN}{Space}{ALT UP}{e}{p}
		;SendInput {RButton}
	} else {
		SendInput {Shift Down}{Insert}{Shift Up}
	}
}

Filter_C_d_Cmd_Console_Outlook() {
	IfWinActive cmd.exe 
	{
		SendInput {Enter}exit{Enter}
	} else IfWinActive DOS 
	{
		SendInput {Enter}exit{Enter}
	; don't use "" for the window name, otherwise is will no effect
	} else IfWinActive Command Prompt 
	{
		SendInput {Enter}exit{Enter}
	; here only need for cmd, not need for G_Console_Cygwin
	} else IfWinActive G_Console_Cmd
	{
		;SendInput ^w		; close the tab, not one layer of shell
		SendRaw	exit
		Send {Enter}
	} else IfWinActive Message 
	{
		msgbox "Don't use this key on outlook mail, otherwise the draft mail will deleted" 
	} else 
	{
		SendInput ^d
	}
}

Filter_CtrlAlt_d()
{
	msgbox, Disabled this hot key, as would cause outlook mail list!
}

CheckoutFileWithComments()
{
	CheckoutFile("")
}

CheckoutFileWithoutComments()
{
	CheckoutFile("-nc")
	SendInput {Enter}exit{Enter}
}

CheckinFileWithComments()
{
	CheckinFile("")
}

CheckinFileWithoutComments()
{
	CheckinFile("-nc")
	;it better not to use SendInput {Enter}exit{Enter}
	;as the cmd may return error for useful info
}

CheckoutFile(commentOption)
{
	IfWinActive Eclipse Platform
	{
		GetFileNameAndPath(fileName, filePath)

		Run cmd
		WinWait cmd.exe
		SendInput M:{Enter}
		SendInput cd %filePath%{Enter}
		SendInput cleartool co %commentOption% %fileName%
	} else {
		SendInput ^+o
	}
}

CheckinFile(commentOption)
{
	IfWinActive Eclipse Platform
	{
		GetFileNameAndPath(fileName, filePath)

		Run cmd
		WinWait cmd.exe
		SendInput M:{Enter}
		SendInput cd %filePath%{Enter}
		SendInput cleartool ci %commentOption% %fileName%
	} else {
		SendInput ^+i
	}
}

ShowElementVersionTree()
{
	IfWinActive Eclipse Platform
	{
		GetFileNameAndPath(fileName, filePath)

		Run cleartool lsvtree -all -g %filePath%\%fileName%
	} else {
		SendInput ^+i
	}
}

GetFileNameAndPath(ByRef fileName, ByRef filePath)
{
	;get file location
	SendInput !{Enter}
	WinWait, Properties for
	ControlGetText, fileFullPath, Edit5
	SendInput {Esc}

	;get the path and the file name
	SplitPath, fileFullPath, fileName, filePath
}

ShowHide_Window_Chrome() 
{
;	msgbox aaa
;	if WinExist("ahk_class Chrome_WindowImpl_0")
;	{
;		WinActivate
;		ControlFocus, Chrome_AutocompleteEditView1
;	}

;	IfWinExist, ahk_class Chrome_WindowImpl_0
;		WinActivate

;	IfWinExist, ahk_class Chrome_WidgetWin_0
;		WinActivate

	If WinExist("ahk_class Chrome_WidgetWin_1")
	{
		If WinActive("ahk_class Chrome_WidgetWin_1") {
			WinActivateBottom, ahk_class Chrome_WidgetWin_1
		} Else {
			WinActivate
		}
	}

}

;CmdPath		the command to execute when window not exist
;WindowName		the part of the window name to be show/hide
ShowHide_Window(CmdPath, WindowName) 
{
	IfWinActive %WindowName% 
	{
		;WinHide %WindowName%
		Winminimize %WindowName%
	} else {
		winShow %WindowName%
		winActivate %WindowName%

		IfWinNotExist , %WindowName%
		{
			run %CmdPath%
			WinWait %WindowName%
			winActivate %WindowName%
		}
	}
}

;TextFilePath		The path of the text file
;CloseWindow		If true, the window will be closed. If false, the window will be hide instead of close. 
;ForceUTF8		force to use the utf-8 encoding to show, note, you will have problem to save if the encoding != fileencoding
;RemoveM		remove the anony ^M 
ShowHide_TextWindow(TextFilePath, CloseWindow, ForceUTF8, RemoveM, AdditionCmd)
{
	; %HOME% already contains a "\"
	TextFilePath="%HOME%%TextFilePath%"
	global ShowHide_TextWindow_PreviousWindowName			; declare as global variable, or the fuction fails
	SplitPath, TextFilePath, TextWindowNameTmp
	StringReplace, TextWindowName, TextWindowNameTmp, ", , All	; remove the last quote

	IfWinActive %TextWindowName%
	{
		;winset AlwaysOnTop, OFF, %TextWindowName%
		sendInput {Esc}
		sendInput ^s
		if %CloseWindow%
		{
			winClose %TextWindowName%
			exit
		} else {
			winHide %TextWindowName%
		}
		; activate the right window
		tmpLength := StrLen(ShowHide_TextWindow_PreviousWindowName)
		if %tmpLength% = 0
		{
			ShowDesktop()
		} else {
			winActivate %ShowHide_TextWindow_PreviousWindowName%
			ShowHide_TextWindow_PreviousWindowName := ""	; clean the record, as this kind of "previous" should only used once
		}
	} else {
		; record current window name before shows the text window
		WinGetActiveTitle, ShowHide_TextWindow_PreviousWindowName

		winShow %TextWindowName%
		;seems need right after the winShow
		winActivate %TextWindowName%
		;winset AlwaysOnTop, ON, %TextWindowName%

		IfWinNotExist , %TextWindowName%
		{
			run %MY_PRO%\A_Text_Vim_7.2_PA-Basic\App\vim\vim72\gVim.exe %TextFilePath%
			WinWait %TextWindowName%
			;winset AlwaysOnTop, ON, %TextWindowName%
			winActivate %TextWindowName%
			; set the "{ },{&},{(},{)},{,}" as a part of file name, this will be useful for vim cmd "gf" to go to a file
			; sendInput :set isfname{+}=32,38,40,41,44
			; sendInput {Enter}
			sendInput :set title titlestring=%TextWindowName%\ (BY\ AHK)\ -\ GVIM
			sendInput {Enter}
			if %ForceUTF8%
			{
				sendInput :set encoding=utf-8
				sendInput {Enter}
			}
			if %RemoveM%{
				; you need to escape every % and \
				sendInput :`%s/`\`%x0d//
				sendInput {Enter}
				sendInput :w
				sendInput {Enter}
			}
			if %AdditionCmd%{
				sendRaw %AdditionCmd%
				sendInput {Enter}
			}
		}
	}
}

ShowDesktop()
{
	send #d
}

ShowExplorer()
{
	send #e
}


QuickOpen_Vim()
{
	run %MY_PRO%\A_Text_Vim_7.2_PA-Basic\App\vim\vim72\gVim.exe
	;winActivate t.txt
}

Filter_C_Tab_Excel_Console_Eclipse()
{
	IfWinActive, Microsoft Excel
	{
		send {CTRL DOWN}{PgDn}{CTRL UP}
	} else IfWinActive, G_Console_
	{
		send {CTRL DOWN}{PgDn}{CTRL UP}
	} else IfWinActive, Eclipse
	{
		send {CTRL DOWN}{PgDn}{CTRL UP}
	} else 
	{
		send {CTRL DOWN}{TAB}{CTRL UP}
	}
}

Filter_C_S_Tab_Excel_Console_Eclipse()
{
	IfWinActive, Microsoft Excel
	{
		send {CTRL DOWN}{PgUp}{CTRL UP}
	} else IfWinActive, G_Console_
	{
		send {CTRL DOWN}{PgUp}{CTRL UP}
	} else IfWinActive, Eclipse
	{
		send {CTRL DOWN}{PgUp}{CTRL UP}
	} else 
	{
		send {CTRL DOWN}{SHIFT DOWN}{TAB}{SHIFT UP}{CTRL UP}
	}
}

;$^PgDn::	Filter_CtrlPageDown_Console()
;$^PgUp::	Filter_CtrlPageUp_Console()
;Filter_CtrlPageDown_Console()
;{
	;IfWinActive, G_Console_
	;{
;		send {CTRL DOWN}{TAB}{CTRL UP}
;	} else {
;		send {CTRL DOWN}{PgDn}{CTRL UP}
;	}
;}
;
;Filter_CtrlPageUp_Console()
;{
;	IfWinActive, G_Console_
;	{
;		send {CTRL DOWN}{SHIFT DOWN}{TAB}{SHIFT UP}{CTRL UP}
;	} else {
;		send {CTRL DOWN}{PgUp}{CTRL UP}
;	}
;}

Filter_C_S_w_Chrome()
{
	IfWinActive, Chrome
	{
		msgbox Filtered by AHK, to avoid close all!
	} else {
		sendInput {CTRL DOWN}{SHIFT DOWN}{w}{CTRL UP}{SHIFT UP}
	}
}

Filter_Esc_Excel()
{
	IfWinActive, Microsoft Excel
	{
		send {Enter}
	} else {
		; to prevent catch the Esc send by itself, use $ prefix for cmd
		send {Esc}
	}
}

Filter_C_S_g_Eclipse()
{
	; don't which program register the ^+g in win system (probably Firefox) for searching, I don't need it.
	IfWinActive, Eclipse
	{
		; a work around to "find reference in workspace"
		sendInput {ALT DOWN}{a}{ALT UP}{e}{w}
	}
}

Filter_C_S_q_Eclipse()
{
	; This will override the "Quick Diff Toggle" shortcut
	IfWinActive, Eclipse
	{
		; Toggle the "Link With Editor"
		; Steps: Show View (^+q) -> Package (p) -> Show View Menu (^F10) -> "Link With Editor" (k) -> Go back to Editor view (F12) 
		sendInput {ALT DOWN}{SHIFT DOWN}{q}{ALT UP}{SHIFT UP}{p}{CTRL DOWN}{F10}{CTRL UP}{k}{F12}
	} else {
		sendInput {CTRL DOWN}{SHIFT DOWN}{q}{CTRL UP}{SHIFT UP}
	}
}

Filter_CtrlAlt_s_Vim()
{
	IfWinActive, ) - GVIM
	{
		sendInput {SHIFT DOWN}{t}{SHIFT UP}
	} else {
		sendInput {CTRL DOWN}{ALT DOWN}{s}{CTRL UP}{ALT UP}
	}
}

Filter_C_S_e_Eclipse()
{
	; This will override the "Close All" shortcut, which is duplicated with "Ctrl + Shift + F4"
	IfWinActive, Eclipse
	{
		; "Collapse All" - Deprecated
		sendInput {CTRL DOWN}{SHIFT DOWN}{NumpadDiv}{CTRL UP}{SHIFT UP}
	} else {
		sendInput {CTRL DOWN}{SHIFT DOWN}{q}{CTRL UP}{SHIFT UP}
	}
}

Filter_F4_Eclipse()
{
	; This will override the "Hiearchy" shortcut, seems useless but time costing
	IfWinActive, Eclipse
	{
		; do nothing, just no need the f4
	} else {
		sendInput {f4}
	}
}

Filter_F3_FreeCommander()
{
	; This will override the "refresh" shortcut
	IfWinActive, FreeCommander
	{
		sendInput {CTRL DOWN}{SHIFT DOWN}{Tab}{CTRL UP}{SHIFT UP}{CTRL DOWN}{Tab}{CTRL UP}
	} else {
		sendInput {f3}
	}
}

Filter_Mouse_Right_Click_ConEmu()
{
	LButtonDownTime:=A_TickCount

	IfWinActive %WindowName% ahk_class VirtualConsoleClass
	{
		send {Shift Down}{LButton Down}
		Loop
		{
			; Break if button has been released.
			GetKeyState,KDE_Button,LButton,P
			If KDE_Button = U
			{
				send {LButton Up}{Shift Up}
				break
			}
		}
		return
	} else
	{
		send {LButton Down}
		Loop
		{
			; Break if button has been released.
			GetKeyState,KDE_Button,LButton,P
			If KDE_Button = U
			{
				send {LButton Up}
				break
			}
		}
	}
}

BackupFile_Freecommander()
{
	IfWinActive, FreeCommander
	{
		clipboard =		; Empty the clipboard
		sendInput {Alt Down}{Insert}{Alt Up}
		ClipWait, 2             ; wait until clipboard contains data
		srcFile = %Clipboard%
		IF FileExist(srcFile)
		{
			FormatTime, CurrentDateTime,, yyyy-MM-dd
			destFile = %srcFile%_%CurrentDateTime%
			IF FileExist(destFile)
			{
				msgbox "File "%destFile%" already exist!"
			} else {
				doNotOverwrite = 0
				FileCopy, %srcFile%, %destFile%, %doNotOverwrite%
			}
		} else {
			msgbox "File "%srcFile%" not exist!"
		}
	} else {
		sendInput {f12}
	}
}

Filter_F1_Vim()
{
	IfWinActive, GVIM
	{
		send {Esc}
	}
	; do nothing, just no need the f1
}

RunTaskCenter()
{
	run cmd
	WinWait cmd.exe
	sendinput cd %MY_ENV% {Enter}
	sendinput set PATH=%MY_PRO%\A_System_Cygwin\bin`;%PATH% {Enter}
	sendinput bash %MY_ENV%\script_a_tasksCenter.sh {Enter}
}

ScreenSave_Black()	
{
	sleep, 500
	run %MY_ENV%\script_ahk\z\BlackScreenSaver.scr /s
}

Goto_Taskbar()
{
	sendInput {LWIN}
	sendInput {ESC}
	sendInput {TAB}
}

Window_CloseCurrent_NoSave()
{
	send !{F4}
	sleep, 300
	send {n}
}

Window_Minimize()
{
	; The letter A means the active window will be used. 
	; This message is mostly equivalent to WinMinimize,
	; but it avoids a bug with FreeCommander & PsPad.
	PostMessage,0x112,0xf020,,,A
	return
}

Window_CloseCurrent()
{
	send !{F4}
}

Window_Drag()
{
	RButtonDownTime:=A_TickCount
	MouseGetPos,KDE_X1,KDE_Y1,KDE_id

	; abort if the window is maximized.
	WinGet,KDE_Win,MinMax,ahk_id %KDE_id%
	If KDE_Win
	{
		send {RButton}
		return
	}

	; Get the initial window position.
	WinGetPos,KDE_WinX1,KDE_WinY1,,,ahk_id %KDE_id%
	Loop
	{
		; Break if button has been released.
		GetKeyState,KDE_Button,RButton,P
		If KDE_Button = U
		{
			If A_TickCount - RButtonDownTime < 400
				send {RButton}
			break
		}
		MouseGetPos,KDE_X2,KDE_Y2
		KDE_X2 -= KDE_X1
		KDE_Y2 -= KDE_Y1
		KDE_WinX2 := (KDE_WinX1 + KDE_X2)
		KDE_WinY2 := (KDE_WinY1 + KDE_Y2)
		WinMove,ahk_id %KDE_id%,,%KDE_WinX2%,%KDE_WinY2%
	}
	return
}

Window_MaxmizeRestore()
{
	WinGet,KDE_Win,MinMax,A
	If KDE_Win
		WinRestore,A
	Else
		WinMaximize,A
	return
}


Window_Resize()
{
	; abort if the window is maximized.
	MouseGetPos,KDE_X1,KDE_Y1,KDE_id
	WinGet,KDE_Win,MinMax,ahk_id %KDE_id%
	If KDE_Win
		return
	
	WinGetPos,KDE_WinX1,KDE_WinY1,KDE_WinW,KDE_WinH,ahk_id %KDE_id%
	If (KDE_X1 < KDE_WinX1 + KDE_WinW / 2)
	   KDE_WinLeft := 1
	Else
	   KDE_WinLeft := -1
	If (KDE_Y1 < KDE_WinY1 + KDE_WinH / 2)
	   KDE_WinUp := 1
	Else
	   KDE_WinUp := -1
	Loop
	{
		GetKeyState,KDE_Button,RButton,P ; Break if button has been released.
		If KDE_Button = U
			break
	
		MouseGetPos,KDE_X2,KDE_Y2
		WinGetPos,KDE_WinX1,KDE_WinY1,KDE_WinW,KDE_WinH,ahk_id %KDE_id%
		KDE_X2 -= KDE_X1
		KDE_Y2 -= KDE_Y1
	
		WinMove,ahk_id %KDE_id%,, KDE_WinX1 + (KDE_WinLeft+1)/2*KDE_X2
								, KDE_WinY1 +   (KDE_WinUp+1)/2*KDE_Y2
								, KDE_WinW  -	 KDE_WinLeft  *KDE_X2
								, KDE_WinH  -	   KDE_WinUp  *KDE_Y2
		KDE_X1 := (KDE_X2 + KDE_X1)
		KDE_Y1 := (KDE_Y2 + KDE_Y1)
	}
	return
}

EditTempCopyText()
{
	;clipboard =		; Empty the clipboard
	sendInput ^c
	ClipWait, 2             ; wait until clipboard contains data

	run %MY_PRO%\A_Text_Vim_7.2_PA-Basic\App\vim\vim72\gVim.exe
	WinWait [No Name] - GVIM
	sendInput ^v
}

EditTempCutText()
{
	clipboard =		; Empty the clipboard
	sendInput ^x
	ClipWait, 2             ; wait until clipboard contains data

	run %MY_PRO%\A_Text_Vim_7.2_PA-Basic\App\vim\vim72\gVim.exe
	WinWait [No Name] - GVIM
	sendInput ^v
}

AppendTo_TempCopiedRepository()
{
	clipboard =		; Empty the clipboard
	sendInput ^c
	ClipWait, 2             ; wait until clipboard contains data

	; the * below means append in binary mode, seems could avoid the stupid ^M
	;FileAppend, ( %Clipboard%`n ), %MY_DOC%\DCB\Record\Note\A_A_NOTE_Copy.txt	; note, do not use "" to embrace the path, otherwise can not successfully write to file
	;newStr := RegExReplace(Clipboard, "\r")  
	;FileAppend, `n%Clipboard%, %MY_DOC%\DCB\Record\Note\A_A_NOTE_Copy.txt	; note, do not use "" to embrace the path, otherwise can not successfully write to file
	;FileAppend, `n%Clipboard%,  "\"E:\\Documents\\DCB\\Google Drive\\NOTE\\A_A_NOTE_Copy.txt\""

	; can not make it work in "Google Drive" (space in path)
	FileAppend, `n%Clipboard%, %MY_DOC%\DCB\Record\Z\A_A_NOTE_Copy.txt
	msgbox, %Clipboard%
}

temp_startEclipse35()
{
	msgbox, Try to start eclipse 3.5 ?

	;IfWinExist, Infranet Controller - Vista - Windows Internet Explorer
	;	msgbox, Please start zoning before eclipse!
	;else IfWinExist, Infranet Controller - Logout - Windows Internet Explorer
	;	msgbox, Please start zoning before eclipse! 
	IfWinNotExist, Rational ClearCase Explorer - ezhuouy_lsv_sig_p528
		msgbox, Please start ClearCase Explorer before eclipse! 
	else IfWinExist, Rational ClearCase Explorer - ezhuouy_lsv_sig_p530 (M:\ezhuouy_lsv_sig_p530)
		msgbox, Please mount related vobs (P530) before eclipse! 
	else IfExist, M:\ezhuouy_lsv_sig_p528\nrg_lsv_ws\dev\Foundation\Root\build.xml
		run %MY_PRO%\eclipse3.5\eclipse.exe
	else
		msgbox, Please start zoning before eclipse!
}


CleanUp:
	msgBox outing
	winShow note_for_tmp.txt
	winActivate note_for_tmp.txt
	send {Escape}:w
	winClose
ExitApp
