# local-proxysql-setup
ProxySQL on Kubernetes

Tools used for sample deployment:

- podman (works for m1)
- Kubectl
- Minikube
- Helm


### Installing Kubectl

#### Detailed install

- Minikube on M1 pro without Docker desktop -> https://0to1.nl/post/minikube-m1-pro-issues/


### Installing Helm

#### Detailed install

- https://helm.sh/docs/intro/install/

#### TL;DR

```
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh
```

## Configuring environment

### Minikube

```
minikube config set memory 6144
minikube config set cpus 2
minikube config set disk-size 50000MB
minikube config set vm-driver podman
minikube start 
minikube status
```

### Add dashboard

```
kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.0.0/aio/deploy/recommended.yaml
minikube addons enable dashboard

# Get dashboard URL (ctrl+c to exit if stuck)
minikube dashboard --url

🤔  Verifying dashboard health ...
🚀  Launching proxy ...
🤔  Verifying proxy health ...
http://192.168.1.229:45536/api/v1/namespaces/kube-system/services/http:kubernetes-dashboard:/proxy/

# Start dashboard on local IP (forwarded from within Minikube VM) - default port is 8001
# and the address in this example 192.168.1.229 is the host physical machine IP (not the VM)
kubectl proxy --address=192.168.1.229 --accept-hosts='^.*'
```

Combining the URL and the `kubectl proxy --address` on default port 8001 the resulting url is: http://192.168.1.229:8001/api/v1/namespaces/kube-system/services/http:kubernetes-dashboard:/proxy/ (or alternatively use the SSH tunnel if on Scaleway and connect to your 192.168.1.229:8001)

## Deploying with Helm

### Install MySQL with bitnami charts

Note: You can configure custom settings (root password / number of slaves / etc. in mysql/values.yaml

```
helm repo add bitnami https://charts.bitnami.com/bitnami
helm install mysql-8 -f ./mysql/values.yaml bitnami/mysql

# Get password for MySQL
echo Password : $(kubectl get secret --namespace default mysql-8 -o jsonpath="{.data.mysql-root-password}" | base64 --decode)
Password : root
```

#### Deploy ProxySQL 

##### Install ProxySQL

```
helm install proxysql-cluster ./proxysql-cluster
```

##### Change settings and re-deploy

```
vi proxysql-cluster/files/proxysql.cnf 
helm upgrade proxysql-cluster ./proxysql-cluster
```

Optionally do a rolling restart (note, templates are configured to re-deploy on configmap changes, i.e. this step is not required unless configmap checksum is removed)

```
kubectl rollout restart deployment/proxysql-cluster
```

##### Delete `proxysql-cluster` deployment

```
helm delete proxysql-cluster
```

##### Connect to ProxySQL 

```
mysql -h$(minikube ip) -P26033 -uroot -proot
```

## Useful commands

### Helm

```
helm install <releasename> <path>
helm upgrade <releasename> <path>
helm delete <releasename>
```

### Kubectl

```
kubectl get services
kubectl get pods
kubectl get deployment
kubectl get pods --all-namespaces
kubectl describe service <servicename>
kubectl rollout restart deployment/proxysql-cluster
```

### Minicube

```
minikube start
minikube delete
```
