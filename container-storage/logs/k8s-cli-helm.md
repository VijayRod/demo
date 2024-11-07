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
