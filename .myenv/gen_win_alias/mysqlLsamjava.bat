@ECHO OFF 
mysql -hlocalhost -P3306 -usample_java -p123456 --database=sample_java %* 
