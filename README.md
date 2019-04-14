# ServiceMapper
## Clone the repository
* Install GIT from https://git-scm.com/.
* Launch GIT Command line and run the following:
```
git clone https://github.com/johnsblevins/ServiceMapper.git
cd ServiceMapper
```
## Get Connection Info
Get-ConnectionInfo.ps should be run on each server for which you would like to collect data.  
```
<#  
.SYNOPSIS  
    Gather Network Connection Info (Source IP, Destination IP and Port Number) over Specified Collection Interval  
.DESCRIPTION  
    This script looks at connections made to/from the system and aggregates the Source IP, Destination IP and Port information for all established IP4 connections.  The collected data is exported to a CSV file. 
.NOTES  
    File Name  : Get-ConnectionInfo.ps1  
    Author     : John Blevins
    Requires   : PowerShell V2 CTP3  
.LINK  
#>

param (
    [Parameter(Mandatory=$false)]
    [string] 
    $connDir = "connections", # Default to "connections" folder under local directory if not specified

    [Parameter(Mandatory=$false)]
    [switch] 
    $enableLoop, 

    [Parameter(Mandatory=$false)]
    [int] 
    $loopCount = 12, # 12 Loops by default

    [Parameter(Mandatory=$false)]
    [int] 
    $loopFreqSecs = 300 # 5 Minute Interval by default
)
```

When run with no parameters a single execution is peformed.  The output directory for the CSV file can be set to a custom path.  If the enableLoop parameter is specified the script will loop through the specified number of interations with the delay frequency specified.  By default it loops 12 times at a 5 minutes interval if no loopCount or loopFreqSecs are specified.  

```
Get-ConnectionInfo.ps1 -connDir c:\temp\conn -enableLoop -loopCount 10 -loopFreqSecs 25
```

## Collect Connection Info Remotely
Invoke-RemoteCollection.ps1 can be run on a workstation or jump server with access to the source systems and initiates the remote invocation of get-connectioninfo.ps1 on source systems.

```
```
Once the remote collection jobs have completed the Get-RemoteCollectionData.ps1 script can be used to collect the collectoin data files from the remote systems and save them to a single local directory.

```
```

### Create Visio Diagram
The Create-VisioDiagram.ps1 script can be used to generate a Visio diagram of connected systems.  It requires Visio to be installed on the local system where the diagram will be rendered and the Visio powershell module to be installed.  To install the Visio powershell module launch powershell with local admin rights and run the following:
```
install-module visio 
```

When execurting the create-visiodiagram.ps1 script provide the path to the directory where the collectoin data files are stored.
```
```

