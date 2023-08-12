```
# helm version
version.BuildInfo{Version:"v3.11.3", GitCommit:"323249351482b3bbfc9f5004f65d400aa70f9ae7", GitTreeState:"clean", GoVersion:"go1.20.3"}
```

```
# To add a Helm repo
helm repo add application-gateway-kubernetes-ingress https://appgwingress.blob.core.windows.net/ingress-azure-helm-package/
helm repo update

# To list Helm repos
helm repo list
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
