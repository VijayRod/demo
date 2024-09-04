```
az aks create -g $rg -n akssafeguard --enable-addons azure-policy --safeguards-level Warning
az aks get-credentials -g $rg -n akssafeguard --overwrite-existing

az aks show -g $rg -n akssafeguard --query addonProfiles.azurepolicy
az aks show -g $rg -n akssafeguard --query safeguardsProfile
{
  "config": null,
  "enabled": true,
  "identity": {
    "clientId": "redacts-2bfd-4a7a-b8ef-111111111111",
    "objectId": "redacts-bd7e-4707-8982-111111111111",
    "resourceId": "/subscriptions/redacts-1111-1111-1111-111111111111/resourcegroups/MC_rg_akssafeguard_swedencentral/providers/Microsoft.ManagedIdentity/userAssignedIdentities/azurepolicy-akssafeguard"
  }
}
{
  "excludedNamespaces": null,
  "level": "Warning",
  "systemExcludedNamespaces": [
    "kube-system",
    "calico-system",
    "tigera-system",
    "gatekeeper-system"
  ],
  "version": "v1.0.0"
}
```

```
kubectl describe k8sazurev1restrictednodeedits.constraints.gatekeeper.sh/azurepolicy-k8sazurev1restrictednodeedits-f08a6c36fcf5d342bfde
Annotations:  azure-policy-assignment-id:
                /subscriptions/efec8e52-e1ad-4ae1-8598-f243e56e2b08/resourceGroups/rg/providers/Microsoft.ContainerService/managedClusters/akssafeguard/pr...
              azure-policy-definition-id: /providers/Microsoft.Authorization/policyDefinitions/53a4a537-990c-495a-92e0-7c21a465442c
              azure-policy-definition-reference-id: restrictedNodeEditsInKubernetesCluster
              azure-policy-definition-version: 1.2.0-preview
              azure-policy-set-definition-id: /providers/Microsoft.Authorization/policySetDefinitions/c047ea8e-9c78-49b2-958b-37e56d291a44
              azure-policy-set-definition-version: 1.7.0-preview

https://github.com/Azure/azure-policy/blob/master/built-in-policies/policySetDefinitions/Kubernetes/AKS_Safeguards.json
  "properties": {
    "policyDefinitions": [
      {
        "policyDefinitionReferenceId": "restrictedNodeEditsInKubernetesCluster",
        "policyDefinitionId": "/providers/Microsoft.Authorization/policyDefinitions/53a4a537-990c-495a-92e0-7c21a465442c",
  "id": "/providers/Microsoft.Authorization/policySetDefinitions/c047ea8e-9c78-49b2-958b-37e56d291a44",
  "name": "c047ea8e-9c78-49b2-958b-37e56d291a44"
```
- https://github.com/Azure/azure-policy/blob/master/built-in-policies/policySetDefinitions/Kubernetes/AKS_Safeguards.json

```
# The constraints Include additional parameter values like allowedUsers, among others.
kubectl describe k8sazurev1restrictednodeedits.constraints.gatekeeper.sh/azurepolicy-k8sazurev1restrictednodeedits-f08a6c36fcf5d342bfde
Spec:
  Enforcement Action:  warn
  Match:
    Excluded Namespaces:
      kube-system
      calico-system
      tigera-system
      gatekeeper-system
    Kinds:
      API Groups:

      Kinds:
        Node
    Source:  Original
  Parameters:
    Allowed Groups:
      system:node
    Allowed Users:
      nodeclient
      system:serviceaccount:kube-system:aci-connector-linux
      system:serviceaccount:kube-system:node-controller
      acsService
      aksService
      system:serviceaccount:kube-system:cloud-node-manager
```

- https://learn.microsoft.com/en-us/azure/aks/deployment-safeguards
