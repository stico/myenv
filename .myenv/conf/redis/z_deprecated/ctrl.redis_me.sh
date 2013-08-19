#!/bin/sh

USAGE="Usage: $0 start/stop/status/restart"
[ $# -lt 1 ] && echo $USAGE && exit 1

# Variables
NAME=redis_me
PORT=6379
DATA=/data/redis/$NAME
PID=$DATA/${NAME}.pid
CMD_CLIENT=$MY_DEV/redis/bin/redis-cli
CMD_SERVER=$MY_DEV/redis/bin/redis-server
CONF_TARGET=$DATA/${NAME}.conf
CONF_TEMPLATE=$MY_ENV/conf/redis/conf.origin.2.6.14.conf

# Check and Prepare
mkdir -p $DATA
sed -e "s/^pidfile\s.*/pidfile $PID/;s/^dir\s.*/dir $DATA/" $CONF_TEMPLATE > $CONF_TARGET
[ ! -e $DATA ] && echo "ERROR: $DATA not exist!" && exit 1
[ ! -e $CMD_CLIENT ] && echo "ERROR: $CMD_CLIENT not exist!" && exit 1
[ ! -e $CMD_SERVER ] && echo "ERROR: $CMD_SERVER not exist!" && exit 1
[ ! -e $CONF_TARGET ] && echo "ERROR: $CONF_TARGET not exist!" && exit 1

case "$1" in
    start)
        if [ -f $PID ]
        then
                echo "$PID exists, process is already running or crashed"
        else
                echo "Starting Redis server..."
                $CMD_SERVER $CONF_TARGET --dir $DATA --pidfile $PID &>> $DATA/redis.log &
        fi
        ;;
    status)
        if [ -f $PID ]
        then
                echo "$PID exists, process is already running or crashed"
		ps -ef | grep $(cat $PID) | grep -v grep
        else
                echo "$PID not exists, process is not running"
	fi
        ;;
    stop)
        if [ ! -f $PID ]
        then
                echo "$PID does not exist, process is not running"
        else
                PID=$(cat $PID)
                echo "Stopping ..."
                $CMD_CLIENT -p $PORT shutdown
                while [ -x /proc/${PID} ]
                do
                    echo "Waiting for Redis to shutdown ..."
                    sleep 1
                done
                echo "Redis stopped"
        fi
        ;;
    restart)
	sh $0 stop
	sh $0 start
	;;
    *)
        echo $USAGE
        ;;
esac
