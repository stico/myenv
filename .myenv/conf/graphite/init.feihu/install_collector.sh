#!/bin/sh

# Prepare Feihu Dir
feihu=/data/apps/feihu
feihu_install=/data/apps/feihu_install
[ ! -e $feihu ] && sudo mkdir $feihu && sudo chown ouyangzhu:ouyangzhu $feihu
[ ! -e $feihu_install ] && sudo mkdir $feihu_install && sudo chown ouyangzhu:ouyangzhu $feihu_install

function func_use_compiled_python() {
	export PYTHON_HOME=$python_target
	export PYTHON=$PYTHON_HOME/bin/python
	export PATH=$python_target/bin:$PATH
	export LD_LIBRARY_PATH=$python_target/lib:$LD_LIBRARY_PATH
}

# Compile Python
python_ver=2.7.5
python_url=http://www.python.org/ftp/python/${python_ver}/Python-${python_ver}.tgz
python_pkg=$feihu_install/Python-${python_ver}.tgz
python_src=$feihu_install/Python-${python_ver}
python_target=$feihu/Python-${python_ver}
python_cmd=$python_target/bin/python
if [ ! -e $python_target ] ; then
	[ ! -e $python_pkg ] && wget $python_url -O $python_pkg
	cd $feihu_install && rm -rf $python_src 
	tar zxvf $python_pkg

	cd $python_src
	sudo apt-get install -y build-essential libgdbm-dev libreadline-dev libsqlite3-dev libbz2-dev libssl-dev libncursesw5-dev libncurses5-dev libncursesw5-dev zlib1g-dev 
	./configure --prefix=$python_target --enable-shared --with-ssl --enable-unicode=ucs4
	[ "$?" -eq 0 ] && make && make install

	func_use_compiled_python
	wget https://bitbucket.org/pypa/setuptools/raw/bootstrap/ez_setup.py -O - | $python_cmd
	wget https://raw.github.com/pypa/pip/master/contrib/get-pip.py -O - | $python_cmd
fi
func_use_compiled_python

# Compile Apache HTTPD
apr_url=http://archive.apache.org/dist/apr/apr-1.4.8.tar.gz
apr_pkg=$feihu_install/apr-1.4.8.tar.gz
apr_name=apr-1.4.8
apr_util_url=http://archive.apache.org/dist/apr/apr-util-1.5.2.tar.gz
apr_util_pkg=$feihu_install/apr-util-1.5.2.tar.gz
apr_util_name=apr-util-1.5.2
httpd_url=http://archive.apache.org/dist/httpd/httpd-2.4.6.tar.gz
httpd_pkg=$feihu_install/httpd-2.4.6.tar.gz
httpd_src=$feihu_install/httpd-2.4.6
httpd_target=$feihu/httpd-2.4.6
if [ ! -e $httpd_target ] ; then
	[ ! -e $httpd_pkg ] && wget $httpd_url -O $httpd_pkg
	[ ! -e $apr_pkg ] && wget $apr_url -O $apr_pkg
	[ ! -e $apr_util_pkg ] && wget $apr_util_url -O $apr_util_pkg

	cd $feihu_install && rm -rf $httpd_src
	tar zxvf $httpd_pkg \
	&& tar zxvf $apr_pkg -C $httpd_src/srclib && mv $httpd_src/srclib/$apr_name $httpd_src/srclib/${apr_name%-*} \
	&& tar zxvf $apr_util_pkg -C $httpd_src/srclib && mv $httpd_src/srclib/$apr_util_name $httpd_src/srclib/${apr_util_name%-*}

	cd $httpd_src
	sudo apt-get install -y build-essential libpcre3 libpcre3-dev
	httpd_conf_opts="
	--enable-so \
	--enable-log-debug \
	--enable-logio=static \
	--enable-suexec=shared \
	--enable-layout=Debian \
	--enable-log-config=static \
	--with-pcre=yes \
	--with-included-apr \
	--enable-pie \
	--enable-http \
	--enable-proxy \
	--enable-deflate \
	--enable-headers \
	--enable-rewrite \
	--enable-expires \
	--enable-proxy-fcgi \
	--enable-proxy-http \
	--enable-mime-magic \
	--enable-slotmem-shm \
	--enable-proxy-balancer
	"
	./configure --prefix=$httpd_target --with-mpm=prefork --enable-shared-mods=all $httpd_conf_opts
	[ "$?" -eq 0 ] && make && make install
fi

# Setup httpd
httpd_conf=$httpd_target/etc/apache2/httpd.conf
if [ ! -e ${httpd_conf}.bak ] ; then
	cp ${httpd_conf}{,.bak}
	sed -i -e "s/^Listen 80/Listen 8070/" $httpd_conf
	sed -i -e "s/^LogLevel warn/LogLevel info/" $httpd_conf
	sed -i -e "s/^#\(.*LoadModule.*slotmem_shm_module.*\)/\1/" $httpd_conf 
fi

