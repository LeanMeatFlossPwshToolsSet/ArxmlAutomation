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
function Add-ItemToProperty{
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
        $finalType=$type.GetElementType()
        $NewItem=New-Object -TypeName $finalType
        if($Process){
            $NewItem|Foreach-Object -Process $Process
        }  
        $Item.$PropertyName+=$NewItem            
        return $NewItem
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
function Add-ItemPropertyFactory{

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
function Add-ReferrableSubItemsToCollection{
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
    [OutputType([AR430.AutoSar])]
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
        [Parameter(ValueFromPipeline,ParameterSetName="AUTOSARCollection")]
        [AR430.AUTOSARCollection]
        $AUTOSARCollection,
        [Parameter(ValueFromPipeline,ParameterSetName="AUTOSAROBJ")]
        [AR430._AR430BaseType]
        $AUTOSARObj,
        [System.Type[]]
        $Type
    )
    process{
        $Type|Foreach-Object{
            $content=[System.Array]::CreateInstance($_,0)
            if($PSCmdlet.ParameterSetName -eq "AUTOSARCollection"){
                $AUTOSARCollection.GetElementArrayByType([ref]$content)
            }
            else{
                $AUTOSARObj.GetElementArrayByType([ref]$content)
            }
            $content
        }
        
    }
}
function Get-ArElementRef{
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline)]
        [AR430._AR430BaseType]
        $ArObjWithRef
    )
    process{
        # get potential ref objects
        if($ArObjWithRef -is [AR430.Ref]){
            return $ArObjWithRef
        }
        else{
            $ArObjWithRef.GetType().GetProperties()|Where-Object{
                $_.PropertyType.BaseType -eq [AR430.Ref]
            }|ForEach-Object{
                $_.GetValue($ArObjWithRef)                
            }
        }
        
    }
}
function Find-ArElementFromRef{
    [CmdletBinding()]
    param(
        [Parameter(ParameterSetName="AUTOSARCollection")]
        [AR430.AUTOSARCollection]
        $AUTOSARCollection,
        [Parameter(ParameterSetName="AUTOSAROBJ")]
        [AR430._AR430BaseType]
        $AUTOSARObj,
        [Parameter(ValueFromPipeline)]
        [AR430._AR430BaseType]
        $ArObjWithRef
    )
    process{
        Get-ArElementRef -ArObjWithRef $ArObjWithRef|Foreach-Object{
            $elementType="AR430.$($_.Dest.ToString())" -as [Type]
            Write-Verbose "Get Element Type Destination: $elementType"
            $content=[System.Array]::CreateInstance($elementType,0)
            if($PSCmdlet.ParameterSetName -eq "AUTOSARCollection"){
                $AUTOSARCollection.GetElementsByPath($_.ToString(),[ref]$content)
            }
            else{
                $AUTOSARObj.GetElementsByPath($_.ToString(),[ref]$content)
            }
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
    param(
        # Parameter help description
        [Parameter(ValueFromPipeline)]
        [AR430.AUTOSARCollection]
        $AUTOSARCollection
    )
    process{
        $AUTOSARCollection|Find-AllItemsByType -Type ([AR430.TimingEvent]),([AR430.BswTimingEvent])
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
                    Write-Host "Null property $($_.Name) for $ArObj <$($ArObj.GetType())> at $($ArObj.GetAutosarPath())" -ForegroundColor Yellow
                }
                else{
                    return $valueReturn
                }
            }
        }
        
    }
}