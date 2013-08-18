#!/bin/bash
# TODO: able to update port
# TODO: able to update settings in $TOMCAT_HOME/conf/*

USAGE="Usage: tomcat.sh start/stop xxx.war [debug/jmx]"
[ "$#" -lt 2 ] && echo $USAGE && exit 1

######################################## Settings
PROFILE=test
ACTION=$1
WAR_PATH=`readlink -f $2`
APP_PORT=8080			# Not really changeable yet!

######################################## Pre-Check
[ -z "$ACTION" ] && echo "ERROR: Env ACTION is empty, pls check!" && exit 1
[ -z "$WAR_PATH" ] && echo "ERROR: Env WAR_PATH is empty, pls check!" && exit 1
[ -z "$JAVA_HOME" ] && echo "ERROR: Env JAVA_HOME is empty, pls check!" && exit 1
[ -z "$TOMCAT_HOME" ] && echo "ERROR: Env JAVA_HOME is empty, pls check!" && exit 1

######################################## Functions
function func_kill_pid_file() {
    FILE=$1
    if [ -f "$FILE" ] ; then
        PID=`cat $FILE`
        echo -n "$HOST_NAME: killing $PID . "
        TIMEOUT=3
        while (( TIMEOUT-- >= 0 )); do
            sleep 1
            if [ -f "$FILE" ] ; then
               kill -9 "$PID" 2>/dev/null
               echo -n ". "
            fi
        done
        rm -f "$FILE"
        echo "OK"
    fi
}

function func_gen_java_opts() {
	JAVA_WORD_LEN=`(file $JAVA_HOME/bin/java | grep -q 64-bit) && echo 64 || echo 32`
	MEM_TOTAL=`cat /proc/meminfo | grep MemTotal | awk '{printf "%d", $2/1024 }'`

	# Based on PROFILE
	case $PROFILE in
	"release")
		if [ "$JAVA_WORD_LEN" -eq 64 ] 
		then JAVA_OPTS=" -server -Xmx2g -Xms2g -Xmn512m -XX:PermSize=192m -Xss256k -XX:+DisableExplicitGC -XX:+UseConcMarkSweepGC -XX:+CMSParallelRemarkEnabled -XX:+UseCMSCompactAtFullCollection -XX:LargePageSizeInBytes=128m -XX:+UseFastAccessorMethods -XX:+UseCMSInitiatingOccupancyOnly -XX:CMSInitiatingOccupancyFraction=70"
		else JAVA_OPTS=" -server -Xms1024m -Xmx1024m -XX:PermSize=128m -XX:SurvivorRatio=2 -XX:+UseParallelGC "
		fi
		;;
	"test")
		JAVA_OPTS=" -server -Xms1024m -Xmx1024m -XX:MaxPermSize=128m -XX:SurvivorRatio=2 -XX:+UseParallelGC "
		;;
	"dev")
		JAVA_OPTS=" -server -Xms64m -Xmx1024m -XX:MaxPermSize=128m "
		;;
	*) 
		echo "ERROR: PROFILE=$PROFILE should be only: release, test, dev!" 1>&2
		exit 1
		;;
	esac

	# Necessary opts
	JAVA_OPTS=" $JAVA_OPTS -Djava.awt.headless=true -Djava.net.preferIPv4Stack=true -Duser.timezone=Asia/Shanghai -Dfile.encoding=UTF-8"

	# Based on input (not really used yet)
	OPTS_JMX=" -Dcom.sun.management.jmxremote.port=$((APP_PORT+9)) -Dcom.sun.management.jmxremote.ssl=false -Dcom.sun.management.jmxremote.authenticate=false "
	OPTS_DEBUG=" -Xdebug -Xnoagent -Djava.compiler=NONE -Xrunjdwp:transport=dt_socket,address=$((APP_PORT+8)) "
	[ "$1" = "jmx" ] && JAVA_OPTS="$JAVA_OPTS $OPTS_JMX"
	[ "$1" = "debug" ] && JAVA_OPTS="$JAVA_OPTS $OPTS_DEBUG"

	echo $JAVA_OPTS
}

function func_gen_deploy_home() {
	# use 2 above level dir, a bit danger assumption
	echo ${WAR_PATH} | sed -e 's:.*/\([^/]*/[^/]*/.*\):\1:;s:/:_:g;s:.war$::'
}

######################################## ENV for Tomcat - Manditory
DEPLOY_NAME=`func_gen_deploy_home`
DEPLOY_PATH=/data/tomcat/${DEPLOY_NAME#_}
export LANG=zh_CN.UTF-8
export JAVA_OPTS=`func_gen_java_opts`
export CATALINA_HOME=$TOMCAT_HOME
export CATALINA_BASE="$DEPLOY_PATH"
export CATALINA_OUT="$DEPLOY_PATH/logs/tomcat_stdout.log"
export CATALINA_PID="$DEPLOY_PATH/tomcat.pid"

######################################## ENV for Tomcat - Optional
#export JAVA_HOME=/usr/local/java
#export JRE_HOME=$JAVA_HOME/jre
#export TOMCAT_USER=www-data
#export JSVC_OPTS='-jvm server'
#export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$CATALINA_HOME/lib

######################################## Actions
case $ACTION in
"start")
	STR=`ps -C java -f --width 1000 | grep "$DEPLOY_PATH"`
	[ ! -z "$STR" ] && echo -e "Already started\n$STR" && exit 1;

	[ -d "$DEPLOY_PATH" ] && rm -rf $DEPLOY_PATH 
	mkdir -p "$DEPLOY_PATH" "$DEPLOY_PATH/webapps" "$DEPLOY_PATH/bin" "$DEPLOY_PATH/logs" "$DEPLOY_PATH/temp" "$DEPLOY_PATH/conf"

	#cp $MY_ENV/conf/tomcat/settings/* $DEPLOY_PATH/conf
	cp -R $TOMCAT_HOME/conf/* $DEPLOY_PATH/conf
	cp $WAR_PATH $DEPLOY_PATH/webapps/ROOT.war	
	
	echo "$MY_ENV/ctrl/tomcat stop $WAR_PATH" >> $DEPLOY_PATH/bin/stop.sh
	echo "$MY_ENV/ctrl/tomcat start $WAR_PATH" >> $DEPLOY_PATH/bin/start.sh
	echo "$MY_ENV/ctrl/tomcat status $WAR_PATH" >> $DEPLOY_PATH/bin/status.sh
	$TOMCAT_HOME/bin/startup.sh
	;;
"stop")
	$TOMCAT_HOME/bin/shutdown.sh
	func_kill_pid_file $CATALINA_PID
	;;
"status")
	STR=`ps -C java -f --width 1000 | grep "$DEPLOY_PATH"`
	[ -z "$STR" ] && echo "Not running" || echo $STR
	;;
*) 
	echo "ERROR: ACTION=$ACTION should be only: start, stop, status!"
	exit 1
	;;
esac
