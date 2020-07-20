[CmdletBinding()]
param(  
    [Alias("c")]
    [switch] $Continuous
)

$currentDirectory = Get-Location
Set-Location $PSScriptRoot

. ./Functions.ps1

$loggingPrefix = "ContentReactor Events Test Unit"

if ($Continuous) {
    $testJob = Start-Job -Name "test-continuous" -ScriptBlock {
        $loggingPrefix = $args[0]
        . ./Functions.ps1
        Write-EdenBuildInfo "Running unit tests continuously." $loggingPrefix
        dotnet watch --project ./../Library.Tests/ContentReactor.Events.Tests.csproj test `
            --filter TestCategory!=Automated `
            /p:CollectCoverage=true `
            /p:CoverletOutput=TestResults/ `
            /p:CoverletOutputFormat=lcov `
            /p:Include="[ContentReactor.Events.*]*" `
            /p:Threshold=80 `
            /p:ThresholdType=line `
            /p:ThresholdStat=total
    } -ArgumentList @($loggingPrefix)

    # Change the default behavior of CTRL-C so that the script can intercept and use it versus just terminating the script.
    [Console]::TreatControlCAsInput = $True
    # Sleep for 1 second and then flush the key buffer so any previously pressed keys are discarded and the loop can monitor for the use of
    #   CTRL-C. The sleep command ensures the buffer flushes correctly.
    # $Host.UI.RawUI.FlushInputBuffer()

    # Continue to loop while there are pending or currently executing jobs.
    While ($testJob) {
        # If a key was pressed during the loop execution, check to see if it was CTRL-C (aka "3"), and if so exit the script after clearing
        #   out any running jobs and setting CTRL-C back to normal.
        If ($Host.UI.RawUI.KeyAvailable -and ($Key = $Host.UI.RawUI.ReadKey("AllowCtrlC,NoEcho,IncludeKeyUp"))) {
            If ([Int]$Key.Character -eq 3) {
                Write-Warning "CTRL-C was used - Shutting down any running jobs before exiting the script."
                Write-EdenBuildInfo "Shutting down testing job." $loggingPrefix
                Get-Job | Where-Object {$_.Name -like "test-continuous"} | Remove-Job -Force -Confirm:$False
                [Console]::TreatControlCAsInput = $False
                exit
            }
            # Flush the key buffer again for the next loop.
            # $Host.UI.RawUI.FlushInputBuffer()
        }

        $testJob | Receive-Job
        # Perform other work here such as process pending jobs or process out current jobs.
    }
}
else {
    $verbose = $VerbosePreference -ne [System.Management.Automation.ActionPreference]::SilentlyContinue
    $testJob = Start-Job -Name "test-continuous" -ScriptBlock {
        $loggingPrefix = $args[0]
        . ./Functions.ps1
        $command = @"
        dotnet test ./../Library.Tests/ContentReactor.Events.Tests.csproj ``
            --logger "trx;logFileName=testResults.trx" ``
            --filter TestCategory!=Automated ``
            /p:CollectCoverage=true ``
            /p:CoverletOutput=TestResults/ ``
            /p:CoverletOutputFormat=lcov ``
            /p:Include=`"[ContentReactor.Events.*]*`" ``
            /p:Threshold=80 ``
            /p:ThresholdType=line ``
            /p:ThresholdStat=total 
"@
        if ($args[1]) {
            Invoke-BuildCommand $command $loggingPrefix "Running unit tests." -Verbose
        } else {
            Invoke-BuildCommand $command $loggingPrefix "Running unit tests."
        }
    } -ArgumentList @($loggingPrefix, $verbose)

    While ($testJob.State -eq "Running") {
        $testJob | Receive-Job
    }
    $testJob | Receive-Job
    Write-EdenBuildInfo "Finished running unit tests." $loggingPrefix
}

Set-Location $currentDirectory
