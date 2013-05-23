@ECHO OFF

REM TODO, merge to the in all init file

set ft_txt=txt_file
set ft_ahk=ahk_file
set ft_pdf=pdf_file
set ft_compressed=compressed_file

assoc .ahk=%ft_ahk%
assoc .pdf=%ft_pdf%

assoc .js=%ft_txt%
assoc .py=%ft_txt%
assoc .sh=%ft_txt%
assoc .txt=%ft_txt%
assoc .lst=%ft_txt%
assoc .csh=%ft_txt%
assoc .log=%ft_txt%
assoc .xml=%ft_txt%
assoc .css=%ft_txt%
assoc .sql=%ft_txt%
assoc .ini=%ft_txt%
assoc .conf=%ft_txt%
assoc .properties=%ft_txt%

assoc .7z=%ft_compressed%
assoc .bz=%ft_compressed%
assoc .bz2=%ft_compressed%
assoc .ear=%ft_compressed%
assoc .war=%ft_compressed%
assoc .jar=%ft_compressed%
assoc .gz=%ft_compressed%
assoc .tar=%ft_compressed%
assoc .tgz=%ft_compressed%
assoc .rar=%ft_compressed%
assoc .zip=%ft_compressed%


REM ftype %ft_pdf%=%MY_PRO%\A_Text_PDF_FoxitReader_5.0.1_PA-Basic\FoxitReaderPortable.exe "%%1"
ftype %ft_pdf%=%MY_PRO%\foxitReader_6.0.2.0413_PA\App\Foxit Reader\Foxit Reader.exe "%%1"
ftype %ft_ahk%=%MY_PRO%\A_System_AutoHotkey_1.0.48.00_Official-Basic\AutoHotkey.exe "%%1"
ftype %ft_txt%=%MY_PRO%\A_Text_Vim\App\vim\vim73\gvim.exe "%%1"
ftype %ft_compressed%=%MY_PRO%\A_System_7-Zip_9.20_PA-Basic\App\7-Zip\7zFM.exe "%%1"

PAUSE
