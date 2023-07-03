# Import the needed credential and management objects from the libraries.
import os
# Import for pass generation
import secrets
import string

from azure.identity import AzureCliCredential
from azure.mgmt.compute import ComputeManagementClient

print(
    "Updating a virtual machine...some operations might take a \
minute or two."
)

# Step 1: Declare variables
# Retrieve subscription ID from environment variable.
subscription_id = os.environ["AZURE_SUBSCRIPTION_ID"]

# Prefix
PREFIX = "az-vm-01"

# RG name and Location
RESOURCE_GROUP_NAME = "rg-python-test"
LOCATION = "eastus"

# VM name and credentials
VM_NAME = PREFIX
VM_SIZE = "Standard_B2ms"
NEW_VM_SIZE = "Standard_B2s"

# Step 2: Initialize the Azure SDK clients:
# Acquire a credential object using CLI-based authentication.
credential = AzureCliCredential()
# Obtain the management object for virtual machines
compute_client = ComputeManagementClient(credential, subscription_id)

# Step 3: Updating the virtual machine
print(
    f"Updating virtual machine {VM_NAME} from {VM_SIZE} to {NEW_VM_SIZE} this operation might \
take a few minutes."
)

VM = compute_client.virtual_machines.get(
    RESOURCE_GROUP_NAME,
    VM_NAME    
)

VM.hardware_profile.vm_size = NEW_VM_SIZE

update_result = compute_client.virtual_machines.begin_create_or_update(
    RESOURCE_GROUP_NAME,
    VM_NAME,
    VM  
)

update_vm = update_result.result()

print(
    f"Virtual machine {update_vm.name} re-sized to new size {NEW_VM_SIZE}"
)