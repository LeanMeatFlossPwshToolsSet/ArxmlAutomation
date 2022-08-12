function Write-FunctionInfos {
    param (
        [Parameter(ValueFromPipeline)]
        [string]
        $Content,
        [string]
        $Heading,
        [System.ConsoleColor]
        $ForegroundColor=[System.Console]::ForegroundColor
    )
    begin{
        $stack=Get-PSCallStack
        $commandName=""
        if($stack.Count -gt 1 -and $stack[1].Command){
            $commandName="[$($stack[1].Command)]"
        }
        $headTab=""#"  "*($stack.Count-1)
        if($Heading){
            $headingColumn=">>>>>$commandName$Heading>>>>>"
            Write-Host -Object "$headTab$headingColumn" -ForegroundColor  $ForegroundColor
        }
        
    }
    process{
        if($Heading){
            Write-Host "$headTab$Content" -ForegroundColor $ForegroundColor
        }
        else{
            Write-Host "$headTab$commandName$Content" -ForegroundColor $ForegroundColor
        }        
    }
    end{
        if($Heading){
            Write-Host ($headTab+($headingColumn -replace "[\S\s]","<")) -ForegroundColor $ForegroundColor
        }
        
    }
    
}

function Invoke-ConfigCommand{
    param(
        [string]
        $FunctionToInvoke,
        [hashtable]
        $Arguments
    )
    process{
        &$Global:ArxmlAutomationConfig[$FunctionToInvoke] @Arguments
    }
}