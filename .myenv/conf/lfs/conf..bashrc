set +h
umask 022
LFS=/mnt/lfs
LC_ALL=POSIX
LFS_TGT=$(uname -m)-lfs-linux-gnu

# this line updated: /mnt/lfs/tools/bin instead of /tool
PATH=/mnt/lfs/tools/bin:/bin:/usr/bin

export LFS LC_ALL LFS_TGT PATH
