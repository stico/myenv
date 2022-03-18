#!/bin/bash

# source libs
MYENV_LIB="${HOME}/.myenv/myenv_lib.sh"
TEST_LIB="${HOME}/.myenv/test/test_lib.sh"
[[ ! -e"${TEST_LIB}" ]] && echo "ERROR: can NOT find lib: ${TEST_LIB}" && exit 1
[[ ! -e"${MYENV_LIB}" ]] && echo "ERROR: can NOT find lib: ${MYENV_LIB}" && exit 1
source "${TEST_LIB}"
source "${MYENV_LIB}"

################################################################################
# Global Var
################################################################################
ERROR_CNT=0

################################################################################
# Test Materials
################################################################################
STR_1_EN_CHAR="test string 1, AAAA."
STR_2_COMMENT="# coment line 3"
STR_3_BLANK_SP="  "
STR_4_BLANK_TAB="	"
STR_5_BLANK_NONE=""
STR_6_BLANK_ALL="$(echo -e " \t\r\n\v\f")"
EXPECT_STR_0="0"
EXPECT_STR_1="1"
FILE_1="$(mktemp)"
FILE_2_NOT_EXIST="/tmp/MYENV_LIB.TEST.SH.FILE_SHOULD_NEVER_EXIST"

read -r -d '' STR_0_MULTI_LINE <<-EOF
${STR_1_EN_CHAR}
${STR_3_BLANK_SP}
${STR_4_BLANK_TAB}
${STR_1_EN_CHAR}
${STR_5_BLANK_NONE}
${STR_1_EN_CHAR}_SUFFIX_[9-1]
${STR_2_COMMENT}
${STR_2_COMMENT}
${STR_2_COMMENT} MORE TEXT in Line.
${STR_6_BLANK_ALL}
EOF
echo "${STR_0_MULTI_LINE}" > "${FILE_1}"
rm "${FILE_2_NOT_EXIST}" &> /dev/null

################################################################################
# Test cases
################################################################################
test_run_all() {
	while read func; do
		test_echo_start "${func}"
		eval "${func}"
		test_echo_end
	done < <(grep "^test_" "$(func_script_self)"			\
		| func_del_pattern_lines "test_run_all" "test_echo_"	\
		| sed -e 's/().*$//')
	
	test_echo_summary
}

test_func_complain_path_exist() {
	func_complain_path_exist "${FILE_1}" &> /dev/null
	test_verify_str_equals "$?" "${EXPECT_STR_0}"

	func_complain_path_exist "${FILE_2_NOT_EXIST}" &> /dev/null
	test_verify_str_equals "$?" "${EXPECT_STR_1}"
}

test_func_complain_path_not_exist() {
	func_complain_path_not_exist "${FILE_1}" &> /dev/null
	test_verify_str_equals "$?" "${EXPECT_STR_1}"

	func_complain_path_not_exist "${FILE_2_NOT_EXIST}" &> /dev/null
	test_verify_str_equals "$?" "${EXPECT_STR_0}"
}

test_func_shrink_pattern_lines() {
	local result

	# only support file mode
	result="$(func_shrink_pattern_lines "${FILE_1}")"
	test_verify_str_line_count "${result}" 3
	test_verify_str_single_occurrence "${result}" "${STR_1_EN_CHAR}"
	test_verify_str_single_occurrence "${result}" "${STR_2_COMMENT}"
}

test_func_shrink_dup_lines() {
	local result

	# pipe mode
	result="$(echo "${STR_0_MULTI_LINE}" | func_shrink_dup_lines)"
	test_verify_str_line_count "${result}" 5
	test_verify_str_single_occurrence "${result}" "${STR_1_EN_CHAR}"
	test_verify_str_single_occurrence "${result}" "${STR_2_COMMENT}"

	# file mode
	result="$(func_shrink_dup_lines "${FILE_1}")"
	test_verify_str_line_count "${result}" 5
	test_verify_str_single_occurrence "${result}" "${STR_1_EN_CHAR}"
	test_verify_str_single_occurrence "${result}" "${STR_2_COMMENT}"
}

