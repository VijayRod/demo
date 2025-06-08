## aks
```
# See the section on aks op

rg=rg
az group create -n $rg -l $loc
az aks create -g $rg -n aks -s $vmsize -c 2
az aks get-credentials -g $rg -n aks --overwrite-existing
kubectl get no; kubectl get po -A

az aks nodepool add -g $rg --cluster-name aks -n npmar -s $vmsize # --os-sku Mariner
az aks nodepool delete -g $rg --cluster-name aks -n np2 --no-wait
```

```
az aks create -g $rg -n akseph -s $vmsize -c 1 --node-osdisk-type Ephemeral -s Standard_DS3_v2
az aks create -g $rg -n aksgen -s $vmsize -c 1 -s Standard_D4s_v5 # Also non-ephemeral
az aks create -g $rg -n akscni --network-plugin azure -s $vmsize -c 1
az aks create -g $rg -n akscilium --network-plugin azure --network-dataplane cilium -s $vmsize -c 1
az aks create -g $rg -n aksblob --enable-blob-driver -s $vmsize -c 1
az aks create -g $rg -n aksapproute --enable-app-routing -s $vmsize
cd /tmp/tcpdump
```

```
rg=rg
az group create -n $rg -l $loc
az network vnet create -g $rg --name vnet --address-prefixes 10.0.0.0/8 -o none 
az network vnet subnet create -g $rg --vnet-name vnet -n akssubnet --address-prefixes 10.240.0.0/16 -o none 
subnetId=$(az network vnet subnet show -g $rg --vnet-name vnet -n akssubnet --query id -otsv)
az aks create -g $rg -n aks --vnet-subnet-id $subnetId -s $vmsize -c 2 --network-plugin azure
az aks get-credentials -g $rg -n aks --overwrite-existing

subnet=subnet2
nodepool=nodepool2
az network vnet subnet create -g $rg --vnet-name vnet -n $subnet --address-prefixes 10.2.0.0/16 -o none 
subnetId=$(az network vnet subnet show -g $rg --vnet-name vnet -n $subnet --query id -otsv)
az aks nodepool add -g $rg --cluster-name aks -n $nodepool --vnet-subnet-id $subnetId -s $vmsize -c 2 # --max-pods 250 # --os-sku Mariner
# az aks nodepool delete -g $rg --cluster-name aks -n $nodepool --no-wait

for i in {2..100}; do az aks nodepool delete -g $rg --cluster-name aks -n nodepool$i --no-wait; done
```

- https://github.com/Azure/azure-rest-api-specs/blob/main/specification/containerservice/resource-manager/Microsoft.ContainerService/aks/stable/2023-02-01/managedClusters.json
- https://github.com/andyzhangx/demo/blob/master/debug/README.md
- https://github.com/feiskyer/kubernetes-handbook/blob/master/README.md
- https://learn.microsoft.com/en-us/azure/aks/
- https://learn.microsoft.com/en-us/rest/api/aks/managed-clusters/create-or-update?tabs=HTTP#examples
- https://learn.microsoft.com/en-us/training/paths/aks-cluster-architecture/
- https://cloudacademy.com/course/introduction-to-aks-954/course-introduction/
- https://learn.microsoft.com/en-us/azure/architecture/guide/multitenant/service/aks
- https://learn.microsoft.com/en-us/azure/aks/best-practices-app-cluster-reliability
- https://github.com/Azure/AKS/
- https://issuetracker.google.com/savedsearches/559746: Open Kubernetes Engine Issues
- https://github.com/Azure/aks-gbb-officehours/blob/main/README.md: updates up to 2022
- https://www.youtube.com/@theakscommunity
- https://azure.github.io/AKS/: AKS Engineering Blog
- https://github.com/Azure/AKS/?tab=readme-ov-file#important-links
- https://cloud.google.com/kubernetes-engine/docs/troubleshooting

