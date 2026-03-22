# 🔍 SonarQube — Install + Configure + Pipeline

---

## PART 1 — Install

```bash
sudo bash install.sh
```

Script does:
1. Installs Java 17
2. Sets `vm.max_map_count=262144` (Elasticsearch needs this)
3. Creates a `sonar` system user
4. Downloads + extracts SonarQube
5. Creates a systemd service
6. Starts SonarQube on port 9000

**Access:** `http://YOUR_SERVER_IP:9000`  |  `admin` / `admin`

---

## PART 2 — Configure SonarQube

### Step 1 — Change the default password
Log in → it asks you to change immediately → do it.

### Step 2 — Generate a SonarQube token (Jenkins uses this)
1. Click username (top right) → **My Account** → **Security** tab
2. Generate Tokens → Name: `jenkins-token` → Type: `Global Analysis Token` → **Generate**
3. Copy the token — you only see it once! Looks like: `sqa_abc123...`

### Step 3 — Add token to Jenkins
**Manage Jenkins → Credentials → Global → Add Credentials**
- Kind: `Secret text`
- Secret: paste the token
- ID: `sonar-token`

### Step 4 — Install SonarQube Scanner plugin in Jenkins
**Manage Jenkins → Plugins → Available → search `SonarQube Scanner` → Install → Restart Jenkins**

### Step 5 — Add SonarQube Server in Jenkins
**Manage Jenkins → System → SonarQube Servers → Add SonarQube**
- Name: `SonarQube`  ← exact name, used in Jenkinsfile
- Server URL: `http://localhost:9000`
- Authentication Token: select `sonar-token`
→ **Save**

### Step 6 — Create a project in SonarQube UI
**Projects → Create Project → Manually**
- Project key: `my-app`  ← write this down, used in Jenkinsfile
- Display name: `My App`
→ **Set Up → With Jenkins**

---

## PART 3 — Add sonar-project.properties to your app repo

Pick the right file from `sonar-configs/`, copy it into your app repo root,
rename it to `sonar-project.properties`, and update the two values at the top.

| Language | Template |
|----------|---------|
| Java / Maven | `sonar-configs/sonar-project.properties.java` |
| Node.js / React | `sonar-configs/sonar-project.properties.nodejs` |
| Python | `sonar-configs/sonar-project.properties.python` |

```bash
# Example for Node.js:
cp sonar-configs/sonar-project.properties.nodejs  YOUR_APP/sonar-project.properties
# Then open it and set sonar.projectKey and sonar.projectName
```

---

## PART 4 — Pipeline Code

Copy `pipeline/Jenkinsfile` into your app repo root as `Jenkinsfile`.

**Change these values at the top:**
```groovy
def SONAR_PROJECT_KEY  = "my-app"      // ← same key as Step 6
def SONAR_PROJECT_NAME = "My App"      // ← display name
def DOCKER_HUB_USER    = "your-user"   // ← Docker Hub username
def IMAGE_NAME         = "my-app"      // ← image name
def ARGOCD_SERVER      = "argocd.example.com"
def ARGOCD_APP         = "my-app"
```

**Pipeline flow:**
```
Checkout → SonarQube Scan → Quality Gate → Build Image → Push → Deploy
                                  ↓
                          FAIL = pipeline stops
                          No image built. No deploy. Fix code first.
```

---

## Useful Commands

```bash
sudo systemctl status sonarqube       # check status
sudo systemctl restart sonarqube      # restart
sudo journalctl -u sonarqube -f       # view logs
sudo sysctl -w vm.max_map_count=262144 # fix Elasticsearch error
```

---

## Common Problems

| Problem | Fix |
|---------|-----|
| SonarQube won't start | `sudo sysctl -w vm.max_map_count=262144` |
| Can't reach port 9000 | `sudo ufw allow 9000` |
| Quality Gate always fails | Check SonarQube UI → Projects → your project → Issues tab |
| "SonarQube server not found" in Jenkins | Name in Manage Jenkins → System must be exactly `SonarQube` |
| `sonar-scanner: command not found` | Install SonarQube Scanner plugin in Jenkins |
