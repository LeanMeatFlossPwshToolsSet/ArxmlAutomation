param(
    [string]
    $NugetKey,
    [string]
    $GitHubKey
)
$PSVersionTable
$env:PSModulePath+=";$($env:GITHUB_WORKSPACE)/ArxmlAutomation"
Write-Host $env:PSModulePath
dir env:
Set-PSRepository PSGallery -InstallationPolicy Trusted
$taggedVersion=git describe --match "v([0-9]\.){3}"
if($LASTEXITCODE -ne 0){
    $taggedVersion="v0.0.1"
    Write-Host "Using $taggedVersion as the init version."
}
$taggedVersionArray=$taggedVersion.Split([string[]]@(".","v"),[System.StringSplitOptions]::RemoveEmptyEntries)
$taggedVersionArray[-1]=([int]$taggedVersionArray[-1]+1).ToString()
$submitVersion=$taggedVersionArray -join "."
$GitNewTaggedVersion="v$($submitVersion)"

# increasing the version
$rev=git rev-parse HEAD
Write-Host "
Current Commit $rev
New Version need to be tagged $GitNewTaggedVersion
"
Get-ChildItem -Path "$($env:GITHUB_WORKSPACE)/ArxmlAutomation" -Directory |ForEach-Object{
    $psdDependenc
    $env:PSModulePath="$env:PSModulePath;"
}
Get-ChildItem -Path "$($env:GITHUB_WORKSPACE)/ArxmlAutomation" -Directory |ForEach-Object{
    Update-ModuleManifest -Path (Join-Path $_.FullName "$($_.Name).psd1") -ModuleVersion $submitVersion
    Test-ModuleManifest -Path (Join-Path $_.FullName "$($_.Name).psd1")
    
    if($env:GITHUB_REF_NAME -eq "main"){
        # main branch methods
        Publish-Module -Path "$($_.FullName)" -NuGetApiKey $NugetKey -Verbose -Force
        git tag -a $GitNewTaggedVersion -m "Continous Delivery Version Submitted"
        git push --tag
        
    }
    else {
        # sub branch methods
        Publish-Module -Path "$($_.FullName)" -NuGetApiKey $NugetKey -WhatIf -Verbose
    }
}

