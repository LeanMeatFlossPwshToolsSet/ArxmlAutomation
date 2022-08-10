# This script is a example for the component port connection in composition
&"$PSScriptRoot\Examples.EnvironmentSetup.ps1"
$ErrorActionPreference="Break"
Import-Module ArxmlAutomation-Swc -Force
Import-Module ArxmlAutomation-Swc-Advance -Force
$autoSARCollection=Get-AUTOSARCollection -FilePaths (Get-ChildItem "../ExampleResouces/SWComponentAndComposition" -Filter "*.arxml" -Recurse)
$compositionDest=$autoSARCollection|Find-AllItemsByType -Type ([AR430.CompositionSwComponentType])|Where-Object {
    $_.GetAutosarPath().Equals("/ComponentTypes/Implementation")
}
$referencedComponents=$compositionDest|Find-AllItemsByType -Type ([AR430.SwComponentPrototype])
$referencedComponents|ForEach-Object{
    # find connected port in connectors
    $ConnectedInfos=@()
    if($compositionDest.Connectors -and $compositionDest.Connectors.AssemblySwConnector){
        $ConnectedInfos+=$compositionDest.Connectors.AssemblySwConnectors|Foreach-Object{
            if(($_.ProviderIref.ContextComponentRef|Find-ArElementFromRef -AUTOSARCollection $autoSARCollection)-eq $_){
                @{
                    Port=$_.ProviderIref.TargetPPortRef|Find-ArElementFromRef -AUTOSARCollection $autoSARCollection
                    PortDirection="P"
                    ConnectTo=$_.RequesterIref.ContextComponentRef|Find-ArElementFromRef
                    ConnectToPort=$_.RequesterIref.TargetRPortRef|Find-ArElementFromRef -AUTOSARCollection $autoSARCollection
                }
            }
            elseif(($_.RequesterIref.ContextComponentRef|Find-ArElementFromRef -AUTOSARCollection $autoSARCollection)-eq $_){
                @{
                    Port=$_.ProviderIref.TargetPPortRef|Find-ArElementFromRef -AUTOSARCollection $autoSARCollection
                    PortDirection="R"
                    ConnectTo=$_.RequesterIref.ContextComponentRef|Find-ArElementFromRef
                    ConnectToPort=$_.RequesterIref.TargetRPortRef|Find-ArElementFromRef -AUTOSARCollection $autoSARCollection
                }
            }
        }
    }
    # filter unconnected port for the component
    $ConnectedInfos+=$_|Find-ArElementFromRef -AUTOSARCollection $autoSARCollection|ForEach-Object {
        $_.Ports.PPortPrototypes|Where-Object{
            if($ConnectedInfos.Count -gt 0){
                -not ($ConnectedInfos|Select-Object -ExpandProperty Port).Contains($_)
            }
            else{
                return $true
            }
            
        }|Foreach-Object{
            @{
                Port=$_
                PortDirection="P"
                ConnectTo=$null
                ConnectToPort=$null
            }
        }
        $_.Ports.RPortPrototypes|Where-Object{
            if($ConnectedInfos.Count -gt 0){
                -not ($ConnectedInfos|Select-Object -ExpandProperty Port).Contains($_)
            }
            else{
                return $true
            }
        }|Foreach-Object{
            @{
                Port=$_
                PortDirection="R"
                ConnectTo=$null
                ConnectToPort=$null
            }
        }
    }
    Write-Host "Raw Connection Info for $_" -BackgroundColor Green
    $ConnectedInfos|Foreach-Object {[PSCustomObject]$_}|Format-Table -AutoSize|Out-String|Write-Host
    # Find port by interfaces
    $ConnectedInfos|Where-Object{-not $_.ConnectToPort}|ForEach-Object{
        # search interface from components
        # assume the interface shall be one to one mapping.
        $compositionDest.Components|ForEach-Object{

        }
    }
}

Get-UnConnectedPort -AutoSarCollection $autoSARCollection -Composition $compositionDest
# $referencedComponents|Find-ArElementFromRef -AUTOSARCollection $autoSARCollection|ForEach-Object{
#     $_.Ports
# }

# The rule is list all the port and unconnected port in the composition