# This script is a example for the component port connection in composition
&"$PSScriptRoot\Examples.EnvironmentSetup.ps1"
Import-Module ArxmlAutomation-Swc -Force
$autoSARCollection=Get-AUTOSARCollection -FilePaths (Get-ChildItem "../ExampleResouces/SWComponentAndComposition" -Filter "*.arxml" -Recurse)
$compositionDest=$autoSARCollection|Find-AllItemsByType -Type ([AR430.CompositionSwComponentType])|Where-Object {
    $_.GetAutosarPath().Equals("/ComponentTypes/Implementation")
}
$referencedComponents=$compositionDest|Find-AllItemsByType -Type ([AR430.SwComponentPrototype])|Find-ArElementFromRef -AUTOSARCollection $autoSARCollection -Verbose -ObjOnly
$referencedComponents|ForEach-Object{
    Write-Host "Component $($_.ShortName) at $($_.GetAutosarPath())"
    $_.Ports.PPortPrototypes|
}

# The rule is list all the port and unconnected port in the composition