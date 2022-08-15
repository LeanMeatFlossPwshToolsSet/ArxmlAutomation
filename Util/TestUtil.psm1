function Add-TypedArgumentInput{
    param(
        [parameter(ValueFromPipeline)]
        [hashtable]
        $UpperParams,
        [type[]]
        $TypesToAppend,
        [string]
        $ParameterName
    )
    process{
        $TypesToAppend|Foreach-Object{
            $forkItem=$UpperParams.Clone()
            $forkItem.$ParameterName=New-Object -TypeName $_.FullName
            return $forkItem
        }
    }
}