# Modules schema

####
child_main.tf - core module for Subscription
 - Inside of the file new modules can be switched on / off
providers.tf - config file for providers

child_main.tf is a child module which is called from root module.
the module invoke respective modules described in catalogs in the Subscription.

Respectively, new modules for deployment have to be descrived there in separated catalogs per each resource type, like compute, storage , etc
####
