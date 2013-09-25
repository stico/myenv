
cmd_composer=composer
#project_path=~/data/httpd/httpd_me/data/zf2-tutorial
project_path=~/data/httpd/httpd_me/data-vhost-zf2

[ ! -e ~/.myenv/env_func_bash ] && echo "ERROR: ~/.myenv/env_func_bash cmd_composer not exist" && exit 1 
source ~/.myenv/env_func_bash

func_validate_inexist $project_path
func_validate_cmd_exist $cmd_composer

$cmd_composer create-project --repository-url="https://packages.zendframework.com" -s dev zendframework/skeleton-application $project_path
cd $project_path
$cmd_composer self-update
$cmd_composer install
