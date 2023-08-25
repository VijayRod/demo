```
rgname=testshack3
loc=swedencentral
clustername=akskeda

az group create -g $rgname -l $loc
az aks create -g $rgname -n $clustername --enable-keda 
# az aks update -g $rgname -n $clustername --enable-keda
```

```
az aks show -g $rgname -n $clustername --query "workloadAutoScalerProfile.keda"

{
  "enabled": true
}

az aks get-credentials -g $rgname -n $clustername --overwrite-existing
kubectl get pods -n kube-system | grep keda

keda-operator-68cdb5d644-kfq9v                     1/1     Running   0          108s
keda-operator-68cdb5d644-l8hj8                     1/1     Running   0          108s
keda-operator-metrics-apiserver-6c6459c987-9jpn4   1/1     Running   0          108s
keda-operator-metrics-apiserver-6c6459c987-zx4s6   1/1     Running   0          108s

kubectl get crd | grep keda.sh

clustertriggerauthentications.keda.sh            2023-08-24T12:04:55Z
scaledjobs.keda.sh                               2023-08-24T12:04:55Z
scaledobjects.keda.sh                            2023-08-24T12:04:55Z
triggerauthentications.keda.sh                   2023-08-24T12:04:55Z

kubectl get crd/scaledobjects.keda.sh -o yaml | grep version

    app.kubernetes.io/version: 2.9.3
    
# To cleanup
az aks update -g $rgname -n $clustername --disable-keda
```
    
- https://learn.microsoft.com/en-us/azure/aks/keda-about
