## kubectl.install

```
sudo az aks install-cli
# az aks install-cli --client-version=v1.5.3
```

- https://github.com/kubernetes/kubectl
- https://github.com/kubernetes/kubernetes/tree/master/cmd/kubectl
- https://kubernetes.io/releases/version-skew-policy/#kubectl
- https://kubernetes.io/docs/reference/kubectl/generated/kubectl/
- https://learn.microsoft.com/en-us/azure/aks/learn/quick-kubernetes-deploy-cli#connect-to-the-cluster
- https://learn.microsoft.com/en-us/azure/aks/tutorial-kubernetes-deploy-cluster?tabs=azure-cli#install-the-kubernetes-cli
- https://learn.microsoft.com/en-us/cli/azure/aks?view=azure-cli-latest#az-aks-install-cli

## kubectl.spec.discovery/memcache
```
# stopped the cluster

az aks get-credentials -g $rg -n aks # retrieves credentials
kubectl get ns
E0918 19:30:42.864781    3734 memcache.go:265] couldn't get current server API group list: Get "https://aks-rg-efec8e-tgdhcfxs.hcp.swedencentral.azmk8s.io:443/api?timeout=32s": dial tcp: lookup aks-rg-efec8e-tgdhcfxs.hcp.swedencentral.azmk8s.io on 10.255.255.254:53: no such host

nslookup aks-rg-efec8e-tgdhcfxs.hcp.swedencentral.azmk8s.io
Server:         10.255.255.254
Address:        10.255.255.254#53
** server can't find aks-rg-efec8e-tgdhcfxs.hcp.swedencentral.azmk8s.io: NXDOMAIN
```

- https://github.com/kubernetes/kubernetes/blob/master/staging/src/k8s.io/client-go/discovery/cached/memory/memcache.go

## kubectl.spec.command.annotate

```
kubectl delete po nginx
kubectl run nginx --image=nginx
kubectl annotate pod nginx app=nginx # pod/nginx annotated
kubectl describe po nginx | grep Annot # Annotations:      app: nginx
kubectl annotate pod --overwrite nginx app=nginx,app2=nginx2 # pod/nginx annotated
kubectl describe po nginx | grep Annot # Annotations:      app: nginx,app2=nginx2
kubectl annotate pod nginx app- app2- # pod/nginx annotated
kubectl describe po nginx | grep Annot # Annotations:      <none>

kubectl delete po nginx
cat << EOF | kubectl create -f -
apiVersion: v1
kind: Pod
metadata:
  annotations:
    app: nginx
  creationTimestamp: null
  labels:
    run: nginx
  name: nginx
spec:
  containers:
  - image: nginx
    name: nginx
    resources: {}
  dnsPolicy: ClusterFirst
  restartPolicy: Always
EOF
kubectl describe po nginx | grep Annot
```
  
- https://kubernetes.io/docs/reference/kubectl/generated/kubectl_annotate/

## kubectl.spec.command.cluster-info

```
kubectl cluster-info
kubectl cluster-info dump
kubectl cluster-info dump | grep -m 1 cluster-cidr
```

## kubectl.tools

```
# See the section on kubectl debug (exec) for additional tools
# See the section on images for additional tools
```

- https://collabnix.github.io/kubetools/, Cluster with Core CLI tools

### kubectl.tools.fubectl
- https://github.com/kubermatic/fubectl

### kubectl.tools.krew
```
kubectl krew
kubectl krew search # Discover available plugins

export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"
```

- https://github.com/kubernetes-sigs/krew
- https://krew.sigs.k8s.io/docs/user-guide/quickstart/

### kubectl.tools.box
- https://github.com/astefanutti/kubebox

### kubectl.tools.kubecolor
- https://github.com/hidetatz/kubecolor

### kubectl.tools.kubectl-status
- https://github.com/bergerx/kubectl-status

### kubectl.tools.kubelogin

- https://github.com/Azure/kubelogin
- https://azure.github.io/kubelogin/install.html
- https://learn.microsoft.com/en-us/azure/aks/kubelogin-authentication
- https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/#no-auth-provider-found: Azure AKS: kubelogin plugin
- https://learn.microsoft.com/en-us/azure/aks/enable-authentication-microsoft-entra-id: You need kubectl with a minimum version of 1.18.1 or kubelogin. With the Azure CLI and the Azure PowerShell module, these two commands are included and automatically managed. Meaning, they're upgraded by default and running az aks install-cli isn't required or recommended

#### kubectl.tools.kubelogin.error.executable kubelogin failed with exit code 1

- https://stackoverflow.com/questions/74702519/executable-kubelogin-failed-with-exit-code-1: Installing snap via kubelogin may also cause this problem. sudo az aks install-cli
- https://learn.microsoft.com/en-us/answers/questions/1191403/i-couldnt-be-able-to-connect-private-aks-cluster: the issue arises when we install kubelogin via snap. Just execute following command to install kubectl & kubelogin. sudo az aks install-cli

### kubectl.tools.lens

```
# Kubernetes IDE
```

- https://github.com/lensapp/lens
- https://github.com/MuhammedKalkan/OpenLens

### kubectl.tools.viddy
- https://github.com/sachaos/viddy

## kubectl.transport/round_trippers
```
kubectl get ns -v=9
I0918 19:34:31.112817    3808 loader.go:373] Config loaded from file:  /root/.kube/config
I0918 19:34:31.117291    3808 round_trippers.go:466] curl -v -XGET  -H "Accept: application/json;as=Table;v=v1;g=meta.k8s.io,application/json;as=Table;v=v1beta1;g=meta.k8s.io,application/json" -H "User-Agent: kubectl/v1.27.1 (linux/amd64) kubernetes/4c94112" -H "Authorization: Bearer <masked>" 'https://aks-rg-efec8e-tgdhcfxs.hcp.swedencentral.azmk8s.io:443/api/v1/namespaces?limit=500'
I0918 19:34:31.187913    3808 round_trippers.go:495] HTTP Trace: DNS Lookup for aks-rg-efec8e-tgdhcfxs.hcp.swedencentral.azmk8s.io resolved to [{20.240.159.12 }]
I0918 19:34:31.258398    3808 round_trippers.go:510] HTTP Trace: Dial to tcp:20.240.159.12:443 succeed
I0918 19:34:31.441639    3808 round_trippers.go:553] GET https://aks-rg-efec8e-tgdhcfxs.hcp.swedencentral.azmk8s.io:443/api/v1/namespaces?limit=500 200 OK in 324 milliseconds
I0918 19:34:31.441704    3808 round_trippers.go:570] HTTP Statistics: DNSLookup 70 ms Dial 70 ms TLSHandshake 106 ms ServerProcessing 76 ms Duration 324 ms
I0918 19:34:31.441713    3808 round_trippers.go:577] Response Headers:
```

- https://github.com/kubernetes/kubernetes/blob/master/staging/src/k8s.io/client-go/transport/round_trippers.go

