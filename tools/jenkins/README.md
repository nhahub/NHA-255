# Jenkins on Kubernetes

This directory contains the manifests and pipeline configurations to deploy Jenkins on a Kubernetes cluster and automate both application builds and infrastructure provisioning.

## Overview

This setup deploys a Jenkins controller in the `devops-tools` namespace and configures it to spawn dynamic agents on Kubernetes for build execution.

## Prerequisites

- A running Kubernetes cluster (e.g., Minikube, EKS, AKS).
- `kubectl` configured to communicate with your cluster.
- `devops-tools` namespace created:
  ```bash
  kubectl create namespace devops-tools
  ```

## Files Description

| File | Description |
|------|-------------|
| `jenkins-deployment.yaml` | Deploys the Jenkins controller (StatefulSet/Deployment) with persistent storage mounts. |
| `jenkins-service.yaml` | Exposes Jenkins UI on NodePort `32000` and JNLP on port `50000`. |
| `jenkins-ServiceAccount.yaml` | Configures RBAC permissions (`jenkins-admin`) allowing Jenkins to manage pods. |
| `jenkins-volume.yaml` | Defines `PersistentVolume` and `PersistentVolumeClaim` for data persistence. |
| `jenkinsfile` | Declarative Jenkins pipeline for building and pushing Docker images for the PetClinic application. |
| `jenkinsfile.infra` | Declarative Jenkins pipeline for Terraform infrastructure automation (Init, Apply). |

## Deployment

1. **Apply the manifests:**
   ```bash
   kubectl apply -f .
   ```

2. **Verify the deployment:**
   ```bash
   kubectl get pods -n devops-tools
   ```

## Accessing Jenkins

- **UI:** Access Jenkins at `http://<NodeIP>:32000`
- **Initial Admin Password:**
  ```bash
  kubectl exec -it <jenkins-pod-name> -n devops-tools -- cat /var/jenkins_home/secrets/initialAdminPassword
  ```

## Application Pipeline (`jenkinsfile`)

The main `jenkinsfile` is designed to build and push Docker images for the Spring PetClinic application.

### Pipeline Stages

1. **Checkout** - Clones the repository from GitHub
2. **Build Docker Image and Push to DockerHub** - Uses Kaniko to build and push images with two tags
3. **Send Email** - Sends a notification email with build details

### Kubernetes Agent Containers

The pipeline runs on a Kubernetes agent with the following containers:
- **git** (`alpine/git:latest`) - For checking out source code
- **kaniko** (`gcr.io/kaniko-project/executor:debug`) - For building and pushing Docker images
- **mailer** (`alpine:latest`) - For sending email notifications

### Environment Variables

| Variable | Value | Description |
|----------|-------|-------------|
| `GIT_REPO` | `https://github.com/nhahub/NHA-255.git` | GitHub repository URL |
| `GIT_BRANCH` | `main` | Git branch to checkout |
| `DOCKER_IMAGE` | `mohamedelsayed22/petclinic-depi` | DockerHub image name |
| `DOCKER_TAG` | `${env.BUILD_NUMBER}` | Build number tag |
| `K8S_NAMESPACE` | `default` | Kubernetes namespace |

### Required Credentials

Configure the following credentials in Jenkins:
- **`dockerhub`** - Username/Password credential for DockerHub authentication
- **`gmail`** - Username/Password credential for Gmail SMTP authentication

### Docker Images Built

The pipeline builds the PetClinic application and pushes two tags:
- `mohamedelsayed22/petclinic-depi:${BUILD_NUMBER}` (e.g., `:1`, `:2`, `:3`)
- `mohamedelsayed22/petclinic-depi:latest`

### Email Notifications

After successful build, an email is sent to `mohamedelsayedhussein22@gmail.com` with:
- Job name and build number
- Build URL
- Docker images built with tags
- Git repository and branch information

---

## Infrastructure Pipeline (`jenkinsfile.infra`)

The `jenkinsfile.infra` is designed for infrastructure provisioning using Terraform on AWS.

### Pipeline Stages

1. **Checkout Code** - Clones the repository
2. **Initialize Terraform** - Runs `terraform init`
3. **Terraform Apply** - Provisions infrastructure with auto-approve

### Kubernetes Agent Containers

- **git** (`mcp/git:latest`) - For checking out source code
- **terraform** (`mcp/aws-terraform`) - For running Terraform commands

### Environment Variables

The pipeline requires the following AWS credentials:
- `AWS_ACCESS_KEY_ID` - AWS access key (from Jenkins credentials)
- `AWS_SECRET_ACCESS_KEY` - AWS secret key (from Jenkins credentials)
- `AWS_DEFAULT_REGION` - Set to `es-east-1` (Note: should be `us-east-1`)

### Required Credentials

Configure the following credentials in Jenkins:
- **`aws-access-key-id`** - AWS access key ID
- **`aws-secret-access-key`** - AWS secret access key

### Email Notifications

Build status notifications are sent to `mohamedelsayedhussein22@gmail.com` on both success and failure.
