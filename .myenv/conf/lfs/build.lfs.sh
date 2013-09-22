#!/bin/bash

# NOTE: on my thinkpad x200s, 1SBU is about 1 minute

# TODO: why binutils nothing in /tools after make install
# TODO: can not build gcc

function func_validate_exist_file() {
	usage="USAGE: $FUNCNAME <path> <path> ..."
	[ "$#" -lt 1 ] && echo $usage && exit 1
	
	for path in $@ ; do
		[ ! -f "$path" ] && echo "ERROR: file ($path) not exist!" && exit 1
	done
}

function func_validate_exist() {
	usage="USAGE: $FUNCNAME <path> <path> ..."
	[ "$#" -lt 1 ] && echo $usage && exit 1
	
	for path in $@ ; do
		[ ! -e "$path" ] && echo "ERROR: $path not exist!" && exit 1
	done
}

function func_validate_current_user() {
	usage="USAGE: $FUNCNAME <user>"
	[ "$#" -lt 1 ] && echo $usage && exit 1
	
	[ "`whoami`" != "$*" ] && echo "ERROR: username is not $*, pls check!" && exit 1
}

function func_die {
	usage="Usage: $FUNCNAME [error_info]"
	[ $# -lt 1 ] && echo $usage && exit 1
	
	echo "$@" 1>&2
	exit 1
}

function func_uncompress() {
	usage="Usage: $FUNCNAME [path]"
	[ $# -lt 1 ] && echo $usage && exit 1

	func_validate_exist $1

	case "$1" in
	*.tar)		tar xvf $1 ;;
	*.zip)		unzip xvf $1 ;;
	*.tar.gz)	tar zxvf $1 ;;
	*.tar.bz2)	tar jxvf $1 ;;
	*.tar.xz)	tar Jxvf $1 ;;
	*)		func_die "ERROR: can not recogonize type to uncompress: $1" ;;
	esac

	$? || func_die "ERROR: failed to uncompress $1"
}

