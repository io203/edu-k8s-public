# lecture-8
- install-vm에서 실행 
- ubuntu유저로  실행   
```sh
# cd ~
# 
cd  ~/practice
```

# 1. rke2 백업 (v1.28.9+rke2r1)
- rke2 etcd snapshot 기본적으로 활성화 되어 있다(스케줄러로 자동) 
- snapshot 기본 경로 : /var/lib/rancher/rke2/server/db/snapshots
- RKE2에서는 스냅샷이 각 etcd 노드에 저장된다
- 수동으로 snapshot 찍는 방법 : rke2 etcd-snapshot save --name pre-upgrade-snapshot
```sh


## nginx namespace 생성및 배포 
kubectl create ns nginx
kubectl apply -f lec8/nginx.yaml

## master-1 os에서 
sudo ls -al /var/lib/rancher/rke2/server/db/snapshots

## 수동으로 백업 
## master-1에서 
sudo rke2 etcd-snapshot save --name pre-upgrade-snapshot

## 확인
sudo ls -al /var/lib/rancher/rke2/server/db/snapshots
## pre-upgrade-snapshot-ip-172-26-11-45-1708237191

```

# rke2 복원 

```sh
## nginx namespace 확인 후 삭제해본다 
kubectl get pod -n nginx
kubectl delete ns nginx 
kubectl get pod -n nginx

## systemd를 통해 활성화된 RKE2 서비스를 중지해야 한다 (모든 master 중지한다) 
## rke2-server 정지
## master-1, master-2, master-3
sudo systemctl stop rke2-server
sudo systemctl status rke2-server

## snapshot 확인
sudo ls -al /var/lib/rancher/rke2/server/db/snapshots

## 복원 작업은 먼전 master-1에서 시작한다 
sudo rke2 server \
  --cluster-reset \
  --cluster-reset-restore-path=/var/lib/rancher/rke2/server/db/snapshots/pre-upgrade-snapshot-ip-172-26-7-200-1715843766

## rke2-server 시작
sudo systemctl start rke2-server

## nginx namespace 복원 되었는지 확인 
kubectl get pod -n nginx 

## 복원이 되면 /var/lib/rancher/rke2/server/db/ 에 복구 이전 db는  etcd-old-%date%/ 로 이름이 변경되고 복원된 데이터로 etcd 디렉토리가 생성된다 
sudo ls -al /var/lib/rancher/rke2/server/db/


## master-2, master-3에서 rke2 db 디렉토리를 삭제한다(복원전 데이터 ) 
rm -rf /var/lib/rancher/rke2/server/db
## master-2, master-3에서  rke2-server 시작한다 
systemctl start rke2-server


```


# 2. Velero

## 2.1 Velero Client 설치 

```sh
## linux 버전
## install-vm에서 아니면 master-1에서 
sudo su -  ## root에서 하자
wget https://github.com/vmware-tanzu/velero/releases/download/v1.13.0/velero-v1.13.0-linux-amd64.tar.gz 
tar -xvf velero-v1.13.0-linux-amd64.tar.gz
sudo cp ./velero-v1.13.0-linux-amd64/velero /usr/local/bin

velero version

```

## 2.2 Velero Server 설치
- aws credentials 파일 생성 
- install-vm 에서 실행 
vi credentials-velero 
```
[default]
aws_access_key_id = 
aws_secret_access_key = 

```

### 2.3 aws s3에 bucket를 만든다 
- aws iam에서 유저가 s3에 대한 read/write 권한이 있어야 한다 
- aws iam에서 사용자 그룹을 admin으로 하고 권한을 AdministratorAccess 정책을 매핑하고 user를 그룹에 매핑한다 
- bucket명: austine-test-bucket 생성 



```sh
export BUCKET=austine-test-bucket
export REGION=ap-northeast-2
velero install \
    --provider aws \
    --plugins velero/velero-plugin-for-aws:v1.9.0 \
    --bucket $BUCKET \
    --backup-location-config region=$REGION \
    --snapshot-location-config region=$REGION \
    --secret-file ./credentials-velero

## 조회
kubectl get pod -n velero


## 백업
### cluster-scope(cluster etcd 전체 백업)
# velero backup create etcd-20240215

### namespace-scope
velero backup create nginx-20240517-1 --include-namespaces nginx

# Describe gives you information
# velero backup describe etcd-20240215
velero backup describe nginx-20240517-1  ## Phase:  Completed

## s3에 bucket에서 확인 
s3://austine-test-bucket/backups/nginx-20240517-1/

## nginx namespace 삭제해본다  
kubectl delete ns nginx

## 삭제된 nginx 복원 
# velero restore create --from-backup  etcd-20240215
velero restore create --from-backup nginx-20240517-1



## clean 
kubectl delete -f lec8/nginx.yaml

kubectl delete namespace/velero clusterrolebinding/velero
kubectl delete crds -l component=velero

```
