#!/bin/bash
# ─────────────────────────────────────────
#  USERMOD + DOCKER SOCKET — Fix Script
#  Ubuntu 20.04 / 22.04
#
#  Run: sudo bash fix.sh
#
#  What this fixes:
#    Jenkins pipelines failing with:
#    "permission denied /var/run/docker.sock"
#    or "Got permission denied while trying to
#     connect to the Docker daemon socket"
# ─────────────────────────────────────────

set -euo pipefail

echo ""
echo "================================="
echo "  Fix Docker Permissions"
echo "  for Jenkins"
echo "================================="
echo ""
echo "  What is being fixed:"
echo "  Jenkins runs as user 'jenkins'"
echo "  Docker runs as root by default"
echo "  Without this fix, Jenkins cannot"
echo "  run any docker commands"
echo ""

echo "► Step 1 — Check jenkins user exists"
if ! id jenkins &>/dev/null; then
  echo "  ❌ jenkins user not found"
  echo "     Install Jenkins first: cd ../jenkins && sudo bash install.sh"
  exit 1
fi
echo "  ✅ jenkins user: $(id jenkins)"

echo ""
echo "► Step 2 — Check docker group exists"
if ! getent group docker &>/dev/null; then
  echo "  ❌ docker group not found"
  echo "     Install Docker first: cd ../docker && sudo bash install.sh"
  exit 1
fi
echo "  ✅ docker group exists"

echo ""
echo "► Step 3 — Add jenkins to docker group (usermod)"
sudo usermod -aG docker jenkins
echo "  ✅ Command run: sudo usermod -aG docker jenkins"
echo "  ✅ Jenkins groups now: $(groups jenkins)"

echo ""
echo "► Step 4 — Fix docker.sock permissions"
sudo chown root:docker /var/run/docker.sock
sudo chmod 660 /var/run/docker.sock
echo "  ✅ /var/run/docker.sock: $(ls -la /var/run/docker.sock)"

echo ""
echo "► Step 5 — Restart Jenkins to apply group change"
sudo systemctl restart jenkins
sleep 3
sudo systemctl is-active jenkins && echo "  ✅ Jenkins restarted"

echo ""
echo "► Step 6 — Test"
sudo -u jenkins docker ps \
  && echo "  ✅ jenkins user can run docker commands!" \
  || echo "  ⚠️  Still failing — try rebooting the server"

echo ""
echo "================================="
echo "  ✅ PERMISSIONS FIXED"
echo "================================="
echo ""
echo "  Test manually: sudo -u jenkins docker ps"
echo "  Next: read README.md"
echo "================================="
