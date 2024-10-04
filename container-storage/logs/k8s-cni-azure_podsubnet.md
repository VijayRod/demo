## k8s-cni.azure.podsubnet

```
az feature register --namespace Microsoft.ContainerService --name AzureVnetScalePreview
az feature show --namespace Microsoft.ContainerService --name AzureVnetScalePreview
```

- https://learn.microsoft.com/en-us/azure/aks/concepts-network-azure-cni-pod-subnet
- https://learn.microsoft.com/en-us/azure/aks/configure-azure-cni-static-block-allocation#plan-ip-addressing

## k8s-cni.azure.podsubnet.staticblock

```
rg=rg
az group create -n $rg -l $loc
az network vnet create -g $rg --name vnet --address-prefixes 10.0.0.0/8 -o none 
az network vnet subnet create -g $rg --vnet-name vnet -n nodesubnet --address-prefixes 10.240.0.0/16 -o none
az network vnet subnet create -g $rg --vnet-name vnet -n podsubnet --address-prefixes 10.40.0.0/13 -o none
nodesubnetId=$(az network vnet subnet show -g $rg --vnet-name vnet -n nodesubnet --query id -otsv)
podsubnetId=$(az network vnet subnet show -g $rg --vnet-name vnet -n podsubnet --query id -otsv)
az aks create -g $rg -n akspodsubnet --network-plugin azure --pod-ip-allocation-mode StaticBlock --vnet-subnet-id $nodesubnetId --pod-subnet-id $podsubnetId --enable-addons monitoring -s $vmsize -c 2
az aks get-credentials -g $rg -n akspodsubnet --overwrite-existing
```

```
az aks show -g $rg -n akspodsubnet
  "agentPoolProfiles": [
      "name": "nodepool1",
      "podIpAllocationMode": "StaticBlock",
      "podSubnetId": "/subscriptions/redacts-1111-1111-1111-111111111111/resourceGroups/rg/providers/Microsoft.Network/virtualNetworks/vnet/subnets/podsubnet",
      "vnetSubnetId": "/subscriptions/redacts-1111-1111-1111-111111111111/resourceGroups/rg/providers/Microsoft.Network/virtualNetworks/vnet/subnets/nodesubnet",
      
kubectl get nnc -n kube-system
NAMESPACE     NAME                                ALLOCATED IPS   NC MODE   NC VERSION
kube-system   aks-nodepool1-36149301-vmss000000   255             static    0
kube-system   aks-nodepool1-36149301-vmss000001   255             static    0

kubectl get nnc -n kube-system -owide
NAME                                REQUESTED IPS   ALLOCATED IPS   SUBNET      SUBNET CIDR    NC ID                  NC MODE   NC TYPE     NC VERSION
aks-nodepool1-36149301-vmss000000   250             255             podsubnet   10.40.0.0/13   68eb969e-c8a9-4f82-a0c6-9b3ec8f9b276   static    vnetblock   0
aks-nodepool1-36149301-vmss000001   250             255             podsubnet   10.40.0.0/13   bf0a349b-c6e5-4fa8-bbbd-c84ee001b851   static    vnetblock   0

kubectl describe nnc -n kube-system aks-nodepool1-36149301-vmss000000
Name:         aks-nodepool1-36149301-vmss000000
Namespace:    kube-system
Labels:       kubernetes.azure.com/podnetwork-delegationguid=3371eec1-b861-4dca-838d-c6bfe7032461
              kubernetes.azure.com/podnetwork-subnet=podsubnet
              kubernetes.azure.com/podnetwork-type=vnetblock
...
Spec:
  Requested IP Count:  250
Status:
  Assigned IP Count:  255
  Network Containers:
    Assignment Mode:  static
...
    Resource Group ID:     rg
    Subcription ID:        redacts-1111-1111-1111-111111111111
    Subnet Address Space:  10.40.0.0/13
    Subnet ID:             podsubnet
    Subnet Name:           podsubnet
    Type:                  vnetblock
    Version:               0
    Vnet ID:               vnet
```    

