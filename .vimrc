if exists('loaded_settings_of_stico')
    finish
endif
let loaded_settings_of_stico = 1


"""""""""""""""""""""""""""""" H1 - 
set nocompatible		" This might reset some settings (e.g. "iskeyword"), so should happen in the beginning. 

"""""""""""""""""""""""""""""" H1 - Topic - Font
if has('gui_running') && has('unix')
	set lines=25 columns=100
	set guifont=XHei\ Mono\ 12
endif
nnoremap <A-+> :silent! let &guifont = substitute(&guifont, '\zs\d\+', '\=eval(submatch(0)+1)', 'g')<CR><CR>
nnoremap <A--> :silent! let &guifont = substitute(&guifont, '\zs\d\+', '\=eval(submatch(0)-1)', 'g')<CR><CR>


"""""""""""""""""""""""""""""" H1 - Input Method
" Option 1: FCITX, slow version, use fcitx.vim if need faster: http://www.vim.org/scripts/script.php?script_id=3764
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

" Option 2: ibus, Need vim-ibus interface to use
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

"""""""""""""""""""""""""""""" H1 - Plugins
"""""""" Pathogen
call pathogen#infect()

"""""""" Solarized
let g:solarized_italic = 0				" 0 to set comment font NOT use italic
colorscheme solarized

"""""""" NERDCommenter
let NERDSpaceDelims = 1					" add space for comment
let NERDTreeWinSize = 45				" tree window width, default is 31

"""""""" Ctrlp
"let g:ctrlp_cmd = 'CtrlPMixed'				" Good but too noise: search in Files, Buffers and MRU files at the same time.
"let g:ctrlp_user_command = 'find %s -type f'		" custom option for finding files
let g:ctrlp_regexp = 1					" 1 to set regexp search as the default
let g:ctrlp_show_hidden = 1
let g:ctrlp_working_path_mode = 0			" not manage the root, will use the :pwd as root
let g:ctrlp_custom_ignore = {
	\ 'dir':  '\v[\/]\.(git|hg|svn|metadata)$|\/target$',
	\ 'file': '\v\.(exe|so|dll|class|jar|svn-base)$',
	\ 'link': 'SOME_BAD_SYMBOLIC_LINKS',
	\ }

"""""""" netrw
" Option 1, disable file creation of .netrwhist
let g:netrw_dirhistmax=0
" Option 2, disable file creation of .netrwhist
" au VimLeave * if filereadable("~/.vim/.netrwhist") | call delete("~/.vim/.netrwhist") | endif 

"""""""" syntastic
"let g:syntastic_aggregate_errors = 1				" display together the errors found by all checkers
"let g:syntastic_always_populate_loc_list = 1			" Always update location list (update only after ':Errors' cmd by default, to minimise conflicts with other plugins)
""let g:syntastic_quiet_messages = { "type": "style" }		" filter out some messages types
"let g:syntastic_php_checkers = ['php', 'phpcs', 'phpmd']	" checker chain, run one by one (only run laters if current success)
let g:syntastic_auto_jump = 2					" jump to 1st error (NOT warning)

"""""""" AutoFormat/auto-format, @astyle
let g:formatprg_c = "astyle"
let g:formatprg_args_c = "--mode=c --style=ansi"
let g:formatprg_java = "astyle"
let g:formatprg_args_java = "--style=java --mode=java --indent=tab --pad-oper --unpad-paren --add-brackets"

"""""""""""""""""""""""""""""" H1 - Indent
"au BufRead,BufNewFile jquery.*.js set filetype=javascript syntax=jquery 
"au FileType javascript set expandtab tabstop=4 shiftwidth=4 

"""""""""""""""""""""""""""""" H1 - Topic - auto save
au FocusLost * silent! wa
set autowriteall

