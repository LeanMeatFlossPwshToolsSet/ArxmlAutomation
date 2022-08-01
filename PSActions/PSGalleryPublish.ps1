param(
    [string]
    $NugetKey
)
$PSVersionTable
if($env:GITHUB_REF_NAME -eq "main"){
    # main branch methods
    Publish-Module -Path "$PSScriptRoot/../PSModules" -NuGetApiKey $NugetKey -Verbose -Confirm
}
else {
    # sub branch methods
    Publish-Module -Path "$PSScriptRoot/../PSModules" -NuGetApiKey $NugetKey -WhatIf -Verbose -Confirm
}