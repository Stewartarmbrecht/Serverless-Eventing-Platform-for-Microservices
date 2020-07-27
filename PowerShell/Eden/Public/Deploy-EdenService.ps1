function Deploy-EdenService {
    [CmdletBinding()]
    param(  
    )
    Deploy-EdenServiceInfrastructure
    Deploy-EdenServiceApplication
    Deploy-EdenServiceSubscriptions    
}
New-Alias `
    -Name e-d `
    -Value Deploy-EdenService
