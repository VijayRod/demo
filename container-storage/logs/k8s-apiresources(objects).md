## k8s-apiresources

```
kubectl api-resources
```

## k8s-apiresources.metadata.ownerReferences

```
kubectl create deploy nginx --image=nginx --replicas=1
sleep 10

kubectl get po -l app=nginx -oyaml # | grep ownerReferences
items:
- apiVersion: v1
  kind: Pod
  metadata:
    creationTimestamp: "2024-10-10T21:36:03Z"
    generateName: nginx-7854ff8877-
    labels:
      app: nginx
      pod-template-hash: 7854ff8877
    name: nginx-7854ff8877-sbp8k
    namespace: default
    ownerReferences:
    - apiVersion: apps/v1
      blockOwnerDeletion: true
      controller: true
      kind: ReplicaSet
      name: nginx-7854ff8877
      uid: bfcf4107-31d9-4790-917d-52500a9a4dba
    resourceVersion: "176104"
    uid: 752f21d2-c2ba-43b6-9d5f-db1de65bed62
  spec:
```

- https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.23/: ownerReferences
- https://kubernetes.io/docs/concepts/overview/working-with-objects/owners-dependents/
- https://kubernetes.io/docs/concepts/architecture/garbage-collection/
