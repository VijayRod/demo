## evict_k8snode.status.notready

```
# systemctl stop kubelet

kubectl get no -w
aks-nodepool1-45428922-vmss000001   Ready    <none>   121m   v1.30.6
aks-nodepool1-45428922-vmss000001   NotReady   <none>   121m   v1.30.6
aks-nodepool1-45428922-vmss000001   NotReady   <none>   135m   v1.30.6
aks-nodepool1-45428922-vmss000001   Ready      <none>   135m   v1.30.6 # 14m

# **KubeletIsDown (Taints unreachable) -> ~13m -> VMEventScheduled (Virtual machine is going to be restarted) (tbd restart by aks-remediator)
kubectl describe no aks-nodepool1-45428922-vmss000001
Taints:             node.kubernetes.io/unreachable:NoExecute
                    node.kubernetes.io/unreachable:NoSchedule
Unschedulable:      false
Lease:
  HolderIdentity:  aks-nodepool1-45428922-vmss000001
  AcquireTime:     <unset>
  RenewTime:       Fri, 06 Dec 2024 18:07:05 +0000
Conditions:
  Type                          Status    LastHeartbeatTime                 LastTransitionTime                Reason                          Message
  ----                          ------    -----------------                 ------------------                ------                          -------
  Ready                         Unknown   Fri, 06 Dec 2024 18:06:26 +0000   Fri, 06 Dec 2024 18:07:49 +0000   NodeStatusUnknown               Kubelet stopped posting node status.
Events:
  Type     Reason                   Age                 From  Message
  ----     ------                   ----                ----  -------
  Warning  KubeletIsDown            26m                 kubelet-custom-plugin-monitor  Node condition KubeletProblem is now: True, reason: KubeletIsDown, message: "Kubelet service is not running"
  Warning  KubeletIsDown            13m (x26 over 26m)  kubelet-custom-plugin-monitor  Kubelet service is not running
  Warning  VMEventScheduled         13m                 custom-scheduledevents-consolidated-condition-plugin-monitor  Node condition VMEventScheduled is now: True, reason: VMEventScheduled, message: "Reboot Scheduled: Fri, 06 Dec 2024 18:09:55 GMT. DurationInSeconds: -1. Virtual machine is going to be restarted as requested by authorized user. For more information, see https://aka.ms/aks/scheduledevents."
  Warning  VMEventScheduled         12m                 custom-scheduledevents-consolidated-condition-plugin-monitor  Node condition VMEventScheduled is now: True, reason: VMEventScheduled, message: "Reboot Scheduled: Fri, 06 Dec 2024 18:09:55 GMT. DurationInSeconds: -1. Virtual machine is going to be restarted as requested by authorized user. For more information, see https://aka.ms/aks/scheduledevents.\nThrottle Result: Too Many Requests"
  Warning  RebootScheduled          12m                 custom-scheduledevents-consolidated-plugin-monitor  Scheduled: Fri, 06 Dec 2024 18:09:55 GMT. DurationInSeconds: -1. Virtual machine is going to be restarted as requested by authorized user. For more information, see https://aka.ms/aks/scheduledevents.
  Warning  ContainerdStart          12m                 systemd-monitor  Starting containerd container runtime...
  Warning  ContainerRuntimeIsDown   12m                 container-runtime-custom-plugin-monitor  containerd service is not running
  Warning  ContainerRuntimeIsDown   12m                 container-runtime-custom-plugin-monitor  Node condition ContainerRuntimeProblem is now: True, reason: ContainerRuntimeIsDown, message: "containerd service is not running"
  Normal   Starting                 12m                 kubelet  Starting kubelet.
  Warning  Rebooted                 12m                 kubelet  Node aks-nodepool1-45428922-vmss000001 has been rebooted, boot id: 970782d7-1295-4b6d-a4a2-92a2beebabf2
  Normal   NodeHasSufficientMemory  12m (x2 over 12m)   kubelet  Node aks-nodepool1-45428922-vmss000001 status is now: NodeHasSufficientMemory
  Normal   NodeHasNoDiskPressure    12m (x2 over 12m)   kubelet   Node aks-nodepool1-45428922-vmss000001 status is now: NodeHasNoDiskPressure
  Normal   NodeHasSufficientPID     12m (x2 over 12m)   kubelet  Node aks-nodepool1-45428922-vmss000001 status is now: NodeHasSufficientPID
  Normal   NodeNotReady             12m                 kubelet  Node aks-nodepool1-45428922-vmss000001 status is now: NodeNotReady
  Normal   NodeAllocatableEnforced  12m                 kubelet  Updated Node Allocatable limit across pods
  Normal   NodeReady                12m                 kubelet  Node aks-nodepool1-45428922-vmss000001 status is now: NodeReady
  Normal   KubeletIsUp              11m                 kubelet-custom-plugin-monitor  Node condition KubeletProblem is now: False, reason: KubeletIsUp, message: "kubelet service is up"
  Normal   ContainerRuntimeIsUp     11m                 container-runtime-custom-plugin-monitor  Node condition ContainerRuntimeProblem is now: False, reason: ContainerRuntimeIsUp, message: "container runtime service is up"
```

