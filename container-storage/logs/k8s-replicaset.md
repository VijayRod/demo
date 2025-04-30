> ## k8s-replicaset

- https://kubernetes.io/docs/concepts/workloads/controllers/replicaset/
- https://kubernetes.io/docs/concepts/workloads/controllers/deployment/: ReplicaSet

```
# create

kubectl delete deploy foo
kubectl create deployment foo --image=nginx --replicas=3
k get deploy -w

kubectl delete rs foo
cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: ReplicaSet
metadata:
  name: foo
spec:
  replicas: 3
  selector:
    matchLabels:
      app: foo
  template:
    metadata:
      labels:
        app: foo
    spec:
      containers:
      - name: nginx
        image: nginx
EOF
k get rs -w
```

```
# describe

k describe rs foo
Name:         foo
Namespace:    default
Selector:     app=foo
Labels:       <none>
Annotations:  <none>
Replicas:     3 current / 3 desired
Pods Status:  3 Running / 0 Waiting / 0 Succeeded / 0 Failed
Pod Template:
  Labels:  app=foo
  Containers:
   nginx:
    Image:         nginx
    Port:          <none>
    Host Port:     <none>
    Environment:   <none>
    Mounts:        <none>
  Volumes:         <none>
  Node-Selectors:  <none>
  Tolerations:     <none>
Events:
  Type    Reason            Age   From                   Message
  ----    ------            ----  ----                   -------
  Normal  SuccessfulCreate  15s   replicaset-controller  Created pod: foo-p2cwk
  Normal  SuccessfulCreate  15s   replicaset-controller  Created pod: foo-xxl5v
  Normal  SuccessfulCreate  15s   replicaset-controller  Created pod: foo-5c6nx
```

```
# scale

kubectl scale --replicas=3 rs/foo
```

- https://kubernetes.io/docs/reference/kubectl/generated/kubectl_scale/

> ## k8s-replicaset.replicationcontroller

- https://kubernetes.io/docs/concepts/workloads/controllers/replicationcontroller/
