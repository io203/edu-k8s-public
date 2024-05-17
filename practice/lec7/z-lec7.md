# lecture-7



# 1. node lables
```sh
kubectl get nodes
kubectl get nodes --show-labels 
kubectl get nodes --show-labels | grep kubernetes.io/hostname

172.26.2.149 worker-1 
172.26.4.25 worker-2
172.26.2.228 worker-3

## node에 label 설정하기 
kubectl get nodes
kubectl label nodes ip-172-26-2-149   web=true ## worker-1
kubectl label nodes ip-172-26-4-25  web=true  ## worker-2
kubectl label nodes ip-172-26-2-228  db=true ## worker-3
kubectl get nodes --show-labels | grep web
kubectl get nodes --show-labels | grep db

## label 삭제 
kubectl label nodes ip-172-26-2-228  db-
kubectl get nodes --show-labels | grep db

```
# 2. nodeSelector 적용 nginx 배포
```sh
## web: "true"
kubectl apply -f lec7/nodeSelector.yaml

```

# 3. nodeAffinity
```sh
## 기존 예제 삭제
kubectl delete -f  lec7/nodeSelector.yaml

## requiredDuringSchedulingIgnoredDuringExecution
## web: "true"
kubectl apply -f  lec7/nodeRequireAffinity.yaml
## 삭제
kubectl delete -f lec7/nodeRequireAffinity.yaml

## preferredDuringSchedulingIgnoredDuringExecution
## 맞지 않는 web=true1 로 설정해서 생성하기 
kubectl apply -f   lec7/nodePreferAffinity.yaml
## 삭제 
kubectl delete -f   lec7/nodePreferAffinity.yaml
```

# 4. podAffinity
```sh 
## 먼저 web=true 에 nginx 배포한다 
kubectl apply -f lec7/nginx-deploy.yaml
kubectl get pod 
## 3개 pod에 security label을 설정 
kubectl label pods nginx-5467d7b76d-b4vqw security=S1
kubectl label pods nginx-5467d7b76d-cj7k4 security=S2
kubectl label pods nginx-5467d7b76d-j878n security=S3

## 기존 security=S3인 pod가 있던  node에 모두 다시 생성된다 
kubectl apply -f lec7/podAffinity.yaml   
## 확장해도 같은 pod의 위치에 배치됨
kubectl scale --current-replicas=4 --replicas=5 deployment/nginx
## 삭제
kubectl delete -f lec7/podAffinity.yaml

```

# 5. podAntiAffinity
```sh
## replicas=3
kubectl apply -f lec7/podAntiAffinity.yaml
## 1개는 pending 이 된다 

## replicas=2 줄여본다 
kubectl scale --current-replicas=3 --replicas=2 deployment/nginx

## update nginx version 
## nginx:1.17 --> nginx:1.18
kubectl set image deployment/nginx nginx=nginx:1.18
## pending 발생 

## pending 발생하여 다음과 같이   strategy.rollingUpdate의 maxUnavailable 으로 제어
## replicas=2, nginx:1.18
kubectl apply -f lec7/podAntiAffinity2.yaml
kubectl set image deployment/nginx nginx=nginx:1.19

## 다른 방법으로  strategy.rollingUpdate의 maxSurge 로 제어 
## replicas=2, nginx:1.21
kubectl apply -f lec7/podAntiAffinity3.yaml
kubectl set image deployment/nginx nginx=nginx:1.22

## clear 
kubectl delete -f lec7/podAntiAffinity3.yaml

```
# 6. Taint/Toleration
```sh
## node에 taint 설정 
kubectl taint nodes ip-172-26-2-149 oss=monitoring:NoSchedule ## ip-172-26-2-149(worker-1)
## taint 확인
kubectl describe node ip-172-26-2-149 | grep Taints

## nginx deploy web=true 한다
kubectl apply -f lec7/nginx-deploy.yaml
## nginx pod가 생성된 node를 확인한다 (모두 ip-172-26-4-25 (worker-2) 생성)
## taint 삭제 
kubectl taint nodes ip-172-26-2-149 oss-
## nginx 1개의 pod를 삭제하여 다른 노드에 설치 되는지 확인 한다 (worker-1에도 생성 되는지 확인)

## nginx 를 모두 삭제 한다 
kubectl delete -f lec7/nginx-deploy.yaml

## 다시 label web=true인 노드의 1개에 taint를 설정한다 (ip-172-26-4-25)
kubectl taint nodes ip-172-26-4-25   oss=monitoring:NoSchedule
kubectl describe node ip-172-26-4-25  ## (worker-2)

## Toleration을  설정한 nginx를 배포하여 모두 생성되는지 확인한다 
kubectl apply -f lec7/nginx-deploy-toleration.yaml

## clear 
kubectl taint nodes ip-172-26-4-25   oss- 
kubectl delete -f lec7/nginx-deploy-toleration.yaml

```

