#!/bin/bash

# Load common function
source ~/.myenv/env_func_bash || eval "$(wget -q -O - "https://raw.github.com/stico/myenv/master/.myenv/env_func_bash")" || exit 1

# Variable
ver=1.3.2
name=logstash-${ver}-flatjar.jar
source=https://download.elasticsearch.org/logstash/logstash/${name}
dev_base=~/dev/logstash-${ver}

func_download "$source" "$dev_base" "--no-check-certificate"
