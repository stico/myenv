#!/bin/bash
#Tested on: ubuntu server 12.04/11.10 (2013-01-18)

[ -e ~/.rvm ] && echo "ERROR: ~/.rvm already exist, if want reinstall, remove it" && exit
sudo apt-get update
sudo apt-get install -y git libsqlite3-dev nodejs

#sudo apt-get install build-essential openssl libreadline6 libreadline6-dev \
#curl git-core zlib1g zlib1g-dev libssl-dev libyaml-dev libsqlite3-dev sqlite3 \
#libxml2-dev libxslt-dev autoconf libc6-dev ncurses-dev automake libtool bison  \
#subversion

\curl -L https://get.rvm.io | bash -s stable
echo "source ~/.rvm/scripts/rvm" >> ~/.bashrc
source ~/.rvm/scripts/rvm
command rvm autolibs enable
command rvm install ruby-1.9.3-p327 --docs
rvm use ruby-1.9.3-p327@global --default
source ~/.rvm/scripts/rvm
#gem install rails
#rvm docs generate
