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

## kubectl.discovery/memcache
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

## kubectl.get-credentials

```
az aks get-credentials -g $rg -n aks
kubectl get ns -v=9
I0918 19:34:31.112817    3808 loader.go:373] Config loaded from file:  /root/.kube/config
I0918 19:34:31.117291    3808 round_trippers.go:466] curl -v -XGET  -H "Accept: application/json;as=Table;v=v1;g=meta.k8s.io,application/json;as=Table;v=v1beta1;g=meta.k8s.io,application/json" -H "User-Agent: kubectl/v1.27.1 (linux/amd64) kubernetes/4c94112" -H "Authorization: Bearer <masked>" 'https://aks-rg-efec8e-tgdhcfxs.hcp.swedencentral.azmk8s.io:443/api/v1/namespaces?limit=500'
I0918 19:34:31.187913    3808 round_trippers.go:495] HTTP Trace: DNS Lookup for aks-rg-efec8e-tgdhcfxs.hcp.swedencentral.azmk8s.io resolved to [{20.240.159.12 }]
I0918 19:34:31.258398    3808 round_trippers.go:510] HTTP Trace: Dial to tcp:20.240.159.12:443 succeed
I0918 19:34:31.441639    3808 round_trippers.go:553] GET https://aks-rg-efec8e-tgdhcfxs.hcp.swedencentral.azmk8s.io:443/api/v1/namespaces?limit=500 200 OK in 324 milliseconds
I0918 19:34:31.441704    3808 round_trippers.go:570] HTTP Statistics: DNSLookup 70 ms Dial 70 ms TLSHandshake 106 ms ServerProcessing 76 ms Duration 324 ms
I0918 19:34:31.441713    3808 round_trippers.go:577] Response Headers:
I0918 19:34:31.441724    3808 round_trippers.go:580]     X-Kubernetes-Pf-Prioritylevel-Uid: 3e77aef6-9abf-4527-9023-f65c428babd0
I0918 19:34:31.441732    3808 round_trippers.go:580]     Date: Wed, 18 Sep 2024 09:34:31 GMT
I0918 19:34:31.441740    3808 round_trippers.go:580]     Audit-Id: afb4fef3-1b35-49ac-ae33-c9749592eeec
I0918 19:34:31.441748    3808 round_trippers.go:580]     Cache-Control: no-cache, private
I0918 19:34:31.441755    3808 round_trippers.go:580]     Content-Type: application/json
I0918 19:34:31.441762    3808 round_trippers.go:580]     X-Kubernetes-Pf-Flowschema-Uid: b7d2df8f-19fa-441e-bae8-a58d416e4028
I0918 19:34:31.441949    3808 request.go:1188] Response Body: {"kind":"Table","apiVersion":"meta.k8s.io/v1","metadata":{"resourceVersion":"165263"},"columnDefinitions":[{"name":"Name","type":"string","format":"name","description":"Name must be unique within a namespace. Is required when creating resources, although some resources may allow a client to request the generation of an appropriate name automatically. Name is primarily intended for creation idempotence and configuration definition. Cannot be updated. More info: https://kubernetes.io/docs/concepts/overview/working-with-objects/names#names","priority":0},{"name":"Status","type":"string","format":"","description":"The status of the namespace","priority":0},{"name":"Age","type":"string","format":"","description":"CreationTimestamp is a timestamp representing the server time when this object was created. It is not guaranteed to be set in happens-before order across separate operations. Clients may not set this value. It is represented in RFC3339 form and is in UTC.\n\nPopulated by the system. Read-only. Null for lists. More info: https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#metadata","priority":0}],"rows":[{"cells":["default","Active","21h"],"object":{"kind":"PartialObjectMetadata","apiVersion":"meta.k8s.io/v1","metadata":{"name":"default","uid":"64ff44b6-7fd6-430a-95db-cbd3e5450be3","resourceVersion":"38","creationTimestamp":"2024-09-17T11:57:54Z","labels":{"kubernetes.io/metadata.name":"default"},"managedFields":[{"manager":"kube-apiserver","operation":"Update","apiVersion":"v1","time":"2024-09-17T11:57:54Z","fieldsType":"FieldsV1","fieldsV1":{"f:metadata":{"f:labels":{".":{},"f:kubernetes.io/metadata.name":{}}}}}]}}},{"cells":["kube-node-lease","Active","21h"],"object":{"kind":"PartialObjectMetadata","apiVersion":"meta.k8s.io/v1","metadata":{"name":"kube-node-lease","uid":"fffd2d3f-465e-4a0a-9c3d-d785a6ce553d","resourceVersion":"28","creationTimestamp":"2024-09-17T11:57:54Z","labels":{"kubernetes.io/metadata.name":"kube-node-lease"},"managedFields":[{"manager":"kube-apiserver","operation":"Update","apiVersion":"v1","time":"2024-09-17T11:57:54Z","fieldsType":"FieldsV1","fieldsV1":{"f:metadata":{"f:labels":{".":{},"f:kubernetes.io/metadata.name":{}}}}}]}}},{"cells":["kube-public","Active","21h"],"object":{"kind":"PartialObjectMetadata","apiVersion":"meta.k8s.io/v1","metadata":{"name":"kube-public","uid":"87858a76-89b3-4aa0-8a93-bfcf847a34cd","resourceVersion":"19","creationTimestamp":"2024-09-17T11:57:54Z","labels":{"kubernetes.io/metadata.name":"kube-public"},"managedFields":[{"manager":"kube-apiserver","operation":"Update","apiVersion":"v1","time":"2024-09-17T11:57:54Z","fieldsType":"FieldsV1","fieldsV1":{"f:metadata":{"f:labels":{".":{},"f:kubernetes.io/metadata.name":{}}}}}]}}},{"cells":["kube-system","Active","21h"],"object":{"kind":"PartialObjectMetadata","apiVersion":"meta.k8s.io/v1","metadata":{"name":"kube-system","uid":"d8823679-d5ee-4bd9-8782-031245332ad4","resourceVersion":"531","creationTimestamp":"2024-09-17T11:57:54Z","labels":{"addonmanager.kubernetes.io/mode":"Reconcile","control-plane":"true","kubernetes.azure.com/managedby":"aks","kubernetes.io/cluster-service":"true","kubernetes.io/metadata.name":"kube-system"},"annotations":{"kubectl.kubernetes.io/last-applied-configuration":"{\"apiVersion\":\"v1\",\"kind\":\"Namespace\",\"metadata\":{\"annotations\":{},\"labels\":{\"addonmanager.kubernetes.io/mode\":\"Reconcile\",\"control-plane\":\"true\",\"kubernetes.azure.com/managedby\":\"aks\",\"kubernetes.io/cluster-service\":\"true\"},\"name\":\"kube-system\"}}\n"},"managedFields":[{"manager":"kube-apiserver","operation":"Update","apiVersion":"v1","time":"2024-09-17T11:57:54Z","fieldsType":"FieldsV1","fieldsV1":{"f:metadata":{"f:labels":{".":{},"f:kubernetes.io/metadata.name":{}}}}},{"manager":"kubectl-client-side-apply","operation":"Update","apiVersion":"v1","time":"2024-09-17T11:58:36Z","fieldsType":"FieldsV1","fieldsV1":{"f:metadata":{"f:annotations":{".":{},"f:kubectl.kubernetes.io/last-applied-configuration":{}},"f:labels":{"f:addonmanager.kubernetes.io/mode":{},"f:control-plane":{},"f:kubernetes.azure.com/managedby":{},"f:kubernetes.io/cluster-service":{}}}}}]}}}]}
NAME              STATUS   AGE
default           Active   21h
kube-node-lease   Active   21h
kube-public       Active   21h
kube-system       Active   21h
```

## kubectl.tools
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

