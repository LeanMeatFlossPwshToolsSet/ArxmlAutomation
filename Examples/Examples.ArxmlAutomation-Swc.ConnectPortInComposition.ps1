# Create a composition sw component type
&"$PSScriptRoot\Examples.EnvironmentSetup.ps1"
Import-Module ArxmlAutomation-Swc -Force
$autoSARCollection=Get-ChildItem "../ExampleResouces/SWComponentAndComposition" -Filter "*.arxml"|Get-AUTOSARCollection
