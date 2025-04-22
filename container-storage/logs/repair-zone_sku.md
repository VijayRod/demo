## sku (vmsize)

```
# See the sections on dedicated host and ppg
```

```
# ps

# list the available locations for your subscription
Get-AzVMSize -Location westeurope | where-object {$_.name -EQ "Standard_D4_v5"}
Get-AzVMSize -Location "REGION" | Where {$_.NumberOfCores -gt 128}
# https://techcommunity.microsoft.com/discussions/compute/how-to-avoid-this-size-is-not-available-in-zone-/3997216
ResourceType                Name   Location     Zones RestrictionInfo
------------                ----   --------     ----- ---------------
virtualMachines Standard_D4ls_v5 westeurope {1, 2, 3} type: Zone, locations: westeurope, zones: 3
```

- https://azure.microsoft.com/en-us/explore/global-infrastructure/products-by-region/
- https://aka.ms/aks/vm-size-selector
- https://azure.microsoft.com/en-us/pricing/vm-selector/

```
# sku.api
```
- https://github.com/Azure/skewer/blob/main/sku.go

```
# sku.error.SkuNotAvailable.The requested size for resource '/subscriptions/.../virtualMachines/myVM' is currently not available in location 'westeurope' zones '2' for subscription '111.....111'

# Get-AzVMSize in that sub
```

## sku.cpu

```
# See the section on cpu
```

## sku.generation

- https://learn.microsoft.com/en-us/azure/virtual-machines/sizes-previous-gen
- https://azure.microsoft.com/en-us/pricing/details/virtual-machines/series/: generation
- TBD https://learn.microsoft.com/en-us/azure/virtual-machines/av2-series: VM Generation Support: Generation 1
- TBD https://learn.microsoft.com/en-us/azure/virtual-machines/generation-2#generation-2-vm-sizes
  
## sku.retirement

- https://learn.microsoft.com/en-us/azure/virtual-machines/nv-series-retirement#how-does-the-nv-series-migration-affect-me: will be set to a deallocated state. These virtual machines will be stopped and removed from the host. These virtual machines will no longer be billed in the deallocated state.
