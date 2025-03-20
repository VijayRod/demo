```
# blob.container.create
az storage container create --name backups --account-name $storage --auth-mode login

# blob.container.upload tbd
az role assignment create --assignee <SEU_USER_ID> --role "Storage Blob Data Owner" --scope $storageId
az storage blob upload --account-name $storage --container-name backups --name cron.deny --file /etc/cron.deny --auth-mode login
```
