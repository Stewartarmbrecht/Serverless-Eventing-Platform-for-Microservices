function Invoke-EdenServiceLocalEnvironmentSetup
{
    [CmdletBinding()]
    param( 
        [String]$serviceName,
        [String]$systemName,
        [Int]$port
    )
    $loggingPrefix = "$systemName $serviceName Setup"

    $serviceTypes = "api","worker"

    foreach ($serviceType in $serviceTypes) {
        
        $currentDirectory = Get-Location
    
        $serviceDirectory = "./$serviceName/$serviceType"
    
        if(Test-Path $serviceDirectory -PathType Container)
        {
            if ($serviceType -eq "worker")
            {
                $port = $port + 1
            }
            Set-Location $serviceDirectory
            ExecuteCommand "func azure functionapp fetch-app-settings $systemName-$serviceName-$serviceType" $loggingPrefix "Fetching the API app settings from azure."
            ExecuteCommand "func settings add ""FUNCTIONS_WORKER_RUNTIME"" ""dotnet""" $loggingPrefix "Adding the service run time setting for 'dotnet'."
            ExecuteCommand "func settings add ""Host.LocalHttpPort"" ""$port""" $loggingPrefix "Adding the service run time port setting for '$port'."
            Set-Location $currentDirectory
        }
    }
}
