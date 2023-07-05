The `az role assignment` command is used to manage both built-in role and custom role assignments for an assignee.

```
# Replace the below with appropriate values.
assignmentResourceGroupName=
objectId=
subId=$(az account show --query id -otsv)
assignmentScope="/subscriptions/$subId/resourceGroups/$assignmentResourceGroupName" ## An alternate scope is "/subscriptions/$subId".
```

```
# To create a role assignment.
az role assignment create --assignee $objectId --role "Contributor" --scope $assignmentScope

# To list a role assignment.
az role assignment list --assignee $objectId --scope $assignmentScope

# To delete a role assignment.
az role assignment delete --assignee $objectId --scope $assignmentScope
```

```
# Additional commands.
az role assignment list --all --assignee $objectId
az role assignment list-changelogs	## The start/end time defaults to -1h and now().
az role assignment list-changelogs --end-time '2000-12-31T12:59:59Z' --start-time '2000-12-31T12:59:59Z'

# To create a role assignment for a kubelet managed identity in AKS.
objectId=$(az aks show -g $rgname -n $clustername --query "identityProfile.kubeletidentity.objectId" -o tsv)
assignmentResourceGroupName=$(az aks show -g $rgname --n $clustername  --query "nodeResourceGroup" -o tsv)
az role assignment create --assignee $objectId --role "Contributor" --scope /subscriptions/$subId/resourceGroups/$assignmentResourceGroupName
```

Here are some related links:
- [azure/role-based-access-control/role-assignments-list-cli](https://learn.microsoft.com/en-us/azure/role-based-access-control/role-assignments-list-cli)
- [azure/role/assignment](https://learn.microsoft.com/en-us/cli/azure/role/assignment?view=azure-cli-latest)
