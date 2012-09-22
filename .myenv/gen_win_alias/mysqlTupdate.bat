@ECHO OFF 
mysql -h192.168.1.111 -uupdateserver -p123456 --database=update_server %* 
