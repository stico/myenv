#!/bin/bash

echo "WARN: script in this file is just for reference, pls perform manually!"
exit

# Create Partition
# allocate new partition (2013-09-16: *500M* for /boot, *18G* for /)
# might need restart if can not find that partition
sudo fdisk

# !!! need manual check !!!
mnt_lfs=/mnt/lfs
dev_lfs=$(sudo fdisk -l | grep sda && echo /dev/sda7 || echo /dev/sdb7)
dev_lfs_boot=$(sudo fdisk -l | grep sda && echo /dev/sda6 || echo /dev/sdb6)

# Check
( ! sudo fdisk -l | grep "${dev_lfs}.*18874368.*83" &> /dev/null ) && echo "ERROR: failed to find $dev_lfs"  && exit 1
( ! sudo fdisk -l | grep "${dev_lfs_boot}.*512000.*83" &> /dev/null ) && echo "ERROR: failed to find $dev_lfs_boot" && exit 1

# Make FS
sudo mkfs -v -t ext4 $dev_lfs
sudo mkfs -v -t ext4 $dev_lfs_boot

sudo mkdir $mnt_lfs					&& \
sudo mount -v -t ext4 $dev_lfs $mnt_lfs			&& \
sudo mkdir $mnt_lfs/boot				&& \
sudo mount -v -t ext4 $dev_lfs_boot $mnt_lfs/boot	|| echo "ERROR: failed to mount partitions, pls check"

swapon -a

sudo mv /bin/sh{,.bak}
sudo ln -s /bin/bash /bin/sh
