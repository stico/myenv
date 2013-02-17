#! /bin/sh

MONGO_HOME=/data/services/monogo/mongodb-linux-x86_64-2.2.2
MONGO_CONF=/data/mongo

#$MONGO_HOME/bin/mongod --auth --logpath $MONGO_CONF/logs/mongod.log --logappend --dbpath $MONGO_CONF/data/ &
$MONGO_HOME/bin/mongod --logpath $MONGO_CONF/logs/mongod.log --logappend --dbpath $MONGO_CONF/data/ &
