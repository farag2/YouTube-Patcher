#Requires -Version 7.4

# Get the latest supported YouTube version to patch
# https://github.com/MorpheApp/morphe-patches/blob/main/patches-list.json
$Parameters = @{
	Uri             = "https://raw.githubusercontent.com/MorpheApp/morphe-patches/refs/heads/main/patches-list.json"
	UseBasicParsing = $true
	Verbose         = $true
}
$Patches = Invoke-RestMethod @Parameters
$MorpheYTdot = ($Patches.patches | Where-Object -FilterScript {$_.name -eq "Video ads"}).compatiblePackages."com.google.android.youtube" | Sort-Object -Descending -Unique | Select-Object -First 1
$MorpheYT = $MorpheYTdot.Replace(".", "-")

Get-Process -Name msedgedriver, msedge -ErrorAction Ignore | Stop-Process -Force -ErrorAction Ignore

Write-Verbose -Message "Microsoft Edge driver" -Verbose

# Get runner Microsoft Edge Version
# https://edgeupdates.microsoft.com/api/products
# https://github.com/GoogleChromeLabs/chrome-for-testing/blob/main/data/last-known-good-versions-with-downloads.json
$RunnerEdgeVersion = (Get-Item -Path "${env:ProgramFiles(x86)}\Microsoft\Edge\Application\msedge.exe").VersionInfo.FileVersion

# Download Microsoft Edge driver
# https://developer.microsoft.com/microsoft-edge/tools/webdriver/
$Parameters = @{
	Uri             = "https://msedgedriver.microsoft.com/$RunnerEdgeVersion/edgedriver_win64.zip"
	OutFile         = "Morphe_Builder\edgedriver_win64.zip"
	UseBasicParsing = $true
	Verbose         = $true
}
Invoke-Webrequest @Parameters

Write-Verbose -Message "Selenium web driver" -Verbose

# Download Selenium web driver
# https://www.nuget.org/packages/selenium.webdriver
# https://www.nuget.org/packages/selenium.support
try
{
	$Parameters = @{
		Uri             = "https://www.nuget.org/api/v2/package/Selenium.WebDriver"
		OutFile         = "Morphe_Builder\selenium.webdriver.nupkg"
		UseBasicParsing = $true
		Verbose         = $true
		ErrorAction     = "Stop"
	}
	Invoke-WebRequest @Parameters
}
catch
{
	Write-Verbose -Message "Cannot download Selenium web driver" -Verbose

	# Exit with a non-zero status to fail the job
	exit 1
}

$Parameters = @{
	Path            = "Morphe_Builder\edgedriver_win64.zip"
	DestinationPath = "Morphe_Builder"
	Force           = $true
	Verbose         = $true
}
Expand-Archive @Parameters

# Extract WebDriver.dll from archive
Add-Type -Assembly System.IO.Compression.FileSystem
$ZIP = [IO.Compression.ZipFile]::OpenRead("Morphe_Builder\selenium.webdriver.nupkg")
$Entries = $ZIP.Entries | Where-Object -FilterScript {$_.FullName -eq "lib/net8.0/WebDriver.dll"}
$Entries | ForEach-Object -Process {[IO.Compression.ZipFileExtensions]::ExtractToFile($_, "Morphe_Builder\$($_.Name)", $true)}
$ZIP.Dispose()

$Paths = @(
	"Morphe_Builder\Driver_Notes",
	"Morphe_Builder\edgedriver_win64.zip",
	"Morphe_Builder\selenium.webdriver.nupkg"
)
Remove-Item -Path $Paths -Force -Recurse

Write-Verbose -Message "Adding web driver" -Verbose

# Start parsing page
Add-Type -Path "Morphe_Builder\WebDriver.dll"

$Options = New-Object -TypeName OpenQA.Selenium.Edge.EdgeOptions
$Options.AddArgument("--headless=new")
$Options.AddArgument("--window-size=1280,720")
$Options.AcceptInsecureCertificates = $true
$Options.AddArgument("--user-agent=Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36 Edg/124.0.0.0")
$driver = New-Object -TypeName OpenQA.Selenium.Edge.EdgeDriver("Morphe_Builder\msedgedriver.exe", $Options)

# https://www.apkmirror.com/apk/google-inc/youtube/
$APKMirrorURL = "https://www.apkmirror.com/apk/google-inc/youtube/youtube-$($MorpheYT)-release/youtube-$($MorpheYT)-android-apk-download/"

Write-Verbose -Message "Trying URL $APKMirrorURL" -Verbose

$driver.Navigate().GoToUrl($APKMirrorURL)
$ButtonTitle = $driver.FindElement([OpenQA.Selenium.By]::CssSelector("a.downloadButton"))

# Get button title. We need a NON-bundle version only
$ButtonTitle.Text.Trim()

if ($ButtonTitle.Text.Trim() -match "DOWNLOAD APK BUNDLE")
{
	Write-Verbose -Message "$ButtonTitle.Text.Trim() matches 'BUNDLE'" -Verbose

	$driver.Quit()
	exit 1
}

$DownloadURL = $ButtonTitle.GetAttribute("href")
Write-Verbose -Message $DownloadURL -Verbose

# Download youtube.apk
# Waiting for Edge to finish downloading
$driver.Navigate().GoToUrl($DownloadURL)
#$DownloadURL = $driver.FindElement([OpenQA.Selenium.By]::Id("download-link")).GetAttribute("href")
#$driver.Navigate().GoToUrl($DownloadURL)

# Get runned Downloads folder
$DownloadsFolder = Get-ItemPropertyValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" -Name "{374DE290-123F-4565-9164-39C4925E467B}"

# Wait until apk is being downloaded
do
{
	$APK = Test-Path -Path "$DownloadsFolder\*.apk"

	if (-not $APK)
	{
		"Waiting for an APK file to be downloaded..."
		Get-ChildItem -Path $DownloadsFolder -File
		Start-Sleep -Seconds 5
	}
}
while (-not $APK)

# Copy APK to Morphe_Builder folder
$Parameters = @{
	Path        = "$DownloadsFolder\*.apk"
	Destination = "Morphe_Builder"
	Force       = $true
}
Copy-Item @Parameters

# Rename file to youtube.apk
Get-Item -Path "Morphe_Builder\*.apk" | Rename-Item -NewName youtube.apk -Force

$driver.Quit()
Get-Process -Name msedgedriver, msedge -ErrorAction Ignore | Stop-Process -Force -ErrorAction Ignore

echo "MorpheYTdot=$MorpheYTdot" >> $env:GITHUB_ENV
