#!/bin/bash

# DESC: init myenv. See conf/myenv/init_all.sh for setup everything 
# one line cmd: curl -sk 'https://raw.githubusercontent.com/stico/myenv/master/.myenv/init/myenv.sh' | bash

TMP_DIR=/tmp/__init_myenv__
TMP_PATH="${TMP_DIR}/myenv"
REPO_ADDR=git://github.com/stico/myenv.git
#REPO_ADDR=git@github.com:stico/myenv.git	# need privilege
#REPO_ADDR=https://github.com/stico/myenv.git	# not work when libcurl not support https

func_die() {
	echo -e "$@" 1>&2
	exit 1
}

# shellcheck disable=1001
func_via_git() {
	mkdir -p "${TMP_DIR}"
	\cd "${TMP_DIR}" || func_die "ERROR: failed to mkdir/cd tmp dir: ${TMP_DIR}"

	echo "INFO: init myenv from github via git"
	[ -e "${TMP_PATH}/.git" ] && \cd "${TMP_PATH}" && \git pull || \git clone "${REPO_ADDR}"
	[ -e "${TMP_PATH}/.git" ] || func_die "ERROR: ${TMP_PATH}/.git NOT exist, git clone failed"

	mv ${TMP_PATH}/* "${HOME}"
	mv ${TMP_PATH}/.[!.]* "${HOME}"
	\cd "${HOME}"
	\git config --global user.email "stico@163.com"
	\git config --global user.name "stico"
	\git config --global push.default simple
	\cd -
	echo "INFO: myenv init success (via git)!"
}

# Check
command -v "git" &> /dev/null || func_die "ERROR: git command NOT exist, pls check"
[ -e "${HOME}/.git" ] && echo "INFO: ${HOME}/.git already exist, skip init myenv" && exit 0

func_via_git
