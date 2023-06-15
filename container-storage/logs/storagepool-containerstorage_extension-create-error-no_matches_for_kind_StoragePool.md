RCA: This error indicates that the custom resource definitions (CRDs) for container storage  are not installed in the cluster. To resolve this issue, you can install the microsoft.azurecontainerstorage extension in this cluster with the `az k8s-extension create` command as indicated [here](containerstorage-create.md).

```
cat << EOF | k apply -f -
apiVersion: containerstorage.azure.com/v1alpha1
kind: StoragePool
metadata:
  name: azuredisk
  namespace: acstor
spec:
  poolType:
    azureDisk: {}
  resources:
    requests: {"storage": 1Ti}
EOF
```

```
error: resource mapping not found for name: "azuredisk" namespace: "acstor" from "STDIN": no matches for kind "StoragePool" in version "containerstorage.azure.com/v1alpha1"
ensure CRDs are installed first
```

Verify if the CRDs are installed by running the following command and checking for output. If you don't see any output, it means the CRDs are not installed.

```
kubectl api-versions | grep containerstorage

# Here is a sample output below.
# containerstorage.azure.com/v1alpha1
```
