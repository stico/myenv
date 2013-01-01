;ClipStep.ahk
;
;Control multiple clipboards using only the keyboard's Ctrl-X-C-V
;
;Select some text, press Ctrl-C a couple of times to copy it to multiple new clipboards. 
; Now hold down Ctrl and press V repeatedly to step through the clipboards. C steps backwards. 
; When you've got the clipboard you want, release Ctrl to paste. 
; To delete a clipboard, hold down Ctrl, press V followed by X twice to delete, three times to 
; delete all, or once to cancel. Release Ctrl to accept. 
;
; The clipboards are saved to separate files, so place the sctipt in it's own folder. 
;
;Skrommel @2005

SetBatchLines,-1

numofclips=0
activeclip=1
paste=no
delete=no

Gosub,INDEX

LOOP:
Sleep,100
GetKeyState,state,CTRL
If state=u
{
  If delete=delete
  { 
    readclip=filearray%activeclip%
    readclip:=%readclip%
    Filedelete,%readclip%.clip
    tooltip=Deleting Clip %activeclip% of %numofclips%
    Gosub,TOOLTIP
    Gosub,INDEX
    Gosub,FINDPREV
  }
  Else
  If delete=all
  {
    tooltip=Deleting all clips
    Gosub,TOOLTIP
    Filedelete,*.clip
    numofclips=0
    activeclip=0
    filearray1=0
    Gosub,INDEX
    activeclip=%numofclips%
  }
  Else    
  If paste=paste
  {
    readclip=filearray%activeclip%
    readclip:=%readclip%
    tooltip=Pasting clip %activeclip%
    Gosub,TOOLTIP
    Gosub,PASTECLIP
  }
  delete=no
  paste=no
}
Goto,LOOP


$^x::
If paste<>no
{
  If delete=delete
  {
    ToolTip,Delete all clips
    SetTimer,TOOLTIPOFF,Off
    delete=all
    paste=yes
    Return
  }
  Else
  If delete=cancel
  {
    If numofclips<1
    {
      tooltip=No clip exists
      Gosub,TOOLTIP
      Return
    }
    readclip=filearray%activeclip%
    readclip:=%readclip%
    FileRead,Clipboard,*c %readclip%.clip
    StringLeft,clip,Clipboard,100
    ToolTip,Delete Clip %activeclip% of %numofclips%`n%clip% 
    SetTimer,TOOLTIPOFF,Off
    delete=delete
    paste=yes
    Return
  }
  Else
  {
    tooltip=Cancel
    Gosub,TOOLTIP
    delete=cancel
    paste=yes
    Return
  }
}
clip1:=ClipboardAll
Clipboard=
Send,^x
ClipWait,1
clip2:=ClipboardAll
If clip2=
{
  tooltip=Empty selection
  Gosub,TOOLTIP
}
Else
If clip1<>%clip2%
{
  tooltip=Copying to clip 1
  Gosub,TOOLTIP
  Gosub,ADDCLIP
  Gosub,INDEX
}
Else
{
  tooltip=Same selection
  Gosub,TOOLTIP
}
clip1=
clip2=
Return

 
$^c::
If paste<>no
{
  If numofclips<1
  {
    tooltip=No clip exists
    Gosub,TOOLTIP
    delete=no
    paste=yes
    Return
  }
  Gosub,FINDPREV
  Gosub,SHOWCLIP
  delete=no
  paste=paste
  Return
}
clip1:=ClipboardAll
Clipboard=
Send,^c
clip2:=ClipboardAll
If clip2=
{
  tooltip=Empty selection
  Gosub,TOOLTIP
}
Else
If clip1<>%clip2%
{
  tooltip=Copying to clip 1
  Gosub,TOOLTIP
  Gosub,ADDCLIP
  Gosub,INDEX
}
Else
{
  tooltip=Same selection
  Gosub,TOOLTIP
}
clip1=
clip2=
Return

 
$^v::
If numofclips<1
{
  tooltip=No clip exists
  Gosub,TOOLTIP
  delete=no
  paste=yes
  Return
}
If paste<>no
  Gosub,FINDNEXT
Gosub,SHOWCLIP
delete=no
paste=paste
Return


ADDCLIP:
readclip=filearray1
readclip:=%readclip%
lastclip=%readclip%
lastclip+=1
numofclips+=1
activeclip=1
IfExist,%lastclip%.clip
  FileDelete,%lastclip%.clip
FileAppend,%ClipboardAll%,%lastclip%.clip
Return


SHOWCLIP:
readclip=filearray%activeclip%
readclip:=%readclip%
clip1:=ClipboardAll
IfExist,%readclip%.clip
  FileRead,Clipboard,*c %readclip%.clip
StringLeft,clip2,Clipboard,100
If clip2=
  clip2=... Image
ToolTip,Clip %activeclip% of %numofclips%`n%clip2% ... 
SetTimer,TOOLTIPOFF,Off
Clipboard:=clip1
clip1=
clip2=
Return
 

PASTECLIP:
readclip=filearray%activeclip%
readclip:=%readclip%
IfExist,%readclip%.clip
  FileRead,Clipboard,*c %readclip%.clip
Send,^v
delete=no
paste=no
Return


DELETECLIP:
delete=no
paste=no
Return


TOOLTIP:
ToolTip,%tooltip%
SetTimer,TOOLTIPOFF,900
Return


TOOLTIPOFF:
ToolTip,
SetTimer,TOOLTIP,Off
Return


INDEX:
filelist=
Loop,*.clip
{
  StringTrimRight,filename,A_LoopFileName,5
  filelist=%filelist%%filename%`n
}
StringTrimRight,filelist,filelist,1
Sort,filelist,N R
StringSplit,filearray,filelist,`n
numofclips=%filearray0%
Return


FINDNEXT:
  If numofclips<1
  {
    tooltip=No clip exists
    Gosub,TOOLTIP
    delete=no
    paste=yes
    Return
  }
activeclip+=1
If activeclip>%numofclips%
  activeclip=1
Return


FINDPREV:
  If numofclips<1
  {
    tooltip=No clip exists
    Gosub,TOOLTIP
    delete=no
    paste=yes
    Return
  }
activeclip-=1
If activeclip<1
  activeclip=%numofclips%
Return

