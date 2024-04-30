#!/bin/bash
# shellcheck disable=1091

# This file is loaded by login shell (check $SHELL var)
# Skip loading .bashrc for non-interactive mode 
[ -n "$PS1" ] \
&& [ -f "${HOME}/.bashrc" ] \
&& [ "$(ps -cp "$$" -o command="")" = "bash" ] \
&& source "${HOME}/.bashrc"
