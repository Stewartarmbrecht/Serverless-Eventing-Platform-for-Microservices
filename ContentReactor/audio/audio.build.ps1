param(
    [String]$systemName = (property systemName toco),
    [String]$userName = (property userName notneeded),
    [String]$password = (property password notneeded),
    [String]$tenantId = (property tenantId notneeded),
    [String]$uniqueDeveloperId = (property uniqueDeveloperId notneeded),
    [String]$apiPort = (property apiPort 7071),
    [String]$workerPort = (property workerPort 7072)
)

. ./audio.utils.ps1

$loggingPrefix = "ContentReactor $systemName "

# Synopsis: Install Build Dependencies
task Build {
    exec { dotnet build }
}

task TestUnit {
    exec { 
        dotnet test --logger "trx;logFileName=testResults.trx" --filter TestCategory!=E2E /p:CollectCoverage=true /p:CoverletOutput=TestResults/ /p:CoverletOutputFormat=lcov /p:Include=`"[ContentReactor.Audio.*]*`" /p:Threshold=80 /p:ThresholdType=line /p:ThresholdStat=total 
    }
}

task TestUnitContinuous {
    exec { 
        dotnet watch --project ./tests/ContentReactor.Audio.Tests.csproj test --filter TestCategory!=E2E /p:CollectCoverage=true /p:CoverletOutput=TestResults/ /p:CoverletOutputFormat=lcov /p:Include="[ContentReactor.Audio.*]*" /p:Threshold=80 /p:ThresholdType=line /p:ThresholdStat=total
    }
}

task SetupLocal {
    exec { 
        az login
        Set-Location "./api"
        func azure functionapp fetch-app-settings $systemName-audio-api 
        func settings add "FUNCTIONS_WORKER_RUNTIME" "dotnet"
        func settings add "Host.LocalHttpPort" "7070"
        Set-Location "./../worker"
        func azure functionapp fetch-app-settings $systemName-audio-worker
        func settings add "FUNCTIONS_WORKER_RUNTIME" "dotnet"
        func settings add "Host.LocalHttpPort" "7071"
    }
}

task Run {
    Write-Build Green "This is a test. $apiPort $workerPort"
    Start-EdenService `
        -systemName $systemName `
        -userName $userName `
        -password $password `
        -tenantId $tenantId `
        -uniqueDeveloperId $uniqueDeveloperId `
        -apiPort $apiPort `
        -workerPort $workerPort
}

task StartApiApp {

    Write-Build Green "$loggingPrefix Starting api application on port $port."

    $job = Start-Job -Name "rt-AudioFunction-$port" -ScriptBlock {
        $port = $args[0]
        $loggingPrefix = $args[1]
        $location = $args[2]

        Set-Location $location

        Write-Build Green "$loggingPrefix Launching function app on port $port."
        $old_ErrorActionPreference = $ErrorActionPreference
        $ErrorActionPreference = 'SilentlyContinue'
        func host start -p $port
        $ErrorActionPreference = $old_ErrorActionPreference 
        Write-Build Green "$loggingPrefix The function app is running."
    } -ArgumentList @($apiPort, $loggingPrefix)

    return $job
}

task TestEndToEnd {
    Write-Build Green "This is a test. $apiPort $workerPort"
    Start-EdenService `
        -systemName $systemName `
        -userName $userName `
        -password $password `
        -tenantId $tenantId `
        -uniqueDeveloperId $uniqueDeveloperId `
        -apiPort $apiPort `
        -workerPort $workerPort `
        -test $TRUE
}

