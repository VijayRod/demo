## lb (load balancer)

```
# See the section on ip azure for vip dip ilpip ca pa
```

- https://learn.microsoft.com/en-us/azure/load-balancer/load-balancer-overview: Azure Load Balancer operates at layer 4 of the Open Systems Interconnection (OSI) model.
- https://learn.microsoft.com/en-us/azure/load-balancer/load-balancer-troubleshoot
- https://learn.microsoft.com/en-us/azure/load-balancer/load-balancer-standard-diagnostics

## lb.app.k8s.aks

```
# See the section on lb logs

rg=rg
az group create -n $rg -l $loc
az aks create -g $rg -n aks -s $vmsize -c 1
az aks create -g $rg -n akscni --network-plugin azure -s $vmsize -c 1

# Same with kubnet and azure-cni
noderg=$(az aks show -g $rg -n aks --query nodeResourceGroup -o tsv)
# noderg=$(az aks show -g $rg -n akscni --query nodeResourceGroup -o tsv)
az network lb list -g $noderg
[
  {
    "backendAddressPools": [
      {
        "backendIPConfigurations": [
          {
            "id": "/subscriptions/redacts-1111-1111-1111-111111111111/resourceGroups/MC_rg_aks_swedencentral/providers/Microsoft.Compute/virtualMachineScaleSets/aks-nodepool1-24666711-vmss/virtualMachines/2/networkInterfaces/aks-nodepool1-24666711-vmss/ipConfigurations/ipconfig1",
            "resourceGroup": "MC_rg_aks_swedencentral"
          }
        ],
        "etag": "W/\"b457d459-2342-408a-b582-6215e3c06bb2\"",
        "id": "/subscriptions/redacts-1111-1111-1111-111111111111/resourceGroups/MC_rg_aks_swedencentral/providers/Microsoft.Network/loadBalancers/kubernetes/backendAddressPools/aksOutboundBackendPool",
        "loadBalancerBackendAddresses": [
          {
            "name": "674b5e55-b16a-47e3-acd1-bdf29ba28594",
            "networkInterfaceIPConfiguration": {
              "id": "/subscriptions/redacts-1111-1111-1111-111111111111/resourceGroups/MC_rg_aks_swedencentral/providers/Microsoft.Compute/virtualMachineScaleSets/aks-nodepool1-24666711-vmss/virtualMachines/2/networkInterfaces/aks-nodepool1-24666711-vmss/ipConfigurations/ipconfig1",
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
            "id": "/subscriptions/redacts-1111-1111-1111-111111111111/resourceGroups/MC_rg_aks_swedencentral/providers/Microsoft.Compute/virtualMachineScaleSets/aks-nodepool1-24666711-vmss/virtualMachines/2/networkInterfaces/aks-nodepool1-24666711-vmss/ipConfigurations/ipconfig1",
            "resourceGroup": "MC_rg_aks_swedencentral"
          }
        ],
        "etag": "W/\"b457d459-2342-408a-b582-6215e3c06bb2\"",
        "id": "/subscriptions/redacts-1111-1111-1111-111111111111/resourceGroups/MC_rg_aks_swedencentral/providers/Microsoft.Network/loadBalancers/kubernetes/backendAddressPools/kubernetes",
        "loadBalancerBackendAddresses": [
          {
            "name": "8975388f-da9a-4c2e-8879-498f2c5e2f6f",
            "networkInterfaceIPConfiguration": {
              "id": "/subscriptions/redacts-1111-1111-1111-111111111111/resourceGroups/MC_rg_aks_swedencentral/providers/Microsoft.Compute/virtualMachineScaleSets/aks-nodepool1-24666711-vmss/virtualMachines/2/networkInterfaces/aks-nodepool1-24666711-vmss/ipConfigurations/ipconfig1",
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
    "etag": "W/\"b457d459-2342-408a-b582-6215e3c06bb2\"",
    "frontendIPConfigurations": [
      {
        "etag": "W/\"b457d459-2342-408a-b582-6215e3c06bb2\"",
        "id": "/subscriptions/redacts-1111-1111-1111-111111111111/resourceGroups/MC_rg_aks_swedencentral/providers/Microsoft.Network/loadBalancers/kubernetes/frontendIPConfigurations/68c14628-122f-4676-9122-02fa4dddd897",
        "name": "68c14628-122f-4676-9122-02fa4dddd897",
        "outboundRules": [
          {
            "id": "/subscriptions/redacts-1111-1111-1111-111111111111/resourceGroups/MC_rg_aks_swedencentral/providers/Microsoft.Network/loadBalancers/kubernetes/outboundRules/aksOutboundRule",
            "resourceGroup": "MC_rg_aks_swedencentral"
          }
        ],
        "privateIPAllocationMethod": "Dynamic",
        "provisioningState": "Succeeded",
        "publicIPAddress": {
          "id": "/subscriptions/redacts-1111-1111-1111-111111111111/resourceGroups/MC_rg_aks_swedencentral/providers/Microsoft.Network/publicIPAddresses/68c14628-122f-4676-9122-02fa4dddd897",
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
        "etag": "W/\"b457d459-2342-408a-b582-6215e3c06bb2\"",
        "frontendIPConfigurations": [
          {
            "id": "/subscriptions/redacts-1111-1111-1111-111111111111/resourceGroups/MC_rg_aks_swedencentral/providers/Microsoft.Network/loadBalancers/kubernetes/frontendIPConfigurations/68c14628-122f-4676-9122-02fa4dddd897",
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
    "resourceGuid": "79315e3b-28d7-4050-83b5-e2fc7910a512",
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
]
```

