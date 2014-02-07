# Get-SplunkForwarder.ps1 
#  Andy Newell
#  Sept. 16 2013
#
# Downloads the Splunk Universal Forwarder to the current directory
#
# Optionally, just print the download link to the pipeline with argument "-link"
#

# Edit 10.4.2013 
#  Splunk 6 has been released;  we want to stay on V5 for now.  
#

# TODO: DONE (elsewhere) "set-executionpolicy remotesigned" before proceeding,  then pop the setting back when done
#
# TODO: programatically add the Splunk URI to "trusted sites" list.   
#			Currently shows a modal dialog but does not interfere with script fucntion
#		DONE Also add test condition before firing the change
#		DONE Redirect output to /dev/nul

 #Requires -Version 3

param(
 [Parameter(Mandatory=$false)] [switch]$link = $false,	#  -link to enable
 [Parameter(Mandatory=$false)] [switch]$install = $false	#  -install to enable
)

$DebugPreference = "continue"

# Add Splunk.com to trusted sites zone

$working_dir = pwd
push-location

$reg_path = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings"

If (-not(Test-Path -Path "$reg_path\ZoneMap\EscDomains\splunk.com")) {

	set-location $reg_path

	push-location ZoneMap\ESCDomains  # down two

	new-item splunk.com | out-null
		push-location splunk.com # down one
		new-itemproperty . -Name "*" -Value 2 -Type DWORD | out-null
	pop-location # up one

	new-item security_powershell_ise.exe | out-null
		push-location security_powershell_ise.exe # down one
		new-itemproperty . -Name about -Value 2 -Type DWORD | out-null
	pop-location # up one

	#new-item //cdn.optimizely.com/js/7177505.js | out-null
	#	push-location //cdn.optimizely.com/js/7177505.js # down one
	#	new-itemproperty . -Name about -Value 2 -Type DWORD | out-null
	#pop-location # up one

	new-item googleadservices.com | out-null
		push-location googleadservices.com # down one
		new-itemproperty . -Name "*" -Value 2 -Type DWORD | out-null
	pop-location # up one

	new-item google-analytics.com | out-null
		push-location google-analytics.com #d own one
		new-itemproperty . -Name "*" -Value 2 -Type DWORD | out-null
	pop-location #up one

	# Out of the Registry, and back to where we started:
	set-location $working_dir
}


#  Get the Splunk Download page itself,  we're gonna scrape it for the link:
#
#$splunk = Invoke-WebRequest https://www.splunk.com/download/universalforwarder -DisableKeepAlive -MaximumRedirection 0

$splunk = Invoke-WebRequest https://www.splunk.com/page/previous_releases -DisableKeepAlive -MaximumRedirection 0

# Look for a link to an MSI package eding with "x64-release.msi".
# There will be two links, Full Splunk and teh Forwarder.
# The forwarder will be the second item in the zero-indexed array:
# assemble the full URI from that.
#$suffix = ($splunk.links.innerHTML | Select-String x64-release.msi)[1]

$suffix =  $splunk.Links.innerHTML | Select-String -Pattern "^splunkforwarder-5.0.\d-\d+-x64-release.msi" | Sort-Object -Descending | Select-Object -First 1


# Pick out the actual version number:
#$version = ($splunk.links.innerHTML | Select-String x64-release.msi)[1].tostring().Split("-")[1]

$version = $suffix.ToString().Split("-")[1]


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
		Start-Process -FilePath "msiexec.exe" -ArgumentList "/i $file RECEIVING_INDEXER=`"10.164.2.6:9997`" DEPLOYMENT_SERVER=`"SPLUNK-DEPLOY.cloud.advent:8089`" WINEVENTLOG_SET_ENABLE=1 AGREETOLICENSE=Yes LAUNCHSPLUNK=0 /qb-" -Wait -Passthru
	}
}
