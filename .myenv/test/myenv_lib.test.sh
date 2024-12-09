#!/bin/bash
# shellcheck disable=1090,2034

# source libs
MYENV_LIB="${HOME}/.myenv/myenv_lib.sh"
TEST_LIB="${HOME}/.myenv/test/test_lib.sh"
[[ ! -e "${TEST_LIB}" ]] && echo "ERROR: can NOT find lib: ${TEST_LIB}" && exit 1
[[ ! -e "${MYENV_LIB}" ]] && echo "ERROR: can NOT find lib: ${MYENV_LIB}" && exit 1
source "${TEST_LIB}"
source "${MYENV_LIB}"

################################################################################
# Global Var
################################################################################
ERROR_CNT=0

################################################################################
# Test Materials
################################################################################
STR_EMPTY_STR=""
STR_BLANK_TAB="	"
STR_BLANK_SPACE="  "
STR_HASH_COMMENT="# coment line 3"
STR_BLANK_ALL_CHAR="$(echo -e " \t\r\n\v\f")"
EXPECT_STR_0="0"
EXPECT_STR_1="1"
FILE_NOT_EXIST="/tmp/MYENV_LIB.TEST.SH.FILE_SHOULD_NEVER_EXIST"

# 这里需要是路径的格式，因为func_path_common_base也要用
STR_EN_CHAR_1="/pa/pbb/pccc/p/ABC"
STR_EN_CHAR_2="/pa/pbb/pccc/p/ABB"

read -r -d '' STR_MULTI_STR_LINE <<-EOF
${STR_EN_CHAR_1}
${STR_BLANK_SPACE}
${STR_BLANK_TAB}
${STR_EN_CHAR_1}
${STR_EMPTY_STR}
${STR_EN_CHAR_1}_SUFFIX_[9-1]
${STR_HASH_COMMENT}
${STR_EN_CHAR_2}
${STR_HASH_COMMENT}
${STR_EN_CHAR_2}_SUFFIX_999
${STR_HASH_COMMENT} MORE TEXT in Line.
${STR_BLANK_ALL_CHAR}
EOF
FILE_STR_LIST="$(mktemp)"
echo "${STR_MULTI_STR_LINE}" > "${FILE_STR_LIST}"

read -r -d '' STR_MULTI_PATTERN_LINE <<-EOF
${STR_EN_CHAR_1}
${STR_EMPTY_STR}
${STR_HASH_COMMENT}
EOF

FILE_PATTERN_LIST="$(mktemp)"
echo "${STR_MULTI_PATTERN_LINE}" > "${FILE_PATTERN_LIST}"
echo "${STR_EN_CHAR_2}" >> "${FILE_PATTERN_LIST}"

# put "${STR_EN_CHAR_2}" at the end, so only last split file contains it
FILE_PATTERN_LIST_LONG="$(mktemp)"
for i in {1..100} ; do
	echo "${STR_MULTI_PATTERN_LINE}" >> "${FILE_PATTERN_LIST_LONG}"
done
echo "${STR_EN_CHAR_2}" >> "${FILE_PATTERN_LIST_LONG}"

rm "${FILE_NOT_EXIST}" &> /dev/null

################################################################################
# Test cases
################################################################################
clean_up() {
	rm "${FILE_STR_LIST}"
	rm "${FILE_PATTERN_LIST}"
	rm "${FILE_PATTERN_LIST_LONG}"
}

test_func_complain_path_exist() {
	func_complain_path_exist "/tmp" &> /dev/null;				test_verify_rcode_success
	func_complain_path_exist "${FILE_STR_LIST}" &> /dev/null;		test_verify_rcode_success
	func_complain_path_exist "${FILE_NOT_EXIST}" &> /dev/null;		test_verify_rcode_failure
}

