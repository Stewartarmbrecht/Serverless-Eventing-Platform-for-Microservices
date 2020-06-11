## System Development Flows
1. Install-Module Eden
1. New-EdenSolution 
    1. -Source https://github.com/stewartarmbrecht/eden-solution
    1. -Name ContentReactor
1. Set-Location ./ContentReactor
1. Configure-Settings
    1. -ProductionInstanceName CReactProd
    1. -DevelopmentInstanceName CReact001
    1. -DeveloperInstanceName CReact001SPA
    1. -Region CentralUs
    1. -TenantId GUID
    1. -ServicePrincipalName GUID
    1. -ServicePrincipalPassword String
1. Setup-Solution
    1. Install-Tools
        1. Check operating system
        1. Install/Update Dotnet Core
        1. Install/Update git
        1. Install/Update VSCode
        1. Install/Update VSCode Extensions
        1. Install/Update Az PowerShell module
        1. Install/Update Azure Functions Tools
    1. Setup-DevelopmentEnvironment
        1. Setup-CloudEnvironment
            1. Create service principal
            1. Set service principal permissions
        1. Invoke-Pipelines
            1. Invoke-EventsPipeline
            1. Invoke-ServicePipelines
            1. Invoke-ApiPipeline
            1. Invoke-WebPipeline
            1. Invoke-HealthPipeline
        1. Setup-LocalEnvironments
            1. Setup-ServiceLocalEnvironments
                1. Setup Local App Configurations
                1. Test-Local
    1. Setup-CodeRepository
    1. Setup-ProductionEnvironment
    1. Setup-ProductionPipeline
    1. Test-ProductionPipeline
1. Start-IDE
1. Show-Docs
1. Add-EdenService 
    1. -SolutionName ContentReactor
    1. -Name MyServiceName
    1. -Source https://github.com/stewartarmbrecht/eden-service
1. Show-Web [-Staging] (VSCode: Get-Web, Get-Web-Staging)
1. Show-Health [-Staging] (VSCode: Get-Health, Get-Health-Staging)
1. Show-WebMontior [-Staging] (VSCode: Get-WebMonitor, Get-WebMonitor-Staging)
1. Show-ApiMonitor [-Staging] (VSCode: Get-ApiMonitor, Get-ApiMonitor-Staging)
1. Show-HealthMonitor [-Staging] (VSCode: Get-HealthMonitor, Get-HealthMonitor-Staging)
1. Delete-DevelopmentEnvironment
1. Delete-ProductionEnvironment

## Service Development Flows
1. Set-Location ./ServiceFolder
1. Start-IDE
1. Show-Docs
1. Build-Applications [-Continuous] (VSCode: Build, Build-Continuous)
1. Test-Unit [-Continuous] (VSCode: Test, Test-Continuous, Test-Debug)
1. Start-Local [-Continuous] (VSCode: Run, Run-Continuous, Run-Debug)
1. Show-Local (VSCode: Launch-Web)
1. Test-Local [-Continuous] (VSCode: LocalTest, LocalTest-Continuouse, LocalTest-Debug)
1. Invoke-Pipeline (VSCode: Pipeline)
    1. Build-Applications
    1. Test-Unit
    1. Build-DeploymentPackages
    1. Deploy-Infrastructure
    1. Deploy-StagingApplications
    1. Deploy-StagingSubscriptions
    1. Test-Staging
    1. Deploy-ProductionSwap
    1. Deploy-ProductionSubscriptions
    1. Test-Production
1. Show-HealthCheck (VSCode: Check-Health)
1. Show-LocalMonitor (VSCode: Monitor-Local)
1. Show-StagingMonitor (VSCode: Monitor-Staging)
1. Show-ProductionMonitor (VSCode: Monitor-Production)
1. Add-Function -Name MyNewFunction (VSCode: Add-Function)
