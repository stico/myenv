#!/bin/bash

# Variable - note the dev_xxx might need update
ver=7.4
base=$MY_DOC/ECS/lfs/$ver
sources_dir=$base/sources
mnt_lfs=/mnt/lfs
mnt_lfs_boot=/mnt/lfs/boot
mnt_lfs_tools=/mnt/lfs/tools
mnt_lfs_sources=/mnt/lfs/sources
dev_lfs=/dev/sda7
dev_lfs_boot=/dev/sda6

# Source functions
func_me=$MY_ENV/env_func_bash
[ ! -e $func_me ] && echo "ERROR: $func_me not exist" && exit 1 || source $func_me

# Pre-Check
func_validate_exist $mnt_lfs 
func_validate_user_exist lfs
( ! df 2> /dev/null | grep -q /mnt/lfs ) && echo "ERROR: /mnt/lfs not mount" && exit 1
( ! df 2> /dev/null | grep -q /mnt/lfs/boot ) && echo "ERROR: /mnt/lfs/boot not mount" && exit 1
( ! /bin/sh --version | head -1 | grep -q "bash" ) && echo "ERROR: /bin/sh must be bash, pls check" && exit 1
( ! sudo fdisk -l | grep "${dev_lfs}.*18874368.*83" &> /dev/null ) && echo "ERROR: failed to find $dev_lfs"  && exit 1
( ! sudo fdisk -l | grep "${dev_lfs_boot}.*512000.*83" &> /dev/null ) && echo "ERROR: failed to find $dev_lfs_boot" && exit 1

# Mount partition and check
sudo mount -v -t ext4 $dev_lfs $mnt_lfs &> /dev/null
func_validate_exist $mnt_lfs_boot
sudo mount -v -t ext4 $dev_lfs_boot $mnt_lfs_boot &> /dev/null
swapon -a

# Cleanup
sudo rm -rf $mnt_lfs_tools $mnt_lfs_sources $mnt_lfs_boot/*