```
# aks.mitigate

# mitigate.cluster
az aks update -g $rg -n aks # cluster reconcile
az aks update -g $rg -n aks --tags nametest=valuetest # cluster reconcile with forced put if new tag?
az aks stop -g $rg -n aks

# mitigate.nodepool/VMSS
az aks nodepool update -g $rg --cluster-name aks -n nodepool1 # node pool reconcile which will not update the VMScaleSet if no property changes
az aks nodepool update -g $rg --cluster-name aks -n nodepool1 --tags npname=npvalue # node pool reconcile with a new tag forces a VMScaleSet put
az aks nodepool upgrade --node-image-only -g --cluster-name -n # node pool reconcile with a new node image forces a VMScaleSet put
az aks nodepool stop -g $rg --cluster-name aks -n nodepool1
az aks nodepool update -g $rg --cluster-name aks -n nodepool1 -c 0 # only in a user node pool and only when cluster-autoscaler is not enabled for that node pool

# mitigate.VMSS (unsupported, for test purpose)
az vmss update -g $rg -n # reconcile
az vmss delete-instances -g $rg -n myVMSS --instance-ids "*" 
az vmss scale -g $rg -n myVMSS --new-capacity 0 # scale down
az vmss delete -g $rg -n myVMSS # then reconcile the cluster to automatically recreate the vmss
```

```
# aks.release
```
- release.aks
  - https://releases.aks.azure.com/
  - https://github.com/Azure/AKS/releases
- release.node-image.component
  - The component version can be found on the component release page, for example, in https://github.com/kubernetes-sigs/azuredisk-csi-driver/releases
  - https://github.com/Azure/AgentBaker/releases: contains the node image version corresponding to the "VHD Component Updates" PR (or see open PRs) which has the component version
    - Alternatively, https://github.com/Azure/AgentBaker/blob/master/vhdbuilder/release-notes/AKSAzureLinux/gen2/latest.txt though it cannot have the ones in open PR
  - https://releases.aks.azure.com/

## aks.core.logs

```
# aks.logs.node

noderg=$(az aks show -g $rg -n aks --query nodeResourceGroup -o tsv)   
az vmss run-command invoke -g $noderg -n aks --instance-id 0 --command-id RunShellScript --scripts 'zip -r /tmp/varlog-vmss000000.zip /var/log/*' --query value[0].message -o tsv

kubectl cp node-debugger-{node-name-xxxx}:/host/var/log/messages /tmp/messages
kubectl cp node-debugger-{node-name-xxxx}:/host/var/log/syslog /tmp/syslog
kubectl cp node-debugger-{node-name-xxxx}:/host/var/log/kern.log /tmp/kern.log
```

```
# aks.logs.node.core
kubectl get --raw "/api/v1/nodes/nodename/proxy/logs/messages"|grep kubelet
node=aks-nodepool1-31079220-vmss000006; kubectl get --raw "/api/v1/nodes/$node/proxy/logs/messages"
node=aks-nodepool1-31079220-vmss000006; kubectl get --raw "/api/v1/nodes/$node/proxy/logs/syslog" | tail
```
- https://learn.microsoft.com/en-us/azure/aks/kubelet-logs#using-kubectl-raw

