Param(
  [int]     $BuildNumber = 0,
  [string]  $GitRepo = "Repo Name",
  [string]  $GitRepoURL = "#",
  [string]  $CiURL = "#",
  [boolean] $ShowHitCommands = $false,
  [double]  $Compliance = 0.8,
  [string]  $ScriptAnalyzerFile = ".\artifacts\ScriptAnalysisResults.json",
  [string]  $PesterFile = ".\artifacts\PesterResults.json",
  [string]  $CoverageFile = ".\artifacts\coverage.xml",
  [string]  $OutputDir = ".\artifacts",
  [switch]  $FailOnSkippedOrPending
)

# HTML Colors
$Colors = @{
    GREEN = '#5cb85c'
    YELLOW = '#FFCE56'
    RED = '#FF6384'
}

# Load HTML Template
$templateFile = "$PSScriptRoot\lib\TestReport.htm"

# Load Pester JSON Files: Required
if (!(Test-Path $PesterFile)) 
{ 
    throw "$PesterFile is missing."
}
$Pester = Get-Content $PesterFile | ConvertFrom-Json

# Load Pester JSON Files: Required
if (!(Test-Path $CoverageFile)) 
{ 
    throw "$CoverageFile is missing."
}
[xml]$Coverage = Get-Content $CoverageFile

# Load ScriptAnalyzer JSON Files: Optional
$ScriptAnalyzer = $null;
if (Test-Path $ScriptAnalyzerFile) 
{ 
    $ScriptAnalyzer = Get-Content $ScriptAnalyzerFile | ConvertFrom-Json
}

# Copy Dependencies manually for now
Copy-Item -Recurse -Path "$PSScriptRoot\lib" -Destination (Join-Path $OutputDir "lib") -Force

# From Pester Source
function Get-HumanTime($Seconds) 
{
    if($Seconds -gt 0.99) {
        $time = [math]::Round($Seconds, 2)
        $unit = 's'
    }
    else {
        $time = [math]::Floor($Seconds * 1000)
        $unit = 'ms'
    }
    return "$time$unit"
}

# Parse Git Commit
function Get-GitCommitHash($Length)
{
    $sha = $null
    
    try {
        $sha = (. git rev-parse HEAD).Substring(0, $length)
    }
    catch [System.Exception] {
        Write-Verbose "Git Hash could not be retrieved."
    }
    
    return $sha
}

# Create Test HTML Table
#$TestResults = $Pester.TestResult | Select-Object Result, Name, Describe, Context, FailureMessage, Time
$TestResults = ($Pester.Tests | Sort-Object -Property { $_.Path[0], $_.Path[1], $_.Name })
foreach($test in $TestResults)
{
    if($test.Result -eq "Passed")
    {
        $status = "<span class='label label-success'>Passed</span>"
    }
    elseif($test.Result -eq "Skipped")
    {
        $status = "<span class='label label-warning'>Skipped</span>"
    }
    elseif($test.Result -eq "Pending")
    {
        $status = "<span class='label label-info'>Pending</span>"
    }
    else
    {
        $status = "<span class='label label-danger'>Failed</span>"
    }

    #$formatTime = [String]::format("{0:%m}m {0:%s}s {0:%ffff}ms", [TimeSpan] $test.Time)

    $formatTime =  Get-HumanTime $test.Duration.TotalSeconds

    $TestResultsTable += "
        <tr>
            <td>$status</td>
            <td>$($test.Path[0])</td>
            <td>$($test.Path[1])</td>
            <td>$($test.Name)</td>
            <td>$($test.ErrorRecord[0])</td>
            <td>$formatTime</td>
        </tr>
    "
}

# Create Script Analyzer Table
foreach ($issue in $ScriptAnalyzer)
{
    if($issue.Severity -eq "1")
    {
        $status = "<span class='label label-warning'>Warning</span>"
    }
    else
    {
        $status = "<span class='label label-danger'>Error</span>"
    }

    $ScriptAnalysisTable += "
    <tr>
        <td>$status</td>
        <td>$($issue.RuleName)</td>
        <td>$($issue.ScriptName)</td>
        <td>$($issue.Line)</td>
        <td>$($issue.Column)</td>
        <td>$($issue.Message)</td>
    </tr>
    "
}