## lb.spec.floatingip

```
noderg=$(az aks show -g $rg -n aks --query nodeResourceGroup -o tsv)
az network lb rule show -g $noderg --lb-name kubernetes -n a3d654cb447704508bc7b1db1dacaec0-TCP-443 # TBD Enable Floating IP (portal)
```

- https://learn.microsoft.com/en-us/azure/load-balancer/load-balancer-floating-ip

## lb.spec.health

- https://learn.microsoft.com/en-us/azure/virtual-network/what-is-ip-address-168-63-129-16: Enables health probes from Azure Load Balancer to determine the health state of VMs.
- https://learn.microsoft.com/en-us/azure/load-balancer/load-balancer-troubleshoot-health-probe-status

## lb.spec.idletimeout

```
noderg=$(az aks show -g $rg -n aks --query nodeResourceGroup -o tsv)
az network lb outbound-rule show -g $noderg --lb-name kubernetes -n aksOutboundRule --query idleTimeoutInMinutes
30

az network lb rule show -g $noderg --lb-name kubernetes -n a3d654cb447704508bc7b1db1dacaec0-TCP-443 # TBD Idle timeout (minutes) (portal)
```

- https://learn.microsoft.com/en-us/azure/load-balancer/load-balancer-tcp-idle-timeout?tabs=tcp-reset-idle-cli
- https://learn.microsoft.com/en-us/azure/aks/load-balancer-standard: IdleTimeoutInMinutes

## lb.spec.tcpreset

```
noderg=$(az aks show -g $rg -n aks --query nodeResourceGroup -o tsv)
az network lb outbound-rule show -g $noderg --lb-name kubernetes -n aksOutboundRule --query enableTcpReset
true
```

```
az network lb rule show -g $noderg --lb-name kubernetes -n a3d654cb447704508bc7b1db1dacaec0-TCP-443 # TBD Enable TCP Reset (portal)
```

- https://learn.microsoft.com/en-us/azure/load-balancer/load-balancer-tcp-idle-timeout?tabs=tcp-reset-idle-cli
- https://learn.microsoft.com/en-us/azure/aks/load-balancer-standard: AKS enables TCP Reset on idle by default. We recommend you keep this configuration and leverage it for more predictable application behavior on your scenarios. TCP RST is only sent during TCP connection in ESTABLISHED state.
