```
# Blocks node communication, including DNS traffic on UDP/TCP port 53.

rg=rg
az group create -n $rg -l $loc
az aks create -g $rg -n aks -s $vmsize -c 1
az aks get-credentials -g $rg -n aks --overwrite-existing
kubectl get no

root@aks-nodepool1-40004829-vmss000003:/# nslookup google.com
;; communications error to 168.63.129.16#53: timed out
;; communications error to 168.63.129.16#53: timed out
;; communications error to 168.63.129.16#53: timed out
;; no servers could be reached

root@aks-nodepool1-40004829-vmss000003:/# ping google.com
ping: google.com: Temporary failure in name resolution

root@aks-nodepool1-40004829-vmss000003:/# cat /var/log/syslog
Nov 23 19:15:12 aks-nodepool1-40004829-vmss000003 node-problem-detector-startup.sh[3466]: E1123 19:15:12.802579    3466 manager.go:162] failed to update node conditions: Patch "https://aks-rg-111111-11111111.hcp.swedencentral.azmk8s.io:443/api/v1/nodes/aks-nodepool1-40004829-vmss000003/status": dial tcp: lookup aks-rg-111111-11111111.hcp.swedencentral.azmk8s.io on 168.63.129.16:53: write udp 10.224.0.4:33642->168.63.129.16:53: write: operation not permitted

kubectl get no
NAME                                STATUS   ROLES   AGE   VERSION
aks-nodepool1-40004829-vmss000003   Ready    agent   77m   v1.27.7

kubectl describe no aks-nodepool1-40004829-vmss000003 # Multiple conditions have not been updated since the 19:02 availability of TCP/UDP ports 53
Conditions:
  Type                          Status  LastHeartbeatTime                 LastTransitionTime                Reason                          Message
  ----                          ------  -----------------                 ------------------                ------                          -------
  NetworkUnavailable            False   Thu, 23 Nov 2023 18:12:48 +0000   Thu, 23 Nov 2023 18:12:48 +0000   RouteCreated                    RouteController created a route
  ContainerRuntimeProblem       False   Thu, 23 Nov 2023 19:02:02 +0000   Thu, 23 Nov 2023 18:11:19 +0000   ContainerRuntimeIsUp            container runtime service is up
  FrequentDockerRestart         False   Thu, 23 Nov 2023 19:02:02 +0000   Thu, 23 Nov 2023 18:11:19 +0000   NoFrequentDockerRestart         docker is functioning properly
  ReadonlyFilesystem            False   Thu, 23 Nov 2023 19:02:02 +0000   Thu, 23 Nov 2023 18:11:19 +0000   FilesystemIsNotReadOnly         Filesystem is not read-only
  KernelDeadlock                False   Thu, 23 Nov 2023 19:02:02 +0000   Thu, 23 Nov 2023 18:11:19 +0000   KernelHasNoDeadlock             kernel has no deadlock
  FilesystemCorruptionProblem   False   Thu, 23 Nov 2023 19:02:02 +0000   Thu, 23 Nov 2023 18:11:19 +0000   FilesystemIsOK                  Filesystem is healthy
  KubeletProblem                False   Thu, 23 Nov 2023 19:02:02 +0000   Thu, 23 Nov 2023 18:11:19 +0000   KubeletIsUp                     kubelet service is up
  VMEventScheduled              False   Thu, 23 Nov 2023 19:02:02 +0000   Thu, 23 Nov 2023 18:11:54 +0000   NoVMEventScheduled              VM has no scheduled event
  FrequentUnregisterNetDevice   False   Thu, 23 Nov 2023 19:02:02 +0000   Thu, 23 Nov 2023 18:11:19 +0000   NoFrequentUnregisterNetDevice   node is functioning properly
  FrequentContainerdRestart     False   Thu, 23 Nov 2023 19:02:02 +0000   Thu, 23 Nov 2023 18:11:19 +0000   NoFrequentContainerdRestart     containerd is functioning properly
  FrequentKubeletRestart        False   Thu, 23 Nov 2023 19:02:02 +0000   Thu, 23 Nov 2023 18:11:19 +0000   NoFrequentKubeletRestart        kubelet is functioning properly
  MemoryPressure                False   Thu, 23 Nov 2023 19:20:40 +0000   Thu, 23 Nov 2023 18:11:14 +0000   KubeletHasSufficientMemory      kubelet has sufficient memory available
  DiskPressure                  False   Thu, 23 Nov 2023 19:20:40 +0000   Thu, 23 Nov 2023 18:11:14 +0000   KubeletHasNoDiskPressure        kubelet has no disk pressure
  PIDPressure                   False   Thu, 23 Nov 2023 19:20:40 +0000   Thu, 23 Nov 2023 18:11:14 +0000   KubeletHasSufficientPID         kubelet has sufficient PID available
  Ready                         True    Thu, 23 Nov 2023 19:20:40 +0000   Thu, 23 Nov 2023 18:11:15 +0000   KubeletReady                    kubelet is posting ready status. AppArmor enabled
## The below is after the availability of TCP/UDP ports 53 around 19:29
Conditions:
  Type                          Status  LastHeartbeatTime                 LastTransitionTime                Reason                          Message
  ----                          ------  -----------------                 ------------------                ------                          -------
  NetworkUnavailable            False   Thu, 23 Nov 2023 18:12:48 +0000   Thu, 23 Nov 2023 18:12:48 +0000   RouteCreated                    RouteController created a route
  KubeletProblem                False   Thu, 23 Nov 2023 19:29:16 +0000   Thu, 23 Nov 2023 18:11:19 +0000   KubeletIsUp                     kubelet service is up
  VMEventScheduled              False   Thu, 23 Nov 2023 19:29:16 +0000   Thu, 23 Nov 2023 18:11:54 +0000   NoVMEventScheduled              VM has no scheduled event
  FrequentUnregisterNetDevice   False   Thu, 23 Nov 2023 19:29:16 +0000   Thu, 23 Nov 2023 18:11:19 +0000   NoFrequentUnregisterNetDevice   node is functioning properly
  FrequentContainerdRestart     False   Thu, 23 Nov 2023 19:29:16 +0000   Thu, 23 Nov 2023 18:11:19 +0000   NoFrequentContainerdRestart     containerd is functioning properly
  FrequentKubeletRestart        False   Thu, 23 Nov 2023 19:29:16 +0000   Thu, 23 Nov 2023 18:11:19 +0000   NoFrequentKubeletRestart        kubelet is functioning properly
  KernelDeadlock                False   Thu, 23 Nov 2023 19:29:16 +0000   Thu, 23 Nov 2023 18:11:19 +0000   KernelHasNoDeadlock             kernel has no deadlock
  FilesystemCorruptionProblem   False   Thu, 23 Nov 2023 19:29:16 +0000   Thu, 23 Nov 2023 18:11:19 +0000   FilesystemIsOK                  Filesystem is healthy
  ReadonlyFilesystem            False   Thu, 23 Nov 2023 19:29:16 +0000   Thu, 23 Nov 2023 18:11:19 +0000   FilesystemIsNotReadOnly         Filesystem is not read-only
  ContainerRuntimeProblem       False   Thu, 23 Nov 2023 19:29:16 +0000   Thu, 23 Nov 2023 18:11:19 +0000   ContainerRuntimeIsUp            container runtime service is up
  FrequentDockerRestart         False   Thu, 23 Nov 2023 19:29:16 +0000   Thu, 23 Nov 2023 18:11:19 +0000   NoFrequentDockerRestart         docker is functioning properly
  MemoryPressure                False   Thu, 23 Nov 2023 19:25:47 +0000   Thu, 23 Nov 2023 18:11:14 +0000   KubeletHasSufficientMemory      kubelet has sufficient memory available
  DiskPressure                  False   Thu, 23 Nov 2023 19:25:47 +0000   Thu, 23 Nov 2023 18:11:14 +0000   KubeletHasNoDiskPressure        kubelet has no disk pressure
  PIDPressure                   False   Thu, 23 Nov 2023 19:25:47 +0000   Thu, 23 Nov 2023 18:11:14 +0000   KubeletHasSufficientPID         kubelet has sufficient PID available
  Ready                         True    Thu, 23 Nov 2023 19:25:47 +0000   Thu, 23 Nov 2023 18:11:15 +0000   KubeletReady                    kubelet is posting ready status. AppArmor enabled

kubectl delete po nginx
kubectl run nginx --image=nginx --overrides='{"spec": { "nodeSelector": {"kubernetes.io/hostname": "aks-nodepool1-40004829-vmss000000"}}}'
sleep 10
kubectl get po nginx # Newly created pods are not assigned to the specified node; instead, they are automatically assigned to a different available node. This issue is likely caused by the non-updated node condition

kubectl delete po busybox
kubectl run busybox --image=busybox --command -- sh -c 'sleep 1d' --overrides='{"spec": { "nodeSelector": {"kubernetes.io/hostname": "aks-nodepool1-40004829-vmss000005"}}}'
sleep 10
kubectl get po busybox -owide
kubectl exec -it busybox -- nslookup google.com # nslookup in existing pods returns the same values before and after port availability
Server:         10.0.0.10
Address:        10.0.0.10:53
Name:   google.com
Address: 142.250.74.14
Non-authoritative answer:
Name:   google.com
Address: 2a00:1450:400f:800::200e

kubectl get svc -n kube-system
NAME             TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)         AGE
kube-dns         ClusterIP   10.0.0.10      <none>        53/UDP,53/TCP   19h
```

```
TBD (so far same nslookup success even with port 53 issues on node running coredns and user pod)
kubectl delete po -n kube-system -l k8s-app=kube-dns
kubectl get po -n kube-system -owide -l k8s-app=kube-dns
kubectl logs -n kube-system -l k8s-app=kube-dns
kubectl get po -owide
```
