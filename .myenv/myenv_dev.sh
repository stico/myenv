#!/bin/bash

#source $HOME/.myenv/myenv_lib.sh || eval "$(wget -q -O - "https://raw.github.com/stico/myenv/master/.myenv/myenv_lib.sh")" || exit 1

dev_effective_url() {
	local usage="Usage: $FUNCNAME <url>"
	local desc="Desc: get effective url (in case there is redirection)" 
	func_param_check 1 "${desc} \n ${usage} \n" "$@"

	local effective_url
	effective_url=$(curl -Ls -o /dev/null -w "%{url_effective}" "${1}")
	[[ "$?" == "0" ]] && echo "${effective_url}" || echo "ERROR: fetch effective url failed, curl exit status: $?"
}

dev_time_on_host() { 
	func_param_check 1 "Usage: $FUNCNAME <url> <host...>" "$@"

	local url="${1}"
	local domain_name="$(echo "${url}" | awk -F '[/:]' '{print $4}')"
	shift

	for host ; do
		echo -e "INFO: start to timing on real_url: ${real_url}" 
		real_url="${url/${domain_name}/${host}}"
		curl -w '\ttime_namelookup\t\t%{time_namelookup}\n\ttime_connect\t\t%{time_connect}\n\ttime_appconnect\t\t%{time_appconnect}\n\ttime_pretransfer\t%{time_pretransfer}\n\ttime_redirect\t\t%{time_redirect}\n\ttime_starttransfer\t%{time_starttransfer}\n\t----------\n\ttime_total\t\t%{time_total}\n' \
		     -Ls -o /dev/null -H "Host: ${domain_name}" "${real_url}"
	done
}

dev_dl_on_host() {
	local usage="Usage: $FUNCNAME <url> <host...>"
	local desc="Desc: download url with specified hosts, one by one" 
	func_param_check 2 "${desc} \n ${usage} \n" "$@"

	local url="${1}"
	shift

	# try to use filename in redirected url
	local effective_url=$(dev_effective_url "${url}")
	local filename="${effective_url##*/}"
	local domain_name="$(echo "${url}" | awk -F '[/:]' '{print $4}')"

	# prepare
	local tmp_dir="$(mktemp -d -t dev_dl_on_host.XXXXXX)"
	local host real_url filename
	\cd "${tmp_dir}"

	echo -e "INFO: start to download. \n\twork dir\t${tmp_dir} \n\tdomain_name\t${domain_name} \n\turl\t\t${url} \n\teffective_url\t${effective_url}" 
	for host ; do
		# NOTE: using original url, NOT redirected url
		real_url="${url/${domain_name}/${host}}"
		host_filename="${host}_${filename}"

		echo "INFO: curl -Ls -H \"Host: ${domain_name}\" \"${real_url}\" > \"${host_filename}\""
		curl -Ls -H "Host: ${domain_name}" "${real_url}" > "${host_filename}"
		echo "INFO: $(\ls -l ${host_filename})"
	done
	\cd - > /dev/null 2>&1
}

dev_http_header() { 
	func_param_check 1 "Usage: $FUNCNAME <url>" "$@"
	#TODO
}

dev_http_body() { 
	func_param_check 1 "Usage: $FUNCNAME <url>" "$@"
	#TODO
}

dev_http_code() { 
	func_param_check 1 "Usage: $FUNCNAME <url>" "$@"
	curl -s -o /dev/null -w "%{http_code}" "${1}" || echo " ERROR: request failed!"
}

dev_http_resp() { 
	func_param_check 1 "Usage: $FUNCNAME <url>" "$@"

	echo "sending request to: $1"
	wget --timeout=2 --tries=1 -O - 2>&1 "$1"	\
	| sed -e '/'${1//\//.}'/d'			\
	| sed -e '/^Resolving/d'			\
	| sed -e '/^Length/d'				\
	| sed -e '/^Saving/d;/100%.*=.*s/d'		\
	| sed -e '/0K.*0.00.=0s/d'			\
	| sed -e '/^$/d'
}
