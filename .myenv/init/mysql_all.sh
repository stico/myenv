#!/bin/bash

# pre check of os
[ $(echo `uname -a` | grep -c -x "^Linux .*") -eq 0 ] && echo "ERROR: script $0 only works on Linux OS, pls check" && exit 1

################################################################################
# INSTALL mysql-client
################################################################################
sudo apt-get -y install mysql-client


################################################################################
# INSTALL mysql-server
################################################################################
# pre check
dpkg -s mysql-server &> /dev/null
[ "$?" -eq "0" ] && echo 'ERROR: mysql-server already installed, will NOT install again!' && exit 1

# dependencies
sudo apt-get install debconf-utils

# auto install. If auto way not work, then manual way: 1) install one manually. 2) `sudo debconf-get-selections | grep mysql-server`
# NOTE: the password might not set success, then use empty password
full_name=`apt-cache depends mysql-server | sed -e '/Depends:/!d;s/\s*Depends:\s*//'`
sudo bash -c "echo \"$full_name mysql-server/root_password password 123456\" | debconf-set-selections"
sudo bash -c "echo \"$full_name mysql-server/root_password_again password 123456\" | debconf-set-selections"
sudo apt-get -y install mysql-server
[ "$?" -ne "0" ] && echo 'ERROR: seems mysql-server installation failed, will NOT continue!' && exit 1

# config
sudo cp /etc/mysql/my.cnf /etc/mysql/my.cnf.bak.`date "+%Y%m%d_%H%M%S"`
sudo sed -i -e "s/\(bind-address\s*\)=.*/\1=0.0.0.0/"		/etc/mysql/my.cnf
sudo sed -i -e "/\[client\]/adefault-character-set=utf8"	/etc/mysql/my.cnf
sudo sed -i -e "/\[mysql\]/adefault-character-set=utf8"		/etc/mysql/my.cnf
sudo sed -i -e "/\[mysqld\]/acollation-server=utf8_unicode_ci"	/etc/mysql/my.cnf
sudo sed -i -e "/\[mysqld\]/ainit-connect='SET NAMES utf8'"	/etc/mysql/my.cnf
sudo sed -i -e "/\[mysqld\]/acharacter-set-server=utf8"		/etc/mysql/my.cnf

# restart
sudo service mysql restart

# config database/user
mysql -uroot -p123456 -e "create database update_server" 
mysql -uroot -p123456 -e "grant all on *.* to 'update_server'@'%' identified by '123456'" 
mysql -uroot -p123456 -e "grant all on *.* to 'update_server'@'localhost' identified by '123456'"
