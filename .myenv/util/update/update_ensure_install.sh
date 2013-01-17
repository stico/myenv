#!/bin/bash
ver=update_ensure-0.0.1.gem

cd ~/amp/download/
rm $ver
mv tmp_transfer_*_update_ensure-0.0.1.gem $ver
cp $ver /data/var/update_ensure/backup/gem_bak/${ver}_`date "+%Y%m%d_%H%M%S"`
sudo /usr/local/ruby/bin/gem install $ver
cd -
