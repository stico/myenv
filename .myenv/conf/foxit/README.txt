- install wine1.5
- put foxit win executable in ~/.wine/drive_c/Program Files/
  /home/ouyangzhu//.wine/drive_c/Program Files/Foxit -> /home/ouyangzhu//program/A_Text_PDF_FoxitReader_5.0.1_PA-Basic/
- create link
  /home/ouyangzhu//.local/share/applications/foxit.desktop -> /home/ouyangzhu//.myenv/conf/foxit/foxit.desktop
- right click pdf file > open with > show all application > (select) Foxit > set as default
   or add line in /home/ouyangzhu//.local/share/applications/mimeapps.list: application/pdf=foxit.desktop;
