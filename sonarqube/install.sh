#!/bin/bash
# ─────────────────────────────────────────
#  SONARQUBE — Install Script
#  Ubuntu 20.04 / 22.04
#  Run: sudo bash install.sh
#
#  CHANGE IF NEEDED:
#    SONAR_VERSION — update to latest from
#    sonarsource.com/products/sonarqube/downloads
# ─────────────────────────────────────────

SONAR_VERSION="10.4.0.87286"   # ← change to latest version if needed

set -euo pipefail

echo ""
echo "================================="
echo "  Installing SonarQube ${SONAR_VERSION}"
echo "================================="
echo ""

echo "► Step 1 — Install Java 17"
sudo apt-get update -y -q
sudo apt-get install -y -q openjdk-17-jdk unzip wget
echo "  ✅ Java: $(java -version 2>&1 | head -1)"

echo ""
echo "► Step 2 — Set vm.max_map_count (Elasticsearch needs this)"
sudo sysctl -w vm.max_map_count=262144
grep -q "vm.max_map_count" /etc/sysctl.conf \
  || echo "vm.max_map_count=262144" | sudo tee -a /etc/sysctl.conf
echo "  ✅ vm.max_map_count=262144"

echo ""
echo "► Step 3 — Create sonar user (cannot run as root)"
sudo useradd --system --no-create-home --shell /bin/false sonar 2>/dev/null \
  || echo "  ℹ️  sonar user already exists"
echo "  ✅ sonar user ready"

echo ""
echo "► Step 4 — Download SonarQube"
cd /tmp
wget -q --show-progress \
  "https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-${SONAR_VERSION}.zip" \
  -O sonarqube.zip
echo "  ✅ Download complete"

echo ""
echo "► Step 5 — Extract to /opt/sonarqube"
sudo rm -rf /opt/sonarqube
sudo unzip -q /tmp/sonarqube.zip -d /opt
sudo mv /opt/sonarqube-${SONAR_VERSION} /opt/sonarqube
sudo chown -R sonar:sonar /opt/sonarqube
rm /tmp/sonarqube.zip
echo "  ✅ Extracted"

echo ""
echo "► Step 6 — Create systemd service"
sudo tee /etc/systemd/system/sonarqube.service > /dev/null <<UNIT
[Unit]
Description=SonarQube
After=network.target

[Service]
Type=forking
ExecStart=/opt/sonarqube/bin/linux-x86-64/sonar.sh start
ExecStop=/opt/sonarqube/bin/linux-x86-64/sonar.sh stop
User=sonar
Group=sonar
Restart=on-failure
LimitNOFILE=65536

[Install]
WantedBy=multi-user.target
UNIT
echo "  ✅ Service created"

echo ""
echo "► Step 7 — Start SonarQube"
sudo systemctl daemon-reload
sudo systemctl enable sonarqube
sudo systemctl start sonarqube
sudo ufw allow 9000/tcp 2>/dev/null || true
echo "  ⏳ Waiting 40 seconds for SonarQube to boot..."
sleep 40
sudo systemctl is-active sonarqube \
  && echo "  ✅ SonarQube running" \
  || echo "  ⚠️  Still starting — check: sudo journalctl -u sonarqube -n 30"

echo ""
echo "================================="
echo "  ✅ SONARQUBE READY"
echo "================================="
echo ""
echo "  URL      : http://$(hostname -I | awk '{print $1}'):9000"
echo "  Username : admin"
echo "  Password : admin  ← change this on first login!"
echo ""
echo "  Next: read README.md for Jenkins setup + pipeline code"
echo "================================="
