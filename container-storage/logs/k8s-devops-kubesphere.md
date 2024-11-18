```
k logs -n kubesphere-system -l app=ks-installer
...
Start installing monitoring
Start installing multicluster
Start installing openpitrix
Start installing network
**************************************************
Waiting for all tasks to be completed ...
task network status is successful  (1/4)
task openpitrix status is successful  (2/4)
task multicluster status is successful  (3/4)


k get all -n kubesphere-system
NAME                                         READY   STATUS              RESTARTS   AGE     LABELS
pod/ks-apiserver-df5649bb5-rrvdk             0/1     ContainerCreating   0          2m11s   app=ks-apiserver,pod-template-hash=df5649bb5,tier=backend
pod/ks-console-6cd7f477cf-89nk9              1/1     Running             0          2m11s   app=ks-console,pod-template-hash=6cd7f477cf,tier=frontend
pod/ks-controller-manager-698466db56-fw5nd   0/1     ContainerCreating   0          2m11s   app=ks-controller-manager,pod-template-hash=698466db56,tier=backend
pod/ks-installer-9c8896984-x65jd             1/1     Running             0          4m49s   app=ks-installer,pod-template-hash=9c8896984

NAME                            TYPE           CLUSTER-IP    EXTERNAL-IP   PORT(S)        AGE     LABELS
service/ks-apiserver            ClusterIP      10.0.11.243   <none>        80/TCP         2m11s   app.kubernetes.io/managed-by=Helm,app=ks-apiserver,tier=backend,version=v3.1.0
service/ks-console              ClusterIP      10.0.11.245   <none>        80:30880/TCP   2m11s   app.kubernetes.io/managed-by=Helm,app=ks-console,tier=frontend,version=v3.1.0
service/ks-controller-manager   ClusterIP      10.0.41.172   <none>        443/TCP        2m11s   app.kubernetes.io/managed-by=Helm,app=ks-controller-manager,tier=backend,version=v3.1.0

NAME                                    READY   UP-TO-DATE   AVAILABLE   AGE     LABELS
deployment.apps/ks-apiserver            0/1     1            0           2m11s   app.kubernetes.io/managed-by=Helm,app=ks-apiserver,tier=backend,version=v3.1.0
deployment.apps/ks-console              1/1     1            1           2m11s   app.kubernetes.io/managed-by=Helm,app=ks-console,tier=frontend,version=v3.1.0
deployment.apps/ks-controller-manager   0/1     1            0           2m11s   app.kubernetes.io/managed-by=Helm,app=ks-controller-manager,tier=backend,version=v3.1.0
deployment.apps/ks-installer            1/1     1            1           4m50s   app=ks-installer

NAME                                               DESIRED   CURRENT   READY   AGE     LABELS
replicaset.apps/ks-apiserver-df5649bb5             1         1         0       2m11s   app=ks-apiserver,pod-template-hash=df5649bb5,tier=backend
replicaset.apps/ks-console-6cd7f477cf              1         1         1       2m11s   app=ks-console,pod-template-hash=6cd7f477cf,tier=frontend
replicaset.apps/ks-controller-manager-698466db56   1         1         0       2m11s   app=ks-controller-manager,pod-template-hash=698466db56,tier=backend
replicaset.apps/ks-installer-9c8896984             1         1         1       4m50s   app=ks-installer,pod-template-hash=9c8896984
```

- https://www.kubesphere.io/docs/v3.3/installing-on-kubernetes/hosted-kubernetes/install-kubesphere-on-aks/#deploy-kubesphere-on-aks
- https://www.kubesphere.io/docs/v3.3/introduction/what-is-kubesphere/: KubeSphere is a member of CNCF and a Kubernetes Conformance Certified platform, further enriching CNCF CLOUD NATIVE Landscape.
- https://www.kubesphere.io/docs/v3.3/workspace-administration/what-is-workspace/
