# Run a separate PowerShell process because the script calls exit, so it will end the current PowerShell session.
[CmdletBinding()]
param(
    $EdenEnvConfig,
    [String] $LoggingPrefix
)
try {
    if($IsWindows) {

        $currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
        $isRunningAsAdmin = $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
        if (!$isRunningAsAdmin) {
            throw "You must run this script as an administrator.  Please restart powershell as an administrator."
        }

        Write-EdenBuildInfo "Installing dotnet core." $LoggingPrefiz
        &powershell -NoProfile -ExecutionPolicy unrestricted -Command "[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; &([scriptblock]::Create((Invoke-WebRequest -UseBasicParsing 'https://dot.net/v1/dotnet-install.ps1'))) -Channel LTS"
        
        Write-EdenBuildInfo "Installing git." $LoggingPrefix
        winget install -e --name Git
        
        Write-EdenBuildInfo "Installing Visual Studio Code." $LoggingPrefix
        winget install -q vscode
        
        Write-EdenBuildInfo "Installing Azure Powershell Module." $LoggingPrefix
        Install-Module -Name Az -AllowClobber -Scope CurrentUser
        
        Write-EdenBuildInfo "Installing Azure Release Management (ARM) Module." $LoggingPrefix
        Install-Module -Name AzureRm -AllowClobber -Scope CurrentUser
        
        Write-EdenBuildInfo "Installing Asure CLI." $LoggingPrefix
        Invoke-WebRequest -Uri https://aka.ms/installazurecliwindows -OutFile .\AzureCLI.msi; Start-Process msiexec.exe -Wait -ArgumentList '/I AzureCLI.msi /quiet'; rm .\AzureCLI.msi
        
        Write-EdenBuildInfo "Installing Node.js." $LoggingPrefix
        winget install openjs.nodejs
        
        Write-EdenBuildInfo "Adding Node.js to the path." $LoggingPrefix
        $env:Path += ";C:\Program Files\nodejs" 
        $oldpath = (Get-ItemProperty -Path 'Registry::HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\Session Manager\Environment' -Name PATH).path
        $newpath = "$oldpath;c:\Program Files\nodejs"
        Set-ItemProperty -Path 'Registry::HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\Session Manager\Environment' -Name PATH -Value $newPath

        Write-EdenBuildInfo "Adding Node.js to the path." $LoggingPrefix
        npm config set prefix 'C:\Program Files\nodejs'

        Write-EdenBuildInfo "Installing Azure Functions Core Tools." $LoggingPrefix
        npm install -g azure-functions-core-tools@3
        Set-Location "$env:USERPROFILE\AppData\Roaming\npm\node_modules\azure-functions-core-tools\"
        npm install unzipper@0.10.7
        node .\lib\install.js
        Set-Location $PSScriptRoot
    }
} catch {
    $message = $_.Exception.Message
    Write-EdenBuildError "Failed to execute tools installation: '$message'." $LoggingPrefix
    return $FALSE
}