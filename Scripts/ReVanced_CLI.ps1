# https://github.com/revanced/revanced-cli

$Parameters = @{
	Uri             = "https://api.github.com/repos/revanced/revanced-cli/releases/latest"
	UseBasicParsing = $true
	Verbose         = $true
}
$CLIReVancedvTag = (Invoke-RestMethod @Parameters).tag_name
$CLIReVancedTag = $CLIReVancedvTag.replace("v", "")

$Parameters = @{
	Uri             = "https://github.com/revanced/revanced-cli/releases/download/$CLIReVancedvTag/revanced-cli-$CLIReVancedTag-all.jar"
	Outfile         = "ReVanced_Builder\revanced-cli.jar"
	Headers         = $Headers
	UseBasicParsing = $true
	Verbose         = $true
}
Invoke-WebRequest @Parameters

echo "CLIReVancedTag=$CLIReVancedTag" >> $env:GITHUB_ENV
