# In Vscode the module need to be imported then we can have lint.
$EnterLocation=Get-Location
Set-Location $PSScriptRoot
$ModulesPath=(Resolve-Path "../ArxmlAutomation")
$env:PSModulePath+=[IO.Path]::PathSeparator+$ModulesPath
Write-Host "
The Ps modules path are:
$env:PSModulePath
"
# Get-ChildItem $ModulesPath -Directory|ForEach-Object{
#     Import-Module "$($_.Name)" -Force -Verbose
# }
Set-Location $EnterLocation