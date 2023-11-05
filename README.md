# backstage-app-deployments

GitOps repository used to manage deployments into Kubernetes cluster integrated in Backstage app.

## Cluster

### Run cluster

`minikube start`

### Stop cluster

`minikube stop`

## Prepare cluster for Backstage

Deploy Backstage Service Account and required Cluster Role Bi ding to enable Backstage to fetch information from cluster.

```shell
# Apply SA and CRB for backstage-demo 
kubectl apply -f ./infrastructure/kubernetes
```

After applying thi,s please run `cluster-info.sh`. It should give you an output like the following

```shell
# ------------------------------------------ #
# Please export the following env variables  #
# ------------------------------------------ #
export BACKSTAGE_K8S_SA_TOKEN=<redacted>
export BACKSTAGE_K8S_CONTROL_PANE_URL=https://127.0.0.1:65202
```

Please export `BACKSTAGE_SERVICE_ACCOUNT_TOKEN` and `BACKSTAGE_K8S_CONTROL_PANE_URL`. With this Backstage can connect to cluster and read deployment information.

## Deploy applications

Deployments make use of Kustomize. In order to deploy a stage to running cluster do like the following 

```shell
# Apply backstage-demo app for dev environment
kubectl apply -k ./dev/backstage-demo/.
```
