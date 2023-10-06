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
