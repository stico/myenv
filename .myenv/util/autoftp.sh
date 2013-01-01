#!/bin/bash

# auto upload a file to host
# parameters: 
# $1	the ftp server address
# $2	the ftp server port
# $3	user
# $4	password
# $5	the upload path
# $6	the ftp command

echo "--> Try to connect to ftp server $1 (port $2)"
ftp -v -n $1 $2 << !
user $3 $4
binary
cd $5
$6

