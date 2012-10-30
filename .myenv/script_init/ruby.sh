#!/bin/bash

[[ ! -d $RVM_HOME && ! -L $RVM_HOME ]] && echo "ERROR: $RVM_HOME not set or not exist, exit!" && exit 1 
[[ -e $RVM_HOME/bin/ruby ]] && echo "ERROR: seems rvm has already installed, exit!" && exit 1 
echo "Precondition check success."

echo "Start to init RVM and latest stable ruby env into: $RVM_HOME"
\curl -L https://get.rvm.io | bash -s stable --ruby
rvm install ruby-1.9.3
rvm docs generate all
