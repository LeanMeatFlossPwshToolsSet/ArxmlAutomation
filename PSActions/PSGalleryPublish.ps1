param(
    [string]
    $NugetKey
)
$PSVersionTable
dir env:
Set-PSRepository PSGallery -InstallationPolicy Trusted
Get-ChildItem -Path "$($env:GITHUB_WORKSPACE)/PSModulesManifest"
if($env:GITHUB_REF_NAME -eq "main"){
    # main branch methods
    Publish-Module -Path "$($env:GITHUB_WORKSPACE)/PSModulesManifest" -NuGetApiKey $NugetKey -Verbose -Confirm
}
else {
    # sub branch methods
    Publish-Module -Path "$($env:GITHUB_WORKSPACE)/PSModulesManifest" -NuGetApiKey $NugetKey -WhatIf -Verbose -Confirm
}