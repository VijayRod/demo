`az role definition` is used to manage custom roles.

```
# Replace the below with appropriate values.
roleName=vijayrod
```

```
# To list the custom roles matching a given name.
az role definition list --custom-role-only -o table | grep $roleName

# To create a file with the role definition. Replace the values in the below as required.
subscriptionId=$(az account show --query id -otsv)
cat > /tmp/mycustomrole.json <<EOF
{
  "Name": "$roleName",
  "IsCustom": true,
  "Description": "Can list clusters",
  "Actions": [
    "Microsoft.ContainerService/containerServices/read",
    "Microsoft.ContainerService/managedClusters/read"
  ],
  "NotActions": [
  ],
  "AssignableScopes": [
    "/subscriptions/$subscriptionId"
  ]
}
EOF
cat /tmp/mycustomrole.json

# To update the role definition of an existing custom role.
az role definition update --role-definition /tmp/mycustomrole.json

# To assign the custom role.
az role assignment create --assignee $appId --role $roleName
```

https://learn.microsoft.com/en-us/azure/role-based-access-control/resource-provider-operations