# Install wsgi For apache 
wsgi_url=http://modwsgi.googlecode.com/files/mod_wsgi-3.4.tar.gz
wsgi_pkg=$feihu_install/mod_wsgi-3.4.tar.gz
wsgi_src=$feihu_install/mod_wsgi-3.4
wsgi_target=$httpd_target/usr/lib/apache2/modules/mod_wsgi.so
if [ ! -e $wsgi_target ] ; then
	[ ! -e $wsgi_pkg ] && wget $wsgi_url -O $wsgi_pkg

	cd $feihu_install && rm -rf $wsgi_src
	tar zxvf $wsgi_pkg
	cd $wsgi_src
	./configure --with-apxs=$httpd_target/usr/bin/apxs --with-python=$python_target/bin/python
	[ "$?" -eq 0 ] && make && make install
fi

################################################# Cairo, 12.04 not need, 10.10 failed
#sudo apt-get build-dep cairo
#
#exit
## Install pixman (ubuntu 10 apt-get version is too low)
#pixman_url=http://cairographics.org/releases/pixman-0.28.2.tar.gz
#pixman_pkg=$feihu_install/pixman-0.28.2.tar.gz
#pixman_src=$feihu_install/pixman-0.28.2
#pixman_target=$feihu/pixman-0.28.2
#if [ ! -e $pixman_target ] ; then
#	[ ! -e $pixman_pkg ] && wget $pixman_url -O $pixman_pkg
#
#	cd $feihu_install && rm -rf $pixman_src
#	tar zxvf $pixman_pkg
#	cd $pixman_src
#fi
#
#exit
## Install cairo (ubuntu 10 apt-get version is too low)
#cairo_url=http://cairographics.org/releases/cairo-1.12.14.tar.xz
#cairo_pkg=$feihu_install/cairo-1.12.14.tar.xz
#cairo_src=$feihu_install/cairo-1.12.14
#cairo_target=$feihu/cairo-1.12.14
#if [ ! -e $cairo_target ] ; then
#	[ ! -e $cairo_pkg ] && wget $cairo_url -O $cairo_pkg
#
#	cd $feihu_install && rm -rf $cairo_src
#	tar Jxvf $cairo_pkg
#	cd $cairo_src
#
#	./configure --prefix=$cairo_target
#	[ "$?" -eq 0 ] && make && make install
#fi
################################################# Cairo, 12.04 not need, 10.10 failed

# Install Graphite PYTHON Dependency
#py2cairo (pip not support)
py2cairo_url=http://cairographics.org/releases/py2cairo-1.10.0.tar.bz2
py2cairo_pkg=$feihu_install/py2cairo-1.10.0.tar.bz2
py2cairo_src=$feihu_install/py2cairo-1.10.0
py2cairo_target=$python_target/include/pycairo/pycairo.h
if [ ! -e $py2cairo_target ] ; then
	[ ! -e $py2cairo_pkg ] && wget $py2cairo_url -O $py2cairo_pkg

	cd $feihu_install && rm -rf $py2cairo_src
	tar jxvf $py2cairo_pkg
	cd $py2cairo_src
	sudo apt-get install -y libcairo2-dev
	./waf configure --prefix=$python_target
	./waf build
	./waf install
fi
#newer django version seems not play well 
pip install 'django<1.6'
pip install django-tagging
pip install python-memcached
#newer Twisted version seems not play well 
pip install 'Twisted<12.0'
pip install txamqp
pip install whisper
# python-ldap failed, but ok since it is optional
#pip install python-ldap	

# Install Graphite
graphite_url=https://github.com/graphite-project/graphite-web.git
graphite_src=$feihu_install/graphite-web_-GIT-
graphite_target=$feihu/graphite
if [ ! -e $graphite_target ] ; then
	[ ! -e $graphite_src ] && cd $feihu_install && git clone $graphite_url $graphite_src

	pip install carbon --install-option="--prefix=$graphite_target" --install-option="--install-lib=$graphite_target/lib"

	cd $graphite_src
	git checkout 0.9.x
	python $graphite_src/check-dependencies.py
	pip install graphite-web --install-option="--prefix=$graphite_target" --install-option="--install-lib=$graphite_target/lib"
fi