test_func_complain_path_not_exist() {
	func_complain_path_not_exist "${FILE_STR_LIST}" &> /dev/null;		test_verify_rcode_failure
	func_complain_path_not_exist "${FILE_NOT_EXIST}" &> /dev/null;		test_verify_rcode_success
}

test_func_shrink_dup_lines() {
	local result

	# pipe mode
	result="$(echo "${STR_MULTI_STR_LINE}" | func_shrink_dup_lines)"
	test_verify_str_line_count "${result}" 7
	test_verify_str_single_occurrence "${result}" "${STR_EN_CHAR_1}"
	test_verify_str_single_occurrence "${result}" "${STR_HASH_COMMENT}"

	# file mode
	result="$(func_shrink_dup_lines "${FILE_STR_LIST}")"
	test_verify_str_line_count "${result}" 7
	test_verify_str_single_occurrence "${result}" "${STR_EN_CHAR_1}"
	test_verify_str_single_occurrence "${result}" "${STR_HASH_COMMENT}"
}

test_func_shrink_blank_lines() {
	local result

	# pipe mode
	result="$(echo "${STR_MULTI_STR_LINE}" | func_shrink_blank_lines)"
	test_verify_str_line_count "${result}" 10
	test_verify_str_contains "${result}" "${STR_EN_CHAR_1}"
	test_verify_str_contains "${result}" "${STR_HASH_COMMENT}"

	# file mode
	result="$(func_shrink_blank_lines "${FILE_STR_LIST}")"
	test_verify_str_line_count "${result}" 10
	test_verify_str_contains "${result}" "${STR_EN_CHAR_1}"
	test_verify_str_contains "${result}" "${STR_HASH_COMMENT}"
}

test_func_is_str_blank() {
	func_is_str_blank "${STR_EN_CHAR_1}";		test_verify_rcode_failure
	func_is_str_blank "${STR_HASH_COMMENT}";	test_verify_rcode_failure
	func_is_str_blank "${STR_VAR_NOT_DEFINED}";	test_verify_rcode_success
	func_is_str_blank "${STR_BLANK_SPACE}";		test_verify_rcode_success
	func_is_str_blank "${STR_BLANK_TAB}";		test_verify_rcode_success
	func_is_str_blank "${STR_EMPTY_STR}";		test_verify_rcode_success
	func_is_str_blank "${STR_BLANK_ALL_CHAR}";	test_verify_rcode_success
}

test_func_str_trim() {
	local STR_A
	STR_A="a b  c   d    e     f"

	test_verify_str_equals "$(func_str_trim "${STR_BLANK_TAB}${STR_A}${STR_BLANK_SPACE}")" "${STR_A}"
	test_verify_str_equals "$(func_str_trim "${STR_BLANK_ALL_CHAR}${STR_A}${STR_BLANK_ALL_CHAR}")" "${STR_A}"

	test_verify_str_equals "$(func_str_trim_left "${STR_BLANK_TAB}${STR_A}${STR_BLANK_SPACE}")" "${STR_A}${STR_BLANK_SPACE}"
	test_verify_str_equals "$(func_str_trim_left "${STR_BLANK_ALL_CHAR}${STR_A}${STR_BLANK_ALL_CHAR}")" "${STR_A}${STR_BLANK_ALL_CHAR}"

	test_verify_str_equals "$(func_str_trim_right "${STR_BLANK_TAB}${STR_A}${STR_BLANK_SPACE}")" "${STR_BLANK_TAB}${STR_A}"
	test_verify_str_equals "$(func_str_trim_right "${STR_BLANK_ALL_CHAR}${STR_A}${STR_BLANK_ALL_CHAR}")" "${STR_BLANK_ALL_CHAR}${STR_A}"
}

