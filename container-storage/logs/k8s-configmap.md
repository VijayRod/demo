```
# cm.create

cat <<EOF >/tmp/example-redis-config.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: example-redis-config
data:
  redis-config: ""
EOF
kubectl create cm redis --from-file=/tmp/example-redis-config.yaml

kubectl create configmap app-config \
  --from-literal=ENV=production \
  --from-literal=DEBUG=false
```

```
# cm.get

kubectl get cm --output=custom-columns=NAME:.metadata.name,CREATE_TIMESTAMP:.metadata.creationTimestamp

kubectl get cm redis
NAME    DATA   AGE
redis   1      10s

kubectl get cm redis -oyaml
apiVersion: v1
data:
  example-redis-config.yaml: |
    apiVersion: v1
    kind: ConfigMap
    metadata:
      name: example-redis-config
    data:
      redis-config: ""
kind: ConfigMap
metadata:
  creationTimestamp: "2023-10-26T19:21:53Z"
  name: redis
  namespace: default
  resourceVersion: "102141"
  uid: ceee0ed6-e4c2-4c5c-a3b0-5c8ec4869902
  
kubectl describe cm redis
Name:         redis
Namespace:    default
Labels:       <none>
Annotations:  <none>
Data
====
example-redis-config.yaml:
----
apiVersion: v1
kind: ConfigMap
metadata:
  name: example-redis-config
data:
  redis-config: ""
BinaryData
====
Events:  <none>
```

- https://kubernetes.io/docs/concepts/configuration/configmap/
- https://kubernetes.io/docs/tasks/configure-pod-container/configure-pod-configmap/
- https://kubernetes.io/docs/tutorials/configuration/configure-redis-using-configmap/
- https://kubernetes.io/docs/concepts/configuration/secret/: Secrets are similar to ConfigMaps but are specifically intended to hold confidential data.