```
# aks.logs.node.core.iptables

# an alternative is to ssh to the node with a vm in the same vnet, or with bastion, or with node-shell, as these options grant root privileges that are not available through kubectl debug too
iptables -vnL
iptables-legacy -vNL
iptables-nft -vNL

kubectl node-shell aks-nodepool1-31079220-vmss000000
root@aks-nodepool1-31079220-vmss000000:/# iptables -vnL
# Warning: iptables-legacy tables present, use iptables-legacy to see them
Chain INPUT (policy ACCEPT 0 packets, 0 bytes)
root@aks-nodepool1-31079220-vmss000000:/# iptables-save # Generated by iptables-save v1.8.7 on Mon Jun  2 18:27:26 2025 # success
root@aks-nodepool1-31079220-vmss000000:/# sudo iptables-save # Generated by iptables-save v1.8.7 on Mon Jun  2 18:27:26 2025 # success
kubectl describe po nsenter-v8t7om
    Command:
      nsenter
      --target
      1
      --mount
      --uts
      --ipc
      --net
      --pid
      bash
      -l
      
az aks command invoke -g $rg -n aks --command "iptables-save" # /bin/sh: 1: iptables-save: not found

kubectl debug node/aks-nodepool1-31079220-vmss000006 -it --image=nicolaka/netshoot -- bash
aks-nodepool1-31079220-vmss000006:~# whoami
root
aks-nodepool1-31079220-vmss000006:~# iptables-save
iptables-save v1.8.10 (nf_tables): Could not fetch rule set generation id: Permission denied (you must be root)
aks-nodepool1-31079220-vmss000006:~# chroot /host
root@aks-nodepool1-31079220-vmss000006:/# iptables-save
iptables-save v1.8.7 (nf_tables): Could not fetch rule set generation id: Permission denied (you must be root)
root@aks-nodepool1-31079220-vmss000006:/# sudo iptables-save
iptables-save v1.8.7 (nf_tables): Could not fetch rule set generation id: Permission denied (you must be root)
kubectl describe po node-debugger-aks-nodepool1-31079220-vmss000006-x476x
  host-root:
    Type:          HostPath (bare host directory volume)
    Path:          /
    HostPathType:

kubectl delete po debug-iptables
kubectl apply -f -<<EOF
apiVersion: v1
kind: Pod
metadata:
  name: debug-iptables
spec:
  nodeSelector:
    kubernetes.io/hostname: aks-nodepool1-31079220-vmss000001
  hostNetwork: true
  hostPID: true
  containers:
  - name: debug
    image: ubuntu:20.04
    securityContext:
      privileged: true
    command:
    - sleep
    - "3600"
EOF
kubectl get po -w
kubectl exec -it debug-iptables -- bash
# apt update && apt install -y iptables && iptables-save
# (tbd - no non-default rules in the output) Generated by iptables-save v1.8.4 on Mon Jun  2 18:51:55 2025

k netshoot debug node/aks-nodepool1-31079220-vmss000001
 aks-nodepool1-31079220-vmss000001 ? ~ ? iptables-save
iptables-save v1.8.10 (nf_tables): Could not fetch rule set generation id: Permission denied (you must be root)

k netshoot debug node/aks-nodepool1-31079220-vmss000001 --host-network
 aks-nodepool1-31079220-vmss000001 ? ~ ? iptables-save
iptables-save v1.8.10 (nf_tables): Could not fetch rule set generation id: Permission denied (you must be root)
```

```
# vm in the same vnet (recommended, works like a normal bash file, however requires copying the credentials)
noderg=$(az aks show -g $rg -n aks --query nodeResourceGroup -o tsv); echo $noderg
vnet=$(az resource list -g $noderg --resource-type "Microsoft.Network/virtualNetworks" --query "[0].name" -otsv); echo $vnet
subnetId=$(az network vnet subnet show -g $noderg --vnet-name $vnet --n aks-subnet --query id -o tsv); echo $subnetId
az vm create -g $rg -n vm --image Ubuntu2204 --subnet $subnetId --admin-username azureuser --public-ip-sku Standard
publicIp=$(az vm list-ip-addresses -g $rg -n vm --query "[0].virtualMachine.network.publicIpAddresses[0].ipAddress" -o tsv); echo $publicIp
az ssh vm --ip $publicIp --private-key-file ~/.ssh/id_rsa
## copy the node ssh credentials to the vm
mkdir -p ~/.ssh; chmod 600 ~/.ssh
cat << EOF > ~/.ssh/id_rsa
-----BEGIN RSA PRIVATE KEY-----
content==
-----END RSA PRIVATE KEY-----
EOF
kubectl get no -owide
ssh azureuser@10.224.0.4

# not required
nsg=$(az resource list -g $noderg --resource-type "Microsoft.Network/networkSecurityGroups" --query "[0].name" -otsv); echo $nsg
az network nsg rule create -g $noderg --nsg-name $nsg -n AllowSSHToVm \
  --priority 1000 --access Allow --direction Inbound --protocol Tcp \
  --source-address-prefixes '*' --source-port-ranges '*' \
  --destination-address-prefixes $publicIp --destination-port-ranges 22 \
  --description "Allow SSH to $destinationIp from any source"

```

