```
kubectl describe pod quick-start | grep token
      AZURE_FEDERATED_TOKEN_FILE:  /var/run/secrets/azure/tokens/azure-identity-token
```

```
# kubectl get sa workload-identity-sa
kubectl create token workload-identity-sa
```
