# ⚙️ Jenkins — Install + Configure + Pipeline

---

## PART 1 — Install

### Run this script

```bash
sudo bash install.sh
```

Script does:
1. Installs Java 17
2. Adds Jenkins GPG key + apt repo
3. Installs Jenkins
4. Starts Jenkins service
5. Prints the admin password + URL

---

## PART 2 — Configure Jenkins (do this after install)

### Step 1 — Open Jenkins in browser
```
http://YOUR_SERVER_IP:8080
```

### Step 2 — Unlock Jenkins
Paste the password printed by the install script.
Or get it again:
```bash
sudo cat /var/lib/jenkins/secrets/initialAdminPassword
```

### Step 3 — Install Suggested Plugins
Click **"Install suggested plugins"** and wait.

### Step 4 — Create your admin account
Fill in username, password, email → Save.

### Step 5 — Install extra plugins you need
Go to: **Manage Jenkins → Plugins → Available plugins**

Search and install these:

| Plugin | Why you need it |
|--------|----------------|
| `Docker Pipeline` | Build/push Docker images in pipelines |
| `SonarQube Scanner` | Run SonarQube scans in pipelines |
| `Git` | Checkout code from Git |
| `Pipeline` | Declarative pipeline support |
| `Credentials Binding` | Use secrets safely in pipelines |

### Step 6 — Add credentials Jenkins needs

Go to: **Manage Jenkins → Credentials → Global → Add Credentials**

Add these one by one:

**Docker Hub login:**
- Kind: `Username with password`
- Username: your Docker Hub username
- Password: your Docker Hub password or access token
- ID: `dockerhub-creds`   ← write this down, used in Jenkinsfile

**ArgoCD token:**
- Kind: `Secret text`
- Secret: your ArgoCD API token (get from ArgoCD UI → Settings → Accounts → Generate Token)
- ID: `argocd-token`   ← write this down, used in Jenkinsfile

### Step 7 — Configure Java and Maven tool (for Java projects)
Go to: **Manage Jenkins → Tools**
- Under **JDK**: Add JDK → Name: `JDK-17` → Install automatically → OpenJDK 17
- Under **Maven**: Add Maven → Name: `Maven-3.9` → Install automatically → 3.9.x

---

## PART 3 — Create a Pipeline Job

### Step 1 — Create new job
- Jenkins dashboard → **New Item**
- Enter job name (e.g. `my-app-pipeline`)
- Select **Pipeline** → OK

### Step 2 — Connect to your Git repo
In the Pipeline section:
- Definition: `Pipeline script from SCM`
- SCM: `Git`
- Repository URL: `https://github.com/YOUR_ORG/YOUR_REPO.git`
- Branch: `*/main`
- Script Path: `Jenkinsfile`  ← name of your pipeline file in the repo

### Step 3 — Add Jenkinsfile to your app repo
Copy the pipeline code from `pipeline/Jenkinsfile` (in this folder) into the root of your app repo.
Edit the top section — fill in your values.

### Step 4 — Build
Click **Save** → **Build Now**

---

## PART 4 — Pipeline Code

Copy `pipeline/Jenkinsfile` into the root of your application repo.

**File:** `pipeline/Jenkinsfile`

Open it and change these values at the top:

```groovy
def DOCKER_HUB_USER = "your-dockerhub-username"  // ← your Docker Hub username
def IMAGE_NAME      = "my-app"                    // ← your image name
def ARGOCD_SERVER   = "argocd.example.com"        // ← your ArgoCD server address
def ARGOCD_APP      = "my-app"                    // ← your ArgoCD app name
```

---

## Useful Commands

```bash
# Check Jenkins status
sudo systemctl status jenkins

# Restart Jenkins
sudo systemctl restart jenkins

# View logs
sudo journalctl -u jenkins -f

# Get password again
sudo cat /var/lib/jenkins/secrets/initialAdminPassword
```
