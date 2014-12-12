#!/bin/bash

source $HOME/.myenv/myenv_lib.sh || eval "$(wget -q -O - "https://raw.github.com/stico/myenv/master/.myenv/myenv_lib.sh")" || exit 1

dev_url_domain_name() {
	local usage="Usage: $FUNCNAME <url>"
	local desc="Desc: extract domain name from url" 
	func_param_check 1 "${desc} \n${usage} \n" "$@"

	echo "${1}" | awk -F '[/:]' '{print $4}'
}

dev_download() {
	local usage="Usage: $FUNCNAME <url> [host...]"
	local desc="Desc: download url. If specified hosts, download against host one by one" 
	func_param_check 1 "${desc} \n${usage} \n" "$@"

	local url="${1}"
	local tmp_dir="$(mktemp -d -t dev_download.XXXXXX)"

	# if NOT specified hosts, just download with same domain name
	if [ -z "${2}" ] ; then
		dev_download_on_host "${url}" "$(dev_url_domain_name "${url}")" "${tmp_dir}"
		return
	fi

	# if specified hosts, do it against host one by one
	shift
	for host ; do
		dev_download_on_host "${url}" "${host}" "${tmp_dir}"
	done
}

dev_download_on_host() {
	local usage="Usage: $FUNCNAME <url> <host> [dir]"
	local desc="Desc: download url with specified host. NOTE, this is for internal use, ${FUNCNAME%_on_host} is easier to use" 
	func_param_check 2 "${desc} \n${usage} \n" "$@"

	local url="${1}"
	local host="${2}"
	local tmp_dir="${3}"
	local host_filename="${host}_${url##*/}"
	local domain_name="$(dev_url_domain_name "${url}")"
	local real_url="${url/${domain_name}/${host}}"

	[ -z "${tmp_dir}" ] && tmp_dir="$(mktemp -d -t dev_download_on_host.XXXXXX)"

	\cd "${tmp_dir}"
	echo "INFO: curl -Ls -H \"Host: ${domain_name}\" \"${real_url}\" > \"${host_filename}\""
	curl -Ls -H "Host: ${domain_name}" "${real_url}" > "${host_filename}"
	echo "INFO: $(\ls -l ${host_filename})"
	\cd - > /dev/null 2>&1
}

dev_effective_url() {
	local usage="Usage: $FUNCNAME <url> [host...]"
	local desc="Desc: get effective url (in case there is redirection). If specified hosts, get against each one by one" 
	func_param_check 1 "${desc} \n${usage} \n" "$@"

	local url="${1}"

	# if NOT specified hosts, just use same domain name
	if [ -z "${2}" ] ; then
		dev_effective_url_on_host "${url}" "$(dev_url_domain_name "${url}")"
		return
	fi

	# if specified hosts, do it against host one by one
	shift
	for host ; do
		echo "INFO: getting effective url against host: ${host}, url:${url}"
		dev_effective_url_on_host "${url}" "${host}"
	done
}

dev_effective_url_on_host() {
	local usage="Usage: $FUNCNAME <url> <host>"
	local desc="Desc: get effective url (in case there is redirection), against specified host. NOTE, this is for internal use, ${FUNCNAME%_on_host} is easier to use" 
	func_param_check 2 "${desc} \n${usage} \n" "$@"

	local url="${1}"
	local host="${2}"
	local domain_name="$(dev_url_domain_name "${url}")"
	local real_url="${url/${domain_name}/${host}}"

	# do NOT output extra info for success case, since its output need to be accurate
	local effective_url
	effective_url=$(curl -Ls -o /dev/null -H "Host: ${domain_name}" -w "%{url_effective}" "${real_url}")
	[[ "$?" == "0" ]] && echo "${effective_url}" || echo "ERROR: fetch effective url failed, curl exit status: $?, url: ${url}, host: ${host}"
}

dev_http_code() { 
	local usage="Usage: $FUNCNAME <url> [host...]"
	local desc="Desc: get status code in response. If specified hosts, get against each one by one" 
	func_param_check 1 "${desc} \n${usage} \n" "$@"

	local url="${1}"

	# if NOT specified hosts, just use same domain name
	if [ -z "${2}" ] ; then
		dev_http_code_on_host "${url}" "$(dev_url_domain_name "${url}")"
		return
	fi

	# if specified hosts, do it against host one by one
	shift
	for host ; do
		echo "INFO: getting status code against host: ${host}, url:${url}"
		dev_http_code_on_host "${url}" "${host}"
	done
}

dev_http_code_on_host() { 
	local usage="Usage: $FUNCNAME <url> <host>"
	local desc="Desc: get status code in response, against specified host. NOTE, this is for internal use, ${FUNCNAME%_on_host} is easier to use" 
	func_param_check 2 "${desc} \n${usage} \n" "$@"

	local url="${1}"
	local host="${2}"
	local domain_name="$(dev_url_domain_name "${url}")"
	local real_url="${url/${domain_name}/${host}}"

	# do NOT output extra info for success case, since its output need to be accurate
	# NOT use -L to follow redirection
	curl -s -o /dev/null -H "Host: ${domain_name}" -w "%{http_code}" "${real_url}" || echo " ERROR: request failed, can NOT get status code for host:${host}, url: ${url}"
}

