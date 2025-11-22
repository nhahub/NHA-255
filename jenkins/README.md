# Jenkins on Kubernetes

This directory contains the manifests and pipeline configuration to deploy Jenkins on a Kubernetes cluster and automate infrastructure provisioning using Terraform.

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
| `jenkinsfile` | Declarative Jenkins pipeline for Terraform automation (Init, Apply). |

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

## Pipeline Configuration

The `jenkinsfile` is designed to run on a Kubernetes agent with the following containers:
- **git**: For checking out source code.
- **terraform**: For running Terraform commands (`init`, `apply`).

### Environment Variables
The pipeline requires the following credentials to be configured in Jenkins:
- `aws-access-key-id`
- `aws-secret-access-key`
