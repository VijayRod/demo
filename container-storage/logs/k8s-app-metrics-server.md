
```
kubectl logs -n kube-system k8s-app=metrics-server
kubectl -n kube-system delete po -l k8s-app=metrics-server
```

```
# kubectl top po -n kube-system | grep metr
NAME                                  CPU(cores)   MEMORY(bytes)
metrics-server-5dd7f7965f-6srpn       3m           43Mi
metrics-server-5dd7f7965f-ng5hr       3m           47Mi
```

- https://learn.microsoft.com/en-us/azure/aks/use-metrics-server-vertical-pod-autoscaler
