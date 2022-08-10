class UnConnectedPortInComposition{
    [AR430.SwComponentPrototype]$Component
    [AR430._AR430BaseType]$Port
}
function Get-UnConnectedPort {
    [OutputType([UnConnectedPortInComposition[]])]
    param (
        [AR430.CompositionSwComponentType]
        $Composition,
        [AR430.AUTOSARCollection]
        $AutoSarCollection
    )
    process{
        # list connectors
        $allConnectors=$Composition|Select-ArProperty -PropertyName Connectors -SelectPropertyName "[a-zA-Z]*SwConnectors"
        Write-Host "Current Connector Infomrations:" -ForegroundColor Green
        if($allConnectors -and $allConnectors.Count -gt 0){
            $allConnectors|ForEach-Object{
                [PSCustomObject]@{                    
                    ProvideComponent="$($_|Select-ArProperty -PropertyName ProviderIref -SelectPropertyName ContextComponentRef|Find-ArElementFromRef).$($_|Select-ArProperty -PropertyName ProviderIref -SelectPropertyName "Target(P|Pr)PortRef"|Find-ArElementFromRef)"
                    Requeired="$($_|Select-ArProperty -PropertyName RequesterIref -SelectPropertyName ContextComponentRef|Find-ArElementFromRef).$($_|Select-ArProperty -PropertyName RequesterIref -SelectPropertyName "Target(R|Pr)PortRef"|Find-ArElementFromRef)" 
                }
            }|Format-Table|Write-Host
        }
        else{
            Write-Host "No connection avaliable at current version `n" -ForegroundColor Yellow
        }
        Write-Host "Current Unconnect ports Infomrations:" -ForegroundColor Green
        $Composition.Components|ForEach-Object{
            $instance=$_
            $type=$_|Find-ArElementFromRef -AUTOSARCollection $AutoSarCollection
            $connectedPortInComposition=@()
            $connectedPortInComposition+=$allConnectors|Select-ArProperty -SelectPropertyName "(Requester|Provider)Iref"|Where-Object{
                ($_|Select-ArProperty -SelectPropertyName ContextComponentRef) -eq $instance
            }|ForEach-Object{
                $_|Select-ArProperty -SelectPropertyName "Target(R|Pr|P)PortRef"|Find-ArElementFromRef -AUTOSARCollection $AutoSarCollection
            }|Select-Object -Unique
            $type|Select-ArProperty -PropertyName Ports -SelectPropertyName "(P|Pr|R)PortPrototypes"|Where-Object{
                -not $connectedPortInComposition.Contains($_)
            }|ForEach-Object{
                [UnConnectedPortInComposition]@{
                    Port=$_
                    Component=$instance
                }                
            }
        }|Tee-Object -Variable result|Format-Table|Out-String|Write-Host
        return $result
    }    
}