"""""""""""""""""""""""""""""" H1 - Topic - Basic
if exists('loaded_settings_of_stico')
	finish
endif
let loaded_settings_of_stico = 1

set nocompatible	" resets some settings (e.g. "iskeyword"), so should happen in the beginning. 
set noerrorbells	" no bell when there is error msg, note: those bell without error msg (e.g. press twice ESC) is not controlled here
set nomodeline		" no modeline support, useless and have secure risk
set visualbell		" enable this togehter with set t_vb to empty, press twice ESC will no bell
set t_vb=		" see 'set visualbell'

"
"""""""""""""""""""""""""""""" H1 - Topic - Font
" if possbile, set guifont=* to ensure which is perferred, then set guifont? to get value and set in .vimrc
if has('gui_running') && has('unix')
	"set lines=25 columns=100	" too small win size for mac
	"set guifont=XHei\ Mono\ 12	" too small font size for mac
	set guifont=XHei-Mono:h15
endif
" Use Alt-+/Alt--/Alt-0 to activate on linux, use Meta-=/Meta-- to activate on osx (Alt-0 seems NOT work on osx), ref more: keys@vim
nnoremap <A-+> :silent! let &guifont = substitute(&guifont, '\zs\d\+', '\=eval(submatch(0)+1)', 'g')<CR><CR>
nnoremap <A--> :silent! let &guifont = substitute(&guifont, '\zs\d\+', '\=eval(submatch(0)-1)', 'g')<CR><CR>
nnoremap <A-0> :silent! let &guifont = substitute(&guifont, '\zs\d\+', '\=15', 'g')<CR><CR>
command! -nargs=0 FontUp :let &guifont = substitute(&guifont, '\zs\d\+', '\=eval(submatch(0)+1)', 'g')
command! -nargs=0 FontDown :let &guifont = substitute(&guifont, '\zs\d\+', '\=eval(submatch(0)-1)', 'g')
command! -nargs=0 FontReset :let &guifont = substitute(&guifont, '\zs\d\+', '\=15', 'g')


"""""""""""""""""""""""""""""" H1 - Input Method

" TODO: Squirrel_v5 (@rime): try smartim plugin (currently only works on mac)

" Squirrel_v4 (@rime): seems just use these, will works on Mac High Serria 
" 1) enter/leave insert mode will change input source. 2) search input also works like insert mode (which is NOT really wanted"
set noimdisable		" default value on macvim/vim is imdisable/noimdisable, so unify it here.
set noimcmdline		" makes the default cmd line input is EN
set imsearch=0		" makes the default search input is EN
set iminsert=0		" 设成0的的时候，在Normal Mode用f时，会有Insert Mode的输入法，很不方便。设置成1时，则f/t会用英文，但Insert Mode的输入法又被置成英文了，也不方便。

" Squirrel_v3 (@rime), improve Squirrel_v2 
" req: 1) cmd defaults/osascrpit. 2) disable shift for squirrel to switch between en/cn mode. 3) enable accessiblity for osascript (in /System/Library/CoreServices/RemoteManagement/ARDAgent.app)
"if executable('defaults') && executable('osascript') && has('unix')
"
"  set noimdisable		" default value on macvim/vim is imdisable/noimdisable, so unify it here.
"  set ttimeoutlen=150		" for what? google shows it will speedup some operation
"
"  " 0 for EN, 2 for CN (Squirrel)
"  let g:osx_detect_input_cmd = "defaults read ~/Library/Preferences/com.apple.HIToolbox.plist AppleSelectedInputSources | awk '/Squirrel/{print 2;exit;};/U\.S\./{print 0;exit;}'"
"  let g:input_toggle = 0
"
"  function! Change2cn()
"     let s:input_status = system(g:osx_detect_input_cmd)
"     if s:input_status != 2 && g:input_toggle == 1
"	let l:a = system("osascript ${HOME}/Documents/DCC/osx/applescript/use_squirrel.applescript")
"	let g:input_toggle = 0
"     endif
"  endfunction
"  autocmd InsertEnter * call Change2cn()
"
"  " seems squirrel will trigger into en mode, so InsertLeave just need to record status
"  function! RecordImStatus()
"     let s:input_status = system(g:osx_detect_input_cmd)
"     if s:input_status == 2
"        let g:input_toggle = 1
"	"let l:a = system("osascript $HOME/.vim/applescript/use_english.applescript")
"     endif
"  endfunction
"  autocmd InsertLeave * call RecordImStatus() 
"endif

" Squirrel_v2 (@rime), slow and annoy version. Like FCITX_v1. Detect current input method and change via command. Since the input change need applescript which is heavy, too much InsertEnter/Leave event makes too much "noise"
" req: 1) cmd defaults/osascrpit. 2) disable shift for squirrel to switch between en/cn mode. 3) enable accessiblity for osascript (in /System/Library/CoreServices/RemoteManagement/ARDAgent.app)
"if executable('defaults') && executable('osascript') && has('unix')
"  let g:input_toggle = 0
"  function! Change2en()
"     let s:input_status = system("defaults read ~/Library/Preferences/com.apple.HIToolbox.plist AppleSelectedInputSources | awk '/Squirrel/{print 2;exit;};/U\.S\./{print 0;exit;}'")
"     if s:input_status == 2
"	let g:input_toggle = 1
"	let l:a = system("osascript $HOME/.vim/applescript/use_english.applescript")
"     endif
"  endfunction
"  function! Change2cn()
"     let s:input_status = system("defaults read ~/Library/Preferences/com.apple.HIToolbox.plist AppleSelectedInputSources | awk '/Squirrel/{print 2;exit;};/U\.S\./{print 0;exit;}'")
"     if s:input_status != 2 && g:input_toggle == 1
"	let l:a = system("osascript $HOME/.vim/applescript/use_squirrel.applescript")
"	let g:input_toggle = 0
"     endif
"  endfunction
"  set ttimeoutlen=150
"  call Change2en()
"  autocmd InsertLeave * call Change2en()
"  autocmd InsertEnter * call Change2cn()
"endif

" FCITX_v1, slow version, use fcitx.vim if need faster: http://www.vim.org/scripts/script.php?script_id=3764
if executable('fcitx-remote') && has('unix')
	" TODO: search CN and then press "n", will not goto next, how to improve? Seems the WinCmdEnter/Leave works not smoothly
	let g:input_toggle = 0
	function! Fcitx2en()
	   let s:input_status = system("fcitx-remote")
	   if s:input_status == 2
	      let g:input_toggle = 1
	      let l:a = system("fcitx-remote -c")
	   endif
	endfunction
	function! Fcitx2cn()
	   let s:input_status = system("fcitx-remote")
	   if s:input_status != 2 && g:input_toggle == 1
	      let l:a = system("fcitx-remote -o")
	      let g:input_toggle = 0
	   endif
	endfunction
	set ttimeoutlen=150
	call Fcitx2en()
	autocmd InsertLeave * call Fcitx2en()
	autocmd InsertEnter * call Fcitx2cn()
endif

" Squirrel_v1 (@rime), NOT good enough: when back in insert mode, input is still english
"if has("unix")
"	let s:uname = system("uname -s")
"	if s:uname == "Darwin"
"		" For macvim to work with input method (otherwise will NOT work properly):
"		" 1) need set "noimdisable"
"		" 2) need set iminsert
"		" 3) need set defaults "defaults write org.vim.MacVim MMUseInlineIm 0" on osx command line
"		" 4) need disable a setting: (in macvim) press M+, > Advanced > (disable) "Draw marked text inline"
"		set noimdisable		" default value on macvim/vim is imdisable/noimdisable, so unify it here.
"
"		" NOT work, will input CN in search mode. seems it changes frequently, so static set will, default value on macvim/vim is 2/0
"		"set iminsert=0
"		
"		" NOT work, can NOT reserve CN mode when to back to insert mode
"		"autocmd! InsertLeave * set imdisable|set iminsert=0	
"		"autocmd! InsertEnter * set noimdisable|set iminsert=0
"	endif
"endif

