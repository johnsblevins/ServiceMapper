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

$loopIndex = 1 # Initialize Loop Index
$connFilename = ($env:COMPUTERNAME).tolower() + "-conns.csv" # Initialize Connecton File Name "<server>-conns.csv"
$connFilePath = $connDir + "\" + $connFilename # Build Connection File Path
$processedConns = @() # Initialize Collection for Processed Connection Details

# Create Directory if it doesn't exist
if ( -not ( test-path -Path $connDir ) )
{
    new-item -ItemType Directory -path $connDir
}

do
{
    # Sleep on subsequent Loop Iterations
    if($enableLoop -and $loopIndex -gt 1){ 
        start-sleep -seconds $loopFreqSecs         
    }

    # Get Local Connections in "Established" State excluding IPV6 and Loopback Entries
    $activeConns = @(Get-NetTCPConnection -State Established | Where-Object { $_.LocalAddress -notlike "*:*" -and $_.LocalAddress -notlike "127.*" }  | Select-Object LocalAddress,LocalPort,RemoteAddress,RemotePort)

    # Process Active Connections
    foreach($activeConn in $activeConns)
    {
        $processedConn = new-object System.Object

        # Determine Source IP, Destination IP and Port Number
        if ($activeConn.LocalPort -in 49152..65535 -and $activeConn.RemotePort -notin 49152..65535) # Includes case where local system initiates connection.  This is where the local port is in the dynamice range (49152-65535) but the remote port isn't.
        {
            $SourceIP = $activeConn.LocalAddress
            $DestinationIP = $activeConn.RemoteAddress
            $Port = $activeConn.RemotePort
        }
        else # Includes cases where remote system initiates connection and where it is unknown which side initiates communication.  This is where both the local port and remote port are in the dynamic range 49152-65535.
        {
            $SourceIP = $activeConn.RemoteAddress
            $DestinationIP = $activeConn.LocalAddress
            $Port = $activeConn.LocalPort
        }
        
        # Populate Processed Connection object with Source IP, Destination IP and Port Number and add to Processed Connection Collection
        $processedConn | add-member -type NoteProperty -name SourceIP -value $SourceIP
        $processedConn | add-member -type NoteProperty -name DestinationIP -value $DestinationIP
        $processedConn | add-member -type NoteProperty -name Port -value $Port
        $processedConns += $processedConn
    }

    # Remove duplicate processed connection entries
    $processedConns = $processedConns | Select-Object SourceIP, DestinationIP, Port -Unique

    # Export Processed Data to Connection File
    if (Test-Path $connFilePath ) # Case where connection file already exists
    {
        $existingConnections = @(Import-Csv -Path $connFilePath)
        $props = $existingConnections[0].PSObject.Properties | Select-Object -Expand Name
        $diffConns = @(@(Compare-Object $existingConnections $processedConns -Property $props | Where-Object { $_.SideIndicator -eq '=>' }) | select SourceIP,DestinationIP,Port)
        
        $existingConnections += $diffConns
        $existingConnections | Export-Csv -Path $connFilePath -NoTypeInformation
    }
    else # Case where connection file doesn't exist
    {   
        $diffConns = $processedConns
        $diffConns | ft     
        $diffConns | Export-Csv -Path $connFilePath -NoTypeInformation
    }
    
    # Print Summary of Connections
    "Existing: " + $existingConnections.Count
    "Current: " + $processedConns.Count
    "New: " + $diffConns.Count
    $diffConns | ft

    # Increment Loop Index
    $loopIndex++
}
while( $enableLoop -and $loopIndex -le $loopCount )