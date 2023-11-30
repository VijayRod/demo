```
kubectl get po -n kube-system -l k8s-app=coredns-autoscaler

kubectl describe cm -n kube-system coredns-autoscaler
Name:         coredns-autoscaler
Namespace:    kube-system
Labels:       <none>
Annotations:  <none>
Data
====
ladder:
----
{"coresToReplicas":[[1,2],[512,3],[1024,4],[2048,5]],"nodesToReplicas":[[1,2],[8,3],[16,4],[32,5]]}
BinaryData
====
Events:  <none>

kubectl get configmap coredns-autoscaler -n kube-system -o yaml
apiVersion: v1
data:
  ladder: '{"coresToReplicas":[[1,2],[512,3],[1024,4],[2048,5]],"nodesToReplicas":[[1,2],[8,3],[16,4],[32,5]]}'
kind: ConfigMap
metadata:
  creationTimestamp: "2023-09-08T20:59:36Z"
  name: coredns-autoscaler
  namespace: kube-system
  resourceVersion: "1069"
  uid: 96464cfe-6b07-46c6-b140-336f70f95ea4
```

- https://github.com/coredns/coredns/issues/3388: The coredns pods always restart because of OOMKilled. In kubernetes, CoreDNS memory usage primarily correlates to the number of services/endpoints in the cluster...
- https://coredns.io/2018/11/15/scaling-coredns-in-kubernetes-clusters/: CoreDNS’s memory usage is predominantly affected by the number of Pods and Services in the cluster
- https://learn.microsoft.com/en-us/azure/aks/coredns-custom#configure-coredns-pod-scaling: Sudden spikes in DNS traffic... Out of memory issues
- TBD https://creators-note.chatwork.com/entry/stabilize-kubernetes-dns: Deploy dns-autoscaler
