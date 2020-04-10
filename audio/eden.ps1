param(  
    [String] $shortCommand,
    [String] $command,
    [Alias("v")]
    [string] $verbosity,
    [String] $bigHugeThesaurusApiKey,
    [string] $userName,
    [string] $password,
    [string] $tenantId,
    [string] $uniqueDeveloperId
)

./../scripts/eden.ps1 `
    -shortCommand $shortCommand `
    -command $command `
    -verbosity $verbosity `
    -namePrefix "toco" `
    -region "WestUS2" `
    -solutionName "ContentReactor" `
    -microserviceName "Audio" `
    -apiPort 7073 `
    -workerPort 7074 `
    -bigHugeThesaurusApiKey $bigHugeThesaurusApiKey, `
    -userName $userName `
    -password $password  `
    -tenantId $tenantId `
    -uniqueDeveloperId $uniqueDeveloperId `
