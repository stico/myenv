@ECHO OFF
REM ----------------------------------------------------------------------------
REM -- Automatically install cygwin
REM -- TODO: init home dir (/etc/fstab.d/). Need init win HOME first?
REM -- TODO: specify version for package
REM -- INFO: inetutils contains telnet
REM -- INFO: ins_path_repo will be (auto added %2f in the end): E:\program\cygwin_1.7.18-1\local_pkg\http%3a%2f%2fmirrors.163.com%2fcygwin%2f
REM ----------------------------------------------------------------------------

REM ----------------------------------------------------------------------------
REM -- Variables
REM ----------------------------------------------------------------------------
SET ins_ver=1.7.18-1
SET ins_bin=setup_%ins_ver%.exe
SET ins_name=cygwin_%ins_ver%
SET ins_path=E:\program\cygwin_%ins_ver%
SET ins_path_repo=%ins_path%\local_pkg
REM SET ins_site=http://mirrors.163.com/cygwin
REM SET ins_site=http://mirrors.neusoft.edu.cn/cygwin
SET ins_site=http://mirrors.sohu.com/cygwin


REM ----------------------------------------------------------------------------
REM -- Packages
REM ----------------------------------------------------------------------------
SET ins_pkg_basic_1=cron,curl,expect,file,inetutils,ncurses,openssh,openssl
SET ins_pkg_basic_2=ping,renameutils,readline,shutdown,tcl,tcl-tk,wget,wput
SET ins_pkg_basic_3=unison2.45,unzip,zip,man,bzip2,patch
SET ins_pkg_basic=%ins_pkg_basic_1%,%ins_pkg_basic_2%,%ins_pkg_basic_3%

SET ins_pkg_build=gcc,gcc-core,gcc-g++,gdb,make
SET ins_pkg_mail=ssmtp,mutt
SET ins_pkg_git=git,git-completion,git-gui,gitk,stgit,git-svn

SET ins_pkg_test=autossh

SET ins_pkgs=%ins_pkg_basic%,%ins_pkg_test%,%ins_pkg_build%,%ins_pkg_mail%,%ins_pkg_git%


REM ----------------------------------------------------------------------------
REM -- Install
REM ----------------------------------------------------------------------------
md %ins_path%
%ins_bin% --site %ins_site% ^
	--local-package-dir %ins_path_repo% ^
	--root %ins_path% ^
	--no-desktop ^
	--no-shortcuts ^
	--no-startmenu ^
	--quiet-mode ^
	--packages %ins_pkgs%


REM ----------------------------------------------------------------------------
REM -- MISC - Inbox
REM ----------------------------------------------------------------------------
REM -- Following line will update cygwin packages
REM -- setup.exe --no-desktop --no-shortcuts --no-startmenu --quiet-mode
