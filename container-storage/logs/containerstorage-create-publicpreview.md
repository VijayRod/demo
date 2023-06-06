TBD: 

If you have not [signed up](https://azure.microsoft.com/en-us/updates/public-preview-azure-container-storage/) for the public preview, there will be no rows returned for the command below. Please follow the create steps in [this link](containerstorage-create.md).

To check the supported container storage API versions, you can run the following command:

```
# https://learn.microsoft.com/en-us/azure/storage/container-storage/use-container-storage-with-managed-disks
kubectl api-versions | grep containerstorage
```

Please note that the output of the command will only display rows if you are signed up for the public preview.
