## k8s-scale-app.karpenter.aks

When you run workloads on AKS, you have to pick the right VM size for your node pool. But that can be hard when your workloads needs different CPU, memory, and other things. You don't want to waste time or money on the wrong VMs. That's where node autoprovisioning (NAP) comes in. It looks at what your pods need and finds the best VMs to run them. It's smart and efficient. NAP uses Karpenter, which is Open Source, and so is the AKS provider. NAP sets up and manages Karpenter for you on your AKS clusters.

```
# Node Auto Provisioning (NAP) aka Karpenter
# https://learn.microsoft.com/en-us/azure/aks/node-autoprovision?tabs=azure-cli#enable-node-autoprovisioning
rg=rg
az group create -n $rg -l $loc
az aks create -g $rg -n aksnap --node-provisioning-mode Auto --network-plugin azure --network-plugin-mode overlay --network-dataplane cilium -s $vmsize
az aks get-credentials -g $rg -n aksnap --overwrite-existing

k api-resources | grep karp
aksnodeclasses                      aksnc,aksncs                        karpenter.azure.com/v1alpha2           false        AKSNodeClass
nodeclaims                                                              karpenter.sh/v1beta1                   false        NodeClaim
nodepools                                                               karpenter.sh/v1beta1                   false        NodePool

kubectl get events -A --field-selector source=karpenter -w

k get po -A # No karpenter pods
```

- https://learn.microsoft.com/en-us/azure/aks/node-autoprovision?tabs=azure-cli#sku-selectors-with-well-known-labels

### k8s-scale-app.karpenter.aks.apiresources.aksnodeclass

```
k get aksnodeclass
NAME           AGE
default        39m
system-surge   39m

k describe aksnodeclass
Name:         default
Namespace:
Labels:       app.kubernetes.io/managed-by=Helm
              helm.toolkit.fluxcd.io/name=karpenter-overlay-main-adapter-helmrelease
              helm.toolkit.fluxcd.io/namespace=670e6c74322dbb0001e9668b
Annotations:  kubernetes.io/description: General purpose AKSNodeClass for running Ubuntu2204 nodes
              meta.helm.sh/release-name: aks-managed-karpenter-overlay
              meta.helm.sh/release-namespace: kube-system
API Version:  karpenter.azure.com/v1alpha2
Kind:         AKSNodeClass
Metadata:
  Creation Timestamp:  2024-10-15T18:25:29Z
  Generation:          1
  Resource Version:    1665
  UID:                 b5743f76-0b08-4b26-af7a-11008208bb44
Spec:
  Image Family:     Ubuntu2204
  Os Disk Size GB:  128
Events:             <none>

Name:         system-surge
Namespace:
Labels:       app.kubernetes.io/managed-by=Helm
              helm.toolkit.fluxcd.io/name=karpenter-overlay-main-adapter-helmrelease
              helm.toolkit.fluxcd.io/namespace=670e6c74322dbb0001e9668b
Annotations:  kubernetes.io/description: Surge AKSNodeClass for running Ubuntu2204 nodes additional systempool capacity
              meta.helm.sh/release-name: aks-managed-karpenter-overlay
              meta.helm.sh/release-namespace: kube-system
API Version:  karpenter.azure.com/v1alpha2
Kind:         AKSNodeClass
Metadata:
  Creation Timestamp:  2024-10-15T18:25:29Z
  Generation:          1
  Resource Version:    1664
  UID:                 c52bf310-30dc-4936-82e7-9ae972abc621
Spec:
  Image Family:     Ubuntu2204
  Os Disk Size GB:  128
Events:             <none>
```

### k8s-scale-app.karpenter.aks.apiresources.aksnodeclass.image

```
Kind:         AKSNodeClass
Spec:
  Image Family:     Ubuntu2204
  Os Disk Size GB:  128
```

- https://learn.microsoft.com/en-us/azure/aks/node-autoprovision?tabs=azure-cli#kubernetes-and-node-image-updates: Kubernetes upgrades for NAP node pools follows the Control Plane Kubernetes version.

### k8s-scale-app.karpenter.aks.apiresources.nodeclaim

```
k get nodeclaim
No resources found
```

- https://karpenter.sh/docs/concepts/nodeclaims/

### k8s-scale-app.karpenter.aks.apiresources.nodepool