" ibus_v1, Need vim-ibus interface to use
" https://github.com/bouzuya/vim-ibus
" https://github.com/eagle0701/vim-ibus
" https://github.com/tuvistavie/dot-files/tree/master/.vim/bundle/vim-ibus
"function! <SID>AC_IBusDisable()
"    if ibus#is_enabled()
"        call ibus#disable()
"        let b:ibustoggle = 1
"    endif
"    set timeoutlen=1000
"endfunction
"function! <SID>AC_IBusRenable()
"    if exists("b:ibustoggle")
"        if b:ibustoggle == 1
"            call ibus#enable()
"            let b:ibustoggle = 0
"            set timeoutlen=100
"        endif
"    else
"        let b:ibustoggle = 0
"    endif
"endfunction
"autocmd InsertLeave call <SID>AC_IBusDisable()
"autocmd InsertEnter call <SID>AC_IBusRenable()

"Option 3: need +xim, very basic and not really usable
"if has("gui_running")
"	set imactivatekey=S-C-space
"	inoremap <ESC> <ESC>:set iminsert=0<CR>
"endif

"""""""""""""""""""""""""""""" H1 - Syntax
syntax on						" switch syntax highlighting on
if has('gui_running')
    set background=light
else
    set background=dark
endif

"""""""""""""""""""""""""""""" H1 - Indent
"au BufRead,BufNewFile jquery.*.js set filetype=javascript syntax=jquery 
"au FileType javascript set expandtab tabstop=4 shiftwidth=4 

"""""""""""""""""""""""""""""" H1 - Topic - autocmd on nomodifable
au WinEnter * if(&modifiable==0) | nnoremap <Space> <C-f> | else | nnoremap <Space> i<Space><Esc> | endif

"""""""""""""""""""""""""""""" H1 - Topic - autocmd on qf
" MNT: defaut behavior of <cr>:
"	1) for location list, goto location and close the window 
"	2) for quickfix list, goto location and KEEP the window, but cursor is in the target window, NOT the quickfix window
" MNT: mapping update here for purpose/effection
" 	1) <esc> to quit location / quickfix list
" 	2) <cr>/<enter> for location list, goto location > move to center > close the window 
" 	3) <cr>/<enter> for quickfix list, goto location > move to center > cursor back to qf window	# TODO: NOT work yet, since share the mapping. So perfer better usage for location window, since used much more
augroup quickfix
	autocmd!
	"autocmd FileType qf setlocal wrap					" makes location window also wraps and messup
	"autocmd FileType qf nmap <buffer> <esc> :x<cr>				" Works
	autocmd FileType qf nmap <buffer> <esc> :x<cr>:noh<cr>

	"autocmd FileType qf nmap <buffer> <cr> <cr>zz<c-w><c-p>		" Works on old version (lapmac), now need add :x<cr> to quit, why?
	"autocmd FileType qf nmap <buffer> <cr> <cr>zz<c-w><c-p>:x<cr>		" Works
	autocmd FileType qf nmap <buffer> <cr> <cr><c-w><c-p>:x<cr>zt:noh<cr>
augroup END

"""""""""""""""""""""""""""""" H1 - Topic - autocmd on help
autocmd FileType help nmap <buffer> <esc> :close<cr>

"""""""""""""""""""""""""""""" H1 - Topic - auto save
autocmd FocusLost * silent! wa
set autowriteall

"""""""""""""""""""""""""""""" H1 - Settings - Misc
filetype plugin indent on				" type detection, language-dependent indenting
set autoread						" auto read if file updated (e.g. by other soft)
set autochdir						" automatically change current dir
set autoindent						" auto indent the new line to the previous one
set dictionary+=$MY_DCO/english/dictionary/words_us	" use <C-N> to trigger 
set nobackup						" won't leave additional file(s) after close VIM
set nowritebackup					" default is :set writebackup, will keep a backup file while file is being worked. Once VIM is closed; the backup will vanish.
set noswapfile						" (1) Keep in mind that this option will keep everything in memory. (2) Don't use this for big files, will be memeory consuming and Recovery will be impossible! (3) In essence; if security is a concern, use this option
set history=50						" set the cmd history
set ruler						" show the current position in the bottom
set showcmd						" show the cmd in the bottom, like 'dw'
set nowrap						" wrap/nowrap the line
set linebreak						" won't break words as wrapping a line, need wrap set
set cursorline						" highlight current line
set gdefault						" make substitute g flag default on
"set shell=bash						" use bash as shell for :!
set shell=bash\ --rcfile\ ~/.bashvimrc			" so could use diff config for bash in vim
set relativenumber					" show number of lines related to current line

"set macmeta						" option key as meta key on mac/macvim
"
"MNT: buildin grep is using quickfix@vim. 
"MNT: set grepformat to customize the grep output
set grepprg=\\grep\ -rIinH\ --color\ --exclude-dir=\\.{svn,git,bzr,hg,metadata}\ --exclude-dir=node_modules\ --exclude-dir=target\ --exclude=.vimtags\ --exclude=\\*.min.js\ --exclude=jquery.js
"MNT: NOT need to change current dir in OuCodeReading mode, since it already changes. Why want to do this at the first place?!!!
"set grepprg=\\cd\ $PWD;\\grep\ -rIinH\ --color\ --exclude-dir=\\.{svn,git,bzr,hg,metadata}\ --exclude-dir=target
"MNT: in OuCodeReading mode, %:p:h not the "root", should use $PWD instead
"set grepprg=\\cd\ %:p:h;\\grep\ -rIinH\ --color\ --exclude-dir=\\.{svn,git,bzr,hg,metadata}\ --exclude-dir=target
"MNT: seems not possible to use getcwd(), while %: is supported/expanded but only for filename related. Have to use :exec xxx . getcwd() . "yyy" form
"set grepprg=\\cd\ getcwd();\\grep\ -rIinH\ --color\ --exclude-dir=\\.{svn,git,bzr,hg,metadata}\ --exclude-dir=target

"set grepprg=\\cd\ %:p:h;func_grep_file\ $*		" reuse the func, note need the "set shellcmdflag=-ic"
"set shellcmdflag=-ic					" run cmd (via :!) in interactive mode, so could use shell alias/function. BUT will slow down all operation which need run shell cmd
"set shell=bash\ --login				" will source .bashrc everytime
"set cursorcolumn					" highlight current column
"set relativenumber

"""""""""""""""""""""""""""""" H1 - Settings - Search
set incsearch						" set the increase search
set hlsearch						" highlighting the last used search pattern.
set ignorecase						" useful when using ^n, ^p
set smartcase						" become case sensitive when have uppercase in search string
"set infercase						" won't change exist case for ^n, need ignorecase open

"""""""""""""""""""""""""""""" H1 - Settings - Encoding
"set fileencodings=utf-8,gbk,ucs-bom,cp936		" set the encodings, it is the sequence vim will try to open a doc
set encoding=utf-8					" fix the encodings
set fileencoding=utf-8					" fix the fileencoding
set viminfo=						" don't want .viminfo everywhere

