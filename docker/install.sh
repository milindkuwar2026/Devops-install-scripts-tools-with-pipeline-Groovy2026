#!/bin/bash
# ─────────────────────────────────────────
#  DOCKER — Install Script
#  Ubuntu 20.04 / 22.04
#  Run: sudo bash install.sh
# ─────────────────────────────────────────

set -euo pipefail

echo ""
echo "================================="
echo "  Installing Docker CE"
echo "================================="
echo ""

echo "► Step 1 — Remove old Docker versions"
sudo apt-get remove -y docker docker-engine docker.io containerd runc 2>/dev/null || true
echo "  ✅ Cleared"

echo ""
echo "► Step 2 — Install dependencies"
sudo apt-get update -y -q
sudo apt-get install -y -q ca-certificates curl gnupg lsb-release
echo "  ✅ Done"

echo ""
echo "► Step 3 — Add Docker GPG key"
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
  | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg
echo "  ✅ Key added"

echo ""
echo "► Step 4 — Add Docker repository"
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
  https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" \
  | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
echo "  ✅ Repo added"

echo ""
echo "► Step 5 — Install Docker CE"
sudo apt-get update -y -q
sudo apt-get install -y -q docker-ce docker-ce-cli containerd.io \
  docker-buildx-plugin docker-compose-plugin
echo "  ✅ Docker installed: $(docker --version)"

echo ""
echo "► Step 6 — Start Docker"
sudo systemctl enable docker
sudo systemctl start docker
echo "  ✅ Docker running"

echo ""
echo "► Step 7 — Add jenkins user to docker group"
if id jenkins &>/dev/null; then
  sudo usermod -aG docker jenkins
  sudo systemctl restart jenkins
  echo "  ✅ jenkins added to docker group"
else
  echo "  ⚠️  Jenkins not installed yet — run this after Jenkins install:"
  echo "      sudo usermod -aG docker jenkins && sudo systemctl restart jenkins"
fi

echo ""
echo "================================="
echo "  ✅ DOCKER READY"
echo "================================="
echo ""
echo "  Test: docker run hello-world"
echo "  Next: read README.md for pipeline setup"
echo "================================="