```
# az aks nodepool delete -g $rg --cluster-name akspodsubnet -n nodepool2    
az network vnet subnet create -g $rg --vnet-name vnet -n nodesubnet2 --address-prefixes 10.242.0.0/16 -o none 
az network vnet subnet create -g $rg --vnet-name vnet -n podsubnet2 --address-prefixes 10.243.0.0/26 -o none
nodesubnetId2=$(az network vnet subnet show -g $rg --vnet-name vnet -n nodesubnet2 --query id -otsv)
podsubnetId2=$(az network vnet subnet show -g $rg --vnet-name vnet -n podsubnet2 --query id -otsv)
az aks nodepool add -g $rg --cluster-name akspodsubnet -n nodepool2 --vnet-subnet-id $nodesubnetId2 --pod-subnet-id $podsubnetId2 --pod-ip-allocation-mode StaticBlock -s $vmsize -c 2 #--no-wait --max-pods 250
````

- https://azure.microsoft.com/en-us/updates/public-preview-azure-cni-static-block-ip-allocation-support-in-aks/
- https://learn.microsoft.com/en-us/azure/aks/configure-azure-cni-static-block-allocation
- https://learn.microsoft.com/en-us/azure/aks/concepts-network-azure-cni-pod-subnet#static-block-allocation-mode-preview

### k8s-cni.azure.podsubnet.staticblock.16IPs

```
# To determine how many 16 IP blocks are allocated to a node, you should look at the number of pods that are currently running on that node.

kubectl delete deploy nginx
cat << EOF | kubectl create -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: nginx
  name: nginx
spec:
  replicas: 1
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - image: nginx
        name: nginx
      nodeSelector:
        kubernetes.io/hostname: aks-nodepool1-90720178-vmss000000
EOF

kubectl scale deploy nginx --replicas 30
kubectl get deploy -w

kubectl get po -A -owide | grep aks-nodepool1-90720178-vmss000000 | grep Running | wc -l
# kubectl describe nnc -n kube-system aks-nodepool1-90720178-vmss000000
```

- https://learn.microsoft.com/en-us/azure/aks/configure-azure-cni-static-block-allocation#plan-ip-addressing: "CIDR blocks of /28 (16 IPs) are allocated to nodes based on..."

### k8s-cni.azure.podsubnet.staticblock.16IPs.error.InsufficientSubnetSize - no NCs found in NNC CRD

```
# InsufficientSubnetSize - no NCs found in NNC CRD
# 10.6.0.0/26 subnet with an IP range from 10.6.0.0 to 10.6.0.63 which give us 64 - 5 reserved addresses = 59 usable IPs.
# "Pre-allocated IPs 160" for the 10 new nodes, which works out to 16 IPs per node. https://learn.microsoft.com/en-us/azure/aks/configure-azure-cni-static-block-allocation#plan-ip-addressing: "CIDR blocks of /28 (16 IPs) are allocated to nodes based on..."

rg=rg
az group create -n $rg -l $loc
az network vnet create -g $rg --name vnet --address-prefixes 10.0.0.0/8 -o none 
az network vnet subnet create -g $rg --vnet-name vnet -n nodesubnet --address-prefixes 10.240.0.0/16 -o none
az network vnet subnet create -g $rg --vnet-name vnet -n podsubnet --address-prefixes 10.40.0.0/13 -o none
nodesubnetId=$(az network vnet subnet show -g $rg --vnet-name vnet -n nodesubnet --query id -otsv)
podsubnetId=$(az network vnet subnet show -g $rg --vnet-name vnet -n podsubnet --query id -otsv)
az aks create -g $rg -n akspodsubnet --network-plugin azure --pod-ip-allocation-mode StaticBlock --vnet-subnet-id $nodesubnetId --pod-subnet-id $podsubnetId --enable-addons monitoring -s $vmsize -c 2
az aks get-credentials -g $rg -n akspodsubnet --overwrite-existing

# az aks nodepool delete -g $rg --cluster-name akspodsubnet -n nodepool5
az network vnet subnet create -g $rg --vnet-name vnet -n nodesubnet5 --address-prefixes 10.5.0.0/16 -o none 
az network vnet subnet create -g $rg --vnet-name vnet -n podsubnet5 --address-prefixes 10.6.0.0/26 -o none
nodesubnetId5=$(az network vnet subnet show -g $rg --vnet-name vnet -n nodesubnet5 --query id -otsv)
podsubnetId5=$(az network vnet subnet show -g $rg --vnet-name vnet -n podsubnet5 --query id -otsv)
az aks nodepool add -g $rg --cluster-name akspodsubnet -n nodepool5 --vnet-subnet-id $nodesubnetId5 --pod-subnet-id $podsubnetId5 --pod-ip-allocation-mode StaticBlock -s $vmsize -c 3
az aks nodepool scale -g $rg --cluster-name akspodsubnet  -n nodepool5 -c 10 # InsufficientSubnetSize - no NCs found in NNC CRD

