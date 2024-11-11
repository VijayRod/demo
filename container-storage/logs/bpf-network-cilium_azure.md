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

k api-resources | grep cilium
ciliumcidrgroups                    ccg                                 cilium.io/v2alpha1                     false        CiliumCIDRGroup
ciliumclusterwidenetworkpolicies    ccnp                                cilium.io/v2                           false        CiliumClusterwideNetworkPolicy
ciliumendpoints                     cep,ciliumep                        cilium.io/v2                           true         CiliumEndpoint
ciliumexternalworkloads             cew                                 cilium.io/v2                           false        CiliumExternalWorkload
ciliumidentities                    ciliumid                            cilium.io/v2                           false        CiliumIdentity
ciliuml2announcementpolicies        l2announcement                      cilium.io/v2alpha1                     false        CiliumL2AnnouncementPolicy
ciliumloadbalancerippools           ippools,ippool,lbippool,lbippools   cilium.io/v2alpha1                     false        CiliumLoadBalancerIPPool
ciliumnetworkpolicies               cnp,ciliumnp                        cilium.io/v2                           true         CiliumNetworkPolicy
ciliumnodeconfigs                                                       cilium.io/v2alpha1                     true         CiliumNodeConfig
ciliumnodes                         cn,ciliumn                          cilium.io/v2                           false        CiliumNode
ciliumpodippools                    cpip                                cilium.io/v2alpha1                     false        CiliumPodIPPool
```

- https://techcommunity.microsoft.com/t5/azure-networking-blog/azure-cni-powered-by-cilium-for-azure-kubernetes-service-aks/ba-p/3662341: Cilium eBPF
- https://learn.microsoft.com/en-us/azure/aks/azure-cni-powered-by-cilium
- https://azure.microsoft.com/en-us/updates/azure-cni-powered-by-cilium/

- https://cilium.io/industries/cloud-providers/
- https://docs.cilium.io/en/stable/#getting-started
- https://docs.cilium.io/en/stable/operations/troubleshooting/
- https://docs.cilium.io/en/v1.9/gettingstarted/k8s-install-aks/
- https://learn.microsoft.com/en-us/azure/aks/use-network-policies#network-policy-options-in-aks: Cilium enforces network policy on the traffic using Linux Berkeley Packet Filter (BPF), which is generally more efficient than "IPTables".
- https://cloud.google.com/kubernetes-engine/docs/concepts/dataplane-v2: GKE Dataplane V2 is implemented using Cilium. The legacy dataplane for GKE is implemented using Calico. Both of these technologies manage Kubernetes NetworkPolicy. Cilium uses eBPF and the Calico Container Network Interface (CNI) uses iptables in the Linux kernel.

## cni.cilium.azure.networkpolicy

```
```

- https://learn.microsoft.com/en-us/azure/aks/azure-cni-powered-by-cilium#network-policy-enforcement
- https://kubernetes.io/docs/tasks/administer-cluster/network-policy-provider/cilium-network-policy/
- https://docs.cilium.io/en/stable/security/policy/#network-policy

## cni.cilium.azure.networkpolicy.CiliumClusterwideNetworkPolicy

```
k get ccnp
```

- https://docs.cilium.io/en/stable/network/kubernetes/policy/#ciliumclusterwidenetworkpolicy

## cni.cilium.azure.networkpolicy.CiliumNetworkPolicy

```
k get cnp -A
```

- https://docs.cilium.io/en/stable/network/kubernetes/policy/#ciliumnetworkpolicy
