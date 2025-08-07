- https://learn.microsoft.com/en-us/graph/api/resources/federatedidentitycredentials-overview?view=graph-rest-1.0:  enables workload identity federation for software workloads. federated identity credential via Microsoft Graph. api://AzureADTokenExchange for Azure AD.
- https://learn.microsoft.com/en-us/graph/api/application-post-federatedidentitycredentials?view=graph-rest-1.0&tabs=cli
- https://learn.microsoft.com/en-us/microsoft-365/troubleshoot/authentication/account-issues-for-federated-users
- https://learn.microsoft.com/en-us/azure/active-directory/workload-identities/workload-identity-federation-considerations

```
# Refer to aks.workloadidentity

# Microsoft.ManagedIdentity/userAssignedIdentities/federatedIdentityCredentials

# portal, Managed Identity, Federated Credentials
```
  
```
az identity federated-credential create -g $rg --identity-name identity -n fedidentity --issuer $oidcUri --subject system:serviceaccount:"$serviceaccountns":"$serviceaccount" --audience api://AzureADTokenExchange
date
sleep 120

{
  "audiences": [
    "api://AzureADTokenExchange"
  ],
  "id": "/subscriptions/redacts-1111-1111-1111-111111111111/resourcegroups/rgident/providers/Microsoft.ManagedIdentity/userAssignedIdentities/identity/federatedIdentityCredentials/fedidentity",
  "issuer": "https://eastus.oic.prod-aks.azure.com/tenantId/key/", # $oidcUri
  "name": "fedidentity",
  "resourceGroup": "rgident",
  "subject": "system:serviceaccount:default:workload-identity-sa", # system:serviceaccount:"$serviceaccountns":"$serviceaccount"
  "systemData": null,
  "type": "Microsoft.ManagedIdentity/userAssignedIdentities/federatedIdentityCredentials"
}

az identity federated-credential list -g $rg --identity-name myIdentity
```


