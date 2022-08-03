BeforeAll{
    Import-Module "$PSScriptRoot/ArxmlAutomation-Basic.psd1"
    $ARXML
}
Describe "Test for Create New Arxml Object" {
    It "AutoSar object shall be delivered"{
        New-AutosarObj|Foreach-Object {$_.GetType().ToString()}|Should -Be ("AR430.Autosar")
    }
}
