# Project structure

└───terraform
    ├───modules
    │   ├───kubernetes
    │   │   └───Example
    │   ├───resourcegroup
    │   ├───single-linux-vm
    │   └───storageaccount
    │       └───Example
    └───resources
        ├───kubernetes
        │   └───we
        ├───storage
        │   └───we
        └───vm
            └───we

####
backend.tf 
    - Configuring external state on S3
root_main.tf
    - Root module for the project
variables.tf
    - env. variables from Azure pipeline and Azure Key Vault. If sometheing wrong with them - It will not work 
####
