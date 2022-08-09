BeforeAll{
    Import-Module "$PSScriptRoot/ArxmlAutomation-Basic.psd1" -Force
    $autoSARComponentCollection=Get-AUTOSARCollection -FilePaths (Get-ChildItem "$PSScriptRoot/../../ExampleResouces/SWComponentAndComposition" -Filter "*.arxml" -Recurse)
}
Describe "Test for Create New Arxml Object" {
    It "AutoSar object shall be delivered"{
        New-AutosarObj|Foreach-Object {$_.GetType().ToString()}|Should -Be ("AR430.Autosar")
    }
}
Describe "Test for Reference Related Functions"{
    It "Find Ref Properties"{
        $autoSARComponentCollection|
            Find-AllItemsByType -Type ([AR430.SwComponentPrototype])|
            Get-ArElementRef|
            Should -BeOfType AR430.Ref
    }
    It "Find Ref Obj"{
        $autoSARComponentCollection|
            Find-AllItemsByType -Type ([AR430.SwComponentPrototype])|
            Find-ArElementFromRef -AUTOSARCollection $autoSARComponentCollection|
            Should -BeOfType AR430.ApplicationSwComponentType
    }
}
