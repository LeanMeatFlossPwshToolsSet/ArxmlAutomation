# This script is a example for the component port connection in composition
&"$PSScriptRoot\Examples.EnvironmentSetup.ps1"
$ErrorActionPreference="Break"
Import-Module ArxmlAutomation-Swc -Force
Import-Module ArxmlAutomation-Swc-Advance -Force
$autoSARCollection=Get-AUTOSARCollection -FilePaths (Get-ChildItem "../ExampleResouces/SWComponentAndComposition" -Filter "*.arxml" -Recurse)
$compositionDest=$autoSARCollection|Find-AllItemsByType -Type ([AR430.CompositionSwComponentType])|Where-Object {
    $_.GetAutosarPath().Equals("/ComponentTypes/Implementation")
}
Get-UnConnectedPort -AutoSarCollection $autoSARCollection -Composition $compositionDest|Connect-ToPort

# $referencedComponents|Find-ArElementFromRef -AUTOSARCollection $autoSARCollection|ForEach-Object{
#     $_.Ports
# }

# The rule is list all the port and unconnected port in the composition