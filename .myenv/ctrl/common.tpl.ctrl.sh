#!/bin/bash

dir=`dirname $0`
COMMON_ENV=env.sh
COMMON_FUNC=common.func.sh

[ ! -e "$dir/$COMMON_ENV" ] && echo "$dir/$COMMON_ENV not exist!" && exit 1 || source $dir/$COMMON_ENV
[ ! -e "$dir/$COMMON_FUNC" ] && echo "$dir/$COMMON_FUNC not exist!" && exit 1 || source $dir/$COMMON_FUNC

