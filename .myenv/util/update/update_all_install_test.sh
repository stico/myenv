installFile=update-server-install-1.2.2 \
&& work_dir=~/amp/`date "+%Y-%m-%d"` \
&& mkdir -p $work_dir \
&& cd $work_dir \
&& rm -rf update-server-install-* ; wget --user=release --password=abc123duowan123yy123 http://113.106.100.60:9999/deploy/release/update-server-install/${installFile}-bin.tar.gz \
&& tar xzvf ${installFile}-bin.tar.gz \
&& cd ${installFile} \
&& sudo bash ./install_test.sh
