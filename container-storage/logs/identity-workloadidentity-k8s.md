```
rg=rgident
az group create -n $rg -l eastus # **Temporarily using eastus for "az identity federated-credential create" error - MethodNotAllowed https://learn.microsoft.com/en-us/azure/active-directory/workload-identities/workload-identity-federation-considerations#unsupported-regions-user-assigned-managed-identities
az aks create -g $rg -n aks --enable-oidc-issuer --enable-workload-identity -s $vmsize -c 1
az aks get-credentials -g $rg -n aks --overwrite-existing
# az aks update -g $rg -n aks --enable-oidc-issuer --enable-workload-identity
# az aks update -g $rg -n aks --disable-workload-identity
```

```
az aks show -g $rg -n aks --query securityProfile.workloadIdentity
{
  "enabled": true
}

az aks show -g $rg -n aks --query oidcIssuerProfile
{
  "enabled": true,
  "issuerUrl": "https://swedencentral.oic.prod-aks.azure.com/tenantId/key/"
}

kubectl get po -n kube-system -l azure-workload-identity.io/system=true
NAME                                                   READY   STATUS    RESTARTS   AGE
azure-wi-webhook-controller-manager-6bbb89cc55-7lpfv   1/1     Running   0          32m
azure-wi-webhook-controller-manager-6bbb89cc55-h86mc   1/1     Running   0          32m

kubectl get rs -n kube-system -l azure-workload-identity.io/system=true
NAME                                             DESIRED   CURRENT   READY   AGE
azure-wi-webhook-controller-manager-6bbb89cc55   2         2         2       34m

kubectl get mutatingwebhookconfigurations -l azure-workload-identity.io/system=true
NAME                                              WEBHOOKS   AGE
azure-wi-webhook-mutating-webhook-configuration   1          35m
```

- https://learn.microsoft.com/en-us/azure/aks/workload-identity-overview?tabs=dotnet
- https://learn.microsoft.com/en-us/azure/aks/workload-identity-deploy-cluster
