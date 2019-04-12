$connectionDirectory = "C:\git\ServiceMapper\conns"
$shapes = @{}
$existingConnections = @()

if (Test-Path $connectionDirectory )
{   
    # Create New Visio App and Document 
    $app=New-VisioApplication
    $doc=New-VisioDocument

    # Get All Connection Files (CSVs) and Aggregate Unique entries
    $connectionFiles = Get-ChildItem $connectionDirectory -Filter "*.csv"
    foreach($connectionFile in $connectionFiles)
    {
            $existingConnections += @(Import-Csv -Path $connectionFile.pspath)     
    }
    $existingConnections = $existingConnections | select SourceIP, DestinationIP, Port -Unique
    
    # Get List of Unique IPs to Create Base Drawing (rectangles)
    $sourceIPs = $existingConnections | select -ExpandProperty SourceIP
    $destinationIPs = $existingConnections | select -ExpandProperty DestinationIP
    $IPs = ($sourceIPs+$destinationIPs) | select -Unique
    foreach($IP in $IPs)
    {
        $shapes.Add($IP, (New-VisioShape -Type Rectangle -Points 0,0,2,1))
        $dnsName = Resolve-DnsName $IP -ErrorAction SilentlyContinue
        if ($dnsName)
        {
            Set-VisioText -Text ( $IP + " (" + $dnsName.namehost + ")" )
        }
        else
        {
            Set-VisioText -Text $IP
        }
    }

    # Create Connector Objects
    foreach($existingConnection in $existingConnections)
    {
        # Create Connector
        $shapes.($existingConnection.SourceIP).AutoConnect($shapes.($existingConnection.DestinationIP),4)
        $connector = $doc.Application.ActivePage.Shapes | select -Last 1
        $connector.Cells('EndArrow')=4
        $connector.Text=$existingConnection.Port + "/TCP"
        $color = $existingConnection.Port % 16  
        if ($color -eq 1) { $color = 0 }
        $connector.CellsU("LineColor").FormulaU = "=" + $color
        $connector.add
        
        #Check if Port Layer exists
        if($existingConnection.Port.ToString() -in ( $doc.Application.ActivePage.Layers | select -ExpandProperty NameU ))
        {
            $layer = $doc.Application.ActivePage.Layers | where { $_.NameU -eq $existingConnection.Port.ToString() }
        }
        else
        {
            $layer = $doc.Application.ActivePage.Layers.Add($existingConnection.Port.ToString())
        }
        
        # Add Connector to Port Layer
        $layer.add($connector,0)
        $rootLayer = $doc.Application.ActivePage.Layers | where { $_.NameU -eq "connector" }
        
        #Remove Connector from Generic Connector Layer
        $rootLayer.Remove($connector,1)        
    }
    
    $doc.Application.ActivePage.AutoSizeDrawing()
    $doc.Application.ActivePage.CenterDrawing()
}
