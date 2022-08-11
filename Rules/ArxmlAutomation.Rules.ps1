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
Write-Host "Current Global Callout Configuration:" -ForegroundColor Green
$Global:ArxmlAutomationConfig|
    Format-Table `
    @{Label="Config Attribute";Expression={$_.Key}},
    @{Label="Target Function";Expression={(Get-Command $_.Value).Name}},
    @{Label="Source";Expression={(Get-Command $_.Value).Source}}
|Out-String|Write-Host