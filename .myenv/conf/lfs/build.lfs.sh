#!/bin/bash

# NOTE: on my thinkpad x200s, 1SBU is about 1 minute

# TODO: why binutils nothing in /tools after make install
# TODO: can not build gcc

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
	[ $# -lt 1 ] && echo $usage && return 1
	
	echo "$@" 1>&2
	exit 1
}

function func_pre_check() {
	func_validate_current_user lfs
	func_validate_exist /mnt/lfs/sources /mnt/lfs/boot /mnt/lfs/tools /tools
}

function func_build_binutils() {
echo "INFO: start to build binutils"
cd /mnt/lfs/sources
func_pre_check
func_validate_exist binutils-2.23.2.tar.bz2
tar xjvf binutils-2.23.2.tar.bz2 && cd binutils-2.23.2 || func_die "ERROR: failed to uncompress"
# Fix syntax errors that prevent the documentation from building with Texinfo-5.1
sed -i -e 's/@colophon/@@colophon/' -e 's/doc@cygnus.com/doc@@cygnus.com/' bfd/doc/bfd.texinfo
mkdir -v ../binutils-build
cd ../binutils-build
../binutils-2.23.2/configure --prefix=/tools --with-sysroot=$LFS --with-lib-path=/tools/lib --target=$LFS_TGT --disable-nls --disable-werror || func_die "ERROR: failed to configure"
make || func_die "ERROR: failed to make"
# If building on x86_64, create a symlink to ensure the sanity of the toolchain:
[ "$(uname -m)" = "x86_64" ] && mkdir -v /tools/lib && ln -sv lib /tools/lib64 
make install || func_die "ERROR: failed to make install"
rm -rf /mnt/lfs/sources/binutils-2.23.2 /mnt/lfs/sources/binutils-build
}


function func_build_gcc() {
echo "INFO: start to build gcc"
cd /mnt/lfs/sources
func_pre_check
func_validate_exist gcc-4.8.1.tar.bz2
tar xjvf gcc-4.8.1.tar.bz2 && cd gcc-4.8.1 || func_die "ERROR: failed to uncompress"
tar -Jxf ../mpfr-3.1.2.tar.xz && mv -v mpfr-3.1.2 mpfr || func_die "ERROR: failed to uncompress"
tar -Jxf ../gmp-5.1.2.tar.xz && mv -v gmp-5.1.2 gmp || func_die "ERROR: failed to uncompress"
tar -zxf ../mpc-1.0.1.tar.gz && mv -v mpc-1.0.1 mpc || func_die "ERROR: failed to uncompress"
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
mkdir -v ../gcc-build
cd ../gcc-build
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
make || func_die "ERROR: failed to make"
make install || func_die "ERROR: failed to make install"
# Question: useless or mistake? since the real file will be deleted?
ln -sv libgcc.a `$LFS_TGT-gcc -print-libgcc-file-name | sed 's/libgcc/&_eh/'`
rm -rf /mnt/lfs/sources/gcc-4.8.1 /mnt/lfs/sources/gcc-build
}


######################################## linux headers




exit
func_build_binutils
func_build_gcc
