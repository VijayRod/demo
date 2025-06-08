> ## k8s-csi-dynatrace

```
# dynatrace
# Refer to k8s unexpected to identify dynatrace in a cluster

# https://docs.dynatrace.com/docs/setup-and-configuration/setup-on-k8s/installation/cloud-native-fullstack#helm
```

- https://docs.dynatrace.com/docs/setup-and-configuration/setup-on-k8s/how-it-works#csi-driver
- https://www.dynatrace.com/
- https://docs.dynatrace.com/docs/setup-and-configuration/setup-on-k8s/installation/cloud-native-fullstack#helm

```
# dynatrace.dynatrace-operator (aka csi.oneagent.dynatrace.com) (aka CSI driver)

# install
# https://docs.dynatrace.com/docs/ingest-from/setup-on-k8s/deployment/full-stack-observability#helm
helm repo remove dynatrace
helm install dynatrace-operator oci://public.ecr.aws/dynatrace/dynatrace-operator \
   --create-namespace \
   --namespace dynatrace \
   --atomic
   
# To verify the current state of the deployments, try:
  $ kubectl get pods -n dynatrace
  $ kubectl logs -f deployment/dynatrace-operator -n dynatrace
  
kubectl get pods -n dynatrace
NAME                                  READY   STATUS    RESTARTS   AGE
dynatrace-oneagent-csi-driver-8d5m6   4/4     Running   0          3m1s
dynatrace-oneagent-csi-driver-tkrl6   4/4     Running   0          3m1s
dynatrace-operator-78d5786cd-8rghx    1/1     Running   0          3m1s
dynatrace-webhook-7f46c54667-74mbb    1/1     Running   0          3m1s
dynatrace-webhook-7f46c54667-kj7lt    1/1     Running   0          3m1s

kubectl get all -n dynatrace --show-labels
NAME                                      READY   STATUS    RESTARTS   AGE   LABELS
pod/dynatrace-oneagent-csi-driver-8d5m6   4/4     Running   0          17m   app.kubernetes.io/component=csi-driver,app.kubernetes.io/managed-by=Helm,app.kubernetes.io/name=dynatrace-operator,app.kubernetes.io/version=1.4.0,controller-revision-hash=6cd6c77655,helm.sh/chart=dynatrace-operator-1.4.0,internal.oneagent.dynatrace.com/app=csi-driver,internal.oneagent.dynatrace.com/component=csi-driver,pod-template-generation=1
pod/dynatrace-oneagent-csi-driver-tkrl6   4/4     Running   0          17m   app.kubernetes.io/component=csi-driver,app.kubernetes.io/managed-by=Helm,app.kubernetes.io/name=dynatrace-operator,app.kubernetes.io/version=1.4.0,controller-revision-hash=6cd6c77655,helm.sh/chart=dynatrace-operator-1.4.0,internal.oneagent.dynatrace.com/app=csi-driver,internal.oneagent.dynatrace.com/component=csi-driver,pod-template-generation=1
pod/dynatrace-operator-78d5786cd-8rghx    1/1     Running   0          17m   app.kubernetes.io/component=operator,app.kubernetes.io/managed-by=Helm,app.kubernetes.io/name=dynatrace-operator,app.kubernetes.io/version=1.4.0,helm.sh/chart=dynatrace-operator-1.4.0,name=dynatrace-operator,pod-template-hash=78d5786cd
pod/dynatrace-webhook-7f46c54667-74mbb    1/1     Running   0          17m   app.kubernetes.io/component=webhook,app.kubernetes.io/managed-by=Helm,app.kubernetes.io/name=dynatrace-operator,app.kubernetes.io/version=1.4.0,helm.sh/chart=dynatrace-operator-1.4.0,internal.dynatrace.com/app=webhook,internal.dynatrace.com/component=webhook,pod-template-hash=7f46c54667
pod/dynatrace-webhook-7f46c54667-kj7lt    1/1     Running   0          17m   app.kubernetes.io/component=webhook,app.kubernetes.io/managed-by=Helm,app.kubernetes.io/name=dynatrace-operator,app.kubernetes.io/version=1.4.0,helm.sh/chart=dynatrace-operator-1.4.0,internal.dynatrace.com/app=webhook,internal.dynatrace.com/component=webhook,pod-template-hash=7f46c54667

NAME                        TYPE        CLUSTER-IP    EXTERNAL-IP   PORT(S)   AGE   LABELS
service/dynatrace-webhook   ClusterIP   10.0.200.14   <none>        443/TCP   17m   app.kubernetes.io/component=webhook,app.kubernetes.io/managed-by=Helm,app.kubernetes.io/name=dynatrace-operator,app.kubernetes.io/version=1.4.0,helm.sh/chart=dynatrace-operator-1.4.0

NAME                                           DESIRED   CURRENT   READY   UP-TO-DATE   AVAILABLE   NODE SELECTOR   AGE   LABELS
daemonset.apps/dynatrace-oneagent-csi-driver   2         2         2       2            2           <none>
17m   app.kubernetes.io/component=csi-driver,app.kubernetes.io/managed-by=Helm,app.kubernetes.io/name=dynatrace-operator,app.kubernetes.io/version=1.4.0,helm.sh/chart=dynatrace-operator-1.4.0

NAME                                 READY   UP-TO-DATE   AVAILABLE   AGE   LABELS
deployment.apps/dynatrace-operator   1/1     1            1           17m   app.kubernetes.io/component=operator,app.kubernetes.io/managed-by=Helm,app.kubernetes.io/name=dynatrace-operator,app.kubernetes.io/version=1.4.0,dynatrace.com/install-source=helm,helm.sh/chart=dynatrace-operator-1.4.0
deployment.apps/dynatrace-webhook    2/2     2            2           17m   app.kubernetes.io/component=webhook,app.kubernetes.io/managed-by=Helm,app.kubernetes.io/name=dynatrace-operator,app.kubernetes.io/version=1.4.0,helm.sh/chart=dynatrace-operator-1.4.0

NAME                                           DESIRED   CURRENT   READY   AGE   LABELS
replicaset.apps/dynatrace-operator-78d5786cd   1         1         1       17m   app.kubernetes.io/component=operator,app.kubernetes.io/managed-by=Helm,app.kubernetes.io/name=dynatrace-operator,app.kubernetes.io/version=1.4.0,helm.sh/chart=dynatrace-operator-1.4.0,name=dynatrace-operator,pod-template-hash=78d5786cd
replicaset.apps/dynatrace-webhook-7f46c54667   2         2         2       17m   app.kubernetes.io/component=webhook,app.kubernetes.io/managed-by=Helm,app.kubernetes.io/name=dynatrace-operator,app.kubernetes.io/version=1.4.0,helm.sh/chart=dynatrace-operator-1.4.0,internal.dynatrace.com/app=webhook,internal.dynatrace.com/component=webhook,pod-template-hash=7f46c54667

k describe po -n dynatrace dynatrace-oneagent-csi-driver-8d5m6 | grep csi.oneag
      DRIVER_REG_SOCK_PATH:  /var/lib/kubelet/plugins/csi.oneagent.dynatrace.com/csi.sock
      /var/lib/kubelet/plugins/csi.oneagent.dynatrace.com/ from lockfile-dir (rw)
    Path:          /var/lib/kubelet/plugins/csi.oneagent.dynatrace.com/
    Path:          /var/lib/kubelet/plugins/csi.oneagent.dynatrace.com/data
    
k get csidriver
NAME                         ATTACHREQUIRED   PODINFOONMOUNT   STORAGECAPACITY   TOKENREQUESTS                REQUIRESREPUBLISH   MODES                  AGE
csi.oneagent.dynatrace.com   false            true             false             <unset>                      false               Ephemeral              48m
disk.csi.azure.com           true             false            false             <unset>                      false               Persistent             2d1h
file.csi.azure.com           false            true             false             api://AzureADTokenExchange   false               Persistent,Ephemeral   2d1h

k get sc
NAME                    PROVISIONER          RECLAIMPOLICY   VOLUMEBINDINGMODE      ALLOWVOLUMEEXPANSION   AGE
azurefile               file.csi.azure.com   Delete          Immediate              true                   2d1h
azurefile-csi           file.csi.azure.com   Delete          Immediate              true                   2d1h
azurefile-csi-premium   file.csi.azure.com   Delete          Immediate              true                   2d1h
azurefile-premium       file.csi.azure.com   Delete          Immediate              true                   2d1h
default (default)       disk.csi.azure.com   Delete          WaitForFirstConsumer   true                   2d1h
managed                 disk.csi.azure.com   Delete          WaitForFirstConsumer   true                   2d1h
managed-csi             disk.csi.azure.com   Delete          WaitForFirstConsumer   true                   2d1h
managed-csi-premium     disk.csi.azure.com   Delete          WaitForFirstConsumer   true                   2d1h
managed-premium         disk.csi.azure.com   Delete          WaitForFirstConsumer   true                   2d1h
```

