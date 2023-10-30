```
fqdn=redacted.hcp.swedencentral.azmk8s.io
kubectl create sa k8sadmin
token=$(kubectl create token k8sadmin)
curl --header "Authorization: Bearer $token" https://$fqdn -k # ok
# kubectl delete sa k8sadmin
```

- https://kubernetes.io/docs/tasks/configure-pod-container/configure-service-account/#manually-create-an-api-token-for-a-serviceaccount
