```
kubectl delete po nginx
kubectl run nginx --image=nginx --overrides='{"spec": { "nodeSelector": {"kubernetes.azure.com/agentpool": "confcompool1"}}}'
kubectl get po -owide # Running
```

- https://github.com/Azure-Samples/confidential-computing/tree/main/containersamples
