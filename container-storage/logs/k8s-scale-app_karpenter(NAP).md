## k8s-scale-app.karpenter.aks

When you run workloads on AKS, you have to pick the right VM size for your node pool. But that can be hard when your workloads needs different CPU, memory, and other things. You don't want to waste time or money on the wrong VMs. That's where node autoprovisioning (NAP) comes in. It looks at what your pods need and finds the best VMs to run them. It's smart and efficient. NAP uses Karpenter, which is Open Source, and so is the AKS provider. NAP sets up and manages Karpenter for you on your AKS clusters.

```
# Node Auto Provisioning (NAP) aka Karpenter
# https://learn.microsoft.com/en-us/azure/aks/node-autoprovision?tabs=azure-cli#enable-node-autoprovisioning
rg=rg
az group create -n $rg -l $loc
az aks create -g $rg -n aksnap --node-provisioning-mode Auto --network-plugin azure --network-plugin-mode overlay --network-dataplane cilium -s $vmsize
az aks get-credentials -g $rg -n aksnap --overwrite-existing

# The node pool resource includes a reference to the associated aksnodeclass
k api-resources | grep karp
aksnodeclasses                      aksnc,aksncs                        karpenter.azure.com/v1alpha2           false        AKSNodeClass
nodeclaims                                                              karpenter.sh/v1beta1                   false        NodeClaim
nodepools                                                               karpenter.sh/v1beta1                   false        NodePool

kubectl get events -A --field-selector source=karpenter -w

k get po -A # No karpenter pods
```

- https://learn.microsoft.com/en-us/azure/aks/node-autoprovision?tabs=azure-cli#sku-selectors-with-well-known-labels
- https://github.com/Azure/karpenter-provider-azure
- https://karpenter.sh/

```
# node pools
```

- https://github.com/Azure/karpenter-provider-azure?tab=readme-ov-file#create-nodepool
- https://github.com/Azure/karpenter-provider-azure/tree/main/examples
- https://learn.microsoft.com/en-us/azure/aks/node-autoprovision?tabs=azure-cli#sku-selectors-with-well-known-labels

```
# skus
# faster in CloudShell
az vm list-skus --resource-type virtualMachines -l $loc --output table
```

```
# test

kubectl create deploy nginx --image=nginx --replicas=10 --dry-run=client -o yaml | kubectl set resources --local -f - --requests=cpu=1 --dry-run=client -o yaml | kubectl apply -f -
kubectl scale deploy nginx --replicas=10
kubectl get no,po

## the node pool resource includes a "default" resource, which is why the nodes named as shown below.
NAME                                     STATUS   ROLES    AGE    VERSION
node/aks-default-2cqc5                   Ready    <none>   102s   v1.30.10
node/aks-default-jwbr6                   Ready    <none>   107s   v1.30.10
node/aks-default-nr8zv                   Ready    <none>   81s    v1.30.10
node/aks-nodepool1-34147650-vmss000000   Ready    <none>   18m    v1.30.10
node/aks-nodepool1-34147650-vmss000001   Ready    <none>   18m    v1.30.10
node/aks-nodepool1-34147650-vmss000002   Ready    <none>   18m    v1.30.10

## there is no node pool named "default"
az aks nodepool list -g $rg --cluster-name aksnap -otable
Name       OsType    VmSize         Count    MaxPods    ProvisioningState    Mode
---------  --------  -------------  -------  ---------  -------------------  ------
nodepool1  Linux     Standard_B2ms  3        250        Succeeded            System

## karpenter.sh/nodepool contains the node pool name, but kubernetes.azure.com/agentpool does not
k describe no aks-default-28dxd
Labels:             agentpool=
                    karpenter.azure.com/sku-cpu=8
                    karpenter.azure.com/sku-encryptionathost-capable=true
                    karpenter.azure.com/sku-family=D
                    karpenter.azure.com/sku-gpu-count=0
                    karpenter.azure.com/sku-memory=16384
                    karpenter.azure.com/sku-name=Standard_D8ls_v5
                    karpenter.azure.com/sku-networking-accelerated=true
                    karpenter.azure.com/sku-storage-premium-capable=true
                    karpenter.azure.com/sku-version=5
                    karpenter.sh/capacity-type=on-demand
                    karpenter.sh/nodepool=default
                    kubernetes.azure.com/agentpool=
                    kubernetes.azure.com/azure-cni-overlay=true
                    kubernetes.azure.com/cluster=MC_rg2_aksnap_swedencentral
                    kubernetes.azure.com/ebpf-dataplane=cilium
                    kubernetes.azure.com/mode=user
                    kubernetes.azure.com/network-subnet=aks-subnet
                    kubernetes.azure.com/nodenetwork-vnetguid=e9c03cff-7f9e-4e4a-a774-2dec2a94dde7
                    kubernetes.azure.com/podnetwork-type=overlay
                    kubernetes.azure.com/role=agent
                    kubernetes.io/arch=amd64
                    kubernetes.io/hostname=aks-default-28dxd
                    kubernetes.io/os=linux
                    node.kubernetes.io/instance-type=Standard_D8ls_v5
                    topology.disk.csi.azure.com/zone=swedencentral-2
                    topology.kubernetes.io/region=swedencentral
                    topology.kubernetes.io/zone=swedencentral-2

```

