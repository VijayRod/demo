Events aren’t saved to the Kubernetes logs and usually get deleted after only an hour, although this is configurable with the –event-ttl flag when you start the Kubernetes API server. It’s best to stream events to a dedicated observability tool so you can retain them for longer time periods and get alerted to failures.

```
kubectl describe po nginx

kubectl get events
kubectl get events -n default
kubectl get events -l run=nginx -A
kubectl get events -w
```

- https://kubernetes.io/docs/reference/command-line-tools-reference/kube-apiserver/: --event-ttl duration     Default: 1h0m0s. Amount of time to retain events.
- https://github.com/kubernetes/kubernetes/issues/52521
