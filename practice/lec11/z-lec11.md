# lecture-11
- install-vm에서 실행 
- ubuntu유저로  실행   
```sh
# cd ~
# 
cd  ~/practice

```


# 1. docker install(없다면 )
```sh
## install-vm에서 실행 
## ubuntu user로 실행 
sudo apt update

snap version  ## 2.61.1 되어야 한다 
## 2.61.1 아니면 아래 실행하여 version ip 한다 
# sudo snap refresh
sudo snap install docker 

sudo docker ps 

## Docker 그룹 생성(snap docker install은 docker 그룹을 만들지 않는다)
sudo addgroup --system docker

## sudo 없이 Docker 명령 실행
sudo usermod -a -G docker $USER

## 재로그인후 체크 
docker ps # 안될경우 sudo reboot 
```

# 2. ansible argocd 설치 및 App 배포 (demo-gitOps/demo)
```sh
cd ansible
## host-vm host 수정 
## argode-ing  host 수정 
## vars.yaml master-host 및 gitOps 변경

## ping test
ansible -i lec11/ansible/host-vm all -m ping

ansible-playbook -i lec11/ansible/host-vm lec11/ansible/playbook.yml -t "argocd, app-deploy" -e "@lec11/ansible/vars.yml"

argocd login --insecure argocd.{server-ip}.sslip.io  --username admin  --password $PASSWORD 
argocd account update-password --current-password $PASSWORD  --new-password admin1234
```
- https://argocd.{server-ip}.sslip.io/ 접속한다 
- 로그인 : admin/admin1234
- demo app이 정상적으로 생성되었는지 확인
- demo app 접속 : http://demo.{server-ip}.sslip.io/

# demo app 수정 
```sh
## install-vm에서 실행 
cd ~/practice/lec11/apps/demo
cat ~/practice/lec11/apps/demo/src/main/java/com/example/demo/controller/DemoController.java
## return "hello world demo !!! version : 1.0.0 "; 에서 소스 수정해 놓았다
## 변경하고 싶다면 
# vi ~/practice/lec11/apps/demo/src/main/java/com/example/demo/controller/DemoController.java

## docker build 
docker build -t [docker-hub 계정]/demo:1.0.0 . 
# ex} docker build -t {gitaccount}/demo:1.0.0 . 
docker images
docker login 
docker push [docker-hub 계정]/demo:1.0.0
# ex} docker push {gitaccount}/demo:1.0.0  
```

## demo-gitOps image tag update 
```sh
## install-vm에서 실행 
## demo-gitOps 없는경우 아래와 같이 git clone 한다 
# cd ~
#  

cd ~/demo-gitops/
vi demo/kustomization.yaml

 # newTag: 3.0.0 수정

 git add . ; git commit -m "demo:3.0.0 수정"; git push origin

```

## argocd demo app auto sync
- argocd 기본적으로 180초(3분) 마다 refresh가 이루어져 자동 sync 된다  
