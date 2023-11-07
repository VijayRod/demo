```
Nov  7 08:12:59 aks-nodepool1-42802770-vmss000001 kubelet[2513]: I1107 08:12:59.338289    2513 flags.go:64] FLAG: --node-status-update-frequency="10s"
```

- https://kubernetes.io/docs/reference/command-line-tools-reference/kube-controller-manager/: --node-monitor-grace-period duration     Default: 40s
- https://kubernetes.io/docs/reference/node/node-status/: Unknown if the node controller has not heard from the node in the last node-monitor-grace-period
- https://github.com/kubernetes-sigs/kubespray/blob/master/docs/kubernetes-reliability.md: Kubelet updates it status to apiserver periodically, as specified by --node-status-update-frequency. The default value is 10s.... In case the status is updated within --node-monitor-grace-period of time, Kubernetes controller manager considers healthy status of Kubelet
