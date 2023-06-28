The "FeatureNotSupportedForAccount" error during the creation of an Azure file share is due to not adhering to the requirements mentioned in the following link: https://learn.microsoft.com/en-us/azure/storage/files/storage-how-to-create-file-share?tabs=azure-portal#create-a-storage-account. For example, in the code snippet provided, the error occurs because the "StorageV2" type of storage account allows to deploy the "Standard_LRS" SKU, the "FileStorage" type allows the "Premium_LRS" SKU.

```
# Replace the below with appropriate values.
rgname=
storageAccountName="mystorageacct$RANDOM"
```

```
# Create a storage account with the "Premium_LRS" SKU.
az storage account create -g $rgname -n $storageAccountName --kind StorageV2 --sku Premium_LRS --enable-large-file-share --output none
```

```
# Create a file share in the storage account.
az storage share-rm create -g $rgname --storage-account $storageAccountName -n $shareName --quota 1024 --enabled-protocols SMB --output none

# Here is a sample output below.
# (FeatureNotSupportedForAccount) File is not supported for the account.
# Code: FeatureNotSupportedForAccount
# Message: File is not supported for the account.
```

```
# Cleanup.
az storage account delete -g $rgname -n $storageAccountName -y
```

```
# The following code, which utilizes "FileStorage" and "Premium_LRS", is successful.
az storage account create -g $rgname -n $storageAccountName --kind FileStorage --sku Premium_LRS --enable-large-file-share --output none
# az storage account create -g $rgname -n $storageAccountName --kind StorageV2 --sku Standard_LRS --enable-large-file-share --output none
az storage share-rm create -g $rgname --storage-account $storageAccountName -n $shareName --quota 1024 --enabled-protocols SMB --output none

# View the created file share.
az storage share-rm list -g $rgname --storage-account $storageAccountName -otable
```
