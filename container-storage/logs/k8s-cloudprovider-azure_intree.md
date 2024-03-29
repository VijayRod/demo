```
# To count the number of in-tree volumes for AzureDisk and AzureFile
kubectl get pv -o yaml | grep azureDisk | wc -l
kubectl get pv -o yaml | grep azureFile | wc -l
```

- https://learn.microsoft.com/en-us/azure/aks/csi-migrate-in-tree-volumes
- https://github.com/kubernetes/kubernetes/tree/v1.13.0/pkg/cloudprovider/providers/azure
- https://github.com/kubernetes-sigs/azurefile-csi-driver/blob/master/docs/design.md: To prevent possible regression issues, azurefile CSI driver use azure cloud provider library. Thus, all bug fixes in the built-in azure file plugin would be incorporated into this driver.
- https://github.com/kubernetes-sigs/blob-csi-driver/blob/master/docs/design.md: To prevent possible regression issues, Azure Blob Storage CSI driver use azure cloud provider library. Thus, all bug fixes in the built-in blobfuse plugin would be incorporated into this driver.
- https://learn.microsoft.com/en-us/azure/aks/csi-storage-drivers: Starting with Kubernetes version 1.26, in-tree persistent volume types kubernetes.io/azure-disk and kubernetes.io/azure-file are deprecated and will no longer be supported. ...you should migrate to the corresponding CSI drivers disk.csi.azure.com and file.csi.azure.com.
