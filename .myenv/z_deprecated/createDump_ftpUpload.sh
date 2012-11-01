#!/bin/bash
# This script is used for automatically generate thread dump for a thread and send the dump to a specified ftp

# prepare the dump name
dumpName=dump_`date "+%Y-%m-%d_%H:%M:%S"`

# make thread dump
pid=`ps -ef | grep traf_svr_1 | grep weblogic | awk '{print $2}'`
cat /dev/null > traf_svr_1.out
for x in {1..5}
do
	echo "--> At `date '+%Y-%m-%d %H:%M:%S'` dump with pid: $pid"
	kill -3 $pid
	sleep 2
done

# make a copy of the dump
echo "--> Copying dump to $dumpName"
cp traf_svr_1.out $dumpName

# connect to 124 and upload the dump file
echo "--> Try to connect to ftp server and upload"
ftp -v -n 10.0.5.47 << !
user productStat productStat
cd temp_stico/jca_temp
put $dumpName
bye