- https://learn.microsoft.com/en-us/azure/aks/node-access#ssh-using-private-ips-from-the-aks-api

```
# bastion connect from portal (works, but the ui command prompt makes it difficult to copy large amounts of data)
noderg=$(az aks show -g $rg -n aks --query nodeResourceGroup -o tsv); echo $noderg
vnet=$(az resource list -g $noderg --resource-type "Microsoft.Network/virtualNetworks" --query "[0].name" -otsv); echo $vnet
vnetId=$(az network vnet show -g $noderg -n $vnet --query id -o tsv); echo $vnetId
az network public-ip create -g $rg -n bastion-ip --sku Standard --allocation-method Static
bastionIpId=$(az network public-ip show -g $rg -n bastion-ip --query id -otsv); echo $bastionIpId
az network vnet show -g $noderg -n $vnet --query addressSpace.addressPrefixes[0]
az network vnet subnet create -g $noderg --vnet-name $vnet -n AzureBastionSubnet --address-prefixes 10.225.0.0/27 # ensure the range is available in the vnet
az network bastion create -g $rg -n myBastion --vnet-name $vnetId --public-ip-address $bastionIpId --enable-tunneling true
bastionIp=$(az network public-ip show -g $rg -n bastion-ip --query ipAddress -otsv); echo $bastionIp
# portal: browse to the scale set VM, Connect, Bastion
# use Ctrl+C to copy, although it is not easy to copy large amounts of text
# azureuser@aks-nodepool1-31079220-vmss000004:~$ iptables-save # iptables-save v1.8.7 (nf_tables): Could not fetch rule set generation id: Permission denied (you must be root)
azureuser@aks-nodepool1-31079220-vmss000004:~$ sudo iptables-save # Generated by iptables-save v1.8.7 on Wed Jun  4 09:32:22 2025 ## success
sudo iptables-save > /tmp/iptables.out
```

- https://learn.microsoft.com/en-us/azure/aks/node-access#ssh-using-azure-bastion-for-windows

```
# bastion cli (recommended), i.e., az network bastion ssh
# can effortlessly copy larger amounts of text as in a standard bash prompt
az network bastion update -g $rg -n myBastion --enable-tunneling true
noderg=$(az aks show -g $rg -n aks --query nodeResourceGroup -o tsv); echo $noderg
vmss=$(az resource list -g $noderg --resource-type "Microsoft.Compute/virtualMachineScaleSets" --query "[0].name" -otsv); echo $vmss
vmId=$(az vmss list-instances -g $noderg -n $vmss --query [0].id -otsv); echo $vmId
az extension add -n ssh
az network bastion ssh -g $rg -n myBastion --target-resource-id $vmId --auth-type "ssh-key" --username azureuser --ssh-key ~/.ssh/id_rsa
# azureuser@aks-nodepool1-31079220-vmss000004:~$ iptables-save > /tmp/iptables-dump # iptables-save v1.8.7 (nf_tables): Could not fetch rule set generation id: Permission denied (you must be root)
azureuser@aks-nodepool1-31079220-vmss000004:~$ sudo iptables-save > /tmp/iptables-dump; cat /tmp/iptables-dump; ls /tmp/ip*
# can effortlessly copy larger amounts of text as in a standard bash prompt

kubectl debug node/aks-nodepool1-31079220-vmss000004 -it --image=mcr.microsoft.com/cbl-mariner/busybox:2.0
/ # ls /tmp/ip*
ls: /tmp/ip*: No such file or directory

https://learn.microsoft.com/en-us/azure/bastion/connect-vm-native-client-windows#ssh-to-a-linux-vm-ip-address
```

