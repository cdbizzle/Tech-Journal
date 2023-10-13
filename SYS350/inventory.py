import getpass
import json
from pyVim.connect import SmartConnect
from pyVmomi import vim
import ssl
from tabulate import tabulate  # Import the tabulate library

# Disable SSL certificate verification
ssl._create_default_https_context = ssl._create_unverified_context

# Request password from user
pw = getpass.getpass()

# Open and read the JSON file containing user and hostname
with open('data.json') as settings:
    config_data = json.load(settings)

table_data2 = []  # Create a list to store table data

for vchost in config_data['vcenter']:
    host = vchost['host']
    user = vchost['user']
    password = pw  # Moved password assignment inside the loop
    port = 443  # Default port for vCenter and ESXi

    # Create a connection
    service_instance = SmartConnect(
        host=host,
        user=user,
        pwd=password,
        port=port,
    )

# Get the current session
current_session = service_instance.content.sessionManager.currentSession

# Retrieve DOMAIN/username, vCenter server, and source IP address
domain_username = current_session.userName
vcenter_server = host
source_ip = current_session.ipAddress

# Get the root folder (datacenter)
content = service_instance.RetrieveContent()
root_folder = content.rootFolder

# Traverse the inventory to find all VMs and their hostnames

# Get the root folder (datacenter)
content = service_instance.RetrieveContent()
root_folder = content.rootFolder

# Traverse the inventory to find all VMs and their hostnames
vm_properties = ["name", "guest.hostName"]
vm_view = content.viewManager.CreateContainerView(
    root_folder, [vim.VirtualMachine], True
)
vms = vm_view.view

# Function to search and filter VMs by name
def search(vms, filter_name=None):
    filtered_vms = []
    for vm in vms:
        if filter_name is None or filter_name.lower() in vm.name.lower():
            filtered_vms.append(vm)
    return filtered_vms

choice = input("Would you like to make changes to any VMs? y/n: ")

if choice == "n":

    # Ask the user for a VM name to filter by
    search_name = input("Enter a VM name to see details or leave empty for all: ")

    # Store VM info in a list of lists
    filtered_vms = search(vms, search_name)
    for vm in filtered_vms:
        if not vm.config.template:
            vm_name = vm.name
            vm_hostname = vm.summary.guest.hostName
            vm_ip = vm.summary.guest.ipAddress
            vm_power_state = vm.summary.runtime.powerState
            vm_num_cpus = vm.config.hardware.numCPU
            vm_mem = vm.config.hardware.memoryMB / 1024
            table_data2.append([
                vm_name,
                vm_hostname,
                vm_ip,
                vm_power_state,
                vm_num_cpus,
                vm_mem,
            ])

    # Create another list to store table data
    table_data1 = []

    # Add data to list
    table_data1.append([
        domain_username,
        vcenter_server,
        source_ip,
    ])

    # Define headers for the table
    table_headers1 = ["DOMAIN\\Username", "vCenter Server", "Source IP Address"]
    table_headers2 = ["VM Name", "Hostname", "IP", "Power State", "Number of CPUs", "Memory (GB)"]

    # Print the table using tabulate
    print(tabulate(table_data1, headers=table_headers1, tablefmt="simple_grid"))
    print(tabulate(table_data2, headers=table_headers2, tablefmt="simple_grid"))

elif choice == "y":
    # Create menu for VM actions
    print("+-------------------+\n| Menu:             |")
    print("| [1] Power On VM   |")
    print("| [2] Power Off VM  |")
    print("| [3] Reboot VM     |")
    print("| [4] Take Snapshot |")
    print("| [5] Clone VM      |")
    print("| [6] Delete VM     |\n+-------------------+")
    menu_choice = input("Enter your choice (1-6): ")
    change_vm = input("Which VM would you like to change: ")

    if menu_choice == "1":
        filtered_vms = search(vms, change_vm)
        for vm in filtered_vms:
            if not vm.config.template:
                # Power on the VM
                vm.PowerOn()
                print(f"Powering on {vm.name}... Done.")
  
    if menu_choice == "2":
        filtered_vms = search(vms, change_vm)
        for vm in filtered_vms:
            if not vm.config.template:
                # Power off the VM
                vm.PowerOff()
                print(f"Powering off {vm.name}... Done.")

    if menu_choice == "3":
            filtered_vms = search(vms, change_vm)
            for vm in filtered_vms:
                if not vm.config.template:
                    # Power off the VM
                    vm.RebootGuest()
                    print(f"Rebooting {vm.name}... Done.")   

    if menu_choice == "4":
        snapshot_name = input("Snapshot name: ")
        snapshot_desc = input("Snapshot description: ")
        filtered_vms = search(vms, change_vm)
        for vm in filtered_vms:
            if not vm.config.template:
                # Take snapshot
                vm.CreateSnapshot(name=snapshot_name, description=snapshot_desc, memory=True, quiesce=False)
                print(f"Taking snapshot of {vm.name}... Done")
    
    # Define 'datacenter' for clone folder
    datacenter = content.rootFolder.childEntity[0]
 
    if menu_choice == "5":
        clone_name = input('What would you like to name the clone: ')
        clone_spec = vim.vm.CloneSpec()
        clone_spec.location = vim.vm.RelocateSpec(datastore=None, host=None, pool=None, diskMoveType="createNewChildDiskBacking")
        clone_folder = datacenter.vmFolder
        filtered_vms = search(vms, change_vm)
        for vm in filtered_vms:
            if not vm.config.template:
                # Clone VM
                vm.CloneVM_Task(folder=clone_folder, name=clone_name, spec=clone_spec)
                print(f"Cloning {vm.name}... Done")

    if menu_choice == "6":
        filtered_vms = search(vms, change_vm)
        for vm in filtered_vms:
            if not vm.config.template:
                # Delete VM
                vm.Destroy_Task()
                print(f"Deleting {vm.name}... Done")