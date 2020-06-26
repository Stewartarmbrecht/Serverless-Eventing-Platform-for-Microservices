function Invoke-CommandPublish
{
    [CmdletBinding()]
    param(
        [String]$SolutionName,
        [String]$ServiceName
    ) 
    dotnet publish ./Service/$SolutionName.$ServiceName.Service.csproj -c Release -o ./.dist/app
    if ($LASTEXITCODE -ne 0) { throw "Publishing exited with an error."}

    $appPath =  "./.dist/app/**"
    $appDestination = "./.dist/app.zip"
    
    Remove-Item -Path $appDestination -Recurse -Force -ErrorAction Ignore
    Compress-Archive -Path $appPath -DestinationPath $appDestination
    
}