```
k get nodepools
NAME           NODECLASS
default        default
system-surge   system-surge

k describe nodepool
Name:         default
Namespace:
Labels:       app.kubernetes.io/managed-by=Helm
              helm.toolkit.fluxcd.io/name=karpenter-overlay-main-adapter-helmrelease
              helm.toolkit.fluxcd.io/namespace=670e6c74322dbb0001e9668b
Annotations:  karpenter.sh/nodepool-hash: 12393960163388511505
              karpenter.sh/nodepool-hash-version: v2
              kubernetes.io/description: General purpose NodePool for generic workloads
              meta.helm.sh/release-name: aks-managed-karpenter-overlay
              meta.helm.sh/release-namespace: kube-system
API Version:  karpenter.sh/v1beta1
Kind:         NodePool
Metadata:
  Creation Timestamp:  2024-10-15T18:25:29Z
  Generation:          1
  Resource Version:    1668
  UID:                 e1d00389-539f-4949-bbc2-e38ab317b0f4
Spec:
  Disruption:
    Budgets:
      Nodes:               100%
    Consolidation Policy:  WhenUnderutilized
    Expire After:          Never
  Template:
    Spec:
      Node Class Ref:
        Name:  default
      Requirements:
        Key:       kubernetes.io/arch
        Operator:  In
        Values:
          amd64
        Key:       kubernetes.io/os
        Operator:  In
        Values:
          linux
        Key:       karpenter.sh/capacity-type
        Operator:  In
        Values:
          on-demand
        Key:       karpenter.azure.com/sku-family
        Operator:  In
        Values:
          D
Events:  <none>

Name:         system-surge
Namespace:
Labels:       app.kubernetes.io/managed-by=Helm
              helm.toolkit.fluxcd.io/name=karpenter-overlay-main-adapter-helmrelease
              helm.toolkit.fluxcd.io/namespace=670e6c74322dbb0001e9668b
Annotations:  karpenter.sh/nodepool-hash: 11366257416229128040
              karpenter.sh/nodepool-hash-version: v2
              kubernetes.io/description: Surge capacity pool for system pod pressure
              meta.helm.sh/release-name: aks-managed-karpenter-overlay
              meta.helm.sh/release-namespace: kube-system
API Version:  karpenter.sh/v1beta1
Kind:         NodePool
Metadata:
  Creation Timestamp:  2024-10-15T18:25:29Z
  Generation:          1
  Resource Version:    1670
  UID:                 ce0a5c0b-20d6-4772-9636-2c6bc5717fb7
Spec:
  Disruption:
    Budgets:
      Nodes:               10%
    Consolidation Policy:  WhenUnderutilized
    Expire After:          Never
  Template:
    Metadata:
      Labels:
        kubernetes.azure.com/mode:  system
    Spec:
      Node Class Ref:
        Name:  system-surge
      Requirements:
        Key:       kubernetes.io/arch
        Operator:  In
        Values:
          amd64
        Key:       kubernetes.io/os
        Operator:  In
        Values:
          linux
        Key:       karpenter.sh/capacity-type
        Operator:  In
        Values:
          on-demand
        Key:       karpenter.azure.com/sku-family
        Operator:  In
        Values:
          D
      Taints:
        Effect:  NoSchedule
        Key:     CriticalAddonsOnly
        Value:   true
Events:          <none>
```

- https://learn.microsoft.com/en-us/azure/aks/node-autoprovision?tabs=azure-cli#node-pools
- https://karpenter.sh/docs/concepts/nodepools/

### k8s-scale-app.karpenter.aks.apiresources.nodepool.disruption

```
Kind:         NodePool
Spec:
  Disruption:
    Budgets:
      Nodes:               10%
    Consolidation Policy:  WhenUnderutilized
    Expire After:          Never
```

- https://learn.microsoft.com/en-us/azure/aks/node-autoprovision?tabs=azure-cli#node-disruption
- https://karpenter.sh/docs/concepts/nodepools/#specdisruption
- https://karpenter.sh/docs/concepts/disruption/

### k8s-scale-app.karpenter.aks.apiresources.nodepool.limit

- https://learn.microsoft.com/en-us/azure/aks/node-autoprovision?tabs=azure-cli#node-pool-limits

### k8s-scale-app.karpenter.aks.apiresources.nodepool.weight

- https://learn.microsoft.com/en-us/azure/aks/node-autoprovision?tabs=azure-cli#node-pool-weights

## k8s-scale-app.karpenter.opensource

```
# https://github.com/Azure/karpenter-provider-azure?tab=readme-ov-file#installation-self-hosted
# tbd https://raw.githubusercontent.com/Azure/karpenter-provider-azure/refs/heads/main/hack/deploy/create-cluster.sh karpenter karpenter kube-system

export LOCATION=swedencentral # This is for the vmsize
...
az aks create without using the --generate-ssh-keys option, but specify the VM size with -s $vmsize
...
tbd

tbd karpenter logs for the worker node names
```

- https://karpenter.sh/docs/getting-started/: See the AKS Node autoprovisioning article on how to use Karpenter on Azure’s AKS or go to the Karpenter provider for Azure open source repository for self-hosting on Azure and additional information.
- https://github.com/Azure/karpenter-provider-azure
- https://karpenter.sh/docs/concepts/nodepools/
- https://github.com/aws/karpenter-provider-aws/blob/main/pkg/apis/crds/karpenter.sh_nodepools.yaml
- https://github.com/aws/karpenter-provider-aws/blob/main/test/suites/scale/deprovisioning_test.go, WhenUnderutilized
