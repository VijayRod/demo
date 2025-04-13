```
kubectl get po -n kube-system -l k8s-app=kube-dns
kubectl get po -n kube-system -l k8s-app=coredns-autoscaler
kubectl -n kube-system top pod | grep coredns
```

- https://kubernetes.io/docs/tasks/access-application-cluster/configure-dns-cluster/: CoreDNS is recommended and is installed by default with kubeadm
- https://kubernetes.io/docs/tasks/administer-cluster/dns-debugging-resolution/
- https://www.tkng.io/dns/
- https://github.com/kubernetes/dns: repository for Kubernetes DNS(kube-dns and nodelocaldns)
- https://github.com/kubernetes/kubernetes/blob/v1.24.9/cluster/addons/dns/coredns/coredns.yaml.base
- - https://learn.microsoft.com/en-us/troubleshoot/azure/azure-kubernetes/connectivity/troubleshoot-dns-failures-across-an-aks-cluster-in-real-time
