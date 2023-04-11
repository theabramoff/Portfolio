# Project - Momo-Store

The catalog includes the following:
- momo-images **(images for the project)**
- momo-store **(Source Code repo with GitLab pipelines)**
- momo-store-infrastructure **(Infrastructure repo with GitLab pipeline and usefull tools)**

Each repo has detailed README.md with instructions.

## Main technologies and tools including into the project:
 
- GitLab as central repo base
- GitLab registry for storing the docker images
- Nexus for storing:
    - Helm Charts
- Security stage in CI:
    - SonarQube 
- Secrets management:
    - GitLab environmnet variables
- Infrastructure:
    - Deployment a kubernetes cluster using HashiCorp Terraform
- Monitoring:
    - Grafana
    - Prometheus
    - Loki
    - Alertmanager

### Delivery - steps:
- CI pipeline generates Docker Images and SonarQube checks the code in Sorce Code repo *momo-store*
- CI/CD pipeline builds Helm-chart and uploads to Nexus repo in infra repo *momo-store-infrastructure*
- CI/CD pipeline triggeres manually and via GitOps deployment using ArgoCD delivers changes to the kubernetes cluster