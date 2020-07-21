function Watch-EdenFolder {
    [CmdletBinding()]
    param(
        [String] $Folder,
        [String] $Filter,
        [ScriptBlock] $Action,
        [String] $LoggingPrefix
    ) 
    Write-EdenBuildInfo "Watching folder '$Folder' with filter '$Filter'" $LoggingPrefix
    ### SET FOLDER TO WATCH + FILES TO WATCH + SUBFOLDERS YES/NO
    $filewatcher = New-Object System.IO.FileSystemWatcher
    #Mention the folder to monitor
    $filewatcher.Path = $Folder
    $filewatcher.Filter = $Filter
    #include subdirectories $true/$false
    $filewatcher.IncludeSubdirectories = $true
    $filewatcher.EnableRaisingEvents = $true  

    $script = @"
    {
        if (`$null -eq `$global:lastActionTime) {
            `$global:lastActionTime = [DateTime]`"1/1/2020`"
        }
        `$currentTime = Get-Date
        `$ts = New-Timespan –Start `$global:lastActionTime –End `$currentTime
        if(`$ts.TotalSeconds -gt 1) {
            Invoke-Command -ScriptBlock { $($Action.ToString()) } -NoNewScope
            `$global:lastActionTime = Get-Date
        }
    }
"@

    $localAction = [ScriptBlock]::Create([ScriptBlock]::Create($script).Invoke())

    $localAction.Invoke()

    ### DECIDE WHICH EVENTS SHOULD BE WATCHED 

    #The Register-ObjectEvent cmdlet subscribes to events that are generated by .NET objects 
    #on the local computer or on a remote computer.
    #When the subscribed event is raised, it is added to the event queue in your session. 
    #To get events in the event queue, use the Get-Event cmdlet.
    $handlers = . {
        Register-ObjectEvent -InputObject $filewatcher -EventName Changed -Action $localAction -SourceIdentifier FSChange
        Register-ObjectEvent -InputObject $filewatcher -EventName Created -Action $localAction -SourceIdentifier FSCreate
        Register-ObjectEvent -InputObject $filewatcher -EventName Deleted -Action $localAction -SourceIdentifier FSDelete
        Register-ObjectEvent -InputObject $filewatcher -EventName Renamed -Action $localAction -SourceIdentifier FSRename
    }

    try
    {
        do
        {
            Wait-Event -Timeout 1
            Write-Host "." -NoNewline
            
        } while ($true)
    }
    finally
    {
        # this gets executed when user presses CTRL+C
        # remove the event handlers
        Unregister-Event -SourceIdentifier FSChange
        Unregister-Event -SourceIdentifier FSCreate
        Unregister-Event -SourceIdentifier FSDelete
        Unregister-Event -SourceIdentifier FSRename
        # remove background jobs
        $handlers | Remove-Job
        # remove filesystemwatcher
        $filewatcher.EnableRaisingEvents = $false
        $filewatcher.Dispose()
        Write-EndBuildInfo "Event Handler disabled." $LoggingPrefix
    }
}