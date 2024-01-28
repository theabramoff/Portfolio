The project is for Azure Firewall Deployment in HUB vnet with Azure Bastion.
The config conciders potential for integration of Azure Application Gateway


Config description:

1. main.tf - general config for common resources and local variables
2. networking.tf - networking resources for the Firewall, bastion, application gateway (not in scope of TF deployment)
3. security.tf - network security group deployment for Azure Bastion
4. firewall.tf - deployment of azure firewall with its policy
5. bastion.tf - Azure Bastion deployment
6. outputs.tf - deployment results as outputs on screen
7. providers.tf - description of terraform provider. Backend is not declared to be stored on S3, hence tf state is localy stored
8. variables.tf - main file where all the variables are described. In order to change any name or sku - this only very file has to be updated 