@ECHO OFF 
mysql -hlocalhost -P3306 -urecharge -precharge --database=recharge_console %* 
