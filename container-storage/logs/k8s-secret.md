## k8s-secret

```
# kubectl create secret generic db-user-pass --from-literal=key=myusername --from-literal=pass=mytestpwd
secret/db-user-pass created

# kubectl get secret db-user-pass -oyaml
apiVersion: v1
data:
  key: bXl1c2VybmFtZQ==
  pass: bXl0ZXN0cHdk
kind: Secret
metadata:
  creationTimestamp: "2023-08-01T18:03:14Z"
  name: db-user-pass
  namespace: default
  resourceVersion: "3647932"
  uid: b7ecbb28-37d4-47cc-abfc-70d0c96b3841
type: Opaque

cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Secret
metadata:
 name: aso-credential
 namespace: default
stringData:
 AZURE_SUBSCRIPTION_ID: "$AZURE_SUBSCRIPTION_ID"
 AZURE_TENANT_ID: "$AZURE_TENANT_ID"
 AZURE_CLIENT_ID: "$AZURE_CLIENT_ID"
 AZURE_CLIENT_SECRET: "$AZURE_CLIENT_SECRET"
EOF

# echo -n 'bXl1c2VybmFtZQ==' | base64 --decode
myusername

# echo -n 'myusername' | base64
bXl1c2VybmFtZQ==

# kubectl edit secret db-user-pass -oyaml
```

- https://kubernetes.io/docs/tasks/configmap-secret/managing-secret-using-kubectl/
- https://kubernetes.io/docs/concepts/configuration/secret/#editing-a-secret
<br>

- https://learn.microsoft.com/en-us/troubleshoot/azure/azure-kubernetes/file-share-mount-failures-azure-files: Manually update the azurestorageaccountkey field in an Azure file secret...

## k8s-secret.pod.environment-variable

```
conn="redacted"
kubectl delete secret redis-key -n istio-ns
kubectl delete po consoleapp1 -n istio-ns
kubectl create secret generic redis-key --from-literal=conn=$conn
cat << EOF | kubectl create -f -
apiVersion: v1
kind: Pod
metadata:
  labels:
    run: consoleapp1
  name: consoleapp1
spec:
  containers:
  - image: registry13959.azurecr.io/consoleapp1:latest
    name: consoleapp1
    resources: {}
    env:
    - name: conn
      valueFrom:
        secretKeyRef:
          name: redis-key
          key: conn
  dnsPolicy: ClusterFirst
  restartPolicy: Always
EOF
```

- https://kubernetes.io/docs/concepts/configuration/secret/#using-secrets-as-environment-variables
- https://kubernetes.io/docs/tasks/inject-data-application/distribute-credentials-secure/#define-container-environment-variables-using-secret-data

## k8s-secret.pod.volume

```
conn="redacted"
kubectl create secret generic redis-key --from-literal=conn=$conn
cat << EOF | kubectl create -f -
apiVersion: v1
kind: Pod
metadata:
  labels:
    run: consoleapp1
  name: consoleapp1
spec:
  containers:
  - image: registry13959.azurecr.io/consoleapp1:latest
    name: consoleapp1
    resources: {}
  dnsPolicy: ClusterFirst
  restartPolicy: Always
  volumes:
  - name: redis-key
    secret:
      secretName: redis-key
EOF
```

- https://kubernetes.io/docs/concepts/configuration/secret/
- https://kubernetes.io/docs/tasks/inject-data-application/distribute-credentials-secure/#create-a-pod-that-has-access-to-the-secret-data-through-a-volume
