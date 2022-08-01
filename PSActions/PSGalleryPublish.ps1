param(
    [string]
    $NugetKey
)
$PSVersionTable
dir env:
Set-PSRepository PSGallery -InstallationPolicy Trusted
if($env:GITHUB_REF_NAME -eq "main"){
    # main branch methods
    Publish-Module -Path "./PSModulesManifest" -NuGetApiKey $NugetKey -Verbose -Confirm
}
else {
    # sub branch methods
    Publish-Module -Path "./PSModulesManifest" -NuGetApiKey $NugetKey -WhatIf -Verbose -Confirm
}