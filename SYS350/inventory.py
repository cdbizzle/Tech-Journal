import getpass
import json
from pyVim.connect import SmartConnect
from pyVmomi import vim
import ssl

# Disable SSL certificate verification
ssl._create_default_https_context = ssl._create_unverified_context

# Request password from user
pw = getpass.getpass()

# Open and read json file containing user and hostname
with open('data.json') as settings:
    dict = json.load(settings)

for vchost in dict['vcenter']:
    host = vchost['host']
    user = vchost['user']
password = pw
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

# Print VM info
filtered_vms = search(vms, search_name)
for vm in filtered_vms:
    if not vm.config.template:
        vm_name = vm.name
        vm_hostname = vm.summary.guest.hostName
        vm_ip = vm.summary.guest.ipAddress
        vm_power_state = vm.summary.runtime.powerState
        vm_num_cpus = vm.config.hardware.numCPU
        vm_mem = vm.config.hardware.memoryMB / 1024
        print(f"VM Name: {vm_name}\nHostname: {vm_hostname}\nIP: {vm_ip}\nPower State: {vm_power_state}\nNumber of CPUs: {vm_num_cpus}\nMemory in GB: {vm_mem}\n----------------------------------")