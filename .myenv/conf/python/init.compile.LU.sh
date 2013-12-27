#!/bin/bash
# (2013-110-6) work with python-2.7.5

name=Python-2.7.5
source=/tmp/$name
target=$HOME/dev/${name/P/p}
source_pkg=$HOME/Documents/ECS/python/${name}.src.tgz

# Prepare. More?: tk-dev libc6-dev 
sudo apt-get install -y libgdbm-dev libreadline-dev libsqlite3-dev libbz2-dev libssl-dev libncursesw5-dev libncurses5-de vlibncursesw5-dev zlib1g-dev 
sudo apt-get build-dep python2.7
[ -e "$source" ] && rm -rf "$source"
tar zxvf "$source_pkg" -C /tmp

# Check
[ ! -e "$source" ] && echo "ERROR: $source not exist!" && exit 1
[ -e "$target" ] && echo "ERROR: $target already exist!" && exit 1
[ -z "$WORKON_HOME" ] && echo "ERROR: env var \$WORKON_HOME not set or empty!" && exit 1
( ! echo $PATH | grep -q "python/bin") && echo "ERROR: 'python/bin' not found in PATH env!" && exit 1

# Compile and Make, --enable-shared is needed when compile wsgi which used by dijango, --enable-unicode=ucs4 seem need by django/sqllite, why?
cd $source
make clean
./configure --prefix=$target --enable-shared --with-ssl --enable-unicode=ucs4
[ "$?" -eq 0 ] && make && make install || echo "ERROR: compile/install failed!"

# Create Link
target_link=${target%-*}
[ ! -e "$target_link" ] && ln -s $target/ $target_link

# Install tools (setuptools, pip)
cmd_python=$target_link/bin/python
[ ! -e "$cmd_python" ] && echo "ERROR: $cmd_python not exist!" && exit 1
wget https://bitbucket.org/pypa/setuptools/raw/bootstrap/ez_setup.py -O - | $cmd_python
wget https://raw.github.com/pypa/pip/master/contrib/get-pip.py -O - | $cmd_python

# Install tools (virtualenv, virtualenvwrapper)
cmd_pip=$target_link/bin/pip
[ ! -e "$cmd_pip" ] && echo "ERROR: $cmd_pip not exist!" && exit 1
[ ! -e "$HOME/.virtualenvs" ] && $cmd_pip install virtualenv && $cmd_pip install virtualenvwrapper
[ ! -e "$WORKON_HOME" ] && mkdir "$WORKON_HOME" 
