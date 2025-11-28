# ArgoCD Applications

This directory contains the ArgoCD Application definitions for the PetClinic project.

## Applications

### 1. `argocd` (App of Apps)
- **File:** `argocd.yaml`
- **Description:** This is the "App of Apps" pattern. It points to this very directory (`argocd`) in the Git repository. Its job is to manage other ArgoCD applications defined here.
- **Sync Policy:** Automated (Self-Heal, Prune).

### 2. `monitoring`
- **File:** `monitoring.yaml`
- **Description:** Deploys the `kube-prometheus-stack` Helm chart for cluster monitoring (Prometheus & Grafana).
- **Chart Version:** `79.8.2`
- **Namespace:** `monitoring`

### 3. `petclinic`
- **File:** `Petclind-cd.yaml` (Note: Typo in filename, refers to PetClinic)
- **Description:** Deploys the main PetClinic application manifests.
- **Source:** `manifests` directory.
- **Namespace:** `default` (or as specified in manifests).
