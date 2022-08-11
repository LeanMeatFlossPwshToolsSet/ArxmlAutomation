# This use for setting up the test environment for all scripts
if($env:LocalDebugMode){
    Set-Location $PSScriptRoot
    $env:PSModulePath+=[IO.Path]::PathSeparator+(Resolve-Path "../ArxmlAutomation")
    Write-Host "
    The Ps modules path are:
    $env:PSModulePath
    "

}
else{
    Find-Module -Name "ArxmlAutomation-*"|Install-Module -Scope CurrentUser
}
$ErrorActionPreference="Break"
&"../Rules/ArxmlAutomation.Rules.ps1"
