#!/bin/bash

# background: this script is for the YY anniversary, request http file, write to static file for nginx serve as static file
# add cron job to ensure consistently running: */1 *   * * *   root    bash /data/file/nianhui/static/script/update.sh >> /data/file/nianhui/static/script/update.log 2>&1

# TODO: extract func_is_cronjob_running, NOTE: 1) might need grep the cron setting line to check if there is a sh/bash there

# detect program
program=`readlink -f "$0"`
proc_count=`ps -ef | grep "$program" | wc -l`
echo "INFO: check if process already running: $program, $proc_count" 
(( $proc_count > 4 )) && echo "INFO: Proccess already running" && exit 1		# 4 means: the `` cmd substitution, plus the grep line itself, plus the crontab cause 2 lines (cron invoke + script itself, NOTE: always 2 lines, no matter there is a "bash" on the crontab line or not, why?)

echo "INFO: starting script: $program"
queryBig=/data/file/nianhui/static/queryBig
queryProgramBase=/data/file/nianhui/static/queryProgram
[ ! -e $queryProgramBase ] && mkdir -p $queryProgramBase 
while true ; do 

	dateTime=`date "+%Y%m%d_%H%M%S"`

	wget --output-document=${queryProgramBase}/20130124.html_${dateTime} --timeout=3  --tries=1 "http://query.2013.yy.com/queryProgram/20130124.html"
	previous_file=`readlink -e ${queryProgramBase}/20130124.html`
	#echo "INFO: ---- "`readlink -e ${queryProgramBase}/20130124.html`
	ln -snf ${queryProgramBase}/20130124.html_${dateTime} ${queryProgramBase}/20130124.html
	[ -e "$previous_file" ] && rm -f "$previous_file" || echo "ERROR: can not delete $previous_file"

	wget --output-document=${queryProgramBase}/schedule2.js_${dateTime} --timeout=3  --tries=1 "http://query.2013.yy.com/queryProgram/schedule2.js"
	previous_file=`readlink -e ${queryProgramBase}/schedule2.js`
	#echo "INFO: ${queryProgramBase}/schedule2.js ---- "`readlink -e ${queryProgramBase}/schedule2.js`
	ln -snf ${queryProgramBase}/schedule2.js_${dateTime} ${queryProgramBase}/schedule2.js
	[ -e "$previous_file" ] && rm -f "$previous_file" || echo "ERROR: can not delete $previous_file"

	wget --output-document=${queryBig}_${dateTime} --timeout=3 --tries=1 "http://query.2013.yy.com/queryBig"
	previous_file=`readlink -e ${queryBig}`
	#echo "INFO: ${queryBig} ---- "`readlink -e ${queryBig}`
	ln -snf ${queryBig}_${dateTime} ${queryBig}
	[ -e "$previous_file" ] && rm -f "$previous_file" || echo "ERROR: can not delete $previous_file"

	sleep 1
	# todo clean up
done