"""""""""""""""""""""""""""""" H1 - Settings - Misc
filetype plugin indent on				" type detection, language-dependent indenting
set dictionary+=$MY_ENV/list/words_us
set nobackup						" won't leave additional file(s) after close VIM
set nowritebackup					" default is :set writebackup, will keep a backup file while file is being worked. Once VIM is closed; the backup will vanish.
set noswapfile						" (1) Keep in mind that this option will keep everything in memory. (2) Don't use this for big files, will be memeory consuming and Recovery will be impossible! (3) In essence; if security is a concern, use this option
set autoindent						" autoindent the new line to the previous one
set history=50						" set the cmd history
set ruler						" show the current position in the bottom
set showcmd						" show the cmd in the bottom, like 'dw'
set nowrap						" wrap/nowrap the line
set linebreak						" won't break words as wrapping a line, need wrap set
set cursorline						" highlight current line
set gdefault						" make substitute g flag default on
set shell=bash						" use bash as shell for :!
set autochdir						" automatically change current dir

"MNT: using quickfix@vim
set grepprg=\\cd\ $PWD;\\grep\ -rIinH\ --color\ --exclude-dir=\\.{svn,git,bzr,hg,metadata}\ --exclude-dir=target
"MNT: in OUCR mode, %:p:h not the "root", should use $PWD instead
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
set infercase						" won't change exist case for ^n, need ignorecase open

"""""""""""""""""""""""""""""" H1 - Settings - Encoding
"set fileencodings=utf-8,gbk,ucs-bom,cp936		" set the encodings, it is the sequence vim will try to open a doc
set encoding=utf-8					" fix the encodings
set fileencoding=utf-8					" fix the fileencoding
set viminfo=						" don't want .viminfo everywhere

"""""""""""""""""""""""""""""" H1 - Settings - Key Charaters
"set isfname+=32,38,40,41,44				make the { },{&},{(},{)},{,} as a part of file name, this will be useful for vim cmd gf to go to a file
"set isfname+=32					" make " " as part of filename, gf (goto file) use it
"set isfname+=44					" make (,) as part of filename, gf (goto file) use it
set isfname-=:						" make ":" NOT a part of the filename, gf (goto file) use it

"""""""""""""""""""""""""""""" H1 - Settings - GUI
set guioptions-=m					" no menu
set guioptions-=T					" no toolbar
set guioptions+=b					" always show buttom scroll-bar
set mousehide						" Hide the mouse when typing text

"""""""""""""""""""""""""""""" H1 - Settings - Movement
set whichwrap+=<,>,[,]					" make the left/right could go cross line in Normal/Visual & Insert/Replace mode
set whichwrap+=h,l					" make the h/l also
set backspace=indent,eol,start				" backspace and cursor keys wrap to previous /next line


"""""""""""""""""""""""""""""" H1 - Mapping - Disable Useless keys
inoremap <F1> <ESC>
nnoremap <F1> <ESC>
vnoremap <F1> <ESC>

"""""""""""""""""""""""""""""" H1 - Mapping - move in insert mode
inoremap <C-H> <Left>
inoremap <C-J> <Down>
inoremap <C-K> <Up>
inoremap <C-L> <Right>

"""""""""""""""""""""""""""""" H1 - Topic - Completion
" NOTE: iskeyword MUST after the "set nocompatible"
set iskeyword+=-
"set iskeyword+=.
hi Pmenu	ctermbg=White ctermfg=DarkGrey
hi PmenuSel	ctermbg=White ctermfg=LightMagenta guibg=LightCyan guifg=LightBlue

