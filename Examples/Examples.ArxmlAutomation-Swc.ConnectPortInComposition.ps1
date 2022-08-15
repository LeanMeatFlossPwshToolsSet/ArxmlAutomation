# This script is a example for the component port connection in composition

&"$PSScriptRoot\Examples.EnvironmentSetup.ps1"
$Global:ErrorActionPreference="Break"
Import-Module ArxmlAutomation-Swc -Force
Import-Module ArxmlAutomation-Swc-Advance -Force
Get-AUTOSARCollection -FilePaths (Get-ChildItem "../ExampleResouces/SWComponentAndComposition" -Filter "*.arxml" -Recurse)|Use-AutoSarCollection
$global:compositionDest=Find-AllItemsByType -Type ([AR430.CompositionSwComponentType])|Where-Object {
    $_.GetAutosarPath().Equals("/ComponentTypes/Implementation")
}
$compositionDest|Show-ConnectionsInfo
Get-UnConnectedRPort  -Composition $compositionDest|Connect-PortAutomation
$compositionDest|Show-ConnectionsInfo

