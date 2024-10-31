```
json='{"key1":"value1"}'; echo "$json" | jq .key1 # "value1"
json='{"key1":"value1"}'; echo "$json" | jq '.key1' # "value1"
json='[{"key1":"value1"}, {"key2":"value2"}]'; echo "$json" | jq .[0].key1 # "value1"
json='[{"key1":"value1"}, {"key2":"value2"}]'; echo "$json" | jq '.[0].key1' # "value1"

# azure.cli
az aks show -g $rg -n aks | jq .nodeResourceGroup # "MC_rgredis12_aks_swedencentral" # az aks show -g $rg -n aks --query nodeResourceGroup (without -otsv as it would remove the double quotes)
az aks show -g $rg -n aks | jq .agentPoolProfiles[0] # az aks show -g $rg -n aks --query agentPoolProfiles[0]
{
  "artifactStreamingProfile": null,
  "availabilityZones": null,
  "capacityReservationGroupId": null,
  "count": 2,
...
az aks show -g $rg -n aks | jq .agentPoolProfiles[0].count # az aks show -g $rg -n aks --query agentPoolProfiles[0].count # 2
az acr login -n $registry --expose-token | jq .accessToken
az aks show -g $rg -n aks | jq .accessToken

# kubectl
kubectl run nginx --image=nginx
kubectl get pods -o json | jq -r '.items[] | select(.metadata.name | test("nginx")).metadata.name'
```

- https://github.com/jqlang/jq
- https://github.com/jqlang/jq/wiki
