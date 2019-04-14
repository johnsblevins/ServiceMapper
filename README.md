# ServiceMapper
## Clone the repository
* Install GIT from https://git-scm.com/.
* Launch GIT Command line and run the following:
```
git clone https://github.com/johnsblevins/ServiceMapper.git
cd ServiceMapper
```
## Get Connection Info
Get-ConnectionInfo can be run on a server.  It takes the following parameters:
```
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

