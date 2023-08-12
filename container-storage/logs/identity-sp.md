`az ad sp` is used to manage service principals.

```
# To create the service principal and retrieve its appId, password, and tenant.
spName="mysp$RANDOM"
spPassword=$(az ad sp create-for-rbac --name $spName --query password -o tsv)

# To retrieve the values
sleep 30
appId=$(az ad sp list --display-name $spName --query "[].appId" -o tsv)
objectId=$(az ad sp list --display-name $spName --query "[].id" -o tsv)
objectId=$(az ad sp show --id $appId --query "id" -o tsv)
tenantId=$(az account show --query tenantId -otsv)

# To view properties of the service principal.
az ad sp list --display-name $spName
az ad sp show --id $appId

# To list your service principals.
az ad sp list --show-mine -otable

# To assign a built-in or custom role.
subId=$(az account show --query id -otsv)
az role assignment create --assignee $appId --role "Contributor" --scope /subscriptions/$subId

# To view the service principal assignments.
az role assignment list --all --assignee $appId

# To login with the service principal after role assignment.
az login --service-principal --username $appId --password $spPassword --tenant $tenantId
az logout ## Then az login to the required account.

# To delete the service principal.
az ad sp delete --id $appId
```

```
# Additional commands.
az ad sp create-for-rbac --name $spName # Note the automatically generated password is displayed.
az ad sp create-for-rbac --name $spName --scopes /subscriptions/$subId/resourceGroups/$rgname
az ad sp create-for-rbac --role Contributor --scopes /subscriptions/$subId
```

```
# Additional commands to retrieve from a JSON file
subId=$(az account show --query id -otsv)
az ad sp create-for-rbac --role Contributor --scopes /subscriptions/$subId -o json > /tmp/auth.json
appId=$(jq -r ".appId" /tmp/auth.json)
password=$(jq -r ".password" /tmp/auth.json)
```

https://learn.microsoft.com/en-us/cli/azure/create-an-azure-service-principal-azure-cli
