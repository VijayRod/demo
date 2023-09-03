```
rg=rg
az group create -n $rg -l swedencentral
az aks create -g $rg -n aks --enable-image-cleaner
az aks get-credentials -g $rg -n aks --overwrite-existing
```

```
kubectl get po -n kube-system -owide --show-labels | grep eraser

eraser-aks-nodepool1-16109745-vmss000000-tbr6v   0/3     Completed   0          21m   10.244.2.2   aks-nodepool1-16109745-vmss000000   <none>           <none>            eraser.sh/type=collector
eraser-aks-nodepool1-16109745-vmss000001-6xzhj   0/3     Completed   0          21m   10.244.1.6   aks-nodepool1-16109745-vmss000001   <none>           <none>            eraser.sh/type=collector
eraser-aks-nodepool1-16109745-vmss000002-549c9   0/3     Completed   0          21m   10.244.0.8   aks-nodepool1-16109745-vmss000002   <none>           <none>            eraser.sh/type=collector
eraser-controller-manager-56dd6fb668-kt86p       1/1     Running     0          21m   10.244.1.3   aks-nodepool1-16109745-vmss000001   <none>           <none>            app.kubernetes.io/name=image-cleaner,control-plane=controller-manager,kubernetes.azure.com/managedby=aks,pod-template-hash=56dd6fb668

kubectl get crd | grep eraser

imagejobs.eraser.sh                              2023-09-03T04:59:16Z
imagelists.eraser.sh                             2023-09-03T04:59:16Z
```

```
kubectl logs -n kube-system -l app.kubernetes.io/name=image-cleaner --timestamps=true

2023-09-03T04:59:19.926630979Z {"level":"info","ts":1693717159.926523,"logger":"controller","msg":"Started collector pod on node","process":"imagejob-controller","job":"imagejob-7lwx4","node":"aks-nodepool1-16109745-vmss000000","nodeName":"aks-nodepool1-16109745-vmss000000"}
2023-09-03T04:59:19.937577009Z {"level":"info","ts":1693717159.9374745,"logger":"controller","msg":"Started collector pod on node","process":"imagejob-controller","job":"imagejob-7lwx4","node":"aks-nodepool1-16109745-vmss000001","nodeName":"aks-nodepool1-16109745-vmss000001"}
2023-09-03T04:59:19.948695740Z {"level":"info","ts":1693717159.9486194,"logger":"controller","msg":"Started collector pod on node","process":"imagejob-controller","job":"imagejob-7lwx4","node":"aks-nodepool1-16109745-vmss000002","nodeName":"aks-nodepool1-16109745-vmss000002"}
2023-09-03T05:00:34.054522506Z {"level":"info","ts":1693717234.054272,"logger":"controller","msg":"ImageCollector Reconcile","process":"imagecollector-controller"}
2023-09-03T05:00:34.054550406Z {"level":"info","ts":1693717234.0543377,"logger":"controller","msg":"completed phase","process":"imagecollector-controller"}
2023-09-03T05:00:34.059744108Z {"level":"info","ts":1693717234.059667,"logger":"controller","msg":"done reconcile","process":"imagecollector-controller"}
2023-09-03T05:00:34.059839008Z {"level":"info","ts":1693717234.0597978,"logger":"controller","msg":"ImageCollector Reconcile","process":"imagecollector-controller"}
2023-09-03T05:00:34.059936408Z {"level":"info","ts":1693717234.0598683,"logger":"controller","msg":"completed phase","process":"imagecollector-controller"}
2023-09-03T05:00:34.060015508Z {"level":"info","ts":1693717234.059903,"logger":"controller","msg":"Delaying imagejob delete","process":"imagecollector-controller","job":"imagejob-7lwx4","deleteAter":"2023-09-03 05:10:34 +0000 UTC"}
2023-09-03T05:00:34.060021408Z {"level":"info","ts":1693717234.0599709,"logger":"controller","msg":"done reconcile","process":"imagecollector-controller"}

kubectl get imagejobs

NAME             AGE
imagejob-7lwx4   7m11s

kubectl describe imagejobs
Name:         imagejob-7lwx4
Namespace:
Labels:       eraser.sh/job-owner=imagecollector
Annotations:  <none>
API Version:  eraser.sh/v1
Kind:         ImageJob
Metadata:
  Creation Timestamp:  2023-09-03T04:59:19Z
  Generate Name:       imagejob-
  Generation:          1
  Resource Version:    529132
  UID:                 cc2b63a1-6657-4b93-ac0a-4fec5eb2e7fa
Status:
  Delete After:  2023-09-03T05:10:34Z
  Desired:       3
  Failed:        0
  Phase:         Completed
  Skipped:       0
  Succeeded:     3
Events:          <none>

kubectl logs -n kube-system eraser-aks-nodepool1-16109745-vmss000000-654s6 --timestamps=true

Defaulted container "collector" out of: collector, remover, trivy-scanner
2023-09-03T04:59:20.609590885Z {"level":"info","ts":1693717160.6094682,"logger":"collector","msg":"images collected","finalImages:":[{"image_id":"sha256:redacted","names":["mcr.microsoft.com/oss/kubernetes/kube-state-metrics:v2.9.2"]},{"image_id":"sha256:redacted","names":...

kubectl get imagelists

No resources found
```

```
az aks update -g $rg -n aks --enable-image-cleaner
az aks update -g $rg -n aks --image-cleaner-interval-hours 48 # default 24
az aks update -g $rg -n aks --disable-image-cleaner
```

- https://learn.microsoft.com/en-us/azure/aks/image-cleaner
