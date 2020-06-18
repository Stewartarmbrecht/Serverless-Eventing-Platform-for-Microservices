# Include: Settings
. './Eden.settings.ps1'

# Include: build_utils
. './build_utils.ps1'

# Synopsis: Run/Publish Tests and Fail Build on Error
task Test BeforeTest, RunTests, ConfirmTestsPassed, AfterTest

# Synopsis: Run full Pipleline.
task . Clean, Analyze, Test

# Synopsis: Run full Pipleline.
task Pipeline Clean, Analyze, Test, Publish

# Synopsis: Install Build Dependencies
task InstallDependencies {
    # Cant run an Invoke-Build Task without Invoke-Build.
    Remove-Module -Name InvokeBuild
    Install-Module -Name InvokeBuild -Force

    Remove-Module -Name DscResourceTestHelper
    Install-Module -Name DscResourceTestHelper -Force

    Remove-Module -Name Pester
    Install-Module -Name Pester -Force

    Remove-Module -Name PSScriptAnalyzer
    Install-Module -Name PSScriptAnalyzer -Force
}

# Synopsis: Clean Artifacts Directory
task Clean BeforeClean, {
    if(Test-Path -Path $Artifacts)
    {
        Remove-Item "$Artifacts/*" -Recurse -Force
    }

    New-Item -ItemType Directory -Path $Artifacts -Force

    # Temp
    & git clone https://github.com/Xainey/PSTestReport.git
}, AfterClean

# Synopsis: Lint Code with PSScriptAnalyzer
task Analyze BeforeAnalyze, {
    $scriptAnalyzerParams = @{
        Path = $ModulePath
        Severity = @('Error', 'Warning')
        Recurse = $true
        Verbose = $false
    }

    $saResults = Invoke-ScriptAnalyzer @scriptAnalyzerParams

    # Save Analyze Results as JSON
    $saResults | ConvertTo-Json | Set-Content (Join-Path $Artifacts "ScriptAnalysisResults.json")

    if ($saResults) {
        $saResults | Format-Table
        throw "One or more PSScriptAnalyzer errors/warnings were found."
    }
}, AfterAnalyze

# Synopsis: Test the project with Pester. Publish Test and Coverage Reports
task RunTests {
    $invokePesterParams = [PesterConfiguration]@{
        TestResults = @{
            OutputFile =  (Join-Path $Artifacts "TestResults.xml")
            OutputFormat = 'NUnitXml'
        }
        Strict = $true
        Run = @{
            Exit = $false
        }
        CodeCoverage = @{
            Enable = $true
            Path = (Get-ChildItem -Path "$ModulePath\*.ps1" -Exclude "*.Tests.*" -Recurse).FullName
        }
        PassThru = $true
        Verbose = $false
    }

    # Publish Test Results as NUnitXml
    $testResults = Invoke-Pester -Configuration @invokePesterParams;

    # Save Test Results as JSON
    $testresults | ConvertTo-Json -Depth 6 | Set-Content  (Join-Path $Artifacts "PesterResults.json")

    # Old: Publish Code Coverage as HTML
    # $moduleInfo = @{
    #     TestResults = $testResults
    #     BuildNumber = $BuildNumber
    #     Repository = $Settings.Repository
    #     PercentCompliance  = $PercentCompliance
    #     OutputFile =  (Join-Path $Artifacts "Coverage.htm")
    # }
    #
    # Publish-CoverageHTML @moduleInfo

    # Temp: Publish Test Report
    $options = @{
        BuildNumber = $BuildNumber
        GitRepo = $Settings.GitRepo
        GitRepoURL = $Settings.ProjectUrl
        CiURL = $Settings.CiURL
        ShowHitCommands = $true
        Compliance = ($PercentCompliance / 100)
        ScriptAnalyzerFile = (Join-Path $Artifacts "ScriptAnalyzerResults.json")
        PesterFile =  (Join-Path $Artifacts "PesterResults.json")
        OutputDir = "$Artifacts"
    }

    . ".\PSTestReport\Invoke-PSTestReport.ps1" @options
}

# Synopsis: Throws and error if any tests do not pass for CI usage
task ConfirmTestsPassed {
    # Fail Build after reports are created, this allows CI to publish test results before failing
    [xml] $xml = Get-Content (Join-Path $Artifacts "TestResults.xml")
    $numberFails = $xml."test-results".failures
    assert($numberFails -eq 0) ('Failed "{0}" unit tests.' -f $numberFails)

    # Fail Build if Coverage is under requirement
    $json = Get-Content (Join-Path $Artifacts "PesterResults.json") | ConvertFrom-Json
    $overallCoverage = [Math]::Floor(($json.CodeCoverage.NumberOfCommandsExecuted / $json.CodeCoverage.NumberOfCommandsAnalyzed) * 100)
    assert($OverallCoverage -gt $PercentCompliance) ('A Code Coverage of "{0}" does not meet the build requirement of "{1}"' -f $overallCoverage, $PercentCompliance)
}

# Synopsis: Creates Archived Zip and Nuget Artifacts
task Archive BeforeArchive, {
    $moduleInfo = @{
        ModuleName = $ModuleName
        BuildNumber = $BuildNumber
    }

    Publish-ArtifactZip @moduleInfo

    $nuspecInfo = @{
        packageName = $ModuleName
        author =  $Settings.Author
        owners = $Settings.Owners
        licenseUrl = $Settings.LicenseUrl
        projectUrl = $Settings.ProjectUrl
        packageDescription = $Settings.PackageDescription
        tags = $Settings.Tags
        destinationPath = $Artifacts
        BuildNumber = $BuildNumber
    }

    Publish-NugetPackage @nuspecInfo
}, AfterArchive

# Synopsis: Publish to SMB File Share
task Publish BeforePublish, {
    $PSDataFile = "$ModulePath/$ModuleName.psd1"
    $ReadmeFile = "$ModulePath/Readme.md"

    #Add a new line to the markdown file.
    $date = Get-Date -Uformat "%D"

    #Update the manifest file
    $manifest = Import-PowerShellDataFile $PSDataFile
    [version]$version = $Manifest.ModuleVersion
    $prerelease = $Manifest.PrivateData.PSData.Prerelease

    # Add one to the build of the version number
    $NewVersion = "{0}.{1}.{2}" -f $Version.Major, $Version.Minor, ($Version.Build + 1)
    $versionString = "$($NewVersion.ToString())$(if($prerelease) { "-$($prerelease.ToString())" })"
    $releaseNotes = "Version $versionString was modified by $($Settings.Author) on $($date)"

    # Update the manifest file
    Update-ModuleManifest -Path $PSDataFile -ModuleVersion $NewVersion -ReleaseNotes $releaseNotes -Prerelease $prerelease

    #Sleep Incase of update
    Start-Sleep -Seconds 5

    # Update the Markdown file to have the version update
    Add-Content -Path $ReadmeFile -Value "  **Version: $($versionString)**"
    Add-Content -Path $ReadmeFile -Value "  by: $($Settings.Author) on $($date)"    
    
    # This assumes you are running PowerShell 5

    # Parameters for publishing the module
    $Path = "$ModulePath\$ModuleName.psd1"
    $PublishParams = @{
        NuGetApiKey = $Env:PSGalleryKey # Swap this out with your API key
        Path = $ModulePath
    }

    # $PublishParams

    Publish-Module @PublishParams

}, AfterPublish