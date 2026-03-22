#!/bin/bash
# ─────────────────────────────────────────
#  JENKINS — Install Script
#  Ubuntu 20.04 / 22.04
#  Run: sudo bash install.sh
# ─────────────────────────────────────────

set -euo pipefail

echo ""
echo "================================="
echo "  Installing Jenkins LTS"
echo "================================="
echo ""

echo "► Step 1 — Install Java 17"
sudo apt-get update -y -q
sudo apt-get install -y -q fontconfig openjdk-17-jre
java -version
echo "  ✅ Java ready"

echo ""
echo "► Step 2 — Add Jenkins GPG key"
sudo wget -q -O /usr/share/keyrings/jenkins-keyring.asc \
  https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key
echo "  ✅ Key added"

echo ""
echo "► Step 3 — Add Jenkins repository"
echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] \
https://pkg.jenkins.io/debian-stable binary/" \
  | sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null
echo "  ✅ Repo added"

echo ""
echo "► Step 4 — Install Jenkins"
sudo apt-get update -y -q
sudo apt-get install -y -q jenkins
echo "  ✅ Jenkins installed"

echo ""
echo "► Step 5 — Start Jenkins"
sudo systemctl enable jenkins
sudo systemctl start jenkins
sleep 5
echo "  ✅ Jenkins running"

echo ""
echo "► Step 6 — Get admin password"
PASS=$(sudo cat /var/lib/jenkins/secrets/initialAdminPassword)

echo ""
echo "================================="
echo "  ✅ JENKINS READY"
echo "================================="
echo ""
echo "  URL      : http://$(hostname -I | awk '{print $1}'):8080"
echo "  Password : $PASS"
echo ""
echo "  Next: read README.md for setup steps"
echo "================================="
