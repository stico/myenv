winName = 'Double Commander'
winCmd = ['/usr/bin/doublecmd']

import subprocess

winList = system.exec_command('wmctrl -l', getOutput=True)

if winName in winList: 
    system.exec_command('wmctrl -a ' + winName, getOutput=True)
else :
    subprocess.Popen(winCmd)
    window.wait_for_exist(winName, timeOut=5)
    winId = system.exec_command('wmctrl -l | grep "' + winName + '" | cut -f1 -d" "', getOutput=True)
    store.set_value(winName, winId)