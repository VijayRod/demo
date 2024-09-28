```
# az aks check-acr -g $rgname -n $clustername --acr $registry
The login server endpoint suffix '.azurecr.io' is automatically appended.
[2023-08-03T12:36:46Z] Checking host name resolution (imageshack.azurecr.io): SUCCEEDED
[2023-08-03T12:36:46Z] Canonical name for ACR (imageshack.azurecr.io): r0726sec.swedencentral.cloudapp.azure.com.
[2023-08-03T12:36:46Z] ACR location: swedencentral
[2023-08-03T12:36:46Z] Checking managed identity...
[2023-08-03T12:36:46Z] Kubelet managed identity client ID: dummyi-959f-429a-94f9-c11f73867df8
[2023-08-03T12:36:46Z] Validating managed identity existance: SUCCEEDED
[2023-08-03T12:36:47Z] Validating image pull permission: SUCCEEDED
[2023-08-03T12:36:47Z]
Your cluster can pull images from imageshack.azurecr.io!

# az aks check-acr -g $rgname -n $clustername --acr $registry --node-name aks-nodepool1-31040111-vmss000005
The login server endpoint suffix '.azurecr.io' is automatically appended.
[2023-08-03T12:37:12Z] Checking host name resolution (imageshack.azurecr.io): SUCCEEDED
[2023-08-03T12:37:12Z] Canonical name for ACR (imageshack.azurecr.io): r0726sec.swedencentral.cloudapp.azure.com.
[2023-08-03T12:37:12Z] ACR location: swedencentral
[2023-08-03T12:37:12Z] Checking managed identity...
[2023-08-03T12:37:12Z] Kubelet managed identity client ID: dummyi-959f-429a-94f9-c11f73867df8
[2023-08-03T12:37:13Z] Validating managed identity existance: SUCCEEDED
[2023-08-03T12:37:13Z] Validating image pull permission: SUCCEEDED
[2023-08-03T12:37:13Z]
Your cluster can pull images from imageshack.azurecr.io!
```
