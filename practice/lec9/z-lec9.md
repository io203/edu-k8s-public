# lecture-9
- install-vm에서 실행 
- ubuntu유저로  실행   
```sh
# cd ~
# 
cd  ~/practice

```


# 1.  Account
kubecofnig file

```sh
kubectl config view 
```
- context 정보
- user 정보(default)가 있다 이를 default2로 변경해도 무방하다 
  
## 1.1 Serviceaccount 접근(추천)
```sh
## namespace 생성
kubectl create ns demo
k get sa -n demo

## serciceAccount 생성
kubectl create sa demo-sa -n demo
k get sa -n demo

## Token 생성
## 1.24 버전부터 sa 를 생성해도 token이 자동으로 생성되지 않는다. 따라서 수동으로 생성해준다 
kubectl apply -f lec9/demo-secret.yaml
kubectl get secret -n demo

## demo namespace에 nginx 배포 
k apply -f lec9/nginx.yaml -n demo

## demo-role 생성 
k apply -f lec9/demo-role.yaml
k get role -n demo

## apiGroup 에서 "" 은 core API group 으로 다음의 출력으로 확인할 수 있다
## APIVERSION 이 v1 인 리소스들이 core API group 이 되면 이들에 대해서 권한을 사용하겠다는 뜻
kubectl api-resources 

## Rolebinding 생성 
k apply -f lec9/demo-rolebinding.yaml
k get rolebinding -n demo

## user token get
kubectl get secret  demo-sa -n demo -ojsonpath={.data.token} | base64 -d

## kubecofnig user 추가
## - users에 demo-user 추가(이름은 자유)
## - contexts> context의 user를 추가한  demo-user 로 변경  
~/.kube/config
#생략
contexts:
- context:
    cluster: default
    user: demo-user
  name: default
current-context: default
kind: Config
preferences: {}
users:
- name: demo-user
  user:
    token: xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
#생략

## demo namespace를  조회해 본다
k get pod -n demo

## 다른 namespace도 조회해 본다(Forbidden 에러 )
k get pod -n kube-system

## rke2 다양한 Role/ clusterroles
kubectl get roles.rbac.authorization.k8s.io --all-namespaces
kubectl get clusterroles.rbac.authorization.k8s.io --all-namespaces

## clear 
## 기존 default 유저로 변경후 아래 명령어 실행 해야 함
k delete -f lec9/demo-rolebinding.yaml
k delete -f lec9/demo-role.yaml
k delete  secret/demo-sa -n demo
k delete sa demo-sa -n demo
k delete -f lec9/nginx.yaml -n demo

```



