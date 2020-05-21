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
    -microserviceName "Categories" `
    -apiPort 7071 `
    -workerPort 7072 `
    -deploymentParameters $deploymentParameters `
    -userName $userName `
    -password $password  `
    -tenantId $tenantId `
    -uniqueDeveloperId $uniqueDeveloperId `