"""" Make Completion behavior like IDE
" menu come up even if only one match.
set completeopt=menuone
" Enter key will simply select the highlighted menu item, just as <C-Y> does
"inoremap <expr> <CR> pumvisible() ? "\<C-y>" : "\<C-g>u\<CR>"
inoremap <expr> <CR> pumvisible() ? "\<C-y>" : "\<lt>CR>"
" the IDE way of completion, 2nd line is for terminal mapping
imap <C-Space> <C-x><C-o>
imap <C-@> <C-Space>

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
noremap <F11> :!source $MY_ENV/myenv_func.sh; func_run_file %:p:gs?\\?/?<Enter>
noremap <F12> :!source $MY_ENV/myenv_func.sh; func_run_file_format_output %:p:gs?\\?/?<Enter>
noremap <C-T> :tabnew<CR>
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

"""""""""""""""""""""""""""""" H1 - Mapping - Win Behave (mostly copied from mswin.vim)
behave mswin
" CTRL-X and SHIFT-Del are Cut
vnoremap <C-X> "+x
" CTRL-C and CTRL-Insert are Copy
vnoremap <C-C> "+y
vnoremap <C-Insert> "+y
" CTRL-V (insert mode) and SHIFT-Insert (all mode) are Paste
map <C-V>		"+gP
map <S-Insert>		"+gP
cmap <C-V>		<C-R>+
cmap <S-Insert>		<C-R>+
" Pasting blockwise/linewise selections is not possible in Insert/Visual mode without +virtualedit feature. They are pasted as if they were characterwise instead. Uses the paste.vim autoload script.
exe 'inoremap <script> <C-V>' paste#paste_cmd['i']
exe 'vnoremap <script> <C-V>' paste#paste_cmd['v']
imap <S-Insert>		<C-V>
vmap <S-Insert>		<C-V>
exe 'inoremap <script> <C-V>' paste#paste_cmd['i']
exe 'vnoremap <script> <C-V>' paste#paste_cmd['v']
imap <S-Insert>		<C-V>
vmap <S-Insert>		<C-V>
exe 'inoremap <script> <C-V>' paste#paste_cmd['i']
exe 'vnoremap <script> <C-V>' paste#paste_cmd['v']
imap <S-Insert>		<C-V>
vmap <S-Insert>		<C-V>
exe 'inoremap <script> <C-V>' paste#paste_cmd['i']
exe 'vnoremap <script> <C-V>' paste#paste_cmd['v']
imap <S-Insert>		<C-V>
vmap <S-Insert>		<C-V>>

" Use CTRL-Q to do what CTRL-V used to do, since CTRL-V has been used or paste
" Use CTRL-S for saving, also in Insert mode
" NOTE: C-S, C-Q in many system is Stop/resume session! (which makes screen froozen!)
noremap <C-Q>		<C-V>
noremap <C-S>		:update<CR>
vnoremap <C-S>		<C-C>:update<CR>
inoremap <C-S>		<C-O>:update<CR>
" For CTRL-V to work autoselect must be off. On Unix we have two selections, autoselect can be used.
if !has("unix")
  set guioptions-=a
endif

"""""""""""""""""""""""""""""" H1 - Mapping - Input
" mswin.vim mapped this to ^Y as undo cmd in windows, but this shield the useful auto complete cmd in vim (auto input the char above)
inoremap <C-Y> <C-Y>
noremap <C-Y> <C-Y>
" for copy 
noremap Y y$
inoremap <A-S-Y> <Esc>l"+y$
nnoremap <A-S-Y> <Esc>"+y$
" to insert a line/tab/space in normal mode
nnoremap <CR> o<Esc>
nnoremap <S-CR> O<Esc>j
nnoremap <C-CR> i<CR><Esc>
" note <C-I> equals <Tab>, so <C-I> is also mapped here!
nnoremap <Tab> i<Tab><Esc>
nnoremap <S-Tab> $F<Tab>i<Tab><Esc>
nnoremap <Space> i<Space><Esc>
" delete by words
inoremap <C-Del> <Esc>ldwi
inoremap <C-Backspace> <Esc>ldbi
noremap <C-Left> b
noremap <C-Right> w
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
" y in visual mode also copy to clipboard
vnoremap y "+y
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
"nnoremap <C-m> :call WindowMaxMinToggle()<CR>	" can not use C-m, which also effects the <enter> key
nnoremap <C-w>m :call WindowMaxMinToggle()<CR>

"""""""""""""""""""""""""""""" H1 - Mapping - Jump
" <C-I> equals <Tab>, since <Tab> is mapped in normal mode, need another key for function "jump next",  C-N in normal mode is useless, so use it
nnoremap <C-N> <C-I>


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
"  <args> is parameter placeholder, <p-args> makes all things as in one
"  for the path, could use "C:\Windows\system32\cmd.exe" or "\%Ruby_HOME\%\bin\ruby" 

command! -nargs=1 SMultiLines		:s/<args>/&\r/g
command! -nargs=1 SMultiLinesAll	:%s/<args>/&\r/g
command! -nargs=? XClipboardOriginal	:.,.+<args>-1 d + | :let @+=substitute(@+,'\_.\%$','','')
command! -nargs=? XClipboard		:silent .,.+<args>-1 s/^\s*// | :silent execute 'normal <C-O>'| :silent .,.+<args>-1 d + | :let @+=substitute(@+,'\_.\%$','','') | :silent! /never-epect-to-exist-string
command! -nargs=? YClipboardOriginal	:.,.+<args>-1 y + | :let @+=substitute(@+,'\_.\%$','','')
command! -nargs=? YClipboard		:silent .,.+<args>-1 s/^\s*// | :silent execute 'normal <C-O>'| :silent .,.+<args>-1 y + | :let @+=substitute(@+,'\_.\%$','','') | :silent undo | :silent! /never-epect-to-exist-string

"TODO: restore mapping: 
"	redir => oldcrmap
"	map <CR>
"	redir END
"	exec "nnoremap " . substitute(oldcrmap, '[\n\*]\|n ', '', 'g')
"TODO: just for try, delete later
"autocmd BufWinEnter quickfix silent! unmap <CR>
"autocmd BufWinEnter quickfix silent! nnoremap <ESC> :q<CR>
"autocmd BufWinEnter quickfix let g:qfix_win = bufnr("$")
"autocmd BufWinLeave * if exists("g:qfix_win") && expand("<abuf>") == g:qfix_win | unlet! g:qfix_win | exec "unmap <ESC>" | exec "nnoremap <CR> o<Esc>" | endif
"
"autocmd BufWinLeave quickfix silent! nnoremap <CR> o<Esc>
"autocmd BufWinLeave quickfix silent! unmap <ESC>
"autocmd FileType qf silent! unmap <CR>
"autocmd FileType qf silent! nnoremap <ESC> :q<CR>

"""""""""""""""""""""""""""""" H1 - Script

" Deprecated - cmd g*/g# already did this
" the vim's * add word boundary, usually I prefer not
"nnoremap * :call SearchCurrentWordWithoutBoundary()<CR>n
"function! SearchCurrentWordWithoutBoundary()
"	let @/ = '\V'.escape(expand('<cword>'), '\')
"endfunction

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

"""
function WindowMaxMinToggle()
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

