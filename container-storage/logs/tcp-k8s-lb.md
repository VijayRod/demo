```
az aks show -g $rg -n aks --query networkProfile.loadBalancerProfile

az network lb show -g MC_rg_aks_swedencentral -n kubernetes
```

```
# networkProfile.loadBalancerProfile
rg=rg
az group create -n $rg -l $loc
az aks create -g $rg -n aks -s $vmsize -c 1
az aks get-credentials -g $rg -n aks --overwrite-existing

az aks show -g $rg -n aks --query networkProfile.loadBalancerProfile
az network lb show -g MC_rg_aks_swedencentral -n kubernetes

{
  "allocatedOutboundPorts": null,
  "backendPoolType": "nodeIPConfiguration",
  "clusterServiceLoadBalancerHealthProbeMode": null,
  "effectiveOutboundIPs": [
    {
      "id": "/subscriptions/redacts-1111-1111-1111-111111111111/resourceGroups/MC_rg_aks_swedencentral/providers/Microsoft.Network/publicIPAddresses/10dc9bf5-518a-4289-a67b-35bdb415d096",
      "resourceGroup": "MC_rg_aks_swedencentral"
    }
  ],
  "enableMultipleStandardLoadBalancers": null,
  "idleTimeoutInMinutes": null,
  "managedOutboundIPs": {
    "count": 1,
    "countIpv6": null
  },
  "outboundIPs": null,
  "outboundIpPrefixes": null
}

{
  "backendAddressPools": [
    {
      "backendIPConfigurations": [
        {
          "id": "/subscriptions/redacts-1111-1111-1111-111111111111/resourceGroups/MC_rg_aks_swedencentral/providers/Microsoft.Compute/virtualMachineScaleSets/aks-nodepool1-32897461-vmss/virtualMachines/0/networkInterfaces/aks-nodepool1-32897461-vmss/ipConfigurations/ipconfig1",
          "resourceGroup": "MC_rg_aks_swedencentral"
        }
      ],
      "etag": "W/\"e5975eb0-22de-414d-ae10-44146f114bde\"",
      "id": "/subscriptions/redacts-1111-1111-1111-111111111111/resourceGroups/MC_rg_aks_swedencentral/providers/Microsoft.Network/loadBalancers/kubernetes/backendAddressPools/aksOutboundBackendPool",
      "loadBalancerBackendAddresses": [
        {
          "name": "7a6806c0-2f39-4548-b71f-25ac71f6b4da",
          "networkInterfaceIPConfiguration": {
            "id": "/subscriptions/redacts-1111-1111-1111-111111111111/resourceGroups/MC_rg_aks_swedencentral/providers/Microsoft.Compute/virtualMachineScaleSets/aks-nodepool1-32897461-vmss/virtualMachines/0/networkInterfaces/aks-nodepool1-32897461-vmss/ipConfigurations/ipconfig1",
            "resourceGroup": "MC_rg_aks_swedencentral"
          }
        }
      ],
      "name": "aksOutboundBackendPool",
      "outboundRules": [
        {
          "id": "/subscriptions/redacts-1111-1111-1111-111111111111/resourceGroups/MC_rg_aks_swedencentral/providers/Microsoft.Network/loadBalancers/kubernetes/outboundRules/aksOutboundRule",
          "resourceGroup": "MC_rg_aks_swedencentral"
        }
      ],
      "provisioningState": "Succeeded",
      "resourceGroup": "MC_rg_aks_swedencentral",
      "type": "Microsoft.Network/loadBalancers/backendAddressPools"
    },
    {
      "backendIPConfigurations": [
        {
          "id": "/subscriptions/redacts-1111-1111-1111-111111111111/resourceGroups/MC_rg_aks_swedencentral/providers/Microsoft.Compute/virtualMachineScaleSets/aks-nodepool1-32897461-vmss/virtualMachines/0/networkInterfaces/aks-nodepool1-32897461-vmss/ipConfigurations/ipconfig1",
          "resourceGroup": "MC_rg_aks_swedencentral"
        }
      ],
      "etag": "W/\"e5975eb0-22de-414d-ae10-44146f114bde\"",
      "id": "/subscriptions/redacts-1111-1111-1111-111111111111/resourceGroups/MC_rg_aks_swedencentral/providers/Microsoft.Network/loadBalancers/kubernetes/backendAddressPools/kubernetes",
      "loadBalancerBackendAddresses": [
        {
          "name": "1f1b4f85-a9e6-45da-8641-96f2e558fea1",
          "networkInterfaceIPConfiguration": {
            "id": "/subscriptions/redacts-1111-1111-1111-111111111111/resourceGroups/MC_rg_aks_swedencentral/providers/Microsoft.Compute/virtualMachineScaleSets/aks-nodepool1-32897461-vmss/virtualMachines/0/networkInterfaces/aks-nodepool1-32897461-vmss/ipConfigurations/ipconfig1",
            "resourceGroup": "MC_rg_aks_swedencentral"
          }
        }
      ],
      "name": "kubernetes",
      "provisioningState": "Succeeded",
      "resourceGroup": "MC_rg_aks_swedencentral",
      "type": "Microsoft.Network/loadBalancers/backendAddressPools"
    }
  ],
  "etag": "W/\"e5975eb0-22de-414d-ae10-44146f114bde\"",
  "frontendIPConfigurations": [
    {
      "etag": "W/\"e5975eb0-22de-414d-ae10-44146f114bde\"",
      "id": "/subscriptions/redacts-1111-1111-1111-111111111111/resourceGroups/MC_rg_aks_swedencentral/providers/Microsoft.Network/loadBalancers/kubernetes/frontendIPConfigurations/10dc9bf5-518a-4289-a67b-35bdb415d096",
      "name": "10dc9bf5-518a-4289-a67b-35bdb415d096",
      "outboundRules": [
        {
          "id": "/subscriptions/redacts-1111-1111-1111-111111111111/resourceGroups/MC_rg_aks_swedencentral/providers/Microsoft.Network/loadBalancers/kubernetes/outboundRules/aksOutboundRule",
          "resourceGroup": "MC_rg_aks_swedencentral"
        }
      ],
      "privateIPAllocationMethod": "Dynamic",
      "provisioningState": "Succeeded",
      "publicIPAddress": {
        "id": "/subscriptions/redacts-1111-1111-1111-111111111111/resourceGroups/MC_rg_aks_swedencentral/providers/Microsoft.Network/publicIPAddresses/10dc9bf5-518a-4289-a67b-35bdb415d096",
        "resourceGroup": "MC_rg_aks_swedencentral"
      },
      "resourceGroup": "MC_rg_aks_swedencentral",
      "type": "Microsoft.Network/loadBalancers/frontendIPConfigurations"
    }
  ],
  "id": "/subscriptions/redacts-1111-1111-1111-111111111111/resourceGroups/MC_rg_aks_swedencentral/providers/Microsoft.Network/loadBalancers/kubernetes",
  "inboundNatPools": [],
  "inboundNatRules": [],
  "loadBalancingRules": [],
  "location": "swedencentral",
  "name": "kubernetes",
  "outboundRules": [
    {
      "allocatedOutboundPorts": 0,
      "backendAddressPool": {
        "id": "/subscriptions/redacts-1111-1111-1111-111111111111/resourceGroups/MC_rg_aks_swedencentral/providers/Microsoft.Network/loadBalancers/kubernetes/backendAddressPools/aksOutboundBackendPool",
        "resourceGroup": "MC_rg_aks_swedencentral"
      },
      "enableTcpReset": true,
      "etag": "W/\"e5975eb0-22de-414d-ae10-44146f114bde\"",
      "frontendIPConfigurations": [
        {
          "id": "/subscriptions/redacts-1111-1111-1111-111111111111/resourceGroups/MC_rg_aks_swedencentral/providers/Microsoft.Network/loadBalancers/kubernetes/frontendIPConfigurations/10dc9bf5-518a-4289-a67b-35bdb415d096",
          "resourceGroup": "MC_rg_aks_swedencentral"
        }
      ],
      "id": "/subscriptions/redacts-1111-1111-1111-111111111111/resourceGroups/MC_rg_aks_swedencentral/providers/Microsoft.Network/loadBalancers/kubernetes/outboundRules/aksOutboundRule",
      "idleTimeoutInMinutes": 30,
      "name": "aksOutboundRule",
      "protocol": "All",
      "provisioningState": "Succeeded",
      "resourceGroup": "MC_rg_aks_swedencentral",
      "type": "Microsoft.Network/loadBalancers/outboundRules"
    }
  ],
  "probes": [],
  "provisioningState": "Succeeded",
  "resourceGroup": "MC_rg_aks_swedencentral",
  "resourceGuid": "bba1e5a2-89f2-4f48-882c-93dd8159dd66",
  "sku": {
    "name": "Standard",
    "tier": "Regional"
  },
  "tags": {
    "aks-managed-cluster-name": "aks",
    "aks-managed-cluster-rg": "rg"
  },
  "type": "Microsoft.Network/loadBalancers"
}
```

