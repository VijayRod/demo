```
kubectl get po nginx -oyaml

kubectl get po nginx -ojson
kubectl get po nginx -ojsonpath={.spec.dnsPolicy}
```

- https://kubernetes.io/docs/reference/kubectl/jsonpath/
