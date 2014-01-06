#!/bin/bash

# Variable - note the dev_xxx might need update
ver=7.4
base=$MY_DOC/ECS/lfs/$ver
sources_dir=$base/sources
mnt_lfs=/mnt/lfs
mnt_lfs_boot=/mnt/lfs/boot
mnt_lfs_tools=/mnt/lfs/tools
mnt_lfs_sources=/mnt/lfs/sources
dev_lfs=$(sudo fdisk -l | grep sda &> /dev/null && echo /dev/sda7 || echo /dev/sdb7)
dev_lfs_boot=$(sudo fdisk -l | grep sda &> /dev/null && echo /dev/sda6 || echo /dev/sdb6)

# Source functions
source ${HOME}/.myenv/myenv_func.sh || eval "$(wget -q -O - "https://raw.github.com/stico/myenv/master/.myenv/myenv_func.sh")" || exit 1

# Pre-Check
func_validate_exist $mnt_lfs 
func_validate_user_exist lfs
( ! /bin/sh --version | head -1 | grep -q "bash" ) && echo "ERROR: /bin/sh must be bash, pls check" && exit 1
( ! sudo fdisk -l | grep "${dev_lfs}.*18874368.*83" &> /dev/null ) && echo "ERROR: failed to find $dev_lfs"  && exit 1
( ! sudo fdisk -l | grep "${dev_lfs_boot}.*512000.*83" &> /dev/null ) && echo "ERROR: failed to find $dev_lfs_boot" && exit 1

# Mount partition and check
sudo mount -v -t ext4 $dev_lfs $mnt_lfs
func_validate_exist $mnt_lfs_boot
sudo mount -v -t ext4 $dev_lfs_boot $mnt_lfs_boot
swapon -a
( ! df 2> /dev/null | grep -q /mnt/lfs ) && echo "ERROR: /mnt/lfs not mount" && exit 1
( ! df 2> /dev/null | grep -q /mnt/lfs/boot ) && echo "ERROR: /mnt/lfs/boot not mount" && exit 1

# Prepare dir and packages
[ ! -e $mnt_lfs_tools ] && sudo mkdir $mnt_lfs_tools
if [ ! -e $mnt_lfs_sources ] ; then
	sudo mkdir $mnt_lfs_sources
	sudo cp $sources_dir/* $mnt_lfs_sources
	sudo chown lfs:lfs -R $mnt_lfs
	sudo chmod -R 755 $mnt_lfs

	# Make directory writable and sticky. "Sticky" (also called "restricted deletion flag") means that even if multiple users have write permission on a directory, only the owner of a file can delete the file within a sticky directory.
	# is it really necessary?
	#sudo chmod -v a+wt $mnt_lfs_sources
fi
[ ! -e /tools ] && sudo ln -s $mnt_lfs_tools /tools

# su to lfs
echo "INFO: login as user 'lfs'"
su - lfs
