# Manifests & Secrets Management

This directory contains Kubernetes manifests for the PetClinic application and its dependencies.

## Sealed Secrets Setup

We use [Sealed Secrets](https://github.com/bitnami-labs/sealed-secrets) to encrypt secrets so they can be safely stored in Git.

### 1. Install Kubeseal CLI

```bash
wget https://github.com/bitnami-labs/sealed-secrets/releases/download/v0.20.5/kubeseal-0.20.5-linux-amd64.tar.gz
tar -xvf kubeseal-0.20.5-linux-amd64.tar.gz
sudo mv kubeseal /usr/local/bin
sudo chmod +x /usr/local/bin/kubeseal
rm kubeseal-0.20.5-linux-amd64.tar.gz
```

### 2. Install Sealed Secrets Controller

```bash
kubectl apply -f https://github.com/bitnami-labs/sealed-secrets/releases/download/v0.20.5/controller.yaml
```

### 3. Generate Secrets

Generate the Kubernetes Secrets locally (do not commit these plain files):

**MySQL Root Password:**
```bash
kubectl create secret generic mysql-root-password --from-literal=password=admin123 --dry-run=client -o yaml > mysql-root-secret.yaml
```

**MySQL User Password:**
```bash
kubectl create secret generic mysql-user-password --from-literal=password=admin --dry-run=client -o yaml > mysql-user-secret.yaml
```

### 4. Seal Secrets

Fetch the public key and seal the secrets:

```bash
kubeseal --fetch-cert > publickey.pem

kubeseal --format=yaml --cert=publickey.pem < mysql-root-secret.yaml > sealed-mysql-root-secret.yaml
kubeseal --format=yaml --cert=publickey.pem < mysql-user-secret.yaml > sealed-mysql-user-secret.yaml
```

You can now safely commit `sealed-mysql-root-secret.yaml` and `sealed-mysql-user-secret.yaml`.

## Helper Commands

Decode base64 strings:
```bash
echo -n "YWRtaW4=" | base64 -d  # Output: admin
echo -n "YWRtaW4xMjM=" | base64 -d # Output: admin123
```
