#! /bin/bash
set -x

sudo yum update -y
# Install SSM agent for SSH access
sudo yum install -y https://s3.${region}.amazonaws.com/amazon-ssm-${region}/latest/linux_amd64/amazon-ssm-agent.rpm
if [[ "$(systemctl is-active amazon-ssm-agent.service)" == "inactive" ]]; then
  systemctl start amazon-ssm-agent.service
fi

echo done.
