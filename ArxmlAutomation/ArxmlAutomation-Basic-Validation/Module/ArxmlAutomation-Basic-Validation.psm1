function Confirm-SameArObjContainer{
    param(
        [AR430._AR430BaseType[]]
        $Items,
        [int]
        $Depth=-1
    )
    process{
        $pass=$True
        $sortedItems=$Items|Sort-Object {$_.GetAutosarPath().Length}
        for ($i = 1; $i -lt $sortedItems.Count; $i++) {
            if(-not $sortedItems[$i].GetAutosarPath().StartsWith($sortedItems[0].GetAutosarPath())){
                Write-Warning "$sortedItems[$i] at $($sortedItems[$i].GetAutosarPath()) is different with $sortedItems[0] at $($sortedItems[0].GetAutosarPath())"
                $pass=$False
            }
            elseif($Depth -lt 0){
                # don't check depth
            }
            elseif($sortedItems[$i].GetAutosarPath().Substring(0,$sortedItems[0].GetAutosarPath().Length).Split(@("/"),[System.StringSplitOptions]::RemoveEmptyEntries).Count -gt $Depth){
                Write-Warning "$sortedItems[$i] at $($sortedItems[$i].GetAutosarPath()) is different with $sortedItems[0] at $($sortedItems[0].GetAutosarPath()) with Depth $Depth"
                $pass=$False
            }
            else{
                Write-Verbose "$sortedItems[$i] at $($sortedItems[$i].GetAutosarPath()) is the same container with $sortedItems[0] at $($sortedItems[0].GetAutosarPath()) with Depth $Depth"
            }
            
        }
        if(-not $pass){
            Write-Error "Same arobj container validation failed for $items."
        }
    }
}
function Assert-ArObjType{
    param(
        [Parameter(ValueFromPipeline)]
        [AR430._AR430BaseType]
        $InputObject,
        [Parameter(ParameterSetName="MatchString" , Position=0)]
        [string[]]
        $AssertTypeMatch,
        [Parameter(ParameterSetName="MatchType", Position=0)]
        [type[]]
        $AssertType,
        [switch]
        $AllowIgnore,
        [switch]
        $ReturnBool
    )
    process{
        if($PSCmdlet.ParameterSetName -eq ("MatchString")){
            if($InputObject.GetType().Name|Select-String -CaseSensitive -Pattern ($AssertTypeMatch|ForEach-Object{
                "(?m)^$_$"
            })){
                if($ReturnBool){
                    return $true
                }
                else{
                    return $InputObject
                }
                
            }
            elseif(-not $AllowIgnore){
                throw "$InputObject is not  part of AssertType $AssertType"
            }
            elseif($ReturnBool){
                return $false
            }
        }
        else{
            if($AssertType|Where-Object{$InputObject -is $_}){
                if($ReturnBool){
                    return $true
                }
                else{
                    return $InputObject
                }
            }
            elseif($ReturnBool){
                return $false
            }
        }
        
    }
}