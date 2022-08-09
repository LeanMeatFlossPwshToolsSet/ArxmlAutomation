# This use for setting up the test environment for all scripts
Set-Location $PSScriptRoot
$env:PSModulePath+=[IO.Path]::PathSeparator+(Resolve-Path "../ArxmlAutomation")
Write-Host "
The Ps modules path are:
$env:PSModulePath
"

