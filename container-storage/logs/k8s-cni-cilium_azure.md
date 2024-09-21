## cni.cilium.azure

```
rg=rgcni
az group create -n $rg -l $loc
az aks create -g $rg -n aks --network-plugin azure --network-plugin-mode overlay --pod-cidr 192.168.0.0/16 --network-dataplane cilium -s $vmsize -c 1 
az aks get-credentials -g $rg -n aks --overwrite-existing
```

```
az aks show -g $rg -n aks --query networkProfile.networkDataplane # cilium
az aks show -g $rg -n aks --query networkProfile.networkPlugin # azure
az aks show -g $rg -n aks --query networkProfile.networkPluginMode # overlay
az aks show -g $rg -n aks --query networkProfile.networkPolicy # cilium

kubectl get po -n kube-system --show-labels
NAME                                  READY   STATUS    RESTARTS   AGE     LABELS
cilium-l7dhk                          1/1     Running   0          3m39s   controller-revision-hash=6c49c64c6f,k8s-app=cilium,kubernetes.azure.com/ebpf-dataplane=cilium,pod-template-generation=1
cilium-operator-8cff7865b-g96jk       1/1     Running   0          3m39s   io.cilium/app=operator,kubernetes.azure.com/ebpf-dataplane=cilium,name=cilium-operator,pod-template-hash=8cff7865b

kubectl get all -n kube-system -l kubernetes.azure.com/ebpf-dataplane=cilium
NAME                                  READY   STATUS    RESTARTS   AGE
pod/cilium-l7dhk                      1/1     Running   0          5m6s
pod/cilium-operator-8cff7865b-g96jk   1/1     Running   0          5m6s

NAME                                        DESIRED   CURRENT   READY   AGE
replicaset.apps/cilium-operator-8cff7865b   1         1         1       5m6s
```

- https://techcommunity.microsoft.com/t5/azure-networking-blog/azure-cni-powered-by-cilium-for-azure-kubernetes-service-aks/ba-p/3662341: Cilium eBPF
- https://learn.microsoft.com/en-us/azure/aks/azure-cni-powered-by-cilium
- https://azure.microsoft.com/en-us/updates/azure-cni-powered-by-cilium/
- https://kubernetes.io/docs/tasks/administer-cluster/network-policy-provider/cilium-network-policy/

## cni.cilium.azure.networkpolicy

```
```

- https://learn.microsoft.com/en-us/azure/aks/azure-cni-powered-by-cilium#network-policy-enforcement
- https://cilium.io/industries/cloud-providers/
- https://docs.cilium.io/en/stable/#getting-started
- https://docs.cilium.io/en/stable/operations/troubleshooting/
- https://docs.cilium.io/en/v1.9/gettingstarted/k8s-install-aks/
