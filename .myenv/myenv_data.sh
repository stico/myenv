#!/bin/bash

source $HOME/.myenv/myenv_lib.sh || eval "$(wget -q -O - "https://raw.github.com/stico/myenv/master/.myenv/myenv_lib.sh")" || exit 1

# Def
#	ts	tab separate, default separator for data fields
#	kv	key-value

data_complain_kv_file_format() {
	# number of columns (1st line as standard)
	local cols=$(head -n1 "${1}" | awk -F $'\t' '{print NF}')

	awk -F $'\t' -v expect="$cols" '
		NF != expect { exit 1 }
		/^$/ { exit 1 }
	' "${1}"

	[ "$?" -ne "0" ] && echo "ERROR: format error: no TAB found, or col count inconsistant: $(basename "${1}")" >&2 && return 1
}

data_complain_kv_file_confliction() {
	awk -F $'\t' '
		!seen[$0]++ {					# 过滤掉完全重复的行 (注意这里是"整行比较")
			if ($1 in kv && kv[$1] != $2) {		# 如果这个 Key 之前已经存过不同的 Value，说明不一致
				print "ERROR: Key [" $1 "] has diff value: [" kv[$1] "] V.S. [" $2 "]"
				has_error = 1
			}
			# 记录当前 Key 对应的 Value
			kv[$1] = $2		
			counter++
		}
		END { if (has_error) exit 1 }
	' "${1}"

	[ "$?" -ne "0" ] && echo "ERROR: K:V conflict: $(basename "${1}")" >&2 && return 1
}

data_check_kv_file() {
	local usage="Usage: $FUNCNAME <tsv_file> <keys_to_lookup>"
	local desc="Desc: file format: <key>\t<value>, for tsv file, 2nd field and after are ALL 'value'" 
	func_param_check 1 "${desc} \n${usage} \n" "$@"

	local fail="false"
	func_complain_path_not_exist "${1}"		&& fail="true" 
	data_complain_kv_file_format "${1}"		&& fail="true"
	data_complain_kv_file_confliction "${1}"	&& fail="true" 

	[[ "${fail}" == "true" ]] && echo "ERROR: kv file check failed!" && return 1
}

data_kv_lookup() {
	local usage="Usage: $FUNCNAME <kv_table> <keys_to_lookup>"
	local desc="Desc: lookup value for <keys_to_lookup> file (or keys from stdin), using <kv_table>." 
	func_param_check 1 "${desc} \n${usage} \n" "$@"

	local k v kv_table
	kv_table="$(mktemp)"

	# check and gen kv_table
	data_check_kv_file "${kv_table}" || return 1
	func_shrink_dup_lines "${1}" > "${kv_table}"
	echo "INFO: using generated kv_table file: ${kv_table}" >&2
	shift

	# lookup
	while IFS= read -r k || [[ -n "${k}" ]] ; do

		# 注意: 
		# 1) key的前后都要约束，否则可能误匹配
		# 2) 不能直接用grep，会导致输入与输出行数对不上 (key不存在时grep不输出)
		v="$(grep "^${k}	" "${kv_table}" | cut -d'	' -f2)"
		echo -e "${k}\t${v}"

	# PIPE_CONTENT_GOES_HERE
	done < <(func_del_blank_hash_lines "$@")
}
