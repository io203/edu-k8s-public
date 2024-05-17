#!/bin/bash -x

swapoff -a
apt-get update -y
systemctl stop ufw && ufw disable && iptables -F

echo "===========download rke2 agent============"
curl -sfL https://get.rke2.io  | INSTALL_RKE2_TYPE="agent" sh -

systemctl enable rke2-agent.service

mkdir -p /etc/rancher/rke2/

echo "========MASTER01_INTERNAL_IP : $MASTER01_INTERNAL_IP"


cat <<EOF > /etc/rancher/rke2/config.yaml
server: https://${MASTER01_INTERNAL_IP}:9345
token: "f6b59a8608679de2c3f79b1dcd9ab8351234"
EOF

echo "=======rke2-agent start============"
systemctl start rke2-agent.service

