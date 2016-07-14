#!/bin/bash

USAGE="$0 [cmd]"
[ $# -lt 1 ] && echo $usage && exit 1

# Any better way to not source those files everytime? Seems source in ~/.xprofile not help
[ -e ~/.myenv/zgen/lu_bash/envVarAll ] && source ~/.myenv/zgen/lu_bash/envVarAll
[ -e ~/.myenv/zgen/lu_bash/envFuncAll ] && source ~/.myenv/zgen/lu_bash/envFuncAll

#wmctrl -a "$1" || eval $2
#eval "$@"
"$@"

#TODO: fix the window title!
