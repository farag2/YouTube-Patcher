# https://github.com/MorpheApp/morphe-desktop

$Parameters = @{
	Uri             = "https://api.github.com/repos/MorpheApp/morphe-desktop/releases/latest"
	UseBasicParsing = $true
	Verbose         = $true
}
$MorpheDesktopvTag = (Invoke-RestMethod @Parameters).tag_name
$MorpheDesktopTag = $MorpheDesktopvTag.replace("v", "")

$Parameters = @{
	Uri             = "https://github.com/MorpheApp/morphe-desktop/releases/download/$MorpheDesktopvTag/morphe-desktop-$MorpheDesktopTag-all.jar"
	Outfile         = "Morphe_Builder\morphe-desktop.jar"
	Headers         = $Headers
	UseBasicParsing = $true
	Verbose         = $true
}
Invoke-WebRequest @Parameters

echo "MorpheDesktopTag=$MorpheDesktopTag" >> $env:GITHUB_ENV
