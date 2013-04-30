#!/bin/bash

dated_bak_dir=$HOME/Documents/DCB/DatedBackup
myenv_init_ro=~/.myenv/init/myenv_lu_ro.sh

# 1) init from github
[ ! -e $myenv_init_ro ] && echo "ERROR: $myenv_init_ro not exist, pls check!" && exit 1
bash $myenv_init_ro 

# 2) check 
[ -e ~/.ssh/config ] && echo "ERROR: ~/.ssh already have content, pls check!" && exit 1
[ -e ~/.myenv/secu ] && echo "ERROR: ~/.myenv/secu already exist, pls check!" && exit 1
[ -e ~/.myenv/secure ] && echo "ERROR: ~/.myenv/secure already exist, pls check!" && exit 1
[ -e $dated_bak_dir ] && echo "ERROR: $dated_bak_dir not exist, not able to find backup package, pls check!" && exit 1

# 3) extract .ssh, secu, secure
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

# 4) update github remote
git remote rm github
git remote add github "stico_github:stico/myenv.git"
