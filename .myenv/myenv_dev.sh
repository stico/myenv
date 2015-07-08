#!/bin/bash

source $HOME/.myenv/myenv_lib.sh || eval "$(wget -q -O - "https://raw.github.com/stico/myenv/master/.myenv/myenv_lib.sh")" || exit 1

dev_url_domain_name() {
	local usage="Usage: $FUNCNAME <url>"
	local desc="Desc: extract domain name from url" 
	func_param_check 1 "${desc} \n${usage} \n" "$@"

	echo "${1}" | awk -F '[/:]' '{print $4}'
}

dev_curl() {
	local usage="Usage: $FUNCNAME <param> <url> [host...]"
	local desc="Desc: run curl with param. If specified hosts, perform against each one by one" 
	func_param_check 2 "${desc} \n${usage} \n" "$@"

	local param="${1}"
	local url="${2}"

	# if NOT specified hosts, just use same domain name
	if [ -z "${3}" ] ; then
		curl ${param} -- "${url}"
		return
	fi

	# if specified hosts, do it against host one by one
	shift;shift
	for host ; do
		local domain_name="$(dev_url_domain_name "${url}")"
		local url_on_host="${url/${domain_name}/${host}}"
		curl ${param} -H "Host: ${domain_name}" "${url_on_host}"
	done
}

dev_http_body() { 
	dev_curl "-s -L -o -" "$@"
}

dev_http_header() {
	dev_curl "-s -o /dev/null -D -" "$@"
}

dev_http_code() {
	dev_curl "-s -o /dev/null -w %{http_code}" "$@"
	echo ""	# create a newline
}

dev_effective_url() {
	dev_curl "-s -o /dev/null -L -w %{url_effective}" "$@"
}

dev_http_time() { 
	dev_curl "-s -o /dev/null -L -w time_namelookup\t\t%{time_namelookup}\ntime_connect\t\t%{time_connect}\ntime_appconnect\t\t%{time_appconnect}\ntime_pretransfer\t%{time_pretransfer}\ntime_redirect\t\t%{time_redirect}\ntime_starttransfer\t%{time_starttransfer}\n----------\ntime_total\t\t%{time_total}\n" "$@"
}

################################################################################
# Deprecated
################################################################################
#dev_http_resp() { 
#	func_param_check 1 "Usage: $FUNCNAME <url>" "$@"
#
#	echo "sending request to: $1"
#	wget --timeout=2 --tries=1 -O - 2>&1 "$1"	\
#	| sed -e '/'${1//\//.}'/d'			\
#	| sed -e '/^Resolving/d'			\
#	| sed -e '/^Length/d'				\
#	| sed -e '/^Saving/d;/100%.*=.*s/d'		\
#	| sed -e '/0K.*0.00.=0s/d'			\
#	| sed -e '/^$/d'
#}