test_func_del_blank_lines() {
	local out_file result

	out_file="$(mktemp)"
	func_del_blank_lines "${FILE_STR_LIST}" > "${out_file}"

	test_verify_file_line_count "${out_file}" 8
	test_verify_file_contains "${out_file}" "${STR_EN_CHAR_1}"
	test_verify_file_contains "${out_file}" "${STR_HASH_COMMENT}"

	result="$(echo "${STR_MULTI_STR_LINE}" | func_del_blank_lines)"

	test_verify_str_line_count "${result}" 8
	test_verify_str_contains "${result}" "${STR_EN_CHAR_1}"
	test_verify_str_contains "${result}" "${STR_HASH_COMMENT}"
}

test_func_del_blank_and_hash_lines() {
	local out_file result

	out_file="$(mktemp)"
	func_del_blank_and_hash_lines "${FILE_STR_LIST}" > "${out_file}"

	test_verify_file_line_count "${out_file}" 5
	test_verify_file_contains "${out_file}" "${STR_EN_CHAR_1}"

	result="$(echo "${STR_MULTI_STR_LINE}" | func_del_blank_and_hash_lines)"

	test_verify_str_line_count "${result}" 5
	test_verify_str_contains "${result}" "${STR_EN_CHAR_1}"
}

test_func_is_valid_ipv4() {
	func_is_valid_ipv4 4.2.2.2;			test_verify_rcode_success
	func_is_valid_ipv4 192.168.1.1;			test_verify_rcode_success
	func_is_valid_ipv4 0.0.0.0;			test_verify_rcode_success
	func_is_valid_ipv4 255.255.255.255;		test_verify_rcode_success
	func_is_valid_ipv4 192.168.0.1;			test_verify_rcode_success
	func_is_valid_ipv4 " 169.252.12.253    ";	test_verify_rcode_success
	func_is_valid_ipv4 255.255.255.256 ;		test_verify_rcode_failure
	func_is_valid_ipv4 a.b.c.d ;			test_verify_rcode_failure
	func_is_valid_ipv4 192.168.0 ;			test_verify_rcode_failure
	func_is_valid_ipv4 1234.123.123.123 ;		test_verify_rcode_failure
}

test_func_is_valid_ipv6() {
	func_is_valid_ipv6 1:2:3:4:5:6:7:8;		test_verify_rcode_success
	func_is_valid_ipv6 1:2:3:4:5:6:7:9999;		test_verify_rcode_success
	func_is_valid_ipv6 1:2:3:4:5:6:7:;		test_verify_rcode_failure
	func_is_valid_ipv6 1:2:3:4:5:6:7:9999999;	test_verify_rcode_failure
}

test_func_is_image_ext() {
	func_is_file_ext_image "a/b/c.png";		test_verify_rcode_success
	func_is_file_ext_image "a/b/c.tif";		test_verify_rcode_success
	func_is_file_ext_image "a/b/c.gif";		test_verify_rcode_success
	func_is_file_ext_image "a/b/c.GIF";		test_verify_rcode_success
	func_is_file_ext_image "a/b/c.jpg";		test_verify_rcode_success
	func_is_file_ext_image "a/b/c.JPG";		test_verify_rcode_success
	func_is_file_ext_image "a/b/c.jpeg";		test_verify_rcode_success
	func_is_file_ext_image "a/b/c.mp4" ;		test_verify_rcode_failure
	func_is_file_ext_image "a/b/c.mkv" ;		test_verify_rcode_failure
	func_is_file_ext_image "a/b/c.PDF" ;		test_verify_rcode_failure
}

test_func_grepf_short_list_with_pipe() {
	local result_str

	# basic
	result_str="$( echo "${STR_MULTI_STR_LINE}" | func_grepf "${FILE_PATTERN_LIST}" )"
	test_verify_str_contains "${result_str}" "${STR_EN_CHAR_1}"
	test_verify_str_line_count "${result_str}" 5

	# with parameter
	result_str="$( echo "${STR_MULTI_STR_LINE}" | func_grepf -v "${FILE_PATTERN_LIST}" )"
	test_verify_str_not_contains "${result_str}" "${STR_EN_CHAR_1}"
	test_verify_str_line_count "${result_str}" 8
}

