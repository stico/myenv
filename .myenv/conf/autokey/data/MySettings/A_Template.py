# TODO
#       winCurrent = window.get_active_title()          # not work, seems no such api

# INFO
#       subprocess.call(['xdg-open', 'PATH_TO_FILE_OR_DIR'])
#
#       tMsg = window.get_active_geometry()
#       subprocess.Popen(['/usr/bin/gvim'])
#       keyboard.send_keys("i" + str(tMsg))

# Variables
#appName = 'Google Chrome'
#appPath = '/usr/bin/google-chrome'
winName = 'GVIM'
winCmd = ['/usr/bin/gvim']

import subprocess

winList = system.exec_command('wmctrl -l', getOutput=True)
if winName in winList : 
    window.activate(winName, switchDesktop=True)
else :
    subprocess.Popen(winCmd)