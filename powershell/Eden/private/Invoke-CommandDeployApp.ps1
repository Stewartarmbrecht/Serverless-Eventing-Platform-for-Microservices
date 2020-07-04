function Invoke-CommandDeployApp
{
    [CmdletBinding()]
    param(
        [EdenEnvConfig]$EdenEnvConfig
    ) 
    $resourceGroupName = "$($EdenEnvConfig.EnvironmentName)-$($EdenEnvConfig.ServiceName)".ToLower()
    $apiName = "$($EdenEnvConfig.EnvironmentName)-$($EdenEnvConfig.ServiceName)".ToLower()
    $apiFilePath = "./.dist/app.zip"

    $result = Publish-AzWebApp `
        -ResourceGroupName $resourceGroupName `
        -Name $apiName `
        -Slot Staging `
        -ArchivePath $apiFilePath `
        -Force
    if ($VerbosePreference -ne 'SilentlyContinue') { $result }
}

