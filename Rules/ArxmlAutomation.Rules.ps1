Import-Module $PSScriptRoot\DefaultRules\ArxmlAutomation-Swc.Default.psm1 -Prefix DefaultRule
$Global:ArxmlAutomationConfig=@{
    "Set-AssemblySWConnectorShortName"="Set-DefaultRuleAssemblySWConnectorShortName"
}