# 🐳 Docker — Install + Configure + Pipeline

---

## PART 1 — Install

```bash
sudo bash install.sh
```

Script does:
1. Removes old Docker versions
2. Adds Docker's official GPG key + apt repo
3. Installs `docker-ce`, `docker-ce-cli`, `containerd.io`
4. Starts Docker service
5. Adds `jenkins` user to `docker` group

**Test it worked:**
```bash
docker run hello-world
sudo -u jenkins docker ps
```

---

## PART 2 — Configure

### Step 1 — Create a Docker Hub account
Go to https://hub.docker.com and create a free account if you don't have one.

### Step 2 — Create a Docker Hub access token
1. Log in to hub.docker.com
2. Click your username (top right) → **Account Settings**
3. Go to **Security** → **New Access Token**
4. Name it: `jenkins-token`
5. Click **Generate** → copy the token (you only see it once!)

### Step 3 — Add Docker Hub credentials in Jenkins
Go to: **Manage Jenkins → Credentials → Global → Add Credentials**
- Kind: `Username with password`
- Username: your Docker Hub username
- Password: paste the access token from step 2
- ID: `dockerhub-creds`
- Description: Docker Hub

Click **Save**.

### Step 4 — Make sure your app has a Dockerfile
Your app repo must have a `Dockerfile` in the root.

Basic example for a Node.js app:
```dockerfile
FROM node:18-alpine
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production
COPY . .
EXPOSE 3000
CMD ["node", "index.js"]
```

Basic example for a Java/Spring Boot app:
```dockerfile
FROM eclipse-temurin:17-jre
WORKDIR /app
COPY target/*.jar app.jar
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]
```

Basic example for a Python Flask app:
```dockerfile
FROM python:3.11-slim
WORKDIR /app
COPY requirements.txt .
RUN pip install -r requirements.txt --no-cache-dir
COPY . .
EXPOSE 5000
CMD ["python", "app.py"]
```

---

## PART 3 — Pipeline Code

Copy the `pipeline/Jenkinsfile` into your **app repo root** (rename it to `Jenkinsfile`).

### What to change in the file

Open `pipeline/Jenkinsfile` and fill in these values at the top:

```groovy
def DOCKER_HUB_USER = "your-dockerhub-username"  // ← your Docker Hub username
def IMAGE_NAME      = "my-app"                    // ← name for your image
                                                  //   e.g. "backend-api", "frontend-app"
```

### What the pipeline does

```
Checkout code
     ↓
docker build -t your-username/my-app:v42 .
     ↓
docker push your-username/my-app:v42
     ↓
Clean up local image
```

### Full pipeline stages explained

| Stage | Command it runs | What it does |
|-------|----------------|--------------|
| Checkout | `git checkout` | Gets your code from Git |
| Build Image | `docker build` | Creates the Docker image |
| Push Image | `docker push` | Uploads image to Docker Hub |
| Cleanup | `docker rmi` | Frees disk space on Jenkins server |

---

## Useful Commands

```bash
# See running containers
docker ps

# See all images
docker images

# Free up disk space (removes unused images)
docker system prune -a

# Check Docker is running
sudo systemctl status docker
```

---

## Common Problems

| Problem | Fix |
|---------|-----|
| `permission denied` when running docker | Run `sudo usermod -aG docker jenkins` then restart Jenkins |
| `Cannot connect to Docker daemon` | Run `sudo systemctl start docker` |
| Image push fails with 401 | Check your Docker Hub credentials in Jenkins are correct |
