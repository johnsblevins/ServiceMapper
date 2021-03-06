<#  
.SYNOPSIS  
    Gather Network Connection Info (Source IP, Destination IP and Port Number) over Specified Collection Interval  
.DESCRIPTION  
    This script looks at connections made to/from the system and aggregates the Source IP, Destination IP and Port information for all established IP4 connections.  The collected data is exported to a CSV file. 
.NOTES  
    File Name  : Invoke-RemoteCollection.ps1  
    Author     : John Blevins
    Requires   : PowerShell V2 CTP3  
.LINK  
#>

param (
    [Parameter(Mandatory=$false)]
    [string] 
    $connDir = "",

    [Parameter(Mandatory=$false)]
    [switch] 
    $enableLoop,

    [Parameter(Mandatory=$false)]
    [int] 
    $loopCount = 5,

    [Parameter(Mandatory=$false)]
    [int] 
    $loopFreqSecs = 5,

    [Parameter(Mandatory=$true)]
    [string] 
    $sysFilepath # Path to systems  file (a text file with one system name per line)
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