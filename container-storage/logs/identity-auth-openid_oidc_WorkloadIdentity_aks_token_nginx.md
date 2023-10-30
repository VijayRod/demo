```
kubectl delete po nginx
kubectl delete sa sa
kubectl create sa sa
cat << EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: nginx
  namespace: default # service account namespace
  labels:
    azure.workload.identity/use: "true" # label
spec:
  containers:
  - image: nginx
    name: nginx
    resources: {}
  dnsPolicy: ClusterFirst
  restartPolicy: Always
  serviceAccountName: sa # service account
EOF
sleep 10
kubectl get po nginx
kubectl describe po nginx | grep token # AZURE_FEDERATED_TOKEN_FILE:  /var/run/secrets/azure/tokens/azure-identity-token
kubectl exec -it nginx -- cat /var/run/secrets/azure/tokens/azure-identity-token # ey...
```

- https://kubernetes.io/docs/tasks/configure-pod-container/configure-service-account/
