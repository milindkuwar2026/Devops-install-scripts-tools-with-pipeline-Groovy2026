# 🔄 ArgoCD — Install + Configure + Pipeline

---

## PART 1 — Install

```bash
bash install.sh
```

Script does:
1. Creates `argocd` namespace in Kubernetes
2. Applies the official ArgoCD install manifest
3. Waits for all pods to be ready
4. Exposes the ArgoCD server
5. Installs ArgoCD CLI on this server
6. Prints the initial admin password

**Before running** — open `install.sh` and change:
```bash
EXPOSE_TYPE="port-forward"  # ← change to "loadbalancer" if on EKS/GKE/AKS
                             #   or "nodeport" for bare metal
```

---

## PART 2 — Configure ArgoCD (do this after install)

### Step 1 — Access the ArgoCD UI

**If using port-forward** (default):
```bash
# Run this in a terminal (keep it open)
kubectl port-forward svc/argocd-server -n argocd 8080:443

# Open in browser:
https://localhost:8080
```

**If using LoadBalancer:**
```bash
# Get the external IP
kubectl get svc argocd-server -n argocd

# Open: https://EXTERNAL_IP
```

### Step 2 — Log in
- Username: `admin`
- Password: printed by the install script. Get it again with:
```bash
kubectl get secret argocd-initial-admin-secret -n argocd \
  -o jsonpath='{.data.password}' | base64 -d
```

### Step 3 — Change the admin password
1. Click username (top right) → **User Info**
2. Click **Update Password**
3. Enter a new strong password

### Step 4 — Log in with the CLI
```bash
argocd login localhost:8080 \
  --username admin \
  --password YOUR_PASSWORD \
  --insecure
```

### Step 5 — Generate an ArgoCD API token for Jenkins
1. In ArgoCD UI → **Settings** → **Accounts**
2. Click **admin** (or create a new service account)
3. Click **Generate Token**
4. Copy the token — looks like: `eyJhbG...`

### Step 6 — Add the ArgoCD token to Jenkins
Go to: **Manage Jenkins → Credentials → Global → Add Credentials**
- Kind: `Secret text`
- Secret: paste your ArgoCD token
- ID: `argocd-token`
- Description: ArgoCD Token

Click **Save**.

### Step 7 — Connect your app's Git repo to ArgoCD

**Option A — In the ArgoCD UI:**
1. Click **Settings** → **Repositories** → **Connect Repo**
2. Connection method: HTTPS
3. Repository URL: `https://github.com/YOUR_ORG/YOUR_REPO.git`
4. If private: enter your GitHub username + personal access token
5. Click **Connect**

**Option B — With the CLI:**
```bash
# Public repo
argocd repo add https://github.com/YOUR_ORG/YOUR_REPO.git

# Private repo
argocd repo add https://github.com/YOUR_ORG/YOUR_REPO.git \
  --username YOUR_GITHUB_USERNAME \
  --password YOUR_GITHUB_TOKEN
```

### Step 8 — Create an ArgoCD Application

This tells ArgoCD: "Watch this Git repo and deploy to this namespace."

**In the UI:**
1. Click **+ New App**
2. Fill in:
   - Application Name: `my-app`       ← write this down, used in Jenkinsfile
   - Project: `default`
   - Sync Policy: `Automatic`
   - Repository URL: your repo
   - Revision: `main`
   - Path: `k8s/` (or wherever your Kubernetes YAML files are)
   - Cluster URL: `https://kubernetes.default.svc`
   - Namespace: `my-app`
3. Click **Create**

**With the CLI:**
```bash
argocd app create my-app \
  --repo https://github.com/YOUR_ORG/YOUR_REPO.git \
  --path k8s/ \
  --dest-server https://kubernetes.default.svc \
  --dest-namespace my-app \
  --sync-policy automated \
  --auto-prune \
  --self-heal
```

### Step 9 — Add Kubernetes manifests to your app repo
ArgoCD needs Kubernetes YAML files to deploy. Add a `k8s/` folder to your repo with at minimum a Deployment and Service:

**`k8s/deployment.yaml`** — the minimum you need:
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-app
  namespace: my-app
spec:
  replicas: 2
  selector:
    matchLabels:
      app: my-app
  template:
    metadata:
      labels:
        app: my-app
    spec:
      containers:
      - name: my-app
        image: YOUR_DOCKERHUB_USER/my-app:latest  # ← ArgoCD updates this tag
        ports:
        - containerPort: 8080
---
apiVersion: v1
kind: Service
metadata:
  name: my-app
  namespace: my-app
spec:
  selector:
    app: my-app
  ports:
  - port: 80
    targetPort: 8080
```

---

## PART 3 — Pipeline Code

Copy `pipeline/Jenkinsfile` into your **app repo root** (name it `Jenkinsfile`).

### What to change at the top

```groovy
def DOCKER_HUB_USER = "your-user"          // ← your Docker Hub username
def IMAGE_NAME      = "my-app"             // ← your image name
def ARGOCD_SERVER   = "argocd.example.com" // ← your ArgoCD server IP or domain
def ARGOCD_APP      = "my-app"             // ← name you gave the app in Step 8
```

### How the pipeline connects to ArgoCD

```
Jenkins builds image → pushes to Docker Hub
    ↓
Jenkins tells ArgoCD:
  "Update the app to use image tag v42"
    ↓
ArgoCD updates the Kubernetes Deployment
    ↓
Kubernetes pulls new image → rolling update
    ↓
Old pods removed, new pods running ✅
```

---

## Useful Commands

```bash
# Start port-forward to access UI
kubectl port-forward svc/argocd-server -n argocd 8080:443

# List all apps
argocd app list

# Check app status
argocd app get my-app

# Manually sync an app
argocd app sync my-app

# Roll back to previous version
argocd app rollback my-app

# Check all pods in argocd namespace
kubectl get pods -n argocd
```

---

## Common Problems

| Problem | Fix |
|---------|-----|
| Can't reach ArgoCD UI | Make sure port-forward is running: `kubectl port-forward svc/argocd-server -n argocd 8080:443` |
| `argocd` command not found | The install script installs it — check: `which argocd` |
| App stuck in Progressing | Run: `argocd app sync my-app --force` |
| App health Degraded | Check pod logs: `kubectl logs -l app=my-app -n my-app` |
| Token auth fails in pipeline | Regenerate token: ArgoCD UI → Settings → Accounts → Generate Token |
