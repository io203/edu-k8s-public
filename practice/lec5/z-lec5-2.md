# lecture-5-2
- install-vm에서 실행 
- ubuntu유저로  실행   
```sh
# cd ~
# 
cd  practice
```

# 1. emptyDir
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
spec:
  selector:
    matchLabels:
      app: nginx
  replicas: 1
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:1.17
        ports:
        - containerPort: 80

        volumeMounts:
        - name: log-volume
          mountPath: /var/log/nginx

      - name: fluent-bit
        image: amazon/aws-for-fluent-bit:2.1.0
        volumeMounts:
        - name: log-volume
          mountPath: /var/log/nginx

      volumes: # 볼륨 선언
      - name: log-volume
        emptyDir: {}
```
```sh 

k apply -f lec5/emptydir-vol.yaml

## emptyDir volume인 log-volume으로 설정해 놓았기 때문에 
##  fluent-bit container에서 이제 nginx 의 access.log  error.log 를 읽을수 있도록 가능해 졌다 
## nginx pod의 fluent-bit container로 접속하여 아래와 같이  nginx의 로그파일이 조회 되는지 확인한다 
ls /var/log/nginx

## clear 
k delete -f lec5/emptydir-vol.yaml
```

# 2. hostPath
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: test-webserver
spec:
  containers:
  - name: test-hostpath-nginx
    image: nginx:1.17
    volumeMounts:
    - mountPath: /var/local/aaa
      name: mydir
    - mountPath: /var/local/aaa/1.txt
      name: myfile
  volumes:
  - name: mydir
    hostPath:
      # 파일 디렉터리가 생성되었는지 확인한다.
      path: /var/local/aaa
      type: DirectoryOrCreate
  - name: myfile
    hostPath:
      path: /var/local/aaa/1.txt
      type: FileOrCreate
```
```sh
## nginx를 배포한다 
k apply -f lec5/hostpath-vol.yaml

## pod의 디렉토리및 파일이 생성 되었는지 확인  
k exec -it test-hostpath-nginx -- ls /var/local
k exec -it test-hostpath-nginx -- ls /var/local/aaa

## 실제 pod가 배포된 node의 에서 디렉토리및 파일이 생성 되었는지 확인  
##  pod가 배포된 노드 확인 
k get pod test-hostpath-nginx -o wide
## node에 ubuntu로 로그인 하여 host에  생성 되었는지  조회 한다 
ls /var/local/aaa

## 다른 노드에서 확인한다 
## ls /var/local/aaa 조회 되지 않을 것이다 

## clear 
k delete -f lec5/hostpath-vol.yaml
```

# 3. pv/pvc

## 3.1  노드에 index.html 파일 생성
```sh
# 사용자 노드에서 슈퍼유저로 명령을 수행하기 위하여
# "sudo"를 사용한다고 가정한다
## worker-1 에만 생성해 본다 
sudo ls  /mnt/data
sudo mkdir -p /mnt/data
sudo sh -c "echo 'Hello from Kubernetes storage' > /mnt/data/index.html"
cat /mnt/data/index.html
```

## 3.2 pv
```yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: task-pv-volume
  labels:
    type: local
spec:
  storageClassName: manual
  capacity:
    storage: 10Gi
  accessModes:
    - ReadWriteOnce
  hostPath:
    path: "/mnt/data"

```
```sh
kubectl apply -f lec5/task-pv-volume.yaml
kubectl get pv task-pv-volume
```
## 3.3 pvc
```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: task-pv-claim
spec:
  storageClassName: manual
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 3Gi
```
```sh
kubectl apply -f lec5/task-pv-claim.yaml

## pvc 조회한다  status가 Bound 되어 있어야 한다  
kubectl get pvc task-pv-claim
## pv 조회한다  status가 Bound 되어 있어야 한다 
kubectl get pv task-pv-volume
```

## 3.4 pod
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: task-pv-pod
spec:
  containers:
    - name: task-pv-container
      image: nginx
      ports:
        - containerPort: 80
          name: "http-server"
      volumeMounts:
        - mountPath: "/usr/share/nginx/html"
          name: task-pv-storage
   volumes:
    - name: task-pv-storage
      persistentVolumeClaim:
        claimName: task-pv-claim
```
```sh
## pod 배포
kubectl apply -f lec5/task-pv-pod.yaml
kubectl get pod task-pv-pod -o wide

## pod 안으로 들어간다 
kubectl exec -it task-pv-pod -- /bin/bash

## 최신버전 nginx image 들은 보안 때문에 curl 이 없을수 있다 curl을 설치하자  
apt update
apt install curl
## nginx를 조회 해 본다 
curl http://localhost/    ## 'Hello from Kubernetes storage' 조회 안될수도 있다  
## 파일이 존재하는지 확인 
cat /usr/share/nginx/html/index.html

## 조회 안될 경우 이는 /mnt/data/index.html 생성한 노드에 pod가 생성되지 않는 경우이다 
## 다른 노드에도  /mnt/data/index.html를   생성해 놓으면 정상적으로 조회 된다 

```
## 3.5 clean 
```sh
kubectl delete pod task-pv-pod
kubectl delete pvc task-pv-claim
kubectl delete pv task-pv-volume
```

# 4. storageClass

## 4.1 nfs storageClass ( 실습 없음)
```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: nfs-client
provisioner: k8s-sigs.io/nfs-subdir-external-provisioner # or choose another name, must match deployment's env PROVISIONER_NAME'
parameters:
  pathPattern: "${.PVC.namespace}/${.PVC.annotations.nfs.io/storage-path}" # waits for nfs.io/storage-path annotation, if not specified will accept as empty string.
  onDelete: delete
