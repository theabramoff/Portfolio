# Import the needed credential and management objects from the libraries.
import os

from azure.identity import AzureCliCredential
from azure.mgmt.resource import ResourceManagementClient

# Acquire a credential object using CLI-based authentication.
credential = AzureCliCredential()

# Retrieve subscription ID from environment variable.
subscription_id = os.environ["AZURE_SUBSCRIPTION_ID"]

# Obtain the management object for resources.
resource_client = ResourceManagementClient(credential, subscription_id)

# Provision the resource group.
rg_result = resource_client.resource_groups.create_or_update(
    "rg-python-test", {"location": "eastus"}
)

print(
    f"Provisioned resource group {rg_result.name} in \
        the {rg_result.location} region"
)

# To update the resource group, repeat the call with different properties, such as tags:
rg_result = resource_client.resource_groups.create_or_update(
    "PythonAzureExample-rg",
    {
        "location": "centralus",
        "tags": {"environment": "test", "Owner": "Abramov, Andrew"},
    },
)

print(f"Updated resource group {rg_result.name} with tags")
