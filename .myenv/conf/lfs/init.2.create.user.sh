#!/bin/bash

# Check
( grep -q "^lfs:" /etc/passwd ) && echo "ERROR: user 'lfs' already exist" && exit 1

# Create user
sudo groupadd lfs
sudo useradd -s /bin/bash -g lfs -m -k /dev/null lfs
sudo passwd lfs	

# Init bash settings
lfs_profile=/home/lfs/.bash_profile
[ ! -e "$lfs_profile" ] && cat > $lfs_profile << "EOF"
exec env -i HOME=$HOME TERM=$TERM PS1='\u:\w\$' /bin/bash
EOF

lfs_rc=/home/lfs/.bashrc
[ ! -e "$lfs_rc" ] && cat > ~/.bashrc << "EOF"
set +h
umask 022
LFS=/mnt/lfs
LC_ALL=POSIX
LFS_TGT=$(uname -m)-lfs-linux-gnu
PATH=/mnt/lfs/tools/bin:/bin:/usr/bin			
# this line updated: /mnt/lfs/tools/bin instead of /tools
export LFS LC_ALL LFS_TGT PATH
EOF

sudo chown lfs:lfs $lfs_rc $lfs_profile
sudo chmod 700 $lfs_rc $lfs_profile