#Keep track of single file coverage so we only iterate once
$FileCoverage = @{}

$PackagesCovered = $coverage.report.package

foreach($package in $PackagesCovered) 
{
    foreach($file in $package.sourceFile) 
    {
        $path = (Join-Path $package.Name $file.Name)
        $FileCoverage[$path] = $file
    }
}

# Create Script for Coverage Table (missed)
Add-Type -AssemblyName System.Web
foreach($path in ($FileCoverage.keys | Sort-Object))
{
    $fileContent = Get-Content $path
    $fileCovered = $FileCoverage[$path]

    if ($fileCovered.counter[1].missed -gt 0)
    {
        for($i=0; $i -le $fileContent.length; $i++)
        {
            $command = [System.Web.HttpUtility]::HtmlEncode($fileContent[$i])
    
            $line = ($fileCovered.line | Where-Object nr -eq ($i+1))
    
            $isCovered = ($line -and $line.mi -eq 0 -and $line.ci -ge 1) -or (!$line)
    
            $labelClass = if($isCovered) { "success" } else { "warning" }
            $label = if($isCovered) { "Hit" } else { "Missed" }
            $color = if($isCovered) { $Colors.GREEN } else { $Colors.YELLOW }
    
            $CoverageTable += "
                <tr class='code-line'>
                    <td><span class='label label-$($labelClass)'>$($label)</span></td>
                    <td>$($path)</td>
                    <td>$($i+1)</td>
                    <td>Unknown</td>
                    <td><pre $(if(!$isCovered) { "style='background-color:$color'" })>$($command)</pre></td>
                </tr>
            "    
        }
    
    
    }

    # foreach($line in $fileCovered.line)
    # {
    #     $command = [System.Web.HttpUtility]::HtmlEncode($fileContent[$line.nr])

    #     $CoverageTable += "
    #         <tr>
    #             <td><span class='label label-warning'>Missed</span></td>
    #             <td>$($fileCovered.Name)</td>
    #             <td>$($line.nr)</td>
    #             <td>Unknown</td>
    #             <td><pre style='border:1px solid $($Colors.YELLOW); background-color: transparent;'>$($command)</pre></td>
    #         </tr>
    #     "
    
    # }
}

# Create Script for Coverage Table (hit) 
foreach($hit in $Pester.CodeCoverage.HitCommands)
{
    if($ShowHitCommands)
    {
        $command = [System.Web.HttpUtility]::HtmlEncode($hit.Command)

        $CoverageTable += "
            <tr>
                <td><span class='label label-success'>Hit</span></td>
                <td>$($hit.File)</td>
                <td>$($hit.Line)</td>
                <td>$($hit.Function)</td>
                <td><pre style='border:1px solid $($Colors.GREEN); background-color: transparent;'>$command</pre></td>
            </tr>
        "
    }

   $FileCoverage[$hit.File].Hit++
}

# Create File Tested Table
# TODO: Add coverage % calcs for each file?
foreach($file in $FileCoverage.values | Sort-Object Name)
{
    $total = ([int]$file.counter[0].covered + [int]$file.counter[0].missed)
    $coverageAmount = [Math]::Round(([int]$file.counter[0].covered / [int]$total) * 100)
    
    if($coverageAmount -lt 10)
    {
       $color = "progress-bar-danger"
    }
    elseif($coverageAmount -lt 50)
    {
        $color = "progress-bar-warning"
    }
    else
    {
        $color = "progress-bar-success"
    }

    $FilesTestedTable += "
        <tr>
        <td>
            <span>$($file.Name)</span>
            <div class='progress' style='margin-bottom:0;'>
                <div class='progress-bar $color' role='progressbar' aria-valuenow='$coverageAmount' aria-valuemin='0' aria-valuemax='100' style='width: $coverageAmount%; min-width: 2em;'>$coverageAmount %</div>
            </div>
        </td>
        </tr>
    "
}

