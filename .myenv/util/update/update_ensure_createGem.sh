ver="update_ensure-0.0.1"

cd ~/dev/code_dw/update-server_trunk/update_ensure 
rm ${ver}.gem 
gem build update_ensure.gemspec 
scpx ${ver}.gem 183.61.143.6:~/amp/download;