"""""""""""""""""""""""""""""" H1 - Settings - Key Charaters
"set isfname+=32,38,40,41,44				make the { },{&},{(},{)},{,} as a part of file name, this will be useful for vim cmd gf to go to a file
"set isfname+=32					" make ' ' as part of filename, gf (goto file) use it
"set isfname+=44					" make ',' as part of filename, gf (goto file) use it
set isfname-=:						" make ':' NOT a part of the filename, gf (goto file) use it

"""""""""""""""""""""""""""""" H1 - Settings - GUI
set guioptions-=m					" no menu
set guioptions-=T					" no toolbar
set guioptions+=b					" always show buttom scroll-bar
set mousehide						" Hide the mouse when typing text

" In many terminal emulators the mouse works just fine, thus enable it.
if has('mouse')
  set mouse=a
endif

"""""""""""""""""""""""""""""" H1 - Settings - Movement
set whichwrap+=<,>,[,]					" make the left/right could go cross line in Normal/Visual & Insert/Replace mode
set whichwrap+=h,l					" make the h/l also
set backspace=indent,eol,start				" backspace and cursor keys wrap to previous /next line

"""""""""""""""""""""""""""""" H1 - Mapping - Terminal Mode
tnoremap <Esc> <C-W>N
tnoremap <C-S-H> <C-w>h
tnoremap <C-S-J> <C-w>j
tnoremap <C-S-K> <C-w>k
tnoremap <C-S-L> <C-w>l

"""""""""""""""""""""""""""""" H1 - Mapping - Misc
"inoremap jj <ESC>					" not really used
"nnoremap <C-6> <C-^>					" (NOT WORK) when update to macvim 8.1, C-6 NOT work any more, need to use C-S-6

"""""""""""""""""""""""""""""" H1 - Mapping - Disable Useless keys
inoremap <F1> <ESC>
nnoremap <F1> <ESC>
vnoremap <F1> <ESC>

"""""""""""""""""""""""""""""" H1 - Mapping - Jump
" <C-I> equals <Tab>, since <Tab> is mapped in normal mode, need another key for function "jump next",  C-N in normal mode is useless, so use it
nnoremap <C-N> <C-I>

"""""""""""""""""""""""""""""" H1 - Mapping - edit/move in insert mode
" like in command line (@emacs). 
" NOTE 1, C-N NOT effects the C-N in completion mode, so no problem :-)
" NOTE 2, C-W (delete back word) in insert mode already works
" NOTE 3, use insert mode command, to avoid InsertEnter/Leave event
"inoremap <C-K> <Right><ESC>C	" NOT useful as always cause mis-operation, and NOT easy to undo
"inoremap <C-U> <Right><ESC>c^	" NOT useful as always cause mis-operation, and NOT easy to undo
inoremap <C-K> <Up>
inoremap <C-D> <Del>
inoremap <C-E> <End>
inoremap <C-J> <Down>
inoremap <C-A> <Home>
inoremap <C-B> <Left>
inoremap <C-F> <Right>
inoremap <C-H> <C-Left>
inoremap <C-L> <C-Right>
" since original C-E (repeat char below) is useful, remap it to <C-T>
inoremap <C-T> <C-E>
" if no Karabiner used, need this, D means command key. NOTE: HJKL need in lowercase
" D-l is occupied by gui menu, need unmap, see "gui_macvim" below
" D-h is occupied by sys menu, need unmap: System Preferences > Keyboard > shortcut > Application Shortcut > All Application > (Add) "Hide MacVim" another key
inoremap <D-k> <Up>
inoremap <D-j> <Down>
inoremap <D-h> <Left>
inoremap <D-l> <Right>
" Cancel some MacVim menu shortcut. Another way is to modify file: $VIMRUNTIME/menu.vim
if has("gui_macvim")
    "macmenu &File.Save key=<nop>
    macmenu Tools.List\ Errors key=<nop>
endif

