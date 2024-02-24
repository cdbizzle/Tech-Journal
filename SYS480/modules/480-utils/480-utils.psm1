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
        $msg = "Already connected to {0}`n" -f $con
        Write-Host $msg -ForegroundColor Green
    } else {
        $con = Connect-VIServer -Server $server
    }
}
function 480fullClone([string] $name, $vm, $snapshot, $vmhost, $ds, $linkedname)
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
function 480linkedClone([string] $name, $vm, $snapshot, $vmhost, $ds, $linkedname)
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
        $msg = "`nUsing Configuration at {0}" -f $configPath
        Write-Host $msg -ForegroundColor Green
    }
    else
    {
        Write-Host -ForegroundColor Yellow "No configuration file found at $configPath"
    }
    return $conf
}
function 480pickVM()
{
    Write-Host "Select a VM:"
    $selectedVM = $null
    try {
        $vms = Get-VM -Location $conf.vmFolder
        $index = 1
        foreach($vm in $vms)
        {
            Write-Host [$index] $vm.name
            $index++
        }
        $pickIndex = Read-Host "Which VM [X] would you like to select?"
        
        # Check if the input is a valid number
        if (-not [int]::TryParse($pickIndex, [ref]$null) -or $pickIndex -lt 1 -or $pickIndex -gt $vms.Count) {
            Write-Host "Invalid input. Please enter a valid number.`n" -ForegroundColor Yellow
            # Prompt the user to try again if they gave an invalid input
            $pickIndex = Read-Host "Which VM [X] would you like to select?"
        }
        
        # Return the selected VM
        $selectedVM = $vms[$pickIndex - 1]
        $chosenVM = $selectedVM.name
        Write-Host "`nYou have chosen" -NoNewline
        Write-Host " $chosenVM" -ForegroundColor Green
        return $selectedVM
    }
    catch {
        # Return red error message if the folder is invalid
        Write-Host "Invalid folder: $conf.vmFolder" -ForegroundColor Red
    }
}
function 480pickDS()
{
    # Ask the user to pick a datastore
    $datastores = Get-Datastore | Where-Object { $_.Name -ne $conf.datastore }

    # Display available datastores to the user
    Write-Host "`nChoose from these available datastores:"
    for ($i = 0; $i -lt $datastores.Count; $i++) {
        $index = $i + 1
        Write-Host "[$index] $($datastores[$i].Name)"
    }

    # Prompt the user to pick a datastore index
    $datastoreIndex = Read-Host "`nWhich datastore [X] would you like to select? (default: $($conf.datastore))"

    # Set the selected datastore based on user input
    if ([string]::IsNullOrEmpty($datastoreIndex)) {
        $datastore = $conf.datastore
    } else {
        $datastore = $datastores[$datastoreIndex - 1].Name

    # Check if the input is a valid number
    if (-not [int]::TryParse($datastoreIndex, [ref]$null) -or $datastoreIndex -lt 1 -or $datastoreIndex -gt $datastore.Count) {
        Write-Host "Invalid input. Please enter a valid number.`n" -ForegroundColor Yellow
        # Prompt the user to try again if they gave an invalid input
        $datastoreIndex = Read-Host "Which datastore [X] would you like to select? (default: $($conf.datastore))"
    }
    }

    # Return the chosen datastore
    Write-Host "`nYou have chosen" -NoNewline
    Write-Host " $datastore" -ForegroundColor Green
    return $datastore
}

function 480pickSnapshot()
{   
    Write-Host "`nDisplaying available snapshots for $($selectedVM.Name):"
    $snapshots = $selectedVM | Get-Snapshot | Select-Object -ExpandProperty Name
    for ($i = 0; $i -lt $snapshots.Count; $i++) {
        $index = $i + 1
        Write-Host "[$index] $($snapshots[$i])"
    }

    $snapshotIndex = Read-Host "Which snapshot [X] would you like to select? (default: $($conf.defaultSnapshot))"

    # Set the selected snapshot based on user input
    if ([string]::IsNullOrEmpty($snapshotIndex)) {
        $snapshotName = $conf.defaultSnapshot
    } else {
        # Check if the input is a valid number
        if (-not [int]::TryParse($snapshotIndex, [ref]$null) -or $snapshotIndex -lt 1 -or $snapshotIndex -gt $snapshots.Count) {
            Write-Host "Invalid input. Please enter a valid number.`n" -ForegroundColor Yellow
            # Prompt the user to try again if they gave an invalid input
            $snapshotIndex = Read-Host "Which snapshot [X] would you like to select? (default: $($conf.defaultSnapshot))"
        }
        $snapshotName = $snapshots[$snapshotIndex - 1]
    }

    # Return the chosen snapshot
    Write-Host "`nYou have chosen" -NoNewline
    Write-Host " $snapshotName" -ForegroundColor Green
    return $snapshotName
}

function 480pickHost()
{
    Write-Host "`nDefault host: $($conf.esxiHost)"
    $changeHost = Read-Host "Do you want to change the host? (y/N)"

    if ($changeHost -eq "y") {
        $hostName = Read-Host "Enter the IP of the host you would like to select"
        $esxiHost = $hostName
    } else {
        $esxiHost = $conf.esxiHost
    }

    # Return the chosen host
    Write-Host "`nYou have chosen" -NoNewline
    Write-Host " $esxiHost" -ForegroundColor Green
    return $esxiHost
}