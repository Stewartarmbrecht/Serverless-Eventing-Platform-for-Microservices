Set-Location $PSScriptRoot
Import-Module ./PowerShell/Eden/Eden.psm1 -Force
Set-Location "$PSScriptRoot/ContentReactor/Audio"
Set-EdenEnvConfig -Load "creactd001"

# Set-Location "./Service"

# Write-EdenBuildInfo "Fetching the app settings from azure." $LoggingPrefix
# func azure functionapp fetch-app-settings "creactd001-audio"

# Write-EdenBuildInfo "Adding the run time setting for 'dotnet'." $LoggingPrefix
# func settings add "FUNCTIONS_WORKER_RUNTIME" "dotnet"

# Write-EdenBuildInfo "Adding the run time port setting for '7071'." $LoggingPrefix
# func settings add "Host.LocalHttpPort" "7071"

# Set-Location "../"