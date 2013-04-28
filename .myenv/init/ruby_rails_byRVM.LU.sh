#!/bin/bash
#Tested on: ubuntu server 12.04/11.10 (2013-01-18)

[ -e ~/.rvm ] && echo "ERROR: ~/.rvm already exist, if want reinstall, remove it" && exit
sudo apt-get update
sudo apt-get install -y libsqlite3-dev nodejs
\curl -L https://get.rvm.io | bash -s stable
echo "source ~/.rvm/scripts/rvm" >> ~/.bashrc
source ~/.rvm/scripts/rvm
command rvm autolibs enable
command rvm install ruby-1.9.3-p327 --docs
rvm use ruby-1.9.3-p327@global --default
gem install rails
source ~/.rvm/scripts/rvm
#rvm docs generate
