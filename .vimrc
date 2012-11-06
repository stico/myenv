if exists('loaded_settings_of_stico')
    finish
endif
let loaded_settings_of_stico = 1

"source $VIMRUNTIME/vimrc_example.vim		"content is already joined
"source $VIMRUNTIME/mswin.vim			"content is already joined


""""""""""""""""""""Tmp for Test""""""""""""""""""""
""""""""""""""""""""Tmp for Test""""""""""""""""""""


"""""""""""""""""""""""""""""" H1 - Syntax
syntax on						" switch syntax highlighting on
set diffopt=filler,iwhite,context:1000,vertical
hi DiffAdd	guibg=#DDDDFF guifg=#993333 gui=none	" for added lines
hi DiffDelete	guibg=#DDDDFF guifg=#993333 gui=none	" for delete lines
hi DiffChange	guibg=#EEEEFF guifg=Gray gui=none	" for identical text in changed lines
hi DiffText	guibg=#DDDDFF guifg=#993333 gui=none	" for different text in changed lines
"hi Normal guibg=grey90					" seem could use num to specify color level?
"
"au BufEnter <buffer> hi Comment	ctermfg=DarkGrey guifg=DarkGrey		" need this way to override the hi defined by filetype specifiy one
"au FileType *	hi Comment	cterm=italic ctermfg=DarkCyan gui=italic guifg=DarkCyan " seems better than line above, as could match filetype  
au FileType *	hi Comment	ctermbg=Grey ctermfg=DarkCyan guibg=LightGrey guifg=DarkCyan " seems better than line above, as could match filetype  
au BufRead,BufNewFile jquery.*.js set filetype=javascript syntax=jquery 
au FileType javascript set expandtab tabstop=4 shiftwidth=4 


"""""""""""""""""""""""""""""" H1 - Plugins
" for pathogen.vim
call pathogen#infect()

" for ctrlp.vim
let g:ctrlp_regexp = 1					" 1 to set regexp search as the default
let g:ctrlp_custom_ignore = {
	\ 'dir':  '\.git$\|\.hg$\|\.svn$|\.metadata$',
	\ 'file': '\.class$\|\.jar$\|\.lnk$|\*\.svn-base$',
	\ 'link': '',
	\ }
"""""""""""""""""""""""""""""" H1 - Settings - Misc
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
"set cursorcolumn					" highlight current column

"""""""""""""""""""""""""""""" H1 - Settings - Search
set incsearch						" set the increase search
set hlsearch						" highlighting the last used search pattern.
set ignorecase						" useful when using ^n, ^p
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
set iskeyword+=45					" make "-" as part of word, auto complete (^N^P) use it
"set iskeyword+=46					" make "." as part of word, auto complete (^N^P) use it

"""""""""""""""""""""""""""""" H1 - Settings - GUI
set guioptions-=m					" no menu
set guioptions-=T					" no toolbar
set guioptions+=b					" always show buttom scroll-bar
set mousehide						" Hide the mouse when typing text

"""""""""""""""""""""""""""""" H1 - Settings - Movement
set whichwrap+=<,>,[,]					" make the left/right could go cross line in Normal/Visual & Insert/Replace mode
set whichwrap+=h,l					" make the h/l also
set backspace=indent,eol,start				" backspace and cursor keys wrap to previous /next line


"""""""""""""""""""""""""""""" H1 - Mapping - Misc
noremap <C-T> :tabnew<CR>
" open new tab and with the allInOne opened, why need 2 <CR> in the end?
" failed to update to use <C-A-s>, seems vim never received 
" failed to update to use <C-S-T>, seems will override the <C-T>
" suggest not to use <A-T>, it means alt+shift+t
noremap <A-t> :tabnew<CR>:e $MY_DOC\DCB\Collection\allFile_All.txt<CR><CR>:set isfname+=:<CR>
" for schedule done
inoremap <A-S-D> <Esc>A<Tab><Tab>done<Esc>5h
nnoremap <A-S-D> <Esc>A<Tab><Tab>done<Esc>5h
" for merge with Tab
inoremap <A-S-J> <Esc>Js<Tab><Esc>
nnoremap <A-S-J> <Esc>Js<Tab><Esc>
" if not, the Q will enter Ex mode which seldom use
map Q gq

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
noremap <CR> o<Esc>
noremap <S-CR> O<Esc>j
noremap <C-CR> i<CR><Esc>
noremap <Tab> i<Tab><Esc>
noremap <S-Tab> $F<Tab>i<Tab><Esc>
noremap <Space> i<Space><Esc>
" delete by words
inoremap <C-Del> <Esc>ldwi
inoremap <C-Backspace> <Esc>ldbi
noremap <C-Left> b
noremap <C-Right> w
" y in visual mode also copy to clipboard
vnoremap y "+y
vnoremap d "+d

"""""""""""""""""""""""""""""" H1 - Mapping - Tab/Window
noremap <C-Tab> gt
inoremap <C-Tab> <Esc>gt
noremap <C-S-Tab> gT
inoremap <C-S-Tab> <Esc>gT
" since <C-I> equals <Tab> and <Tab> can is used 
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

command! -nargs=* RCmd			:w | :silent ! cmd.exe <args> "%:p" & pause
command! -nargs=* RBash			:w | :silent ! bash    <args> "%:p" & pause
command! -nargs=* RRuby			:w | :silent ! ruby    <args> "%:p" & pause
command! -nargs=* RPython		:w | :silent ! python  <args> "%:p" & pause
command! -nargs=* RGroovy		:w | :silent ! groovy  <args> "%:p" & pause

"autocmd BufNewFile,BufReadPost *.sh map <buffer> <F11> :pwd
autocmd Filetype sh map <buffer> <F11> :RInBash<Enter>
autocmd Filetype ruby map <buffer> <F11> :RInRuby<Enter>
autocmd Filetype groovy map <buffer> <F11> :RInGroovy<Enter>
autocmd Filetype python map <buffer> <F11> :RInPython<Enter>
autocmd Filetype dosbatch map <buffer> <F11> :RInCmd<Enter>


"""""""""""""""""""""""""""""" H1 - Script

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
" 1 use "setlocal textwidth=78" to set the width when needed
" 2 put plugin files in directory (~/.vim/pulgin or $VIM/vimfiles/plugin),
"   they will be sourced by the vim, just so simple.
"   For filetype plugins, you should put them into directory "ftplugin").
"
"
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" TODO List         "
"""""""""""""""""""""
" done:
" 	1 How to set the right click command "Edit with Vim" 	
"
"
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
