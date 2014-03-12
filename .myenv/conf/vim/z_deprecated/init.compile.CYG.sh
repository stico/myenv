#!/bin/bash
# (2013-05-02) could compile terminal version (vim), but failed to compile GUI version (gvim)
# (2013-05-03) and article uses the Make_cyg.mak file, success to build gvim and works. Need more work on -xim and path specification. 
#		http://users.skynet.be/antoine.mechelynck/vim/compile.htm

# Var
log_prefix=log_vim_compile
vim_source=/cygdrive/e/amp/vim_source/vim
vim_target=/cygdrive/e/program/vim_73_compile
cyg_makefile=${vim_source}/src/Make_cyg.mak
cyg_mirror=http://mirrors.163.com/cygwin

# Init and Check, the /etc/pango  is a bug for 1.0
[ ! -e $vim_source ] && echo "ERROR: $vim_source not exist, pls check!" && exit 1
[ ! -e /etc/pango ] && mkdir /etc/pango
[ ! -e ${cyg_makefile}.bak ] && cp ${cyg_makefile} ${cyg_makefile}.bak
[ ! -e /bin/apt-cyg ] && curl http://apt-cyg.googlecode.com/svn/trunk/apt-cyg > /bin/ && chmod +x /bin/apt-cyg
[ -e $vim_target ] && rm -rf $vim_target


# OPTION 1: If trying to create a native Windows vim, use Make_cyg.mak (specially designed to build native windows gvim.exe) which uses i686-pc-mingw32-g++ and i686-pc-mingw32-gcc
# NOTE: this only gen vim/gvim binary, you still need runtime files
# Current Status: too long, see end of file
cd $vim_source/src
apt-cyg install \
	--cache /local_pkg \
	--mirror $cyg_mirror \
	ruby python tcl tcl-tk \
	mingw-gcc mingw64-i686-gcc &> ${log_prefix}_apt-cyg.log 
make clean &> ${log_prefix}_make_clean.log

sed -i 's/^FEATURES = .*/FEATURES = HUGE/'		$cyg_makefile
sed -i 's/^RUBY_VER = .*/RUBY_VER = 19/'		$cyg_makefile
sed -i 's/^RUBY_VER_LONG = .*/RUBY_VER_LONG = 1.9/'	$cyg_makefile


make -B -f $cyg_makefile GUI=no vim.exe &> ${log_prefix}_make_native_vim.log
make -B -f $cyg_makefile OLE=yes IME=yes gvim.exe &> ${log_prefix}_make_native_gvim.log



# OPTION 2: use MinGW to compile
# NOTE: ! runs in win cmd.exe ! (MingGW must be installed)
#ming_makefile=${vim_source}/src/Make_ming.mak
#sed -i 's/^FEATURES=.*/FEATURES=HUGE/'			$ming_makefile
#sed -i 's/^OLE=.*/OLE=yes/'				$ming_makefile
#mingw32-make -f $ming_makefile


# OPTION 3: If trying to build a Cygwin vim, Just use the configure mechanism and let it figure out things
#		seems only make, libncurses-devel, pkg-config, lib*-devel, mingw64-i686-gcc is really needed
# Current Status: could build vim, failed not build gvim
#cd $vim_source
#apt-cyg install \
#	--cache /local_pkg \
#	--mirror $cyg_mirror \
#	gcc4 \
#	ruby python tcl tcl-tk \
#	pkg-config libncurses-devel \
#	gtk2.0 libgtk2.0-devel libgtk2.0_0 \
#	glib2.0 libglib2.0-devel libglib2.0_0 \
#	pango1.0 libpango1.0-devel libpango1.0_0 atk1.0 \
#	libatk1.0-devel libatk1.0_0 git2.0-atk-bridge \
#	pixman libpixman1_0 libpixman1-devel \
#	libX11 libX11_6 libX11-devel \
#	libXt libXt-devel libXt6 \
#	libXtst libXtst-devel libXtst6 \
#	libXpm libXpm4 libXpm-noX libXpm-noX_4 libXpm-devel libXpm-noX-devel sxpm \
#	cairo libcairo2 libcairo-devel &> ${log_prefix}_apt-cyg.log 
#make clean &> ${log_prefix}_make_clean.log
#./configure --prefix=$vim_target --with-features=huge --enable-gui=gtk2 \
#	--enable-fontset --enable-multibyte --enable-xim \
#	--enable-pythoninterp --enable-rubyinterp 2>&1 > ${log_prefix}_configure.log 
#make &> ${log_prefix}_make.log 
#make install &> ${log_prefix}_make_install.log



