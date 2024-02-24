# Initiate connection to server
$vcenter = "vcenter.cole.local"
Connect-VIServer($vcenter)
Write-Host "`nSuccessfully connected to $vcenter"

# Assign variables
$name = Read-Host "Which VM would you like to create a base VM for"
$vm = Get-VM -Name $name
$snapshot = Get-Snapshot -VM $vm -Name "Base"
$vmhost = Get-VMHost -Name "192.168.7.16"
$ds = Get-Datastore -Name "datastore2"
$linkedname = "{0}.linked" -f $vm.name

# Build the temporary VM
$linkedvm = New-VM -LinkedClone -Name $linkedname -VM $vm -ReferenceSnapshot $snapshot -VMHost $vmhost -Datastore $ds

# Build the new VM
$newvm = New-VM -Name "$name.V2" -VM $linkedvm -VMHost $vmhost -Datastore $ds

# Take a new snapshot
$snapshotname = "Base"
New-Snapshot -VM $newvm  -Name $snapshotname

# Delete original temporary VM
$linkedvm | Remove-VM

# Print success report
Write-Host "`nNew VM named $newvm has successfully been created"
Write-Host "New snapshot named $snapshotname has successfully been created"
