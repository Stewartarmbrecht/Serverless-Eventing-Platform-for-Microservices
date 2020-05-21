function Invoke-EdenServiceTest
{
    [CmdletBinding()]
    param( 
        [Parameter(Mandatory=$true)]
        [String]$serviceName,
        [Parameter(Mandatory=$true)]
        [String]$solutionName,
        [Parameter(Mandatory=$true)]
        [String]$systemName,
        [Alias("c")]
        [switch] $continuous
    )

    $location = Get-Location

    $loggingPrefix = "$systemName $serviceName Test Unit"

    if ($continuous) {
        $testJob = Start-Job -Name "test-continuous" -ScriptBlock {
            $serviceName = $args[0]
            $solutionName = $args[1]
            $location = $args[2]
            Set-Location $location
            D "Running unit tests continuously." $loggingPrefix
            dotnet watch --project ./../$serviceName/tests/$solutionName.$serviceName.Tests.csproj test --filter TestCategory!=E2E /p:CollectCoverage=true /p:CoverletOutput=TestResults/ /p:CoverletOutputFormat=lcov /p:Include="[$SolutionName.$serviceName.*]*" /p:Threshold=80 /p:ThresholdType=line /p:ThresholdStat=total
        } -ArgumentList @($serviceName, $solutionName, $location)

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
                    D "Shutting down testing job." $loggingPrefix
                    Get-Job | Where-Object {$_.Name -like "test-continuous"} | Remove-Job -Force -Confirm:$False
                    [Console]::TreatControlCAsInput = $False
                    Set-Location $currentDirectory
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
        Set-Location "./../$serviceName/tests"
        $command = "dotnet test --logger ""trx;logFileName=testResults.trx"" --filter TestCategory!=E2E  /p:CollectCoverage=true /p:CoverletOutput=TestResults/ /p:CoverletOutputFormat=lcov /p:Include=`"[$SolutionName.$serviceName.*]*`" /p:Threshold=80 /p:ThresholdType=line /p:ThresholdStat=total"
        $result = ExecuteCommand $command $loggingPrefix "Running unit tests."
        if ($verbosity -eq "Normal" -or $verbosity -eq "n") {
            $result
        }
        D "Finished running unit tests." $loggingPrefix
    }
    Set-Location $currentDirectory
}