```
kubectl delete po nginx
kubectl run nginx --image=nginx # No resource limits
sleep 10
kubectl get po nginx
kubectl exec -it nginx -- bash

# root@nginx:/#
apt update
apt install stress-ng -y
swapoff -a
for ((i = 0 ; i < 100 ; i++)); do
  stress-ng --vm 1 --vm-bytes 5% -t 1h &> /dev/null &
  sleep 1
done
# command terminated with exit code 137
```

```
kubectl describe po nginx
Status:           Failed
Reason:           Evicted
Message:          The node was low on resource: memory. Threshold quantity: 750Mi, available: 225800Ki. Container nginx was using 4395616Ki, request is 0, has larger consumption of memory.
IP:               10.244.1.3
IPs:
  IP:  10.244.1.3
Containers:
  nginx:
    Container ID:
    Image:          nginx
    Image ID:
    Port:           <none>
    Host Port:      <none>
    State:          Terminated
      Reason:       ContainerStatusUnknown
      Message:      The container could not be located when the pod was terminated
      Exit Code:    137
      Started:      Mon, 01 Jan 0001 00:00:00 +0000
      Finished:     Mon, 01 Jan 0001 00:00:00 +0000
    Last State:     Terminated
      Reason:       ContainerStatusUnknown
      Message:      The container could not be located when the pod was deleted.  The container used to be Running
      Exit Code:    137
      Started:      Mon, 01 Jan 0001 00:00:00 +0000
      Finished:     Mon, 01 Jan 0001 00:00:00 +0000
    Ready:          False
    Restart Count:  1
    Environment:    <none>
    Mounts:
      /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-tv6m9 (ro)
Conditions:
  Type               Status
  DisruptionTarget   True
  Initialized        True
  Ready              False
  ContainersReady    False
  PodScheduled       True
Events:
  Type     Reason     Age    From               Message
  ----     ------     ----   ----               -------
  Warning  Evicted    7m24s  kubelet            The node was low on resource: memory. Threshold quantity: 750Mi, available: 225800Ki. Container nginx was using 4395616Ki, request is 0, has larger consumption of memory.
  Normal   Killing    7m24s  kubelet            Stopping container nginx
  
cat /var/log/syslog
Oct 12 19:34:44 aks-nodepool1-24207654-vmss000002 kubelet[2480]: I1012 19:34:44.999261    2480 eviction_manager.go:374] "Eviction manager: pods ranked for eviction" pods="[default/nginx kube-system/kube-proxy-5thr6 kube-system/csi-azurefile-node-wz6c7 kube-system/csi-azuredisk-node-vsljb kube-system/cloud-node-manager-wcrvk kube-system/azure-ip-masq-agent-mr5d7 kube-system/ama-logs-6h992]"
Oct 12 19:34:45 aks-nodepool1-24207654-vmss000002 kubelet[2480]: I1012 19:34:45.000152    2480 kuberuntime_container.go:709] "Killing container with a grace period" pod="default/nginx" podUID=27aff94d-e0d9-43d1-84d6-9ab000aa57e2 containerName="nginx" containerID="containerd://4296b9e2377fddb0e7e42d20223c36771268cb7a1828315331405b66f0030add" gracePeriod=30
Oct 12 19:34:45 aks-nodepool1-24207654-vmss000002 kubelet[2480]: I1012 19:34:45.357018    2480 kubelet.go:2231] "SyncLoop (PLEG): event for pod" pod="default/nginx" event=&{ID:27aff94d-e0d9-43d1-84d6-9ab000aa57e2 Type:ContainerDied Data:4296b9e2377fddb0e7e42d20223c36771268cb7a1828315331405b66f0030add}
Oct 12 19:34:45 aks-nodepool1-24207654-vmss000002 kubelet[2480]: I1012 19:34:45.445172    2480 eviction_manager.go:595] "Eviction manager: pod is evicted successfully" pod="default/nginx"
```
