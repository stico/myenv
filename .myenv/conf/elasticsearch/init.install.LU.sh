#!/bin/bash

# Load common function
source ${HOME}/.myenv/myenv_func.sh || eval "$(wget -q -O - "https://raw.github.com/stico/myenv/master/.myenv/myenv_func.sh")" || exit 1

# Variable
ver=0.90.9
name=elasticsearch-${ver}
source=https://download.elasticsearch.org/elasticsearch/elasticsearch/${name}.zip
ecs_base=~/Documents/ECS/elasticsearch
dev_base=~/dev/${name}

func_download "${source}" "${ecs_base}" "--no-check-certificate"
func_uncompress "${ecs_base}.zip" "${dev_base}"
