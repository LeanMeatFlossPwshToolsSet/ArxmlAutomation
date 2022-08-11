Import-Module $PSScriptRoot\DefaultRules\ArxmlAutomation-Rules-Swc.Default.psm1 -Prefix DefaultRule
$Global:ArxmlAutomationConfig=@{
    "Set-AssemblySWConnectorShortName"="Set-DefaultRuleAssemblySWConnectorShortName"
    "Find-PortMatched"="Find-DefaultRulePortMatched"
}