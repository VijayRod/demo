```
rg=rgblob
az group create -n $rg -l $loc
az aks create -g $rg -n aks --enable-blob-driver
az aks get-credentials -g $rg -n aks --overwrite-existing
kubectl get no

kubectl describe ds csi-blob-node -n kube-system
  Init Containers:
   install-blobfuse-proxy:
    Image:      mcr.microsoft.com/oss/kubernetes-csi/blob-csi:v1.21.4
    Port:       <none>
    Host Port:  <none>
    Command:
      /blobfuse-proxy/init.sh
    Environment:
      DEBIAN_FRONTEND:        noninteractive
      INSTALL_BLOBFUSE:       false
      BLOBFUSE_VERSION:       1.4.4

root@aks-nodepool1-40777476-vmss000000:/# blobfuse2 -v
blobfuse2 version 2.0.5
root@aks-nodepool1-40777476-vmss000000:/# blobfuse
blobfuse: command not found
```

- https://github.com/kubernetes-sigs/blob-csi-driver/tree/master#install-driver-on-a-kubernetes-cluster: kubectl patch daemonset csi-blob-node -n kube-system -p '{"spec":{"template":{"spec":{"initContainers":[{"env":[{"name":"INSTALL_BLOBFUSE2","value":"true"},{"name":"BLOBFUSE2_VERSION","value":"2.0.5"}],"name":"install-blobfuse-proxy"}]}}}}'
- https://github.com/Azure/AKS/blob/master/vhd-notes/aks-ubuntu/AKSUbuntu-2204/202308.16.0.txt: blobfuse2/jammy,now 2.0.5 amd64 [installed]
