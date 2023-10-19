```
linkerd viz install | kubectl apply -f - # Install the viz extension into the 'linkerd-viz' namespace
linkerd viz check # Validate the extension works!
kubectl get all -n linkerd-viz --show-labels
```

```
NAME                                READY   STATUS    RESTARTS   AGE     LABELS
pod/metrics-api-85849cd6c5-dbx9j    2/2     Running   0          2m42s   component=metrics-api,linkerd.io/control-plane-ns=linkerd,linkerd.io/extension=viz,linkerd.io/proxy-deployment=metrics-api,linkerd.io/workload-ns=linkerd-viz,pod-template-hash=85849cd6c5
pod/prometheus-5c98895dcf-jd8c5     2/2     Running   0          2m40s   component=prometheus,linkerd.io/control-plane-ns=linkerd,linkerd.io/extension=viz,linkerd.io/proxy-deployment=prometheus,linkerd.io/workload-ns=linkerd-viz,namespace=linkerd-viz,pod-template-hash=5c98895dcf
pod/tap-5fdff649b6-fv74v            2/2     Running   0          2m39s   component=tap,linkerd.io/control-plane-ns=linkerd,linkerd.io/extension=viz,linkerd.io/proxy-deployment=tap,linkerd.io/workload-ns=linkerd-viz,namespace=linkerd-viz,pod-template-hash=5fdff649b6
pod/tap-injector-5588b69c7f-mshjd   2/2     Running   0          2m38s   component=tap-injector,linkerd.io/control-plane-ns=linkerd,linkerd.io/extension=viz,linkerd.io/proxy-deployment=tap-injector,linkerd.io/workload-ns=linkerd-viz,pod-template-hash=5588b69c7f
pod/web-645bd596d7-4jbc6            2/2     Running   0          2m37s   component=web,linkerd.io/control-plane-ns=linkerd,linkerd.io/extension=viz,linkerd.io/proxy-deployment=web,linkerd.io/workload-ns=linkerd-viz,namespace=linkerd-viz,pod-template-hash=645bd596d7

NAME                   TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)             AGE     LABELS
service/metrics-api    ClusterIP   10.0.128.149   <none>        8085/TCP            2m42s   component=metrics-api,linkerd.io/extension=viz
service/prometheus     ClusterIP   10.0.118.113   <none>        9090/TCP            2m40s   component=prometheus,linkerd.io/extension=viz,namespace=linkerd-viz
service/tap            ClusterIP   10.0.105.39    <none>        8088/TCP,443/TCP    2m40s   component=tap,linkerd.io/extension=viz,namespace=linkerd-viz
service/tap-injector   ClusterIP   10.0.183.32    <none>        443/TCP             2m38s   component=tap-injector,linkerd.io/extension=viz
service/web            ClusterIP   10.0.244.84    <none>        8084/TCP,9994/TCP   2m37s   component=web,linkerd.io/extension=viz,namespace=linkerd-viz

NAME                           READY   UP-TO-DATE   AVAILABLE   AGE     LABELS
deployment.apps/metrics-api    1/1     1            1           2m42s   app.kubernetes.io/name=metrics-api,app.kubernetes.io/part-of=Linkerd,app.kubernetes.io/version=stable-2.14.1,component=metrics-api,linkerd.io/extension=viz
deployment.apps/prometheus     1/1     1            1           2m40s   app.kubernetes.io/name=prometheus,app.kubernetes.io/part-of=Linkerd,app.kubernetes.io/version=stable-2.14.1,component=prometheus,linkerd.io/extension=viz,namespace=linkerd-viz
deployment.apps/tap            1/1     1            1           2m39s   app.kubernetes.io/name=tap,app.kubernetes.io/part-of=Linkerd,app.kubernetes.io/version=stable-2.14.1,component=tap,linkerd.io/extension=viz,namespace=linkerd-viz
deployment.apps/tap-injector   1/1     1            1           2m38s   app.kubernetes.io/name=tap-injector,app.kubernetes.io/part-of=Linkerd,component=tap-injector,linkerd.io/extension=viz
deployment.apps/web            1/1     1            1           2m37s   app.kubernetes.io/name=web,app.kubernetes.io/part-of=Linkerd,app.kubernetes.io/version=stable-2.14.1,component=web,linkerd.io/extension=viz,namespace=linkerd-viz

NAME                                      DESIRED   CURRENT   READY   AGE     LABELS
replicaset.apps/metrics-api-85849cd6c5    1         1         1       2m42s   component=metrics-api,linkerd.io/extension=viz,pod-template-hash=85849cd6c5
replicaset.apps/prometheus-5c98895dcf     1         1         1       2m40s   component=prometheus,linkerd.io/extension=viz,namespace=linkerd-viz,pod-template-hash=5c98895dcf
replicaset.apps/tap-5fdff649b6            1         1         1       2m39s   component=tap,linkerd.io/extension=viz,namespace=linkerd-viz,pod-template-hash=5fdff649b6
replicaset.apps/tap-injector-5588b69c7f   1         1         1       2m38s   component=tap-injector,linkerd.io/extension=viz,pod-template-hash=5588b69c7f
replicaset.apps/web-645bd596d7            1         1         1       2m37s   component=web,linkerd.io/extension=viz,namespace=linkerd-viz,pod-template-hash=645bd596d7
```

- https://github.com/linkerd/linkerd-viz
