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

## k8s-secret.op

```
# secret.op.delete.garbage-collector.example
# Tip for delete RCA: Find the k8s object with the UID (it may not be available, for example, if there was a pod or node scale down or delete, unless the creation was within the data retention time).

kubectl create deploy webapp --image=nginx
kubectl get deploy webapp -n default -o jsonpath='{.metadata.uid}' # replace the value below
# kubectl get deploy webapp -n default -o yaml | yq '.metadata.uid'
# kubectl get deploy webapp -n default -o yaml | grep uid:

cat << EOF | kubectl create -f -
apiVersion: v1
kind: Secret
metadata:
  name: webapp-credentials
  namespace: default
  ownerReferences:
  - apiVersion: apps/v1
    kind: Deployment
    name: webapp
    uid: 859ef882-bdb0-4d08-9d19-e217d9422d41 # replace the uid here
    controller: true
    blockOwnerDeletion: true
type: Opaque
data:
  username: dXNlcg==   # base64 de 'user'
  password: cGFzc3dvcmQ= # base64 de 'password'
EOF
kubectl get secret # webapp-credentials

kubectl delete deploy webapp
kubectl get secret # no entries found

# k get sa -n kube-system | grep garb # generic-garbage-collector                     0         3d7h
```

- tbd https://overcast.blog/kubernetes-garbage-collection-a-practical-guide-22a5c7125257: Automate Garbage Collection Processes. Secrets that are no longer in use.

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

> ## secret.tls

```
# cert create

mkdir cert
cd cert
openssl req -x509 -newkey rsa:2048 -keyout tls.key -out tls.crt -days 365 -nodes -subj "/CN=example.com"
ls # tls.crt  tls.key

cat tls.crt | base64 -w0  # -w0 para não ter quebras de linha
cat tls.key | base64 -w0

kubectl create secret tls tls-secret --cert=./tls.crt --key=./tls.key
# kubectl get secret tls-secret -oyaml # type: kubernetes.io/tls

TLS_CRT=$(kubectl get secret tls-secret -o jsonpath="{.data.tls\.crt}" | base64 -d) # echo "$TLS_CRT" > tls.crt
TLS_KEY=$(kubectl get secret tls-secret -o jsonpath="{.data.tls\.key}" | base64 -d) # echo "$TLS_KEY" > tls.key
```

```
# pod mount secret

kubectl delete po mypod
cat << EOF | kubectl create -f -
apiVersion: v1
kind: Pod
metadata:
  name: mypod
spec:
  containers:
    - name: app
      image: nginx
      volumeMounts:
        - name: tls-volume
          mountPath: /etc/tls
          readOnly: true
  volumes:
    - name: tls-volume
      secret:
        secretName: tls-secret
EOF
kubectl get po -owide -w

kubectl exec -it mypod -- /bin/sh
ls /etc/tls
cat /etc/tls/tls.crt

cd /var/lib/kubelet/pods/17652a02-b389-481f-af9f-efe39ab5f520/volumes/kubernetes.io~secret/tls-volume
ls # tls.crt  tls.key
```

> ## secret.tls.synchronize

```
# Refer to the secret store driver
```