test_func_shrink_blank_lines() {
	local result

	# pipe mode
	result="$(echo "${STR_0_MULTI_LINE}" | func_shrink_blank_lines)"
	test_verify_str_line_count "${result}" 8
	test_verify_str_contains "${result}" "${STR_1_EN_CHAR}"
	test_verify_str_contains "${result}" "${STR_2_COMMENT}"

	# file mode
	result="$(func_shrink_blank_lines "${FILE_1}")"
	test_verify_str_line_count "${result}" 8
	test_verify_str_contains "${result}" "${STR_1_EN_CHAR}"
	test_verify_str_contains "${result}" "${STR_2_COMMENT}"
}

test_func_is_str_blank() {
	func_is_str_blank "${STR_VAR_NOT_DEFINED}"
	test_verify_str_equals "$?" "${EXPECT_STR_0}"

	func_is_str_blank "${STR_3_BLANK_SP}"
	test_verify_str_equals "$?" "${EXPECT_STR_0}"

	func_is_str_blank "${STR_4_BLANK_TAB}"
	test_verify_str_equals "$?" "${EXPECT_STR_0}"

	func_is_str_blank "${STR_5_BLANK_NONE}"
	test_verify_str_equals "$?" "${EXPECT_STR_0}"

	func_is_str_blank "${STR_6_BLANK_ALL}"
	test_verify_str_equals "$?" "${EXPECT_STR_0}"

}

test_func_del_blank_lines() {
	local out_file="$(mktemp)"
	func_del_blank_lines "${FILE_1}" > "${out_file}"

	test_verify_file_line_count "${out_file}" 6
	test_verify_file_contains "${out_file}" "${STR_1_EN_CHAR}"
	test_verify_file_contains "${out_file}" "${STR_2_COMMENT}"

	local result
	result="$(echo "${STR_0_MULTI_LINE}" | func_del_blank_lines)"

	test_verify_str_line_count "${result}" 6
	test_verify_str_contains "${result}" "${STR_1_EN_CHAR}"
	test_verify_str_contains "${result}" "${STR_2_COMMENT}"
}

test_func_del_blank_and_hash_lines() {
	local out_file="$(mktemp)"
	func_del_blank_and_hash_lines "${FILE_1}" > "${out_file}"

	test_verify_file_line_count "${out_file}" 3
	test_verify_file_contains "${out_file}" "${STR_1_EN_CHAR}"

	local result
	result="$(echo "${STR_0_MULTI_LINE}" | func_del_blank_and_hash_lines)"

	test_verify_str_line_count "${result}" 3
	test_verify_str_contains "${result}" "${STR_1_EN_CHAR}"
}

################################################################################
# Deprecated
################################################################################
#
#test_func_file_remove_blank_lines() {
#	local out_file="$(mktemp)"
#	func_file_remove_blank_lines "${FILE_1}" > "${out_file}"
#
#	test_verify_file_line_count "${out_file}" 2
#	test_verify_file_contains "${out_file}" "${STR_1_EN_CHAR}"
#	test_verify_file_contains "${out_file}" "${STR_2_COMMENT}"
#}
#
#test_func_file_remove_blank_and_hash_lines() {
#	local out_file="$(mktemp)"
#	func_file_remove_blank_and_hash_lines "${FILE_1}" > "${out_file}"
#
#	test_verify_file_line_count "${out_file}" 1
#	test_verify_file_contains "${out_file}" "${STR_1_EN_CHAR}"
#}
#
#test_func_pipe_remove_blank_lines() {
#	local result
#	result="$(echo "${STR_0_MULTI_LINE}" | func_pipe_remove_blank_lines)"
#
#	test_verify_str_line_count "${result}" 2
#	test_verify_str_contains "${result}" "${STR_1_EN_CHAR}"
#	test_verify_str_contains "${result}" "${STR_2_COMMENT}"
#}
#
#test_func_pipe_remove_blank_and_hash_lines() {
#	local result
#	result="$(echo "${STR_0_MULTI_LINE}" | func_pipe_remove_blank_and_hash_lines)"
#
#	test_verify_str_line_count "${result}" 1
#	test_verify_str_contains "${result}" "${STR_1_EN_CHAR}"
#}

test_run_all
