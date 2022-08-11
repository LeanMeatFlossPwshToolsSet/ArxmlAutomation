BeforeAll{
    $env:PSModulePath+=[IO.Path]::PathSeparator+(Resolve-Path "..")
    Import-Module ArxmlAutomation-Basic-Validation -Force
}
Describe "Assert-ArObjType"{
    It "AssertType correct "{
        {
            [AR430.AbsoluteTolerance]::new()|Assert-ArObjType -AssertType "AbsoluteTolerance"|Should -BeOfType [AR430.AbsoluteTolerance]
        }|Should -Not -Throw
    }
    It "Assert type incorrect"{
        {
            [AR430.AbsoluteTolerance]::new()|Assert-ArObjType -AssertType "AbsoluteTolerance2"
        }|Should -Throw
    }
    It "AssertType with regular expressions "{
        {
            [AR430.AbsoluteTolerance]::new()|Assert-ArObjType -AssertType "AbsoluteToleranc[a-z]"|Should -BeOfType [AR430.AbsoluteTolerance]
        }|Should -Not -Throw
    }
    It "AssertType shall match the type name with full content"{
        {
            [AR430.AbsoluteTolerance]::new()|Assert-ArObjType -AssertType "[a-zA-Z0-9]*"|Should -BeOfType [AR430.AbsoluteTolerance]
        }|Should -Not -Throw
    }
    It "AssertType shall not match the type name with full content"{
        {
            [AR430.AbsoluteTolerance]::new()|Assert-ArObjType -AssertType "[a-z]*"|Should -BeOfType [AR430.AbsoluteTolerance]
        }|Should -Throw
    }
}