#!/bin/bash -x

swapoff -a
apt-get update -y
systemctl stop ufw && ufw disable && iptables -F

echo "=======download rke2======"
curl -sfL https://get.rke2.io | sh -

systemctl enable rke2-server.service

mkdir -p /etc/rancher/rke2/

echo "========EXTERNAL_IP : $EXTERNAL_IP"
echo "========MASTER01_INTERNAL_IP : $MASTER01_INTERNAL_IP"

cat <<EOF > /etc/rancher/rke2/config.yaml
server: https://${MASTER01_INTERNAL_IP}:9345
token: "f6b59a8608679de2c3f79b1dcd9ab8351234"
write-kubeconfig-mode: "0644"
tls-san:
    - $EXTERNAL_IP
etcd-expose-metrics: true
EOF

echo "rke2-server start"
systemctl start rke2-server.service

# kubeconfig
echo "=====kubeconfig settings======"
mkdir -p ~/.kube/
cp /etc/rancher/rke2/rke2.yaml ~/.kube/config
export PATH=$PATH:/var/lib/rancher/rke2/bin/
echo 'export PATH=/usr/local/bin:/var/lib/rancher/rke2/bin:$PATH' >> ~/.bashrc

echo 'source <(kubectl completion bash)' >>~/.bashrc
echo 'alias k=kubectl' >>~/.bashrc
echo 'complete -F __start_kubectl k' >>~/.bashrc