# Current Status of Make_cyg.mak way: 
#	VIM - Vi IMproved 7.3 (2010 Aug 15, compiled May  3 2013 14:15:20)
#	MS-Windows 32-bit GUI version
#	Included patches: 1-918
#	Compiled by ouyangzh@w7vm
#	Huge version with GUI.  Features included (+) or not (-):
#	+arabic             +cursorshape        -hangul_input       +multi_byte_ime/dyn +scrollbind         +user_commands
#	+autocmd            +dialog_con_gui     +iconv/dyn          +multi_lang         +signs              +vertsplit
#	+balloon_eval       +diff               +insert_expand      -mzscheme           +smartindent        +virtualedit
#	+browse             +digraphs           +jumplist           +netbeans_intg      -sniff              +visual
#	++builtin_terms     -dnd                +keymap             -ole                +startuptime        +visualextra
#	+byte_offset        -ebcdic             +langmap            +path_extra         +statusline         +viminfo
#	+cindent            +emacs_tags         +libcall            -perl               -sun_workshop       +vreplace
#	+clientserver       +eval               +linebreak          +persistent_undo    +syntax             +wildignore
#	+clipboard          +ex_extra           +lispindent         -postscript         +tag_binary         +wildmenu
#	+cmdline_compl      +extra_search       +listcmds           +printer            +tag_old_static     +windows
#	+cmdline_hist       +farsi              +localmap           +profile            -tag_any_white      +writebackup
#	+cmdline_info       +file_in_path       -lua                -python             -tcl                -xfontset
#	+comments           +find_in_path       +menu               -python3            -tgetent            -xim
#	+conceal            +float              +mksession          +quickfix           -termresponse       -xterm_save
#	+cryptv             +folding            +modify_fname       +reltime            +textobjects        -xpm_w32
#	+cscope             -footer             +mouse              +rightleft          +title              
#	+cursorbind         +gettext/dyn        +mouseshape         -ruby               +toolbar            
#	   system vimrc file: "$VIM\vimrc"
#	     user vimrc file: "$HOME\_vimrc"
#	 2nd user vimrc file: "$VIM\_vimrc"
#	      user exrc file: "$HOME\_exrc"
#	  2nd user exrc file: "$VIM\_exrc"
#	  system gvimrc file: "$VIM\gvimrc"
#	    user gvimrc file: "$HOME\_gvimrc"
#	2nd user gvimrc file: "$VIM\_gvimrc"
#	    system menu file: "$VIMRUNTIME\menu.vim"
#	Compilation: i686-pc-mingw32-gcc -O3 -fomit-frame-pointer -freg-struct-return -fno-strength-reduce -DWIN32 -DHAVE_PATHDEF -DFEAT_HUGE  -DWINVER=0x0500 -D_WIN32_WINNT=0x0500 -DDYNAMIC_GETTEXT -DDYNAMIC_ICONV -DFEAT_MBYTE -DFEAT_MBYTE_IME -DDYNAMIC_IME -DFEAT_CSCOPE -DFEAT_NETBEANS_INTG -DFEAT_GUI_W32 -DFEAT_CLIPBOARD -march=i386 -Iproto -s -mno-cygwin
#	Linking: i686-pc-mingw32-gcc -s -o gvim.exe  -luuid -lole32 -lwsock32 -mwindows -lcomctl32 -lversion
# Compare to Official gvim: 
#	features support less: -osfiletype -profile 
#	both not support: -dnd -ebcdic -footer -hangul_input -lua -mzscheme -ole -perl -postscript -python -python3 -ruby -sniff -sun_workshop -tag_any_white -tcl -termresponse -tgetent -xfontset -xim -xpm_w32 -xterm_save 
#	must fix -xim
# Compare to MingGW gvim: 
#	features support less:  -ole -xpm_w32
#	both not support: -dnd -ebcdic -footer -hangul_input -lua -mzscheme -ole -perl -postscript -python -python3 -ruby -sniff -sun_workshop -tag_any_white -tcl -termresponse -tgetent -xfontset -xim -xpm_w32 -xterm_save -osfiletype -profile 
# Compare to gvim from Cream (the note.txt)
#	some option less for link:  -loleaut32 -Wl,-Bstatic -lstdc++ -Wl,-Bdynamic
#	many option less for compile:  

	#gcc4 \
	#--with-x 	# use X window system
