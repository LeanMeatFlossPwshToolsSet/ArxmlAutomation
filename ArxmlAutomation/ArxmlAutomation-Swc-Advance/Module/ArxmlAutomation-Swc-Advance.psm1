class PortInstanceInfo{
    [AR430.SwComponentPrototype]$Component
    [AR430._AR430BaseType]$Port
}
function Get-AllConnectors{
    param (
        [Parameter(ValueFromPipeline)]
        [AR430.CompositionSwComponentType]
        $Composition
    )
    process{
        return $Composition|Select-ArProperty -PropertyName Connectors -SelectPropertyName "[a-zA-Z]*SwConnectors"
    }
}
function Show-ConnectionsInfo{
    param (
        [Parameter(ValueFromPipeline)]
        [AR430.CompositionSwComponentType]
        $Composition
    )
    process{
        
        $Composition|Get-AllConnectors|ForEach-Object{
            [PSCustomObject]@{                    
                ProvideComponent="$($_|Select-ArProperty -PropertyName ProviderIref -SelectPropertyName ContextComponentRef|Find-ArElementFromRef).$($_|Select-ArProperty -PropertyName ProviderIref -SelectPropertyName "Target(P|Pr)PortRef"|Find-ArElementFromRef)"
                Requeired="$($_|Select-ArProperty -PropertyName RequesterIref -SelectPropertyName ContextComponentRef|Find-ArElementFromRef).$($_|Select-ArProperty -PropertyName RequesterIref -SelectPropertyName "Target(R|Pr)PortRef"|Find-ArElementFromRef)" 
            }
        }|Format-Table|Out-String|Write-FunctionInfos -Heading "Current Connector Infomrations:" -ForegroundColor Green
    }
}
function Get-UnConnectedRPort{
    [CmdletBinding()]
    [OutputType([PortInstanceInfo[]])]
    param (
        [AR430.CompositionSwComponentType]
        $Composition
    )
    process{
        # list connectors
        $allConnectors=$Composition|Get-AllConnectors
        
        
        $result=$Composition.Components|ForEach-Object{
            $instance=$_
            $type=$_|Find-ArElementFromRef
            $connectedPortInComposition=@()
            $connectedPortInComposition+=$allConnectors|Select-ArProperty -SelectPropertyName "(Requester)Iref"|Where-Object{
                ($_|Select-ArProperty -SelectPropertyName ContextComponentRef) -eq $instance
            }|ForEach-Object{
                $_|Select-ArProperty -SelectPropertyName "Target(R|Pr)PortRef"|Find-ArElementFromRef
            }|Select-Object -Unique
            $type|Select-ArProperty -PropertyName Ports -SelectPropertyName "(Pr|R)PortPrototypes"|Where-Object{
                -not $connectedPortInComposition.Contains($_)
            }|ForEach-Object{
                [PortInstanceInfo]@{
                    Port=$_
                    Component=$instance
                }                
            }
        }
        $result|Format-Table|Out-String|Write-FunctionInfos -Heading "Current Unconnect R Port Infomrations:" -ForegroundColor Green
        return $result
    }
}
function Get-UnConnectedPort {
    [CmdletBinding()]
    [OutputType([PortInstanceInfo[]])]
    param (
        [AR430.CompositionSwComponentType]
        $Composition
    )
    process{
        # list connectors
        $allConnectors=$Composition|Select-ArProperty -PropertyName Connectors -SelectPropertyName "[a-zA-Z]*SwConnectors"

        $allConnectors|ForEach-Object{
            [PSCustomObject]@{                    
                ProvideComponent="$($_|Select-ArProperty -PropertyName ProviderIref -SelectPropertyName ContextComponentRef|Find-ArElementFromRef).$($_|Select-ArProperty -PropertyName ProviderIref -SelectPropertyName "Target(P|Pr)PortRef"|Find-ArElementFromRef)"
                Requeired="$($_|Select-ArProperty -PropertyName RequesterIref -SelectPropertyName ContextComponentRef|Find-ArElementFromRef).$($_|Select-ArProperty -PropertyName RequesterIref -SelectPropertyName "Target(R|Pr)PortRef"|Find-ArElementFromRef)" 
            }
        }|Format-Table|Write-FunctionInfos -Heading "Current Connector Infomrations:" -ForegroundColor Green
        $result=$Composition.Components|ForEach-Object{
            $instance=$_
            $type=$_|Find-ArElementFromRef
            $connectedPortInComposition=@()
            $connectedPortInComposition+=$allConnectors|Select-ArProperty -SelectPropertyName "(Requester|Provider)Iref"|Where-Object{
                ($_|Select-ArProperty -SelectPropertyName ContextComponentRef) -eq $instance
            }|ForEach-Object{
                $_|Select-ArProperty -SelectPropertyName "Target(R|Pr|P)PortRef"|Find-ArElementFromRef
            }|Select-Object -Unique
            $type|Select-ArProperty -PropertyName Ports -SelectPropertyName "(P|Pr|R)PortPrototypes"|Where-Object{
                -not $connectedPortInComposition.Contains($_)
            }|ForEach-Object{
                [PortInstanceInfo]@{
                    Port=$_
                    Component=$instance
                }                
            }
        }
        $result|Format-Table|Out-String|Write-FunctionInfos -Heading "Current Unconnect ports Infomrations:" -ForegroundColor Green
        return $result
    }
}
function Connect-PortAutomation{
    param (
        [Parameter(ValueFromPipeline)]
        [PortInstanceInfo]
        $SourcePortInstanceInfo
    )
    begin{
        $ConnectionInfos=@()
    }
    process{
        $ConnectionInfos+=@{
            SourceInfo=$SourcePortInstanceInfo
        }
        $targetPortInfo=(& $Global:ArxmlAutomationConfig."Find-PortMatched" -SourceSWComponent $SourcePortInstanceInfo.Component -SourcePort $SourcePortInstanceInfo.Port)|ForEach-Object{
            [PortInstanceInfo]$_
        }
        if($targetPortInfo){
            $ConnectionInfos[-1].TargetInfo=$targetPortInfo
            New-AssemblySWConnector -RequestComponent $SourcePortInstanceInfo.Component  -RequestPort $SourcePortInstanceInfo.Port -ProvideComponent $targetPortInfo.Component -ProvidePort $targetPortInfo.Port|
                Update-ReferrableItemToCollection -Container $SourcePortInstanceInfo.Component._AutosarParent
             
        }
        else{
            Write-FunctionInfos "No sepecify connection find for $($SourcePortInstanceInfo.Component).$($SourcePortInstanceInfo.Port)" -ForegroundColor Yellow
        }
    }
    end{
        $ConnectionInfos|ForEach-Object{[PSCustomObject]$_}|Format-Table `
        @{Label="Source";Expression={"$($_.SourceInfo.Component).$($_.SourceInfo.Port)"}},
        @{Label="Target";Expression={if($_.TargetInfo){"$($_.TargetInfo.Component).$($_.TargetInfo.Port)"}else{""}}}
        |Out-String|Write-FunctionInfos -Heading "Automation Port Connection Infos"
    }
}