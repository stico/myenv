
cmd_composer=composer
#project_path=~/data/httpd/httpd_me/data/zf2-tutorial
project_path=~/data/httpd/httpd_me/data-vhost-zf2

common_func=$MY_ENV/ctrl/common.func.sh
[ ! -e "$common_func" ] && echo "ERROR: $common_func not exist" && exit 1 || source $common_func

func_validate_inexist $project_path
func_validate_cmd_exist $cmd_composer

$cmd_composer create-project --repository-url="https://packages.zendframework.com" -s dev zendframework/skeleton-application $project_path
cd $project_path
$cmd_composer self-update
$cmd_composer install
