#!/bin/bash
# Check Getting starte guide
# https://argoproj.github.io/argo-workflows/quick-start/

SCRIPT_PARENT_PATH=$( cd "$(dirname "${BASH_SOURCE[0]}")" ; pwd -P )

# Argo variables
ARGO_CD_NAMESPACE=argocd
ARGO_PORT_FORWARD=8080

# Github variables
GH_USER=floriandorau
GH_TOKEN=$GITHUB_TOKEN

# Backstage variables
BACKSTAGE_DEPLOYMENT_REPO=https://github.com/floriandorau/backstage-app-deployments
BACKSTAGE_DEPLOYMENT_APP=backstage-demo-service

echo ""
echo "# -----------------------------------------------------------------------#"
echo "#  Initializing ArgoCD namespace                                         #"
echo "# -----------------------------------------------------------------------#"
echo ""
echo "# 01.01 - Initializing ArgoCD '$ARGO_CD_NAMESPACE' namespace"
kubectl create ns $ARGO_CD_NAMESPACE >/dev/null

echo ""
echo "# -----------------------------------------------------------------------#"
echo "#  Starting ArgoCD installation                                          #"
echo "# -----------------------------------------------------------------------#"
echo ""

echo "# 02.01 - Applying ArgoCD manifests in '$ARGO_CD_NAMESPACE'"
kubectl apply -n $ARGO_CD_NAMESPACE -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml >/dev/null

echo "# 02.02 - Applying ArgoCD account configuration"
kubectl apply -n $ARGO_CD_NAMESPACE -f "$SCRIPT_PARENT_PATH/argo_account_config.yaml" >/dev/null

echo "# 02.03 - Generating ArgoCD account API token"
BACKSTAGE_API_TOKEN=$(argocd account generate-token --account backstage)

echo ""
echo "# -----------------------------------------------------------------------#"
echo "#  Provisioning ArgoCD installation                                      #"
echo "# -----------------------------------------------------------------------#"
echo ""

echo "# 03.01 - Running Port-Forwarding for internal ArgoCD Server at port:$ARGO_PORT_FORWARD"
bash -c "kubectl port-forward svc/argocd-server -n argocd $ARGO_PORT_FORWARD:443" & 
argoPortForwardPID=$!

echo "# 03.02 - Adding repo $BACKSTAGE_DEPLOYMENT_REPO to ArgoCD"
kubectl config set-context --current --namespace=$ARGO_CD_NAMESPACE >/dev/null
argocd repo add $BACKSTAGE_DEPLOYMENT_REPO \
     --username "$GH_USER" \
     --password "$GH_TOKEN" \
     --upsert >/dev/null

echo "# 03.03 - Creating $BACKSTAGE_DEPLOYMENT_APP app deployment"
argocd app create $BACKSTAGE_DEPLOYMENT_APP \
    --repo $BACKSTAGE_DEPLOYMENT_REPO \
    --path dev/backstage-demo \
    --dest-server https://kubernetes.default.svc \
    --dest-namespace backstage-demo >/dev/null

echo "# 03.04 - Syncing $BACKSTAGE_DEPLOYMENT_APP app deployment"
argocd app sync $BACKSTAGE_DEPLOYMENT_APP >/dev/null

echo "# 03.04 - Stopping ArgoCD port-forwarding (PID: $argoPortForwardPID)"
kill $argoPortForwardPID

echo ""
echo "# -----------------------------------------------------------------------#"
echo "#  ArgoCD successfully installed and proivioned.                         #"
echo "# -----------------------------------------------------------------------#"
echo "#                                                                        #"
echo "# Please export the following env variable in Backstage terminal session #"
echo "# export BACKSTAGE_ARGOCD_AUTH_TOKEN='argocd.token=$BACKSTAGE_API_TOKEN'"
echo "#                                                                        #"
echo "# Pleae keep in mind to run port-forward to make ArgoCD serer accessable #" 
echo "# kubectl port-forward svc/argocd-server -n $ARGO_CD_NAMESPACE 8080:443  #"
echo "# -----------------------------------------------------------------------#"
