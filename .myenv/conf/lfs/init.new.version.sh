
ver=7.4
base=$MY_DOC/ECS/lfs/$ver
sources_dir=$base/sources
sources_md5sums=$base/sources-md5sums
sources_wget_list=$base/sources-wget-list


# safe check
[ ! -e $(dirname $base) ] && echo "ERROR: $(dirname $base) not exist!" && exit 1

# init dir and download packages
[ ! -e $base ] && mkdir -p $base
[ -e $sources_md5sums ] || wget http://www.linuxfromscratch.org/lfs/downloads/${ver}/md5sums -O $sources_md5sums
[ -e $sources_wget_list ] || wget http://www.linuxfromscratch.org/lfs/downloads/${ver}/wget-list -O $sources_wget_list
[ -e $sources_dir ] || wget -i $sources_wget_list -P $sources_dir
cp $sources_md5sums $sources_dir
cd $sources_dir
md5sum -c $(basename $sources_md5sums) | grep -v OK && echo "ERROR: md5 check failed!" && exit 1


exit

#	# Create Partition
#	# allocate new partition (2013-09-16: *500M* for /boot, *18G* for /)
#	# might need restart if can not find that partition
#	sudo fdisk
#	
#	# Make FS
#	sudo mkfs -v -t ext4 /dev/sda6
#	sudo mkfs -v -t ext4 /dev/sda7
	mnt_lfs=/mnt/lfs
	mnt_lfs_boot=/mnt/lfs/boot
	mnt_lfs_tools=/mnt/lfs/tools
	mnt_lfs_sources=/mnt/lfs/sources
	sudo mkdir -p $mnt_lfs $mnt_lfs_boot $mnt_lfs_tools $mnt_lfs_sources

	sudo groupadd lfs
	sudo useradd -s /bin/bash -g lfs -m -k /dev/null lfs
	sudo passwd lfs	

	sudo cp $sources_dir/* $mnt_lfs_sources
	sudo chown lfs:lfs -R $mnt_lfs

	# Make directory writable and sticky. "Sticky" (also called "restricted deletion flag") means that even if multiple users have write permission on a directory, only the owner of a file can delete the file within a sticky directory.
	# is it really necessary?
	#sudo chmod -v a+wt $mnt_lfs_sources

	# is it really necessary?
	#sudo ln -s $mnt_lfs_tools /tools

	su - lfs
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
