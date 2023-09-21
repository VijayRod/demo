TBD (success)

```
rg=rgauth
az group create -n $rg -l $loc
az aks create -g $rg -n aks -s $vmsize -c 1

roleName= # Add role name here
subId=$(az account show --query id -otsv)
cat > /tmp/mycustomrole.json <<EOF
{
  "Name": "$roleName",
  "IsCustom": true,
  "Description": "Can list clusters",
  "Actions": [
    "*"
  ],
  "NotActions": [
    "Microsoft.Network/virtualNetworks/write"
  ],
  "AssignableScopes": [
    "/subscriptions/$subId"
  ]
}
EOF
cat /tmp/mycustomrole.json
az role definition update --role-definition /tmp/mycustomrole.json

spName="mysp$RANDOM"
spPassword=$(az ad sp create-for-rbac --name $spName --query password -o tsv)
sleep 30
appId=$(az ad sp list --display-name $spName --query "[].appId" -o tsv)
objectId=$(az ad sp list --display-name $spName --query "[].id" -o tsv)
tenantId=$(az account show --query tenantId -otsv)
echo $appId

az role assignment create --assignee $appId --role $roleName
az role assignment create --assignee $objectId --role "Reader" --scope /subscriptions/$subId
az login --service-principal --username $appId --password $spPassword --tenant $tenantId
# az aks scale -g $rg -n aks -c1
# az logout
```

```
az group delete -n $rg -y --no-wait
az ad sp delete --id $appId
```