""" OnlyFileNameInTab is for showing only the filename, excluding the path
set guitablabel=%{OnlyFileNameInTab()}		" invoke the function
function OnlyFileNameInTab()
	" Show root name in ~Oucr mode
	if exists('t:OucrRoot')
		let t:OucrTablabel = fnamemodify(t:OucrRoot,':t')
		return tabpagenr() . ":OUCR:" . t:OucrTablabel
	endif
	
	" Show tab index and filename/basename
	let bufnrlist = tabpagebuflist(v:lnum) 
	let label = bufname(bufnrlist[tabpagewinnr(v:lnum) - 1])
	let filename = tabpagenr() . ":" . fnamemodify(label,':t')

	return filename
endfunction

" code reading mode 
command! -nargs=0 OucrSet :call OucrSet()
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
	exec "cd ". t:OucrRoot
	set noautochdir

	" disable syntastic for mvn project, since too slow
        if(filereadable("pom.xml"))
		exec "SyntasticToggleMode"	
	endif

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

" Highlight all instances of word under cursor, when idle. Useful when studying strange source code.
command! -nargs=0 TAutoHighLight :if ToggleAutoHighlight() | :set hls | endif
function! ToggleAutoHighlight()
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

" Dim inactive windows, using 'colorcolumn', usefull but 1) tends to slow down redrawing. 2) only work with lines containing text (i.e. not '~'). Based on https://groups.google.com/d/msg/vim_use/IJU-Vk-QLJE/xz4hjPjCRBUJ
function! s:DimInactiveWindows()
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
augroup DimInactiveWindows
  au!
  au WinEnter * call s:DimInactiveWindows()
  au WinEnter * set cursorline
  au WinLeave * set nocursorline
augroup END

"""""""""""""""""""""""""""""" H1 - Mapping - FileType based mapping
function! NoteOutline()
	call setloclist(0, [])
	let save_cursor = getpos(".")

	call cursor(1, 1)
	let flags = 'cW'
	let file = expand('%')
	"while search("^\t*[^ \t]\+$", flags) > 0					" NOT works, why?
	"while search("^[[:space:]]*[-_\.[:alnum:]]\+[[:space:]]*$", flags) > 0		" NOT works, since vim not fully support POSIX regex syntax
	"while search("^\t*[^ \t][^ \t]*$", flags) > 0					" works, but all Chinese becomes outline
	while search("^\t*[-_a-z0-9\/\.][-_a-z0-9\/\.]*[\t ]*$", flags) > 0		" works, but a bit strict
		let flags = 'W'
		let title = substitute(getline('.'), '[ \t]*$', '', '')			" remove trailing blanks
		let titleToShow = substitute(title, '\t', '........', 'g')		" quickfix window removes any preceding blanks
		if titleToShow !~ "^\\." 
			let blank = printf('%s:%d:%s', file, line('.'), "  ")
			laddexpr blank
		endif
		let msg = printf('%s:%d:%s', file, line('.'), titleToShow)
		laddexpr msg
	endwhile

	call setpos('.', save_cursor)
	vertical lopen
	vertical resize 40

	" hide filename and line number in quickfix window, not sure how it works yet.
	set conceallevel=2 concealcursor=nc
	syntax match qfFileName /^.*| / transparent conceal
	"syntax match qfFileName /^[^|]*/ transparent conceal
endfunction
nnoremap <silent> mo :<C-U>call NoteOutline()<CR>

" Works for "[Quickfix List]": keep cursor in quickfix window and show content above 
" Works for "[Location List]": jump to corresponding location (loc window closed). (how it works?)
au FileType qf nmap <buffer> <esc> :close<cr>
au FileType qf nmap <buffer> <cr> <cr>zz<c-w><c-p>
" Deprecated by above lines
""autocmd BufWinEnter quickfix silent! nnoremap <ESC> :q<CR>
""autocmd BufWinEnter quickfix silent! exec "unmap <CR>" | exec "nnoremap <CR> <CR>:bd ". g:qfix_win . "<CR>zt"	" seems not need delete the buffer anymore (because of what? vim updates? plugin updates?)
"autocmd BufWinEnter "Location List" let g:qfix_win = bufnr("$")
"autocmd BufWinEnter "Location List" silent! nnoremap <ESC> :exec "bd " . g:qfix_win<CR>
"autocmd BufWinEnter "Location List" silent! exec "unmap <CR>" | exec "nnoremap <CR> <CR>zt"
"autocmd BufLeave * if exists("g:qfix_win") && expand("<abuf>") == g:qfix_win | unlet! g:qfix_win | exec "unmap <ESC>" | exec "nnoremap <CR> o<Esc>" | endif
"autocmd BufWinLeave * if exists("g:qfix_win") && expand("<abuf>") == g:qfix_win | unlet! g:qfix_win | exec "unmap <ESC>" | exec "nnoremap <CR> o<Esc>" | endif	" use BufLeave, seems BufWinLeave NOT triggered when hit <Enter> in outline(quickfix) window

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" SETTING CANDIDATE "  
"""""""""""""""""""""
" show the diff between current buffer and the original loaded content
if !exists(":DiffOrig")
  command DiffOrig vert new | set bt=nofile | r # | 0d_ | diffthis 
  	\ | wincmd p | diffthis
endif
" In many terminal emulators the mouse works just fine, thus enable it.
if has('mouse')
  set mouse=a
endif

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

