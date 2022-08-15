# Add-Type -Path "$PSScriptRoot/../Library/TesterOutput.dll"
function Get-ArxmlObj {
    [OutputType([AR430.AutoSar])]
    param (
        $arxmlFilePath
    )
    process{
        $PowerShell = [powershell]::Create()
        $Runspace = [runspacefactory]::CreateRunspace()
        $PowerShell.runspace = $Runspace
        $Runspace.Open()
        $script=@"
    [AR430.AutoSar]`$arxmlParsed=`$null
    [AR430.AutoSar]::GetInstance(`"{0}`",[ref]`$arxmlParsed)
    Write-Output @{{outp=`$arxmlParsed}}
"@ -f $arxmlFilePath
        [void]$PowerShell.AddScript([string]$script)
        $AsyncObject = $PowerShell.BeginInvoke()

        $percent=0
        while(-not $AsyncObject.IsCompleted){
            Write-Progress -Activity "Reading Arxml File..." -PercentComplete $percent
            start-sleep 0.5
            $percent+=1
            if($percent -gt 100){
                $percent-=100
            }
        }
        Write-Progress -Activity "Reading Arxml File..." -Complete
        $arxmlParsed=$PowerShell.EndInvoke($AsyncObject).outp
        $PowerShell.Dispose()
        return $arxmlParsed
    }
    
}
function New-AutosarObj{
    process{
        return [AR430.Autosar]::new()
    }
}
function New-AutosarItem{
    param(        
        $Type,
        [scriptblock]
        $Process
    )
    process{
        $NewItem=New-Object -TypeName "AR430.$Type"
        if($Process){
            $NewItem|Foreach-Object -Process $Process
        }  
        return $NewItem
    }
}
function New-ReferenceProperty{
    param(
        [Parameter(ValueFromPipeline)]
        [AR430._AR430BaseType]        
        $Item,
        [Parameter(ValueFromPipelineByPropertyName)]
        $PropertyName,
        [AR430._AR430BaseType] 
        $ReferenceItem
    )
    process{
        $Item |New-PropertyFactory -PropertyName $PropertyName -Process{
            # set dest
            $_.Dest=$ReferenceItem.GetType().Name -as $_.Dest.GetType()
            $_|Set-StringToProperty -Value $ReferenceItem.GetAutosarPath()
        }
    }
}
function Get-PropertyFactory{
    param(
        [Parameter(ValueFromPipeline)]
        [AR430._AR430BaseType]        
        $Item,
        [Parameter(ValueFromPipelineByPropertyName)]
        $PropertyName,
        $Index,
        [scriptblock]
        $Process
    )
    process{
        $findItem=$Item.$PropertyName
        if($Index){
            $findItem=$findItem[$Index]
        }
        if(-not $findItem){
            $findItem=$Item |New-PropertyFactory -PropertyName $PropertyName
        }
        if($Process){
            $findItem|Foreach-Object -Process $Process
        }              
        return $findItem
    }
}
function New-PropertyFactory{
    param(
        [Parameter(ValueFromPipeline)]
        [AR430._AR430BaseType]        
        $Item,
        [Parameter(ValueFromPipelineByPropertyName)]
        $PropertyName,
        [scriptblock]
        $Process
    )
    process{
        $type=$Item.GetType().GetMember($PropertyName).PropertyType
        $finalType=$type
        if($type.IsArray){
            $finalType=$type.GetElementType()
        }
        else{

        }
        $NewItem=New-Object -TypeName $finalType
        if($NewItem|Get-Member -Name _AutosarParent){
            $NewItem._AutosarParent=$Item
        }
        
        if($Process){
            $NewItem|Foreach-Object -Process $Process
        }  
        if($type.IsArray){
            $Item.$PropertyName+=$NewItem
        }
        else{
            $Item.$PropertyName=$NewItem
        }              
        return $NewItem
    }
}
function Set-StringToProperty{
    param(
        [Parameter(ValueFromPipeline)]       
        $Item,
        [string]
        $Value
    )
    process{
        $Item._XmlText=$Value
    } 
}
function Set-ShortName{
    param(
        [Parameter(ValueFromPipeline)]
        [AR430._AR430BaseType]        
        $Item,
        [string]
        $Name
    )
    process{
        $Item|New-PropertyFactory -PropertyName ShortName -Process {
            $_|Set-StringToProperty -Value $Name
        }|Out-Null
    }
}
function New-ReferrableSubItem{
    param(
        $ItemName,
        [AR430.ReferrableSubtypesEnum]
        $Type
    )
    process{
        New-AutosarItem -Type $Type.ToString() -Process {
            $_|Set-ShortName -Name $ItemName
        }
    }
}
function Find-DirectReferrableItem{
    param(
        [Parameter(ValueFromPipeline)]
        $Type
    )
    process{
        $Type.GetProperties()|
        Where-Object{
            -not $_.PropertyType.IsArray
        }|Where-Object{
            $_.Name -ne "_AutosarParent"
        }|Where-Object{
            $_.PropertyType.IsSubclassOf([AR430._AR430BaseType])
        }|Where-Object{
            $_.PropertyType.GetProperties()|Where-Object{$_.Name -eq "ShortName"}
        }
    }
}
function Find-NestedReferrableItem{
    param(
        [Parameter(ValueFromPipeline)]
        $Type,
        [int]
        $DepthCurrent=0,
        [int]
        $DepthAllow=-1
    )
    process{
        
        $Type.GetProperties()|Where-Object{
            $_.PropertyType.IsSubclassOf([AR430._AR430BaseType])
        }|Where-Object{
            -not $_.PropertyType.IsArray
        }|Where-Object{
            $_.Name -ne "_AutosarParent"
        }|Where-Object{
            -not ($_.PropertyType.GetProperties()|Where-Object {$_.Name -eq "ShortName"})
        }|ForEach-Object{
            $PropertyArray=@($_)
            $_.PropertyType|Find-DirectReferrableItem|ForEach-Object{
                $newAppendArray=$PropertyArray.Clone()
                $newAppendArray+=$_
                return ,$newAppendArray
            }
            $_.PropertyType|Find-ArrayReferrableItem|ForEach-Object{
                $newAppendArray=$PropertyArray.Clone()
                $newAppendArray+=$_
                return ,$newAppendArray
            }   
            if($DepthCurrent+1 -ne $DepthAllow){
                # this has depth issue
                $_.PropertyType|Find-NestedReferrableItem -DepthCurrent ($DepthCurrent+1) -DepthAllow $DepthAllow|ForEach-Object{
                    $newAppendArray=$PropertyArray.Clone()
                    $newAppendArray+=$_
                    return ,$newAppendArray
                }   
            }
            
        }
    }
}
function Find-ArrayReferrableItem{
    param(
        [Parameter(ValueFromPipeline)]
        $Type
    )
    process{
        $Type.GetProperties()|
        Where-Object{
            $_.PropertyType.IsArray
        }|Where-Object{
            $_.PropertyType.GetElementType().BaseType -eq [AR430._AR430BaseType]
        }|Where-Object{
            $_.PropertyType.GetElementType().GetProperties()|Where-Object{$_.Name -eq "ShortName"}
        }
    }
}
function Find-NextReferrableItemProperty{
    param(
        [Parameter(ValueFromPipeline)]
        $Container
    )
    process{
        $returnValue=@()
        $returnValue+=,$Container.GetType()|Find-DirectReferrableItem
        $returnValue+=,$Container.GetType()|Find-ArrayReferrableItem
        $returnValue+=,$Container.GetType()|Find-NestedReferrableItem -DepthAllow 5
        return $returnValue
    }
}
function Update-ReferrableItemToCollection{
    param(      
        $Container,
        [Parameter(ValueFromPipeline)]
        $Item
    )
    process{
        $Container|Find-NextReferrableItemProperty|Where-Object{
            if(($_[-1].PropertyType.IsArray)){
                $_[-1].PropertyType.GetElementType() -eq $Item.GetType()
            }
            else{
                $_[-1].PropertyType -eq $Item.GetType()
            }            
        }|Select-Object -First 1|ForEach-Object{
            # processing with the property array
            $currentContainer=$Container
            foreach($propertyItem in $_){
                if($propertyItem.PropertyType.IsArray){
                    if($propertyItem -eq $_[-1]){
                        $getResult=$propertyItem.GetValue($currentContainer)
                        if(-not $getResult){
                            $getResult=[System.Array]::CreateInstance($propertyItem.PropertyType.GetElementType(),0)
                        }
                        $findItem=$getResult|Where-Object{$_.ShortName -eq $Item.ShortName}|Select-Object -First 1
                        if($findItem){
                            "Replace $findItem with $Item at $($currentContainer._AutosarParent.GetAutosarPath())"|Write-FunctionInfos
                            $getResult-=$findItem
                        }
                        else{
                            $path=$currentContainer._AutosarParent.GetAutosarPath()
                            "Add $Item at $path"|Write-FunctionInfos
                        }
                        $Item._AutosarParent=$currentContainer
                        $getResult+=,$Item
                        $resultcontainer=$getResult -as "$($propertyItem.PropertyType.FullName)"
                        $propertyItem.SetValue($currentContainer,$resultcontainer)
                    }else{
                        # not the final one, try to create a container
                        # last index, has to process
                        $getResult=$propertyItem.GetValue($currentContainer)
                        if(-not $getResult){
                            $getResult=[System.Array]::CreateInstance($propertyItem.PropertyType.GetElementType(),0)
                        }
                        if($getResult.Count -gt 0){
                            $currentContainer=$getResult[0]
                        }
                        else{
                            $newItem=New-Object -TypeName $propertyItem.PropertyType.GetElementType()
                            $getResult+=$newItem
                            $newItem._AutosarParent=$currentContainer
                            $propertyItem.SetValue($currentContainer,($getResult -as "$($propertyItem.PropertyType.FullName)"))
                            $currentContainer=$newItem
                        }
                    }
                }
                else{
                    if($propertyItem -eq $_[-1]){
                        # last index, has to process
                        $getResult=$propertyItem.GetValue($currentContainer)
                        if($getResult){
                            "Replace $getResult with $Item at $($currentContainer.GetAutosarPath())"|Write-FunctionInfos
                        }
                        else{
                            "Set $Item at $($currentContainer.GetAutosarPath())"|Write-FunctionInfos
                        }
                        $Item._AutosarParent=$currentContainer
                        $propertyItem.SetValue($currentContainer,$Item)
                    }
                    else{
                        # none last, process to the last
                        # last index, has to process
                        $getResult=$propertyItem.GetValue($currentContainer)
                        if($getResult){
                            $currentContainer=$getResult
                        }
                        else{
                            "$($propertyItem.Name) at $currentContainer($($currentContainer.GetAutosarPath())) empty, create new"
                            $getResult=New-Object -TypeName $propertyItem.PropertyType
                            $getResult._AutosarParent=$currentContainer
                            $propertyItem.SetValue($currentContainer,$getResult)
                            $currentContainer=$getResult
                        }
                    }
                }
            }
        }
    }
}
function New-ReferrableSubItemsToCollection{
    param(
        [Parameter(ValueFromPipeline)]
        [AR430._AR430BaseType]        
        $Container,
        [Parameter(ValueFromPipelineByPropertyName)]
        $PropertyName,
        $ItemName,
        [AR430.ReferrableSubtypesEnum]
        $Type
    )
    process{
        $newItem=New-ReferrableSubItem  -ItemName $ItemName -Type $Type
        $Container.$PropertyName+=$newItem
        return $newItem
    }
}
function New-IdentifiableItem{
    param(
        $ItemName,
        [AR430.IdentifiableSubtypesEnum]
        $Type
    )
    process{
        New-AutosarItem -Type $Type.ToString() -Process {
            $_|Set-ShortName -Name $ItemName
        }
    }
}
function Add-Action{
    param(
        [array]
        $Container,
        [string]
        $ActionName,
        [scriptblock]
        $Process
    )
    process{
        $Container+=@{
            Name=$ActionName
            Action=$Process
        }
    }
}
function Get-AUTOSARCollection{
    [OutputType([AR430.AUTOSARCollection])]
    param(
        [Parameter(ValueFromPipeline)]
        [System.IO.FileInfo[]]
        $FilePaths
    )
    process{
        [string[]]$fileList=@()
        $FilePaths|ForEach-Object{$fileList+=$_.FullName}
        [AR430.AUTOSARCollection]::LoadFile($fileList)
    }
}
[AR430.AUTOSARCollection]$Global:_CurrentAutoSarCollection=$null
function Use-AutoSarCollection{
    param(
        [Parameter(ValueFromPipeline)]
        [AR430.AUTOSARCollection]
        $AUTOSARCollection
    )
    process{        
        $Global:_CurrentAutoSarCollection=$AUTOSARCollection
        $AUTOSARCollection|Format-Table|Out-String|Write-FunctionInfos -Heading "Current Processing AutoSarCollection" -ForegroundColor Green
    }
}
function Get-CurrentAutoSarCollection{
    process{
        if(-not $Global:_CurrentAutoSarCollection){
            throw "Current AutosarCollection Not Specified"
        }
        else{
            return $Global:_CurrentAutoSarCollection
        }
        
    }
}

function Use-ArxmlFile{
    param (
        [System.IO.FileInfo]
        $ArxmlFilePath,
        [string]
        $ArxmlVariableName="AR_OBJ",
        [scriptblock]
        $Process,
        [switch]
        $Confirm
    )
    begin{
        $arobj=Get-ArxmlObj -arxmlFilePath   $ArxmlFilePath
    }
    process{
        $Process.InvokeWithContext($null,@(
            [psvariable]::new($ArxmlVariableName,$arobj)
        ),$null)
    }
    end{
        if(-not $Confirm){
            $confirmation=Read-Host "Confirm the upper changes?(Y/N)"
        }
        if($Confirm -or ($confirmation.ToLower() -eq "y")){
            $arobj.GetXmlOutput()|Out-File $ArxmlFilePath -Force
        }
    }
}
function Find-AllItemsByType{
    [CmdletBinding()]
    param(
        [System.Type[]]
        $Type
    )
    process{
        $Type|Foreach-Object{
            $content=[System.Array]::CreateInstance($_,0)
            (Get-CurrentAutoSarCollection).GetElementArrayByType([ref]$content)
            $content
        }
        
    }
}
function Get-ArElementRef{
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline)]
        [ValidateScript({
            $_|Assert-ArObjType ([AR430._AR430BaseType],[AR430.Ref]) 
        })]
        $ArObjWithRef
    )
    process{
        # get potential ref objects
        if($ArObjWithRef -is [AR430.Ref]){
            return $ArObjWithRef
        }
        else{
            $ArObjWithRef.GetType().GetProperties()|Where-Object{
                $_.PropertyType.IsSubclassOf([AR430.Ref])
            }|ForEach-Object{
                $_.GetValue($ArObjWithRef)                
            }
        }
        
    }
}
function Find-ArElementFromRef{
    [CmdletBinding()]
    param(
        [ValidateScript({
            $_|Assert-ArObjType ([AR430._AR430BaseType],[AR430.Ref]) 
        })]
        [Parameter(ValueFromPipeline)]
        $ArObjWithRef
    )
    process{
        $AUTOSARCollection=Get-CurrentAutoSarCollection
        Get-ArElementRef -ArObjWithRef $ArObjWithRef|Foreach-Object{
            $elementType="AR430.$($_.Dest.ToString())" -as [Type]
            Write-Verbose "Get Element Type Destination: $elementType"
            $content=[System.Array]::CreateInstance($elementType,0)
            $AUTOSARCollection.GetElementsByPath($_.ToString(),[ref]$content)
            if($content.Count -gt 1){
                Write-Error "Get more than 1 item referenced to $($_)"
            }
            elseif($content.Count -eq 0){
                Write-Error "Cannot find $($_)"
            }
            else{
                $content[0]
            }            
        }        
    }
}
function Get-AllEvents{
    process{
        Get-CurrentAutoSarCollection|Find-AllItemsByType -Type ([AR430.TimingEvent]),([AR430.BswTimingEvent])
    }
}

function Select-ArProperty{
    param(
        [Parameter(ValueFromPipeline)]
        [AR430._AR430BaseType]
        $ArObj,
        [Parameter(ValueFromPipelineByPropertyName)]
        $PropertyName,
        [string[]]
        $SelectPropertyName
    )
    process{
        if($PropertyName){
            $finalObj=$ArObj.$PropertyName
            if(-not $finalObj){
                Write-Warning "Null property <$PropertyName> for $ArObj <$($ArObj.GetType())> at $($ArObj.GetAutosarPath())"
                return
            }            
        }
        else{
            $finalObj=$ArObj
        }
        if(-not $finalObj){
            Write-Error "Try to select $SelectPropertyName from Null object"
        }
        else{
            $finalObj.GetType().GetProperties()|Where-Object{
                $_.Name|Select-String -Pattern $SelectPropertyName
            }|ForEach-Object{
                $valueReturn=$_.GetValue($finalObj)
                if(-not $valueReturn){
                    Write-FunctionInfos "Null property $($_.Name) for $ArObj <$($ArObj.GetType())> at $($ArObj.GetAutosarPath())" -ForegroundColor Yellow
                }
                else{
                    return $valueReturn
                }
            }
        }
        
    }
}