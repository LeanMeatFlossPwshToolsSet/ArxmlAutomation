BeforeAll{
    Import-Module "$PSScriptRoot/ArxmlAutomation-Basic.psd1" -Force
    Get-AUTOSARCollection -FilePaths (Get-ChildItem "$PSScriptRoot/../../ExampleResouces/SWComponentAndComposition" -Filter "*.arxml" -Recurse)|Use-AutoSarCollection
}
Describe "Test for Create New Arxml Object" {
    It "AutoSar object shall be delivered"{
        New-AutosarObj|Foreach-Object {$_.GetType().ToString()}|Should -Be ("AR430.Autosar")
    }
}
Describe "Test for Reference Related Functions"{
    It "Find Ref Properties"{
            Find-AllItemsByType -Type ([AR430.SwComponentPrototype])|
            Get-ArElementRef|
            Should -BeOfType AR430.Ref
    }
    It "Find Ref Obj"{
            Find-AllItemsByType -Type ([AR430.SwComponentPrototype])|
            Find-ArElementFromRef|
            Should -BeOfType AR430.ApplicationSwComponentType
    }
}