- https://github.com/Dynatrace/dynatrace-operator/blob/main/README.md
- https://docs.dynatrace.com/docs/shortlink/how-it-works-k8s-operator#csidriver: The Dynatrace CSI driver provides OneAgent code modules for the application pods, while minimizing storage usage, and load on the Dynatrace environment.
- https://docs.dynatrace.com/docs/ingest-from/setup-on-k8s/deployment/troubleshooting: kubectl -n dynatrace logs -f deployment/dynatrace-operator

```
# dynatrace.dynatrace-operator.error.csi.oneagent.dynatrace.com not found in the list of registered CSI drivers
```

- https://github.com/Dynatrace/dynatrace-operator/issues/3490: csi.oneagent.dynatrace.com not found in the list of registered CSI drivers. Dynatrace responds to requests like these via Dynatrace ONE support (Support request)
- https://github.com/Dynatrace/dynatrace-operator/issues/4380: Upgrading Kubernetes version to 1.30.9, calico-node is failing with "driver name csi.oneagent.dynatrace.com not found in the list of registered CSI drivers". Dynatrace responds to requests like these via Dynatrace ONE support (Support request)


> ## k8s-csi-dynatrace.debug

- https://docs.dynatrace.com/docs/ingest-from/dynatrace-oneagent/oneagent-troubleshooting/oneagent-diagnostics#analyze-automatically

> ## k8s-csi-dynatrace.debug.profiling.memory-profiling
- https://www.dynatrace.com/news/blog/dynatrace-memory-analysis-helps-product-architects-identify-unknown-unknowns/
- https://docs.dynatrace.com/docs/observe/applications-and-microservices/profiling-and-optimization/memory-profiling
