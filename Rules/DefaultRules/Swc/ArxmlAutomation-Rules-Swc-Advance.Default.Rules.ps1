Import-Module $PSScriptRoot\ArxmlAutomation-Rules-Swc-Advance.Default.Rules.psm1 -Prefix DefaultRule -Force
$Global:ArxmlAutomationConfig."Set-AssemblySWConnectorShortName"=Get-Command Set-DefaultRuleAssemblySWConnectorShortName
$Global:ArxmlAutomationConfig."Find-PortMatched"=Get-Command Find-DefaultRulePortMatched