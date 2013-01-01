[ ! -n "$1" ] && echo '-!> Error: Must set the 1st parameter, which indicating the working dir' && exit
[ ! -n "$2" ] && echo '-!> Error: Must set the 2st parameter, which indicating the backup dir' && exit

tmpDir="C:/zmpC"
bakSource=${1//\\/\/}
bakDir=${2//\\/\/}
bakFile=${bakSource##*/}_Backup_`date "+%Y-%m-%d_%H-%M-%S"`.tar 

echo "--> Enter tmp dir $tmpDir for packaging"
cd $tmpDir

echo "--> Creating backup package with source: $bakSource , bakFile: $bakFile"
tar cvf $bakFile $bakSource

echo "--> Moving backup package to: $bakDir"
# use "" embrace the $bakDir, or the shell will have problem to deal with the blank space in the path
mv $bakFile "$bakDir"
