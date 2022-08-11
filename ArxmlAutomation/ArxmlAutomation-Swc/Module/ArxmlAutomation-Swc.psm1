function Set-AssemblySWConnector {
    param (
        [AR430.SwComponentPrototype]
        $ProvideComponent,
        [ValidateScript({
            $_|Assert-ArObjType ([AR430.PPortPrototype],[AR430.PRPortPrototype])
        })]
        [AR430._AR430BaseType]
        $ProvidePort,
        [AR430.SwComponentPrototype]
        $RequestComponent,
        [ValidateScript({
            $_|Assert-ArObjType ([AR430.RPortPrototype],[AR430.PRPortPrototype])
        })]
        [AR430._AR430BaseType]
        $RequestPort
    )
    process{
        $AutoSarCollection=Get-CurrentAutoSarCollection
        # create reference
        Confirm-SameArObjContainer -Items $ProvideComponent,$RequestComponent -Depth 1
        # confirm interface types
        $ProvidePort
        $AssemblyConnector=[AR430.AssemblySwConnector]::new()
        $AssemblyConnector|New-PropertyFactory -PropertyName ProviderIref -Process {
            $_|New-ReferenceProperty -ReferenceItem $ProvideComponent -PropertyName ContextComponentRef
            $_|New-ReferenceProperty -ReferenceItem $ProvideComponent -PropertyName TargetPPortRef
        }
        $AssemblyConnector|New-PropertyFactory -PropertyName RequesterIref -Process {
            $_|New-ReferenceProperty -ReferenceItem $RequestComponent -PropertyName ContextComponentRef
            $_|New-ReferenceProperty -ReferenceItem $ProvideComponent -PropertyName TargetRPortRef
        }
        Invoke-Expression -Command $Global:ArxmlAutomationConfig["Set-AssemblySWConnectorShortName"] -AssemblySwConnector $AssemblyConnector
        $ProvideComponent._AutosarParent|Assert-ArObjType -AssertType ([AR430.CompositionSwComponentType])|ForEach-Object{
            $_.Connectors.AssemblySwConnectors
        }
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