# 🔑 usermod & Docker Socket — Fix + Explanation + Pipeline

---

## PART 1 — What is this and why do you need it?

### The problem
When Jenkins tries to run Docker commands in a pipeline, you get this error:
```
Got permission denied while trying to connect to the Docker daemon socket
at unix:///var/run/docker.sock
```

### Why does this happen?

```
Docker daemon  ←→  /var/run/docker.sock  ←→  whoever talks to Docker
                         ↑
                   This file is owned by root:docker
                   Jenkins runs as the "jenkins" OS user
                   "jenkins" is NOT in the docker group by default
                   → Jenkins cannot touch this socket → permission denied
```

### The fix: two things

**1. usermod** — add `jenkins` user to the `docker` group:
```bash
sudo usermod -aG docker jenkins
```
`-a` = append (don't remove from other groups)
`-G` = supplementary groups to add to

**2. Fix the socket** — make sure the file has correct permissions:
```bash
sudo chown root:docker /var/run/docker.sock
sudo chmod 660 /var/run/docker.sock
```

After this: jenkins user → is in docker group → can read/write docker.sock → can run docker commands ✅

---

## PART 2 — Run the fix

```bash
sudo bash fix.sh
```

Script does:
1. Checks `jenkins` user exists
2. Checks `docker` group exists
3. Adds `jenkins` to `docker` group (`usermod -aG docker jenkins`)
4. Fixes `/var/run/docker.sock` ownership and permissions
5. Restarts Jenkins to apply the group change
6. Tests that `jenkins` user can now run docker

**Test it worked:**
```bash
sudo -u jenkins docker ps
# Should show a table — NOT a permission error
```

---

## PART 3 — Special case: Jenkins running as a Docker container

If Jenkins itself runs inside Docker, the usermod approach doesn't apply.
Instead, **mount the socket into the Jenkins container**:

```bash
docker run -d \
  --name jenkins \
  -p 8080:8080 \
  -p 50000:50000 \
  -v jenkins_home:/var/jenkins_home \
  -v /var/run/docker.sock:/var/run/docker.sock \
  jenkins/jenkins:lts
```

The key line:
```
-v /var/run/docker.sock:/var/run/docker.sock
```
This makes the host's Docker socket available inside the Jenkins container.

---

## PART 4 — Pipeline Code

Once the fix is applied, this is how you use Docker inside a Jenkins pipeline.

Copy `pipeline/Jenkinsfile` into your app repo root.

### What to change:
```groovy
def DOCKER_HUB_USER = "your-dockerhub-username"  // ← CHANGE THIS
def IMAGE_NAME      = "my-app"                    // ← CHANGE THIS
```

### The pipeline builds and pushes an image:
```
Checkout
   ↓
docker build -t your-user/my-app:v1 .
   ↓
docker push your-user/my-app:v1
   ↓
Clean up
```

---

## Manual Commands (if you prefer to run manually)

```bash
# Add jenkins to docker group
sudo usermod -aG docker jenkins

# Fix socket permissions
sudo chown root:docker /var/run/docker.sock
sudo chmod 660 /var/run/docker.sock

# Restart Jenkins
sudo systemctl restart jenkins

# Test
sudo -u jenkins docker ps
```

---

## Common Problems

| Problem | Fix |
|---------|-----|
| `groups jenkins` doesn't show docker | Run `sudo usermod -aG docker jenkins` and restart Jenkins |
| Still getting permission denied after fix | Reboot the server — group changes sometimes need a full reboot |
| `/var/run/docker.sock` not found | Docker is not running: `sudo systemctl start docker` |
