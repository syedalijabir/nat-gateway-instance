#! /bin/bash
set -x

sudo yum update -y
# Install SSM agent for SSH access
sudo yum install -y https://s3.${region}.amazonaws.com/amazon-ssm-${region}/latest/linux_amd64/amazon-ssm-agent.rpm
if [[ "$(systemctl is-active amazon-ssm-agent.service)" == "inactive" ]]; then
  systemctl start amazon-ssm-agent.service
fi

# Configure NAT rules
sudo echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf
sudo sysctl -p

# NAT
sudo iptables -t nat -A POSTROUTING -o eth0 -s ${vpc_cidr} -j MASQUERADE

# Open 443 for input
sudo iptables -A INPUT -p tcp --dport 443 -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT
sudo iptables -A OUTPUT -p tcp --sport 443 -m conntrack --ctstate ESTABLISHED -j ACCEPT

echo done.
