<#
    .SYNOPSIS
        Invokes Eden tasks.

    .DESCRIPTION
        Invokes Eden tasks.
        Finds the root directory of the solution and 
        then navigates down to the microservice directory and 
        execute dotnet build.

    .PARAMETER continuous
        Boolean flag that indicates whet

    .PARAMETER Help
        Just a minor wrapper to call Get-Help or further customize

    .EXAMPLE
        Invoke-Eden -Ask "Why is my cereal on fire?"

    .NOTES
#>
function Invoke-Eden {

    [cmdletbinding()]
    param(  
        [String[]] $commands,
        [String] $deploymentParameters,
        [string] $userName,
        [string] $password,
        [string] $tenantId,
        [string] $uniqueDeveloperId,
        [string] $systemName,
        [string] $region,
        [string] $solutionName,
        [string] $serviceName,
        [int] $port
    )

    $currentDirectory = Get-Location

    foreach($command in $commands)
    {

    }

    $config = $commands.Contains("configure") -or $commands.Contains("config")
    $setup =  $commands.Contains("setup")

    if (!$config -and !$setup) {

        $build =          $commands.Contains("build" -or                $commands.Contains("b")
        $continuoustest = $commands.Contains("test-continuous" -or      $commands.Contains("tc")
        $test = (         $commands.Contains("test" -or                 $commands.Contains("t")) -and !$continuoustest
        $run =            $commands.Contains("run" -or                  $commands.Contains("r")
        $continuouse2e =  $commands.Contains("e2e-continuous" -or       $commands.Contains("ec")
        $e2e = (          $commands.Contains("e2e" -or                  $commands.Contains("e")) -and !$continuouse2e
        $package =        $commands.Contains("package" -or              $commands.Contains("k")
        $deployAll =      $commands.Contains("deploy-all" -or           $commands.Contains("dl")
        $deployInfra =    $commands.Contains("deploy-infrastructure" -or $commands.Contains("di")
        $deployApps =     $commands.Contains("deploy-apps" -or          $commands.Contains("da")
        $deploySubs =     $commands.Contains("deploy-subscriptions" -or $commands.Contains("ds")
        $pipeline =       $commands.Contains("pipeline" -or             $commands.Contains("p")
        
        if($continuoustest -and 
            ( $run -or $continuouse2e -or $e2e -or $package -or $deployAll -or $deployInfra -or $deployApps -or $deploySubs -or $pipeline)
        ) {
            Write-Error "You can not run continuous testing and any downstream commands." 
            exit
        }
        
        if($run -and 
            ( $continuouse2e -or $e2e -or $package -or $deployAll -or $deployInfra -or $deployApps -or $deploySubs -or $pipeline)
        ) {
            Write-Error "You can not issue the run command and any downstream commands." 
            exit
        }
        
        if($continuouse2e -and 
            ( $package -or $deployAll -or $deployInfra -or $deployApps -or $deploySubs -or $pipeline)
        ) {
            Write-Error "You can not issue the e2e continuous command and any downstream commands." 
            exit
        }
        
    }

    if ($config) {
        Configure-Eden `
            -systemName $systemName `
            -region $region `
            -solutionName $solutionName `
            -serviceName $serviceName `
            -apiPort $apiPort `
            -workerPort $workerPort `
            -deploymentParameters $deploymentParameters `
            -userName $userName `
            -password $password  `
            -tenantId $tenantId `
            -uniqueDeveloperId $uniqueDeveloperId
        exit
    }

    if ($setup) {
        Setup-EdenServiceLocalEnvironment `
            -serviceName $serviceName `
            -systemName $systemName `
            -port $apiPort
        exit
    }

    if ($pipeline) {
        Set-Location "$PSScriptRoot"
        ./pipeline.ps1 -v $verbosity
        Set-Location $currentDirectory
        exit
    }

    if ($build) {
        Set-Location "$PSScriptRoot"
        ./build.ps1 -v $verbosity
        Set-Location $currentDirectory
    }

    if ($test) {
        Set-Location "$PSScriptRoot"
        ./test-unit.ps1 -v $verbosity
        Set-Location $currentDirectory
    }

    if ($continuoustest) {
        Set-Location "$PSScriptRoot"
        ./test-unit.ps1 -v $verbosity -c $TRUE
    }

    if ($run) {
        Set-Location "$PSScriptRoot"
        ./run.ps1 -v $verbosity
    }

    if ($e2e) {
        Set-Location "$PSScriptRoot"
        ./run.ps1 -t $TRUE -v $verbosity
        Set-Location $currentDirectory
    }

    if ($continuouse2e) {
        Set-Location "$PSScriptRoot"
        ./run.ps1 -t $TRUE -c $TRUE -v $verbosity
    }

    if ($package) {
        Set-Location "$PSScriptRoot"
        ./package.ps1 -v $verbosity
        Set-Location $currentDirectory
    }

    if ($deployInfra -or $deployAll) {
        Set-Location "$PSScriptRoot"
        ./deploy-infrastructure.ps1 -v $verbosity
        Set-Location $currentDirectory
    }

    if ($deployApps -or $deployAll) {
        Set-Location "$PSScriptRoot"
        ./deploy-apps.ps1 -v $verbosity
        Set-Location $currentDirectory
    }

    if ($deploySubs -or $deployAll) {
        Set-Location "$PSScriptRoot"
        ./deploy-subscriptions.ps1 -v $verbosity
        Set-Location $currentDirectory
    }

    Set-Location $currentDirectory
}