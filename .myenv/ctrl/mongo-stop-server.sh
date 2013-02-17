#! /bin/sh

MONGO_ID=`ps -ef | grep mongodb | grep linux | awk '{print $2}'`

if [ ! -z "$MONGO_ID" ];then
	kill -INT $MONGO_ID
fi
