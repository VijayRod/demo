A kubernetes secret object is automatically created for a dynamically created azureblob-fuse PVC. This object has a naming convention `azure-storage-account-<storageAccountName>-secret`. Such an object must be manually created for a static PVC. Regardless of the creation method, this object contains the storage account name and the key.

```
# kubectl get secret
NAME                                                   TYPE     DATA   AGE
azure-storage-account-fusea5e2a60b1f5b42c08bb-secret   Opaque   2      41s

# kubectl get secret -oyaml azure-storage-account-fusea5e2a60b1f5b42c08bb-secret
apiVersion: v1
data:
  azurestorageaccountkey: redacted==
  azurestorageaccountname: ZnVzZWE1ZTJhNjBiMWY1YjQyYzA4YmI=
kind: Secret
metadata:
  creationTimestamp: "2023-08-01T17:39:35Z"
  name: azure-storage-account-fusea5e2a60b1f5b42c08bb-secret
  namespace: default
  resourceVersion: "3641957"
  uid: 65ea9e9d-0dd3-4aea-a2a4-2d0a86cfaa63
type: Opaque
```

The values of both the azurestorageaccountkey and the azurestorageaccountname can be verified with a base64 conversion.

```
# echo -n 'ZnVzZWE1ZTJhNjBiMWY1YjQyYzA4YmI=' | base64 --decode ;echo
fusea5e2a60b1f5b42c08bb
```

- https://learn.microsoft.com/en-us/troubleshoot/azure/azure-kubernetes/mounting-azure-blob-storage-container-fail#cause1-for-blobfuse-error2
