Multicloud architecture diagram

Model - Hybrid-cloud

Public cloud - Microsoft Azure cloud
Private cloud - on-premises datacenter

Scenario:
- Azure cloud provided - mainly for stateless configuration, like k8s (AKS), Function App, etc.
- On-premises DC - mainly for stateful services, like Databases (I't important die to Russian law and primary data)
- Development should be processed in Azure DevOps (or GitLab, but Azure DevOps is preferable as it has native connectors to Azure services)
- Containers should be stored in Azure Container registry and replicated between regions (if HA required)
- Azure Front Door allows to have geo-distributed public IP and WAF, means traffic can be forwarded based on an end user location
- TF state, ETCD state, other sensitive data can be stored on Azure Storage Account (S3) with different redundancy option (Local or GEO redundant), versioning and backup if required
- Secrets should be stored in Azure Key Vault
 
Advantages:
1. Azure Cloud provider has a lot of different services with variety of regions and different redundancy options
2. Having Stateless configuration in the cloud allows to manage it in agile manner
3. Having Stateful configuration on-premises allows to keep data in safe if it's required by the local law or company's policies
4. Azure DevOps - regional service with high SLA score and native free of charge backup
5. Pay-as-you-go and different partnership options
6. DR plan can be done to other Azure regions or AWS

Disadvantages:
1. Cost should be controlled 
2. Azure backup does not support k8s backup yet or k8s' pvs backup
3. Latency can be an issue (can be adjusted using Azure Express Route, but with significant cost increase)
4. Business impact analysis should be done in advance - based on RTO/RPO, redundancy, backup, etc should be considered
5. Due to sunctions, non-russian cloud providers can be limited