```
## 4.2 pvc example
```yaml
kind: PersistentVolumeClaim
apiVersion: v1
metadata:
  name: test-claim
  annotations:
    nfs.io/storage-path: "test-path" # not required, depending on whether this annotation was shown in the storage class description
spec:
  storageClassName: nfs-client
  accessModes:
    - ReadWriteMany
  resources:
    requests:
      storage: 1Mi

```

# 5. Rancher Local-Path-Provisioner
- local-path-storage를 지원하는 provider이다 

```sh
## Local-Path-Provisioner 배포 
kubectl apply -f https://raw.githubusercontent.com/rancher/local-path-provisioner/v0.0.26/deploy/local-path-storage.yaml

## pod 확인
kubectl get pod -n local-path-storage 

## log 확인
kubectl logs -f -n local-path-storage  -l app=local-path-provisioner

```
## 5.1  pvc 생성 
```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: local-path-pvc
spec:
  accessModes:
    - ReadWriteOnce
  storageClassName: local-path
  resources:
    requests:
      storage: 128Mi
```
```sh
## 온라인 예제로 실행 
kubectl create -f https://raw.githubusercontent.com/rancher/local-path-provisioner/master/examples/pvc/pvc.yaml
## local-path-pvc pvc를 조회하면 status가  pending 되어 있다(pv도 생성되지 않는다) , pvc를 사용하는  pod consubmer가 생성되면 binding 된다 , 이떼 pv도 생성된다
```

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: volume-test
spec:
  containers:
  - name: volume-test
    image: nginx:stable-alpine
    imagePullPolicy: IfNotPresent
    volumeMounts:
    - name: volv
      mountPath: /data
    ports:
    - containerPort: 80
  volumes:
  - name: volv
    persistentVolumeClaim:
      claimName: local-path-pvc
```
```sh
kubectl create -f https://raw.githubusercontent.com/rancher/local-path-provisioner/master/examples/pod/pod.yaml

kubectl get pod  
## pod가 생성되면 pvc는 pod의 요청으로 pv를  자동으로  생성되면서 먼저 pv와 Binding 되면서 pvc도 binding 된다 
kubectl get pvc
## local-path-pvc   Bound    pvc-9875c93c-bb64-4761-b588-2b92341156af   128Mi 

kubectl get pv                
## pvc-9875c93c-bb64-4761-b588-2b92341156af   128Mi   

## pod에서 test.txt를 생성해 놓는다
kubectl exec volume-test -- sh -c "echo practice-test-local-path-test-1234 > /data/test.txt"
kubectl exec volume-test -- sh -c "ls /data/test.txt"

# delete pod
kubectl delete -f https://raw.githubusercontent.com/rancher/local-path-provisioner/master/examples/pod/pod.yaml

## pvc는 지워지지 않는다 
kubectl get pvc

# pod를 재생성(recreate)
kubectl create -f https://raw.githubusercontent.com/rancher/local-path-provisioner/master/examples/pod/pod.yaml

# check volume content
kubectl exec volume-test -- sh -c "cat /data/test.txt"

## 생성된 pv에서 보면 hostPath 경로를 확인 가능(describe) 
hostPath:   
  path: /opt/local-path-provisioner/pvc-b728be50-6af5-4f62-b48c-8be928139647_default_local-path-pvc

## worker 노드에서 test.txt 확인해 보자 (pv describe에서 Node Affinity로 설정된 노드에서 확인 가능)
cat /opt/local-path-provisioner/pvc-b728be50-6af5-4f62-b48c-8be928139647_default_local-path-pvc/test.txt

## nginx deployment
k apply -f lec5/local-path-vol-nginx.yaml

## nginx pod 안으로 접속하여 (k9s에서 )
cat /data/test.txt

```

## 5.2 clear
```sh
kubectl delete -f https://raw.githubusercontent.com/rancher/local-path-provisioner/master/examples/pod/pod.yaml
k delete -f lec5/local-path-vol-nginx.yaml
k delete pvc local-path-pvc
kubectl delete -f https://raw.githubusercontent.com/rancher/local-path-provisioner/v0.0.26/deploy/local-path-storage.yaml

```



# 6. POD 의 Request / Limit

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: frontend
spec:
  containers:
  - name: app
    image: images.my-company.example/app:v4
    resources:
      requests:
        memory: "64Mi"
        cpu: "250m"
      limits:
        memory: "128Mi"
        cpu: "500m"
  - name: log-aggregator
    image: images.my-company.example/log-aggregator:v6
    resources:
      requests:
        memory: "64Mi"
        cpu: "250m"
      limits:
        memory: "128Mi"
        cpu: "500m"


```

# 8. ETCD 
- rke2 v1.28.9 에서 접속 불가로 변경됨
```sh
kubectl -n kube-system exec -it etcd-ip-172-26-7-200 -- /bin/bash

etcd --version
etcdctl version

## 환경변수 설정 
export ETCDCTL_ENDPOINTS='https://127.0.0.1:2379' 
export ETCDCTL_CACERT='/var/lib/rancher/rke2/server/tls/etcd/server-ca.crt' 
export ETCDCTL_CERT='/var/lib/rancher/rke2/server/tls/etcd/server-client.crt' 
export ETCDCTL_KEY='/var/lib/rancher/rke2/server/tls/etcd/server-client.key' 
export ETCDCTL_API=3 

## health 
etcdctl endpoint health
## etcd member 리스트 
etcdctl member list
## endpoint status 조회
etcdctl endpoint status --cluster -w table
```
