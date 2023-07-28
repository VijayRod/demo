```
az aks nodepool add -g $rgname --cluster-name $clustername --name agentpool2 --node-count 1 --host-group-id $hostGroupId --node-vm-size Standard_D4s_v4
```

```
# az aks show -g $rgname -n $clustername --query agentPoolProfiles[1].hostGroupId
"/subscriptions/dummys-1111-1111-1111-111111111111/resourceGroups/SECURESHACK2/providers/Microsoft.Compute/hostGroups/myHostGroup"

# az aks nodepool show -g $rgname --cluster-name $clustername --name agentpool2 --query hostGroupId
"/subscriptions/dummys-1111-1111-1111-111111111111/resourceGroups/SECURESHACK2/providers/Microsoft.Compute/hostGroups/myHostGroup"
```