"""""""""""""""""""""""""""""" H1 - Topic - Completion (also see 
" NOTE: iskeyword MUST after the "set nocompatible"
set iskeyword+=-
"hi Pmenu	ctermbg=White ctermfg=DarkGrey
"hi PmenuSel	ctermbg=White ctermfg=LightMagenta guibg=LightCyan guifg=LightBlue

"""" Make Completion behavior like IDE
" menu come up even if only one match.
"set completeopt=menuone
" Enter key will simply select the highlighted menu item, just as <C-Y> does
"inoremap <expr> <CR> pumvisible() ? "\<C-y>" : "\<C-g>u\<CR>"
"inoremap <expr> <CR> pumvisible() ? "\<C-y>" : "\<lt>CR>"

" keeps a menu item always highlighted. This way you can keep typing characters to narrow the matches, and the nearest match will be selected so that you can hit Enter at any time to insert it.
"inoremap <expr> <C-n> pumvisible() ? '<C-n>' : '<C-n><C-r>=pumvisible() ? "\<lt>Down>" : ""<CR>'
" open omni completion menu closing previous if open and opening new menu without changing the text
"inoremap <expr> <C-Space> (pumvisible() ? (col('.') > 1 ? '<Esc>i<Right>' : '<Esc>i') : '') . '<C-x><C-o><C-r>=pumvisible() ? "\<lt>C-n>\<lt>C-p>\<lt>Down>" : ""<CR>'
" simulates <C-X><C-O> to bring up the omni completion menu, then it simulates <C-N><C-P> to remove the longest common text, and finally it simulates <Down> again to keep a match highlighted.
"inoremap <expr> <M-,> pumvisible() ? '<C-n>' : '<C-x><C-o><C-n><C-p><C-r>=pumvisible() ? "\<lt>Down>" : ""<CR>'

"""" For Ruby
let g:rubycomplete_rails = 1
let g:rubycomplete_buffer_loading = 1
let g:rubycomplete_classes_in_global = 1


"""""""""""""""""""""""""""""" H1 - Mapping - Misc
noremap <D-r> :!source $MY_ENV/myenv_func.sh; func_run_file %:p:gs?\\?/?<Enter>
noremap <F11> :!source $MY_ENV/myenv_func.sh; func_run_file %:p:gs?\\?/?<Enter>
noremap <F12> :!source $MY_ENV/myenv_func.sh; func_run_file_format_output %:p:gs?\\?/?<Enter>

" open tmp file. Old way is 'new tab with random tempfile', but not easy to find, so change to fixed file
" D is <Command> key on osx, buts seems <D-T> is used by macvim self and not really work
" nnoremap <C-T> :exe ":tabnew " . tempname() . "-tmp"<CR>
" nnoremap <D-T> :exe ":tabnew " . tempname() . "-tmp"<CR>
nnoremap <C-T> :exe ":tabnew ~/amp/delete/vim-tmp.txt"<CR>
nnoremap <D-T> :exe ":tabnew ~/amp/delete/vim-tmp.txt"<CR>

" open new tab and with the allInOne opened, why need 2 <CR> in the end?
" failed to update to use <C-A-s>, seems vim never received 
" failed to update to use <C-S-T>, seems will override the <C-T>
" suggest not to use <A-T>, it means alt+shift+t
noremap <A-t> :tabnew<CR>:e $MY_ENV/zgen/collection_note/collection_content.txt<CR><CR>:set isfname+=:<CR>
" for line merge, not cursor after J will either on the insert blank (when vim insert one) or on the 1st char of next line (when already blank on 1st line and no need to insert)
nnoremap J JgEldw
nnoremap gJ J
" if not, the Q will enter Ex mode which seldom use
map Q gq
" exchange the */# and g*/g#
nnoremap * g*
nnoremap # g#
nnoremap g* *
nnoremap g# #

" ! hijack <Esc> seems a bad idea, makes some vim starts in REPLACE mode!
" quick way for no highlight, originally want to set noh after substitution, but seems no better way
" nnoremap <Esc> :silent noh<Bar>echo<CR>

" CTRL-V (insert mode) and SHIFT-Insert (all mode) are Paste
" NOTE: <D-V> NOT work, need <D-v> (lowercase)
map <C-V>		"+gP
map <D-v>		"+gP
map <S-Insert>		"+gP
cmap <C-V>		<C-R>+
cmap <D-v>		<C-R>+
cmap <S-Insert>		<C-R>+
imap <C-V>		<C-R>+
imap <D-v>		<C-R>+
imap <S-Insert>		<C-R>+

"""""""""""""""""""""""""""""" H1 - Mapping - Win Behave (mostly copied from mswin.vim)
behave mswin
vnoremap <C-X> "+x
vnoremap <C-C> "+y
vnoremap <C-Insert> "+y

" For CTRL-V to work autoselect must be off. On Unix we have two selections, autoselect can be used.
if !has("unix")
  set guioptions-=a
endif

" Use CTRL-Q to do what CTRL-V used to do, since CTRL-V has been used or paste
" NOTE: C-S, C-Q in many system is Stop/resume session! (which makes screen froozen!)
noremap <C-Q>		<C-V>

" Deprecated since not really used. Use CTRL-S for saving.
"noremap <C-S>		:update<CR>
"vnoremap <C-S>		<C-C>:update<CR>
"inoremap <C-S>		<C-O>:update<CR>

" NOT REALLY UNDERSTAND 
" Pasting blockwise/linewise selections is not possible in Insert/Visual mode without +virtualedit feature. 
" They are pasted as if they were characterwise instead. Uses the paste.vim autoload script.
"exe 'inoremap <script> <C-V>' paste#paste_cmd['i']
"exe 'vnoremap <script> <C-V>' paste#paste_cmd['v']
"imap <S-Insert>		<C-V>
"vmap <S-Insert>		<C-V>
"exe 'inoremap <script> <C-V>' paste#paste_cmd['i']
"exe 'vnoremap <script> <C-V>' paste#paste_cmd['v']
"imap <S-Insert>		<C-V>
"vmap <S-Insert>		<C-V>
"exe 'inoremap <script> <C-V>' paste#paste_cmd['i']
"exe 'vnoremap <script> <C-V>' paste#paste_cmd['v']
"imap <S-Insert>		<C-V>
"vmap <S-Insert>		<C-V>
"exe 'inoremap <script> <C-V>' paste#paste_cmd['i']
"exe 'vnoremap <script> <C-V>' paste#paste_cmd['v']
"imap <S-Insert>		<C-V>
"vmap <S-Insert>		<C-V>>

"""""""""""""""""""""""""""""" H1 - Mapping - Input (mswin.vim)
" Good for bash scripting, 'wb' moves cursor to the 1st char of current word
noremap ysv wbi"${<ESC>ea}"<ESC>
noremap ysV wbi${<ESC>ea}<ESC>
" mswin.vim mapped this to ^Y as undo cmd in windows, but this shield the useful auto complete cmd in vim (auto input the char above)
inoremap <C-Y> <C-Y>
noremap <C-Y> <C-Y>
noremap Y y$
" to insert a line/tab/space in normal mode
nnoremap <CR> o<Esc>
nnoremap <S-CR> O<Esc>j
nnoremap <C-CR> i<CR><Esc>
" note <C-I> equals <Tab>, so <C-I> is also mapped here!
nnoremap <Tab> i<Tab><Esc>
nnoremap <S-Tab> $F<Tab>i<Tab><Esc>
" delete by words
inoremap <C-Del> <Esc>ldwi
inoremap <C-Backspace> <Esc>ldbi
" jump by word, TODO_test_should_restore
"noremap <C-Left> b
"noremap <C-Right> e
" default C-Right goes to next line when hit line end
inoremap <C-Right> <Esc>ea
" visual selection
nnoremap <S-Right> vl
"nnoremap <C-S-Right> ve
nnoremap <S-Left> lvh
"nnoremap <C-S-Left> lvb
inoremap <S-Right> <ESC>lvl
"inoremap <C-S-Right> <ESC>lve
inoremap <S-Left> <ESC>lvh
"inoremap <C-S-Left> <ESC>lvb
vnoremap <S-Right> l
"vnoremap <C-S-Right> e
vnoremap <S-Left> h
"vnoremap <C-S-Left> b
" cut/yank in visual mode also to clipboard
vnoremap y "+y
vnoremap x "+x
vnoremap d "+d

"""""""""""""""""""""""""""""" H1 - Mapping - Tab/Window
noremap <C-Tab> gt
inoremap <C-Tab> <Esc>gt
noremap <C-S-Tab> gT
inoremap <C-S-Tab> <Esc>gT
" gnome terminator style window jump, note vim actually can not distiguish <C-H> and <C-S-H>
nnoremap <C-S-H> <C-w>h
nnoremap <C-S-J> <C-w>j
nnoremap <C-S-K> <C-w>k
nnoremap <C-S-L> <C-w>l
" gnome terminator style window adjustment, note vim actually can not distiguish <C-Left> and <C-S-Left> since depends on cursor in which window
nnoremap <C-S-Left> <C-w><
nnoremap <C-S-Right> <C-w>>
nnoremap <C-S-Up> <C-w>-
nnoremap <C-S-Down> <C-w>+

"""""""""""""""""""""""""""""" H1 - Mapping - Eclipse Simulation
" use Alt to move a line up/down as in eclipse
nnoremap <A-Down> ddp
nnoremap <A-Up> ddkP
inoremap <A-Down> <Esc>ddpi
inoremap <A-Up> <Esc>ddkPi
" copy a line as in eclipse
nnoremap <C-A-Down> yyp
nnoremap <C-A-Up> yyP
inoremap <C-A-Down> <Esc>yypi
inoremap <C-A-Up> <Esc>yyPi
"vnoremap <A-Down> ddp	
"vnoremap <A-Up> ddkP

"""""""""""""""""""""""""""""" H1 - Mapping - Commands
" the window remains, not need to 'press ...'
" %:p is filename (%) with modifier of full path (:p), use " incase have blanks
" -nargs=* means it accepts any number of parameter
"  <args> is parameter placeholder, <q-args> makes all things as in one
"  for the path, could use "C:\Windows\system32\cmd.exe" or "\%Ruby_HOME\%\bin\ruby" 

command! -nargs=1 SMultiLines		:s/<args>/&\r/g
command! -nargs=1 SMultiLinesAll	:%s/<args>/&\r/g
command! -nargs=0 OuCaa			:tabnew ~/.myenv/zgen/collection/all_content.txt

"TODO: restore mapping: 
"	redir => oldcrmap
"	map <CR>
"	redir END
"	exec "nnoremap " . substitute(oldcrmap, '[\n\*]\|n ', '', 'g')

"""""""""""""""""""""""""""""" H1 - Script

" show the diff between current buffer and the original loaded content
if !exists(":DiffOrig")
  command DiffOrig vert new | set bt=nofile | r # | 0d_ | diffthis 
  	\ | wincmd p | diffthis
endif

""" OuLineJoin: better line join
nnoremap <silent> J :call OuLineJoin()<CR>

function! OuLineJoin()
	let l:curr_line_num = line('.')

	" Check: is last line
	if l:curr_line_num == line('$')
		return
	endif

	" Check: is next line empty
	let l:next_line = getline(l:curr_line_num + 1)
	if match(l:next_line, '^\s*$') >= 0
		" minimize reg effection (better than 'norm! dd')
		silent exec l:curr_line_num+1 "delete _"
		norm! ``
		return
	endif

	" Check: is join str used
	let l:join_str = "\t"
	if match(@., '\s*/\s*') >= 0
		let l:join_str = " / "
	elseif match(@., '\s*,\s*') >= 0
		let l:join_str = ", "
	endif

	" Perform: change content, set cursor pos
	let l:curr_line = getline(l:curr_line_num)
	let l:new_curr_line = trim(l:curr_line, "\t ", 2) . l:join_str . trim(l:next_line)
	norm! $
	call setline(l:curr_line_num, l:new_curr_line)
	silent exec l:curr_line_num+1 "delete _"
	norm! ``l
endfunction

""" OuToggleWinMaxRestore: Toggle window size between maximize/restore state
"nnoremap <C-m> :call OuToggleWinMaxRestore()<CR>	" can not use C-m, which also effects the <enter> key
nnoremap <C-w>m :call OuToggleWinMaxRestore()<CR>
function! OuToggleWinMaxRestore()
	if exists('t:window_max_min_sizes') && (t:window_max_min_sizes.after == winrestcmd())
		silent! exe t:window_max_min_sizes.before
		if t:window_max_min_sizes.before != winrestcmd()
			wincmd =
		endif
		unlet t:window_max_min_sizes
	elseif winnr('$') > 1
		let t:window_max_min_sizes = { 'before': winrestcmd() }
		vert resize | resize
		let t:window_max_min_sizes.after = winrestcmd()
	endif
	normal! ze
endfunction

""" OuFilenameAsTabLabel: Use filename as tab label, excluding file path
" TODO: (on macvim) the index NOT work for either solution, NEED to set again after open 2nd tab
if has('gui_running') && has('unix')
	set showtabline=2			" always show tab line for gui version
endif
function! OuFilenameAsTabLabel()
	" Show root name in ~Oucr mode
	if exists('t:OucrRoot')
		let t:OucrTablabel = fnamemodify(t:OucrRoot,':t')
		return tabpagenr() . ":OUCR:" . t:OucrTablabel
	endif
	
	" Show tab index and filename/basename
	let bufnrlist = tabpagebuflist(v:lnum) 
	let label = bufname(bufnrlist[tabpagewinnr(v:lnum) - 1])
	let filename = v:lnum . ":" . fnamemodify(label,':t')

	" seems tabpagenr() not work in script, result will only filename without label
	"let filename = tabpagenr() . ":" . fnamemodify(label,':t')	

	return filename
endfunction
set guitablabel=%M%N:%t				" solution 1
"set guitablabel=%{OuFilenameAsTabLabel()}	" solution 2, WORKS, use function to control 

""" OuCodeReading: (short for: Oucr) use code reading mode
"command! -nargs=0 Oucr :call OucrSet()		
command! -nargs=0 OuCodeReading :call OucrSet()
function! OucrSet()
	let t:OucrRoot = expand("%:p:h")
	let t:OucrOldAcd = &autochdir
	let t:OucrOldRoot = getcwd()
	call OucrCheck()
endfunction
function! OucrCheck()
	if !(exists('t:OucrRoot'))
		return
	endif

	" update current dir and disable auto change (is "lcd" enough? since "cd" is global, "lcd" is per window)
	exec "cd ". t:OucrRoot
	set noautochdir

	" disable syntastic for mvn project, since too slow
        if(filereadable("pom.xml"))
		exec "SyntasticToggleMode"	
	endif

	" invoke again since 't:OucrRoot' might not exist before
	set guitablabel=%{OuFilenameAsTabLabel()}

	" open NERDTree if not opened
	for bufnr in tabpagebuflist()
		if bufname(bufnr) =~ "NERD_Tree_\d*"
			return
		endif
	endfor
	exec "NERDTree"				
endfunction
function! OucrRestore()
	if !(exists('t:OucrRoot'))
		return
	endif
	exec "cd ". t:OucrOldRoot
	let &autochdir = t:OucrOldAcd
endfunction
autocmd TabEnter * call OucrCheck()
autocmd TabLeave * call OucrRestore()

""" AutoHighlightToggle: Ou Toggle Auto highlight, highlight all instances of word under cursor
command! -nargs=0 AutoHighlightToggle :if AutoHighlightToggle() | :set hls | endif
function! AutoHighlightToggle()
  let @/ = ''
  if exists('#auto_highlight')
    autocmd! auto_highlight
    augroup! auto_highlight
    match none
    setl updatetime=4000
    echo 'Highlight current word: OFF'
    return 0
  else
    augroup auto_highlight
      autocmd!
      autocmd CursorMoved * exe printf('match PmenuSel /\V\<%s\>/', escape(expand('<cword>'), '/\'))
    augroup end
    setl updatetime=500
    echo 'Highlight current word: ON'
    return 1
  endif
endfunction

""" OuDimInactiveWindows: Dim inactive windows, using 'colorcolumn', 
""" usefull but 1) tends to slow down redrawing. 2) only work with lines containing text (i.e. not '~'). 
""" Based on https://groups.google.com/d/msg/vim_use/IJU-Vk-QLJE/xz4hjPjCRBUJ
augroup OuDimInactiveWindows
  au!
  au WinEnter * call s:OuDimInactiveWindows()
  au WinEnter * set cursorline
  au WinLeave * set nocursorline
augroup END
function! s:OuDimInactiveWindows()
  for i in range(1, tabpagewinnr(tabpagenr(), '$'))
    let l:range = ""
    if i != winnr()
      if &wrap
        " HACK: when wrapping lines is enabled, we use the maximum number
        " of columns getting highlighted. This might get calculated by
        " looking for the longest visible line and using a multiple of
        " winwidth().
        let l:width=256 " max
      else
        let l:width=winwidth(i)
      endif
      let l:range = join(range(1, l:width), ',')
    endif
    call setwinvar(i, '&colorcolumn', l:range)
  endfor
endfunction

""" OuCopyToClipboard: copy to clipboard instead of register, support BOTH count and motion
""" TODO: sort following stuff
" Copied from http://vim.wikia.com/wiki/Act_on_text_objects_with_custom_functions which adapted from unimpaired.vim by Tim Pope.
function! s:DoAction(algorithm,type)
  " backup settings that we will change
  let sel_save = &selection
  let cb_save = &clipboard
  " make selection and clipboard work the way we need
  set selection=inclusive clipboard-=unnamed clipboard-=unnamedplus
  " backup the unnamed register, which we will be yanking into
  let reg_save = @@
  " yank the relevant text, and also set the visual selection (which will be reused if the text needs to be replaced)
  if a:type =~ '^\d\+$'				" if type is a number, then select that many lines
    silent exe 'normal! V'.a:type.'$y'
  elseif a:type =~ '^.$'			" if type is 'v', 'V', or '<C-V>' (i.e. 0x16) then reselect the visual region
    silent exe "normal! `<" . a:type . "`>y"
  elseif a:type == 'line'			" line-based text motion
    "silent exe "normal! '[V']y"
    silent exe "normal! '[V']"
  elseif a:type == 'block'			" block-based text motion
    silent exe "normal! `[\<C-V>`]y"
  else						" char-based text motion
    silent exe "normal! `[v`]y"
  endif
  " call the user-defined function, passing it the contents of the unnamed register
  let repl = s:{a:algorithm}(@@)
  " if the function returned a value, then replace the text
  if type(repl) == 1
    " put the replacement text into the unnamed register, and also set it to be a
    " characterwise, linewise, or blockwise selection, based upon the selection type of the
    " yank we did above
    call setreg('@', repl, getregtype('@'))
    " relect the visual region and paste
    normal! gvp
  endif
  " restore saved settings and register value
  let @@ = reg_save
  let &selection = sel_save
  let &clipboard = cb_save
