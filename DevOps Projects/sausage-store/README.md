# Project - Sausage-Store

The catalog includes the following:
- sausage-store **(Source Code repo with GitLab pipelines)**
- sausage-store-infrastructure **(Infrastructure repo with GitLab pipeline and usefull tools)**
- sausage-store-versions **(Different versions of delivery the application, Security stage is skipped on purpose)**
    - Simple GitLab CI with Slack notification
    - Multi-stage Gitlab CI/CD via deploy.sh as Systemd Unit service with Slack notification   
    - Multi-stage Gitlab CI generating docker images and CD via deploy.sh as Docker executable on a VM using JWT token to retrieve secrets from Hashicorp vault
    - Multi-stage Gitlab CI generating docker images and CD via deploy.sh as Docker-compose executable on a VM using JWT token to retrieve secrets from Hashicorp vault
    - Multi-stage Gitlab CI generating docker images and CD via deploy.sh as Docker-compose executable on a VM using JWT token to retrieve secrets from Hashicorp vault. Additionally, including blue/green deployment strategy. Frontend image is improved with nginx-proxy.
    - Multi-stage Gitlab CI generating docker images without CD stage and deploy.sh. CD stage processing via ArgoCD in infra repo.

## Main technologies and tools including into the project:

- GitLab as central repo base
- GitLab registry for storing the docker images
- Nexus for storing:
    - Maven images
    - Node js 
    - Helm Charts
- Security stage in CI:
    - SonarQube 
    - GitLab SAST
- Secrets management:
    - HashiCorp Vault
    - GitLab environmnet variables
    - base64 encryption for non-prod deployment
- Infrastructure:
    - Deployment a VM using HashiCorp Terraform
    - Configuration of the VM using Ansible
    - Provisioned shared Kubernetes cluster
- Monitoring:
    - Grafana
    - Prometheus
    - Loki
    - Alertmanager

### Delivery options:
- Manual deployment using Linux commands
- CI/CD with deploy.sh and bash script
- Ansible runbook
- CI/CD with deploy.sh and docker execution
- CI/CD with deploy.sh and docker-compose execution
- CI/CD with deploy.sh and docker-compose execution including blue - green deployment
- Manual deployment on kubernetes using yaml manufests and kubectl command
- Manual deployment on kubernetes helm charts
- GitOps deployment using ArgoCD and Gitlab CI/CD pipeline