dev_http_body() { 
	local usage="Usage: $FUNCNAME <url> [host...]"
	local desc="Desc: get http body in response. If specified hosts, get against each one by one" 
	func_param_check 1 "${desc} \n${usage} \n" "$@"

	local url="${1}"

	# if NOT specified hosts, just use same domain name
	if [ -z "${2}" ] ; then
		dev_http_body_on_host "${url}" "$(dev_url_domain_name "${url}")"
		return
	fi

	# if specified hosts, do it against host one by one
	shift
	for host ; do
		echo "INFO: getting http body against host: ${host}, url:${url}"
		dev_http_body_on_host "${url}" "${host}"
	done
}

dev_http_body_on_host() {
	local usage="Usage: $FUNCNAME <url> <host>"
	local desc="Desc: get http body in response, against specified host. NOTE, this is for internal use, ${FUNCNAME%_on_host} is easier to use" 
	func_param_check 2 "${desc} \n${usage} \n" "$@"

	local url="${1}"
	local host="${2}"
	local domain_name="$(dev_url_domain_name "${url}")"
	local real_url="${url/${domain_name}/${host}}"

	curl -Ls -H "Host: ${domain_name}" "${real_url}"
}

################################################################################
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

#dev_download() {
#	local usage="Usage: $FUNCNAME <url> <host...>"
#	local desc="Desc: download url with specified hosts, one by one" 
#	func_param_check 2 "${desc} \n${usage} \n" "$@"
#
#	local url="${1}"
#	shift
#
#	# try to use filename in redirected url
#	local effective_url=$(dev_effective_url "${url}")
#	local filename="${effective_url##*/}"
#	local domain_name="$(echo "${url}" | awk -F '[/:]' '{print $4}')"
#
#	# prepare
#	local tmp_dir="$(mktemp -d -t dev_download.XXXXXX)"
#	local host real_url filename
#	\cd "${tmp_dir}"
#
#	echo -e "INFO: start to download. \n\twork dir\t${tmp_dir} \n\tdomain_name\t${domain_name} \n\turl\t\t${url} \n\teffective_url\t${effective_url}" 
#	for host ; do
#		# NOTE: using original url, NOT redirected url
#		real_url="${url/${domain_name}/${host}}"
#		host_filename="${host}_${filename}"
#
#		echo "INFO: curl -Ls -H \"Host: ${domain_name}\" \"${real_url}\" > \"${host_filename}\""
#		curl -Ls -H "Host: ${domain_name}" "${real_url}" > "${host_filename}"
#		echo "INFO: $(\ls -l ${host_filename})"
#	done
#	\cd - > /dev/null 2>&1
#}

dev_http_header() { 
	func_param_check 1 "Usage: $FUNCNAME <url>" "$@"
	#TODO
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



################################################################################
# Variables
url_base="http://hp2.proxy.yy.duowan.com:8080"
#hosts="113.107.239.227 122.13.201.227 113.107.239.228 122.13.201.228" 
hosts="113.107.239.227 122.13.201.228" 
urls_get_pic=(  "${url_base}/get_pic.php?uid=0&picid=0&size=full"
		"${url_base}/get_pic.php?uid=0&picid=79870938&size=full"
		"${url_base}/get_pic.php?uid=20380960&picid=1&size=full"
		"${url_base}/get_pic.php?uid=357307040&picid=1&size=full"
		"${url_base}/get_pic.php?uid=964491277&picid=1&size=full"
		"${url_base}/get_pic.php?uid=110559697&picid=1&size=full"
		"${url_base}/get_pic.php?uid=841380729&picid=1398879629&size=full" )

urls_get_pic=(  "${url_base}/get_pic.php?uid=0&picid=0&size=full"
		"${url_base}/get_pic.php?uid=841380729&picid=1398879629&size=full" )

# Verification
echo "INFO: verify response code of path /get_pic.php, expect 302"
#for host in ${hosts} ; do
#	for url in "${urls_get_pic[@]}" ; do
#		status_code="$(dev_http_code_on_host "${url}" "${host}")"
#		[[ "302" ==  "${status_code}" ]]								\
#		&& echo -e "\tSUCCESS: get code 302, host: ${host}, url: ${url##${url_base}}"	\
#		|| echo "\tFAILED: get ${status_code} for ${url##${url_base}}"
#	done
#done

echo "INFO: verify redirected url of path /get_pic.php, expect FDFS path"
#for host in ${hosts} ; do
#	for url in "${urls_get_pic[@]}" ; do
#		effective_url="$(dev_effective_url_on_host "${url}" "${host}")"
#		echo "${effective_url}" | grep -q "/group[123]/"											\
#		&& echo -e "\tSUCCESS: redirected, host: ${host}, effective_url: ${effective_url##${url_base}}, url: ${url##${url_base}}"	\
#		|| echo -e "\tFAILED: host: ${host}, effective_url: ${effective_url##${url_base}}, url: ${url##${url_base}}"	
#	done
#done

echo "INFO: verify content of crossdomain.xml"
#for host in ${hosts} ; do
#	url="${url_base}/crossdomain.xml"
#	dev_http_body_on_host "${url}" "${host}" | grep -q "allow.*\(yy\|duowan\).com"	\
#	&& echo -e "\tSUCCESS: file content as expected"				\
#	|| echo -e "\tFAILED: NOT as expected"
#done

echo "INFO: download redirected pictures"
for url in "${urls_get_pic[@]}" ; do
	tmp_dir="$(mktemp -d -t verify_hp2.XXXXXX)"
	effective_url="$(dev_effective_url_on_host "${url}" "${host}")"
	for host in ${hosts} ; do
		dev_download_on_host "${host}" "${effective_url}" "${tmp_dir}"
	done
done
