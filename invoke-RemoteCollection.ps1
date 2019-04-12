<#
    .DESCRIPTION
    
    $connDir # Directory to store output CSV file without trailing /
    $loopCount = 20 # Number of Times to Loop
    $loopFreqSecs = 10 # Number of Seconds to wait between loops

    .NOTES
        AUTHOR: 
        LASTEDIT: 
#>

param (
    [Parameter(Mandatory=$false)]
    [string] 
    $connDir = "c:\temp\conns",

    [Parameter(Mandatory=$false)]
    [switch] 
    $enableLoop = $true,

    [Parameter(Mandatory=$false)]
    [int] 
    $loopCount = 5,

    [Parameter(Mandatory=$false)]
    [int] 
    $loopFreqSecs = 5,

    [Parameter(Mandatory=$false)]
    [string] 
    $sysFilepath = "systems.txt",

    [Parameter(Mandatory=$false)]
    [string] 
    $collFilepath = "c:\temp\ConnCollection"

)

if ( test-path $sysFilepath )
{
    $systems = @(Get-Content $sysFilepath)
}

foreach($system in $systems)
{ 
$script = [scriptblock]::create( @"
param(`$connDir,`$enableLoop,`$loopCount,`$loopFreqSecs) 
&{ $(Get-Content get-ConnectionInfo.ps1 -delimiter ([char]0)) } @PSBoundParameters
"@ )
    Invoke-Command -AsJob $system -Script $script -Args $connDir, $enableLoop, $loopCount, $loopFreqSecs    
}


# Run this again once remote jobs are complete to collect all of the CSV files from the remote machines
foreach($system in $systems)
{
    $connDirUnc="\\$system\" + $connDir.Replace(":","$")
    if ( -not ( test-path $collFilepath ) )
    {
        Mkdir $collFilepath
    }

    Copy-Item ($connDirUnc+"\*.csv") -Destination $collFilepath -include "*.csv" -Recurse
}