```
# another way instead of waiting for aks-remediator
noderg=$(az aks show -g $rg -n aks --query nodeResourceGroup -o tsv)  
az vmss run-command invoke -g $noderg -n aks-nodepool1-45428922-vmss --command-id RunShellScript --instance-id 1 --scripts "systemctl start kubelet"
```

- https://kubernetes.io/docs/reference/node/node-status/#node-status-fields: A Node's status contains the following information: Addresses Conditions Capacity and Allocatable Info. 
- https://kubernetes.io/docs/reference/node/node-status/#heartbeats: The kubelet is responsible for creating and updating the .status of Nodes, and for updating their related Leases.
- https://github.com/kubernetes/kubernetes/issues/125618#issuecomment-2206300812: an example for node temporarily not ready but pods running. If kubelet disconnects from the ApiServer network, the node will become notready, but the pod on the node is still running.

## evict_k8snode.status.notready.kubelet-unavailable

```
# systemctl stop kubelet

kubectl get no -w
aks-nodepool1-45428922-vmss000001   Ready    <none>   121m   v1.30.6
aks-nodepool1-45428922-vmss000001   NotReady   <none>   121m   v1.30.6
aks-nodepool1-45428922-vmss000001   NotReady   <none>   135m   v1.30.6
aks-nodepool1-45428922-vmss000001   Ready      <none>   135m   v1.30.6 # 14m

# another way instead of waiting for aks-remediator
noderg=$(az aks show -g $rg -n aks --query nodeResourceGroup -o tsv)  
az vmss run-command invoke -g $noderg -n aks-nodepool1-45428922-vmss --command-id RunShellScript --instance-id 1 --scripts "systemctl start kubelet"
```

- https://learn.microsoft.com/en-us/azure/aks/node-auto-repair: NotReady status on consecutive checks within a 10-minute time frame. node doesn't report any status within 10 minutes. AKS identifies an unhealthy node that remains unhealthy for five minutes. The overall auto repair process can take up to an hour to complete.
  
## evict_k8snode.status.notready.port10250.input.drop

```
# node: iptables -A INPUT -p tcp --dport 10250 -j DROP
kubectl get no # aks-nodepool1-14945448-vmss000001   NotReady   agent   26m   v1.28.10

noderg=$(az aks show -g $rg -n aks --query nodeResourceGroup -o tsv)  
az vmss run-command invoke -g $noderg -n aks-nodepool1-14945448-vmss000001 --command-id RunShellScript --instance-id 0 --scripts "iptables -D INPUT -p tcp --dport 10250 -j DROP" # ParentResourceNotFound. 

# Tbd One mitigation strategy is to allow a few minutes for the remediator to take action.
```

- https://learn.microsoft.com/en-us/troubleshoot/azure/azure-kubernetes/connectivity/tunnel-connectivity-issues
- https://kubernetes.io/docs/reference/networking/ports-and-protocols/#node

## evict_k8snode.status.notready.tool.aks-remediator

