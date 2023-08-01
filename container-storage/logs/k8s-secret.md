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

# echo -n 'bXl1c2VybmFtZQ==' | base64 --decode
myusername

# echo -n 'myusername' | base64
bXl1c2VybmFtZQ==

# kubectl edit secret db-user-pass -oyaml
```

- https://kubernetes.io/docs/tasks/configmap-secret/managing-secret-using-kubectl/
