function New-AssemblySWConnector {
    param (
        [AR430.SwComponentPrototype]
        $ProvideComponent,
        [ValidateScript({
            $_|Assert-ArObjType ([AR430.PPortPrototype],[AR430.PRPortPrototype]) 
        },ErrorMessage="ProvidePort shall be [AR430.PPortPrototype],[AR430.PRPortPrototype]")]
        [AR430._AR430BaseType]
        $ProvidePort,
        [AR430.SwComponentPrototype]
        $RequestComponent,
        [ValidateScript({
            $_|Assert-ArObjType ([AR430.RPortPrototype],[AR430.PRPortPrototype]) 
        },ErrorMessage="RequirePort shall be [AR430.RPortPrototype],[AR430.PRPortPrototype]")]
        [AR430._AR430BaseType]
        $RequestPort
    )
    process{
        # create reference
        Confirm-SameArObjContainer -Items $ProvideComponent,$RequestComponent -Depth 1
        # confirm interface types
        $AssemblyConnector=[AR430.AssemblySwConnector]::new()
        $AssemblyConnector|New-PropertyFactory -PropertyName ProviderIref -Process {
            $_|New-ReferenceProperty -ReferenceItem $ProvideComponent -PropertyName ContextComponentRef
            $_|New-ReferenceProperty -ReferenceItem $ProvidePort -PropertyName TargetPPortRef
        }
        $AssemblyConnector|New-PropertyFactory -PropertyName RequesterIref -Process {
            $_|New-ReferenceProperty -ReferenceItem $RequestComponent -PropertyName ContextComponentRef
            $_|New-ReferenceProperty -ReferenceItem $RequestPort -PropertyName TargetRPortRef
        }
        Invoke-ConfigCommand -FunctionToInvoke "Set-AssemblySWConnectorShortName" -Arguments @{
            AssemblySwConnector=$AssemblyConnector
        }
        return $AssemblyConnector
    }
    
}
function Confirm-AssemblySWConnector{
    param(
        [AR430.AssemblySwConnector]
        $AssemblySwConnector
    )
    process{

    }
}
function Confirm-AssemblySWConnectorRulesInterfaceShallMatch{
    param(
        [AR430.AssemblySwConnector]
        $AssemblySwConnector
    )
    process{

    }
}