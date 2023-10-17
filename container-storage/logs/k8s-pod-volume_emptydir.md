```
kubectl delete po test-pod
cat << EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: test-pod
spec:
  containers:
  - image: registry.k8s.io/test-webserver
    name: test-container
    volumeMounts:
    - mountPath: /cache
      name: cache-volume
  volumes:
  - name: cache-volume
    emptyDir:
      sizeLimit: 500Mi
EOF
sleep 5
kubectl get po test-pod
```

- https://kubernetes.io/docs/concepts/storage/volumes/#emptydir
- https://github.com/kubernetes/kubernetes/issues/112630#issuecomment-1762220209: EmptyDir not being cleaned up after pod terminated with open file handles
