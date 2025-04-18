## k8s-networkpolicy.spec.provider.azure.policy.npm

```
rg=rgnpm
az group create -n $rg -l $loc
az aks create -g $rg -n aks --network-plugin azure --network-policy azure -s $vmsize -c 1
az aks get-credentials -g $rg -n aks --overwrite-existing
```

```
kubectl get po -n kube-system -l k8s-app=azure-npm
NAME              READY   STATUS    RESTARTS   AGE
azure-npm-z7tdq   1/1     Running   0          76m

kubectl get ds -n kube-system azure-npm
NAME        DESIRED   CURRENT   READY   UP-TO-DATE   AVAILABLE   NODE SELECTOR   AGE
azure-npm   1         1         1       1            1           <none>          76m
```

- https://github.com/Azure/azure-container-networking/blob/master/docs/npm.md
- https://learn.microsoft.com/en-us/azure/aks/use-network-policies#network-policy-options-in-aks
- https://github.com/Azure/AKS/issues/2792: NPM pods watch pod, namespace and netpol related events
- https://learn.microsoft.com/en-us/azure/aks/use-network-policies#network-policy-options-in-aks: To enforce the specified policies, Azure Network Policy Manager for Linux uses Linux IPTables. Azure Network Policy Manager for Windows uses Host Network Service (HNS) ACLPolicies. Policies are translated into sets of allowed and disallowed IP pairs. These pairs are then programmed as IPTable or HNS ACLPolicy filter rules.

> ## k8s-networkpolicy.spec.provider.azure.policy.npm.debug

```
# The performance of NPM depends on pod labels as one of the factors.
kubectl get pods --all-namespaces -o jsonpath='{range .items[*]}{.metadata.labels}{"\n"}{end}' | jq -c 'to_entries[] | "\(.key)=\(.value)"' | sort | uniq | wc -l

# The recommendation is to transition from npm to Cilium.
```

- https://github.com/Azure/azure-container-networking/blob/master/docs/npm.md#troubleshooting
- https://learn.microsoft.com/en-us/azure/aks/use-network-policies#limitations-of-azure-network-policy-manager
  
## k8s-networkpolicy.spec.provider.azure.policy.npm.disable

```
az aks update -g $rg -n akscal --network-policy none # disable an existing network policy
```

- https://github.com/Azure/AKS/issues/3845: [Feature] Disable network policy on the existing AKS Cluster (to allow migration to overlay): --network-policy none
- https://learn.microsoft.com/en-us/cli/azure/aks?view=azure-cli-latest: "none" when no Network Policy Engine is installed (default value).
- tbd https://github.com/Azure/AKS/releases/tag/2024-02-07
- https://github.com/Azure/AKS/releases/tag/2024-05-13: Default network policy is "networkPolicy=none" when network policy is not set on new clusters starting from API version 2024-05-01. Allow disabling NPM for existing clusters with "networkPolicy=none" for stable api version 2024-05-01.
