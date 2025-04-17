## k8s-node-topology_zone.azure

```
az account list-locations -ojson | jq -r '.[].name' | while read; do printf "Subscription: $REPLY has eastus2-az3 as logical zone "; az account set --subscription "${REPLY}"; az account list-locations --include-extended-locations -ojson | jq -r 'map(select(.name=="eastus2"))[0].availabilityZoneMappings | map(select(.physicalZone=="eastus2-az3"))[].logicalZone'; done

az account list-locations --include-extended-locations -ojson | jq 'map(select(.name=="eastus2"))'
[
  {
    "availabilityZoneMappings": [
      {
        "logicalZone": "1",
        "physicalZone": "eastus2-az2"
      },
      {
        "logicalZone": "2",
        "physicalZone": "eastus2-az3"
      },
      {
        "logicalZone": "3",
        "physicalZone": "eastus2-az1"
      }
    ],
    "displayName": "East US 2",
    "id": "/subscriptions/redacts-1111-1111-1111-111111111111/locations/eastus2",
    "metadata": {
      "geography": "United States",
      "geographyGroup": "US",
      "latitude": "36.6681",
      "longitude": "-78.3889",
      "pairedRegion": [
        {
          "id": "/subscriptions/redacts-1111-1111-1111-111111111111/locations/centralus",
          "name": "centralus"
        }
      ],
      "physicalLocation": "Virginia",
      "regionCategory": "Other",
      "regionType": "Physical"
    },
    "name": "eastus2",
    "regionalDisplayName": "(US) East US 2",
    "type": "Region"
  }
]
```

- https://learn.microsoft.com/en-us/azure/reliability/availability-zones-overview
  - https://learn.microsoft.com/en-us/azure/reliability/availability-zones-service-support#azure-regions-with-availability-zone-support

## k8s-node-topology_zone.azure.aks

```
rg=rg
az group create -n $rg -l $loc
az aks create -g $rg -n akszone --zones 1 2 -s $vmsize -c 2
az aks get-credentials -g $rg -n aks --overwrite-existing
kubectl get no; kubectl get po -A

az aks show -g $r -n akszone --query agentPoolProfiles[0].availabilityZones
[
  "1",
  "2"
]

# node pool create without specifying --zone
# k describe no | grep -E 'name|zone'
k describe no | grep zone
                    failure-domain.beta.kubernetes.io/zone=0
                    topology.disk.csi.azure.com/zone=
                    topology.kubernetes.io/zone=0

# kubectl describe nodes | grep -e "Name:" -e "topology.kubernetes.io/zone"
# kubectl describe no -l kubernetes.azure.com/agentpool=np2 | grep zone # topology.disk.csi.azure.com/zone=swedencentral-1
Name:               aks-nodepool1-29870350-vmss000000
                    topology.kubernetes.io/zone=swedencentral-1
Name:               aks-nodepool1-29870350-vmss000001
                    topology.kubernetes.io/zone=swedencentral-2
Name:               aks-nodepool1-29870350-vmss000002
                    topology.kubernetes.io/zone=swedencentral-1
```

```
kubectl describe no -l kubernetes.azure.com/agentpool=np2 | grep zone # topology.disk.csi.azure.com/zone=swedencentral-1
noderg=$(az aks show -g $rg -n akszone --query nodeResourceGroup -o tsv)
diskUri=$(az disk create -g $noderg -n myAKSDisk --size-gb 1 --zone 2 --query id --output tsv); echo $diskUri # --zone different from VM
az disk show -g $noderg -n myAKSDisk --query zones # [  "2"]

az vmss show -g $noderg -n aks-np2-39852331-vmss --query zones # [  "1"]

az vmss list-instances -g $noderg -n aks-np2-39852331-vmss
[
    "name": "aks-np2-39852331-vmss_0",
    "zones": [
      "1"
```                    

```
k describe no -l kubernetes.azure.com/agentpool=np2 | grep zone
topology.kubernetes.io/zone=swedencentral-1

kubectl delete po nginx
cat << EOF | kubectl create -f -
apiVersion: v1
kind: Pod
metadata:
  labels:
    run: nginx
  name: nginx
spec:
  containers:
  - image: nginx
    name: nginx
  nodeSelector:
    kubernetes.azure.com/agentpool: np2
    topology.kubernetes.io/zone: swedencentral-2 # different zone
EOF
kubectl get po
kubectl describe po

NAME    READY   STATUS    RESTARTS   AGE
nginx   0/1     Pending   0          0s

Events:
  Type     Reason            Age   From               Message
  ----     ------            ----  ----               -------
  Warning  FailedScheduling  23s   default-scheduler  0/2 nodes are available: 2 node(s) didn't match Pod's node affinity/selector. preemption: 0/2 nodes are available: 2 Preemption is not helpful for scheduling.
```
                    
- https://learn.microsoft.com/en-us/azure/aks/availability-zones
- https://learn.microsoft.com/en-us/azure/aks/free-standard-pricing-tiers#uptime-sla-terms-and-conditions
- https://kubernetes.io/docs/setup/best-practices/multiple-zones/

## k8s-node-topology_zone.azure.aks.controlplane

- https://learn.microsoft.com/en-us/azure/aks/availability-zones: The availability zones that the managed control plane components are deployed into are not controlled by this parameter (az aks create --zones). They are automatically spread across all availability zones (if present) in the region during cluster deployment.
- https://github.com/Azure/AKS/issues/3493: [Feature] Convert all clusters with non-AZ enabled control planes to be AZ enabled

## k8s-node-topology_zone.azure.vm

- https://learn.microsoft.com/en-us/azure/virtual-machines/availability

## k8s-node-topology_zone.azure.vm.vmss

```
az vmss list-instances -g MC_rg_akszone_swedencentral -n aks-nodepool1-14795161-vmss --query "[].{Instance:instanceId, Zone:zones[0]}" -o table
```

- https://learn.microsoft.com/en-us/azure/virtual-machine-scale-sets/virtual-machine-scale-sets-use-availability-zones
- https://learn.microsoft.com/en-us/azure/virtual-machine-scale-sets/virtual-machine-scale-sets-use-availability-zones?tabs=portal-2

