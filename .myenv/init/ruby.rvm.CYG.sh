#!/bin/bash
# Test failed on cygwin with some small error report on yaml configure (2013-01-17)
# Ref: http://blog.developwithpassion.com/2012/03/30/installing-rvm-with-cygwin-on-windows/

echo "ERROR: in dev, not really work yet, disable this line to continue"

[ -e ~/.rvm ] && echo "ERROR: ~/.rvm already exist, if want reinstall, remove it" && exit

devtool_cmd=osx_or_cygwin_kick_off
devtool_path=~/repositories/developwithpassion
settings="$(whoami).settings"

rm -rf $devtool_path
mkdir -p $devtool_path
echo "path ~/repositories/developwithpassion is originally create for installing rvm in cygwin, could be delete after that" > ~/repositories/A_NOTE.txt

cd $devtool_path
git clone git://github.com/developwithpassion/devtools

cd $devtool_path/devtools
./$devtool_cmd

sed -i -e "s/:cygwin.*=>.*,/:cygwin => 'E:\\\\program\\\\A_System_Cygwin\\\\Cygwin.bat',/" $settings
# seems still will install ruby even cmd below works correctly, and need manually input q to proceed
sed -i -e "s/.*rvm_install_some_rubies/#&/" $devtool_cmd
./$devtool_cmd