(InsufficientSubnetSize) Pre-allocated IPs 160 exceeds IPs available 59 in Subnet Cidr 10.6.0.0/26, Subnet Name pod5subnet. http://aka.ms/aks/insufficientsubnetsize
Code: InsufficientSubnetSize
Message: Pre-allocated IPs 160 exceeds IPs available 59 in Subnet Cidr 10.6.0.0/26, Subnet Name pod5subnet. http://aka.ms/aks/insufficientsubnetsize
Target: agentPoolProfile.podSubnetID

kubectl get no
NAME                                  STATUS     ROLES    AGE   VERSION
aks-newnodepool-29606608-vmss000000   Ready      <none>   46m   v1.29.8
aks-newnodepool-29606608-vmss000001   Ready      <none>   45m   v1.29.8
aks-nodepool5-25787112-vmss000000     NotReady   <none>   37m   v1.29.8
aks-nodepool5-25787112-vmss000001     NotReady   <none>   37m   v1.29.8
aks-nodepool5-25787112-vmss000002     NotReady   <none>   37m   v1.29.8

kubectl describe no aks-nodepool5-25787112-vmss000000
Conditions:
  Type                          Status  LastHeartbeatTime                 LastTransitionTime                Reason                          Message
  ----                          ------  -----------------                 ------------------                ------                          -------
  Ready                         False   Thu, 03 Oct 2024 22:22:21 +0000   Thu, 03 Oct 2024 22:01:55 +0000   KubeletNotReady                 container runtime network not ready: NetworkReady=false reason:NetworkPluginNotReady message:Network plugin returns error: cni plugin not initialized

kubectl get nnc -n kube-system
NAME                                  ALLOCATED IPS   NC MODE   NC VERSION
aks-nodepool1-36149301-vmss000000     255             static    0
aks-nodepool1-36149301-vmss000001     255             static    0
aks-nodepool5-25787112-vmss000000
aks-nodepool5-25787112-vmss000001
aks-nodepool5-25787112-vmss000002

kubectl describe nnc -n kube-system aks-nodepool5-25787112-vmss000000
Spec:
  Requested IP Count:  250
Events:
  Type     Reason          Age                 From                   Message
  ----     ------          ----                ----                   -------
  Normal   CreatingNC      38m                 dnc-rc/nnc-reconciler  Creating new NC 709d9812-5c41-41ee-9b56-31e27eb35bf4 for node 66ff06410495660001f2629e_aks-nodepool5-25787112-vmss000000 of type AzVnetBlock
  Warning  NCUpdateFailed  15m (x19 over 38m)  dnc-rc/nnc-reconciler  Failed to upsert NC 709d9812-5c41-41ee-9b56-31e27eb35bf4, err = JsonError:[Code:Unknown Status, Text:[dnctl] failed to Get NetworkContainer status with status 400: {"State":"Reserve","Status":"Failed","NICStatus":"N/A","FailureDetail":{"ErrorCode":8,"Text":"Failed to allocate address for request {SubnetName:pod5subnet SubnetType:AzVnetBlock IPConstraint: NodeConstraint: RequestType: Scope: SecondaryIPCount:250 PrimaryIPPrefixBits:0 IPFamilies:[]}. Subnet is full","HttpStatusCode":400}}
, HTTPStatus:400]
  Warning  ReconcileError  15m (x19 over 38m)  dnc-rc/nnc-reconciler  publishCreateOrUpdateNC error: error(s) while making NCs for NNC: could not create nc(s): 1 errors: [JsonError:[Code:Unknown Status, Text:[dnctl] failed to Get NetworkContainer status with status 400: {"State":"Reserve","Status":"Failed","NICStatus":"N/A","FailureDetail":{"ErrorCode":8,"Text":"Failed to allocate address for request {SubnetName:pod5subnet SubnetType:AzVnetBlock IPConstraint: NodeConstraint: RequestType: Scope: SecondaryIPCount:250 PrimaryIPPrefixBits:0 IPFamilies:[]}. Subnet is full","HttpStatusCode":400}}
, HTTPStatus:400]
error upserting NC
go.goms.io/acn/dnc/requestcontroller/kubernetes.(*NodeNetworkConfigReconciler).createNCinDNC
  /usr/local/src/dnc/requestcontroller/kubernetes/nodenetworkconfigreconciler.go:1178
go.goms.io/acn/dnc/requestcontroller/kubernetes.(*NodeNetworkConfigReconciler).makeNCsInDNC.func1
  /usr/local/src/dnc/requestcontroller/kubernetes/nodenetworkconfigreconciler.go:1074
runtime.goexit
  /usr/local/go/src/runtime/asm_amd64.s:1650
error processing NC request for subnet {DelegatedSubnetID:3371eec1-b861-4dca-838d-c6bfe7032461 SubnetName:pod5subnet SubnetID: PrimaryToken:806a6008-f38f-4880-a78b-cbc8d5778327 SecondaryToken:4521b9ff-f77c-47d3-a0d2-15dc8e4840c4 VnetID:3371eec1-b861-4dca-838d-c6bfe7032461 RoutingDomainID: PodCIDR: AllocationBlockPrefixSize:28 AllocationBlockPrefixSizeV6:0 BackendNetworkID:}
go.goms.io/acn/dnc/requestcontroller/kubernetes.(*NodeNetworkConfigReconciler).makeNCsInDNC.func1
  /usr/local/src/dnc/requestcontroller/kubernetes/nodenetworkconfigreconciler.go:1076
runtime.goexit
  /usr/local/go/src/runtime/asm_amd64.s:1650]
  
