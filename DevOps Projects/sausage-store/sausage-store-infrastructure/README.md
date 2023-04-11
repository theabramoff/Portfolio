# Infrastructure 

The catalog **sausage-store-infrastructure** includes several sub catalogs for overall infrastructure configuration:

## Installing the app to a cloud VM using Ansible 
- terraform
    - IaC baseline for VM deployment
    - State is stored on S3
    - Module structure is in place 
    - respective README is in place with description
- ansible
    - VM configuration and app installation 
    - respective README is in place with description
- backup
    - options for backup setup and log rotation
- database
    - potential indexing

## Installing the app to a shared kubernetes cluster with monitoring tools 
- kubernetes
- helm
- argocd
- monitoring-tools

## Explaining multicloud concept (Hybrid mode)
- multicloud

## Getting started

The repo has GitLab CI/CD pipeline.
The pipeline includes 3 stages:
  - build
  - release
  - deploy

The main idea is to build a helm chart, push it to Nexus repo and then trigger ArgoCD to pull helm chart from Nexus repo.
Helm charts are located in **helm** catalog.

Catalog **kubernetes** is for manual Kubernetes app installation.
It has own dedicated pipeline for application delivery from Gitlab (alternative pipeline)

The application is complemented with VPA for backend and HPA for microservice. Connectivity is configured with ingress.
As the k8s cluster is shared, then a shared cert-manager is used. 

As the deployment is purely dev secrets are encrypted in based64 only. For PRD deployment it's strongly recommended to use HarshiCorp vault integration. 

## Connectivity

As an ingress controller we use Nginx.
As Frontend container is based on nginx and passed to it static content, we use *ConfigMap* with respective **nginx config**.

## Monitoring

- alertmanager
    - Sending an alert to telegram channel  
- grafana
    - Providing graphs and business dashboards 
- prometheus
    - Processing service discovery using scrape config and communicating with alert manager 

How to install and configure - please check respective README.md.