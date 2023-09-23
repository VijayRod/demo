By default, events are retained for [1 hour](https://github.com/kubernetes/kubernetes/blob/da53a247633cd91bd8e9818574279f3b04aed6a5/cmd/kube-apiserver/app/options/options.go#L71-L72).

```
# To monitor pod events.
kubectl get events --watch --field-selector involvedObject.kind=Pod
```

- https://stackoverflow.com/questions/68797633/how-to-kubectl-get-event-of-node-not-pod
- https://kubernetes.io/docs/reference/kubernetes-api/cluster-resources/event-v1/
