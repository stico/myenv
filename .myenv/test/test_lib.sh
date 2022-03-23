#!/bin/bash

# source libs
MYENV_LIB="${HOME}"/.myenv/myenv_lib.sh
[[ ! -e"${MYENV_LIB}" ]] && echo "ERROR: can NOT find lib: ${MYENV_LIB}" && exit 1
source "${MYENV_LIB}"

test_echo_error() {
	local usage="Usage: ${FUNCNAME[0]} <msg> <expect> <result>" 
	local desc="Desc: echo msg as DEBUG level, based on env var ME_DEBUG=true to really show"
	func_param_check 1 "$@"
	
	echo -e "------> X: FAILED: ${1}"
	(( ERROR_CNT+=1 ))
}

test_echo_start() {
	echo -e "START:\tC: ${1}"
}

test_echo_end() {
	return
	# TODO
	echo -e "\tI: time cost: ${1}"
}

test_echo_summary() {
	if (( ERROR_CNT == 0 )); then
		echo -e "SUMMARY:\n\tALL PASS!"
	else
		echo -e "SUMMARY:\n\t${ERROR_CNT} errors, pls check!"
	fi
}

test_verify_rcode_success() {
	local rcode="$?"
	[[ "${rcode}" == "0" ]] || test_echo_error "return code error: '${rcode}' != '0' (expect)" 
}

test_verify_rcode_failure() {
	local rcode="$?"
	[[ "${rcode}" == "0" ]] && test_echo_error "return code error: '${rcode}' (expect: > 0)"
}

test_verify_str_equals() {  
	[[ "${1}" == "${2}" ]] || test_echo_error "str NOT equal: '${1}' != '${2}' (expect)"
}

test_verify_str_contains() { 
	local expect="${2}"
	if ! echo "${1}" | grep -qF "${expect}" ; then
		test_echo_error "NO str: '${expect}' (expect) found in: ${1}"
	fi
}

test_verify_str_single_occurrence() {
	local occurrence
	occurrence="$(echo "${2}" | grep -c -F "${1}")"
	[[ "${occurrence}" == "1" ]] || test_echo_error "NOT single occurrence: '${occurrence}' != 1 (expect)"
}

test_verify_file_contains() {
	local file="${1}"
	local expect="${2}"

	grep -q "${expect}" "${file}" || test_echo_error "file NOT contain str: '${expect}', file: ${file}"
}

test_verify_str_line_count() {
	local expect="${2}"
	local count="$(echo "${1}" | wc -l)"

	(( count == expect )) || test_echo_error "str line count NOT match, gets: ${count} != ${expect} (expect)"
}

test_verify_file_line_count() {
	local expect="${2}"
	local count="$(func_file_line_count "${1}")"

	(( count == expect )) || test_echo_error "file line count NOT match, gets: ${count} != ${expect} (expect)"
}
