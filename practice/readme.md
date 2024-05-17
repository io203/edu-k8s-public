# k8s 교육


## sed 
```sh

## replace
cd ~/practice
find . -type f -name "*.yaml" -exec sed -i 's/{server-ip}/{server-ip}/g' {} +
find . -type f -name "*.md" -exec sed -i 's/{server-ip}/{server-ip}/g' {} +

cd ~/demo-gitops
find . -type f -name "*.yaml" -exec sed -i 's/{server-ip}/{server-ip}/g' {} +

## 복원
cd ~/practice
find . -type f -name "*.yaml" -exec sed -i 's/52.78.167.234/{server-ip}/g' {} +
find . -type f -name "*.md" -exec sed -i 's/52.78.167.234/{server-ip}/g' {} +

cd ~/demo-gitops
find . -type f -name "*.yaml" -exec sed -i 's/52.78.167.234/{server-ip}/g' {} +



## 개별 폴더에서 할경우 
sed -i 's/{server-ip}/52.78.167.234/' *.yaml
sed -i 's/{server-ip}/52.78.167.234/' *.md
```
