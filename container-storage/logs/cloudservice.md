```
rg=rg
az group create -n $rg -l $loc
# Blob SAS URL of cspkg after uploading to a storage account container
packageUrl="https://stor1204.blob.core.windows.net/mycontainer/ContosoCS.cspkg?sp=r&st=..."
TBD (403 Forbidden) az cloud-service create -g $rg -n cs --roles ContosoFrontend:Standard_D1_v2:1:Standard ContosoBackend:Standard_D1_v2:1:Standard --package-url $packageUrl
```

```
TBD az cloud-service show -g $rg -n cs
```

- https://azure.microsoft.com/en-us/products/cloud-services/
- https://github.com/Azure-Samples/cloud-services-extended-support: Has sample files (cspkg, cscfg, csdef) that can be uploaded to a storage account container.
- https://learn.microsoft.com/en-us/azure/cloud-services-extended-support/sample-create-cloud-service
- https://learn.microsoft.com/en-us/azure/cloud-services/cloud-services-how-to-create-deploy-portal
- https://learn.microsoft.com/en-us/cli/azure/cloud-service
- https://techcommunity.microsoft.com/t5/azure-paas-blog/how-to-use-azure-devops-to-publish-cloud-service-extended/ba-p/3675180
