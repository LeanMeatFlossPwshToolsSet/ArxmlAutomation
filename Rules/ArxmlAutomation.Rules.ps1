param(
    [System.IO.FileInfo]
    $CustomerRuleFiles
)
$Global:ArxmlAutomationConfig=@{

}

# Load Default Rules
Get-ChildItem "$PSScriptRoot/DefaultRules" -Recurse -Filter *.Rules.ps1|ForEach-Object{
    & $_.FullName
}
$Global:ArxmlAutomationConfig|
    Format-Table `
    @{Label="Config Attribute";Expression={$_.Key}},
    @{Label="Target Function";Expression={($_.Value).Name}},
    @{Label="Source";Expression={($_.Value).Source}}
|Out-String|Write-FunctionInfos -Heading "Current Global Callout Configuration:" -ForegroundColor Green