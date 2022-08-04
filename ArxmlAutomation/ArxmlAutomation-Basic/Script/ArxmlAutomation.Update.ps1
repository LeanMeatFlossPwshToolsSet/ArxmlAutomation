Get-InstalledModule -Name "ArxmlAutomation-*"|ForEach-Object{
    Update-Module -Name $_.Name -Verbose
}