```
rgname=rgkeda
clustername=aks

az group create -g $rgname -l $loc
az aks create -g $rgname -n $clustername --enable-keda
az aks get-credentials -g $rgname -n $clustername --overwrite-existing
# az aks update -g $rgname -n $clustername --enable-keda
# az aks update -g $rgname -n $clustername --disable-keda
```

```
az aks show -g $rgname -n $clustername --query "workloadAutoScalerProfile.keda"
{
  "enabled": true
}

kubectl get all -n kube-system | grep keda
kube-system   pod/keda-admission-webhooks-7d979d849b-wrwq6           1/1     Running   0               4m21s
kube-system   pod/keda-admission-webhooks-7d979d849b-wwg8h           1/1     Running   0               4m21s
kube-system   pod/keda-operator-7ff6499fd7-pfk2j                     1/1     Running   1 (4m12s ago)   4m21s
kube-system   pod/keda-operator-7ff6499fd7-wb9bt                     1/1     Running   0               4m21s
kube-system   pod/keda-operator-metrics-apiserver-7f4f645876-s8chd   1/1     Running   0               4m21s
kube-system   pod/keda-operator-metrics-apiserver-7f4f645876-tt76w   1/1     Running   0               4m21s
kube-system   service/keda-admission-webhooks           ClusterIP   10.0.18.194   <none>        443/TCP          4m22s
kube-system   service/keda-operator                     ClusterIP   10.0.112.93   <none>        9666/TCP         4m22s
kube-system   service/keda-operator-metrics-apiserver   ClusterIP   10.0.29.144   <none>        443/TCP,80/TCP   4m22s
kube-system   deployment.apps/keda-admission-webhooks           2/2     2            2           4m23s
kube-system   deployment.apps/keda-operator                     2/2     2            2           4m23s
kube-system   deployment.apps/keda-operator-metrics-apiserver   2/2     2            2           4m23s
kube-system   replicaset.apps/keda-admission-webhooks-7d979d849b           2         2         2       4m23s
kube-system   replicaset.apps/keda-operator-7ff6499fd7                     2         2         2       4m23s
kube-system   replicaset.apps/keda-operator-metrics-apiserver-7f4f645876   2         2         2       4m23s

kubectl get crd | grep keda.sh
clustertriggerauthentications.keda.sh            2023-08-24T12:04:55Z
scaledjobs.keda.sh                               2023-08-24T12:04:55Z
scaledobjects.keda.sh                            2023-08-24T12:04:55Z
triggerauthentications.keda.sh                   2023-08-24T12:04:55Z

kubectl get crd/scaledobjects.keda.sh -o yaml | grep version
    app.kubernetes.io/version: 2.9.3

kubectl get apiservice | grep keda
v1alpha1.keda.sh                       Local                                         True        7m43s
v1beta1.external.metrics.k8s.io        kube-system/keda-operator-metrics-apiserver   True        7m43s

kubectl get apiservice v1beta1.external.metrics.k8s.io -o "jsonpath={.status}"
  conditions:
  - lastTransitionTime: "2023-10-03T19:11:57Z"
    message: all checks passed
    reason: Passed
    status: "True"
    type: Available
```
    
- https://learn.microsoft.com/en-us/azure/aks/keda-about
- https://github.com/search?q=repo%3AAzure%2FAKS%20keda&type=code