# Setup graphite
if [ ! -e $graphite_target/conf/carbon.conf ] ; then
	cd $graphite_target/conf
	cp carbon.conf{.example,}
	cp graphite.wsgi{.example,}
	cp storage-schemas.conf{.example,}
	cp storage-aggregation.conf{.example,}
	cp $graphite_target/lib/graphite/settings.py{,.bak}

	sed -i -e "s+/opt/graphite+${graphite_target}+" graphite.wsgi					
	sed -i -e "s+^SECRET_KEY.*=.*+SECRET_KEY = '*lk^6@0l0(iulga)fbvfy^(^uqk3j73d18@ur^xuTxY'+" $graphite_target/lib/graphite/settings.py
	sed -i "/\[default_1min_for_1day\]/,$d" storage-schemas.conf
	echo -e "\n[stats]\npattern = ^stats\\.\nretentions = 10s:1d,1m:30d,1h:1y\n\n[default_1min_for_1day]\npattern = .*\nretentions = 60s:1d" >> storage-schemas.conf
	sed -i -e '/\[default_average\]/,$d' storage-aggregation.conf
	echo -e "\n[statsd_lower]\npattern = \\.lower$\nxFilesFactor = 0.1\naggregationMethod = min\n\n[statsd_upper]\npattern = \\.upper$\nxFilesFactor = 0.1\naggregationMethod = max\n\n[statsd_upper_90]\npattern = \\.upper_90$\nxFilesFactor = 0.1\naggregationMethod = max\n\n[statsd_sum]\npattern = \\.sum$\nxFilesFactor = 0\naggregationMethod = sum\n\n[statsd_sum_90]\npattern = \\.sum_90$\nxFilesFactor = 0\naggregationMethod = sum\n\n[statsd_count]\npattern = \\.count$\nxFilesFactor = 0\naggregationMethod = sum\n\n[statsd_count_legacy]\npattern = ^stats_counts\\.\nxFilesFactor = 0\naggregationMethod = sum\n\n[default_average]\npattern = .*\nxFilesFactor = 0.5\naggregationMethod = average\n" >> storage-aggregation.conf

	# Time zone (not sure which one works, but works)
	cp $graphite_target/lib/graphite/local_settings.py{.example,}
	sed -i -e "s+^#TIME_ZONE = .*+TIME_ZONE = 'Asia/Shanghai'+" $graphite_target/lib/graphite/local_settings.py
	mkdir -p $graphite_target/webapp/graphite ; echo "TIME_ZONE = 'Asia/Shanghai'" > $graphite_target/webapp/graphite/local_settings.py

	cd $graphite_target/lib/graphite
	python manage.py syncdb
	# yes to create super user, 
	# copy and use example-graphite-vhost.conf in apache
fi

# Setup graphite for httpd
graphite_vhost=$graphite_target/examples/example-graphite-vhost.conf
if [ ! -e ${graphite_vhost}.bak ] ; then
	cp ${graphite_vhost}{,.bak}

	sed -i -e "s+/opt/graphite+${graphite_target}+" $graphite_vhost
	sed -i -e "s+<VirtualHost \*:80>+<VirtualHost \*:8070>+" $graphite_vhost
	sed -i -e "s+^WSGISocketPrefix run/wsgi+#WSGISocketPrefix run/wsgi+" $graphite_vhost
	sed -i -e "s+^[^#]*LoadModule wsgi_module.*+    LoadModule wsgi_module usr/lib/apache2/modules/mod_wsgi.so+" $graphite_vhost
	sed -i -e "s+^[[:blank:]]*WSGIDaemonProcess.*+& python-path=$PYTHON_HOME/lib/python2.7/site-packages:$PYTHON_HOME/lib:$graphite_target/lib+" $graphite_vhost
	sed -i -e '/\/Directory/,$d' $graphite_vhost
	echo -e "\n\t\tRequire all granted\n\t</Directory>\n\t<Directory $graphite_target/webapp/>\n\t\tRequire all granted\n\t</Directory>\n</VirtualHost>" >> $graphite_vhost
	echo -e "\nInclude $graphite_vhost" >> $httpd_conf
fi

# Final setup
stop_script=$feihu/collector_stop.sh
start_script=$feihu/collector_start.sh
status_script=$feihu/collector_status.sh
if [ ! -e $stop_script ] ; then
	cat > $stop_script <<-EOF
		#!/bin/bash

		echo $feihu/graphite/bin/carbon-cache.py stop
		$feihu/graphite/bin/carbon-cache.py stop

		apache_pid=\$(ps -ef | grep wsgi:graphite | grep -v grep | awk '{print \$3}' | uniq)
		echo kill \$apache_pid
		kill \$apache_pid
	EOF
fi
if [ ! -e $start_script ] ; then
	cat > $start_script <<-EOF
		#!/bin/bash

		export PYTHON_HOME=$feihu/Python-2.7.5
		export PYTHON=$PYTHON_HOME/bin/python
		export PATH=$feihu/Python-2.7.5/bin:$PATH
		export LD_LIBRARY_PATH=$feihu/Python-2.7.5/lib:$LD_LIBRARY_PATH

		echo $feihu/graphite/bin/carbon-cache.py start
		$feihu/graphite/bin/carbon-cache.py start
		echo $feihu/httpd-2.4.6/usr/sbin/apachectl -f $feihu/httpd-2.4.6/etc/apache2/httpd.conf &
		$feihu/httpd-2.4.6/usr/sbin/apachectl -f $feihu/httpd-2.4.6/etc/apache2/httpd.conf &
	EOF
fi
if [ ! -e $status_script ] ; then
	cat > $status_script <<-EOF
		#!/bin/bash
		echo "INFO: checking ports, graphite web on apache owns 8070, graphite carbon owns 2003"
		netstat -an | grep ":8070.*LISTEN\|:2003.*LISTEN"

		echo "INFO: checking process"
		ps -ef | grep "carbon-cache\|httpd" | grep -v grep
	EOF
fi
