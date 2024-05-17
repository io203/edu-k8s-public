



# 1. install rke2
- single-master : lec0 > single-master 
- multi-master : lec0 > multi-master 

## aws 환경 준비 
-  aws lightsail 에서 master 3개 , worker 2개를  생성한다 
-  networking에서 static-ip를 만들고 master-1에게 할당하여 ip를 획득한다 
-  방화벽:  master1에서 다음 port를 오픈한다  : 6443, 443

# [참고] uninstall rke2
```sh
sudo rke2-uninstall.sh
```

# 2 install-vm tools 설치 
```sh
## install kubectl 
sudo apt update
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

echo 'source <(kubectl completion bash)' >>~/.bashrc
echo 'alias k=kubectl' >>~/.bashrc
echo 'complete -F __start_kubectl k' >>~/.bashrc

source ~/.bashrc
k version

## ansible은 ssh 통신을 위해서 ssh public-key를  각 서버에  공유한다 
ssh-keygen -t rsa -b 4096 
ls ~/.ssh/

cat ~/.ssh/id_rsa.pub 
## text 편집기에서 1줄로 정리한다 

```
## master-1 서버에서 ssh 설정 
```sh
## ubuntu 유저로 실행 
## master-1 서버 접속하여 install-vm의 id_rsa.pub 값을 master-1의 authorized_keys 에 추가한다
vi ~/.ssh/authorized_keys


## install-vm에서 
## kubconfig copy
mkdir -p ~/.kube/
scp ubuntu@172.26.13.104:~/.kube/config ~/.kube/config
cat ~/.kube/config
sed -i 's/127.0.0.1/172.26.11.45/g' ~/.kube/config
cat ~/.kube/config

## master-1의 6443 방화벽 open을 먼저 한다 
k get pod -A

```

## 2.2 k9s 설치 
```bash
# install k9s with snap
sudo snap install k9s 
sudo ln -s /snap/k9s/current/bin/k9s /snap/bin/


#### windows
# Via scoop
scoop install k9s
# 또는 Via chocolatey
choco install k9s
```


# [참고]. 로컬에서 kubectl remote 접속 하기 

```sh
## master-1에서 실행 
cat ~/.kube/config

## 로컬위치(~/.kube/config) 복사해 넣는다 
export KUBECONFIG=~/.kube/config

# master-1의 external-ip로 변경한다  
# kubectl get pod -A 로 하면 접속이 안되어 timeout이 된다 
# lightsail master01의 방화벽에서 6443 포트를 open 한다 

kubectl get pod -A
kubectl get nodes
```




## 참고: tls-san 변경하거나 추가 한다면
```bash
# 수정한다 
sudo vi  /etc/rancher/rke2/config.yaml

# 재 시작해 주면 된다 
sudo systemctl restart rke2-server.service

sudo systemctl status  rke2-server.service
```


## ssh cofnig 
- local에서 진행 

```
cd ~
vi .ssh/cofnig
----------
Host master-1
  HostName 3.39.238.55
  IdentityFile /Users/blackstar/.ssh/aws/lightsail-key.pem
  User ubuntu

ssh master-1
```

## k9s manual
```sh
#사용가능한 전체 단축키
?       

## pod 
: pod

## service 
: svc [service]

## deployment
: deploy [deployment]

## node
: node [nodes]

## namspace
: ns [namspace]

## ingress
: ing [ingress]

## 전체 namespaces pod 보기 
0 

## pod 선택후 
d   : describe
e   : edit
l  : log
y   : yaml
s   : container shell
ctrl-d   : 삭제

```