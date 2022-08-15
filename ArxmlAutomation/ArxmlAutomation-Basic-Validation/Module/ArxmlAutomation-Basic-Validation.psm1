function Confirm-SameArObjContainer{
    param(
        [AR430._AR430BaseType[]]
        $Items,
        [int]
        $Depth=-1
    )
    process{
        $pass=$True
        $sortedItems=$Items|Sort-Object {$_.GetAutosarPath().Length}|Foreach-Object {,@($_.GetAutosarPath() -split "/")}
        $objectMeasures=($sortedItems|ForEach-Object {$_.Count}|Measure-Object -Maximum -Minimum)
        if($Depth -gt 0 -and $objectMeasures.Maximum-$objectMeasures.Minimum -gt $Depth){
            
            $pass=$False
        }
        if($pass){
            $DepthMeasured=0
            for($i=0;$i-lt $objectMeasures.Minimum;$i++){
                # loop
                if(($sortedItems|ForEach-Object{
                    $_[$i]
                }|Select-Object -Unique).Count -ne 1){
                    
                    if($DepthMeasured -eq $Depth){
                        $pass=$False
                        break;
                    }
                    else{
                        $DepthMeasured++
                    }
                    
                }
            }
        }       
        if(-not $pass){
            Write-Warning "$($items|Foreach-Object{$_.GetAutosarPath()}) container different"
            Write-Error "Same arobj container validation failed for $items."
        }
    }
}
function Assert-ArObjType{
    param(
        [Parameter(ValueFromPipeline)]
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