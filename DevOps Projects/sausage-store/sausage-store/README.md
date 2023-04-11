# Sausage Store Final version

## General

The version represents a sausage store running on a shared kubernetes cluster.

The repo includes module-pipeline which triggers child pipelines: backend, backend-report, frontend if any changes are made in the catalogs. 
As an outcome of succesfull pipeline execution - docker image tagged as lates and stored in GitLab container registry. 

Child pipelines include several stages:
- build
- test (for backend and frontend)
- release

SAST are process via SonarQube.

This version of CI does not include CD part. Deployment stage is removed to CI/CD in the infra repo. Deployment process via CI/CD and application installes using GitOPS approach - ArgoCD. 

## Results of Build

The application is conteinerized. Container engine is Docker.

### Frontend

Frontend is based on multy-stage build:
- NPM package manager generates static content for the web-site
- Static content passes to nginx

### Backend

Backend:
- generating jar file

### Backend-report

Backend:
- generating py file

## Technologies used

* Frontend – TypeScript, Angular.
* Backend  – Java 16, Spring Boot, Spring Data.
* Backend-report - Python
* Database – H2.

## Installation guide

The guide below is a general guide "how to" to deal with local deployment.
Installation steps van be used for Dockerfile configuration as well or to use directly in CI/CD pipeline

### Backend

Install Java 16 and maven and run:

```bash
cd backend
mvn package
cd target
java -jar sausage-store-0.0.1-SNAPSHOT.jar
```
### Frontend

Install NodeJS and npm on your computer and run:

```bash
cd frontend
npm install
npm run build
npm install -g http-server
sudo http-server ./dist/frontend/ -p 80 --proxy http://localhost:8080
```

Then open your browser and go to [http://localhost](http://localhost)

### Backend-report

Check respective README in the folder