```
# bastion cli (the copy did not work from /tmp)
az network bastion tunnel -g $rg -n myBastion --target-resource-id $vmId --resource-port 22 --port 8080
## terminal 2
scp -P 8080 /tmp/iptables azureuser@127.0.0.1:/tmp/iptables-dump # scp: stat local "/tmp/iptables-dump": No such file or directory
```

- https://learn.microsoft.com/en-us/azure/bastion/vm-upload-download-native#tunnel-command

## aks.core.reconcile

```
# See the section on aks op reconcile auto
```

## aks.core.remediator

- https://learn.microsoft.com/en-us/azure/aks/node-auto-repair: AKS initiates repair operations with the user account aks-remediator.

## aks.spec.agentPool.vmSize

- https://learn.microsoft.com/en-us/azure/aks/quotas-skus-regions#supported-vm-sizes
- https://learn.microsoft.com/en-us/azure/aks/gpu-cluster?#supported-gpu-enabled-vms
- https://aka.ms/aks/restricted-skus

## aks.spec.sku.Automatic

```
# create
az aks create -g $rg -n aksauto --sku automatic
az aks get-credentials -g $rg -n aksauto --overwrite-existing

# misc
az aks show -g $rg -n aks --query kind # "Automatic"
az aks show -g $rg -n aks --query sku.name # "Automatic"

# create.custom-vnet
tbd BadRequest
rg=rgvnet
az group create -n $rg -l $loc
az network vnet create -g $rg --name vnet --address-prefixes 10.0.0.0/8 -o none 
az network vnet subnet create -g $rg --vnet-name vnet -n akssubnet --address-prefixes 10.240.0.0/16 -o none 
subnetId=$(az network vnet subnet show -g $rg --vnet-name vnet -n akssubnet --query id -otsv)
# az aks create -g $rg -n aksauto --vnet-subnet-id $subnetId --sku automatic # (OnlySupportedOnUserAssignedMSICluster) System-assigned managed identity not supported for custom resource VirtualNetworks. Please use user-assigned managed identity.
userIdentityName="userIdentity$RANDOM"
az identity create -g $rg -n $userIdentityName
userIdentityUri=$(az identity show -g $rg --name $userIdentityName --query id -otsv); echo $userIdentityUri
# az aks create -g $rg -n aksauto --vnet-subnet-id $subnetId --sku automatic --enable-managed-identity --assign-identity $userIdentityUri # (InvalidParameter) Outbound type is managedNATGateway but agent pool 'nodepool1' is using custom VNet, which is not allowed.
userIdentityUri=$(az identity show -g $rg --name $userIdentityName --query id -otsv); echo $userIdentityUri
az network public-ip create -g $rg -n natIp --sku standard
az network nat gateway create -g $rg -n natGateway --public-ip-addresses natIp
az network vnet subnet update --ids $subnetId --nat-gateway natGateway
# az network vnet subnet create -g $rg --vnet-name vnet -n akssubnet --address-prefixes 10.240.0.0/16 --nat-gateway natGateway
az aks create -g $rg -n aksauto --vnet-subnet-id $subnetId --sku automatic --enable-managed-identity --assign-identity $userIdentityUri --outbound-type userAssignedNATGateway
# (BadRequest) Managed cluster 'Automatic' SKU should enable 'OutboundType' feature with recommended values; Managed cluster 'Automatic' should only allow cluster with managed identity to be created.
az aks get-credentials -g $rg -n aks --overwrite-existing
```

- https://azure.microsoft.com/en-us/updates/public-preview-aks-automatic/
- https://learn.microsoft.com/en-us/azure/aks/intro-aks-automatic
- https://learn.microsoft.com/en-us/azure/aks/learn/quick-kubernetes-automatic-deploy
- https://azure.github.io/AKS/2024/05/22/aks-automatic

## aks.scale
- https://learn.microsoft.com/en-us/azure/aks/best-practices-performance-scale-large
