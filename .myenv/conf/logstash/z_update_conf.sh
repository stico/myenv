collector_in_data=/data/logstash/collector/conf/collector.conf 
collector_in_env=/home/ouyangzhu/.myenv/conf/logstash/conf_collector.conf
cp $collector_in_data $collector_in_env

shipper_in_data=/data/logstash/shipper/conf/shipper.conf 
shipper_in_env=/home/ouyangzhu/.myenv/conf/logstash/conf_shipper.conf
cp $shipper_in_data $shipper_in_env
