#!/bin/sh

# Prepare Feihu Dir
feihu=/data/apps/feihu
feihu_install=/data/apps/feihu_install
[ ! -e $feihu ] && sudo mkdir $feihu && sudo chown ouyangzhu:ouyangzhu $feihu
[ ! -e $feihu_install ] && sudo mkdir $feihu_install && sudo chown ouyangzhu:ouyangzhu $feihu_install

# Setup nodejs
node_url=http://nodejs.org/dist/v0.10.24/node-v0.10.24-linux-x64.tar.gz
node_pkg=$feihu_install/node-v0.10.24-linux-x64.tar.gz
node_src=$feihu_install/node-v0.10.24-linux-x64
node_target=$feihu/node-v0.10.24-linux-x64
if [ ! -e $node_target ] ; then
	[ ! -e $node_pkg ] && wget $node_url -O $node_pkg

	cd $feihu
	tar zxvf $node_pkg
fi

# Setup stats
statsd_url=https://github.com/etsy/statsd
statsd_src=$feihu_install/statsd_-GIT-
statsd_target=$feihu/statsd
if [ ! -e $statsd_target ] ; then
	[ ! -e $statsd_src ] && cd $feihu_install && git clone $statsd_url $statsd_src

	mkdir -p $statsd_target
	cp -R $statsd_src/* $statsd_target

	echo '{graphitePort: 2003, graphiteHost: "183.136.136.188", port: 8125, backends: [ "./backends/graphite" ], legacyNamespace: "false", flushInterval: 10000}' >> $statsd_target/shipper.conf
fi

# Setup logstash
logstash_url=https://download.elasticsearch.org/logstash/logstash/logstash-1.3.2-flatjar.jar
logstash_pkg=$feihu_install/logstash-1.3.2-flatjar.jar
logstash_conf=$feihu_install/install_logstash_shipper.conf
logstash_target=$feihu/logstash/
if [ ! -e $logstash_target ] ; then
	[ ! -e $logstash_pkg ] && wget $logstash_url -O $logstash_pkg
	
	mkdir -p $logstash_target
	cp $logstash_pkg $logstash_target
	local_ip=$(/sbin/ifconfig | sed -n -e '/inet addr:\(127\|172\|192\|10\)/d;/inet addr/s/.*inet6* addr:\s*\([.:a-z0-9]*\).*/\1/p' | head -1)
	sed -e "s/ReplaceMe_127.0.0.1_ReplaceMe/$local_ip/" $logstash_conf > $logstash_target/shipper.conf
fi


# Final Setup
stop_script=$feihu/stop_shipper.sh
start_script=$feihu/start_shipper.sh
status_script=$feihu/status_shipper.sh
if [ ! -e $stop_script ] ; then
	cat > $stop_script <<-EOF
		#!/bin/bash

		statsd_pid=\$(ps -ef | grep statsd | grep -v grep | awk '{print \$2}' | uniq)
		echo kill \$statsd_pid
		kill \$statsd_pid

		logstash_pid=\$(ps -ef | grep logstash | grep -v grep | awk '{print \$2}' | uniq)
		echo kill \$logstash_pid
		kill \$logstash_pid
	EOF
fi
if [ ! -e $start_script ] ; then
	cat > $start_script <<-EOF
		#!/bin/bash
		
		echo nohup $node_target/bin/node $statsd_target/stats.js $statsd_target/shipper.conf >> $statsd_target/shipper.log 2>&1 &
		nohup $node_target/bin/node $statsd_target/stats.js $statsd_target/shipper.conf >> $statsd_target/shipper.log 2>&1 &

		echo nohup /usr/local/bin/java -jar $logstash_target/$(basename $logstash_pkg) agent -f $logstash_target/shipper.conf -l $logstash_target/shipper.log >> $logstash_target/shipper.log 2>&1 &
		nohup /usr/local/bin/java -jar $logstash_target/$(basename $logstash_pkg) agent -f $logstash_target/shipper.conf -l $logstash_target/shipper.log >> $logstash_target/shipper.log 2>&1 &
	EOF
fi
if [ ! -e $status_script ] ; then
	cat > $status_script <<-EOF
		#!/bin/bash
		echo "INFO: checking ports"
		netstat -an | grep ":8125"

		echo "INFO: checking process"
		ps -ef | grep "logstash\|statsd" | grep -v grep
	EOF
fi
