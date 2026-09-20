# https://github.com/MorpheApp/MicroG-RE

$Headers = @{
	Accept                 = "application/vnd.github+json"
	Authorization          = "Bearer $env:GITHUB_TOKEN"
}
$Parameters = @{
	Uri             = "https://api.github.com/repos/MorpheApp/MicroG-RE/releases/latest"
	Headers         = $Headers
	UseBasicParsing = $true
	Verbose         = $true
}
$Releases = Invoke-RestMethod @Parameters
$URL = ($Releases.assets | Where-Object -FilterScript {$_.browser_download_url -match "microg-$($Releases.tag_name)-arm64-v8a.apk"}).browser_download_url

$Parameters = @{
	Uri             = $URL
	Outfile         = "Morphe_Builder\microg_morphe.apk"
	UseBasicParsing = $true
	Verbose         = $true
}
Invoke-WebRequest @Parameters

$MicroG_Morphe = $Releases.tag_name
echo "MicroG_Morphe=$MicroG_Morphe" >> $env:GITHUB_ENV
