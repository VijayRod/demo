```
az aks nodepool add -g $rgname --cluster-name $clustername --name agentpool2 --node-count 1 --host-group-id $hostGroupId --node-vm-size Standard_D4s_v4
```

```
# az aks show -g $rgname -n $clustername --query agentPoolProfiles[1].hostGroupId
"/subscriptions/8d99b0de-7ea1-4a2b-8fd0-c2ef9f25c5dc/resourceGroups/SECURESHACK2/providers/Microsoft.Compute/hostGroups/myHostGroup"

# az aks nodepool show -g $rgname --cluster-name $clustername --name agentpool2 --query hostGroupId
"/subscriptions/8d99b0de-7ea1-4a2b-8fd0-c2ef9f25c5dc/resourceGroups/SECURESHACK2/providers/Microsoft.Compute/hostGroups/myHostGroup"
```
