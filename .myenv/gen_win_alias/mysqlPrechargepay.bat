@ECHO OFF 
mysql -h222.88.95.252 -P6208 -urecharge_paysrv -ppayservice12345 --database=recharge_payservice %* 
