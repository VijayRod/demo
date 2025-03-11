## k8s.cli.helm

```
# https://helm.sh/docs/intro/install/#from-script
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
help help

helm version
version.BuildInfo{Version:"v3.11.3", GitCommit:"323249351482b3bbfc9f5004f65d400aa70f9ae7", GitTreeState:"clean", GoVersion:"go1.20.3"}
```

```
helm repo add application-gateway-kubernetes-ingress https://appgwingress.blob.core.windows.net/ingress-azure-helm-package/ # To add a Helm repo
helm repo update

helm repo list # To list Helm repos

helm repo remove dynatrace
```

```
# To install a Helm chart in kubernetes
# https://helm.sh/docs/helm/helm_install/#helm
TBD (working sample) helm install -f helm-config.yaml --generate-name application-gateway-kubernetes-ingress/ingress-azure
TBD (working sample) helm install ingress-nginx ingress-nginx/ingress-nginx --version 4.0.13 --namespace ingress-basic --set controller.replicaCount=2 --set controller.replicaCount=2 --set controller.nodeSelector."kubernetes\.io/os"=linux

# To upgrade to a new version of a chart or install if the release doesn't exist
helm upgrade --install ingress-nginx ingress-nginx --repo https://kubernetes.github.io/ingress-nginx --namespace ingress-nginx --create-namespace

# To list the values that you can set for a chart
helm show values ingress-nginx --repo https://kubernetes.github.io/ingress-nginx
```

- https://helm.sh/docs/intro/install/
  - https://helm.sh/docs/intro/cheatsheet/
- https://learn.microsoft.com/en-us/azure/aks/quickstart-helm?tabs=azure-cli
  - https://learn.microsoft.com/en-us/azure/aks/kubernetes-helm

## k8s.cli.helm.debug

```
TBD helm install ...Debug=true
TBD helm upgrade ...Debug=true
helm status trident
helm get all trident
```
- tbd https://gist.github.com/fardjad/7532a2b275e255ae92494435f2220c73#file-debugging-and-authoring-helm-charts-and-post-renderer-hooks-with-viddy-md

```
# helm.release
helm list -A # lists all of the releases in all namespaces
helm list -n azureml
```

```
# helm.release.delete

## delete the release and its history
## **Heads up: helm uninstall deletes the associated pods, deployments, etc., leaving just the namespace object with its secrets
helm uninstall <release-name> -n <namespace> # --keep-history # To purge (completely remove) a Helm release and its history
release "mllab" uninstalled

helm list -A --uninstalled # If the release no longer appears, it has been fully purged.
NAME    NAMESPACE       REVISION        UPDATED STATUS  CHART   APP VERSION

## to view remaining objects after helm uninstall
kubectl get all -n azureml # should be empty after helm uninstall
kubectl get secrets -n azureml # contains secrets as these are not deleted automatically on helm uninstall
```

```
# helm.release.history
# helm uninstall to remove the release, with or without its history

helm history mllab -n azureml
REVISION        UPDATED                         STATUS          CHART                   APP VERSION     DESCRIPTION
1               Fri Mar  7 18:37:26 2025        deployed        amlarc-extension-1.1.71 1.16.0          Install complete

helm history aks-ml-extension -n azureml
k get secrets -n azureml
```

```
# helm.release.history/cleanup/delete_stuck_helm_secrets.sh
# Usage: ./delete_stuck_helm_secrets.sh amlarc-extension-1.1.71 azureml

cd /tmp
rm delete_stuck_helm_secrets.sh
nano delete_stuck_helm_secrets.sh

#####
#!/bin/bash

# Set release name and namespace
RELEASE_NAME=$1
NAMESPACE=$2

# Validate input
if [[ -z "$RELEASE_NAME" || -z "$NAMESPACE" ]]; then
    echo "Usage: $0 <release-name> <namespace>"
    exit 1
fi

echo "Fetching Helm history for release: $RELEASE_NAME in namespace: $NAMESPACE"

# Get stuck revisions (PENDING_ROLLBACK or PENDING_UPGRADE) using grep + awk for accurate parsing
STUCK_REVISIONS=$(helm history "$RELEASE_NAME" -n "$NAMESPACE" | grep 'pending-' | awk '{print $1}')

if [[ -z "$STUCK_REVISIONS" ]]; then
    echo "No stuck Helm revisions found. Nothing to delete."
    exit 0
fi

echo "Found stuck Helm revisions: $STUCK_REVISIONS"

# Loop through each stuck revision and delete the corresponding secret
for REVISION in $STUCK_REVISIONS; do
    SECRET_NAME="sh.helm.release.v1.${RELEASE_NAME}.v${REVISION}"
   
    echo "Deleting Helm history secret: $SECRET_NAME"
   
    kubectl delete secret -n "$NAMESPACE" "$SECRET_NAME" --ignore-not-found
done

echo "Cleanup complete. Verify with 'helm history $RELEASE_NAME -n $NAMESPACE'"

exit 0
#####

# cat delete_stuck_helm_secrets.sh
chmod +x delete_stuck_helm_secrets.sh
./delete_stuck_helm_secrets.sh my-release my-namespace
```

```
# helm.release.history/release-uninstall
# helm uninstall to remove the release, *including its associated deployments*, with or without its history
```
