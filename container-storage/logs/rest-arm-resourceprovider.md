## rest-arm-resourceprovider

```
az provider register -n Microsoft.ContainerService
az provider register -n Microsoft.Compute --wait

az provider show -n Microsoft.RedHatOpenShift | grep regis
{
  "authorizations": [
    {
      "applicationId": "f1dd0a37-89c6-4e07-bcd1-ffd3d43d8875",
      "managedByAuthorization": {
        "allowManagedByInheritance": true
      },
      "managedByRoleDefinitionId": "9e3af657-a8ff-583c-a75c-2fe7c4bcb635",
      "roleDefinitionId": "640c5ac9-6f32-4891-94f4-d20f7aa9a7e6"
    }
  ],
  "id": "/subscriptions/redacts-1111-1111-1111-111111111111/providers/Microsoft.RedHatOpenShift",
  "namespace": "Microsoft.RedHatOpenShift",
  "providerAuthorizationConsentState": null,
  "registrationPolicy": "RegistrationRequired",
  "registrationState": "Registered",
...
```

- https://learn.microsoft.com/en-us/azure/azure-resource-manager/management/resource-providers-and-types
- https://learn.microsoft.com/en-us/azure/azure-resource-manager/management/deployment-models: SRP: Storage Resource Provider, CRP: Compute Resource Provider, NRP: Network Resource Provider

## rest-arm-resourceprovider.feature

```
az feature register --namespace "Microsoft.ContainerService" --name "NodeAutoProvisioningPreview"
az feature show --namespace "Microsoft.ContainerService" --name "NodeAutoProvisioningPreview"
# Once the feature status shows as Registered, go ahead and refresh the resource provider's registration with the az provider register command.
```

## rest-arm-resourceprovider.manifest

```
# See the section on ARM
```

## rest-arm-resourceprovider.rp.compute

- https://learn.microsoft.com/en-us/azure/architecture/guide/technology-choices/compute-decision-tree
- https://techcommunity.microsoft.com/t5/azure-paas-blog/how-custom-resource-provider-achieve-async-deployment/ba-p/3067963