```
# systemctl stop kubelet

kubectl get no -w
aks-nodepool1-45428922-vmss000001   Ready    <none>   121m   v1.30.6
aks-nodepool1-45428922-vmss000001   NotReady   <none>   121m   v1.30.6
aks-nodepool1-45428922-vmss000001   NotReady   <none>   135m   v1.30.6
aks-nodepool1-45428922-vmss000001   Ready      <none>   135m   v1.30.6 # 14m

# KubeletIsDown (Taints unreachable) -> ~13m -> VMEventScheduled (Virtual machine is going to be restarted) (tbd aks-remediator)
kubectl describe no aks-nodepool1-45428922-vmss000001
Taints:             node.kubernetes.io/unreachable:NoExecute
                    node.kubernetes.io/unreachable:NoSchedule
Unschedulable:      false
Lease:
  HolderIdentity:  aks-nodepool1-45428922-vmss000001
  AcquireTime:     <unset>
  RenewTime:       Fri, 06 Dec 2024 18:07:05 +0000
Conditions:
  Type                          Status    LastHeartbeatTime                 LastTransitionTime                Reason                          Message
  ----                          ------    -----------------                 ------------------                ------                          -------
  Ready                         Unknown   Fri, 06 Dec 2024 18:06:26 +0000   Fri, 06 Dec 2024 18:07:49 +0000   NodeStatusUnknown               Kubelet stopped posting node status.
Events:
  Type     Reason                   Age                 From  Message
  ----     ------                   ----                ----  -------
  Warning  KubeletIsDown            26m                 kubelet-custom-plugin-monitor  Node condition KubeletProblem is now: True, reason: KubeletIsDown, message: "Kubelet service is not running"
  Warning  KubeletIsDown            13m (x26 over 26m)  kubelet-custom-plugin-monitor  Kubelet service is not running
  Warning  VMEventScheduled         13m                 custom-scheduledevents-consolidated-condition-plugin-monitor  Node condition VMEventScheduled is now: True, reason: VMEventScheduled, message: "Reboot Scheduled: Fri, 06 Dec 2024 18:09:55 GMT. DurationInSeconds: -1. Virtual machine is going to be restarted as requested by authorized user. For more information, see https://aka.ms/aks/scheduledevents."
  Warning  VMEventScheduled         12m                 custom-scheduledevents-consolidated-condition-plugin-monitor  Node condition VMEventScheduled is now: True, reason: VMEventScheduled, message: "Reboot Scheduled: Fri, 06 Dec 2024 18:09:55 GMT. DurationInSeconds: -1. Virtual machine is going to be restarted as requested by authorized user. For more information, see https://aka.ms/aks/scheduledevents.\nThrottle Result: Too Many Requests"
  Warning  RebootScheduled          12m                 custom-scheduledevents-consolidated-plugin-monitor  Scheduled: Fri, 06 Dec 2024 18:09:55 GMT. DurationInSeconds: -1. Virtual machine is going to be restarted as requested by authorized user. For more information, see https://aka.ms/aks/scheduledevents.
  Warning  ContainerdStart          12m                 systemd-monitor  Starting containerd container runtime...
  Warning  ContainerRuntimeIsDown   12m                 container-runtime-custom-plugin-monitor  containerd service is not running
  Warning  ContainerRuntimeIsDown   12m                 container-runtime-custom-plugin-monitor  Node condition ContainerRuntimeProblem is now: True, reason: ContainerRuntimeIsDown, message: "containerd service is not running"
  Normal   Starting                 12m                 kubelet  Starting kubelet.
  Warning  Rebooted                 12m                 kubelet  Node aks-nodepool1-45428922-vmss000001 has been rebooted, boot id: 970782d7-1295-4b6d-a4a2-92a2beebabf2
  Normal   NodeHasSufficientMemory  12m (x2 over 12m)   kubelet  Node aks-nodepool1-45428922-vmss000001 status is now: NodeHasSufficientMemory
  Normal   NodeHasNoDiskPressure    12m (x2 over 12m)   kubelet   Node aks-nodepool1-45428922-vmss000001 status is now: NodeHasNoDiskPressure
  Normal   NodeHasSufficientPID     12m (x2 over 12m)   kubelet  Node aks-nodepool1-45428922-vmss000001 status is now: NodeHasSufficientPID
  Normal   NodeNotReady             12m                 kubelet  Node aks-nodepool1-45428922-vmss000001 status is now: NodeNotReady
  Normal   NodeAllocatableEnforced  12m                 kubelet  Updated Node Allocatable limit across pods
  Normal   NodeReady                12m                 kubelet  Node aks-nodepool1-45428922-vmss000001 status is now: NodeReady
  Normal   KubeletIsUp              11m                 kubelet-custom-plugin-monitor  Node condition KubeletProblem is now: False, reason: KubeletIsUp, message: "kubelet service is up"
  Normal   ContainerRuntimeIsUp     11m                 container-runtime-custom-plugin-monitor  Node condition ContainerRuntimeProblem is now: False, reason: ContainerRuntimeIsUp, message: "container runtime service is up"
```

```
# another way instead of waiting for aks-remediator
noderg=$(az aks show -g $rg -n aks --query nodeResourceGroup -o tsv)  
az vmss run-command invoke -g $noderg -n aks-nodepool1-45428922-vmss --command-id RunShellScript --instance-id 1 --scripts "systemctl start kubelet"
```

- https://learn.microsoft.com/en-us/azure/aks/node-auto-repair: AKS initiates repair operations with the user account aks-remediator.
  
## evict_k8snode.status.notready.kube-controller-manager

```
Nov  7 08:12:59 aks-nodepool1-42802770-vmss000001 kubelet[2513]: I1107 08:12:59.338289    2513 flags.go:64] FLAG: --node-status-update-frequency="10s"
```

- https://kubernetes.io/docs/reference/command-line-tools-reference/kube-controller-manager/: --node-monitor-grace-period duration     Default: 40s
  - Amount of time which we allow running Node to be unresponsive before marking it unhealthy. Must be N times more than kubelet's nodeStatusUpdateFrequency, where N means number of retries allowed for kubelet to post node status.
- https://kubernetes.io/docs/reference/node/node-status/#condition: Node Condition Ready. False if the node is not healthy and is not accepting pods, and Unknown if the node controller has not heard from the node in the last node-monitor-grace-period (default is 40 seconds)
  - when the status of the Ready condition remains Unknown or False for longer than the kube-controller-manager's NodeMonitorGracePeriod, which defaults to 40 seconds. This will cause either an node.kubernetes.io/unreachable taint, for an Unknown status, or a node.kubernetes.io/not-ready taint, for a False status, to be added to the Node.
- https://github.com/kubernetes-sigs/kubespray/blob/master/docs/kubernetes-reliability.md: Kubelet updates it status to apiserver periodically, as specified by --node-status-update-frequency. The default value is 10s.... In case the status is updated within --node-monitor-grace-period of time, Kubernetes controller manager considers healthy status of Kubelet
