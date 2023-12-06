# Make sure Hyper-V module is imported
Import-Module Hyper-V

# Set the information about the VM being cloned
$name = "rockyBase"
$baseVM = Get-VM -Name $name

# Take a checkpoint of the VM being cloned
$checkpointName = "rockyBasePreClone"
Checkpoint-VM -Name $name -SnapshotName $checkpointName

# Set VHD to read-only
$pathVHD = "C:\Users\Public\Documents\Hyper-V\Virtual hard disks\rockyBase.vhdx"
Set-ItemProperty -Path $pathVHD -Name IsReadOnly -Value $true

# Specify paths for the linked clone configuration and VHDX
$cloneConfigPath = "C:\Users\Public\Documents\Hyper-V\Virtual hard disks\LinkedClones"
$destinationDisk = "C:\Users\Public\Documents\Hyper-V\Virtual hard disks\LinkedClones\$name.vhdx"

# Create the linked clone
$cloneName = $name+"Clone"
New-VHD -ParentPath $pathVHD -Path $destinationDisk -Differencing
New-VM -Name $cloneName -Path $cloneConfigPath -VHDPath $destinationDisk -Generation 2 -MemoryStartupBytes 2GB -SwitchName "LAN-INTERNAL"
