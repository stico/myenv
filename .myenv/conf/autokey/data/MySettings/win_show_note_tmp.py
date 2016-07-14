winName = 'A_NOTE_Tmp.txt'
winCmd = ['/usr/bin/gvim', '/home/ouyangzhu/Documents/FCZ/record/A_NOTE_Tmp.txt']

import subprocess

winList = system.exec_command('wmctrl -l', getOutput=True)
try :
    winId=store.get_value(winName)
except :
    winId = "0x00000000"

if winId in winList : 
    system.exec_command('wmctrl -i -a ' + winId, getOutput=True)
else :
    subprocess.Popen(winCmd)
    window.wait_for_exist(winName, timeOut=5)
    winId = system.exec_command('wmctrl -l | grep "' + winName + '" | cut -f1 -d" "', getOutput=True)
    store.set_value(winName, winId)