- https://github.com/Azure/karpenter-provider-azure?tab=readme-ov-file#scale-up-deployment

```
# test.nap tbd (no auto scale-up)

rg=rgkata
az group create -n $rg -l $loc
az aks create -g $rg -n aks -s $vmsize -c 2 --node-provisioning-mode Auto --network-plugin azure --network-plugin-mode overlay --network-dataplane cilium
az aks get-credentials -g $rg -n aks --overwrite-existing
kubectl get no; kubectl get po -A

az aks nodepool add -g $rg --cluster-name aks -n npkata --os-sku AzureLinux --workload-runtime KataMshvVmIsolation --node-vm-size Standard_D4s_v3 -c 1
kubectl get no; kubectl get po -A

cat << EOF | kubectl create -f -
kind: Pod
apiVersion: v1
metadata:
  name: untrusted
spec:
  runtimeClassName: kata-mshv-vm-isolation
  containers:
  - name: untrusted
    image: mcr.microsoft.com/aks/fundamental/base-ubuntu:v0.0.11
    command: ["/bin/sh", "-ec", "while :; do echo '.'; sleep 5 ; done"]
EOF
kubectl get po -owide -w

kubectl create deploy nginx --image=nginx --replicas=10 --dry-run=client -o yaml | kubectl set resources --local -f - --requests=cpu=1 --dry-run=client -o yaml | kubectl apply -f -
kubectl scale deploy nginx --replicas=10
kubectl get no,po
```

```
# unsupported

## https://github.com/Azure/karpenter-provider-azure/blob/main/pkg/providers/imagefamily/customscriptsbootstrap/provisionclientbootstrap.go
		// AgentPoolWindowsProfile: &models.AgentPoolWindowsProfile{},               // Unsupported as of now; TODO(Windows)
		// KubeletDiskType:         lo.ToPtr(models.KubeletDiskTypeUnspecified),    // Unsupported as of now
		// CustomLinuxOSConfig:     &models.CustomLinuxOSConfig{},                   // Unsupported as of now (sysctl)
		// EnableFIPS:              lo.ToPtr(false),                                 // Unsupported as of now
		// GpuInstanceProfile:      lo.ToPtr(models.GPUInstanceProfileUnspecified), // Unsupported as of now (MIG)
		// WorkloadRuntime:         lo.ToPtr(models.WorkloadRuntimeUnspecified),    // Unsupported as of now (Kata)
```

- https://github.com/Azure/karpenter-provider-azure/blob/main/pkg/providers/imagefamily/customscriptsbootstrap/provisionclientbootstrap.go

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
# The node pool resource includes a reference to the associated aksnodeclass

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
