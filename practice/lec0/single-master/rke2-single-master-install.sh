#!/bin/bash -x

swapoff -a
apt-get update -y
systemctl stop ufw && ufw disable && iptables -F

echo "===========download rke2============"
curl -sfL https://get.rke2.io | sh -

systemctl enable rke2-server.service

mkdir -p /etc/rancher/rke2/



cat <<EOF > /etc/rancher/rke2/config.yaml
write-kubeconfig-mode: "0644"
token: "f6b59a8608679de2c3f79b1dcd9ab8351234"
tls-san:
  - $EXTERNAL_IP
etcd-expose-metrics: true
EOF

echo "=======rke2-server start============"
systemctl start rke2-server.service

# kubeconfig
echo "=====kubeconfig settings======="
mkdir -p ~/.kube/
cp /etc/rancher/rke2/rke2.yaml ~/.kube/config
export PATH=$PATH:/var/lib/rancher/rke2/bin/
echo 'export PATH=/usr/local/bin:/var/lib/rancher/rke2/bin:$PATH' >> ~/.bashrc

echo 'source <(kubectl completion bash)' >>~/.bashrc
echo 'alias k=kubectl' >>~/.bashrc
echo 'complete -F __start_kubectl k' >>~/.bashrc