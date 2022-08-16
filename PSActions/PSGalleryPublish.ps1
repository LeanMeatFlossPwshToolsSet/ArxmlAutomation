param(
    [string]
    $NugetKey,
    [string]
    $GitHubKey
)
$PSVersionTable
$env:PSModulePath+=[IO.Path]::PathSeparator+"$($env:GITHUB_WORKSPACE)/ArxmlAutomation"

git config user.name "CD Process"
git config user.email "CD.Process@users.noreply.github.com"



Write-Host "
The Ps modules path are:
$env:PSModulePath
"
dir env:
Set-PSRepository PSGallery -InstallationPolicy Trusted
git fetch --all --tags
Write-Host "Current Tags:"
git tag
$taggedVersions=@()+(git tag -l "v[0-9.]*" --sort="v:refname")
$taggedVersions|Write-Host

$taggedVersion=$taggedVersions[-1]
if($LASTEXITCODE -ne 0){
    $taggedVersion="v0.0.1"
    Write-Host "Using $taggedVersion as the init version."
}
$taggedVersionArray=$taggedVersion.Split([string[]]@(".","v"),[System.StringSplitOptions]::RemoveEmptyEntries)
$taggedVersionArray[-1]=([int]$taggedVersionArray[-1]+1).ToString()




$script:submitVersion=$taggedVersionArray -join "."
$script:GitNewTaggedVersion="v$($script:submitVersion)"

# increasing the version
$rev=$env:GITHUB_SHA
Write-Host "
Current Commit $rev
New Version need to be tagged $script:GitNewTaggedVersion
"
$script:PublishedModule=@()
function Publish-ModuleWizard{
    param(
        [System.IO.DirectoryInfo]
        $FilePath,
        $NugetKey,
        [int]
        $DependencyDepth=0,
        [int]
        $MaxDependency=-1
    )
    process{
        # Read Dependency
        $moduleConfiguration=Import-PowerShellDataFile  $FilePath.FullName
        $moduleConfiguration.NestedModules|ForEach-Object{
            $nestModule=$_
            if(-not $script:PublishedModule|Where-Object{$_.Name -eq $nestModule }){
                # publish dependency
                if($DependencyDepth -ne $MaxDependency){
                    Write-Host "Publish Dependency Module $nestModule"
                    Publish-ModuleWizard -FilePath (Get-Item "$($env:GITHUB_WORKSPACE)/ArxmlAutomation/$nestModule") -NugetKey $NugetKey -DependencyDepth ($DependencyDepth+1) -MaxDependency $MaxDependency
                }
                else{
                    Write-Error "Dependency Over Flow on Publish $nestModule"
                }
            }
        }
        # publish current module
        if($script:PublishedModule|Where-Object{$_.Name -eq $FilePath.Name }){
            Write-Host "$($FilePath.Name) has been published, skip"
            return
        }       


        $moduleOnCloud=Find-Module -Name $FilePath.Name -ErrorAction Continue
        # $moduleOnCloud|Write-Host
        if($moduleOnCloud){
            $cloudVersion=$moduleOnCloud.Version.Split([string[]]@(".","v"),[System.StringSplitOptions]::RemoveEmptyEntries)
            for ($i = 0; $i -lt $cloudVersion.Count; $i++) {
                <# Action that will repeat until the condition is met #>
                if($taggedVersionArray[$i] -le $cloudVersion[$i]){
                    $taggedVersionArray[$i]=$cloudVersion[$i]
                    if($i -eq 2){
                        $taggedVersionArray[$i]=(([int]$cloudVersion[$i])+1).ToString()
                    }
                }
                $newSubmitVersion=$taggedVersionArray -join "."
                if(-not $newSubmitVersion.Equals($script:submitVersion)){
                    $script:submitVersion=$taggedVersionArray -join "."
                    $script:GitNewTaggedVersion="v$($script:submitVersion)"
                    Write-Host "
                    Version update
                    New Version need to be tagged $script:GitNewTaggedVersion
                    "
                }
                
            }
        }
        Update-ModuleManifest -Path (Join-Path $FilePath.FullName "$($FilePath.Name).psd1") -ModuleVersion $script:submitVersion
        Test-ModuleManifest -Path (Join-Path $FilePath.FullName "$($FilePath.Name).psd1")
        if($env:GITHUB_REF_NAME -eq "main"){
            # main branch methods
            Publish-Module -Path "$($FilePath.FullName)" -NuGetApiKey $NugetKey -Verbose -Force
            
        }
        else {
            # sub branch methods
            Publish-Module -Path "$($FilePath.FullName)" -NuGetApiKey $NugetKey -WhatIf -Verbose
        
        }
    }
}
Get-ChildItem -Path "$($env:GITHUB_WORKSPACE)/ArxmlAutomation" -Directory |ForEach-Object{
    Publish-ModuleWizard -FilePath $_ -NugetKey $NugetKey
}
if($env:GITHUB_REF_NAME -eq "main"){
    # main branch methods
    "Push tag to Repo"|Write-Host
    git tag -a $script:GitNewTaggedVersion $rev -m "Continous Delivery Version Submitted"
    git push origin "$script:GitNewTaggedVersion"
    
}
else{
    "In branch don't push the tag"|Write-Host
}


