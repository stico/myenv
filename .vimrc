if exists('loaded_settings_of_stico')
    finish
endif
let loaded_settings_of_stico = 1

"source $VIMRUNTIME/vimrc_example.vim		"content is already joined
"source $VIMRUNTIME/mswin.vim			"content is already joined


""""""""""""""""""""Tmp for Test""""""""""""""""""""
""""""""""""""""""""Tmp for Test""""""""""""""""""""

"""""""""""""""""""""""""""""" H1 - Input Method
" Note: this only works with compile option +xim in GUI version
if has("gui_running")
	set imactivatekey=S-C-space
	inoremap <ESC> <ESC>:set iminsert=0<CR>
endif

"""""""""""""""""""""""""""""" H1 - Syntax
syntax on						" switch syntax highlighting on
if has('gui_running')
    set background=light
else
    set background=dark
endif


"""""""""""""""""""""""""""""" H1 - Plugins
call pathogen#infect()

let g:solarized_italic = 0				" 0 to set comment font NOT use italic
colorscheme solarized

let g:ctrlp_regexp = 1					" 1 to set regexp search as the default
let g:ctrlp_working_path_mode = 0			" not manage the root, will use the :pwd as root
let g:ctrlp_custom_ignore = {
	\ 'dir':  '/\.(git\|hg\|svn\|metadata)$\|/target/\|\\target\\',
	\ 'file': '\.(exe\|so\|dll\|class\|jar\|svn-base)$',
	\ 'link': 'some_bad_symbolic_links',
	\ }

" disable the creation
" Option 1
let g:netrw_dirhistmax=0
" Option 2
" au VimLeave * if filereadable("~/.vim/.netrwhist") | call delete("~/.vim/.netrwhist") | endif 

"""""""""""""""""""""""""""""" H1 - Indent
"au BufRead,BufNewFile jquery.*.js set filetype=javascript syntax=jquery 
"au FileType javascript set expandtab tabstop=4 shiftwidth=4 


"""""""""""""""""""""""""""""" H1 - Topic - Completion
set iskeyword+=45			" make "-" as part of word, auto complete (^N^P) use it
"set iskeyword+=46			" make "." as part of word, auto complete (^N^P) use it
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


"""""""""""""""""""""""""""""" H1 - Topic - auto save
au FocusLost * silent! wa
set autowriteall


"""""""""""""""""""""""""""""" H1 - Settings - Misc
set dictionary+=$MY_ENV/list/words_us
set nocompatible					" very important for vim, since we are using vim, not vi
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
"set shell=bash\ --login				" make :! will source .bashrc everytime
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
set isfname+=32						" make " " as part of filename, gf (goto file) use it
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

"""""""""""""""""""""""""""""" H1 - Mapping - Misc
noremap <F11> :!source $MY_ENV/env_func_bash; func_run_file %:p <Enter>
noremap <C-T> :tabnew<CR>
" open new tab and with the allInOne opened, why need 2 <CR> in the end?
" failed to update to use <C-A-s>, seems vim never received 
" failed to update to use <C-S-T>, seems will override the <C-T>
" suggest not to use <A-T>, it means alt+shift+t
noremap <A-t> :tabnew<CR>:e $HOME/Documents/DCB/Collection_Note/allFile_All.txt<CR><CR>:set isfname+=:<CR>
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
" quick way for no highlight, originally want to set noh after substitution, but seems no better way
nnoremap <Esc> :silent noh<Bar>echo<CR>

"""""""""""""""""""""""""""""" H1 - Mapping - Win Behave (mostly copied from mswin.vim)
behave mswin
" backspace in Visual mode deletes selection
vnoremap <BS> d
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
" CTRL-Z is Undo; not in cmdline though
noremap <C-Z> u
inoremap <C-Z> <C-O>u
" CTRL-A is Select all
noremap <C-A> gggH<C-O>G
inoremap <C-A> <C-O>gg<C-O>gH<C-O>G
cnoremap <C-A> <C-C>gggH<C-O>G
onoremap <C-A> <C-C>gggH<C-O>G
snoremap <C-A> <C-C>gggH<C-O>G
xnoremap <C-A> <C-C>ggVG
" CTRL-F4 is Close window
noremap <C-F4> <C-W>c
inoremap <C-F4> <C-O><C-W>c
cnoremap <C-F4> <C-C><C-W>c
onoremap <C-F4> <C-C><C-W>c


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
nnoremap <C-S-Right> ve
nnoremap <S-Left> lvh
nnoremap <C-S-Left> lvb
inoremap <S-Right> <ESC>lvl
inoremap <C-S-Right> <ESC>lve
inoremap <S-Left> <ESC>lvh
inoremap <C-S-Left> <ESC>lvb
vnoremap <S-Right> l
vnoremap <C-S-Right> e
vnoremap <S-Left> h
vnoremap <C-S-Left> b
" y in visual mode also copy to clipboard
vnoremap y "+y
vnoremap d "+d

