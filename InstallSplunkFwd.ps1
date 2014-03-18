
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


#mkdir C:\Install;  set-location C:\install; explorer C:\install

#Start-Process -FilePath "msiexec.exe" -ArgumentList "/i splunkforwarder-5.0.7-192438-x64-release.msi RECEIVING_INDEXER=`"10.164.2.6:9997`" DEPLOYMENT_SERVER=`"SPLUNK-DEPLOY.cloud.advent:8089`" WINEVENTLOG_SET_ENABLE=1 AGREETOLICENSE=Yes LAUNCHSPLUNK=0 /qb-" -Wait -Passthru