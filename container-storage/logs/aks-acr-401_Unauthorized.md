In this demo, the actual error is not the 401 but 'failed to resolve reference'.

```
# kubectl run ubuntu --image=$registry.azurecr.io/samples/ubuntu2
pod/ubuntu created

# kubectl describe po ubuntu
Name:             ubuntu
Namespace:        default
Priority:         0
Service Account:  default
Node:             aks-nodepool1-31040111-vmss000003/10.224.0.4
Start Time:       Thu, 03 Aug 2023 12:19:16 +0000
Labels:           run=ubuntu
Annotations:      <none>
Status:           Pending
IP:               10.244.1.6
IPs:
  IP:  10.244.1.6
Containers:
  ubuntu:
    Container ID:
    Image:          imageshack.azurecr.io/samples/ubuntu2
    Image ID:
    Port:           <none>
    Host Port:      <none>
    State:          Waiting
      Reason:       ImagePullBackOff
    Ready:          False
    Restart Count:  0
    Environment:    <none>
    Mounts:
      /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-xvtlk (ro)
Conditions:
  Type              Status
  Initialized       True
  Ready             False
  ContainersReady   False
  PodScheduled      True
Volumes:
  kube-api-access-xvtlk:
    Type:                    Projected (a volume that contains injected data from multiple sources)
    TokenExpirationSeconds:  3607
    ConfigMapName:           kube-root-ca.crt
    ConfigMapOptional:       <nil>
    DownwardAPI:             true
QoS Class:                   BestEffort
Node-Selectors:              <none>
Tolerations:                 node.kubernetes.io/not-ready:NoExecute op=Exists for 300s
                             node.kubernetes.io/unreachable:NoExecute op=Exists for 300s
Events:
  Type     Reason     Age               From               Message
  ----     ------     ----              ----               -------
  Normal   Scheduled  18s               default-scheduler  Successfully assigned default/ubuntu to aks-nodepool1-31040111-vmss000003
  Normal   BackOff    15s               kubelet            Back-off pulling image "imageshack.azurecr.io/samples/ubuntu2"
  Warning  Failed     15s               kubelet            Error: ImagePullBackOff
  Normal   Pulling    2s (x2 over 17s)  kubelet            Pulling image "imageshack.azurecr.io/samples/ubuntu2"
  Warning  Failed     2s (x2 over 16s)  kubelet            Failed to pull image "imageshack.azurecr.io/samples/ubuntu2": [rpc error: code = NotFound desc = failed to pull and unpack image "imageshack.azurecr.io/samples/ubuntu2:latest": failed to resolve reference "imageshack.azurecr.io/samples/ubuntu2:latest": imageshack.azurecr.io/samples/ubuntu2:latest: not found, rpc error: code = Unknown desc = failed to pull and unpack image "imageshack.azurecr.io/samples/ubuntu2:latest": failed to resolve reference "imageshack.azurecr.io/samples/ubuntu2:latest": failed to authorize: failed to fetch anonymous token: unexpected status from GET request to https://imageshack.azurecr.io/oauth2/token?scope=repository%3Asamples%2Fubuntu2%3Apull&service=imageshack.azurecr.io: 401 Unauthorized]
  Warning  Failed     2s (x2 over 16s)  kubelet            Error: ErrImagePull
```

- https://learn.microsoft.com/en-us/azure/container-registry/container-registry-faq#how-do-i-enable-anonymous-pull-access-
- https://learn.microsoft.com/en-us/troubleshoot/azure/azure-kubernetes/cannot-pull-image-from-acr-to-aks-cluster#cause-1-401-unauthorized-error
