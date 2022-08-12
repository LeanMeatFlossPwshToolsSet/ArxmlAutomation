BeforeAll{
    $env:PSModulePath+=[IO.Path]::PathSeparator+(Resolve-Path "$PSScriptRoot/..")
    $moduleName=(([System.IO.DirectoryInfo] (Resolve-Path "$PSScriptRoot").Path).Name)
    Write-Host "Test Module Name $moduleName"
    Import-Module $moduleName  -Force
    Import-Module (Resolve-Path "$PSScriptRoot/../../Util/TestUtil.psm1") -Force 
    Get-AUTOSARCollection -FilePaths (Get-ChildItem "$PSScriptRoot/../../ExampleResouces/SWComponentAndComposition" -Filter "*.arxml" -Recurse)|Use-AutoSarCollection   
}
Describe "New-AssemblySWConnector" {
    Context "Default Context" {
        BeforeAll{
            Mock Invoke-ConfigCommand{} -ModuleName $moduleName
        }
        It  "Validation Correct Parameter"{
            @{}|
                Add-TypedArgumentInput -ParameterName ProvideComponent -TypesToAppend ([AR430.SwComponentPrototype])|
                Add-TypedArgumentInput -ParameterName ProvidePort -TypesToAppend ([AR430.PPortPrototype],[AR430.PRPortPrototype])|
                Add-TypedArgumentInput -ParameterName RequestComponent -TypesToAppend ([AR430.SwComponentPrototype])|
                Add-TypedArgumentInput -ParameterName RequestPort -TypesToAppend ([AR430.RPortPrototype],[AR430.PRPortPrototype])|
                ForEach-Object{
                    {
                        New-AssemblySWConnector @_
                    }|Should -Not -Throw
                    Should -Invoke Invoke-ConfigCommand -ModuleName $moduleName -ParameterFilter {$FunctionToInvoke -eq "Set-AssemblySWConnectorShortName"}               
                }      
        }  
        It  "Validation Incorrect Parameter"{
            @{}|
                Add-TypedArgumentInput -ParameterName ProvideComponent -TypesToAppend ([AR430.SwComponentPrototype])|
                Add-TypedArgumentInput -ParameterName ProvidePort -TypesToAppend ([AR430.SwComponentPrototype],[AR430.SwComponentPrototype])|
                Add-TypedArgumentInput -ParameterName RequestComponent -TypesToAppend ([AR430.SwComponentPrototype])|
                Add-TypedArgumentInput -ParameterName RequestPort -TypesToAppend ([AR430.SwComponentPrototype],[AR430.SwComponentPrototype])|
                ForEach-Object{
                    {
                        New-AssemblySWConnector @_
                    }|Should -Throw
                }      
                Should -Not -Invoke Invoke-ConfigCommand -ModuleName $moduleName -ParameterFilter {$FunctionToInvoke -eq "Set-AssemblySWConnectorShortName"}
        }  
    }
    
                
}