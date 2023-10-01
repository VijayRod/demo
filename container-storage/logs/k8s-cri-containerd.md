```
# kubectl get no -owide
NAME                                STATUS   ROLES   AGE    VERSION   INTERNAL-IP    EXTERNAL-IP   OS-IMAGE                KERNEL-VERSION      CONTAINER-RUNTIME
aks-nodepool1-11303738-vmss00000w   Ready    agent   124m   v1.25.6   10.224.0.217   <none>        Ubuntu 22.04.2 LTS               5.15.0-1039-azure   containerd://1.7.1+azure-1
aksnp201900000o                     Ready    agent   121m   v1.25.6   10.224.0.66    <none>        Windows Server 2019 Datacenter   10.0.17763.4499     containerd://1.6.21+azure

journalctl -u kubelet > /tmp/kubelet.log && journal -u containerd > /tmp/containerd.log
```

- https://azure.microsoft.com/en-us/updates/azure-kubernetes-service-aks-support-for-containerd-runtime-is-in-preview/
- https://learn.microsoft.com/en-us/azure/aks/cluster-configuration#container-runtime-configuration
- https://learn.microsoft.com/en-us/azure/aks/learn/quick-windows-container-deploy-cli#connect-to-the-cluster
