# Create a composition sw component type
if (-not (Get-InstalledModule -Name ArxmlAutomation-Swc)){
    Install-Module ArxmlAutomation-Swc -Scope CurrentUser
}
Import-Module ArxmlAutomation-Swc

$CompositionSWCompontn