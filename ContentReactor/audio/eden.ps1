param(  
    [String] $systemName,
    [String] $shortCommand,
    [Alias("v")]
    [string] $verbosity,
    [String] $command,
    [String] $deploymentParameters,
    [string] $userName,
    [string] $password,
    [string] $tenantId,
    [string] $uniqueDeveloperId
)

./../scripts/eden.ps1 `
    -shortCommand $shortCommand `
    -command $command `
    -verbosity $verbosity `
    -systemName $systemName `
    -region "WestUS2" `
    -solutionName "ContentReactor" `
    -microserviceName "Audio" `
    -apiPort 7073 `
    -workerPort 7074 `
    -deploymentParameters "uniqueResourcesystemName=$systemName" `
    -userName $userName `
    -password $password  `
    -tenantId $tenantId `
    -uniqueDeveloperId $uniqueDeveloperId `
