# backstage-app-deployments

GitOps repository used to manage deployments into Kubernetes cluster integrated in [Backstage demo](https://github.com/floriandorau/backstage-demo) application.

## Cluster

### Minikube

Make sure you can use [minikube](https://minikube.sigs.k8s.io/docs/)

#### Run cluster

```shell
minikube start
```

#### Stop cluster

```shell
minikube stop
```

### Prepare cluster for Backstage

Deploy Backstage Service Account and required Cluster Role Binding to enable Backstage demo application to fetch information from cluster.

```shell
# Apply SA and CRB for backstage-demo 
kubectl apply -f ./infrastructure/kubernetes
```

After applying this, please run `cluster-info.sh`. It will print actual Service Account token and Kubernetes control pane port like the following;

```shell
# ------------------------------------------ #
# Please export the following env variables  #
# ------------------------------------------ #
export BACKSTAGE_K8S_SA_TOKEN=<redacted>
export BACKSTAGE_K8S_CONTROL_PANE_URL=https://127.0.0.1:65202
```

Please export `BACKSTAGE_SERVICE_ACCOUNT_TOKEN` and `BACKSTAGE_K8S_CONTROL_PANE_URL`. With this Backstage can connect to cluster and read deployment information.

## Deploy applications

Deployments make use of [Kustomize](https://kustomize.io/). In order to deploy a stage to running cluster do like the following:

```shell
# Apply backstage-demo app for dev environment
kubectl apply -k ./dev/backstage-demo/.
```

## Argo CD

Make sure ArgoCD CLI is installed

`brew install argocd`

Rub `sh infrastructure/argo_cd/install.sh` to install ArgoCD into running cluster