endfunction
function! s:ActionOpfunc(type)
  return s:DoAction(s:encode_algorithm, a:type)
endfunction
function! s:ActionSetup(algorithm)
  let s:encode_algorithm = a:algorithm
  let &opfunc = matchstr(expand('<sfile>'), '<SNR>\d\+_').'ActionOpfunc'
endfunction
function! MapAction(algorithm, key)
  exe 'nnoremap <silent> <Plug>actions'    .a:algorithm.' :<C-U>call <SID>ActionSetup("'.a:algorithm.'")<CR>g@'
  exe 'xnoremap <silent> <Plug>actions'    .a:algorithm.' :<C-U>call <SID>DoAction("'.a:algorithm.'",visualmode())<CR>'
  exe 'nnoremap <silent> <Plug>actionsLine'.a:algorithm.' :<C-U>call <SID>DoAction("'.a:algorithm.'",v:count1)<CR>'
  exe 'nmap '.a:key.'  <Plug>actions'.a:algorithm
  exe 'xmap '.a:key.'  <Plug>actions'.a:algorithm
  exe 'nmap '.a:key.a:key[strlen(a:key)-1].' <Plug>actionsLine'.a:algorithm
endfunction
function! s:ReverseString(str)
  let out = join(reverse(split(a:str, '\zs')), '')
  " Remove a trailing newline that reverse() moved to the front.
  let out = substitute(out, '^\n', '', '')
  return out
