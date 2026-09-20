# https://github.com/MorpheApp/morphe-patches

$Headers = @{
	Accept                 = "application/vnd.github+json"
	Authorization          = "Bearer $env:GITHUB_TOKEN"
}
$Parameters = @{
	Uri             = "https://api.github.com/repos/MorpheApp/morphe-patches/releases/latest"
	Headers         = $Headers
	UseBasicParsing = $true
	Verbose         = $true
}
$MorphePatchesvTag = (Invoke-RestMethod @Parameters).tag_name
$MorphePatchesTag = $MorphePatchesvTag.replace("v", "")

$Parameters = @{
	Uri             = "https://github.com/MorpheApp/morphe-patches/releases/download/$MorphePatchesvtag/patches-$MorphePatchestag.mpp"
	Outfile         = "Morphe_Builder\morphe-patches.mpp"
	UseBasicParsing = $true
	Verbose         = $true
}
Invoke-WebRequest @Parameters

echo "MorphePatchesTag=$MorphePatchesTag" >> $env:GITHUB_ENV
