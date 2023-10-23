```
rg=rgcal
az group create -n $rg -l $loc
az aks create -g $rg -n aks --network-plugin azure --network-policy calico -s $vmsize -c 1
# az aks create -g $rg -n akskubecal --network-plugin kubenet --network-policy calico -s $vmsize -c 1
az aks get-credentials -g $rg -n aks --overwrite-existing
kubectl get all -n calico-system --show-labels
kubectl get all -n tigera-operator --show-labels
```

```
kubectl get all -n calico-system --show-labels
NAME                                           READY   STATUS    RESTARTS   AGE     LABELS
pod/calico-kube-controllers-74cbcf688c-bcp7z   1/1     Running   0          3h32m   app.kubernetes.io/name=calico-kube-controllers,k8s-app=calico-kube-controllers,pod-template-hash=74cbcf688c
pod/calico-node-grnmb                          1/1     Running   0          3h32m   app.kubernetes.io/name=calico-node,controller-revision-hash=58d58f64c,k8s-app=calico-node,pod-template-generation=1
pod/calico-typha-7cb9cff6c4-9kxhd              1/1     Running   0          3h32m   app.kubernetes.io/name=calico-typha,k8s-app=calico-typha,pod-template-hash=7cb9cff6c4

NAME                                      TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)    AGE     LABELS
service/calico-kube-controllers-metrics   ClusterIP   None         <none>        9094/TCP   3h32m   k8s-app=calico-kube-controllers
service/calico-typha                      ClusterIP   10.0.55.59   <none>        5473/TCP   3h32m   k8s-app=calico-typha

NAME                                    DESIRED   CURRENT   READY   UP-TO-DATE   AVAILABLE   NODE SELECTOR    AGE     LABELS
daemonset.apps/calico-node              1         1         1       1            1           kubernetes.io/os=linux     3h32m   <none>
daemonset.apps/calico-windows-upgrade   0         0         0       0            0           kubernetes.io/os=windows   3h32m   <none>

NAME                                      READY   UP-TO-DATE   AVAILABLE   AGE     LABELS
deployment.apps/calico-kube-controllers   1/1     1            1           3h32m   app.kubernetes.io/name=calico-kube-controllers,k8s-app=calico-kube-controllers
deployment.apps/calico-typha              1/1     1            1           3h32m   app.kubernetes.io/name=calico-typha,k8s-app=calico-typha

NAME                                                 DESIRED   CURRENT   READY   AGE     LABELS
replicaset.apps/calico-kube-controllers-74cbcf688c   1         1         1       3h32m   app.kubernetes.io/name=calico-kube-controllers,k8s-app=calico-kube-controllers,pod-template-hash=74cbcf688c
replicaset.apps/calico-typha-7cb9cff6c4              1         1         1       3h32m   app.kubernetes.io/name=calico-typha,k8s-app=calico-typha,pod-template-hash=7cb9cff6c4

kubectl describe po -n calico-system | grep Image:
    Image:          mcr.microsoft.com/oss/calico/kube-controllers:v3.24.6
    Image:          mcr.microsoft.com/oss/calico/pod2daemon-flexvol:v3.24.6
    Image:         mcr.microsoft.com/oss/calico/cni:v3.24.6
    Image:          mcr.microsoft.com/oss/calico/node:v3.24.6
    Image:          mcr.microsoft.com/oss/calico/typha:v3.24.6

kubectl get all -n tigera-operator --show-labels
NAME                                  READY   STATUS    RESTARTS   AGE     LABELS
pod/tigera-operator-644ddf967-xnttp   1/1     Running   0          8m45s   k8s-app=tigera-operator,kubernetes.azure.com/managedby=aks,name=tigera-operator,pod-template-hash=644ddf967

NAME                              READY   UP-TO-DATE   AVAILABLE   AGE     LABELS
deployment.apps/tigera-operator   1/1     1            1           8m45s   addonmanager.kubernetes.io/mode=Reconcile,k8s-app=tigera-operator,kubernetes.azure.com/managedby=aks

NAME                                        DESIRED   CURRENT   READY   AGE     LABELS
replicaset.apps/tigera-operator-644ddf967   1         1         1       8m45s   k8s-app=tigera-operator,kubernetes.azure.com/managedby=aks,name=tigera-operator,pod-template-hash=644ddf967

kubectl describe po -n tigera-operator | grep Image:
    Image:         mcr.microsoft.com/oss/tigera/operator:v1.28.13
```

```
# Calico pods will be unavailable for a few seconds until they are automatically recreated
kubectl delete deploy -n calico-system calico-kube-controllers
kubectl delete deploy -n calico-system calico-typha
kubectl delete ds -n calico-system calico-node
kubectl delete ds -n calico-system calico-windows-upgrade
```

- https://docs.tigera.io/calico/latest/getting-started/kubernetes/managed-public-cloud/aks
- https://github.com/projectcalico/calico
- https://learn.microsoft.com/en-us/azure/aks/use-network-policies#differences-between-azure-network-policy-manager-and-calico-network-policy-and-their-capabilities
- https://www.tigera.io/tigera-products/calico/: Calico Open Source offers a choice of data planes, including a pure Linux eBPF data plane
- https://azure.microsoft.com/en-us/blog/integrating-azure-cni-and-calico-a-technical-deep-dive/
- https://techcommunity.microsoft.com/t5/azure-developer-community-blog/7-security-best-practices-for-managing-containerized-workloads/ba-p/3786506
- https://github.com/Azure/AKS/releases?q=%22Updated+Calico%22&expanded=true
- https://github.com/Azure/AKS/blob/master/vhd-notes/aks-ubuntu/AKSUbuntu-2204/202309.06.0.txt: mcr.microsoft.com/oss/calico/...
