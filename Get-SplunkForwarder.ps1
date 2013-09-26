# Get-SplunkForwarder.ps1 
#  Andy Newell
#  Sept. 16 2013
#
# Downloads the latest Splunk Universal Forwarder to the current directory
#
# Optionally, just print the download link to the pipeline with argument "-link"
#

# TODO: "set-executionpolicy remotesigned" before proceeding,  then pop the setting back when done
#
# TODO: programatically add the Splunk URI to "trusted sites" list.   
#			Currently shows a modal dialog but does not interfere with script fucntion

param(
 [Parameter(Mandatory=$false)] [switch]$link = $false,	#  -link to enable
 [Parameter(Mandatory=$false)] [switch]$install = $false	#  -install to enable
)

$DebugPreference = "continue"

#  Get the Splunk Download page itself,  we're gonna scrape it for the link:
#
$splunk = Invoke-WebRequest https://www.splunk.com/download/universalforwarder

# Look for a link to an MSI package eding with "x64-release.msi".
# There will be two links, Full Splunk and teh Forwarder.
# The forwarder will be the second item in the zero-indexed array:
# assemble the full URI from that.
$suffix = ($splunk.links.innerHTML | Select-String x64-release.msi)[1]

# Pick out the actual version number:
$version = ($splunk.links.innerHTML | Select-String x64-release.msi)[1].tostring().Split("-")[1]

# Splunk wants to wrap the requests in a click-tracker.. Screw that.
# The prefix below is the actual download URI:
$prefix = "http://download.splunk.com/releases/$version/universalforwarder/windows/"


if ($link -eq $true) { 
	# just the Link
	Write-Output "$prefix$suffix"
} else {
	# Retrieve the file:
	$storageDir = pwd
	$webclient = New-Object System.Net.WebClient
	$url = "$prefix$suffix"
	Write-Debug "$url"
	$file = "$storageDir\$suffix"
	Write-Debug "$file"
	$webclient.DownloadFile($url,$file)
}
# ~30 Mb takes a moment to download, be patient!

# Install the file..  Silently if Elevated,  otherwise throw a prompt to eleveate, say Yes.
if ($install -eq $true) {
	if ($link -eq $true) {
		Write-Output "Error: Cannot specify -link in combination with -install; nothing to do."
	}else{
		Write-Debug "Installing Splunk Forwarder"
		Start-Process -FilePath "msiexec.exe" -ArgumentList "/i $file RECEIVING_INDEXER=`"SPLUNK-INDEX:9997`" DEPLOYMENT_SERVER=`"SPLUNK-DEPLOY.cloud.advent:8089`" WINEVENTLOG_SET_ENABLE=1 AGREETOLICENSE=Yes LAUNCHSPLUNK=0 /qb-" -Wait -Passthru
	}
}