<#  
.SYNOPSIS  
    Gather Network Connection Info (Source IP, Destination IP and Port Number) over Specified Collection Interval  
.DESCRIPTION  
    This script looks at connections made to/from the system and aggregates the Source IP, Destination IP and Port information for all established IP4 connections.  The collected data is exported to a CSV file. 
.NOTES  
    File Name  : Copy-RemoteCollectionData.ps1  
    Author     : John Blevins
    Requires   : PowerShell V2 CTP3  
.LINK  
#>

param (
    [Parameter(Mandatory=$false)]
    [string] 
    $connDir = "",

    [Parameter(Mandatory=$true)]
    [string] 
    $sysFilepath = "",

    [Parameter(Mandatory=$false)]
    [string] 
    $collFilepath = ""

)

if ( test-path $sysFilepath )
{
    $systems = @(Get-Content $sysFilepath)
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