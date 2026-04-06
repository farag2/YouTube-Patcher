(Get-Content -Path ReleaseNotesTemplate.md -Encoding utf8 -Raw).Replace("ReVancedYTdot", "${{ env.ReVancedYTdot }}").
	Replace("CLIReVancedTag", "${{ env.CLIReVancedTag }}").
	Replace("ReVancedPatchesTag", "${{ env.ReVancedPatchesTag }}").
	Replace("MicroG_ReVanced", "${{ env.MicroG_ReVanced }}").
	Replace("MorpheYTdot", "${{ env.MorpheYTdot }}").
	Replace("CLIMorpheTag", "${{ env.CLIMorpheTag }}").
	Replace("MorphePatchesTag", "${{ env.MorphePatchesTag }}").
	Replace("MicroG_Morphe", "${{ env.MicroG_Morphe }}") | Set-Content -Path ReleaseNotesTemplate.md -Encoding utf8 -Force

# https://trstringer.com/github-actions-multiline-strings/
Add-Content -Path $env:GITHUB_OUTPUT -Value "ReleaseBody=ReleaseNotesTemplate.md"

$ReleaseName = Get-Date -f "yyyy.MM.dd"
echo "RELEASE_NAME=$ReleaseName" >> $env:GITHUB_ENV
