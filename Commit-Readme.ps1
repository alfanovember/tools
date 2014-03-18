Set-location "C:\Scripts\Splunk\git\deployment-apps"


$dir = gci "C:\Scripts\Splunk\git\deployment-apps\"


Push-Location

foreach ($app in $dir) { 
	
	Push-Location
	
	Set-Location $app
	
	if (test-path README.txt) {

		## The git mechanics need cleaning up..  works, mostly

		& git add README.txt
		& git commit -m "Add auto-generated README files"
		& git push

	}
	Pop-Location

}