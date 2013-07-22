# Download: https://raw.github.com/stico/myenv/master/.myenv/init/myenv.rw.ps1
# Run: C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe -ExecutionPolicy RemoteSigned -F E:/amp/myenv.rw.ps1

# Var
$me_dir = "E:"
$tmp_dir = "E:\amp\myenv_init"
$bak_dir = "E:\Documents\DCB\DatedBackup"
$git_cmd = "E:\program\A_System_Cygwin\bin\git.exe"
$zip_cmd = "E:\program\A_System_7-Zip_9.20_PA-Basic\App\7-Zip\7z.exe"
$git_addr = "https://github.com/stico/myenv.git"
$git_addr2 = "stico_github:stico/myenv.git"

# Pre-Check
if (!(Test-Path $git_cmd))    {throw "ERROR: $git_cmd does not exist, pls check!";}
if (!(Test-Path $zip_cmd))    {throw "ERROR: $zip_cmd does not exist, pls check!";}
if (!(Test-Path $bak_dir))    {throw "ERROR: $bak_dir does not exist, pls check!";}
if (Test-Path $me_dir\.git)   {throw "ERROR: $me_dir\.git already exist, pls check!";}

# Prepare
if (Test-Path $tmp_dir) {Remove-Item -path $tmp_dir -Recurse}
New-Item -type directory $tmp_dir 

# Git clone
cd $tmp_dir
& $git_cmd "clone" $git_addr

# Git update remote
cd $tmp_dir/myenv
& $git_cmd "remote" "rm" "origin"
& $git_cmd "remote" "add" "origin" $git_addr2
& $git_cmd "remote" "add" "github" $git_addr2

# Extract Secure dirs
cd $tmp_dir
$myenv_bak = @(Get-ChildItem -Path $bak_dir -Filter "*workpc*myenv*full*.zip")[-1]
Copy-Item $myenv_bak.FullName .
& $zip_cmd x $myenv_bak.FullName.split("\")[-1] > zip.log
$ssh_dir=@(Get-ChildItem -Path $path -Include ".ssh" -Recurse | Where-Object { $_.PSIsContainer })[-1]
$secu_dir=@(Get-ChildItem -Path $path -Include "secu" -Recurse | Where-Object { $_.PSIsContainer })[-1]
Copy-Item $ssh_dir.FullName $tmp_dir\myenv -Recurse
Copy-Item $secu_dir.FullName $tmp_dir\myenv\.myenv -Recurse

# Finally, copy to home dir
Copy-Item $tmp_dir\myenv\* $me_dir\ -Recurse
if (Test-Path $me_dir\.git) {Write-Output "Myenv init success!"} else {Write-Output "ERROR: Myenv init failed, pls check!"}