function func_uncompress_cd() {
	usage="Usage: $FUNCNAME [path]"
	[ $# -lt 1 ] && echo $usage && exit 1

	func_uncompress $1
	\cd ${1%%.tar*} || \cd ${1%%.zip} || func_die "ERROR: failed to cd into uncompress dir, maybe the dir naming problem!"
}

function func_lfs_pre_check() {
	func_validate_current_user lfs
	func_validate_exist /mnt/lfs/sources /mnt/lfs/boot /mnt/lfs/tools /tools
	( ! df 2> /dev/null | grep -q /mnt/lfs ) && echo "ERROR: /mnt/lfs not mount" && exit 1
	( ! df 2> /dev/null | grep -q /mnt/lfs/boot ) && echo "ERROR: /mnt/lfs/boot not mount" && exit 1
	( ! /bin/sh --version | head -1 | grep -i -q "bash" ) && echo "ERROR: /bin/sh must be bash, pls check" && exit 1
	( ! /usr/bin/awk -V | head -1 | grep -i -q "GNU Awk" ) && echo "ERROR: /usr/bin/awk must be gawk, pls check" && exit 1
	( ! /usr/bin/yacc --help | head -1 | grep -i -q "bison" ) && echo "ERROR: /usr/bin/yacc must be bison based, pls check" && exit 1
}

function func_lfs_build_start() {
	usage="Usage: $FUNCNAME [pkg_name] [flag_file]"
	[ $# -lt 1 ] && echo $usage && exit 1

	echo "INFO: $(date "+%Y-%m-%d %H:%M:%S") Start of building $1"
	[ -e "$2" ] && echo "INFO: seems already build" && return 1

	func_validate_exist_file $1
	func_lfs_pre_check
	\cd /mnt/lfs/sources
}

function func_lfs_build_end() {
	usage="Usage: $FUNCNAME [pkg_name] [flag_file]"
	[ $# -lt 1 ] && echo $usage && exit 1

	pkg_uncompress_dir=/mnt/lfs/sources/${1%%.tar*}
	pkg_build_dir=${pkg_uncompress_dir}-build

	func_validate_exist_file $pkg_uncompress_dir $pkg_build_dir
	rm -rf $pkg_uncompress_dir $pkg_build_dir
	[ ! -e "$2" ] && func_die "ERROR: seems build failed ($2 not exist)"
	echo "INFO: $(date "+%Y-%m-%d %H:%M:%S") End of building $1"
}

function func_lfs_build_start_build() {
	usage="Usage: $FUNCNAME [pkg_name]"
	[ $# -lt 1 ] && echo $usage && exit 1

	pkg_build_dir=/mnt/lfs/sources/${1%%.tar*}-build
	mkdir -v $pkg_build_dir
	cd $pkg_build_dir
}

function func_lfs_build_make_install() {
	make || func_die "ERROR: failed to 'make', pkg: $1"
	make install || func_die "ERROR: failed to 'make install', pkg: $1"
}

function func_lfs_build_binutils() {
	pkg_name=binutils-2.23.2.tar.bz2 
	flag_file=/tools/bin/x86_64-lfs-linux-gnu-ld 

	func_lfs_build_start $pkg_name $flag_file || return 0
	func_uncompress_cd $pkg_name

	# Fix syntax errors that prevent the documentation from building with Texinfo-5.1
	sed -i -e 's/@colophon/@@colophon/' -e 's/doc@cygnus.com/doc@@cygnus.com/' bfd/doc/bfd.texinfo

	func_lfs_build_start_build $pkg_name
	../binutils-2.23.2/configure --prefix=/tools --with-sysroot=$LFS --with-lib-path=/tools/lib --target=$LFS_TGT --disable-nls --disable-werror || func_die "ERROR: failed to configure"
	# If building on x86_64, create a symlink to ensure the sanity of the toolchain:
	[ "$(uname -m)" = "x86_64" ] && mkdir -v /tools/lib && ln -sv lib /tools/lib64 

	func_lfs_build_make_install $pkg_name

	func_lfs_build_end $pkg_name $flag_file
}


function func_lfs_build_gcc() {
	pkg_name=gcc-4.8.1.tar.bz2
	flag_file=/tools/bin/x86_64-lfs-linux-gnu-gcc

	func_lfs_build_start $pkg_name $flag_file || return 0
	func_uncompress_cd $pkg_name
	func_uncompress ../mpfr-3.1.2.tar.xz && mv -v mpfr-3.1.2 mpfr 
	func_uncompress ../gmp-5.1.2.tar.xz && mv -v gmp-5.1.2 gmp
	func_uncompress ../mpc-1.0.1.tar.gz && mv -v mpc-1.0.1 mpc

	# change the location of GCC's default dynamic linker to use the one installed in /tools, also removes /usr/include from GCC's include search path
	for file in $(find gcc/config -name linux64.h -o -name linux.h -o -name sysv4.h)
	do
		cp -uv $file{,.orig}
		sed -e 's@/lib\(64\)\?\(32\)\?/ld@/tools&@g' -e 's@/usr@/tools@g' $file.orig > $file
echo '
#undef STANDARD_STARTFILE_PREFIX_1
#undef STANDARD_STARTFILE_PREFIX_2
#define STANDARD_STARTFILE_PREFIX_1 "/tools/lib/"
#define STANDARD_STARTFILE_PREFIX_2 ""' >> $file
		touch $file.orig
	done
	sed -i '/k prot/agcc_cv_libc_provides_ssp=yes' gcc/configure

	func_lfs_build_start_build $pkg_name
	# export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/path/to/mpc/lib/
	#    --with-mpc-include=$(pwd)/../gcc-4.8.1/mpc/src   \
	#    --with-mpc-lib=$(pwd)/mpc/src/.libs              \
	#    --with-gmp-include=$(pwd)/../gcc-4.8.1/gmp       \
	#    --with-gmp-lib=$(pwd)/gmp/.libs                  \
	../gcc-4.8.1/configure                               \
	    --target=$LFS_TGT                                \
	    --prefix=/tools                                  \
	    --with-sysroot=$LFS                              \
	    --with-newlib                                    \
	    --without-headers                                \
	    --with-local-prefix=/tools                       \
	    --with-native-system-header-dir=/tools/include   \
	    --disable-nls                                    \
	    --disable-shared                                 \
	    --disable-multilib                               \
	    --disable-decimal-float                          \
	    --disable-threads                                \
	    --disable-libatomic                              \
	    --disable-libgomp                                \
	    --disable-libitm                                 \
	    --disable-libmudflap                             \
	    --disable-libquadmath                            \
	    --disable-libsanitizer                           \
	    --disable-libssp                                 \
	    --disable-libstdc++-v3                           \
	    --enable-languages=c,c++                         \
	    --with-mpfr-include=$(pwd)/../gcc-4.8.1/mpfr/src \
	    --with-mpfr-lib=$(pwd)/mpfr/src/.libs || func_die "ERROR: failed to configure"

	func_lfs_build_make_install $pkg_name

	# Question: useless or mistake? since the real file will be deleted?
	ln -sv libgcc.a `$LFS_TGT-gcc -print-libgcc-file-name | sed 's/libgcc/&_eh/'`

	func_lfs_build_end $pkg_name $flag_file
}

function func_lfs_build_linux() {
	pkg_name=linux-3.10.10.tar.xz
	flag_file=/tools/include/linux/limits.h

	func_lfs_build_start $pkg_name $flag_file || return 0
	func_uncompress_cd $pkg_name

	# this pkg not need build dir, make it just for consistency handling of func_lfs_build_end
	mkdir /mnt/lfs/sources/${pkg_name%%.tar*}-build

	make mrproper
	make headers_check
	make INSTALL_HDR_PATH=dest headers_install
	cp -rv dest/include/* /tools/include

	func_lfs_build_end $pkg_name $flag_file
}

######################################## linux headers


log=/mnt/lfs/ouyangzhu/log_$(date "+%Y-%m-%d_%H-%M-%S")

func_lfs_build_binutils	2>&1 | tee -a $log
func_lfs_build_gcc	2>&1 | tee -a $log
func_lfs_build_linux	2>&1 | tee -a $log

echo "INFO: all log goes to $log"
