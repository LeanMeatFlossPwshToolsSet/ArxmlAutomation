Import-Module Pester
$configuration=[PesterConfiguration]::Default
$configuration.CodeCoverage.Enabled = $true
Get-ChildItem (Resolve-Path "$PSScriptRoot/../") -Recurse -Filter "*.Tests.ps1"|ForEach-Object{
 Invoke-Pester $_
}