function Deploy-EdenService {
    [CmdletBinding()]
    param(  
    )
    Deploy-EdenServiceInfrastructure
    Deploy-EdenServiceApplication
    Deploy-EdenServiceSubscriptions    
}