endfunction
call MapAction('ReverseString', '<leader>r')
function! s:OpenUrl(str)
  silent execute "!firefox ".shellescape(a:str, 1)
  redraw!
endfunction
call MapAction('OpenUrl','<leader>u')
function! s:ComputeMD5(str)
  let out = system('md5sum |cut -b 1-32', a:str)
  " Remove trailing newline.
  let out = substitute(out, '\n$', '', '')
  return out
endfunction
call MapAction('ComputeMD5','<leader>M')
""" NOTE: 3myj get 2 lines, my3j get 4 lines, so just always use my<motion>
function! s:CopyToClipboard(str)
  let @+ = a:str
  "echo "COPY TO CLIPBOARD: " . a:str
  "return a:str
endfunction
call MapAction('CopyToClipboard','my')
call MapAction('CopyToClipboard','mm')

""" copied from vimrc_example.vim, see comments there
if has("autocmd") && !exists("autocommands_loaded")
	let autocommands_loaded = 1
	" add to a group, and clean the previous cmds
	augroup vimrcEx							
		au!
		" goto the last position last edit before quit
		autocmd BufReadPost * if line("'\"") > 0 && line("'\"") <= line("$") | exe "normal! g`\"" | endif
	augroup END
endif


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" SETTING CANDIDATE "  
"""""""""""""""""""""

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Deprecated
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"	" Deprecated as used vim-colors-solarized
"	set diffopt=filler,iwhite,context:1000,vertical
"	hi DiffAdd	guibg=#DDDDFF guifg=#993333 gui=none	" for added lines
"	hi DiffDelete	guibg=#DDDDFF guifg=#993333 gui=none	" for delete lines
"	hi DiffChange	guibg=#EEEEFF guifg=Gray gui=none	" for identical text in changed lines
"	hi DiffText	guibg=#DDDDFF guifg=#993333 gui=none	" for different text in changed lines
"	"hi Normal guibg=grey90					" seem could use num to specify color level?
"
"	"au BufEnter <buffer> hi Comment	ctermfg=DarkGrey guifg=DarkGrey		" need this way to override the hi defined by filetype specifiy one
"	"au FileType *	hi Comment	cterm=italic ctermfg=DarkCyan gui=italic guifg=DarkCyan " seems better than line above, as could match filetype  
"	au FileType *	hi Comment	ctermbg=Grey ctermfg=DarkCyan guibg=LightGrey guifg=DarkCyan " seems better than line above, as could match filetype  
"
" Deprecated - cmd g*/g# already did this
" the vim's * add word boundary, usually I prefer not
"nnoremap * :call SearchCurrentWordWithoutBoundary()<CR>n
"function! SearchCurrentWordWithoutBoundary()
"	let @/ = '\V'.escape(expand('<cword>'), '\')
"endfunction

"Deprecated my OuCopyToClipboard
"inoremap <A-S-Y> <Esc>l"+y$
"nnoremap <A-S-Y> <Esc>"+y$
"
"Deprecated my OuCopyToClipboard
"command! -nargs=? XClipboardOriginal	:.,.+<args>-1 d + | :let @+=substitute(@+,'\_.\%$','','')
"command! -nargs=? XClipboard		:silent .,.+<args>-1 s/^\s*// | :silent execute 'normal <C-O>'| :silent .,.+<args>-1 d + | :let @+=substitute(@+,'\_.\%$','','') | :silent! /never-epect-to-exist-string
"command! -nargs=? YClipboardOriginal	:.,.+<args>-1 y + | :let @+=substitute(@+,'\_.\%$','','')
"command! -nargs=? YClipboard		:silent .,.+<args>-1 s/^\s*// | :silent execute 'normal <C-O>'| :silent .,.+<args>-1 y + | :let @+=substitute(@+,'\_.\%$','','') | :silent undo | :silent! /never-epect-to-exist-string
"
"Deprecated as moved the logic into bash function
"command! -nargs=* RInCmd		:wa | :silent	! cmd.exe		<args> "%:p" & pause
"command! -nargs=* RInBash		:wa | :silent	! bash			<args> "%:p" & pause
"command! -nargs=* RInRuby               :wa |		! bundle exec ruby	<args> "%:p"
"command! -nargs=* RInPython		:wa | :silent	! python		<args> "%:p" & pause
"command! -nargs=* RInGroovy		:wa | :silent	! groovy		<args> "%:p" & pause
"autocmd Filetype sh map <buffer> <F11> :RInBash<Enter>
"autocmd Filetype ruby map <buffer> <F11> :RInRuby<Enter>
"autocmd Filetype groovy map <buffer> <F11> :RInGroovy<Enter>
"autocmd Filetype python map <buffer> <F11> :RInPython<Enter>
"autocmd Filetype dosbatch map <buffer> <F11> :RInCmd<Enter>

" Deprecated - move to vim-oumg
"function! NoteOutline()
"	call setloclist(0, [])
"	let save_cursor = getpos(".")
"
"	call cursor(1, 1)
"	let flags = 'cW'
"	let file = expand('%')
"	"while search("^\t*[^ \t]\+$", flags) > 0					" NOT works, why?
"	"while search("^[[:space:]]*[-_\.[:alnum:]]\+[[:space:]]*$", flags) > 0		" NOT works, since vim not fully support POSIX regex syntax
"	"while search("^\t*[^ \t][^ \t]*$", flags) > 0					" works, but all Chinese becomes outline
"	while search("^\t*[-_a-z0-9\/\.][-_a-z0-9\/\.]*[\t ]*$", flags) > 0		" works, but a bit strict
"		let flags = 'W'
"		let title = substitute(getline('.'), '[ \t]*$', '', '')			" remove trailing blanks
"		let titleToShow = substitute(title, '\t', '........', 'g')		" quickfix window removes any preceding blanks
"		if titleToShow !~ "^\\." 
"			let blank = printf('%s:%d:%s', file, line('.'), "  ")
"			laddexpr blank
"		endif
"		let msg = printf('%s:%d:%s', file, line('.'), titleToShow)
"		laddexpr msg
"	endwhile
"
"	call setpos('.', save_cursor)
"	vertical lopen
"	vertical resize 40
"
"	" hide filename and line number in quickfix window, not sure how it works yet.
"	set conceallevel=2 concealcursor=nc
"	syntax match qfFileName /^.*| / transparent conceal
"	"syntax match qfFileName /^[^|]*/ transparent conceal
"endfunction
"nnoremap <silent> mo :<C-U>call NoteOutline()<CR>

" Since 7.3, not work anymore
""" Some settings on diff, not really understand
"set diffexpr=MyDiff()
"function MyDiff()
"  let opt = '-a --binary '
"  if &diffopt =~ 'icase' | let opt = opt . '-i ' | endif
"  if &diffopt =~ 'iwhite' | let opt = opt . '-b ' | endif
"  let arg1 = v:fname_in
"  if arg1 =~ ' ' | let arg1 = '"' . arg1 . '"' | endif
"  let arg2 = v:fname_new
"  if arg2 =~ ' ' | let arg2 = '"' . arg2 . '"' | endif
"  let arg3 = v:fname_out
"  if arg3 =~ ' ' | let arg3 = '"' . arg3 . '"' | endif
"  let eq = ''
"  if $VIMRUNTIME =~ ' '
"    if &sh =~ '\<cmd'
"      let cmd = '""' . $VIMRUNTIME . '\diff"'
"      let eq = '"'
"    else
"      let cmd = substitute($VIMRUNTIME, ' ', '" ', '') . '\diff"'
"    endif
"  else
"    let cmd = $VIMRUNTIME . '\diff'
"  endif
"  silent execute '!' . cmd . ' ' . opt . arg1 . ' ' . arg2 . ' > ' . arg3 . eq
"endfunction
"
" WINDOWNS map: Some win behavior seems not really used
" backspace in Visual mode deletes selection
"vnoremap <BS> d
" CTRL-Z is Undo; not in cmdline though
"noremap <C-Z> u
"inoremap <C-Z> <C-O>u
" CTRL-F4 is Close window
"noremap <C-F4> <C-W>c
"inoremap <C-F4> <C-O><C-W>c
"cnoremap <C-F4> <C-C><C-W>c
"onoremap <C-F4> <C-C><C-W>c
" Select all, BUT seems the orginal increment is more useful
"noremap <C-A> gggH<C-O>G		
"inoremap <C-A> <C-O>gg<C-O>gH<C-O>G
"cnoremap <C-A> <C-C>gggH<C-O>G
"onoremap <C-A> <C-C>gggH<C-O>G
"snoremap <C-A> <C-C>gggH<C-O>G
"xnoremap <C-A> <C-C>ggVG

