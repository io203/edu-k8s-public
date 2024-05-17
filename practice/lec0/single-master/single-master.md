# 1.  git clone practice
```bash
## master-1에서 실행
## root로 실행
sudo su -

cd practice/lec0/single-master
```

# 2. single-master rke2

## 2.1 master 설치
```bash

## root로 실행  
export EXTERNAL_IP=3.38.100.174
sh rke2-single-master-install.sh

source ~/.bashrc

watch kubectl get pod -A
## 9분정도 소요

## ubuntu유저 kubeconfig 설정
## ubuntu유저로 전환후 실행
exit


cd practice/lec0/single-master

sh master-ubuntu-user-kubeconfig.sh
source ~/.bashrc

## debug
## journalctl -u rke2-server -f
```

## 2.2 master token  

master vm에서 실행  
```sh
sudo cat /var/lib/rancher/rke2/server/node-token

```

## 2.3 agent 설치
```sh
## worker-1/worker-2 실행 
## root로  설치 한다 
sudo su -

cd practice/lec0/single-master

## master의 private IP를 입력 해야 함 
export MASTER01_INTERNAL_IP=172.26.8.74
sh rke2-single-agent-install.sh

```

## 2.4 ubuntu 유저에서 kubeconfig 설정 
### ubuntu 유저
```sh
sh master-ubuntu-user-kubeconfig.sh
```

