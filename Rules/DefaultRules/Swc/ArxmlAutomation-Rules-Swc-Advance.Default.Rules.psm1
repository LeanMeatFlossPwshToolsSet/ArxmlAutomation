Import-Module ArxmlAutomation-Swc
function Set-AssemblySWConnectorShortName{
    param(
        [AR430.AssemblySwConnector]
        $AssemblySwConnector
    )
    process{
        # default naming rule
        # <P_ComponentName>_<PortName>_<R_ComponentName>_<PortName>
        $P_Component=$AssemblySwConnector.ProviderIref.ContextComponentRef|Find-ArElementFromRef 
        $P_Port=$AssemblySwConnector.ProviderIref.TargetPPortRef|Find-ArElementFromRef 
        $R_Component=$AssemblySwConnector.RequesterIref.ContextComponentRef|Find-ArElementFromRef 
        $R_Port=$AssemblySwConnector.RequesterIref.TargetRPortRef|Find-ArElementFromRef
        return "$($P_Component)_$($P_Port)_$($R_Component)_$($R_Port)"
    }
}
function Confirm-AssemblySWConnector{
    param(
        [AR430.AssemblySwConnector]
        $AssemblySwConnector
    )
    process{
        return true
    }
}
function Find-PortMatched{
    <#
    .SYNOPSIS
        Default Rule for Find Matched Port
    .DESCRIPTION
        This function will try to find the matched port by
        1. R port(or R in PR port) need to be connected to the P port with the same interface.
        If match not find, will return nothing.
        If match find, we will return a object containing two properties:
        TargetComponent
        TargetPort

    .NOTES
        Information or caveats about the function e.g. 'This function is not supported in Linux'
    .LINK
        Specify a URI to a help page, this will show when Get-Help -Online is used.
    .EXAMPLE
        Test-MyTestFunction -Verbose
        Explanation of the function or its result. You can include multiple examples with additional .EXAMPLE lines
    #>
    [CmdletBinding()]
    [OutputType([PortInstanceInfo])]
    param (
        [AR430.SwComponentPrototype]
        $SourceSWComponent,
        [AR430._AR430BaseType]
        $SourcePort
    )
    process{
        if($SourcePort|Assert-ArObjType -AssertType "(R|Pr)PortPrototype" -Ignore){
            $SourceSWComponent._AutosarParent|Assert-ArObjType -AssertType CompositionSwComponentType|Select-ArProperty -SelectPropertyName Components|ForEach-Object{
                $componentInstance=$_
                $componentType=$_|Find-ArElementFromRef 
                $componentType|Select-ArProperty -PropertyName Ports -SelectPropertyName "(Pr|P)PortPrototypes"|Where-Object{
                    # get interface
                    ($_|Find-ArElementFromRef ) -eq ($SourcePort|Find-ArElementFromRef)
                }|ForEach-Object{
                    Write-Host "The port $_ of $componentInstance match the port $SourcePort of $SourceSWComponent"
                    return [PSCustomObject]@{
                        TargetComponent=$componentInstance
                        TargetPort = $_
                    }
                }|Select-Object -First 1
            }
        }
        
        # find all interface that match $SourcePort interface 
        # $SourcePort|Find-ArElementFromRef|Assert-ArObjType []
    }
}