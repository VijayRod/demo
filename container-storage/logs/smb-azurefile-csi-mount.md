```
rg=rg
az group create -n $rg -l swedencentral
az aks create -g $rg -n aks
az aks get-credentials -g $rg -n aks --overwrite-existing
kubectl apply -f https://raw.githubusercontent.com/kubernetes-sigs/azurefile-csi-driver/master/deploy/example/pvc-azurefile-csi.yaml
kubectl apply -f https://raw.githubusercontent.com/kubernetes-sigs/azurefile-csi-driver/master/deploy/example/nginx-pod-azurefile.yaml

kubectl get po nginx-azurefile
kubectl get pvc pvc-azurefile
kubectl get pv

kubectl exec nginx-azurefile -- ls -l /mnt/azurefile
total 15
-rwxrwxrwx 1 root root 14728 Sep  1 19:12 outfile
```

- https://github.com/kubernetes-sigs/azurefile-csi-driver/blob/master/pkg/azurefile/azurefile.go
- https://github.com/Azure/AKS/tree/master/vhd-notes
- https://github.com/kubernetes-sigs/azurefile-csi-driver/blob/master/docs/csi-debug.md
- https://learn.microsoft.com/en-us/azure/aks/azure-files-csi
- https://learn.microsoft.com/en-us/azure/aks/concepts-storage#azure-files
- https://github.com/kubernetes-sigs/azurefile-csi-driver/tree/master/deploy/example
- https://github.com/kubernetes/examples/blob/master/staging/volumes/azure_file/README.md
- https://learn.microsoft.com/en-us/azure/aks/concepts-storage#azure-files
- https://cloud-provider-azure.sigs.k8s.io/faq/known-issues/azurefile/
- https://learn.microsoft.com/en-us/troubleshoot/azure/azure-storage/files-troubleshoot: TCP 445
