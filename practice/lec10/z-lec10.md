# lecture-10
- install-vm에서 실행 
- ubuntu유저로  실행   
```sh
# cd ~
# 
cd  ~/practice/lec10

```


# 1. install ansible
- install-vm 에서 실행
```sh 
## user로 한다  
sudo apt update
sudo apt install -y software-properties-common
sudo add-apt-repository --yes --update ppa:ansible/ansible
sudo apt update
sudo apt install ansible -y ansible
ansible --version  ## ansible core 2.15.9

## ansible은 ssh 통신을 위해서 ssh public-key를  각 서버에  공유한다 
ssh-keygen -t rsa -b 4096 
ls ~/.ssh/

cat ~/.ssh/id_rsa.pub 
## text 편집기에서 1줄로 정리한다 

```
## 1.1 master-1 서버에서 ssh 설정 
```sh
## ubuntu 유저로 실행 
## master-1 서버 접속하여 install-vm의 id_rsa.pub 값을 master-1의 authorized_keys 에 추가한다
vi ~/.ssh/authorized_keys

## 패스워드 없이 접속하기 ( sudo 권한은 이미 부여 되어 있음 )
sudo vi /etc/sudoers

## 맨 하단에 아래 추가 한다 
ubuntu ALL=(ALL) NOPASSWD: ALL

```

## 1.2 install-vm에서  ansible ping test
vi host-vm
```sh
master-1 ansible_host={server-ip} ansible_user=ubuntu ansible_port=22 ansible_ssh_private_key_file=~/.ssh/id_rsa
```

ping test
```sh 
ansible -i lec10/host-vm all -m ping
## Are you sure you want to continue connecting (yes/no/[fingerprint])? yes 한다
## --아래와 같이 출력되면 성공-----
master-1 | SUCCESS => ....
```
## 1.3 ansible task 실행하여 k9s 설치(step1)

```sh
## 먼저 설치할 master-1 서버에서  ubuntu유저에서 k9s 실행 가능 여부 
k9s
## 있다면 k9s 삭제한다 
sudo snap remove k9s


## 다시 install-vm에서 ansible task 실행하여 k9s 설치한다  
ansible-playbook -i lec10/host-vm lec10/playbook-step1.yml -t "pre,k9s"

```

## 1.4 anssible step2( redis master/salve 설치)
```sh
## ansible-galaxy kubernetes collection 사용하기 위해서 install-vm에 설치 한다 
ansible-galaxy collection install kubernetes.core

ansible-playbook -i lec10/host-vm lec10/playbook-step2.yml -t "pre,helm,step2" -e "@lec10/vars.yml"
## 정상으로 설치되면 redis-master-0, redis-replicas-0, redis-replicas-1, redis-replicas-2 생성 되어야 한다 

## k9s 에서 redis master-pod  접속 
redis-cli -h redis-master
auth redis1234
ping
info
set hello vas!!
get hello
```

# 2. Clear 
```sh
helm ls -n redis-system
helm uninstall redis -n redis-system

```

