```
kubectl get -n kube-system cm eraser-system-exclusion -o yaml

apiVersion: v1
data:
  system-exclusion.json: |
    {
      "excluded": [
        "mcr.microsoft.com/oss/kubernetes/pause:*"
      ]
    }
```

- https://learn.microsoft.com/en-us/azure/aks/image-cleaner#image-exclusion-list
