```
linkerd check --pre                     # Validate that Linkerd can be installed (in the k8s cluster)
linkerd install --crds | kubectl apply -f - # Install the Linkerd CRDs
linkerd install | kubectl apply -f -    # Install the control plane into the 'linkerd' namespace
linkerd check                           # Validate everything worked!
kubectl get all -n linkerd --show-labels
```

```
NAME                                          READY   STATUS    RESTARTS   AGE     LABELS
pod/linkerd-destination-698954d54b-djm4s      4/4     Running   0          3m33s   linkerd.io/control-plane-component=destination,linkerd.io/control-plane-ns=linkerd,linkerd.io/proxy-deployment=linkerd-destination,linkerd.io/workload-ns=linkerd,pod-template-hash=698954d54b
pod/linkerd-identity-5d4fb75794-kgc4z         2/2     Running   0          3m34s   linkerd.io/control-plane-component=identity,linkerd.io/control-plane-ns=linkerd,linkerd.io/proxy-deployment=linkerd-identity,linkerd.io/workload-ns=linkerd,pod-template-hash=5d4fb75794
pod/linkerd-proxy-injector-86786666b7-pfgxz   2/2     Running   0          3m32s   linkerd.io/control-plane-component=proxy-injector,linkerd.io/control-plane-ns=linkerd,linkerd.io/proxy-deployment=linkerd-proxy-injector,linkerd.io/workload-ns=linkerd,pod-template-hash=86786666b7

NAME                                TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)    AGE     LABELS
service/linkerd-dst                 ClusterIP   10.0.218.0     <none>        8086/TCP   3m34s   linkerd.io/control-plane-component=destination,linkerd.io/control-plane-ns=linkerd
service/linkerd-dst-headless        ClusterIP   None           <none>        8086/TCP   3m34s   linkerd.io/control-plane-component=destination,linkerd.io/control-plane-ns=linkerd
service/linkerd-identity            ClusterIP   10.0.158.183   <none>        8080/TCP   3m34s   linkerd.io/control-plane-component=identity,linkerd.io/control-plane-ns=linkerd
service/linkerd-identity-headless   ClusterIP   None           <none>        8080/TCP   3m34s   linkerd.io/control-plane-component=identity,linkerd.io/control-plane-ns=linkerd
service/linkerd-policy              ClusterIP   None           <none>        8090/TCP   3m33s   linkerd.io/control-plane-component=destination,linkerd.io/control-plane-ns=linkerd
service/linkerd-policy-validator    ClusterIP   10.0.208.250   <none>        443/TCP    3m33s   linkerd.io/control-plane-component=destination,linkerd.io/control-plane-ns=linkerd
service/linkerd-proxy-injector      ClusterIP   10.0.72.147    <none>        443/TCP    3m32s   linkerd.io/control-plane-component=proxy-injector,linkerd.io/control-plane-ns=linkerd
service/linkerd-sp-validator        ClusterIP   10.0.101.1     <none>        443/TCP    3m33s   linkerd.io/control-plane-component=destination,linkerd.io/control-plane-ns=linkerd

NAME                                     READY   UP-TO-DATE   AVAILABLE   AGE     LABELS
deployment.apps/linkerd-destination      1/1     1            1           3m34s   app.kubernetes.io/name=destination,app.kubernetes.io/part-of=Linkerd,app.kubernetes.io/version=stable-2.14.1,linkerd.io/control-plane-component=destination,linkerd.io/control-plane-ns=linkerd
deployment.apps/linkerd-identity         1/1     1            1           3m35s   app.kubernetes.io/name=identity,app.kubernetes.io/part-of=Linkerd,app.kubernetes.io/version=stable-2.14.1,linkerd.io/control-plane-component=identity,linkerd.io/control-plane-ns=linkerd
deployment.apps/linkerd-proxy-injector   1/1     1            1           3m33s   app.kubernetes.io/name=proxy-injector,app.kubernetes.io/part-of=Linkerd,app.kubernetes.io/version=stable-2.14.1,linkerd.io/control-plane-component=proxy-injector,linkerd.io/control-plane-ns=linkerd

NAME                                                DESIRED   CURRENT   READY   AGE     LABELS
replicaset.apps/linkerd-destination-698954d54b      1         1         1       3m34s   linkerd.io/control-plane-component=destination,linkerd.io/control-plane-ns=linkerd,linkerd.io/proxy-deployment=linkerd-destination,linkerd.io/workload-ns=linkerd,pod-template-hash=698954d54b
replicaset.apps/linkerd-identity-5d4fb75794         1         1         1       3m35s   linkerd.io/control-plane-component=identity,linkerd.io/control-plane-ns=linkerd,linkerd.io/proxy-deployment=linkerd-identity,linkerd.io/workload-ns=linkerd,pod-template-hash=5d4fb75794
replicaset.apps/linkerd-proxy-injector-86786666b7   1         1         1       3m33s   linkerd.io/control-plane-component=proxy-injector,linkerd.io/control-plane-ns=linkerd,linkerd.io/proxy-deployment=linkerd-proxy-injector,linkerd.io/workload-ns=linkerd,pod-template-hash=86786666b7

NAME                              SCHEDULE      SUSPEND   ACTIVE   LAST SCHEDULE   AGE     LABELS
cronjob.batch/linkerd-heartbeat   32 18 * * *   False     0        <none>          3m33s   app.kubernetes.io/name=heartbeat,app.kubernetes.io/part-of=Linkerd,app.kubernetes.io/version=stable-2.14.1,linkerd.io/control-plane-component=heartbeat,linkerd.io/control-plane-ns=linkerd
```
