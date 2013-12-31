myenv_conf_graphite=/home/ouyangzhu/.myenv/conf/graphite

wsgi=/home/ouyangzhu/.virtualenvs/graphite/conf/graphite.wsgi
carbon=/home/ouyangzhu/.virtualenvs/graphite/conf/carbon.conf
storage_schemas=/home/ouyangzhu/.virtualenvs/graphite/conf/storage-schemas.conf
storage_agrregation=/home/ouyangzhu/.virtualenvs/graphite/conf/storage-aggregation.conf

cp $wsgi $myenv_conf_graphite/conf_$(basename $wsgi)
cp $carbon $myenv_conf_graphite/conf_$(basename $carbon)
cp $storage_schemas $myenv_conf_graphite/conf_$(basename $storage_schemas)
cp $storage_agrregation $myenv_conf_graphite/conf_$(basename $storage_agrregation)
