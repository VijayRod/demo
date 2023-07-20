The KubeEvents table provides information about events that occur within a Kubernetes environment.

```
# kubectl run nginx2 --image=nginx2
pod/nginx2 created
```

```
# kubectl get po
NAME     READY   STATUS         RESTARTS   AGE
nginx2   0/1     ErrImagePull   0          4s

# kubectl describe po nginx2
Status:           Pending
Containers:
  nginx2:
    Container ID:
    Image:          nginx2
    Image ID:
    Port:           <none>
    Host Port:      <none>
    State:          Waiting
      Reason:       ImagePullBackOff
    Ready:          False
    Restart Count:  0
    Environment:    <none>
    Mounts:
      /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-ndfpf (ro)
Conditions:
  Type              Status
  Initialized       True
  Ready             False
  ContainersReady   False
  PodScheduled      True
Events:
  Type     Reason     Age                             From               Message
  ----     ------     ----                            ----               -------
  Normal   Scheduled  <invalid>                       default-scheduler  Successfully assigned default/nginx2 to aks-nodepool1-51397738-vmss00000b
  Normal   Pulling    <invalid> (x4 over <invalid>)   kubelet            Pulling image "nginx2"
  Warning  Failed     <invalid> (x4 over <invalid>)   kubelet            Failed to pull image "nginx2": rpc error: code = Unknown desc = failed to pull and unpack image "docker.io/library/nginx2:latest": failed to resolve reference "docker.io/library/nginx2:latest": pull access denied, repository does not exist or may require authorization: server message: insufficient_scope: authorization failed
  Warning  Failed     <invalid> (x4 over <invalid>)   kubelet            Error: ErrImagePull
  Warning  Failed     <invalid> (x6 over <invalid>)   kubelet            Error: ImagePullBackOff
  Normal   BackOff    <invalid> (x63 over <invalid>)  kubelet            Back-off pulling image "nginx2"
```

```
KubePodInventory
| where Name startswith "nginx2"
| project TimeGenerated, Namespace, Name, PodStatus, ContainerStatusReason

# Here is a sample output below.
TimeGenerated [UTC]	Namespace	Name	PodStatus	ContainerStatusReason
7/19/2023, 10:20:31.000 AM	default	nginx2	Pending	ImagePullBackOff
```

```
KubeEvents
| where ObjectKind =="Pod" and Name startswith "nginx2"
| project TimeGenerated, Namespace, Name, Reason, Message

# Here is a sample output below.
TimeGenerated [UTC]	Namespace	Name	Reason	Message
7/19/2023, 10:13:12.000 AM	default	nginx2	Failed	Failed to pull image "nginx2": rpc error: code = Unknown desc = failed to pull and unpack image "docker.io/library/nginx2:latest": failed to resolve reference "docker.io/library/nginx2:latest": pull access denied, repository does not exist or may require authorization: server message: insufficient_scope: authorization failed
7/19/2023, 10:13:12.000 AM	default	nginx2	Failed	Error: ErrImagePull
7/19/2023, 10:13:13.000 AM	default	nginx2	Failed	Error: ImagePullBackOff
```

- https://learn.microsoft.com/en-us/azure/azure-monitor/reference/tables/kubeevents