kubectl get po -n kube-system -owide | grep cns | grep nodepool5
kube-system   azure-cns-59v7p                       0/1     Completed           2 (7m34s ago)   42m   10.5.0.5         aks-nodepool5-25787112-vmss000001     <none>           <none>
kube-system   azure-cns-g5l6d                       1/1     Running             2 (5m5s ago)    42m   10.5.0.6         aks-nodepool5-25787112-vmss000002     <none>           <none>
kube-system   azure-cns-tbd4m                       1/1     Running             3 (2m12s ago)   42m   10.5.0.4         aks-nodepool5-25787112-vmss000000     <none>           <none>

kubectl logs -n kube-system azure-cns-59v7p
2024/10/03 22:19:18 [1] Reconciling initial CNS state
2024/10/03 22:19:18 [1] reconciling initial CNS state attempt: 1
2024/10/03 22:19:18 [1] Retrieved NNC: &{TypeMeta:{Kind: APIVersion:} ObjectMeta:{Name:aks-nodepool5-25787112-vmss000001 GenerateName: Namespace:kube-system SelfLink: UID:40d5cf40-3b9c-42c1-898c-a55a7884f86c ResourceVersion:9074 Generation:1 CreationTimestamp:2024-10-03 21:36:06 +0000 UTC DeletionTimestamp:<nil> DeletionGracePeriodSeconds:<nil> Labels:map[kubernetes.azure.com/podnetwork-delegationguid:3371eec1-b861-4dca-838d-c6bfe7032461 kubernetes.azure.com/podnetwork-subnet:pod5subnet kubernetes.azure.com/podnetwork-type:vnetblock managed:true owner:aks-nodepool5-25787112-vmss000001] Annotations:map[] OwnerReferences:[{APIVersion:v1 Kind:Node Name:aks-nodepool5-25787112-vmss000001 UID:83285fa6-def3-4a27-be4e-1167c5529360 Controller:0xc0006e803f BlockOwnerDeletion:0xc0006e803e}] Finalizers:[finalizers.acn.azure.com/dnc-operations] ManagedFields:[{Manager:dnc-rc Operation:Update APIVersion:acn.azure.com/v1alpha Time:2024-10-03 21:36:06 +0000 UTC FieldsType:FieldsV1 FieldsV1:{"f:metadata":{"f:finalizers":{".":{},"v:\"finalizers.acn.azure.com/dnc-operations\"":{}},"f:labels":{".":{},"f:kubernetes.azure.com/podnetwork-delegationguid":{},"f:kubernetes.azure.com/podnetwork-subnet":{},"f:kubernetes.azure.com/podnetwork-type":{},"f:managed":{},"f:owner":{}},"f:ownerReferences":{".":{},"k:{\"uid\":\"83285fa6-def3-4a27-be4e-1167c5529360\"}":{}}},"f:spec":{".":{},"f:requestedIPCount":{}}} Subresource:}]} Spec:{RequestedIPCount:250 IPsNotInUse:[]} Status:{AssignedIPCount:0 Scaler:{BatchSize:0 ReleaseThresholdPercent:0 RequestThresholdPercent:0 MaxIPCount:0} Status: NetworkContainers:[]}}
2024/10/03 22:19:18 [1] failed to reconcile initial CNS state, attempt: 1 err: failed to init CNS state: no NCs found in NNC CRD
```
