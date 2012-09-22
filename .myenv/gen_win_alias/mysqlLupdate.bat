@ECHO OFF 
mysql -hlocalhost -P3306 -uupdateserver -p123456 --database=update_server %* 
