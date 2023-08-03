```
# kubectl -n ingress-controller get all
NAME                                  READY   STATUS    RESTARTS   AGE
pod/haproxy-ingress-d47cd45dc-jjvq6   1/1     Running   0          52s
NAME                      TYPE           CLUSTER-IP   EXTERNAL-IP    PORT(S)                      AGE
service/haproxy-ingress   LoadBalancer   10.0.68.14   20.240.25.48   80:30941/TCP,443:32251/TCP   6m26s
NAME                              READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/haproxy-ingress   1/1     1            1           6m26s
NAME                                        DESIRED   CURRENT   READY   AGE
replicaset.apps/haproxy-ingress-d47cd45dc   1         1         1       6m26s

# kubectl -n ingress-controller describe po
  Normal  Pulling    44s   kubelet            Pulling image "quay.io/jcmoraisjr/haproxy-ingress:v0.14.4"
```

```
# kubectl -n ingress-controller get configmap haproxy-ingress -o yaml
apiVersion: v1
data:
  healthz-port: "10253"
  stats-port: "1936"
kind: ConfigMap
metadata:
  annotations:
    meta.helm.sh/release-name: haproxy-ingress
    meta.helm.sh/release-namespace: ingress-controller
  creationTimestamp: "2023-08-03T07:20:16Z"
  labels:
    app.kubernetes.io/instance: haproxy-ingress
    app.kubernetes.io/managed-by: Helm
    app.kubernetes.io/name: haproxy-ingress
    app.kubernetes.io/version: v0.14.4
    helm.sh/chart: haproxy-ingress-0.14.4
  name: haproxy-ingress
  namespace: ingress-controller
  resourceVersion: "7131860"
  uid: 9ec57515-4a0e-4e65-8bf0-027658fb8944
  
# kubectl -n ingress-controller get configmap ingress-controller-leader-haproxy -o yaml
apiVersion: v1
kind: ConfigMap
metadata:
  annotations:
    control-plane.alpha.kubernetes.io/leader: '{"holderIdentity":"haproxy-ingress-d47cd45dc-jjvq6","leaseDurationSeconds":30,"acquireTime":"2023-08-03T07:26:26Z","renewTime":"2023-08-03T07:29:19Z","leaderTransitions":1}'
  creationTimestamp: "2023-08-03T07:20:21Z"
  name: ingress-controller-leader-haproxy
  namespace: ingress-controller
  resourceVersion: "7134544"
  uid: 74ccaddd-05fc-46ba-befe-0a2029b22401
```

```
# kubectl get svc echoserver. This has the ClusterIP for the sample pod.
NAME         TYPE        CLUSTER-IP    EXTERNAL-IP   PORT(S)    AGE
echoserver   ClusterIP   10.0.167.28   <none>        8080/TCP   3m45s

# kubectl get ingress echoserver. This uses the haproxy class.
NAME         CLASS     HOSTS              ADDRESS   PORTS     AGE
echoserver   haproxy   echoserver.local             80, 443   2m55s
```

```
# kubectl get ingressclass
NAME      CONTROLLER                             PARAMETERS   AGE
haproxy   haproxy-ingress.github.io/controller   <none>       24m

# kubectl describe ingressclass
Name:         haproxy
Labels:       app.kubernetes.io/instance=haproxy-ingress
              app.kubernetes.io/managed-by=Helm
              app.kubernetes.io/name=haproxy-ingress
              app.kubernetes.io/version=v0.14.4
              helm.sh/chart=haproxy-ingress-0.14.4
Annotations:  meta.helm.sh/release-name: haproxy-ingress
              meta.helm.sh/release-namespace: ingress-controller
Controller:   haproxy-ingress.github.io/controller
Events:       <none>
```

- https://haproxy-ingress.github.io/v0.14/docs/getting-started/
