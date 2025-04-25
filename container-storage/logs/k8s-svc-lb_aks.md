## k8s-svc-lb.aks

- https://cloud-provider-azure.sigs.k8s.io/topics/loadbalancer/
- https://learn.microsoft.com/en-us/azure/aks/load-balancer-standard

```
az aks show -g $rg -n aks --query networkProfile.loadBalancerProfile

az network lb show -g MC_rg_aks_swedencentral -n kubernetes

kubectl delete po nginx
kubectl delete svc nginx
kubectl run nginx --image=nginx --port=80
sleep 5
kubectl get po nginx
kubectl expose po nginx --type=LoadBalancer
sleep 60
kubectl get svc,ep; kubectl get po -owide
```

```
# svc.lb.finalizer
kubectl get svc nginx -oyaml
metadata:
  finalizers:
  - service.kubernetes.io/load-balancer-cleanup
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

kubectl delete po nginx
kubectl delete svc nginx
kubectl run nginx --image=nginx --port=80
sleep 5
kubectl get po nginx
kubectl expose po nginx --type=LoadBalancer
sleep 60
kubectl get svc; kubectl get po -owide

# Same with kubnet and azure-cni
k describe po nginx | grep Port:
Containers:
  nginx:
    Port:           80/TCP
    Host Port:      0/TCP
k get svc;k get po -owide
NAME         TYPE           CLUSTER-IP     EXTERNAL-IP      PORT(S)        AGE
nginx        LoadBalancer   10.0.216.132   74.241.154.123   80:32642/TCP   13m
az network lb list -g $noderg
      {
        "backendIPConfigurations": [
...
        ],
        "loadBalancingRules": [
          {
            "id": "/subscriptions/redacts-1111-1111-1111-111111111111/resourceGroups/mc_rg_akscni_swedencentral/providers/Microsoft.Network/loadBalancers/kubernetes/loadBalancingRules/a3ec62707b79842639e5500b53b299d0-TCP-80",
            "resourceGroup": "mc_rg_akscni_swedencentral"
          }
        ],
        "name": "kubernetes",
        "provisioningState": "Succeeded",
        "resourceGroup": "mc_rg_akscni_swedencentral",
        "type": "Microsoft.Network/loadBalancers/backendAddressPools"
      }
    ],
    "etag": "W/\"ddefdbd0-ce8f-442f-8e93-99adf3784432\"",
    "frontendIPConfigurations": [
      {
...
      },
      {
        "etag": "W/\"ddefdbd0-ce8f-442f-8e93-99adf3784432\"",
        "id": "/subscriptions/redacts-1111-1111-1111-111111111111/resourceGroups/mc_rg_akscni_swedencentral/providers/Microsoft.Network/loadBalancers/kubernetes/frontendIPConfigurations/a3ec62707b79842639e5500b53b299d0",
        "loadBalancingRules": [
          {
            "id": "/subscriptions/redacts-1111-1111-1111-111111111111/resourceGroups/mc_rg_akscni_swedencentral/providers/Microsoft.Network/loadBalancers/kubernetes/loadBalancingRules/a3ec62707b79842639e5500b53b299d0-TCP-80",
            "resourceGroup": "mc_rg_akscni_swedencentral"
          }
        ],
        "name": "a3ec62707b79842639e5500b53b299d0",
        "privateIPAllocationMethod": "Dynamic",
        "provisioningState": "Succeeded",
        "publicIPAddress": {
          "id": "/subscriptions/redacts-1111-1111-1111-111111111111/resourceGroups/mc_rg_akscni_swedencentral/providers/Microsoft.Network/publicIPAddresses/kubernetes-a3ec62707b79842639e5500b53b299d0",
          "resourceGroup": "mc_rg_akscni_swedencentral"
        },
        "resourceGroup": "mc_rg_akscni_swedencentral",
        "type": "Microsoft.Network/loadBalancers/frontendIPConfigurations"
      }
    ],
    "id": "/subscriptions/redacts-1111-1111-1111-111111111111/resourceGroups/mc_rg_akscni_swedencentral/providers/Microsoft.Network/loadBalancers/kubernetes",
    "inboundNatPools": [],
    "inboundNatRules": [],
    "loadBalancingRules": [
      {
        "backendAddressPool": {
          "id": "/subscriptions/redacts-1111-1111-1111-111111111111/resourceGroups/mc_rg_akscni_swedencentral/providers/Microsoft.Network/loadBalancers/kubernetes/backendAddressPools/kubernetes",
          "resourceGroup": "mc_rg_akscni_swedencentral"
        },
        "backendAddressPools": [
          {
            "id": "/subscriptions/redacts-1111-1111-1111-111111111111/resourceGroups/mc_rg_akscni_swedencentral/providers/Microsoft.Network/loadBalancers/kubernetes/backendAddressPools/kubernetes",
            "resourceGroup": "mc_rg_akscni_swedencentral"
          }
        ],
        "backendPort": 80,
        "disableOutboundSnat": true,
        "enableFloatingIP": true,
        "enableTcpReset": true,
        "etag": "W/\"ddefdbd0-ce8f-442f-8e93-99adf3784432\"",
        "frontendIPConfiguration": {
          "id": "/subscriptions/redacts-1111-1111-1111-111111111111/resourceGroups/mc_rg_akscni_swedencentral/providers/Microsoft.Network/loadBalancers/kubernetes/frontendIPConfigurations/a3ec62707b79842639e5500b53b299d0",
          "resourceGroup": "mc_rg_akscni_swedencentral"
        },
        "frontendPort": 80,
        "id": "/subscriptions/redacts-1111-1111-1111-111111111111/resourceGroups/mc_rg_akscni_swedencentral/providers/Microsoft.Network/loadBalancers/kubernetes/loadBalancingRules/a3ec62707b79842639e5500b53b299d0-TCP-80",
        "idleTimeoutInMinutes": 4,
        "loadDistribution": "Default",
        "name": "a3ec62707b79842639e5500b53b299d0-TCP-80",
        "probe": {
          "id": "/subscriptions/redacts-1111-1111-1111-111111111111/resourceGroups/mc_rg_akscni_swedencentral/providers/Microsoft.Network/loadBalancers/kubernetes/probes/a3ec62707b79842639e5500b53b299d0-TCP-80",
          "resourceGroup": "mc_rg_akscni_swedencentral"
        },
        "protocol": "Tcp",
        "provisioningState": "Succeeded",
        "resourceGroup": "mc_rg_akscni_swedencentral",
        "type": "Microsoft.Network/loadBalancers/loadBalancingRules"
      }
    ],
    "location": "swedencentral",
    "name": "kubernetes",
    "outboundRules": [
      {
...
      }
    ],
    "probes": [
      {
        "etag": "W/\"ddefdbd0-ce8f-442f-8e93-99adf3784432\"",
        "id": "/subscriptions/redacts-1111-1111-1111-111111111111/resourceGroups/mc_rg_akscni_swedencentral/providers/Microsoft.Network/loadBalancers/kubernetes/probes/a3ec62707b79842639e5500b53b299d0-TCP-80",
        "intervalInSeconds": 5,
        "loadBalancingRules": [
          {
            "id": "/subscriptions/redacts-1111-1111-1111-111111111111/resourceGroups/mc_rg_akscni_swedencentral/providers/Microsoft.Network/loadBalancers/kubernetes/loadBalancingRules/a3ec62707b79842639e5500b53b299d0-TCP-80",
            "resourceGroup": "mc_rg_akscni_swedencentral"
          }
        ],
        "name": "a3ec62707b79842639e5500b53b299d0-TCP-80",
        "numberOfProbes": 2,
        "port": 32642,
        "probeThreshold": 2,
        "protocol": "Tcp",
        "provisioningState": "Succeeded",
        "resourceGroup": "mc_rg_akscni_swedencentral",
        "type": "Microsoft.Network/loadBalancers/probes"
      }
    ],
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

## k8s-svc-lb.aks.outbound

- A single outbound IP address

```
kubectl run nginx --image=nginx
sleep 10
kubectl exec -it nginx -- curl ifconfig.me # 74.241.163.46

