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

        Write-BuildInfo "Deploying the application from '$apiFilePath' to group '$resourceGroupName', app '$apiName' on the staging slot." $loggingPrefix
    
        Invoke-CommandDeployApp `
            -ServiceName $serviceName `
            -InstanceName $instanceName `
            -TenantId $tenantId `
            -Region $region
    
    }
    catch {
        Write-BuildError "Exception thrown while executing the automated tests. Message: '$($_.Exception.Message)'" $LoggingPrefix
        throw $_        
    }
}