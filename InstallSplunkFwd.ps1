
#
# Paste into in an elevated Powershell ISE window for reliable use
#


(get-service SplunkForwarder).status

if (!(Test-Path C:\Install)) {mkdir C:\Install | Out-Null}
set-location C:\Install
push-location
$EP = get-executionpolicy
Set-ExecutionPolicy remotesigned -Force
(invoke-webrequest https://raw.github.com/alfanovember/tools/master/Get-SplunkForwarder.ps1).content | out-file Get-SplunkForwarder.ps1
.\Get-SplunkForwarder.ps1 -install
Start-Service SplunkForwarder
Set-ExecutionPolicy $EP -Force
Get-Service SplunkForwarder