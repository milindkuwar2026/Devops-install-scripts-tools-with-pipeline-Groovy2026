# 🚀 DevOps Setup — Complete Guide

Each folder = one tool.
Inside every folder you get **everything**:
- ✅ `install.sh` — one script to install
- ✅ `README.md` — install steps + configure steps + pipeline code explanation
- ✅ `pipeline/Jenkinsfile` — copy into your app repo and run

---

## 📁 Folders

| Folder | What's inside |
|--------|--------------|
| `jenkins/` | Install Jenkins + configure + basic pipeline |
| `docker/` | Install Docker + give Jenkins access + Docker build/push pipeline |
| `usermod-socket/` | Fix docker permission errors + pipeline to verify the fix |
| `sonarqube/` | Install SonarQube + connect to Jenkins + sonar-project.properties + scan pipeline |
| `argocd/` | Install ArgoCD + connect to Jenkins + k8s manifests + deploy pipeline |
| `full-pipeline/` | ⭐ Everything combined — one Jenkinsfile for the full flow + k8s files |

---

## 🗺️ Setup Order

```
Step 1 → jenkins/           install Jenkins
Step 2 → docker/            install Docker
Step 3 → usermod-socket/    fix docker permissions
Step 4 → sonarqube/         install SonarQube
Step 5 → argocd/            install ArgoCD
Step 6 → full-pipeline/     use the combined Jenkinsfile + k8s files
```

---

## ⭐ Quick Start (already have everything installed?)

Go straight to `full-pipeline/`:
1. Copy `full-pipeline/pipeline/Jenkinsfile` into your app repo root
2. Copy `full-pipeline/k8s/` folder into your app repo
3. Open `Jenkinsfile` → change the CONFIG block at the top
4. Create a Jenkins Pipeline job pointing to your repo
5. Build Now

---

## 📌 Every folder follows the same pattern

```
tool-name/
├── install.sh              ← run this to install
├── README.md               ← PART 1: Install
│                              PART 2: Configure (step by step)
│                              PART 3: Pipeline code (what to change + how it works)
├── pipeline/
│   └── Jenkinsfile         ← copy into YOUR app repo
└── extra files             ← sonar-project.properties, k8s yamls, etc.
```
