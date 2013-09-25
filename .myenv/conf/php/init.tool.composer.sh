target_dir=~/dev/php/bin

[ ! -e "$target_dir" ] && echo "ERROR: $target_dir not exist" && exit 1

curl -s https://getcomposer.org/composer.phar -o $target_dir/composer.phar
cd $target_dir
ln -s composer.phar composer
chmod u+x composer.phar composer
