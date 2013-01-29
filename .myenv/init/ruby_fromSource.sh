#!/bin/bash                                                                                                                                                                                                                                  
#Tested on: ubuntu 12.04 server/desktop

sudo apt-get -y build-dep ruby1.9
sudo apt-get -y install libyaml-dev zlib1g-dev openssl libopenssl-ruby libssl-dev

ruby_ver=ruby-1.9.3-p327
ruby_ver_targz=${ruby_ver}.tar.gz
#ruby_path=/usr/duowan/ruby
#ruby_install_path=/usr/duowan/install/$ruby_ver
ruby_path=/home/ouyangzhu/dev/ruby
ruby_install_path=/home/ouyangzhu/dev/$ruby_ver

cd /tmp
[ -e $ruby_ver_targz ] || wget http://ftp.ruby-lang.org/pub/ruby/1.9/$ruby_ver_targz
rm -rf $ruby_ver &> /dev/null
tar -zxvf $ruby_ver_targz
cd $ruby_ver

./configure --prefix=$ruby_install_path
make && make install
$ruby_path/bin/gem install rdoc
chmod -R 755 $ruby_install_path
