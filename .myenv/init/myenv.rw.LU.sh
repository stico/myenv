#!/bin/bash

# Init dir and var
myenv_init_ro_url=https://raw.github.com/stico/myenv/master/.myenv/init/myenv.ro.LU.sh
myenv_init_ro=$tmp_init_dir/myenv.ro.LU.sh
dated_bak_dir=$HOME/Documents/DCB/DatedBackup
tmp_init_dir=/tmp/os_init/`date "+%Y%m%d_%H%M%S"`
[ -n "$1" -a -d "$1" ] && tmp_init_dir=$1 
mkdir -p $tmp_init_dir

# Init readonly version
wget -O $myenv_init_ro $myenv_init_ro_url
[ ! -e $myenv_init_ro ] && echo "$myenv_init_ro not found, init myenv_ro failed!" && exit 1
bash $myenv_init_ro $tmp_init_dir

# Pre check 
[ -e ~/.ssh/config -o -e ~/.myenv/secu -o -e ~/.myenv/secure ] && echo "~/.ssh or ~/.myenv/secu or ~/.myenv/secure exist, pls check!" && exit 1
[ ! -e $dated_bak_dir ] && echo "$dated_bak_dir not exist, not able to find backup package, pls check!" && exit 1

# Extract .ssh, secu, secure
myenv_full_bak=`find $dated_bak_dir -name "*myenv*full*.zip" | tail -1`
tmp1=${myenv_full_bak%.zip}
myenv_full_bak_name=${tmp1##*/}
rm -rf /tmp/$myenv_full_bak_name 
unzip -q $myenv_full_bak -d /tmp
ssh_bak=`find /tmp/$myenv_full_bak_name -name ".ssh" -type d | tail -1`
secu_bak=`find /tmp/$myenv_full_bak_name -name "secu" -type d | tail -1`
secure_bak=`find /tmp/$myenv_full_bak_name -name "secure" -type d | tail -1`
mkdir -p ~/.ssh ~/.myenv/secu ~/.myenv/secure 
[ -e "$ssh_bak" ] && cp -rf $ssh_bak/* ~/.ssh/ || echo "ERROR: failed to restore files in .ssh/"
[ -e "$secu_bak" ] && cp -rf $secu_bak/* ~/.myenv/secu/ || echo "INFO: .myenv/secu/ not exist, not restored"
[ -e "$secure_bak" ] && cp -rf $secure_bak/* ~/.myenv/secure/ || echo "INFO: .myenv/secure/ not exist, not restored"

# Update github remote
git remote rm github
git remote add github "stico_github:stico/myenv.git"
