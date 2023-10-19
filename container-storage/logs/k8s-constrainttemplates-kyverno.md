```
rg=rgpolicykyverno
az group create -n $rg -l $loc
az aks create -g $rg -n aks -s $vmsize -c 1
az aks get-credentials -g $rg -n aks --overwrite-existing

# https://kyverno.io/docs/installation/methods/
kubectl create -f https://github.com/kyverno/kyverno/releases/download/v1.10.0/install.yaml

kubectl get all -n kyverno --show-labels
```

```
NAME                                                 READY   STATUS              RESTARTS   AGE   LABELS
pod/kyverno-admission-controller-6bbdc7db58-fvm57    0/1     PodInitializing     0          15s   app.kubernetes.io/component=admission-controller,app.kubernetes.io/instance=kyverno,app.kubernetes.io/part-of=kyverno,app.kubernetes.io/version=v1.10.0,pod-template-hash=6bbdc7db58
pod/kyverno-background-controller-58b95559d7-trkk5   1/1     Running             0          15s   app.kubernetes.io/component=background-controller,app.kubernetes.io/instance=kyverno,app.kubernetes.io/part-of=kyverno,app.kubernetes.io/version=v1.10.0,pod-template-hash=58b95559d7
pod/kyverno-cleanup-controller-bfffd8845-rm92k       0/1     ContainerCreating   0          15s   app.kubernetes.io/component=cleanup-controller,app.kubernetes.io/instance=kyverno,app.kubernetes.io/part-of=kyverno,app.kubernetes.io/version=v1.10.0,pod-template-hash=bfffd8845
pod/kyverno-reports-controller-69c88b4c8f-xvp7l      0/1     ContainerCreating   0          15s   app.kubernetes.io/component=reports-controller,app.kubernetes.io/instance=kyverno,app.kubernetes.io/part-of=kyverno,app.kubernetes.io/version=v1.10.0,pod-template-hash=69c88b4c8f

NAME                                            TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)    AGE   LABELS
service/kyverno-background-controller-metrics   ClusterIP   10.0.147.236   <none>        8000/TCP   16s   app.kubernetes.io/component=background-controller,app.kubernetes.io/instance=kyverno,app.kubernetes.io/part-of=kyverno,app.kubernetes.io/version=v1.10.0
service/kyverno-cleanup-controller              ClusterIP   10.0.12.9      <none>        443/TCP    16s   app.kubernetes.io/component=cleanup-controller,app.kubernetes.io/instance=kyverno,app.kubernetes.io/part-of=kyverno,app.kubernetes.io/version=v1.10.0
service/kyverno-cleanup-controller-metrics      ClusterIP   10.0.183.166   <none>        8000/TCP   16s   app.kubernetes.io/component=cleanup-controller,app.kubernetes.io/instance=kyverno,app.kubernetes.io/part-of=kyverno,app.kubernetes.io/version=v1.10.0
service/kyverno-reports-controller-metrics      ClusterIP   10.0.153.249   <none>        8000/TCP   16s   app.kubernetes.io/component=reports-controller,app.kubernetes.io/instance=kyverno,app.kubernetes.io/part-of=kyverno,app.kubernetes.io/version=v1.10.0
service/kyverno-svc                             ClusterIP   10.0.153.103   <none>        443/TCP    16s   app.kubernetes.io/component=admission-controller,app.kubernetes.io/instance=kyverno,app.kubernetes.io/part-of=kyverno,app.kubernetes.io/version=v1.10.0
service/kyverno-svc-metrics                     ClusterIP   10.0.98.102    <none>        8000/TCP   16s   app.kubernetes.io/component=admission-controller,app.kubernetes.io/instance=kyverno,app.kubernetes.io/part-of=kyverno,app.kubernetes.io/version=v1.10.0

NAME                                            READY   UP-TO-DATE   AVAILABLE   AGE   LABELS
deployment.apps/kyverno-admission-controller    0/1     1            0           15s   app.kubernetes.io/component=admission-controller,app.kubernetes.io/instance=kyverno,app.kubernetes.io/part-of=kyverno,app.kubernetes.io/version=v1.10.0
deployment.apps/kyverno-background-controller   1/1     1            1           15s   app.kubernetes.io/component=background-controller,app.kubernetes.io/instance=kyverno,app.kubernetes.io/part-of=kyverno,app.kubernetes.io/version=v1.10.0
deployment.apps/kyverno-cleanup-controller      0/1     1            0           15s   app.kubernetes.io/component=cleanup-controller,app.kubernetes.io/instance=kyverno,app.kubernetes.io/part-of=kyverno,app.kubernetes.io/version=v1.10.0
deployment.apps/kyverno-reports-controller      0/1     1            0           15s   app.kubernetes.io/component=reports-controller,app.kubernetes.io/instance=kyverno,app.kubernetes.io/part-of=kyverno,app.kubernetes.io/version=v1.10.0

NAME                                                       DESIRED   CURRENT   READY   AGE   LABELS
replicaset.apps/kyverno-admission-controller-6bbdc7db58    1         1         0       16s   app.kubernetes.io/component=admission-controller,app.kubernetes.io/instance=kyverno,app.kubernetes.io/part-of=kyverno,app.kubernetes.io/version=v1.10.0,pod-template-hash=6bbdc7db58
replicaset.apps/kyverno-background-controller-58b95559d7   1         1         1       16s   app.kubernetes.io/component=background-controller,app.kubernetes.io/instance=kyverno,app.kubernetes.io/part-of=kyverno,app.kubernetes.io/version=v1.10.0,pod-template-hash=58b95559d7
replicaset.apps/kyverno-cleanup-controller-bfffd8845       1         1         0       16s   app.kubernetes.io/component=cleanup-controller,app.kubernetes.io/instance=kyverno,app.kubernetes.io/part-of=kyverno,app.kubernetes.io/version=v1.10.0,pod-template-hash=bfffd8845
replicaset.apps/kyverno-reports-controller-69c88b4c8f      1         1         0       16s   app.kubernetes.io/component=reports-controller,app.kubernetes.io/instance=kyverno,app.kubernetes.io/part-of=kyverno,app.kubernetes.io/version=v1.10.0,pod-template-hash=69c88b4c8f

NAME                                                      SCHEDULE       SUSPEND   ACTIVE   LAST SCHEDULE   AGE   LABELS
cronjob.batch/kyverno-cleanup-admission-reports           */10 * * * *   False     0        <none>          16s   app.kubernetes.io/instance=kyverno,app.kubernetes.io/part-of=kyverno,app.kubernetes.io/version=v1.10.0
cronjob.batch/kyverno-cleanup-cluster-admission-reports   */10 * * * *   False     0        <none>          16s   app.kubernetes.io/instance=kyverno,app.kubernetes.io/part-of=kyverno,app.kubernetes.io/version=v1.10.0
```

- https://learn.microsoft.com/en-us/azure/architecture/aws-professional/eks-to-aks/governance#kyverno
- https://learn.microsoft.com/en-us/troubleshoot/azure/azure-kubernetes/troubleshoot-apiserver-etcd: Verify that you don't have any custom admission webhook (such as the Kyverno policy engine) that's blocking the calls to the API server.
- https://kyverno.io/docs/troubleshooting/
- https://github.com/kyverno/kyverno
