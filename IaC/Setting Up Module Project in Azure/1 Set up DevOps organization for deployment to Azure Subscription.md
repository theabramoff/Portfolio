1. Create SPN on Azure AD
2. RBAC to be provided for the SPN at subscription level
3. Create DevOps organization
4. Provide Basic license, create new project
5. Create new service connection from the organization to subscription (SPN has to be a proper access at the subscription level)
6. In the project create new REPO
7. From VSCode new repo to be set up as remote
8. Create shared TF resources:
	- Resource group for storing tf resources (below)
	- Storage account for tf state
	- Azure Key vault for SPN secrets
9. Set up secrets on Azure Key vault:
- Storage key 1 - `satrfmstate-key1`
- Storage key 2 - `satrfmstate-key2`
- SPN Client ID - `sp-client-id`
- SPN Object ID - `sp-object-id`
- SPN Tenant ID - `sp-tenant-id`
- SPN Secret - `sp-secret`
10. In Azure Key vault, key vault access policy to be created for the SPN with following permission:
	- GET
	- LIST
11. Create a Variable group on Azure DevOps project (Pipelines blade --> library) and add all secrets from the Key vault
12. Create 2 Pipelines for TF code validation and TF Plan formation:
	- **Pipeline 1 - Terraform Status Check (Validate & Plan - No Artifacts)**
		-  The Pipeline goes throughout Terraform code
		-  Validating code
		-  Making preliminary plan and showing how it goes (OK or errors)
- **Pipeline 2 - Terraform Plan (starts after Pipeline 2)**
		-  The Pipeline goes throughout Terraform code
		-  Validating code
		-  Making preliminary plan and showing how it goes (OK or errors)
		-  Making artifacts from terraform plan from step 3
		-  Uploading the artifacts to local Artifact repository
13. **Create Release Pipeline**
	- Release Pipeline should consist at least of 2 parts
	- Artifacts
	- Stage for deployment:
	- Extracting files from artifacts (terraform plan)
	- Installing terraform on a runner
	- Initializing terraform
	- Applying terraform plan
	- ***Optional - it's possible to set up extra approval on the Pipeline***