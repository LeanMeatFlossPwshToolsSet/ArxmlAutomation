function Set-AssemblySWConnector {
    param (
        [AR430.SwComponentPrototype]
        $ProvideComponent,
        [AR430.PPortPrototype]
        $ProvidePort,
        [AR430.SwComponentPrototype]
        $RequestComponent,
        [AR430.RPortPrototype]
        $RequestPort,
        [AR430.AUTOSARCollection]
        $AutoSarCollection
    )
    process{
        # create reference
        $AssemblyConnector=[AR430.AssemblySwConnector]::new()
        $AssemblyConnector|New-PropertyFactory -PropertyName ProviderIref -Process {
            $_|New-ReferenceProperty -ReferenceItem $ProvideComponent -PropertyName ContextComponentRef
            $_|New-ReferenceProperty -ReferenceItem $ProvideComponent -PropertyName TargetPPortRef
        }
        $AssemblyConnector|New-PropertyFactory -PropertyName RequesterIref -Process {
            $_|New-ReferenceProperty -ReferenceItem $RequestComponent -PropertyName ContextComponentRef
            $_|New-ReferenceProperty -ReferenceItem $ProvideComponent -PropertyName TargetRPortRef
        }
        Invoke-Expression -Command $Global:ArxmlAutomationConfig["Set-AssemblySWConnectorShortName"] -AssemblySwConnector $AssemblyConnector -AutoSarCollection $AutoSarCollection
        ($ProvideComponent|Find-ArElementFromRef)._AutosarParent
        ($RequestComponent|Find-ArElementFromRef)._AutosarParent
    }
    
}
function Confirm-AssemblySWConnector{
    param(
        [AR430.AssemblySwConnector]
        $AssemblySwConnector,
        [AR430.AUTOSARCollection]
        $AutoSarCollection
    )
    process{

    }
}
function Confirm-AssemblySWConnector-Rules-InterfaceShallMatch{
    param(
        [AR430.AssemblySwConnector]
        $AssemblySwConnector,
        [AR430.AUTOSARCollection]
        $AutoSarCollection
    )
    process{

    }
}