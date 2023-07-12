The steps mentioned [here](security-encrypt-diskencryptionset_osdisk.md) are used to create a cluster with an ephemeral OS disk. However, this process fails, and the following self-explanatory message is displayed:

```
az aks create -g $rgname -n $clustername --node-osdisk-diskencryptionset-id $diskEncryptionSetId --node-osdisk-type Ephemeral

# Here is a sample output below.
# The behavior of this command has been altered by the following extension: aks-preview
# (EphemeralOSAndBYOKNotSupported) BYOK and Ephemeral OS disk can not be combined in Azure. Disable ephemeral OS disk or disable BYOK.
# Code: EphemeralOSAndBYOKNotSupported
# Message: BYOK and Ephemeral OS disk can not be combined in Azure. Disable ephemeral OS disk or disable BYOK.
```

Additional information can be found at this link: [AKS/issues/2569](https://github.com/Azure/AKS/issues/2569).
