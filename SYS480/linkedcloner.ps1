# Initiate connection to server
$vcenter = "vcenter.cole.local"
Connect-VIServer($vcenter)
Write-Host "`nSuccessfully connected to $vcenter"

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
