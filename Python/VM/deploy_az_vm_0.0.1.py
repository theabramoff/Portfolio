# Import the needed credential and management objects from the libraries.
import os
# Import for pass generation
import secrets
import string

from azure.identity import AzureCliCredential
from azure.mgmt.compute import ComputeManagementClient
from azure.mgmt.network import NetworkManagementClient
from azure.mgmt.network import models as network_models
from azure.mgmt.resource import ResourceManagementClient

print(
    "Provisioning a virtual machine...some operations might take a \
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

# Network and IP address names
VNET_NAME = f"vnet-{PREFIX}"
VNET_IP_ADDRESS_RANGE = "10.0.0.0/16"
SUBNET_NAME = f"snet-{PREFIX}"
SNET_IP_ADDRESS_RANGE = "10.0.0.0/24"
IP_NAME = f"pip-{PREFIX}"
IP_CONFIG_NAME = "ip-config"
NIC_NAME = f"nic-{PREFIX}"
NSG_NAME = f"nsg-{PREFIX}"
# Network Security Group Rule
NSG_SSH_RULE_NAME = "Allow_SSH"

# VM name and credentials
VM_NAME = PREFIX
VM_SIZE = "Standard_B2s"
USERNAME = "sysmgr"

# Define the length and characters allowed in the password
# Define the length of the password
password_length = 12

# Define the allowed characters for each category
uppercase_letters = string.ascii_uppercase
lowercase_letters = string.ascii_lowercase
digits = string.digits
special_characters = string.punctuation

# Define the allowed character set for the password
allowed_characters = uppercase_letters + lowercase_letters + digits + special_characters

# Generate the password
PASSWORD = secrets.choice(uppercase_letters) + \
           secrets.choice(lowercase_letters) + \
           secrets.choice(digits) + \
           secrets.choice(special_characters) + \
           ''.join(secrets.choice(allowed_characters) for _ in range(password_length - 4))

# Shuffle the password to randomize the character order
password_list = list(PASSWORD)
secrets.SystemRandom().shuffle(password_list)
PASSWORD = ''.join(password_list)

# Step 2: Initialize the Azure SDK clients:
# Acquire a credential object using CLI-based authentication.
credential = AzureCliCredential()
resource_client = ResourceManagementClient(credential, subscription_id)
# Obtain the management object for networks
network_client = NetworkManagementClient(credential, subscription_id)
# Obtain the management object for virtual machines
compute_client = ComputeManagementClient(credential, subscription_id)

# Step 3: Provision the resource group
rg_result = resource_client.resource_groups.create_or_update(
    RESOURCE_GROUP_NAME,  
    {
        "location": LOCATION,
        "tags": {"environment": "test", "Owner": "Abramov, Andrew", "Description": "Python test deployment"},
    },
)

print(
    f"Provisioned resource group {rg_result.name} in the {rg_result.location} region"
    )

# Step 4: Provision Networking

# Step 4.1: Deployment of NSG

# Create Network Security Group
nsg_parameters = network_models.NetworkSecurityGroup(
    location=LOCATION
    )
nsg = network_client.network_security_groups.begin_create_or_update(
    RESOURCE_GROUP_NAME, 
    NSG_NAME, 
    parameters = nsg_parameters
).result()

#print("Create Network Security Group:\n{}".format(nsg.name))

print(
    f"Create Network Security Group: {nsg.name}"
)

# Create Network Security Group Rule
nsg_rule_parameters = network_models.SecurityRule(
    protocol='TCP',
    direction='inbound',
    source_address_prefix='*',
    source_port_range='*',
    destination_address_prefix='*',
    destination_port_range=22,
    access='allow',
    priority=200
)
nsg_rule = network_client.security_rules.begin_create_or_update(
    RESOURCE_GROUP_NAME,
    NSG_NAME,
    NSG_SSH_RULE_NAME,
    nsg_rule_parameters
).result()

print(
    f"Create Network Security Group Rule: {nsg_rule.name}"
)

# Step 4.2: Provision vNet
# Provision the virtual network and wait for completion
poller = network_client.virtual_networks.begin_create_or_update(
    RESOURCE_GROUP_NAME,
    VNET_NAME,
    {
        "location": LOCATION,
        "address_space": {"address_prefixes": [VNET_IP_ADDRESS_RANGE]},
    },
)

vnet_result = poller.result()

print(
    f"Provisioned virtual network {vnet_result.name} with address \
prefixes {vnet_result.address_space.address_prefixes}"
)

# Step 4.3: Provision sNet
poller = network_client.subnets.begin_create_or_update(
    RESOURCE_GROUP_NAME,
    VNET_NAME,
    SUBNET_NAME,
    {"address_prefix": SNET_IP_ADDRESS_RANGE},
)
subnet_result = poller.result()

print(
    f"Provisioned virtual subnet {subnet_result.name} with address \
prefix {subnet_result.address_prefix}"
)

# Assiciate with the NSG
subnet_result.network_security_group = {
    "id": nsg.id,
}

subnet_update_result = network_client.subnets.begin_create_or_update(
    RESOURCE_GROUP_NAME, VNET_NAME, SUBNET_NAME, subnet_result
)
subnet = subnet_update_result.result()

print(
    f"Associated Network Security Group '{nsg.name}' with subnet '{subnet.name}'"
)


# Step 4.4: Provision PIP
poller = network_client.public_ip_addresses.begin_create_or_update(
    RESOURCE_GROUP_NAME,
    IP_NAME,
    {
        "location": LOCATION,
        "sku": {"name": "Standard"},
        "public_ip_allocation_method": "Static",
        "public_ip_address_version": "IPV4",
    },
)

ip_address_result = poller.result()

print(
    f"Provisioned public IP address {ip_address_result.name} \
with address {ip_address_result.ip_address}"
)

# Step 5: Provision NIC
poller = network_client.network_interfaces.begin_create_or_update(
    RESOURCE_GROUP_NAME,
    NIC_NAME,
    {
        "location": LOCATION,
        "ip_configurations": [
            {
                "name": IP_CONFIG_NAME,
                "subnet": {"id": subnet_result.id},
                "public_ip_address": {"id": ip_address_result.id},
            }
        ],
    },
)

nic_result = poller.result()

print(
    f"Provisioned network interface client {nic_result.name}"
)

# Step 6: Provision the virtual machine

print(
    f"Provisioning virtual machine {VM_NAME}; this operation might \
take a few minutes."
)

poller = compute_client.virtual_machines.begin_create_or_update(
    RESOURCE_GROUP_NAME,
    VM_NAME,
    {
        "location": LOCATION,
        "storage_profile": {
            "image_reference": {
                "publisher": "Canonical",
                "offer": "UbuntuServer",
                "sku": "16.04.0-LTS",
                "version": "latest",
            }
        },
        "hardware_profile": {"vm_size": VM_SIZE},
        "os_profile": {
            "computer_name": VM_NAME,
            "admin_username": USERNAME,
            "admin_password": PASSWORD,
        },
        "network_profile": {
            "network_interfaces": [
                {
                    "id": nic_result.id,
                }
            ]
        },
    },
)

vm_result = poller.result()

print(
    f"Provisioned virtual machine {vm_result.name}"
)

# Print the generated password
print(
    f"Generated password: {PASSWORD}"
)