function Invoke-StagingSwap
{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$TRUE)]
        [String]$InstanceName,
        [Parameter(Mandatory=$TRUE)]
        [String]$ServiceName,
        [Parameter(Mandatory=$TRUE)]
        [String]$LoggingPrefix
    )

    try {
        $resourceGroupName = "$InstanceName-$ServiceName".ToLower()
        $apiName = "$InstanceName-$ServiceName".ToLower()

        Write-EdenBuildInfo "Switching the '$resourceGroupName/$apiName' azure functions app staging slot with production." $LoggingPrefix
        
        $result = Switch-AzWebAppSlot -SourceSlotName "Staging" -DestinationSlotName "Production" -ResourceGroupName $resourceGroupName -Name $apiName
        if ($VerbosePreference -ne 'SilentlyContinue') { $result }
    }
    catch {
        Write-EdenBuildError "Exception thrown while executing the automated tests. Message: '$($_.Exception.Message)'" $LoggingPrefix
        throw $_        
    }
}