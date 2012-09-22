@ECHO OFF 
mysql -h113.106.100.60 -P6208 -urecharge_paysrv -ppayservice12345 --database=recharge_payservice %* 
