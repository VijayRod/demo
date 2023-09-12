```
kubectl run nginx --image=nginx
kubectl expose po nginx --port=80 --type=LoadBalancer
kubectl patch svc nginx -p '{"spec":{"externalTrafficPolicy":"Local"}}' # Changing externalTrafficPolicy from 'cluster' (default)
kubectl get svc nginx
kubectl describe svc nginx | grep External
```

```
kubectl delete svc nginx
kubectl delete po nginx
```

- https://kubernetes.io/docs/reference/networking/virtual-ips/#external-traffic-policy
- https://github.com/kubernetes/kubernetes/issues/51255#issuecomment-346967750
- https://github.com/nginxinc/kubernetes-ingress/issues/1199#issuecomment-712944309
- https://github.com/nginxinc/kubernetes-ingress/issues/1199#issuecomment-713187084