```
# network-plugin
rg=rg
az group create -n $rg -l $loc
az aks create -g $rg -n aks -s $vmsize -c 1
az aks get-credentials -g $rg -n aks --overwrite-existing
az aks create -g $rg -n akscni --network-plugin azure -s $vmsize -c 1
az aks get-credentials -g $rg -n akscni --overwrite-existing

az aks show -g $rg -n aks --query networkProfile.loadBalancerProfile
az aks show -g $rg -n akscni --query networkProfile.loadBalancerProfile # same

az network lb show -g MC_rg_aks_swedencentral -n kubernetes
az network lb show -g MC_rg_akscni_swedencentral -n kubernetes # same
```

```
# load-balancer-backend-pool-type=nodeIP (tbd lb service provisioning with a higher node count)

rg=rg
az group create -n $rg -l $loc
az aks create -g $rg -n aksnodeip --load-balancer-backend-pool-type=nodeIP -s $vmsize -c 1
az aks get-credentials -g $rg -n aksnodeip --overwrite-existing
az aks create -g $rg -n aksnodeipconfig --load-balancer-backend-pool-type=nodeIPConfiguration -s $vmsize -c 1
az aks get-credentials -g $rg -n aksnodeipconfig --overwrite-existing


az aks show -g $rg -n aksnodeip --query networkProfile.loadBalancerProfile.backendPoolType -otsv # nodeIP
az aks show -g $rg -n aksnodeipconfig --query networkProfile.loadBalancerProfile.backendPoolType -otsv # nodeIPConfiguration

az network lb address-pool show -g MC_rg_aksnodeip_swedencentral --lb-name kubernetes -n aksOutboundBackendPool
az network lb address-pool show -g MC_rg_aksnodeipconfig_swedencentral --lb-name kubernetes -n aksOutboundBackendPool # same
 
 
date
az aks scale -g $rg -n aksnodeip -c 10
date # 03:13 minutes
az aks scale -g $rg -n aksnodeipconfig -c 10
date # 03:13 minutes (same)
az aks scale -g $rg -n aksnodeip -c 1
az aks scale -g $rg -n aksnodeipconfig -c 1


kubectl delete po nginx
kubectl delete svc nginx
kubectl run nginx --image=nginx --port=80
sleep 5
kubectl get po nginx
date
kubectl expose po nginx --type=LoadBalancer
date # 1 second

az aks scale -g $rg -n aksnodeip -c 10
az aks scale -g $rg -n aksnodeipconfig -c 10

az aks get-credentials -g $rg -n aksnodeip --overwrite-existing
# az aks get-credentials -g $rg -n aksnodeipconfig --overwrite-existing
kubectl delete svc --all=true
kubectl delete po --all=true
kubectl run nginx --image=nginx --port=80
kubectl run nginx2 --image=nginx --port=80
kubectl run nginx3 --image=nginx --port=80
sleep 10
kubectl get po
kubectl expose po nginx --type=LoadBalancer
kubectl expose po nginx2 --type=LoadBalancer
kubectl expose po nginx3 --type=LoadBalancer
kubectl get svc -w

aksnodeip 27s
nginx        LoadBalancer   10.0.147.49   <pending>     80:32393/TCP   1s
nginx2       LoadBalancer   10.0.225.5    <pending>     80:31479/TCP   1s
nginx3       LoadBalancer   10.0.195.24   <pending>     80:31364/TCP   0s
nginx        LoadBalancer   10.0.147.49   74.241.233.125   80:32393/TCP   11s
nginx2       LoadBalancer   10.0.225.5    74.241.233.127   80:31479/TCP   19s
nginx3       LoadBalancer   10.0.195.24   74.241.233.165   80:31364/TCP   27s

aksnodeipconfig 25s (~same)
NAME         TYPE           CLUSTER-IP     EXTERNAL-IP   PORT(S)        AGE
nginx        LoadBalancer   10.0.154.116   <pending>     80:31246/TCP   2s
nginx2       LoadBalancer   10.0.103.178   <pending>     80:32714/TCP   1s
nginx3       LoadBalancer   10.0.57.147    <pending>     80:31452/TCP   1s
nginx        LoadBalancer   10.0.154.116   74.241.216.83   80:31246/TCP   9s
nginx2       LoadBalancer   10.0.103.178   74.241.161.23   80:32714/TCP   17s
nginx3       LoadBalancer   10.0.57.147    74.241.167.112   80:31452/TCP   25s
```

