## az-hsm.dedicated

```
az dedicated-hsm create -g $rg --name dhsm --sku "SafeNet Luna Network HSM A790" -l EastUS
# (InvalidResourceType) The resource type could not be found in the namespace 'Microsoft.HardwareSecurityModules' for api version '2021-11-30'.
# https://github.com/Azure/azure-powershell/issues/16814: InvalidResourceType. namespace 'Microsoft.HardwareSecurityModules'. subscription should be whitelisted
```

- https://learn.microsoft.com/en-us/cli/azure/dedicated-hsm?view=azure-cli-latest
- https://learn.microsoft.com/en-us/azure/dedicated-hsm/overview

## az-hsm.managed

```
# Please refer to az-keyvault.hsm
# az keyvault create -g $rg --hsm-name $keyvaultName --administrators $oid --retention-days 7
```

## az-hsm.payment

```
az dedicated-hsm create -g $rg --name paymenthsm --sku payShield10K_LMK1_CPS60 -l westus
# (InvalidResourceType) The resource type could not be found in the namespace 'Microsoft.HardwareSecurityModules' for api version '2021-11-30'.
# https://github.com/Azure/azure-powershell/issues/16814: InvalidResourceType. namespace 'Microsoft.HardwareSecurityModules'. subscription should be whitelisted
```

- https://azure.microsoft.com/en-us/blog/secure-your-digital-payment-system-in-the-cloud-with-azure-payment-hsm-now-generally-available/
- https://azure.microsoft.com/en-us/products/payment-hsm/
- https://learn.microsoft.com/en-us/azure/payment-hsm/quickstart-cli
