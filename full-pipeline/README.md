# 🔁 Full Pipeline — Everything Combined

This folder has the **complete end-to-end pipeline** that uses all tools together:

```
Jenkins → SonarQube → Docker → ArgoCD → Kubernetes
```

---

## What's in this folder

| File | What it is |
|------|-----------|
| `pipeline/Jenkinsfile` | Complete pipeline for Java, Node.js, or Python |
| `k8s/deployment.yaml` | Kubernetes Deployment + Service for your app |
| `k8s/config.yaml` | ConfigMap + Secret template |

---

## How to use

### Step 1 — Copy `pipeline/Jenkinsfile` into your app repo root
```bash
cp pipeline/Jenkinsfile  YOUR_APP_REPO/Jenkinsfile
```

### Step 2 — Copy `k8s/` folder into your app repo
```bash
cp -r k8s/  YOUR_APP_REPO/k8s/
```

### Step 3 — Change all the values
Open each file and fill in every `← CHANGE THIS` line.

### Step 4 — Commit and push
```bash
git add Jenkinsfile k8s/
git commit -m "add Jenkins pipeline and k8s manifests"
git push
```

### Step 5 — Create Jenkins job pointing to your repo
- New Item → Pipeline → SCM → Git → your repo URL → Jenkinsfile
- Build Now

---

## Full flow explained

```
You push code to Git
       ↓
Jenkins detects the push (or you click Build Now)
       ↓
Stage 1: Checkout — gets your code
       ↓
Stage 2: Test — runs your unit tests
       ↓
Stage 3: SonarQube Scan — analyses code quality
       ↓
Stage 4: Quality Gate — passes or STOPS HERE if code is bad
       ↓
Stage 5: Build Image — docker build -t your-user/app:v42 .
       ↓
Stage 6: Push Image — docker push to Docker Hub
       ↓
Stage 7: Deploy — tells ArgoCD to update image tag to v42
       ↓
Stage 8: Wait — waits for Kubernetes pods to be healthy
       ↓
Done ✅  New version is live
```
