function Invoke-EdenServicePipeline {
    [CmdletBinding()]
    param(  
    )
    Build-EdenService
    Test-EdenServiceCode
    Test-EdenServiceFeatures
    Publish-EdenService
    Deploy-EdenService
}