"""""""""""""""""""""""""""""" H1 - Mapping - Tab/Window
noremap <C-Tab> gt
inoremap <C-Tab> <Esc>gt
noremap <C-S-Tab> gT
inoremap <C-S-Tab> <Esc>gT


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
  filetype plugin indent on				" type detection, language-dependent indenting

  augroup vimrcEx					" add to a group, and clean the previous cmds
  au!

  autocmd FileType text setlocal textwidth=78		" set width 78 if type is text

  autocmd BufReadPost *					" goto the last position last edit before quit
    \ if line("'\"") > 0 && line("'\"") <= line("$") |
    \   exe "normal! g`\"" |
    \ endif

  augroup END

endif " for autocmd


""" OnlyFileNameInTab is for showing only the filename, excluding the path
set guitablabel=%{OnlyFileNameInTab()}		" invoke the function
function OnlyFileNameInTab()
	let bufnrlist = tabpagebuflist(v:lnum) 
	
	" show only the first 6 letters of the name + ..
	let label = bufname(bufnrlist[tabpagewinnr(v:lnum) - 1])
	let filename = fnamemodify(label,':t')

	"if want to show a short filename in the tab, use following
	"
	"if strlen(filename) >=8
	"	let ret = filename[0:9].'..'
	"else
	"	let ret = filename
	"endif
	"return ret  
	
	return filename
endfunction

" Highlight all instances of word under cursor, when idle. Useful when studying strange source code.
command! -nargs=0 TAutoHighLight	:if ToggleAutoHighlight() | :set hls | endif
function! ToggleAutoHighlight()
  let @/ = ''
  if exists('#auto_highlight')
    au! auto_highlight
    augroup! auto_highlight
    setl updatetime=4000
    echo 'Highlight current word: OFF'
    return 0
  else
    augroup auto_highlight
      au!
      " TODO: when holding nothing, will search all
      au CursorHold * let text = expand('<cword>') | if strlen(text) | let @/ = '\V'.escape(expand('<cword>'), '\') | endif		" without word boundary, non-empty string
      "au CursorHold * let @/ = '\V'.escape(expand('<cword>'), '\')		" without word boundary
      "au CursorHold * let @/ = '\V\<'.escape(expand('<cword>'), '\').'\>'	" with word boundary
      "au CursorHold * let @/ = '\<'.expand('<cword>').'\>'			" In general the escape is a good idea, but in practice the current word (cword) is unlikely to have punctuation in it that needs escaping. Thoughts?
    augroup end
    setl updatetime=500
    echo 'Highlight current word: ON'
    return 1
  endif
endfunction


""" Some settings on diff, not really understand
set diffexpr=MyDiff()
function MyDiff()
  let opt = '-a --binary '
  if &diffopt =~ 'icase' | let opt = opt . '-i ' | endif
  if &diffopt =~ 'iwhite' | let opt = opt . '-b ' | endif
  let arg1 = v:fname_in
  if arg1 =~ ' ' | let arg1 = '"' . arg1 . '"' | endif
  let arg2 = v:fname_new
  if arg2 =~ ' ' | let arg2 = '"' . arg2 . '"' | endif
  let arg3 = v:fname_out
  if arg3 =~ ' ' | let arg3 = '"' . arg3 . '"' | endif
  let eq = ''
  if $VIMRUNTIME =~ ' '
    if &sh =~ '\<cmd'
      let cmd = '""' . $VIMRUNTIME . '\diff"'
      let eq = '"'
    else
      let cmd = substitute($VIMRUNTIME, ' ', '" ', '') . '\diff"'
    endif
  else
    let cmd = $VIMRUNTIME . '\diff'
  endif
  silent execute '!' . cmd . ' ' . opt . arg1 . ' ' . arg2 . ' > ' . arg3 . eq
endfunction
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
"
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" SKILLS            "
"""""""""""""""""""""


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" TODO List         "
"""""""""""""""""""""
" done:
" 	1 How to set the right click command "Edit with Vim" 	
"

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