"""""""""""""""""""""""""""""" H1 - Plugins
"""""""" vim-easymotion@vim
let g:EasyMotion_smartcase = 1
nmap , <Plug>(easymotion-s)
inoremap ,, <ESC><Plug>(easymotion-s)

"""""""" vim-islime2@vim
let g:islime2_29_mode=1
"nnoremap <silent> <D-CR> :ISlime2CurrentLine<CR>	" 官方文档中提供的这个命令，会把开关的Tab也送过去，导致大量的tab输入给iTerm
nnoremap <silent> <D-CR> :call islime2#iTermSendNext(substitute(trim(getline('.')),'\s*#.*$','',''))<CR>
vnoremap <silent> <D-CR> :<C-u>call islime2#iTermSendOperator(visualmode(), 1)<CR>

"""""""" vim-surround@vim
" 'v(118)/V(86)' (like B for {}) to surround word into shell var with/out quote
"autocmd FileType sh let b:surround_118 = "\"${\r}\""
let g:surround_86 = "${\r}"
let g:surround_118 = "\"${\r}\""

"""""""" pathogen@vim
"if filereadable("~/.vim/autoload/pathogen.vim")	" NOT work
if !empty(glob("~/.vim/autoload/pathogen.vim"))
	execute pathogen#infect()
endif

"""""""" solarized@vim
let g:solarized_italic = 0				" 0 to set comment font NOT use italic
colorscheme solarized

"""""""""""""""""""""""""""""" H1 - Color - Terminal Mode (NEED after colorscheme)
" Works, any better solution?
let g:terminal_ansi_colors = [
  \'#282828', '#CC241D', '#98971A', '#D79921',
  \'#458588', '#B16286', '#689D6A', '#D65D0E',
  \'#fb4934', '#b8bb26', '#fabd2f', '#83a598',
  \'#d3869b', '#8ec07c', '#fe8019', '#FBF1C7' ]
highlight Terminal guibg='#282828' guifg='#ebdbb2'

"""""""" NERDCommenter@vim
let NERDSpaceDelims = 1					" add space for comment
let NERDTreeWinSize = 45				" tree window width, default is 31

"""""""" Ctrlp@vim
"let g:ctrlp_cmd = 'CtrlPMixed'				" Good but too noise: search in Files, Buffers and MRU files at the same time.
"let g:ctrlp_user_command = 'find %s -type f'		" custom option for finding files
"let g:ctrlp_root_markers = ['pom.xml', '.p4ignore']	" for root finder, add additional indicators, default is: .git .hg .svn .bzr _darcs
let g:ctrlp_regexp = 1					" 1 to set regexp search as the default
let g:ctrlp_by_filename = 1				" default to use filename mode
let g:ctrlp_show_hidden = 1				" also show dotfiles and dotdirs
let g:ctrlp_working_path_mode = 0			" not manage the root, will use the :pwd as root
let g:ctrlp_custom_ignore = {
	\ 'dir':  '\v[\/]\.(git|hg|svn|idea|metadata)$|\/target$',
	\ 'file': '\v\.(exe|so|dll|class|jar|svn-base)$',
	\ 'link': 'SOME_BAD_SYMBOLIC_LINKS',
	\ }

"""""""" EasyTags@vim
" "tags" is a Vim buildin setting to locate tags file(s), relative to working dir or buffer (using a leading ./)
" 1) ./.vimtags	means find file with name ".vimtags" in dir of current file
" 2) .vimtags	means find file with name ".vimtags" in working directory
" 3) /		means keep looking up and up until reach /
set tags=./.vimtags,.vimtags;/
let g:easytags_dynamic_files = 2 			" seems tag files are big, separate them by project

"let g:easytags_autorecurse = 1				" never set this, which cause frozen (e.g. save .vimrc will gen tag for whole $HOME)
"let g:easytags_events = ['BufWritePost']
let g:easytags_events = []				" do NOT gen tag, unless I invoke :UpdateTags
let g:easytags_autorecurse = 1				" make -R as default
let g:easytags_always_enabled = 0			" do NOT gen tag, unless I invoke :UpdateTags
let g:easytags_auto_highlight = 0
let g:easytags_include_members = 1
let g:easytags_cmd = '/opt/local/bin/ctags'

"""""""" Tabular@vim
" auto alignment when input "|". Copied from tabular doc, but NOT work, why?
"inoremap <silent> <Bar> <Bar><Esc>:call <SID>align()<CR>a
"function! s:align()
"  let p = '^\s*|\s.*\s|\s*$'
"  if exists(':Tabularize') && getline('.') =~# '^\s*|' && (getline(line('.')-1) =~# p || getline(line('.')+1) =~# p)
"    let column = strlen(substitute(getline('.')[0:col('.')],'[^|]','','g'))
"    let position = strlen(matchstr(getline('.')[0:col('.')],'.*|\s*\zs.*'))
"    Tabularize/|/l1
"    normal! 0
"    call search(repeat('[^|]*|',column).'\s\{-\}'.repeat('.',position),'ce',line('.'))
"  endif
"endfunction

