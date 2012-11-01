Set VIM_Path=C:\Program_Files_2\A_System_Cygwin\bin\vim-nox.exe
Set VIM_Config=C:\Program_Files_2\A_Text_Vim_7.2_PA-Basic\Data\settings\_vimrc

REM set the VIMRUNTIME makes the vim in cygwin could use plugins in the gvim portable
Set VIMRUNTIME=/cygdrive/c/Program_Files_2/A_Text_Vim_7.2_PA-Basic/App/vim/vim72
Set TERM=xterm

%VIM_Path% -u %VIM_Config%
