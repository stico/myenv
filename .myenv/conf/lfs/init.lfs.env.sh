#!/bin/bash

mnt_lfs=/mnt/lfs
mnt_lfs_boot=/mnt/lfs/boot
dev_lfs=/dev/sda7
dev_lfs_boot=/dev/sda6

# Check
[ ! -e $mnt_lfs ] && echo "ERROR: $mnt_lfs not exist!" && exit 1
[ ! -e $mnt_lfs_boot ] && echo "ERROR: $mnt_lfs_boot not exist!" && exit 1
( ! sudo fdisk -l | grep "${dev_lfs}.*18874368.*83" &> /dev/null ) && echo "ERROR: failed to find $dev_lfs"  && exit 1
( ! sudo fdisk -l | grep "${dev_lfs_boot}.*512000.*83" &> /dev/null ) && echo "ERROR: failed to find $dev_lfs_boot" && exit 1

# Init env
export LFS=$mnt_lfs

# Mount partitions, enable swap
mount -v -t ext4 $dev_lfs $LFS
mount -v -t ext4 $dev_lfs_boot $LFS/boot
swapon -a

su - lfs
