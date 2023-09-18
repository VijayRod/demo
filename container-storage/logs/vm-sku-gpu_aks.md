```
# To create a cluster
clustername=aksgpu
rgname=testshack
location=eastus
az group create -n $rgname -l $location
az aks create -g $rgname -n $clustername

# To add a node pool
az aks nodepool add -g $rgname --cluster-name $clustername -n gpunp --node-vm-size Standard_NC6s_v3 --node-taints sku=gpu:NoSchedule --aks-custom-headers UseGPUDedicatedVHD=true -c 1 --mode user

# To deploy a pod
cat << EOF | kubectl create -f -
apiVersion: v1
kind: Pod
metadata:
  creationTimestamp: null
  labels:
    run: nginx
  name: nginx14
spec:
  containers:
  - image: nginx
    name: nginx
    resources: {}
  dnsPolicy: ClusterFirst
  restartPolicy: Always
  tolerations:
  - key: "sku"
    operator: "Equal"
    value: "gpu"
    effect: "NoSchedule"
  nodeSelector:
    "kubernetes.azure.com/agentpool": gpunp
EOF
```

```
# az aks nodepool show -g $rgname --cluster-name $clustername -n gpunp --query gpuInstanceProfile
(null)

# az aks nodepool show -g $rgname --cluster-name $clustername -n gpunp --query nodeTaints
[
  "sku=gpu:NoSchedule"
]

# az aks nodepool show -g $rgname --cluster-name $clustername -n gpunp --query nodeImageVersion
"AKSUbuntu-1804gen2gpucontainerd-202307.27.0"

# az aks nodepool show -g $rgname --cluster-name $clustername -n gpunp --query vmSize
"Standard_NC6s_v3"

# kubectl describe node aks-gpunp-10282168-vmss000000
Name:               aks-gpunp-10282168-vmss000000
Roles:              agent
Labels:             accelerator=nvidia
                    agentpool=gpunp
                    beta.kubernetes.io/arch=amd64
                    beta.kubernetes.io/instance-type=Standard_NC6s_v3
                    beta.kubernetes.io/os=linux
                    failure-domain.beta.kubernetes.io/region=eastus
                    failure-domain.beta.kubernetes.io/zone=0
                    kubernetes.azure.com/accelerator=nvidia
                    kubernetes.azure.com/agentpool=gpunp
                    kubernetes.azure.com/cluster=MC_testshack_aksgpu_eastus
                    kubernetes.azure.com/consolidated-additional-properties=02eb9584-3773-11ee-af08-321fa34b746b
                    kubernetes.azure.com/kubelet-identity-client-id=dummyk-0638-4e6d-a36b-2f78538a95f0
                    kubernetes.azure.com/mode=user
                    kubernetes.azure.com/node-image-version=AKSUbuntu-1804gen2gpucontainerd-202307.27.0
                    kubernetes.azure.com/nodepool-type=VirtualMachineScaleSets
                    kubernetes.azure.com/os-sku=Ubuntu
                    kubernetes.azure.com/role=agent
                    kubernetes.io/arch=amd64
                    kubernetes.io/hostname=aks-gpunp-10282168-vmss000000
                    kubernetes.io/os=linux
                    kubernetes.io/role=agent
                    node-role.kubernetes.io/agent=
                    node.kubernetes.io/instance-type=Standard_NC6s_v3
                    topology.disk.csi.azure.com/zone=
                    topology.kubernetes.io/region=eastus
                    topology.kubernetes.io/zone=0
Annotations:        csi.volume.kubernetes.io/nodeid: {"disk.csi.azure.com":"aks-gpunp-10282168-vmss000000","file.csi.azure.com":"aks-gpunp-10282168-vmss000000"}
                    node.alpha.kubernetes.io/ttl: 0
                    volumes.kubernetes.io/controller-managed-attach-detach: true
CreationTimestamp:  Thu, 10 Aug 2023 11:45:24 +0000
Taints:             sku=gpu:NoSchedule
Unschedulable:      false
Lease:
  HolderIdentity:  aks-gpunp-10282168-vmss000000
  AcquireTime:     <unset>
  RenewTime:       Thu, 10 Aug 2023 11:47:37 +0000
Conditions:
  Type                 Status  LastHeartbeatTime                 LastTransitionTime                Reason
            Message
  ----                 ------  -----------------                 ------------------                ------
            -------
  NetworkUnavailable   False   Thu, 10 Aug 2023 11:46:33 +0000   Thu, 10 Aug 2023 11:46:33 +0000   RouteCreated                 RouteController created a route
  MemoryPressure       False   Thu, 10 Aug 2023 11:45:27 +0000   Thu, 10 Aug 2023 11:45:24 +0000   KubeletHasSufficientMemory   kubelet has sufficient memory available
  DiskPressure         False   Thu, 10 Aug 2023 11:45:27 +0000   Thu, 10 Aug 2023 11:45:24 +0000   KubeletHasNoDiskPressure     kubelet has no disk pressure
  PIDPressure          False   Thu, 10 Aug 2023 11:45:27 +0000   Thu, 10 Aug 2023 11:45:24 +0000   KubeletHasSufficientPID      kubelet has sufficient PID available
  Ready                True    Thu, 10 Aug 2023 11:45:27 +0000   Thu, 10 Aug 2023 11:45:27 +0000   KubeletReady                 kubelet is posting ready status. AppArmor enabled
Addresses:
  InternalIP:  10.224.0.7
  Hostname:    aks-gpunp-10282168-vmss000000
Capacity:
  cpu:                6
  ephemeral-storage:  129886128Ki
  hugepages-1Gi:      0
  hugepages-2Mi:      0
  memory:             115397144Ki
  nvidia.com/gpu:     1
  pods:               110
Allocatable:
  cpu:                5840m
  ephemeral-storage:  119703055367
  hugepages-1Gi:      0
  hugepages-2Mi:      0
  memory:             105863704Ki
  nvidia.com/gpu:     1
  pods:               110
System Info:
  Machine ID:                 c63ae820bf2b4b379414308772c4523b
  System UUID:                e3d2e4cf-93b9-43b5-a8cc-04c20d7505de
  Boot ID:                    ef9c0bf4-4f11-4b21-8184-90823390f8c1
  Kernel Version:             5.4.0-1112-azure
  OS Image:                   Ubuntu 18.04.6 LTS
  Operating System:           linux
  Architecture:               amd64
  Container Runtime Version:  containerd://1.7.1+azure-1
  Kubelet Version:            v1.26.6
  Kube-Proxy Version:         v1.26.6
PodCIDR:                      10.244.3.0/24
PodCIDRs:                     10.244.3.0/24
ProviderID:                   azure:///subscriptions/dummys-1111-1111-1111-111111111111/resourceGroups/mc_testshack_aksgpu_eastus/providers/Microsoft.Compute/virtualMachineScaleSets/aks-gpunp-10282168-vmss/virtualMachines/0
Non-terminated Pods:          (5 in total)
  Namespace                   Name                         CPU Requests  CPU Limits  Memory Requests  Memory Limits  Age
  ---------                   ----                         ------------  ----------  ---------------  -------------  ---
  kube-system                 azure-ip-masq-agent-cldc8    100m (1%)     500m (8%)   50Mi (0%)        250Mi (0%)     2m20s
  kube-system                 cloud-node-manager-vj4s4     50m (0%)      0 (0%)      50Mi (0%)        512Mi (0%)     2m20s
  kube-system                 csi-azuredisk-node-sqfkh     30m (0%)      0 (0%)      60Mi (0%)        400Mi (0%)     2m20s
  kube-system                 csi-azurefile-node-rc7tk     30m (0%)      0 (0%)      60Mi (0%)        600Mi (0%)     2m20s
  kube-system                 kube-proxy-lnkd9             100m (1%)     0 (0%)      0 (0%)           0 (0%)         2m20s
Allocated resources:
  (Total limits may be over 100 percent, i.e., overcommitted.)
  Resource           Requests    Limits
  --------           --------    ------
  cpu                310m (5%)   500m (8%)
  memory             220Mi (0%)  1762Mi (1%)
  ephemeral-storage  0 (0%)      0 (0%)
  hugepages-1Gi      0 (0%)      0 (0%)
  hugepages-2Mi      0 (0%)      0 (0%)
  nvidia.com/gpu     0           0
```

```
# To cleanup
az aks get-credentials -g $rgname -n $clustername
az group delete -n $rgname -y --no-wait
```

- https://learn.microsoft.com/en-us/azure/aks/gpu-cluster
- https://learn.microsoft.com/en-us/azure/aks/gpu-multi-instance
- https://github.com/Azure/aks-gpu
