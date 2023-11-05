#!/bin/bash

CONTROL_PANE_URL=$(kubectl cluster-info | grep 'Kubernetes control plane' |  grep -o 'https*://[^"]*')
SA_TOKEN=$(kubectl -n default get secret backstage-sa-secret -o=json | jq -r '.data["token"]' | base64 --decode)

echo "# ------------------------------------------ #"
echo "# Please export the following env variables: #"
echo "# ------------------------------------------ #"
echo "export BACKSTAGE_K8S_SA_TOKEN=$SA_TOKEN"
echo ""
echo "export BACKSTAGE_K8S_CONTROL_PANE_URL=$CONTROL_PANE_URL"
echo ""