###############################################################################
# Customize these properties and tasks
###############################################################################
param(
    $Artifacts = './artifacts',
    $ModuleName = 'Eden',
    $ModulePath = "$pwd/Eden",
    $PercentCompliance  = '60'
)

###############################################################################
# Static settings -- no reason to include these in the param block
###############################################################################
$Settings = @{
    SMBRepoName = 'DSCGallery'
    SMBRepoPath = '\\Server01\Repo'

    Author =  "Stewart Armbrecht"
    Owners = "Stewart Armbrecht"
    PackageDescription = "Powershell module to initialize and build serverless applications on Azure."
    Repository = 'https://github.com/stewartarmbrecht/Eden.git'
    Tags = ""

    # TODO: fix any redudant naming
    GitRepo = "stewartarmbrecht/Eden"
    CIUrl = "http://jenkins/job/Eden/"
}

###############################################################################
# Before/After Hooks for the Core Task: Clean
###############################################################################

# Synopsis: Executes before the Clean task.
task BeforeClean {}

# Synopsis: Executes after the Clean task.
task AfterClean {}

###############################################################################
# Before/After Hooks for the Core Task: Analyze
###############################################################################

# Synopsis: Executes before the Analyze task.
task BeforeAnalyze {}

# Synopsis: Executes after the Analyze task.
task AfterAnalyze {}

###############################################################################
# Before/After Hooks for the Core Task: Archive
###############################################################################

# Synopsis: Executes before the Archive task.
task BeforeArchive {}

# Synopsis: Executes after the Archive task.
task AfterArchive {}

###############################################################################
# Before/After Hooks for the Core Task: Publish
###############################################################################

# Synopsis: Executes before the Publish task.
task BeforePublish {}

# Synopsis: Executes after the Publish task.
task AfterPublish {}

###############################################################################
# Before/After Hooks for the Core Task: Test
###############################################################################

# Synopsis: Executes before the Test Task.
task BeforeTest {}

# Synopsis: Executes after the Test Task.
task AfterTest {}