test_func_grepf_short_list_with_file() {
	local result_str

	# basic
	result_str="$( func_grepf "${FILE_PATTERN_LIST}" "${FILE_STR_LIST}" )"
	test_verify_str_contains "${result_str}" "${STR_EN_CHAR_1}"
	test_verify_str_line_count "${result_str}" 5

	# with parameter
	result_str="$( func_grepf -v "${FILE_PATTERN_LIST}" "${FILE_STR_LIST}" )"
	test_verify_str_not_contains "${result_str}" "${STR_EN_CHAR_1}"
	test_verify_str_line_count "${result_str}" 8
}

test_func_grepf_long_list_with_pipe() {
	local result_str

	# set this var to force pattern file split
	FUNC_GREPF_MAX_PATTERN_LINE=30

	result_str="$( echo "${STR_MULTI_STR_LINE}" | func_grepf "${FILE_PATTERN_LIST_LONG}" )"
	test_verify_str_contains "${result_str}" "${STR_EN_CHAR_1}"
	test_verify_str_line_count "${result_str}" 5

	result_str="$( echo "${STR_MULTI_STR_LINE}" | func_grepf -v "${FILE_PATTERN_LIST_LONG}" )"
	test_verify_str_not_contains "${result_str}" "${STR_EN_CHAR_1}"
	test_verify_str_line_count "${result_str}" 8
}

test_func_str_common_prefix() {
	local result_str
	result_str="$( echo "${STR_MULTI_STR_LINE}" | func_del_blank_and_hash_lines | func_str_common_prefix )"

	# "${STR_EN_CHAR_1::-1}" means: remove last char
	test_verify_str_contains "${result_str}" "${STR_EN_CHAR_1::-1}"
}

test_func_path_common_base() {
	local result_str

	# pipe mode
	result_str="$( echo "${STR_MULTI_STR_LINE}" | func_path_common_base )"
	test_verify_str_contains "${result_str}" "${STR_EN_CHAR_1%/*}/"

	# file mode
	result_str="$( func_path_common_base "${FILE_STR_LIST}" )"
	test_verify_str_contains "${result_str}" "${STR_EN_CHAR_1%/*}/"
}

test_run_all
clean_up

################################################################################
# Deprecated
################################################################################
#
#test_func_file_remove_blank_lines() {
#	local out_file="$(mktemp)"
#	func_file_remove_blank_lines "${FILE_STR_LIST}" > "${out_file}"
#
#	test_verify_file_line_count "${out_file}" 2
#	test_verify_file_contains "${out_file}" "${STR_EN_CHAR_1}"
#	test_verify_file_contains "${out_file}" "${STR_HASH_COMMENT}"
#}
#
#test_func_file_remove_blank_and_hash_lines() {
#	local out_file="$(mktemp)"
#	func_file_remove_blank_and_hash_lines "${FILE_STR_LIST}" > "${out_file}"
#
#	test_verify_file_line_count "${out_file}" 1
#	test_verify_file_contains "${out_file}" "${STR_EN_CHAR_1}"
#}
#
#test_func_pipe_remove_blank_lines() {
#	local result
#	result="$(echo "${STR_MULTI_STR_LINE}" | func_pipe_remove_blank_lines)"
#
#	test_verify_str_line_count "${result}" 2
#	test_verify_str_contains "${result}" "${STR_EN_CHAR_1}"
#	test_verify_str_contains "${result}" "${STR_HASH_COMMENT}"
#}
#
#test_func_pipe_remove_blank_and_hash_lines() {
#	local result
#	result="$(echo "${STR_MULTI_STR_LINE}" | func_pipe_remove_blank_and_hash_lines)"
#
#	test_verify_str_line_count "${result}" 1
#	test_verify_str_contains "${result}" "${STR_EN_CHAR_1}"
#}
