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

table_data = []  # Create a list to store table data

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
            table_data.append([
                vm_name,
                vm_hostname,
                vm_ip,
                vm_power_state,
                vm_num_cpus,
                vm_mem,
            ])

# Define headers for the table
table_headers = ["VM Name", "Hostname", "IP", "Power State", "Number of CPUs", "Memory (GB)"]

# Print the table using tabulate
print(tabulate(table_data, headers=table_headers, tablefmt="simple_grid"))