publicIpResourceUri=$(az aks show -g $rg -n aks --query networkProfile.loadBalancerProfile.effectiveOutboundIPs[].id -otsv)
az network public-ip show --ids $publicIpResourceUri --query ipAddress -o tsv # 74.241.163.46
```

- Multiple outbound IP addresses

```
az aks update -g $rg -n aksdns --load-balancer-managed-outbound-ip-count 2
kubectl run nginx --image=nginx
kubectl run nginx2 --image=nginx
sleep 10
kubectl exec -it nginx -- curl ifconfig.me # 74.241.163.46
kubectl exec -it nginx2 -- curl ifconfig.me # 74.241.163.46 (Shows the same IP)
```

- https://learn.microsoft.com/en-us/azure/load-balancer/outbound-rules#scale

## k8s-svc-lb.aks.outbound.port

```
az aks create
    --load-balancer-managed-outbound-ip-count                     : Load balancer managed outbound IP count.
        Desired number of managed outbound IPs for load balancer outbound connection. Valid for Standard SKU load balancer cluster only.
    --load-balancer-outbound-ports                                : Load balancer outbound allocated ports.
        Desired static number of outbound ports per VM in the load balancer backend pool. By default, set to 0 which uses the default allocation based on the number of VMs. Please specify a value in the range of [0, 64000] that is a multiple of 8.

