
## DevOps Projects

-  *momo-store* - The catalog provides a full DevOps project.
-  *sausage-store* - The catalog provides a full DevOps project and different options for roll-out.

Each catalog describes the gist of each project, what tech stack is used and how to run it on the web.

Both projects do meet principals of Twelve-Factor App methodology:

 1. Codebase
		*- Centralize GIT Repo for source code is GitLab
		- Git Workflow - Feature Branch workflow*   
 2. Dependencies
		*- All dependencies are declared, e.g. pom.xml in sausage-store
		- Dependencies are isolated with Docker containers*
 3. Config
		*- Variables are declared in the code, but values are stored as environment variables in GitLab or externally in HashiCorp Vault*
 4. Backing services
		*- Datasources and REST APIs are not hardcoded in the source code and declared using variables*
 5. Build, release, run
		*- Each change in the code goes throughout 3 stages every time once main branch is updated.
		- Each release saves with unique name including CI Pipeline ID and SemVer approach*
 6. Processes
		*- Static content is stored outside on S3*
 7. Port binding
		*- Each application component has its own port for work with it*
 8. Concurrency
		*- Each application component has ability to scale out *
 9. Disposability
		*- The applications are reliable and stateless - have minimum impact against shutdown and restart* 
 10. Dev/prod parity
 		*- In the provided examples, there's only a single environment, but in case of several environments it's convenient to organize it *
 11. Logs
  		*- For both Application Logging (Loki), Monitoring (Grafana) and Alerting (Prometheus & Alertmanager) tolls are considered*
 12. Admin processes
   		*- For both Application GitOps approach is in favor using ArgoCD*
