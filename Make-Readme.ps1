#
# _   _  ____ _______ 
#| \ | |/ __ \__   __|
#|  \| | |  | | | |   
#| . ` | |  | | | |   
#| |\  | |__| | | |   
#|_| \_|\____/  |_|   
#                     
#                     
# _____ _____  ______ __  __ _____   ____ _______ ______ _   _ _______ 
#|_   _|  __ \|  ____|  \/  |  __ \ / __ \__   __|  ____| \ | |__   __|
#  | | | |  | | |__  | \  / | |__) | |  | | | |  | |__  |  \| |  | |   
#  | | | |  | |  __| | |\/| |  ___/| |  | | | |  |  __| | . ` |  | |   
# _| |_| |__| | |____| |  | | |    | |__| | | |  | |____| |\  |  | |   
#|_____|_____/|______|_|  |_|_|     \____/  |_|  |______|_| \_|  |_|   
#
#
# This will create new README.txt files in the splunk deployment-apps directory
#
# Old versions will be renamed with a datestamp
#
# Remove the -whatif statements if you really want to do this.


Set-location "C:\Scripts\Splunk\git\deployment-apps"


$dir = gci "C:\Scripts\Splunk\git\deployment-apps\"


foreach ($app in $dir) { 

if (test-path $app\README.txt) {$date=(Get-Date -f u).Split()[0]; Move-Item $app\README.txt -Destination $app\README.$date -WhatIf }


if (Test-Path $app\local\inputs.conf) {
	Get-Content $app\local\inputs.conf | Select-String -Pattern '\[monitor','\[script' | Out-File -FilePath $app\README.txt -Encoding ascii -WhatIf
	}
}

foreach ($app in $dir) { 
	if (Test-Path $app\local\wmi.conf) {
		Get-Content $app\local\wmi.conf | Select-String -Pattern '\[wmi' | Out-File -FilePath $app\README.txt -Append -Encoding ascii -whatif
	}
}