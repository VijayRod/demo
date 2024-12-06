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

## kubectl.spec.command.cp
```
kubectl cp ~/.ssh/id_rsa pod-name:/id_rsa # --retries=10
kubectl cp nsenter-es99e8:/tmp/capture_file_nodeC.pcap /tmp/capture_file_nodeC.pcap
```

## kubectl.spec.command.cluster-info

```
kubectl cluster-info
kubectl cluster-info dump
kubectl cluster-info dump | grep -m 1 cluster-cidr
```

## kubectl.spec.command.create

```
# create
kubectl create deploy nginx --image=nginx

# run
kubectl run nginx --image=nginx
kubectl run busybox --image=busybox --command -- sh -c 'sleep 1d' # sleep 1d or sleep 100000 or sleep infinity

# yaml
kubectl create deploy nginx --image=nginx -oyaml --dry-run=client
kubectl run nginx --image=nginx -oyaml --dry-run=client
```

- https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#create
- https://kubernetes.io/docs/reference/kubectl/generated/kubectl_create/

## kubectl.spec.command.delete

```
kubectl delete pods --all # -A
```

```
kubectl create deploy nginx --image=nginx
sleep 10; kubectl get po | grep nginx
kubectl delete deploy nginx --cascade=foreground
```

- https://kubernetes.io/docs/reference/kubectl/cheatsheet/#deleting-resources

## kubectl.spec.command.expose

```
kubectl run --image=nginx nginx --port=80
kubectl expose po nginx --type=LoadBalancer ##--name=public-svc
# kubectl expose po nginx --port=80 # curl ip
# kubectl expose po nginx --port=8080 --target-port=80 # curl ip:8080
```

```
kubectl create deploy nginx --image=nginx --port=80 --replicas=2
kubectl scale deploy nginx --replicas=3
kubectl expose deploy nginx --type=LoadBalancer
```

## kubectl.spec.command.events

Events aren’t saved to the Kubernetes logs and usually get deleted after only an hour, although this is configurable with the –event-ttl flag when you start the Kubernetes API server. It’s best to stream events to a dedicated observability tool so you can retain them for longer time periods and get alerted to failures.

```
kubectl describe po nginx

kubectl get events
kubectl get events -n default
kubectl get events -l run=nginx -A
kubectl get events -w
```

- https://kubernetes.io/docs/reference/command-line-tools-reference/kube-apiserver/: --event-ttl duration     Default: 1h0m0s. Amount of time to retain events.
- https://github.com/kubernetes/kubernetes/issues/52521

## kubectl.spec.command.get

```
kubectl get po -A --show-labels
kubectl get po -A -l k8s-app=kube-dns
kubectl get all -n kube-system --show-labels

# Retrieve the name
kubectl get pods --no-headers -o custom-columns=":metadata.name" # nginx
kubectl get pods -o=name # pod/nginx
var=$(kubectl get po -n kube-system -l k8s-app=kube-dns --no-headers=true | head -n 1 | awk '{print $1}'); echo $var # nginx
```

- https://kubernetes.io/docs/reference/kubectl/cheatsheet/#viewing-and-finding-resources
- https://kubernetes.io/docs/tasks/access-application-cluster/list-all-running-container-images/
- https://stackoverflow.com/questions/35797906/kubernetes-list-all-running-pods-name
- https://stackoverflow.com/questions/51611868/how-do-i-get-a-single-pod-name-for-kubernetes

## kubectl.spec.command.patch

- https://kubernetes.io/docs/tasks/manage-kubernetes-objects/update-api-object-kubectl-patch/
- TBD https://stackoverflow.com/questions/64355902/is-there-a-way-in-kubectl-patch-to-delete-a-specific-object-in-an-array-withou

## kubectl.spec.command.rollout

```
kubectl create deploy nginx --image=nginx
kubectl rollout restart deploy nginx # ds, statefulset
kubectl rollout restart deploy -l app=nginx
kubectl rollout status deploy -l app=nginx # deployment "nginx" successfully rolled out

kubectl rollout restart deploy -n kube-system ama-metrics
```

- https://kubernetes.io/docs/tutorials/kubernetes-basics/update/update-intro/: Performing a Rolling Update

## kubectl.spec.command.scale

```
kubectl scale deploy nginx --replicas=2
```

- https://learn.microsoft.com/en-us/azure/aks/tutorial-kubernetes-scale?tabs=azure-cli#manually-scale-pods

## kubectl.spec.command.taint

```
kubectl describe no aks-nodepool1-45428922-vmss000001 | grep Taints -A 5
Taints:             <none>

# add
kubectl taint nodes aks-nodepool1-45428922-vmss000001 key1=value1:NoSchedule
kubectl taint nodes aks-nodepool1-45428922-vmss000001 key1=value1:NoExecute
kubectl taint nodes aks-nodepool1-45428922-vmss000001 key2=value2:NoSchedule
node/aks-nodepool1-45428922-vmss000001 tainted
node/aks-nodepool1-45428922-vmss000001 tainted
node/aks-nodepool1-45428922-vmss000001 tainted

# remove
kubectl taint nodes aks-nodepool1-45428922-vmss000001 key1=value1:NoSchedule- key1=value1:NoExecute- key2=value2:NoSchedule-
node/aks-nodepool1-45428922-vmss000001 untainted
```

- https://kubernetes.io/docs/concepts/scheduling-eviction/taint-and-toleration/

## kubectl.spec.command.token

```
fqdn=redacted.hcp.swedencentral.azmk8s.io
kubectl create sa k8sadmin
token=$(kubectl create token k8sadmin)
curl --header "Authorization: Bearer $token" https://$fqdn -k # ok
# kubectl delete sa k8sadmin
```

- https://kubernetes.io/docs/tasks/configure-pod-container/configure-service-account/#manually-create-an-api-token-for-a-serviceaccount
  
## kubectl.spec.output

```
## See the section on jq

kubectl get po nginx -oyaml

kubectl get po nginx -ojson
kubectl get po nginx -ojsonpath={.spec.dnsPolicy}
```

- https://kubernetes.io/docs/reference/kubectl/jsonpath/

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

