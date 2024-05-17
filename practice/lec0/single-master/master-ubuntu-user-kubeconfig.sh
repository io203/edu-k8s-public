#!/bin/bash -x

# kubeconfig
echo "=====ubuntu user kubeconfig settings======="
mkdir -p ~/.kube/
cp /etc/rancher/rke2/rke2.yaml ~/.kube/config
sudo cp /var/lib/rancher/rke2/bin/kubectl /usr/local/bin

echo 'source <(kubectl completion bash)' >>~/.bashrc
echo 'alias k=kubectl' >>~/.bashrc
echo 'complete -F __start_kubectl k' >>~/.bashrc