# https://learn.microsoft.com/en-us/troubleshoot/azure/azure-kubernetes/create-upgrade-delete/error-code-invalidloadbalancerprofileallocatedoutboundports: 64,000 ports per IP / <outbound ports per node> * <number of outbound IPs> = <maximum number of nodes in the cluster>. each worker node is allocated 1,024 ports (by default). consider node surges that happen during cluster upgrades and other operations
# i.e. (64,000 ports per IP / <outbound ports per node>) * <number of outbound IPs> = <maximum number of nodes in the cluster>
# For example, if we have a cluster of 100 nodes and each worker node has the default 1024 ports, we'll need 2 outbound IPs because the calculation is 100 * (1024/64000) which equals 1.6, rounding up to 2.
```        
        
- https://aka.ms/aks/slb-port
- https://learn.microsoft.com/en-us/azure/aks/load-balancer-standard#configure-outbound-ports-and-idle-timeout
- https://learn.microsoft.com/en-us/azure/aks/load-balancer-standard#scale-the-number-of-managed-outbound-public-ips

## k8s-svc-lb.aks.outbound.port.error.InvalidLoadBalancerProfileAllocatedOutboundPorts

```
# (64000 ports per IP / 50000 outbound ports configured) * 1 outbound IP configured = 1.n = max of 1 node
rg=rg
az group create -n $rg -l $loc
az aks create -g $rg -n akslb --load-balancer-managed-outbound-ip-count 1 --load-balancer-outbound-ports 50000 -s $vmsize -c 2 # InvalidLoadBalancerProfileAllocatedOutboundPorts

(InvalidLoadBalancerProfileAllocatedOutboundPorts) Load balancer profile allocated ports 50000 is not in an allowable range given the number of nodes and IPs provisioned. Total node count 3 requires 150000 ports but only 64000 ports are available given 1 outbound public IPs. Refer to https://aka.ms/aks/slb-ports for more details.
Code: InvalidLoadBalancerProfileAllocatedOutboundPorts
Message: Load balancer profile allocated ports 50000 is not in an allowable range given the number of nodes and IPs provisioned. Total node count 3 requires 150000 ports but only 64000 ports are available given 1 outbound public IPs. Refer to https://aka.ms/aks/slb-ports for more details.
Target: networkProfile.loadBalancerProfile.allocatedOutboundPorts
```

- https://learn.microsoft.com/en-us/troubleshoot/azure/azure-kubernetes/create-upgrade-delete/error-code-invalidloadbalancerprofileallocatedoutboundports

## k8s-svc-lb.aks.timeout

```
# lb.timeout.outbound (SNAT) (not related to k8s svc)

# az aks update -h | grep load-balancer-idle-timeout # Desired idle timeout for load balancer outbound flows, default is 30 minutes.
az aks update -g $rg -n aks --load-balancer-idle-timeout 30
az network lb outbound-rule list -g $noderg --lb-name kubernetes -o table # verify
az network lb outbound-rule show -g $noderg --lb-name kubernetes -n aksOutboundRule # verify
```
- https://learn.microsoft.com/en-us/azure/aks/load-balancer-standard#configure-the-load-balancer-idle-timeout: When SNAT port resources are exhausted, outbound flows fail until existing flows release SNAT ports.. load balancer uses a 30-minute idle timeout for reclaiming SNAT ports from idle flows.
- https://learn.microsoft.com/en-us/azure/load-balancer/load-balancer-tcp-idle-timeout?tabs=tcp-reset-idle-cli: If a period of inactivity is longer than the timeout value, there's no guarantee that the TCP or HTTP session is maintained between the client and your service.
- https://learn.microsoft.com/en-us/azure/load-balancer/load-balancer-tcp-reset#configurable-tcp-idle-timeout: default is 4 minutes
- https://stackoverflow.com/questions/50706483/what-azure-kubernetes-aks-time-out-happens-to-disconnect-connections-in-out: best way (I feel) to handle this is to leave the timeout at 4 minutes (since it has to exist anyway) and then setup your infrastructure to disconnect your connections in a graceful way (when idle) prior to hitting the Load Balancer timeout.
- https://learn.microsoft.com/en-us/answers/questions/1350652/idle-timeout-of-load-balancing-rules-belonging-to

```
# lb.timeout.inbound
# the default value is 4 and will reconcile to the default value during any PUT operation on the cluster if changed
az network lb rule list -g $noderg --lb-name kubernetes -o table # verify
az network lb rule show -g $noderg --lb-name kubernetes -n <rule-name> # verify

kind: Service
annotations:
  service.beta.kubernetes.io/azure-load-balancer-tcp-idle-timeout: 4
```
- https://learn.microsoft.com/en-us/azure/aks/load-balancer-standard#customizations-via-kubernetes-annotations: time in minutes for TCP connection idle timeouts to occur on the load balancer. The default and minimum value is 4. The maximum value is 30.
- https://learn.microsoft.com/en-us/answers/questions/1350652/idle-timeout-of-load-balancing-rules-belonging-to
