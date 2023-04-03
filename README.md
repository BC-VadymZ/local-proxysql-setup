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
➜  ~ minikube dashboard
🔌  Enabling dashboard ...
    ▪ Using image docker.io/kubernetesui/dashboard:v2.7.0
    ▪ Using image docker.io/kubernetesui/metrics-scraper:v1.0.8
💡  Some dashboard features require the metrics-server addon. To enable all features please run:

	minikube addons enable metrics-server


🤔  Verifying dashboard health ...
🚀  Launching proxy ...
🤔  Verifying proxy health ...
🎉  Opening http://127.0.0.1:61172/api/v1/namespaces/kubernetes-dashboard/services/http:kubernetes-dashboard:/proxy/ in your default browser...
```

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

### Useful links

https://www.youtube.com/watch?v=UCvgHO9TtMs
https://proxysql.com/blog/new-schemaname-routing-algorithm/