$OverallCoverage = [Math]::Floor(([int]$Coverage.report.counter[0].covered / ([int]$Coverage.report.counter[0].missed + [int]$Coverage.report.counter[0].covered)) * 100)


# Determine Pester overall status
if($Pester.FailedCount -eq 0)
{
    # If the switch $FailOnSkippedOrPending is set, any skipped or pending tests will fail the build.
    if ($FailOnSkippedOrPending -and ($Pester.PendingCount -ne 0) -and ($Pester.SkippedCount -ne 0) ) 
    {
        $PesterPassed = $false
    }
    else
    {
        $PesterPassed = $true
    }
}
else
{
    $PesterPassed = $false
}

# Replace Everything in html template and output report
$Replace = @{
    # Custom
    REPO = $GitRepo
    REPO_URL = $GitRepoURL
    CI_BUILD_URL = $CiURL
    NUMBER_OF_PS1_FILES = (Get-ChildItem -Recurse -Include *ps1 | Measure-Object).Count
    BUILD_NUMBER = $BuildNumber
    BUILD_DATE = Get-Date -Format u
    COMMIT_HASH = Get-GitCommitHash -Length 10

    # Generated 
    BUILD_RESULT = if($OverallCoverage -ge $Compliance -and $PesterPassed) {"PASSED"} else {"FAILED"}
    BUILD_RESULT_COLOR = if($OverallCoverage -ge $Compliance -and$PesterPassed) {"panel-success"} else {"panel-danger"}
    BUILD_RESULT_ICON = if($OverallCoverage -ge $Compliance -and $PesterPassed) {"fa-check"} else {"fa-times"}

    TEST_TABLE = $TestResultsTable
    FILES_TESTED_TABLE = $FilesTestedTable
    SCRIPT_ANALYSIS_TABLE = $ScriptAnalysisTable
    COVERAGE_TABLE = $CoverageTable
    TEST_OVERALL = [Math]::Round(($Pester.PassedCount/$Pester.TotalCount) * 100, 0)
    TEST_OVERALL_COLOR = if($Pester.FailedCount -eq 0) {$Colors.GREEN} else {$Colors.RED}
    COVERAGE_OVERALL = [Math]::Round($OverallCoverage, 0)
    COVERAGE_OVERALL_COLOR = if($OverallCoverage -lt 10) {$Colors.RED} elseif($OverallCoverage -lt 50) {$Colors.YELLOW} else {$Colors.GREEN} 

    # Pester
    TOTAL_COUNT = $Pester.TotalCount
    PASSED_COUNT = $Pester.PassedCount
    FAILED_COUNT = $Pester.FailedCount
    SKIPPED_COUNT = $Pester.SkippedCount
    PENDING_COUNT = $Pester.PendingCount
    NUMBER_OF_COMMANDS_ANALYZED = [int]$Coverage.report.counter[0].covered + [int]$Coverage.report.counter[0].missed
    NUMBER_OF_FILES_ANALYZED = [int]$Coverage.report.counter[3].covered + [int]$Coverage.report.counter[3].missed
    NUMBER_OF_COMMANDS_EXECUTED = [int]$Coverage.report.counter[0].covered
    NUMBER_OF_COMMANDS_MISSED = [int]$Coverage.report.counter[0].missed

    # Script Analyzer
    SA_ERROR_COUNT = ($ScriptAnalyzer | where-object {$_.Severity -eq "2"} | Measure-Object).Count
    SA_WARNING_COUNT = ($ScriptAnalyzer | where-object {$_.Severity -eq "1"} | Measure-Object).Count
}

$template = (Get-Content $templateFile) 
foreach ($var in $Replace.GetEnumerator())
{
    # Write-Host "Replacing: $($var.key)"
    $template = $template | ForEach-Object { $_.replace( "{$($var.key)}", $var.value ) }  
}

$template | Set-Content (Join-Path $OutputDir "TestReport.htm")