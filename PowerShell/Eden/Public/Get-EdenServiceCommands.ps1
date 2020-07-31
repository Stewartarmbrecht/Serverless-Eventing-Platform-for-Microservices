function Get-EdenServiceCommands {
    [CmdletBinding()]
    param(
        [Switch] $CommandMissing
    )

    $commandsAndFiles = @(

    @{Command="-----ENVIRONMENTS-----"},

        @{Command="Set-EdenEnvConfig";                          Alias="e-es";           Files = @()},
        @{Command="Install-EdenServiceTools";                   Alias="e-eit";          Files = @("./Eden/Install-ServiceTools.ps1")},
        @{Command="Initialize-EdenServiceEnvironment";          Alias="e-ei";           Files = @("./Eden/Initialize-ServiceEnvironment.ps1")},
        @{Command="Get-EdenEnvConfig";                          Alias="e-eg";           Files = @()},
        @{Command="Get-EdenEnvConfig -All";                     Alias="e-eg -a";        Files = @()},
        @{Command="Get-EdenServiceCommands";                    Alias="e-esc";          Files = @()},
        @{Command="New-EdenServicePipeline";                    Alias="e-ep";           Files = @("./Eden/New-ServicePipeline.ps1")},

    @{Command="-----CODING-----"},
        @{Command="New-EdenServiceFunction";                    Alias="e-cfunc";        Files = @("./Eden/New-ServiceFunction.ps1")},
        @{Command="New-EdenServiceFunctionRequest";             Alias="e-creq";         Files = @("./Eden/New-ServiceFunctionRequest.ps1")},
        @{Command="New-EdenServiceFunctionResponse";            Alias="e-cres";         Files = @("./Eden/New-ServiceFunctionResponse.ps1")},
        @{Command="New-EdenServiceEvent";                       Alias="e-cevent";       Files = @("./Eden/New-ServiceEvent.ps1")},
        @{Command="New-EdenServiceSubscription";                Alias="e-csub";         Files = @("./Eden/New-ServiceSubscription.ps1")},
        @{Command="New-EdenServiceFeatureTest";                 Alias="e-cftest";       Files = @("./Eden/New-ServiceFeatureTest.ps1")},
    
    @{Command="-----BUILDING-----"},
    
        @{Command="Build-EdenService";                          Alias="e-b";            Files = @("./Eden/Build-Service.ps1")},
        @{Command="Build-EdenService -Continuous";              Alias="e-b -c";         Files = @("./Eden/Build-ServiceContinuous.ps1")},
        
    @{Command="-----HOSTING-----"},
        
        @{Command="Start-EdenServiceLocal";                     Alias="e-hs";           Files = @("./Eden/Start-ServiceLocal.ps1",
                                                                                                "./Eden/Start-ServiceTunnelLocal.ps1",
                                                                                                "./Eden/Get-ServiceHealthLocal.ps1",
                                                                                                "./Eden/Get-ServiceUrlPublicLocal.ps1",
                                                                                                "./Eden/Deploy-ServiceSubscriptionsLocal.ps1")},
        @{Command="Start-EdenServiceLocal -Continuous";         Alias="e-hs -c";        Files = @("./Eden/Start-ServiceLocalContinuous.ps1",
                                                                                                "./Eden/Start-ServiceTunnelLocal.ps1",
                                                                                                "./Eden/Get-ServiceHealthLocal.ps1",
                                                                                                "./Eden/Get-ServiceUrlPublicLocal.ps1",
                                                                                                "./Eden/Deploy-ServiceSubscriptionsLocal.ps1")},

        @{Command="Get-EdenServiceUrlPublicLocal";              Alias="e-hupl";         Files = @("./Eden/Test-ServiceCode.ps1")},
    @{Command="-----TESTING CODE-----"},
        @{Command="Test-EdenServiceCode";                       Alias="e-tc";           Files = @("./Eden/Test-ServiceCode.ps1")},
        @{Command="Test-EdenServiceCode -Continuous";           Alias="e-tc -c";        Files = @("./Eden/Test-ServiceCodeContinuous.ps1")}
        @{Command="Show-EdenServiceCodeCoverage";               Alias="e-tccc";         Files = @("./Eden/Show-ServiceCodeCoverage.ps1")},
        @{Command="Publish-EdenServiceCodeCoverage";            Alias="e-tcccp";        Files = @("./Eden/Publish-ServiceCodeCoverage.ps1")},
        @{Command="Show-EdenServiceCodeCoverage -Published";    Alias="e-tccc -p";      Files = @("./Eden/Show-ServiceCodeCoveragePublished.ps1")},
        @{Command="Show-EdenServiceCodeTestResults";            Alias="e-tctr";         Files = @("./Eden/Show-ServiceCodeTestResults.ps1")},
        @{Command="Publish-EdenServiceCodeTestResults";         Alias="e-tctrp";        Files = @("./Eden/Publish-ServiceCodeTestResults.ps1")},
        @{Command="Show-EdenServiceCodeTestResults -Published"; Alias="e-tctr -p";      Files = @("./Eden/Show-ServiceCodeTestResultsPublished.ps1")},
    
    @{Command="-----TESTING FEATURES-----"},
        @{Command="Test-EdenServiceFeatures";                   Alias="e-tf";           Files = @("./Eden/Start-ServiceLocal.ps1",
                                                                                                "./Eden/Start-ServiceTunnelLocal.ps1",
                                                                                                "./Eden/Get-ServiceStatusLocal.ps1",
                                                                                                "./Eden/Get-ServiceUrlPublicLocal.ps1",
                                                                                                "./Eden/Deploy-ServiceSubscriptionsLocal.ps1",
                                                                                                "./Eden/Test-ServiceFeaturesLocal.ps1")},
        @{Command="Test-EdenServiceFeatures -Continuous";       Alias="e-tf -c";        Files = @("./Eden/Start-ServiceLocal.ps1",
                                                                                                "./Eden/Start-ServiceTunnelLocal.ps1",
                                                                                                "./Eden/Get-ServiceStatusLocal.ps1",
                                                                                                "./Eden/Get-ServiceUrlPublicLocal.ps1",
                                                                                                "./Eden/Deploy-ServiceSubscriptionsLocal.ps1",
                                                                                                "./Eden/Test-ServiceFeaturesLocalContinuous.ps1")},
        @{Command="Show-EdenServiceFeaturesTestResults";        Alias="e-tftr";         Files = @("./Eden/Show-ServiceFeaturesTestResults.ps1")},
        @{Command="Publish-EdenServiceFeaturesTestResults";     Alias="e-tftrp";        Files = @("./Eden/Publish-ServiceFeaturesTestResults.ps1")},
        @{Command="Show-EdenServiceFeaturesTestResults -Published";Alias="e-tftr -p";   Files = @("./Eden/Show-ServiceFeaturesTestResultsPublished.ps1")},
    
    @{Command="-----TESTING PERFORMANCE-----"},
        @{Command="Test-EdenServicePerformance";                Alias="e-tp";           Files = @("./Eden/Test-ServicePerformance.ps1")},
        @{Command="Show-EdenServicePerformanceTestResults";     Alias="e-tptr";         Files = @("./Eden/Show-ServicePerformanceTestResults.ps1")},
        @{Command="Publish-EdenServicePerformanceTestResults";  Alias="e-tptrp";        Files = @("./Eden/Publish-ServicePerformanceTestResults.ps1")},
        @{Command="Show-EdenServicePerformanceTestResults -Published";Alias="e-tptr -c";Files = @("./Eden/Show-ServicePerformanceTestResultsPublished.ps1")},
    
    @{Command="-----DEPLOYING-----"},
        @{Command="Publish-EdenService";                        Alias="e-dp";          Files = @("./Eden/Publish-Service.ps1")},
        @{Command="Deploy-EdenServiceInfrastructure";           Alias="e-di";           Files = @("./Eden/Deploy-ServiceInfrastructure.ps1")},
        @{Command="Deploy-EdenServiceApplication";              Alias="e-da";           Files = @("./Eden/Deploy-ServiceAppStaging.ps1",
                                                                                                "./Eden/Test-ServiceFeaturesStaging.ps1",
                                                                                                "./Eden/Invoke-ServiceStagingSwap.ps1")},
        @{Command="Deploy-EdenServiceSubscriptions";            Alias="e-ds";           Files = @("./Eden/Deploy-ServiceSubscriptions.ps1")},
        @{Command="Deploy-EdenService";                         Alias="e-d";            Commands = @("Deploy-EdenServiceInfrastructure",
                                                                                                    "Deploy-EdenServiceApplication",
                                                                                                    "Deploy-EdenServiceSubscriptions")},
        @{Command="Show-EdenServiceDeploymentsList";            Alias="e-dl";           Files = @("./Eden/Show-ServiceDeploymentsList.ps1")},
    
    @{Command="-----PIPELINE-----"},
        @{Command="Invoke-EdenServicePipeline";                 Alias="e-p";            Commands = @("Build-EdenService",
                                                                                                    "Test-EdenServiceCode",
                                                                                                    "Test-EdenServiceFeatures",
                                                                                                    "Publish-EdenService",
                                                                                                    "Deploy-EdenService")},
        @{Command="Show-EdenServicePipelineReport";             Alias="e-pr";          Files = @("./Eden/Show-ServicePipelineReport.ps1")},
        @{Command="Show-EdenServicePipelineHistory";            Alias="e-ph";          Files = @("./Eden/Show-ServicePipelineHistory.ps1")},
    
    @{Command="-----OPERATIONS-----"},
        @{Command="Show-EdenServiceInfrastructure";             Alias="e-oi";           Files = @("./Eden/Show-ServiceInfrastructure.ps1")},
        @{Command="Show-EdenServiceMonitor";                    Alias="e-om";           Files = @("./Eden/Show-ServiceMonitor.ps1")},
        @{Command="Get-EdenServiceHealth";                      Alias="e-oh";           Files = @("./Eden/Get-ServiceHealthLocal.ps1")},
        @{Command="Get-EdenServiceHealth -Staging";             Alias="e-oh -s";        Files = @("./Eden/Get-ServiceHealthStaging.ps1")},
        @{Command="Get-EdenServiceHealth -Production";          Alias="e-oh -p";        Files = @("./Eden/Get-ServiceHealthProduction.ps1")},
        @{Command="Get-EdenServiceStatus";                      Alias="e-os";           Files = @("./Eden/Get-ServiceStatusLocal.ps1")},
        
    
    @{Command="-----SOURCE CONROL-----"},
        @{Command="Show-EdenServiceChanges";                    Alias="e-sch";          Files = @("./Eden/Show-ServiceChanges.ps1")},
        @{Command="Save-EdenServiceChanges";                    Alias="e-schsv";         Files = @("./Eden/Show-ServiceChanges.ps1")},
        @{Command="New-EdenServiceCommit";                      Alias="e-scomn";         Files = @("./Eden/New-ServiceCommit.ps1")},
        @{Command="Show-EdenServiceCommits";                    Alias="e-scoml";         Files = @("./Eden/Show-ServiceChangesLocal.ps1")},
        @{Command="Sync-EdenServiceCommits";                    Alias="e-scoms";        Files = @("./Eden/Show-ServiceChangesLocal.ps1")},

    @{Command="-----PRODUCT-----"},
        @{Command="Show-EdenServiceProductRoadMap";             Alias="e-prm";         Files = @("./Eden/Show-ServiceProductRoadMap.ps1")},
        @{Command="Show-EdenServiceProductFeatures";            Alias="e-pf";         Files = @("./Eden/Show-ServiceProductFeatures.ps1")},

    @{Command="-----WORK ITEMS-----"},
        @{Command="Show-EdenServiceWorkItemAssignments";        Alias="e-wia";         Files = @("./Eden/Show-ServiceWorkItemAssignments.ps1")},
        @{Command="Show-EdenServiceWorkItemList";               Alias="e-wil";         Files = @("./Eden/Show-ServiceWorkItemList.ps1")},
        @{Command="Show-EdenServiceWorkItemBoard";              Alias="e-wib";         Files = @("./Eden/Show-ServiceWorkItemBoard.ps1")},

    @{Command="-----ISSUES-----"},
        @{Command="Show-EdenServiceIssueList";                  Alias="e-il";          Files = @("./Eden/Show-ServiceIssueList.ps1")},
        @{Command="Show-EdenServiceIssueSubmissionForm";        Alias="e-isf";         Files = @("./Eden/Show-ServiceIssueSubmissionForm.ps1")},

    @{Command="-----DOCUMENTATION-----"},
        @{Command="Show-EdenServiceDocs";                       Alias="e-doc";         Files = @("./Eden/Show-ServiceDocs.ps1")},
        @{Command="Show-EdenServiceDocs -Functional";           Alias="e-doc -f";      Files = @("./Eden/Show-ServiceDocsFunc.ps1")},
        @{Command="Show-EdenServiceDocs -Reference";            Alias="e-doc -r";      Files = @("./Eden/Show-ServiceDocsRef.ps1")},
        @{Command="Show-EdenServiceDocs -Architecture";         Alias="e-doc -a";      Files = @("./Eden/Show-ServiceDocsArch.ps1")},
        @{Command="Show-EdenServiceDocs -Infrastructure";       Alias="e-doc -i";      Files = @("./Eden/Show-ServiceDocsInfra.ps1")},
        @{Command="Show-EdenServiceDocs -Operations";           Alias="e-doc -o";      Files = @("./Eden/Show-ServiceDocsOps.ps1")},
        @{Command="Show-EdenServiceDocs -Team";                 Alias="e-doc -t";      Files = @("./Eden/Show-ServiceDocsTeam.ps1")},
        @{Command="Show-EdenServiceDocs -Chat";                 Alias="e-doc -c";      Files = @("./Eden/Show-ServiceDocsChat.ps1")},
        @{Command="Show-EdenServiceDocs -Bots";                 Alias="e-doc -b";      Files = @("./Eden/Show-ServiceDocsBots.ps1")},

    @{Command="-----UTILITIES-----"},
        @{Command="Watch-EdenFolder";                          Alias="e-uwf";           Files = @()},
        @{Command="Write-EdenBuildInfo";                       Alias="e-uwi";           Files = @()},
        @{Command="Write-EdenBuildError";                      Alias="e-uwe";           Files = @()}
    )

    Write-Host "Supported | Alias      | Command" -ForegroundColor Blue
    foreach ($command in $commandsAndFiles) {
        if ($command.Alias.Length -gt 0 -and ($commandsAndFiles | where {$_.Alias -eq $command.Alias -and $_.Command -ne $command.Command}).Count -gt 0) {
            Write-Host "DUPLICATE ALIAS: $($command.Alias)" -ForegroundColor Yellow
        }
        $supported = $true
        $missing = @()
        if ($command.Command.ToString().StartsWith("-----")) {
            Write-Host $command.Command -ForegroundColor Blue
        } else {
            if (Get-Command $command.Command.Split()[0] -errorAction SilentlyContinue) {
                foreach ($file in $command.Files) {
                    $fileFound = (Test-Path $file)
                    $supported = ($supported -and $fileFound)
                    if ($CommandMissing -and !$fileFound) { $missing += "              v        | Missing File: $file" }
                }
                foreach ($commandDependency in $command.Commands) {
                    $supported = $supported -and ($commandsAndFiles | where {$_.Command -eq $commandDependency}).Count -gt 0
                }
                $command.Supported = $supported
                $color = if ($supported) { "Green" } else { "Red" };
                $supportedCommand = if ($supported) { "Yes" } else { "No " }
                Write-Host "$supportedCommand       | $($command.Alias.PadRight(10," ")) | $($command.Command)" -ForegroundColor $color
                foreach($missingFile in $missing) {
                    Write-Host $missingFile -ForegroundColor Red
                }    
            } else {
                Write-Host "Future    | $($command.Alias.PadRight(10," ")) | $($command.Command)" -ForegroundColor Gray
            }
        }
    }
}
New-Alias `
    -Name e-esc `
    -Value Get-EdenServiceCommands