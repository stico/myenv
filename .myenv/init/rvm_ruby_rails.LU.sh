#!/bin/bash
#Tested on: ubuntu 12.04 server (2013-01-17)

[ -e ~/.rvm ] && echo "ERROR: ~/.rvm already exist, if want reinstall, remove it" && exit
sudo apt-get update
sudo apt-get install -y libsqlite3-dev nodejs
\curl -L https://get.rvm.io | bash -s stable
echo "source ~/.rvm/scripts/rvm" >> ~/.bashrc
source ~/.rvm/scripts/rvm
command rvm install ruby-1.9.3-p327
rvm use ruby-1.9.3-p327@global --default
gem install rails
source ~/.rvm/scripts/rvm
