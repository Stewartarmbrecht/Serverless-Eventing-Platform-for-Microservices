$Private = @( Get-ChildItem `
    -Path $PSScriptRoot `
    -Exclude Import-PrivateFunctions.ps1 `
    -ErrorAction SilentlyContinue )

foreach($import in $Private)
{
    . $import.fullname
}

