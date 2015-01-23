#!/bin/bash
# tputcolors

echo
echo -e "$(tput bold) reg  bld  und   tput-command-colors$(tput sgr0)"

for i in $(seq 1 7); do
  echo "
$(tput setaf $i)Text$(tput sgr0) \
$(tput bold)$(tput setaf $i)Text$(tput sgr0) \
$(tput sgr 0 1)$(tput setaf $i)Text$(tput sgr0)  \$(tput setaf $i)"
done

echo ' Bold            $(tput bold)'
echo ' Underline       $(tput sgr 0 1)'
echo ' Reset           $(tput sgr0)'
echo

echo "message to stderr" 1>&2 2> >(while read line; do echo -e "\e[01;31m$line\e[0m" >&2; done)
