```
# Replace the below with appropriate values
rgname=
clustername=akskube
```

```
# Create an AKS cluster with Kubenet network plugin
az aks create -g $rgname -n $clustername --enable-pod-identity --enable-pod-identity-with-kubenet
```
