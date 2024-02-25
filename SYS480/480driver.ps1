# Import the nessesary module
Import-Module '480-utils' -Force

# Call the banner function
480Banner

# Pull config file
$conf = 480Config -configPath "/home/cole/Tech-Journal/SYS480/480.json"

# Connect to the vCenter server
480Connect -server $conf.vcenterServer

# Select a VM
$selectedVM = 480pickVM

# Select a datastore
$selectedDS = 480pickDS

# Select a snapshot
$selectedSnap = 480pickSnapshot

# Select a host
$selectedHost = 480pickHost

# Take a full clone of the selected VM
480fullClone -vm $selectedVM -ds $selectedDS -host $selectedHost