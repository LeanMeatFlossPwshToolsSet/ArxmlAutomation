
Get-InstalledModule -Name "ArxmlAutomation-*" -ErrorAction Ignore|ForEach-Object{
    Update-Module -Name $_.Name -Verbose
}