"""""""" netrw
" Use whole "words" when opening URLs. This avoids cutting off parameters (after '?') and anchors (after '#'). See http://vi.stackexchange.com/q/2801/1631
 let g:netrw_gx="<cWORD>"                                                                                                                   
" Option 1, disable file creation of .netrwhist
let g:netrw_dirhistmax=0
" Option 2, disable file creation of .netrwhist
" au VimLeave * if filereadable("~/.vim/.netrwhist") | call delete("~/.vim/.netrwhist") | endif 

"""""""" syntastic@vim
" TODO: try async alternative on vim8: ale
"let g:syntastic_aggregate_errors = 1					" display together the errors found by all checkers
"let g:syntastic_always_populate_loc_list = 1				" Always update location list (update only after ':Errors' cmd by default, to minimise conflicts with other plugins)
""let g:syntastic_quiet_messages = { "type": "style" }			" filter out some messages types
"let g:syntastic_php_checkers = ['php', 'phpcs', 'phpmd']		" checker chain, run one by one (only run laters if current success)
let g:syntastic_auto_jump = 2						" jump to 1st error (NOT warning)
let g:syntastic_sh_checkers=['shellcheck']				" syntastic@vim, sub section 'bash'
let g:syntastic_sh_shellcheck_args=['-fgcc']				" syntastic@vim, sub section 'bash'
let g:syntastic_python_checkers=['pyflakes']				" syntastic@vim, sub section 'python'
let g:syntastic_html_checkers=['tidy', 'jshint']
let g:syntastic_javascript_checkers = ['eslint']			" syntastic@vim, sub section 'javascript'

"""""""" auto-format@vim, @astyle
let g:formatprg_c = "astyle"
let g:formatprg_args_c = "--mode=c --style=ansi"
let g:formatprg_java = "astyle"
let g:formatprg_args_java = "--style=java --mode=java --indent=tab --pad-oper --unpad-paren --add-brackets"

"""""""" YouCompleteMe@vim >> Deprecated by ~coc.nvim@vim
"highlight Pmenu ctermfg=2 ctermbg=3 guifg=#005f87 guibg=#EEE8D5	" 菜单补全菜单配色
"highlight PmenuSel ctermfg=2 ctermbg=3 guifg=#AFD700 guibg=#106900	" 选中项补全菜单配色
"let g:ycm_complete_in_comments=1					" 补全功能在注释中同样有效
"let g:ycm_confirm_extra_conf=0						" 允许 vim 加载 .ycm_extra_conf.py 文件，不再提示
"let g:ycm_collect_identifiers_from_tags_files=1			" 开启 YCM 标签补全引擎
"set tags+=/data/misc/software/misc./vim/stdcpp.tags			" 引入 C++ 标准库tags
"inoremap <leader>; <C-x><C-o>						" YCM 集成 OmniCppComplete 补全引擎，设置其快捷键
"set completeopt-=preview						" 补全内容不以分割子窗口形式出现，只显示补全列表
"let g:ycm_min_num_of_chars_for_completion=1				" 从第一个键入字符就开始罗列匹配项
"let g:ycm_cache_omnifunc=0						" 禁止缓存匹配项，每次都重新生成匹配项
"let g:ycm_seed_identifiers_with_syntax=1				" 语法关键字补全         
"let g:ycm_server_keep_logfiles = 1					" server keeps log, so could use :YcmDebugInfo to check crash info

"""""""" vim-go@vim
let g:go_def_mapping_enabled = 0					" disable vim-go :GoDef shortcut (gd). Will use coc.nvim@vim for this.
let g:go_metalinter_autosave = 1					" call :GoMetaLinter on save
let g:go_auto_type_info = 1						" always show :GoInfo in status line (DISABLE THIS IF FEEL SLOW, and use :GoSameIds manually)
"let g:go_auto_sameids = 1						" always highlight same identifier (DISABLE THIS IF FEEL SLOW, and use :GoSameIds manually), 实际使用好像有bug。会有一堆的黄色高亮显示，且错位

"""""""" coc.nvim@vim
"mostly from coc.nvim default settings
set hidden								" if hidden is not set, TextEdit might fail.
set updatetime=300							" Smaller updatetime for CursorHold & CursorHoldI
set shortmess+=c							" don't give |ins-completion-menu| messages.
set signcolumn=yes							" always show signcolumns, otherwise it would shift the text each time diagnostics appear/become resolved.
"set cmdheight=2							" Better display for messages >> use it when really needed
"set nobackup								" already set
"set nowritebackup							" already set

let g:coc_disable_startup_warning = 1
if exists('g:did_coc_loaded')
	" Highlight the symbol and its references when holding the cursor.
	autocmd CursorHold * silent call CocActionAsync('highlight')
endif

" When suggestion shows, use tab for navigate. Use <c-space> to trigger completion.
inoremap <silent><expr>  <TAB> pumvisible() ? "\<C-n>" : "\<TAB>"
inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"
inoremap <silent><expr> <c-space> coc#refresh()

" CMD: command to Format/Fold/OrganizeImports for current buffer.
command! -nargs=0 Format :call CocAction('format')
command! -nargs=? Fold   :call CocAction('fold', <f-args>)
command! -nargs=0 OR     :call CocAction('runCommand', 'editor.action.organizeImport')

" EDIT: Symbol renaming.
nmap <leader>rn <Plug>(coc-rename)
" EDIT: Formatting selected code.
xmap <leader>f  <Plug>(coc-format-selected)
nmap <leader>f  <Plug>(coc-format-selected)
" EDIT: Apply AutoFix to problem on the current line.
nmap <leader>qf  <Plug>(coc-fix-current)

" JUMP: Use `[g` and `]g` to navigate diagnostics
nmap <silent> [g <Plug>(coc-diagnostic-prev)
nmap <silent> ]g <Plug>(coc-diagnostic-next)
" JUMP: GoTo code navigation.
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)

" Introduce function text object. NOTE: Requires 'textDocument.documentSymbol' support from the language server.
xmap if <Plug>(coc-funcobj-i)
xmap af <Plug>(coc-funcobj-a)
omap if <Plug>(coc-funcobj-i)
omap af <Plug>(coc-funcobj-a)

" VIEW: Use K to show documentation in preview window.
nnoremap <silent> K :call <SID>show_documentation()<CR>
function! s:show_documentation()
  if (index(['vim','help'], &filetype) >= 0)
    execute 'h '.expand('<cword>')
  else
    call CocAction('doHover')
  endif
endfunction

" <cr> to confirm, `<C-g>u` means break undo chain at current position. Coc only does snippet and additional edit on confirm.
if exists('*complete_info')
  inoremap <expr> <cr> complete_info()["selected"] != "-1" ? "\<C-y>" : "\<C-g>u\<CR>"
else
  inoremap <expr> <cr> pumvisible() ? "\<C-y>" : "\<C-g>u\<CR>"
  "inoremap <expr> <CR> pumvisible() ? "\<C-y>" : "\<lt>CR>"
endif

augroup mygroup
  autocmd!
  " Setup formatexpr specified filetype(s).
  autocmd FileType typescript,json setl formatexpr=CocAction('formatSelected')
  " Update signature help on jump placeholder.
  autocmd User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')
augroup end
