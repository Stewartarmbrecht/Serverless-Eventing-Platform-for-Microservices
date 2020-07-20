[CmdletBinding()]
param(
)

$currentDirectory = Get-Location
Set-Location $PSScriptRoot

. ./Functions.ps1

$loggingPrefix = "ContentReactor Setup Solution"


# Install Tools

# Run a separate PowerShell process because the script calls exit, so it will end the current PowerShell session.
if($IsWindows -and $false) {
    Write-EdenBuildInfo "Installing dotnet core." $loggingPrefix
    &powershell -NoProfile -ExecutionPolicy unrestricted -Command "[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; &([scriptblock]::Create((Invoke-WebRequest -UseBasicParsing 'https://dot.net/v1/dotnet-install.ps1'))) -Channel LTS"
    Write-EdenBuildInfo "Installing git." $loggingPrefix
    winget install -e --name Git
    Write-EdenBuildInfo "Installing Visual Studio Code." $loggingPrefix
    winget install -q vscode
    Write-EdenBuildInfo "Installing Azure Powershell Module." $loggingPrefix
    Install-Module -Name Az -AllowClobber -Scope CurrentUser
    Write-EdenBuildInfo "Installing Azure Release Management (ARM) Module." $loggingPrefix
    Install-Module -Name AzureRm -AllowClobber -Scope CurrentUser
    Write-EdenBuildInfo "Installing Asure CLI." $loggingPrefix
    Invoke-WebRequest -Uri https://aka.ms/installazurecliwindows -OutFile .\AzureCLI.msi; Start-Process msiexec.exe -Wait -ArgumentList '/I AzureCLI.msi /quiet'; rm .\AzureCLI.msi
    Write-EdenBuildInfo "Installing Node.js." $loggingPrefix
    winget install openjs.nodejs
    Write-EdenBuildInfo "Installing Azure Functions Core Tools." $loggingPrefix
    npm install -g azure-functions-core-tools@3
    Set-Location "$env:USERPROFILE\AppData\Roaming\npm\node_modules\azure-functions-core-tools\"
    npm install unzipper@0.10.7
    node .\lib\install.js
    Set-Location $PSScriptRoot
}


# Setup Development Environment

./Configure-Environment.ps1

## Setup Cloud Environment
Connect-AzureServicePrincipal $loggingPrefix

## Invoke Pipelines
$Env:InstanceName = $Env:DevInstanceName

./../Events/Pipeline/Invoke-Pipeline.ps1

Start-EdenJob "Audio-Pipeline" "./../Audio/Pipeline/Invoke-Pipeline.ps1"
#./../category/pipeline/Invoke-Pipeline.ps1
#./../text/pipeline/Invoke-Pipeline.ps1
#./../image/pipeline/Invoke-Pipeline.ps1

# Change the default behavior of CTRL-C so that the script can intercept and use it versus just terminating the script.
[Console]::TreatControlCAsInput = $True

While(Get-Job -State "Running")
{
    Get-Job | Receive-Job

    # Sleep for 1 second and then flush the key buffer so any previously pressed keys are discarded and the loop can monitor for the use of
    #   CTRL-C. The sleep command ensures the buffer flushes correctly.
    # $Host.UI.RawUI.FlushInputBuffer()
    Start-Sleep -Seconds 1
    # If a key was pressed during the loop execution, check to see if it was CTRL-C (aka "3"), and if so exit the script after clearing
    #   out any running jobs and setting CTRL-C back to normal.
    If ($Host.UI.RawUI.KeyAvailable -and ($Key = $Host.UI.RawUI.ReadKey("AllowCtrlC,NoEcho,IncludeKeyUp"))) {
        If ([Int]$Key.Character -eq 3) {
            Write-Warning "CTRL-C was used - Shutting down any running jobs before exiting the script."
            Write-EdenBuildInfo "Stopping and removing jobs." $loggingPrefix
            Stop-Job rt-*
            Remove-Job rt-*
            Write-EdenBuildInfo "Stopped." $loggingPrefix
            [Console]::TreatControlCAsInput = $False
        }
        # Flush the key buffer again for the next loop.
        # $Host.UI.RawUI.FlushInputBuffer()
    }
}

Get-Job | Receive-Job

./../Api/pipeline/Invoke-Pipeline.ps1
#./../Web/pipeline/Invoke-Pipeline.ps1
#./../Health/Pipeline/Invoke-Pipeline.ps1

## Setup LocalEnvironments

# Setup Code Repository

# Setup Production Environment

# Setup Production Pipeline

# Test Production Pipeline

Set-Location $currentDirectory
