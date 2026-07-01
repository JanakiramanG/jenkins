#!/bin/bash
# =============================================================================
# Jenkins Installation Script — Amazon Linux 2023
# =============================================================================
set -euxo pipefail

# ── System update ─────────────────────────────────────────────────────────────
dnf update -y

# ── Install Java 17 (Jenkins requirement) ────────────────────────────────────
dnf install -y java-17-amazon-corretto-headless

# ── Add Jenkins repository ────────────────────────────────────────────────────
wget -O /etc/yum.repos.d/jenkins.repo \
  https://pkg.jenkins.io/redhat-stable/jenkins.repo

rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key

# ── Install Jenkins ───────────────────────────────────────────────────────────
dnf install -y jenkins

# ── Enable & start Jenkins ────────────────────────────────────────────────────
systemctl daemon-reload
systemctl enable jenkins
systemctl start jenkins

# ── Install Git (useful for Jenkins pipelines) ───────────────────────────────
dnf install -y git

# ── Wait for Jenkins to write the initial admin password ─────────────────────
echo "Waiting for Jenkins to generate initial admin password..."
timeout 120 bash -c \
  'until [ -f /var/lib/jenkins/secrets/initialAdminPassword ]; do sleep 5; done'

ADMIN_PASS=$(cat /var/lib/jenkins/secrets/initialAdminPassword)
echo "Jenkins initial admin password: ${ADMIN_PASS}"

# ── Write password to a file for easy retrieval via SSM / CloudWatch ─────────
echo "${ADMIN_PASS}" > /home/ec2-user/jenkins_initial_password.txt
chmod 600 /home/ec2-user/jenkins_initial_password.txt
chown ec2-user:ec2-user /home/ec2-user/jenkins_initial_password.txt

# ── Install CloudWatch agent for log shipping ─────────────────────────────────
dnf install -y amazon-cloudwatch-agent

cat > /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json <<'EOF'
{
  "logs": {
    "logs_collected": {
      "files": {
        "collect_list": [
          {
            "file_path": "/var/log/jenkins/jenkins.log",
            "log_group_name": "/jenkins/application",
            "log_stream_name": "{instance_id}",
            "retention_in_days": 30
          }
        ]
      }
    }
  }
}
EOF

/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
  -a fetch-config \
  -m ec2 \
  -c file:/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json \
  -s

echo "Jenkins installation complete. Access via the load balancer on port 443."
