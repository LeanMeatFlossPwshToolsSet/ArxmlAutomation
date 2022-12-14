
BeforeAll{
    $env:PSModulePath+=[IO.Path]::PathSeparator+(Resolve-Path "$PSScriptRoot/..")
    $moduleName=(([System.IO.DirectoryInfo] (Resolve-Path "$PSScriptRoot").Path).Name)
    Write-Host "Test Module Name $moduleName"
    Import-Module $moduleName
    Import-Module ArxmlAutomation-Basic -Force
}

Describe "Assert-ArObjType"{
    It "AssertType correct "{
        {
            [AR430.AbsoluteTolerance]::new()|Assert-ArObjType -AssertTypeMatch "AbsoluteTolerance"|Should -BeOfType [AR430.AbsoluteTolerance]
        }|Should -Not -Throw
    }
    It "Assert type incorrect"{
        {
            [AR430.AbsoluteTolerance]::new()|Assert-ArObjType -AssertTypeMatch "AbsoluteTolerance2"
        }|Should -Throw
    }
    It "AssertType with regular expressions "{
        {
            [AR430.AbsoluteTolerance]::new()|Assert-ArObjType -AssertTypeMatch "AbsoluteToleranc[a-z]"|Should -BeOfType [AR430.AbsoluteTolerance]
        }|Should -Not -Throw
    }
    It "AssertType shall match the type name with full content"{
        {
            [AR430.AbsoluteTolerance]::new()|Assert-ArObjType -AssertTypeMatch "[a-zA-Z0-9]*"|Should -BeOfType [AR430.AbsoluteTolerance]
        }|Should -Not -Throw
    }
    It "AssertType shall not match the type name with full content"{
        {
            [AR430.AbsoluteTolerance]::new()|Assert-ArObjType -AssertTypeMatch "[a-z]*"|Should -BeOfType [AR430.AbsoluteTolerance]
        }|Should -Throw
    }
}
