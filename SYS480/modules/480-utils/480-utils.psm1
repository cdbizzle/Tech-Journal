function 480Banner()
{
    $banner = @"
    ____  _____ ____ _  _    ___   ___        _   _ _____ ___ _     ____                  
    / ___|| ____/ ___| || |  ( _ ) / _ \      | | | |_   _|_ _| |   / ___|                 
    \___ \|  _|| |   | || |_ / _ \| | | |_____| | | | | |  | || |   \___ \                 
     ___) | |__| |___|__   _| (_) | |_| |_____| |_| | | |  | || |___ ___) |                
    |____/|_____\____|  |_|  \___/ \___/       \___/  |_| |___|_____|____/                 
           _ _   _           _                            __      _ _     _         _      
      __ _(_) |_| |__  _   _| |__   ___ ___  _ __ ___    / /__ __| | |__ (_)_______| | ___ 
     / _` | | __| '_ \| | | | '_ \ / __/ _ \| '_ ` _ \  / / __/ _` | '_ \| |_  /_  / |/ _ \
    | (_| | | |_| | | | |_| | |_) | (_| (_) | | | | | |/ / (_| (_| | |_) | |/ / / /| |  __/
     \__, |_|\__|_| |_|\__,_|_.__(_)___\___/|_| |_| |_/_/ \___\__,_|_.__/|_/___/___|_|\___|
     |___/                                                                                 
"@
Write-Host $banner
}
function 480Connect([string] $server)
{
    $con = $global:DefaultVIServer
    if ($con){
        $msg = "Already connected to {0}" -f $con
        Write-Host $msg -ForegroundColor Green
    } else {
        $con = Connect-VIServer -Server $server
    }
}
function 480fullClone()
{
# Assign variables
$name = Read-Host "Which VM would you like to create a base VM for"
$vm = Get-VM -Name $name
$snapshot = Get-Snapshot -VM $vm -Name "base"
$vmhost = Get-VMHost -Name "192.168.7.16"
$ds = Get-Datastore -Name "datastore2"
$linkedname = "{0}.linked" -f $vm.name

# Build the temporary VM
$linkedvm = New-VM -LinkedClone -Name $linkedname -VM $vm -ReferenceSnapshot $snapshot -VMHost $vmhost -Datastore $ds

# Build the new VM
$newvm = New-VM -Name "$name.V2" -VM $linkedvm -VMHost $vmhost -Datastore $ds

# Take a new snapshot
$snapshotname = "base"
New-Snapshot -VM $newvm  -Name $snapshotname

# Delete original temporary VM
$linkedvm | Remove-VM

# Print success report
Write-Host "`nNew VM named $newvm has successfully been created"
Write-Host "New snapshot named $snapshotname has successfully been created"
}
function 480linkedClone()
{
# Assign variables
Get-VM | Select-Object Name
$name = Read-Host "Which VM would you like to create a base VM for"
$vm = Get-VM -Name $name
$snapshot = Get-Snapshot -VM $vm -Name "base"
$vmhost = Get-VMHost -Name "192.168.7.16"
$ds = Get-Datastore -Name "datastore2"
$linkedclone = Read-Host "What would you like to name this linked clone"

# Build the temporary VM
$linkedvm = New-VM -LinkedClone -Name $linkedclone -VM $vm -ReferenceSnapshot $snapshot -VMHost $vmhost -Datastore $ds
$linkedvm | Get-NetworkAdapter | Select-Object NetworkName
$netname = Read-Host "What network adapter should $linkedclone be on"
$linkedvm | Get-NetworkAdapter | Set-NetworkAdapter -NetworkName $netname

# Print success report
Write-Host "`nNew linked clone named $linkedclone has successfully been created"
Write-Host "New linked clone named $linkedclone has been set to $netname network adapter"
}
function 480Config([string]$configPath) 
{
    $conf = $null
    # Pull the config path, and send a message if there is no config file found
    if(Test-Path $configPath)
    {
        # Convert from json to variables
        $conf = Get-Content -Raw -Path $configPath | ConvertFrom-Json
        $msg = "Using Configuration at {0}" -f $configPath
        Write-Host $msg -ForegroundColor Green
    }
    else
    {
        Write-Host -ForegroundColor Yellow "No configuration file found at $configPath"
    }
    return $conf
}