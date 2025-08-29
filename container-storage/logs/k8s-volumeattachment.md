```
# refer to csi azuredisk
# mitigate pod mount failure caused by unattached disk: kubectl delete volumeattachment

kubectl get volumeattachment
kubectl patch volumeattachment csi-234sdf -p '{"metadata":{"finalizers":null}}'
```

- https://kubernetes.io/docs/reference/kubernetes-api/config-and-storage-resources/volume-attachment-v1/