```
# load-balancer-backend-pool-type=nodeIPConfiguration (legacy)

rg=rg
az group create -n $rg -l $loc
az aks create -g $rg -n aksnodeipconfig --load-balancer-backend-pool-type=nodeIPConfiguration -s $vmsize -c 1
az aks get-credentials -g $rg -n aksnodeipconfig --overwrite-existing

az aks show -g $rg -n aksnodeipconfig --query networkProfile.loadBalancerProfile.backendPoolType -otsv # nodeIPConfiguration
# az network lb address-pool show -g MC_rg_aksnodeip_swedencentral --lb-name kubernetes -n aksOutboundBackendPool
```

- https://learn.microsoft.com/en-us/azure/aks/load-balancer-standard#change-the-inbound-pool-type

```
# svc.LoadBalancer - network lb show
az aks get-credentials -g $rg -n aks --overwrite-existing
# az aks get-credentials -g $rg -n akscni --overwrite-existing
kubectl delete po nginx
kubectl delete svc nginx
kubectl run nginx --image=nginx --port=80
sleep 5
kubectl get po nginx
kubectl expose po nginx --type=LoadBalancer
kubectl get svc nginx -w

az network lb show -g MC_rg_aks_swedencentral -n kubernetes
az network lb show -g MC_rg_akscni_swedencentral -n kubernetes # same

  "frontendIPConfigurations": [
    {...
    },
    {
      "etag": "W/\"7503422d-f1ad-4bac-b600-46a357ba0967\"",
      "id": "/subscriptions/redacts-1111-1111-1111-111111111111/resourceGroups/mc_rg_aks_swedencentral/providers/Microsoft.Network/loadBalancers/kubernetes/frontendIPConfigurations/adfc5e64f5d904777853de3a1b27773b",
      "loadBalancingRules": [
        {
          "id": "/subscriptions/redacts-1111-1111-1111-111111111111/resourceGroups/mc_rg_aks_swedencentral/providers/Microsoft.Network/loadBalancers/kubernetes/loadBalancingRules/adfc5e64f5d904777853de3a1b27773b-TCP-80",
          "resourceGroup": "mc_rg_aks_swedencentral"
        }
      ],
      "name": "adfc5e64f5d904777853de3a1b27773b",
      "privateIPAllocationMethod": "Dynamic",
      "provisioningState": "Succeeded",
      "publicIPAddress": {
        "id": "/subscriptions/redacts-1111-1111-1111-111111111111/resourceGroups/mc_rg_aks_swedencentral/providers/Microsoft.Network/publicIPAddresses/kubernetes-adfc5e64f5d904777853de3a1b27773b",
        "resourceGroup": "mc_rg_aks_swedencentral"
      },
      "resourceGroup": "mc_rg_aks_swedencentral",
      "type": "Microsoft.Network/loadBalancers/frontendIPConfigurations"
    }
  ],
  "loadBalancingRules": [
    {
      "backendAddressPool": {
        "id": "/subscriptions/redacts-1111-1111-1111-111111111111/resourceGroups/mc_rg_aks_swedencentral/providers/Microsoft.Network/loadBalancers/kubernetes/backendAddressPools/kubernetes",
        "resourceGroup": "mc_rg_aks_swedencentral"
      },
      "backendAddressPools": [
        {
          "id": "/subscriptions/redacts-1111-1111-1111-111111111111/resourceGroups/mc_rg_aks_swedencentral/providers/Microsoft.Network/loadBalancers/kubernetes/backendAddressPools/kubernetes",
          "resourceGroup": "mc_rg_aks_swedencentral"
        }
      ],
      "backendPort": 80,
      "disableOutboundSnat": true,
      "enableFloatingIP": true,
      "enableTcpReset": true,
      "etag": "W/\"7503422d-f1ad-4bac-b600-46a357ba0967\"",
      "frontendIPConfiguration": {
        "id": "/subscriptions/redacts-1111-1111-1111-111111111111/resourceGroups/mc_rg_aks_swedencentral/providers/Microsoft.Network/loadBalancers/kubernetes/frontendIPConfigurations/adfc5e64f5d904777853de3a1b27773b",
        "resourceGroup": "mc_rg_aks_swedencentral"
      },
      "frontendPort": 80,
      "id": "/subscriptions/redacts-1111-1111-1111-111111111111/resourceGroups/mc_rg_aks_swedencentral/providers/Microsoft.Network/loadBalancers/kubernetes/loadBalancingRules/adfc5e64f5d904777853de3a1b27773b-TCP-80",
      "idleTimeoutInMinutes": 4,
      "loadDistribution": "Default",
      "name": "adfc5e64f5d904777853de3a1b27773b-TCP-80",
      "probe": {
        "id": "/subscriptions/redacts-1111-1111-1111-111111111111/resourceGroups/mc_rg_aks_swedencentral/providers/Microsoft.Network/loadBalancers/kubernetes/probes/adfc5e64f5d904777853de3a1b27773b-TCP-80",
        "resourceGroup": "mc_rg_aks_swedencentral"
      },
      "protocol": "Tcp",
      "provisioningState": "Succeeded",
      "resourceGroup": "mc_rg_aks_swedencentral",
      "type": "Microsoft.Network/loadBalancers/loadBalancingRules"
    }
  ],
  "probes": [
    {
      "etag": "W/\"7503422d-f1ad-4bac-b600-46a357ba0967\"",
      "id": "/subscriptions/redacts-1111-1111-1111-111111111111/resourceGroups/mc_rg_aks_swedencentral/providers/Microsoft.Network/loadBalancers/kubernetes/probes/adfc5e64f5d904777853de3a1b27773b-TCP-80",
      "intervalInSeconds": 5,
      "loadBalancingRules": [
        {
          "id": "/subscriptions/redacts-1111-1111-1111-111111111111/resourceGroups/mc_rg_aks_swedencentral/providers/Microsoft.Network/loadBalancers/kubernetes/loadBalancingRules/adfc5e64f5d904777853de3a1b27773b-TCP-80",
          "resourceGroup": "mc_rg_aks_swedencentral"
        }
      ],
      "name": "adfc5e64f5d904777853de3a1b27773b-TCP-80",
      "numberOfProbes": 2,
      "port": 31423,
      "probeThreshold": 2,
      "protocol": "Tcp",
      "provisioningState": "Succeeded",
      "resourceGroup": "mc_rg_aks_swedencentral",
      "type": "Microsoft.Network/loadBalancers/probes"
    }
  ],
```
