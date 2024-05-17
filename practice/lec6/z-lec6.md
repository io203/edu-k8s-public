# lecture-6



# 1. CI/CD 
- git : github
- image Registry: docker-hub
- giOps: github
- build :  docker build
- deploy: argocd
- github/docker-hub 계정 필요 

# 2. install argo-cd 
```bash
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

## argocd password
## linux에서 실행시 
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d  | tr -d "\n"

### mac에서 실행시( clipboard에 복사된다  )
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d  | pbcopy

# t5DOPaVhf0UocEd8

```
## 2.1 rke2 Updating Nginx Helm
- rke2에 미리 설치된 rke2-ingress-nginx-controller는 enable-ssl-passthrough 에 대한 설정이 없다 
- 다음과 같이 설정을 추가 할수 있다 
```bash
kubectl apply -f lec6/rke2-ingress-nginx.yaml

```
- 1개씩 update 가 된다 (완료 될때 까지 기다린다)

## 2.2 lightsail lb 서버의 443 오픈 
- lb 서버의 network에서 443 추가 
  
argocd-ingress
```sh
kubectl apply -f lec6/argocd-ing.yaml
```
### 2.3 access argocd ui
- https://argocd.{server-ip}.sslip.io/
- admin/ t5DOPaVhf0UocEd8
- changepassword: admin1234
- 재로그인 


## 3 docker build

```sh
docker info
docker login
docker build -t saturn203/demo-app:1.0 .   ## 마지막의 .을 생략하면 안됨
docker images

docker push saturn203/demo-app:1.0

```
- docker-hub에서 push 사항을  확인한다 

# 4. k8s-gitops 


# 5.  argocd git repository 설정 
- argocd 홈  >  Settings > Repositories > connect REPO
- VIA HTTPS 선택 
- type: git
- project: default
- Repository URL : https://github.com/io203/k8s-gitops.git


# 6. demo namespace 생성 
```sh
kubectl create ns demo 
```

# 7.  argocd applications
- Applications > NEW APP
- Name: demo
- Project Name: default
- Repository URL :  선택 
- Revision: main
- Path :  vas 선택 
- Cluster URL :  https://kubernetes.default.svc 선택 
- Namespace:  demo
- kustomize : Images 부분에 이미지와 tag 버전이 맞는지 확인 
- 위의 CREATE 버튼 클릭
- SYNC 버튼 클릭 >  SYNCRONIZE

## 7.1 demo 서비스 확인 
- http://demo.{server-ip}.sslip.io/

## 7.2 demo 2.0 업데이트 
- k8s-gitops/kustomization.yaml 에서 버전업한다 
```yaml
images:
- name: saturn203/demo-app
  newTag: "2.0" ## 1.0 --> 2.0
```

# 8. clear
```sh

k delete deployment demo-deploy -n demo

## arog UI 에서 vas application delete 한다  
kubectl delete -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

k delete -f lec6/argocd-ing.yaml


```
